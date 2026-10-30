// lib/screens/kontak_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/app_provider.dart';
import '../models/app_models.dart';
import '../theme.dart';
import '../widgets/sos_dialog.dart';

class KontakScreen extends StatelessWidget {
  const KontakScreen({super.key});

  Future<void> _makeCall(BuildContext context, String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat melakukan panggilan ke $phone')),
        );
      }
    }
  }

  Future<void> _sendWhatsApp(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final formattedPhone = cleanPhone.startsWith('0')
        ? '62${cleanPhone.substring(1)}'
        : cleanPhone;

    final uri = Uri.parse(
      'https://wa.me/$formattedPhone?text=${Uri.encodeComponent('[DARURAT BANJIR] Halo, saya butuh bantuan darurat di wilayah Kota Bandar Lampung.')}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final contacts = provider.allEmergencyContacts;

        return Scaffold(
          backgroundColor: AppTheme.surface,
          appBar: AppBar(
            title: const Text('Kontak & Bantuan Darurat'),
            backgroundColor: AppTheme.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add_alt_1_outlined),
                tooltip: 'Tambah Kontak Pribadi',
                onPressed: () => _showAddContactDialog(context, provider),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Hero Panic SOS Box
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppTheme.emergencySosGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🚨', style: TextStyle(fontSize: 32)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pusat Komando Bencana',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Hubungi nomor penting di bawah atau aktifkan suar darurat jika terjebak arus air.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () => SosDialog.show(context),
                            icon: const Text('🆘',
                                style: TextStyle(fontSize: 14)),
                            label: const Text('BUKA MODE PANIC SOS'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red.shade900,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Title and Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Nomor Cepat Tanggap',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddContactDialog(context, provider),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Tambah Kontak',
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ...contacts.map((contact) => _ContactCard(
                    contact: contact,
                    onCall: () => _makeCall(context, contact.phone),
                    onWhatsApp: contact.phone.length > 5
                        ? () => _sendWhatsApp(context, contact.phone)
                        : null,
                    onDelete: contact.isCustom
                        ? () => provider.deleteCustomContact(contact.name)
                        : null,
                  )),

              const SizedBox(height: 20),
              const Text(
                'SOP Komunikasi Saat Terjebak',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const _ProcedureCard(
                step: '1',
                icon: '📍',
                title: 'Sebutkan Lokasi & Patokan',
                desc: 'Nama dusun, RT/RW, nomor rumah atau ciri tiang/pohon terdekat.',
              ),
              const _ProcedureCard(
                step: '2',
                icon: '👥',
                title: 'Data Jumlah Jiwa & Rentan',
                desc: 'Berapa orang dewasa, lansia, balita, atau orang yang sedang sakit.',
              ),
              const _ProcedureCard(
                step: '3',
                icon: '📏',
                title: 'Taksir Ketinggian Air',
                desc: 'Laporkan apakah air setinggi lutut, dada, atau sudah menyentuh atap.',
              ),
              const _ProcedureCard(
                step: '4',
                icon: '📱',
                title: 'Hemat Daya Baterai',
                desc: 'Jangan menutup panggilan sebelum petugas selesai mencatat posisi Anda.',
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.info.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Text('💡', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Simpan nomor darurat ini ke kontak telepon fisik Anda. Dalam situasi darurat banjir, nomor 112 dapat dihubungi bebas pulsa bahkan saat pulsa Anda habis.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }

  void _showAddContactDialog(BuildContext context, AppProvider provider) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tambah Kontak Keluarga / RT',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama / Hubungan',
                hintText: 'Contoh: Ketua RT 02 / Ayah',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon / WhatsApp',
                hintText: 'Contoh: 08123456789',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Keterangan',
                hintText: 'Contoh: Kontak keluarga terdekat',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final phone = phoneCtrl.text.trim();
              if (name.isNotEmpty && phone.isNotEmpty) {
                provider.addCustomContact(
                  EmergencyContact(
                    name: name,
                    phone: phone,
                    icon: '👤',
                    description: descCtrl.text.trim().isEmpty
                        ? 'Kontak Darurat Tersimpan'
                        : descCtrl.text.trim(),
                    isCustom: true,
                  ),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

// ── Contact Card ───────────────────────────────────────────────────────────
class _ContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final VoidCallback onCall;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onDelete;

  const _ContactCard({
    required this.contact,
    required this.onCall,
    this.onWhatsApp,
    this.onDelete,
  });

  Color get _cardColor =>
      contact.phone.length <= 3 ? AppTheme.statusBahaya : AppTheme.primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _cardColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(contact.icon, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          contact.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onDelete != null)
                        InkWell(
                          onTap: onDelete,
                          child: const Icon(Icons.delete_outline,
                              size: 18, color: Colors.red),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contact.description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contact.phone,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _cardColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Call Action Button
            IconButton.filled(
              onPressed: onCall,
              icon: const Icon(Icons.phone, size: 18),
              style: IconButton.styleFrom(backgroundColor: _cardColor),
              tooltip: 'Panggil ${contact.phone}',
            ),

            if (onWhatsApp != null) ...[
              const SizedBox(width: 6),
              IconButton.filled(
                onPressed: onWhatsApp,
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                ),
                tooltip: 'WhatsApp',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Procedure Card ─────────────────────────────────────────────────────────
class _ProcedureCard extends StatelessWidget {
  final String step, icon, title, desc;
  const _ProcedureCard({
    required this.step,
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              step,
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
