// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_provider.dart';
import '../models/app_models.dart';
import '../theme.dart';
import 'admin_screen.dart';
import 'maps_screen.dart';
import 'cctv_screen.dart';
import 'shelter_screen.dart';
import 'panduan_screen.dart';
import 'kontak_screen.dart';
import 'laporan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final status = provider.state.status;
        final isAman = status == FloodStatus.aman;
        final statusColor = AppTheme.statusColor(status);

        return Scaffold(
          backgroundColor: AppTheme.surface,
          body: NestedScrollView(
            headerSliverBuilder: (ctx, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 210,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF0C2340),
                title: innerBoxIsScrolled
                    ? Row(
                        children: [
                          const Icon(Icons.water, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'BlastSafe Bandar Lampung',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              provider.state.statusLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    : null,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: _HomeHeader(
                    provider: provider,
                    isAman: isAman,
                    statusColor: statusColor,
                    onAdminTap: () => Navigator.push(
                      ctx,
                      MaterialPageRoute(builder: (_) => const AdminScreen()),
                    ),
                  ),
                ),
              ),
            ],
            body: _HomeBody(
              provider: provider,
              isAman: isAman,
              statusColor: statusColor,
            ),
          ),
        );
      },
    );
  }
}

// ── Header Expanded ────────────────────────────────────────────────────────
class _HomeHeader extends StatelessWidget {
  final AppProvider provider;
  final bool isAman;
  final Color statusColor;
  final VoidCallback onAdminTap;

  const _HomeHeader({
    required this.provider,
    required this.isAman,
    required this.statusColor,
    required this.onAdminTap,
  });

  String _formatIndonesianDate(DateTime dt) {
    const days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dayName = days[dt.weekday - 1];
    final monthName = months[dt.month - 1];
    return '$dayName, ${dt.day} $monthName ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final nowFormatted = _formatIndonesianDate(DateTime.now());

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0C2340), // Official Dark Slate Navy
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Institutional Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shield_outlined,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BLASTSAFE BANDAR LAMPUNG',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          '$nowFormatted • BPBD Kota Bandar Lampung',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white70,
                      size: 20,
                    ),
                    tooltip: 'Operator Desa',
                    onPressed: onAdminTap,
                  ),
                ],
              ),

              // Status Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'STATUS WILAYAH SAAT INI',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          provider.state.statusLabel,
                          style: TextStyle(
                            color: isAman ? Colors.white : Colors.amber.shade200,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isAman ? 'NORMAL' : 'PERINGATAN',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
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
    );
  }
}

// ── Body ───────────────────────────────────────────────────────────────────
class _HomeBody extends StatelessWidget {
  final AppProvider provider;
  final bool isAman;
  final Color statusColor;

