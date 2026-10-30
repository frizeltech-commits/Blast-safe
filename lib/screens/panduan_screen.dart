// lib/screens/panduan_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_provider.dart';
import '../models/app_models.dart';
import '../theme.dart';

class PanduanScreen extends StatefulWidget {
  const PanduanScreen({super.key});

  @override
  State<PanduanScreen> createState() => _PanduanScreenState();
}

class _PanduanScreenState extends State<PanduanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppTheme.surface,
          appBar: AppBar(
            title: const Text('Panduan & Kesiapsiagaan'),
            backgroundColor: AppTheme.primary,
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              tabs: [
                Tab(
                  child: Row(
                    children: [
                      const Text('🎒 Tas Siaga'),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${provider.checklistCompletedCount}/${provider.checklist.length}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const Tab(text: '⚡ Pra-Banjir'),
                const Tab(text: '🌊 Saat Banjir'),
                const Tab(text: '🌱 Pasca Banjir'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _TabTasSiaga(provider: provider),
              _TabPraBanjir(tips: provider.safetyTips),
              const _TabSaatBanjir(),
              const _TabPascaBanjir(),
            ],
          ),
        );
      },
    );
  }
}

// ── Tab 1: Interactive Tas Siaga Bencana (72-Hour Kit) ───────────────────────
class _TabTasSiaga extends StatefulWidget {
  final AppProvider provider;
  const _TabTasSiaga({required this.provider});

  @override
  State<_TabTasSiaga> createState() => _TabTasSiagaState();
}

class _TabTasSiagaState extends State<_TabTasSiaga> {
  String _selectedCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final allItems = provider.checklist;
    final filtered = _selectedCategory == 'Semua'
        ? allItems
        : allItems.where((i) => i.category == _selectedCategory).toList();

    final pct = (provider.checklistProgress * 100).toInt();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Progress Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🎒', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Checklist Tas Siaga 72 Jam',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Perlengkapan wajib bertahan mandiri selama 3 hari pertama bencana.',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _confirmReset(context, provider),
                    child: const Text('Reset',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kesiapan: $pct%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${provider.checklistCompletedCount} dari ${provider.checklist.length} siap',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: provider.checklistProgress,
                  minHeight: 10,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    pct == 100
                        ? const Color(0xFF10B981)
                        : (pct >= 50
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFFFBBF24)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Filter Categories
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _categoryChip('Semua'),
              _categoryChip('Dokumen & Finansial'),
              _categoryChip('Pangan & Nutrisi'),
              _categoryChip('Medis & Kesehatan'),
              _categoryChip('Peralatan Bertahan'),
              _categoryChip('Sandang'),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Items Checklist
        ...filtered.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: item.isChecked
                    ? AppTheme.statusAman.withOpacity(0.5)
                    : AppTheme.border,
                width: item.isChecked ? 1.5 : 1.0,
              ),
            ),
            child: CheckboxListTile(
              value: item.isChecked,
              activeColor: AppTheme.statusAman,
              checkboxShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              onChanged: (_) => provider.toggleChecklistItem(item.id),
              title: Text(
                item.title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: item.isChecked
                      ? AppTheme.textPrimary
                      : AppTheme.textPrimary,
                  decoration: item.isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: Text(
                item.subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
              secondary: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _categoryEmoji(item.category),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _categoryChip(String label) {
    final isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedCategory = label),
        selectedColor: AppTheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textPrimary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }

  String _categoryEmoji(String cat) {
    switch (cat) {
      case 'Dokumen & Finansial':
        return '📁';
      case 'Pangan & Nutrisi':
        return '🥫';
      case 'Medis & Kesehatan':
        return '💊';
      case 'Peralatan Bertahan':
        return '🔦';
      case 'Sandang':
        return '👕';
      default:
        return '📦';
    }
  }

  void _confirmReset(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Checklist?'),
        content: const Text(
            'Seluruh centang pada Tas Siaga Bencana akan direset kembali.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.resetChecklist();
              Navigator.pop(ctx);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

// ── Tab 2: Pra-Banjir ───────────────────────────────────────────────────────
class _TabPraBanjir extends StatelessWidget {
  final List<SafetyTip> tips;
  const _TabPraBanjir({required this.tips});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader(
          icon: '⚡',
          title: 'Kesiapsiagaan Pra-Banjir',
          subtitle: 'Tindakan pencegahan saat wilayah memasuki musim hujan lebat',
          color: AppTheme.primary,
        ),
        const SizedBox(height: 14),
        ...tips.asMap().entries.map(
              (e) => _TipCard(
                number: e.key + 1,
                icon: e.value.icon,
                title: e.value.title,
                description: e.value.description,
              ),
            ),
      ],
    );
  }
}

// ── Tab 3: Saat Banjir ──────────────────────────────────────────────────────
class _TabSaatBanjir extends StatelessWidget {
  const _TabSaatBanjir();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SectionHeader(
          icon: '🌊',
          title: 'Protokol Darurat Saat Banjir',
          subtitle: 'Prioritaskan keselamatan jiwa di atas harta benda',
          color: AppTheme.danger,
        ),
        SizedBox(height: 14),
        _StepCard(
          step: 1,
          icon: '⚡',
          title: 'Putus Jalur Listrik & Gas',
          description:
              'Matikan saklar MCB utama sebelum air merendam stopkontak. Cabut regulator tabung gas LPJ dan amankan ke tempat tinggi.',
          isUrgent: true,
        ),
        _StepCard(
          step: 2,
          icon: '🚪',
          title: 'Segera Evakuasi Menuju Shelter',
          description:
              'Jangan menunda evakuasi hingga air mencapai leher. Bawa anak-anak, lansia, dan ibu hamil terlebih dahulu ke posko shelter resmi desa.',
          isUrgent: true,
        ),
        _StepCard(
          step: 3,
          icon: '🚫',
          title: 'Hindari Arus Air & Selokan Terbuka',
          description:
              'Jangan nekat menerobos banjir dengan motor atau berjalan tanpa tongkat. Arus 15 cm sudah sanggup menggulingkan orang dewasa.',
          isUrgent: true,
        ),
        _StepCard(
          step: 4,
          icon: '🔦',
          title: 'Beri Sinyal Bantuan Jika Terjebak',
          description:
              'Gunakan peluit, senter berkedip, atau fitur Sinyal Suar di tombol SOS aplikasi BlastSafe untuk memandu perahu penyelamat regu SAR.',
          isUrgent: true,
        ),
        _StepCard(
          step: 5,
          icon: '📱',
          title: 'Laporkan Titik Koordinat Anda',
          description:
              'Kirimkan laporan darurat atau kontak regu relawan desa lewat menu Laporan dan Kontak di aplikasi.',
          isUrgent: false,
        ),
        SizedBox(height: 10),
        _WarningBox(
          title: '⛔ PANTANGAN KERAS SAAT BANJIR',
          items: [
            'Jangan menyentuh tiang listrik, kabel putus, atau gardu transformator',
            'Jangan biarkan anak-anak bermain atau berenang di genangan air banjir',
            'Jangan berkendara menerobos jembatan yang mulai tergenang arus deras',
            'Jangan kembali ke rumah terendam untuk mengambil barang sebelum air surut total',
          ],
        ),
      ],
    );
  }
}

