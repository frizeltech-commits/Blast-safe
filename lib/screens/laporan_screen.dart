// lib/screens/laporan_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_provider.dart';
import '../models/app_models.dart';
import '../theme.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  String _category = 'Ketinggian Air';
  String _waterDepth = '30-70 cm';
  String _urgency = 'Penting';
  String _filterTag = 'Semua';

  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    context.read<AppProvider>().addReport(
          WargaReport(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            description: _descCtrl.text.trim(),
            location: _locationCtrl.text.trim(),
            time: DateTime.now(),
            reporterName: _nameCtrl.text.trim().isEmpty
                ? 'Warga Anonim'
                : _nameCtrl.text.trim(),
            category: _category,
            waterDepth: _waterDepth,
            urgency: _urgency,
            confirmations: 1,
          ),
        );

    _descCtrl.clear();
    _locationCtrl.clear();
    _nameCtrl.clear();
    setState(() {
      _isSubmitting = false;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final reports = provider.reports;
        final filteredReports = reports.where((r) {
          if (_filterTag == 'Butuh Evakuasi') {
            return r.category == 'Butuh Evakuasi' || r.urgency.contains('Darurat');
          }
          if (_filterTag == 'Jalan Terputus') {
            return r.category == 'Jalan Terputus';
          }
          if (_filterTag == 'Terverifikasi') {
            return r.isVerified;
          }
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: AppTheme.surface,
          appBar: AppBar(
            title: const Text('Laporan & Situasi Lapangan'),
            backgroundColor: AppTheme.primary,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_submitted)
                _SuccessBanner(
                  onReset: () => setState(() => _submitted = false),
                )
              else
                _FormCard(
                  formKey: _formKey,
                  descCtrl: _descCtrl,
                  locationCtrl: _locationCtrl,
                  nameCtrl: _nameCtrl,
                  category: _category,
                  waterDepth: _waterDepth,
                  urgency: _urgency,
                  onCategoryChanged: (v) => setState(() => _category = v),
                  onDepthChanged: (v) => setState(() => _waterDepth = v),
                  onUrgencyChanged: (v) => setState(() => _urgency = v),
                  isSubmitting: _isSubmitting,
                  onSubmit: _submit,
                ),
              const SizedBox(height: 22),

              // Filter Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Laporan Warga di Lapangan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${reports.length} laporan',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Filter tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('Semua'),
                    _filterChip('Butuh Evakuasi'),
                    _filterChip('Jalan Terputus'),
                    _filterChip('Terverifikasi'),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              if (filteredReports.isEmpty)
                Container(
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Text('📭', style: TextStyle(fontSize: 40)),
                        SizedBox(height: 10),
                        Text(
                          'Tidak ada laporan pada kategori ini',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...filteredReports.map(
                  (r) => _ReportCard(
                    report: r,
                    onConfirm: () => provider.confirmReport(r.id),
                  ),
                ),
              const SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _filterTag == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _filterTag = label),
        selectedColor: AppTheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textPrimary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

// ── Form Input Card ─────────────────────────────────────────────────────────
class _FormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController descCtrl, locationCtrl, nameCtrl;
  final String category, waterDepth, urgency;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onDepthChanged;
  final ValueChanged<String> onUrgencyChanged;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _FormCard({
    required this.formKey,
    required this.descCtrl,
    required this.locationCtrl,
    required this.nameCtrl,
    required this.category,
    required this.waterDepth,
    required this.urgency,
    required this.onCategoryChanged,
    required this.onDepthChanged,
    required this.onUrgencyChanged,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('📝', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kirim Laporan Lapangan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Informasi Anda langsung diterima warga dan Posko Relawan',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Kategori Laporan Dropdown / Selector
            const Text(
              'Kategori Situasi',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                'Ketinggian Air',
                'Butuh Evakuasi',
                'Jalan Terputus',
                'Bantuan Logistik',
              ].map((cat) {
                final selected = category == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  selectedColor: AppTheme.primary,
                  onSelected: (_) => onCategoryChanged(cat),
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.white : AppTheme.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Estimasi Ketinggian Air
            const Text(
              'Perkiraan Ketinggian Air',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                '10-30 cm',
                '30-70 cm',
                '70-120 cm',
                '> 120 cm (Dada)',
              ].map((d) {
                final selected = waterDepth == d;
                return ChoiceChip(
                  label: Text(d),
                  selected: selected,
                  selectedColor: Colors.teal.shade700,
                  onSelected: (_) => onDepthChanged(d),
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.white : AppTheme.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Tingkat Urgensi
            const Text(
              'Tingkat Urgensi',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: ['Normal', 'Penting', 'Darurat Kritis'].map((urg) {
                final selected = urgency == urg;
                final Color chipColor = urg == 'Darurat Kritis'
                    ? Colors.red.shade700
                    : (urg == 'Penting' ? Colors.orange.shade700 : Colors.blueGrey);
                return ChoiceChip(
                  label: Text(urg),
                  selected: selected,
                  selectedColor: chipColor,
                  onSelected: (_) => onUrgencyChanged(urg),
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.white : AppTheme.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Pelapor (Opsional)',
                prefixIcon: Icon(Icons.person_outline),
                hintText: 'Nama Anda / Anonim',
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Lokasi Kejadian Lengkap *',
                prefixIcon: Icon(Icons.location_on_outlined),
                hintText: 'Contoh: Depan Underpass Unila / Pasir Gintung / Teluk Betung',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Lokasi wajib diisi' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Kondisi Lapangan *',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.description_outlined),
                ),
                hintText:
                    'Jelaskan kondisi jalan, korban terjebak, atau arus air...',
                alignLabelWithHint: true,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Deskripsi wajib diisi' : null,
            ),
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : onSubmit,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  isSubmitting ? 'Mengirim Laporan...' : 'KIRIM LAPORAN SEKARANG',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Success Banner ──────────────────────────────────────────────────────────
class _SuccessBanner extends StatelessWidget {
  final VoidCallback onReset;
  const _SuccessBanner({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.statusAman.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.statusAman.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          const Text('✅', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 10),
          const Text(
            'Laporan Berhasil Diterbitkan!',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppTheme.statusAman,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Laporan Anda telah tersimpan dan disebarkan ke papan pantau desa serta regu siaga bencana.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onReset,
            child: const Text('Kirim Laporan Baru'),
          ),
        ],
      ),
    );
  }
}

// ── Report Card ────────────────────────────────────────────────────────────
class _ReportCard extends StatelessWidget {
  final WargaReport report;
  final VoidCallback onConfirm;

  const _ReportCard({
    required this.report,
    required this.onConfirm,
  });

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    final isUrgentCritical = report.urgency.contains('Darurat');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgentCritical
              ? Colors.red.shade300
              : AppTheme.border,
          width: isUrgentCritical ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: report.isVerified
                      ? AppTheme.statusAman.withOpacity(0.12)
                      : AppTheme.statusWaspada.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  report.isVerified ? '✅ Terverifikasi' : '⏳ Menunggu Validasi',
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  report.category,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _timeAgo(report.time),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            report.description,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),

          // Location and Water Depth Tags
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on,
                    size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    report.location,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Air: ${report.waterDepth}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Reporter info & community confirmation button
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 13, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(
                report.reporterName,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onConfirm,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.thumb_up_alt_outlined,
                          size: 13, color: AppTheme.primary),
                      const SizedBox(width: 5),
                      Text(
                        'Konfirmasi (${report.confirmations})',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
