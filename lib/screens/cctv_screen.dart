// lib/screens/cctv_screen.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/app_provider.dart';
import '../models/app_models.dart';

class CctvScreen extends StatefulWidget {
  final String? initialCameraId;
  const CctvScreen({super.key, this.initialCameraId});

  @override
  State<CctvScreen> createState() => _CctvScreenState();
}

class _CctvScreenState extends State<CctvScreen>
    with SingleTickerProviderStateMixin {
  late int _selectedCamIndex;
  bool _isNightVision = false;
  double _zoomLevel = 1.0;
  Offset _panOffset = Offset.zero;
  late AnimationController _waveController;
  Timer? _clockTimer;
  DateTime _currentStreamTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedCamIndex = 0;
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() => _currentStreamTime = DateTime.now());
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.initialCameraId != null) {
      final cctvs = context.read<AppProvider>().cctvs;
      final idx = cctvs.indexWhere((c) => c.id == widget.initialCameraId);
      if (idx != -1) {
        _selectedCamIndex = idx;
      }
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }

  void _resetPtz() {
    setState(() {
      _zoomLevel = 1.0;
      _panOffset = Offset.zero;
    });
  }

  void _pan(double dx, double dy) {
    setState(() {
      _panOffset += Offset(dx, dy);
    });
  }

  void _zoom(double delta) {
    setState(() {
      _zoomLevel = (_zoomLevel + delta).clamp(1.0, 3.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final cctvs = provider.cctvs;
        if (cctvs.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Tidak ada CCTV terhubung')),
          );
        }

        final currentCam = cctvs[_selectedCamIndex.clamp(0, cctvs.length - 1)];
        final isCritical = currentCam.currentStatus.contains('Siaga') ||
            currentCam.currentStatus.contains('KRITIS');

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A), // Dark operational surface
          appBar: AppBar(
            backgroundColor: const Color(0xFF0B132B),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monitoring CCTV Siaga Banjir',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Kamera Streaming Real-Time • BPBD Kota Bandar Lampung',
                  style: TextStyle(fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isNightVision
                      ? Icons.nightlight_round
                      : Icons.wb_sunny_outlined,
                  color: _isNightVision ? Colors.amber : Colors.white70,
                ),
                tooltip: 'Mode Night Vision / IR',
                onPressed: () =>
                    setState(() => _isNightVision = !_isNightVision),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white70),
                tooltip: 'Muat Ulang Stream',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Stream CCTV direfresh (Latency: 42ms)'),
                      duration: Duration(milliseconds: 1200),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // ── CCTV Live Player Screen ──────────────────────────────────
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Video Stream Canvas Animation
                      ClipRect(
                        child: Transform.translate(
                          offset: _panOffset,
                          child: Transform.scale(
                            scale: _zoomLevel,
                            child: AnimatedBuilder(
                              animation: _waveController,
                              builder: (ctx, _) {
                                return CustomPaint(
                                  painter: _CctvStreamPainter(
                                    waveProgress: _waveController.value,
                                    waterLevelCm: currentCam.waterLevelCm,
                                    isNightVision: _isNightVision,
                                    cameraCode: currentCam.code,
                                    isRaining: provider.state.status !=
                                        FloodStatus.aman,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      // Scanlines & Grain Overlay
                      IgnorePointer(
                        child: CustomPaint(
                          painter: _ScanlineOverlayPainter(),
                        ),
                      ),

                      // Live Stamp Overlays (Top Row)
                      Positioned(
                        top: 10,
                        left: 12,
                        right: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isCritical
                                      ? Colors.red
                                      : Colors.white30,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: isCritical
                                          ? Colors.redAccent
                                          : const Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${currentCam.code} • LIVE',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                DateFormat('yyyy-MM-dd HH:mm:ss')
                                    .format(_currentStreamTime),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom Feed Overlay: Water level & telemetry
                      Positioned(
                        bottom: 8,
                        left: 12,
                        right: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isCritical
                                    ? Colors.red.withOpacity(0.85)
                                    : Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'TMA: ${currentCam.waterLevelCm} CM | ${currentCam.currentStatus.toUpperCase()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${currentCam.resolution} | ${currentCam.bitrateKbps} kbps',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── PTZ Controls Strip (Responsive, Compact & Bebas Overflow) ──
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF162032),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF334155), width: 0.8),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge Judul PTZ
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: const Color(0xFF0284C7).withOpacity(0.4),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.gamepad_outlined,
                                size: 13, color: Color(0xFF38BDF8)),
                            SizedBox(width: 5),
                            Text(
                              'PTZ',
                              style: TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Pan Buttons (Kiri, Atas, Bawah, Kanan)
                      _PtzIconButton(
                        icon: Icons.chevron_left_rounded,
                        tooltip: 'Geser Kiri',
                        onTap: () => _pan(-20, 0),
                      ),
                      const SizedBox(width: 4),
                      _PtzIconButton(
                        icon: Icons.expand_less_rounded,
                        tooltip: 'Geser Atas',
                        onTap: () => _pan(0, -20),
                      ),
                      const SizedBox(width: 4),
                      _PtzIconButton(
                        icon: Icons.expand_more_rounded,
                        tooltip: 'Geser Bawah',
                        onTap: () => _pan(0, 20),
                      ),
                      const SizedBox(width: 4),
                      _PtzIconButton(
                        icon: Icons.chevron_right_rounded,
                        tooltip: 'Geser Kanan',
                        onTap: () => _pan(20, 0),
                      ),

                      // Separator
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 1,
                        height: 20,
                        color: Colors.white24,
                      ),

                      // Zoom Controls
                      _PtzIconButton(
                        icon: Icons.remove_rounded,
                        tooltip: 'Perkecil Zoom',
                        onTap: () => _zoom(-0.2),
                      ),
                      const SizedBox(width: 5),

                      // Zoom Value Badge (Clickable to Reset)
                      Tooltip(
                        message: 'Klik untuk Reset Zoom & Posisi',
                        child: InkWell(
                          onTap: _resetPtz,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: (_zoomLevel > 1.0 || _panOffset != Offset.zero)
                                  ? const Color(0xFF38BDF8).withOpacity(0.2)
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: (_zoomLevel > 1.0 || _panOffset != Offset.zero)
                                    ? const Color(0xFF38BDF8)
                                    : Colors.white24,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${_zoomLevel.toStringAsFixed(1)}x',
                                  style: TextStyle(
                                    color: (_zoomLevel > 1.0 ||
                                            _panOffset != Offset.zero)
                                        ? const Color(0xFF38BDF8)
                                        : Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                if (_zoomLevel > 1.0 ||
                                    _panOffset != Offset.zero) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.restart_alt_rounded,
                                      size: 13, color: Color(0xFF38BDF8)),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      _PtzIconButton(
                        icon: Icons.add_rounded,
                        tooltip: 'Perbesar Zoom',
                        onTap: () => _zoom(0.2),
                      ),

                      // Separator
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 1,
                        height: 20,
                        color: Colors.white24,
                      ),

                      // Snapshot Action Button
                      _PtzIconButton(
                        icon: Icons.camera_alt_rounded,
                        tooltip: 'Ambil Tangkapan Layar CCTV',
                        color: const Color(0xFF34D399),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      color: Color(0xFF34D399), size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Snapshot ${currentCam.code} (${currentCam.name}) tersimpan.',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(milliseconds: 1500),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 6),

                      // Reset PTZ Action Button
                      _PtzIconButton(
                        icon: Icons.center_focus_strong_rounded,
                        tooltip: 'Reset Posisi & Zoom Kamera',
                        onTap: _resetPtz,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Camera Switcher List ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PILIH TITIK KAMERA CCTV',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${cctvs.length} Unit Aktif Online',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  itemCount: cctvs.length,
                  itemBuilder: (ctx, i) {
                    final cam = cctvs[i];
                    final isSelected = i == _selectedCamIndex;
                    final camAlert = cam.currentStatus.contains('Siaga') ||
                        cam.currentStatus.contains('KRITIS');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF131D31),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF38BDF8)
                              : Colors.white12,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            _selectedCamIndex = i;
                            _resetPtz();
                          });
                        },
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF0284C7).withOpacity(0.2)
                                : Colors.white10,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF38BDF8)
                                  : Colors.white12,
                            ),
                          ),
                          child: Icon(
                            Icons.videocam_outlined,
                            color: isSelected
                                ? const Color(0xFF38BDF8)
                                : Colors.white70,
                            size: 22,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              cam.code,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: isSelected
                                    ? const Color(0xFF38BDF8)
                                    : Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                cam.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(
                              cam.locationDescription,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.white54),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'TMA: ${cam.waterLevelCm} cm',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: camAlert
                                        ? Colors.redAccent
                                        : Colors.amberAccent,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  cam.currentStatus,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: camAlert
                                        ? Colors.redAccent
                                        : const Color(0xFF34D399),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Icon(
                          isSelected
                              ? Icons.play_circle_fill
                              : Icons.play_circle_outline,
                          color: isSelected
                              ? const Color(0xFF38BDF8)
                              : Colors.white38,
                          size: 26,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Realistic CCTV Simulation Stream Painter ────────────────────────────────
class _CctvStreamPainter extends CustomPainter {
  final double waveProgress;
  final int waterLevelCm;
  final bool isNightVision;
  final String cameraCode;
  final bool isRaining;

  _CctvStreamPainter({
    required this.waveProgress,
    required this.waterLevelCm,
    required this.isNightVision,
    required this.cameraCode,
    required this.isRaining,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint();
    if (isNightVision) {
      bgPaint.color = const Color(0xFF0A1F0D); // Greenish IR night vision
    } else {
      bgPaint.color = const Color(0xFF1E293B); // Dark slate landscape
    }
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // River banks / Concrete embankment walls
    final wallPaint = Paint()
      ..color = isNightVision ? const Color(0xFF1B3820) : const Color(0xFF334155);
    final leftWall = Path()
      ..moveTo(0, size.height * 0.3)
      ..lineTo(size.width * 0.22, size.height * 0.5)
      ..lineTo(size.width * 0.2, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(leftWall, wallPaint);

    final rightWall = Path()
      ..moveTo(size.width, size.height * 0.3)
      ..lineTo(size.width * 0.78, size.height * 0.5)
      ..lineTo(size.width * 0.8, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(rightWall, wallPaint);

    // Water level height calculation
    final waterHeightRatio = (waterLevelCm / 300).clamp(0.2, 0.85);
    final waterTop = size.height * (1.0 - (waterHeightRatio * 0.7));

    // Dynamic Flowing Water Waves
    final waterPaint = Paint();
    if (isNightVision) {
      waterPaint.color = const Color(0xFF144D25).withOpacity(0.85);
    } else {
      // Muddy river flood color if high, dark blue-green if normal
      waterPaint.color = waterLevelCm > 140
          ? const Color(0xFF785536).withOpacity(0.85) // muddy flood water
          : const Color(0xFF1E4E79).withOpacity(0.85);
    }

    final wavePath = Path();
    wavePath.moveTo(0, size.height);
    wavePath.lineTo(0, waterTop);

    for (double x = 0; x <= size.width; x += 15) {
      final y = waterTop +
          math.sin((x / size.width * 4 * math.pi) + (waveProgress * 2 * math.pi)) *
              6;
      wavePath.lineTo(x, y);
    }
    wavePath.lineTo(size.width, size.height);
    wavePath.close();
    canvas.drawPath(wavePath, waterPaint);

    // Water depth measuring staff (Peilschaal / Pengukur TMA)
    final staffPaint = Paint()
      ..color = isNightVision ? const Color(0xFF86EFAC) : Colors.yellow.shade700
      ..strokeWidth = 6;
    final staffX = size.width * 0.24;
    canvas.drawLine(
        Offset(staffX, size.height * 0.35), Offset(staffX, size.height * 0.95), staffPaint);

    // Tick marks on staff
    final tickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;
    for (double y = size.height * 0.35; y <= size.height * 0.95; y += 14) {
      canvas.drawLine(Offset(staffX - 4, y), Offset(staffX + 4, y), tickPaint);
    }

    // Crosshairs overlay in center
    final crosshairPaint = Paint()
      ..color = isNightVision
          ? const Color(0xFF4ADE80).withOpacity(0.4)
          : Colors.white30
      ..strokeWidth = 1.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawLine(Offset(cx - 20, cy), Offset(cx + 20, cy), crosshairPaint);
    canvas.drawLine(Offset(cx, cy - 20), Offset(cx, cy + 20), crosshairPaint);

    // Rain effect simulation if disaster warning is active
    if (isRaining) {
      final rainPaint = Paint()
        ..color = Colors.white.withOpacity(0.25)
        ..strokeWidth = 1.2;
      for (int i = 0; i < 35; i++) {
        final rx = (i * 19.0 + (waveProgress * 300)) % size.width;
        final ry = (i * 23.0 + (waveProgress * 450)) % size.height;
        canvas.drawLine(Offset(rx, ry), Offset(rx - 4, ry + 16), rainPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CctvStreamPainter old) => true;
}

// ── Subtle Scanline Filter ──────────────────────────────────────────────────
class _ScanlineOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..strokeWidth = 1.0;
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── PTZ Icon Button Component ───────────────────────────────────────────────
class _PtzIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color? color;

  const _PtzIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 18, color: color ?? Colors.white),
          ),
        ),
      ),
    );
  }
}
