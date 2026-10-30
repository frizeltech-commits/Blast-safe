// lib/widgets/sos_dialog.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/app_provider.dart';
import '../theme.dart';

class SosDialog extends StatefulWidget {
  const SosDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SosDialog(),
    );
  }

  @override
  State<SosDialog> createState() => _SosDialogState();
}

class _SosDialogState extends State<SosDialog> {
  bool _isStrobeActive = false;
  bool _strobeState = false;
  Timer? _strobeTimer;
  final TextEditingController _noteCtrl = TextEditingController(
    text: 'TOLONG! Saya terjebak banjir dan membutuhkan evakuasi segera.',
  );

  @override
  void dispose() {
    _strobeTimer?.cancel();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _toggleStrobe() {
    setState(() {
      _isStrobeActive = !_isStrobeActive;
      if (_isStrobeActive) {
        _strobeTimer = Timer.periodic(const Duration(milliseconds: 300), (t) {
          if (mounted) {
            setState(() => _strobeState = !_strobeState);
          }
        });
      } else {
        _strobeTimer?.cancel();
        _strobeState = false;
      }
    });
  }

  Future<void> _sendWhatsAppSos(String phone, String text) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final formattedPhone = cleanPhone.startsWith('0')
        ? '62${cleanPhone.substring(1)}'
        : cleanPhone;

    final uri = Uri.parse(
      'https://wa.me/$formattedPhone?text=${Uri.encodeComponent(text)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Container(
      decoration: BoxDecoration(
        color: _isStrobeActive && _strobeState
            ? Colors.red.shade900
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.dangerGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🆘', style: TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PANIC SOS DARURAT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Kirim sinyal bahaya, panggil tim SAR, atau aktifkan suar evakuasi.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Strobe Visual Signal Button
            InkWell(
              onTap: _toggleStrobe,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _isStrobeActive
                      ? Colors.amber.shade100
                      : Colors.orange.shade50,
                  border: Border.all(
                    color: _isStrobeActive
                        ? Colors.amber.shade700
                        : Colors.orange.shade300,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isStrobeActive
                          ? Icons.flash_on
                          : Icons.flashlight_on_outlined,
                      color: _isStrobeActive
                          ? Colors.amber.shade900
                          : Colors.orange.shade800,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isStrobeActive
                                ? 'Lampu Sinyal Suar: AKTIF'
                                : 'Aktifkan Lampu Suar Evakuasi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.orange.shade900,
                            ),
                          ),
                          const Text(
                            'Layar berkedip terang sebagai sinyal penjemputan regu penyelamat di malam hari.',
                            style:
                                TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isStrobeActive,
                      activeColor: Colors.amber.shade800,
                      onChanged: (_) => _toggleStrobe(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Emergency Call Quick Grid
            const Text(
              'Panggilan Darurat Cepat',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _QuickCallButton(
                    title: '112',
                    subtitle: 'Darurat Bebas Pulsa',
                    icon: Icons.emergency,
                    color: const Color(0xFFDC2626),
                    onTap: () => _makePhoneCall('112'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickCallButton(
                    title: 'BPBD',
                    subtitle: 'Bandar Lampung',
                    icon: Icons.fire_truck,
                    color: const Color(0xFFEA580C),
                    onTap: () => _makePhoneCall('0721252741'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickCallButton(
                    title: 'Tagana',
                    subtitle: 'Relawan Dinsos',
                    icon: Icons.volunteer_activism,
                    color: const Color(0xFF0284C7),
                    onTap: () => _makePhoneCall('081279888990'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // WhatsApp Quick Dispatch with Auto-Location & Message
            const Text(
              'Pesan Darurat WhatsApp ke Posko Relawan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Tuliskan lokasi dan kondisi darurat Anda...',
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                final text =
                    '[SOS DARURAT BANJIR - KOTA BANDAR LAMPUNG]\n${_noteCtrl.text.trim()}\n\nStatus Wilayah: ${provider.state.statusLabel}\nKetinggian Air Sekitar: ${provider.waterSensor.currentLevelCm} cm\nDikirim melalui Aplikasi BlastSafe Bandar Lampung';
                _sendWhatsAppSos('0811790119', text);
              },
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              label: const Text('KIRIM SOS KE WHATSAPP POSKO'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup Layar SOS'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickCallButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickCallButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