  const _HomeBody({
    required this.provider,
    required this.isAman,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        // Warning banner if status is not safe
        if (!isAman && provider.showWarningBanner)
          GestureDetector(
            onTap: () => provider.dismissWarning(),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: statusColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peringatan Bencana: ${provider.state.statusLabel}',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        if (provider.state.warningMessage.isNotEmpty)
                          Text(
                            provider.state.warningMessage,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: statusColor, size: 18),
                    onPressed: () => provider.dismissWarning(),
                  ),
                ],
              ),
            ),
          ),

        // ── CCTV Live Monitoring Quick Preview Banner ─────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _CctvQuickPreviewCard(provider: provider),
        ),

        // ── Peta Spasial Quick Access Card ────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _MapsQuickAccessCard(provider: provider),
        ),

        // ── Water Level Sensor (TMA) ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _WaterSensorCard(sensor: provider.waterSensor),
        ),

        // ── Weather & Hidrometeorologi ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _WeatherCard(
            provider: provider,
            onTap: () => _showWeatherDetail(context, provider),
          ),
        ),

        // ── Quick Services Section ─────────────────────────────────────────
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 18, 16, 8),
          child: Text(
            'Layanan & Kesiapsiagaan Warga',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.45,
            children: [
              _MenuCard(
                icon: Icons.night_shelter_outlined,
                title: 'Posko Shelter',
                subtitle: '${provider.shelters.length} titik terdata',
                color: const Color(0xFF0F766E),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShelterScreen()),
                ),
              ),
              _MenuCard(
                icon: Icons.backpack_outlined,
                title: 'Tas Siaga 72 Jam',
                subtitle:
                    '${provider.checklistCompletedCount}/${provider.checklist.length} perlengkapan',
                color: const Color(0xFFB45309),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PanduanScreen()),
                ),
              ),
              _MenuCard(
                icon: Icons.menu_book_outlined,
                title: 'Panduan Darurat',
                subtitle: 'SOP Evakuasi & Medis',
                color: const Color(0xFF1D4ED8),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PanduanScreen()),
                ),
              ),
              _MenuCard(
                icon: Icons.contact_phone_outlined,
                title: 'Kontak Bantuan',
                subtitle: 'SAR, BPBD, Relawan',
                color: const Color(0xFFB91C1C),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KontakScreen()),
                ),
              ),
            ],
          ),
        ),

        // ── Citizen Field Reports ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Laporan Lapangan Warga',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LaporanScreen()),
                ),
                child: const Text(
                  'Kirim Laporan →',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: provider.reports.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Center(
                    child: Text(
                      'Tidak ada laporan genangan aktif dari warga.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: provider.reports
                      .take(2)
                      .map((r) => _ReportItem(report: r))
                      .toList(),
                ),
        ),
      ],
    );
  }

  void _showWeatherDetail(BuildContext context, AppProvider provider) {
    final s = provider.state.status;
    final data = _weatherData(s);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.cloud_outlined, color: AppTheme.primary),
                  SizedBox(width: 10),
                  Text(
                    'Informasi Hidrometeorologi BMKG',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _wRow('Kondisi Langit', data['kondisi']!),
              _wRow('Suhu Udara', data['suhu']!),
              _wRow('Curah Hujan', data['curahHujan']!),
              _wRow('Debit Aliran Sungai', data['airSungai']!),
              _wRow('Status Level Air', data['statusSungai']!),
              _wRow('Kecepatan Angin', data['angin']!),
              _wRow('Peringatan Dini BMKG', data['bmkg']!),
            ],
          ),
        ),
      ),
    );
  }

  static Map<String, String> _weatherData(FloodStatus s) {
    switch (s) {
      case FloodStatus.aman:
        return {
          'kondisi': 'Cerah Berawan',
          'suhu': '28°C',
          'curahHujan': '4 mm/jam (Ringan)',
          'airSungai': '0.85 m (Debit Normal)',
          'statusSungai': 'Aman – Dalam batas normal',
          'angin': '9 km/jam',
          'bmkg': 'Tidak ada peringatan cuaca ekstrem',
        };
      case FloodStatus.waspada:
        return {
          'kondisi': 'Hujan Sedang Terus-Menerus',
          'suhu': '24°C',
          'curahHujan': '45 mm/jam',
          'airSungai': '1.45 m (Ketinggian Meningkat)',
          'statusSungai': 'Waspada – Pantau debit hilir',
          'angin': '16 km/jam',
          'bmkg': 'Potensi hujan lebat disertai kilat sore hari',
        };
      case FloodStatus.siaga:
        return {
          'kondisi': 'Hujan Lebat Badai',
          'suhu': '22°C',
          'curahHujan': '90 mm/jam',
          'airSungai': '2.10 m (Mendekati Bibir Tanggul)',
          'statusSungai': 'Siaga 2 – Bersiap evakuasi',
          'angin': '30 km/jam',
          'bmkg': 'Peringatan dini banjir lokal wilayah bantaran',
        };
      case FloodStatus.bahaya:
        return {
          'kondisi': 'Hujan Sangat Lebat & Angin Kencang',
          'suhu': '21°C',
          'curahHujan': '185 mm/jam',
          'airSungai': '2.75 m (MELUAP / KRITIS)',
          'statusSungai': 'Siaga 1 – SEGERA EVAKUASI KE SHELTER',
          'angin': '48 km/jam',
          'bmkg': 'Status darurat banjir! Segera amankan jiwa',
        };
    }
  }

  Widget _wRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
}