// ── Tab 4: Pasca Banjir ─────────────────────────────────────────────────────
class _TabPascaBanjir extends StatelessWidget {
  const _TabPascaBanjir();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SectionHeader(
          icon: '🌱',
          title: 'Pemulihan Pasca Banjir',
          subtitle: 'Langkah aman kembali ke rumah dan sterilisasi lingkungan',
          color: AppTheme.success,
        ),
        SizedBox(height: 14),
        _StepCard(
          step: 1,
          icon: '🔍',
          title: 'Pemeriksaan Struktur Bangunan',
          description:
              'Waspada retakan pondasi atau dinding miring akibat tanah longsor/labil. Jangan masuk bila kondisi rumah tidak stabil.',
          isUrgent: true,
        ),
        _StepCard(
          step: 2,
          icon: '💡',
          title: 'Uji Kelayakan Instalasi Listrik',
          description:
              'Pastikan semua saklar dan kabel telah kering sempurna sebelum MCB dinyalakan kembali. Minta bantuan teknisi jika ragu.',
          isUrgent: true,
        ),
        _StepCard(
          step: 3,
          icon: '🧹',
          title: 'Disinfeksi Lumpur & Kuman',
          description:
              'Gunakan sarung tangan karet dan sepatu bot saat membersihkan lumpur. Gunakan cairan karbol/disinfektan untuk mencegah bakteri Leptospira.',
          isUrgent: false,
        ),
        _StepCard(
          step: 4,
          icon: '💧',
          title: 'Sterilisasi Sumber Air Bersih',
          description:
              'Kuras sumur yang tercemar lumpur banjir dan rebus air minum sampai mendidih minimal 3 menit sebelum dikonsumsi.',
          isUrgent: false,
        ),
      ],
    );
  }
}

// ── Helper Widgets ──────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
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

class _TipCard extends StatelessWidget {
  final int number;
  final String icon;
  final String title;
  final String description;

  const _TipCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.4,
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

class _StepCard extends StatelessWidget {
  final int step;
  final String icon;
  final String title;
  final String description;
  final bool isUrgent;

  const _StepCard({
    required this.step,
    required this.icon,
    required this.title,
    required this.description,
    required this.isUrgent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUrgent ? Colors.red.shade200 : AppTheme.border,
          width: isUrgent ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isUrgent
                  ? Colors.red.shade100
                  : AppTheme.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '$step',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isUrgent ? Colors.red.shade800 : AppTheme.info,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    if (isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: const Text(
                          'Prioritas',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.4,
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

class _WarningBox extends StatelessWidget {
  final String title;
  final List<String> items;

  const _WarningBox({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.red.shade900,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade900,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