// ── CCTV Quick Preview Card ─────────────────────────────────────────────────
class _CctvQuickPreviewCard extends StatelessWidget {
  final AppProvider provider;
  const _CctvQuickPreviewCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final cctvs = provider.cctvs;
    final primaryCam = cctvs.isNotEmpty ? cctvs[0] : null;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'LIVE CCTV MONITORING',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                '${cctvs.length} Titik Kamera Online',
                style: const TextStyle(
                  color: Color(0xFF34D399),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 72,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.videocam_outlined,
                  color: Color(0xFF38BDF8),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      primaryCam != null
                          ? '${primaryCam.code}: ${primaryCam.name}'
                          : 'CCTV Pintu Air Way Belau',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      primaryCam != null
                          ? 'TMA: ${primaryCam.waterLevelCm} cm • ${primaryCam.currentStatus}'
                          : 'Streaming 1080p FHD aktif',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CctvScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: const Text('Buka CCTV'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Maps Spasial Quick Access Card ──────────────────────────────────────────
class _MapsQuickAccessCard extends StatelessWidget {
  final AppProvider provider;
  const _MapsQuickAccessCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F2942).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.map_outlined,
              color: Color(0xFF0F2942),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peta Spasial & Titik Genangan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Lihat sebaran posko shelter, kamera CCTV, dan zona bahaya',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapsScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Lihat Peta', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ── Water Level Sensor Card ─────────────────────────────────────────────────
class _WaterSensorCard extends StatelessWidget {
  final WaterLevelSensor sensor;
  const _WaterSensorCard({required this.sensor});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.statusColor(sensor.floodStatus);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.waves, color: statusColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SENSOR TINGGI MUKA AIR (TMA)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      sensor.location,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  sensor.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${sensor.currentLevelCm}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: statusColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text(
                  'cm',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Tren Aliran: ${sensor.trend}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: sensor.levelFraction,
              minHeight: 8,
              backgroundColor: AppTheme.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weather Card ────────────────────────────────────────────────────────────
class _WeatherCard extends StatelessWidget {
  final AppProvider provider;
  final VoidCallback onTap;
  const _WeatherCard({required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = provider.state.status;
    final String label;
    final double air;

    switch (s) {
      case FloodStatus.aman:
        label = 'Cerah Berawan (Kondisi Normal)';
        air = 0.85;
        break;
      case FloodStatus.waspada:
        label = 'Hujan Sedang (Siaga 3)';
        air = 1.45;
        break;
      case FloodStatus.siaga:
        label = 'Hujan Lebat (Siaga 2)';
        air = 2.10;
        break;
      case FloodStatus.bahaya:
        label = 'Hujan Badai (Siaga 1 Kritis)';
        air = 2.75;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.cloud_outlined,
                  color: Color(0xFF0284C7), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Prakiraan Cuaca Stasiun BMKG • Ketuk detail',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            Text(
              'TMA: ${air}m',
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Menu Card ───────────────────────────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Report Item ────────────────────────────────────────────────────────────
class _ReportItem extends StatelessWidget {
  final WargaReport report;
  const _ReportItem({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: report.isVerified
                      ? AppTheme.statusAman.withOpacity(0.12)
                      : AppTheme.statusWaspada.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  report.isVerified ? 'Terverifikasi' : 'Belum Diverifikasi',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: report.isVerified
                        ? AppTheme.statusAman
                        : AppTheme.statusWaspada,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                report.category,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
              const Spacer(),
              Text(
                _ago(report.time),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            report.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 13, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  report.location,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'Kedalaman: ${report.waterDepth}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes} mnt lalu';
    if (d.inHours < 24) return '${d.inHours} jam lalu';
    return '${d.inDays} hari lalu';
  }
}
