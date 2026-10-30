// lib/screens/admin_screen.dart
// FULL: tambah shelter, hapus shelter, edit shelter, update status, verifikasi laporan

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_provider.dart';
import '../models/app_models.dart';
import '../theme.dart';

// ── Entry: Login atau Dashboard ────────────────────────────────────────────
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _userCtrl = TextEditingController(text: 'admin');
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        if (provider.state.isLoggedIn) {
          return _AdminDashboard(onLogout: provider.logout);
        }
        return _buildLogin();
      },
    );
  }

  Widget _buildLogin() {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
          title: const Text('Login Admin'), backgroundColor: AppTheme.primary),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: const Center(
                  child: Text('🛡️', style: TextStyle(fontSize: 38))),
            ),
            const SizedBox(height: 16),
            const Text('Portal Admin BlastSafe',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
            const Text('Masuk untuk kelola data desa',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border)),
              child: Column(children: [
                TextField(
                  controller: _userCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  onSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppTheme.statusBahaya.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(_error!,
                        style: const TextStyle(
                            color: AppTheme.statusBahaya, fontSize: 12)),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: _login, child: const Text('Masuk')),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  void _login() {
    final provider = context.read<AppProvider>();
    if (_userCtrl.text.trim() == 'admin' && _passCtrl.text == 'admin123') {
      provider.login(_userCtrl.text.trim());
      setState(() => _error = null);
    } else {
      setState(
          () => _error = 'Username atau password salah. Silakan coba lagi.');
    }
  }
}

// ── Dashboard ─────────────────────────────────────────────────────────────
class _AdminDashboard extends StatefulWidget {
  final VoidCallback onLogout;
  const _AdminDashboard({required this.onLogout});
  @override
  State<_AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<_AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) => Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(
          title: const Row(children: [
            Text('🛡️', style: TextStyle(fontSize: 16)),
            SizedBox(width: 8),
            Text('Dashboard Admin'),
          ]),
          backgroundColor: AppTheme.primary,
          actions: [
            TextButton.icon(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout, color: Colors.white, size: 16),
              label:
                  const Text('Keluar', style: TextStyle(color: Colors.white)),
            ),
          ],
          bottom: TabBar(
            controller: _tab,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            tabs: const [
              Tab(text: 'Status & Cuaca'),
              Tab(text: 'Kelola Shelter'),
              Tab(text: 'Laporan'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tab,
          children: [
            _TabStatus(provider: provider),
            _TabShelter(provider: provider),
            _TabLaporan(provider: provider),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// TAB 1 — Status Wilayah
// ══════════════════════════════════════════════════════════════════
class _TabStatus extends StatefulWidget {
  final AppProvider provider;
  const _TabStatus({required this.provider});
  @override
  State<_TabStatus> createState() => _TabStatusState();
}

class _TabStatusState extends State<_TabStatus> {
  late FloodStatus _selected;
  final _msgCtrl = TextEditingController();
  late int _sensorCm;
  late String _sensorTrend;
  bool _init = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_init) {
      _selected = widget.provider.state.status;
      _msgCtrl.text = widget.provider.state.warningMessage;
      _sensorCm = widget.provider.waterSensor.currentLevelCm;
      _sensorTrend = widget.provider.waterSensor.trend;
      _init = true;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1565C0)]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            const Text('🛡️', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Halo, ${widget.provider.state.adminUser}!',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  const Text('Pusdalops BPBD Kota Bandar Lampung',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                '${widget.provider.state.statusEmoji} ${widget.provider.state.statusLabel}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // Pilih status
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Text('🚦', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text('Update Status Wilayah',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
              ]),
              const SizedBox(height: 6),
              const Text(
                'Pilih level status, lalu isi pesan untuk ditampilkan ke warga.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 14),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: FloodStatus.values
                    .map((s) => _StatusBtn(
                          status: s,
                          isSelected: _selected == s,
                          onTap: () => setState(() => _selected = s),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _msgCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Pesan untuk Warga',
                  hintText:
                      'Contoh: Curah hujan tinggi. Warga bantaran sungai harap siaga.',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.message_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.provider.updateStatus(_selected, _msgCtrl.text);
                    _showSnack(
                        context, '✅ Status diperbarui!', AppTheme.statusAman);
                  },
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('Kirim Update Status'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // NEW: Kalibrasi Sensor TMA
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('🌊', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    'Kalibrasi Sensor TMA (Tinggi Muka Air)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Sesuaikan ketinggian air sungai (cm) dan tren aliran untuk pemantauan presisi warga.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ketinggian Saat Ini:',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(
                    '$_sensorCm cm',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _sensorCm.toDouble(),
                min: 20,
                max: 300,
                divisions: 56,
                activeColor: AppTheme.primary,
                label: '$_sensorCm cm',
                onChanged: (v) => setState(() => _sensorCm = v.toInt()),
              ),
              const SizedBox(height: 8),
              const Text('Tren Debit Air:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: ['Stabil', 'Naik', 'Turun', 'Naik Cepat'].map((t) {
                  final sel = _sensorTrend == t;
                  return ChoiceChip(
                    label: Text(t),
                    selected: sel,
                    onSelected: (_) => setState(() => _sensorTrend = t),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    widget.provider.updateWaterSensor(
                      levelCm: _sensorCm,
                      trend: _sensorTrend,
                    );
                    _showSnack(
                      context,
                      '✅ Data sensor TMA berhasil dikalibrasi!',
                      AppTheme.statusAman,
                    );
                  },
                  icon: const Icon(Icons.waves, size: 16),
                  label: const Text('Simpan Kalibrasi Sensor'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusBtn extends StatelessWidget {
  final FloodStatus status;
  final bool isSelected;
  final VoidCallback onTap;
  const _StatusBtn(
      {required this.status, required this.isSelected, required this.onTap});

  String get label {
    switch (status) {
      case FloodStatus.aman:
        return '✅ AMAN';
      case FloodStatus.waspada:
        return '⚠️ WASPADA';
      case FloodStatus.siaga:
        return '🔶 SIAGA';
      case FloodStatus.bahaya:
        return '🚨 BAHAYA';
    }
  }

  Color get color {
    switch (status) {
      case FloodStatus.aman:
        return AppTheme.statusAman;
      case FloodStatus.waspada:
        return AppTheme.statusWaspada;
      case FloodStatus.siaga:
        return AppTheme.statusSiaga;
      case FloodStatus.bahaya:
        return AppTheme.statusBahaya;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: isSelected ? 2 : 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ]
              : [],
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// TAB 2 — Kelola Shelter (CRUD: tambah, edit, hapus)
// ══════════════════════════════════════════════════════════════════
class _TabShelter extends StatelessWidget {
  final AppProvider provider;
  const _TabShelter({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header tombol tambah
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text('${provider.shelters.length} Shelter Terdaftar',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      fontSize: 14)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddEditDialog(context, provider, null),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Tambah'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: provider.shelters.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🏚️', style: TextStyle(fontSize: 40)),
                      SizedBox(height: 8),
                      Text('Belum ada shelter terdaftar',
                          style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.shelters.length,
                  itemBuilder: (ctx, i) => _ShelterAdminCard(
                    shelter: provider.shelters[i],
                    onEdit: () =>
                        _showAddEditDialog(ctx, provider, provider.shelters[i]),
                    onDelete: () =>
                        _confirmDelete(ctx, provider, provider.shelters[i]),
                    onUpdateOccupancy: (val) => provider.updateShelterOccupancy(
                        provider.shelters[i].id, val),
                  ),
                ),
        ),
      ],
    );
  }

  void _showAddEditDialog(
      BuildContext context, AppProvider provider, Shelter? shelter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _ShelterFormSheet(
        shelter: shelter,
        onSave: (data) {
          if (shelter == null) {
            provider.addShelter(data);
            _showSnack(context, '✅ Shelter berhasil ditambahkan!',
                AppTheme.statusAman);
          } else {
            provider.editShelter(data);
            _showSnack(context, '✅ Shelter diperbarui!', AppTheme.statusAman);
          }
        },
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, AppProvider provider, Shelter shelter) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Shelter?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
            'Shelter "${shelter.name}" akan dihapus permanen dari daftar.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteShelter(shelter.id);
              _showSnack(context, '🗑 Shelter dihapus.', AppTheme.statusBahaya);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusBahaya),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// Form tambah/edit shelter
class _ShelterFormSheet extends StatefulWidget {
  final Shelter? shelter;
  final Function(Shelter) onSave;
  const _ShelterFormSheet({this.shelter, required this.onSave});
  @override
  State<_ShelterFormSheet> createState() => _ShelterFormSheetState();
}

class _ShelterFormSheetState extends State<_ShelterFormSheet> {
  final _form = GlobalKey<FormState>();
  late TextEditingController _name, _address, _phone, _cap, _occ, _dist;
  String _type = 'Balai Desa';

  final List<String> _types = [
    'Balai Desa',
    'Sekolah',
    'Tempat Ibadah',
    'Gedung Serbaguna',
    'Posko Darurat',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.shelter;
    _name = TextEditingController(text: s?.name ?? '');
    _address = TextEditingController(text: s?.address ?? '');
    _phone = TextEditingController(text: s?.phone ?? '');
    _cap = TextEditingController(text: s != null ? '${s.capacity}' : '');
    _occ =
        TextEditingController(text: s != null ? '${s.currentOccupancy}' : '0');
    _dist = TextEditingController(text: s != null ? '${s.distance}' : '');
    _type = s?.type ?? 'Balai Desa';
  }

  @override
  void dispose() {
    for (final c in [_name, _address, _phone, _cap, _occ, _dist]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.shelter != null;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isEdit ? '✏️ Edit Shelter' : '➕ Tambah Shelter Baru',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),
              _field(_name, 'Nama Shelter *', Icons.home_outlined,
                  required: true),
              const SizedBox(height: 10),
              _field(_address, 'Alamat Lengkap *', Icons.location_on_outlined,
                  required: true),
              const SizedBox(height: 10),
              _field(_phone, 'No. Telepon', Icons.phone_outlined),
              const SizedBox(height: 10),
              // Jenis shelter dropdown
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: InputDecoration(
                  labelText: 'Jenis Shelter',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                items: _types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v ?? _type),
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                    child: _field(
                        _cap, 'Kapasitas (orang) *', Icons.people_outline,
                        required: true, isNum: true)),
                const SizedBox(width: 10),
                Expanded(
                    child: _field(_occ, 'Terisi Saat Ini', Icons.person_outline,
                        isNum: true)),
              ]),
              const SizedBox(height: 10),
              _field(_dist, 'Jarak (KM)', Icons.straighten, isNum: true),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: Icon(isEdit ? Icons.save : Icons.add, size: 16),
                  label:
                      Text(isEdit ? 'Simpan Perubahan' : 'Tambahkan Shelter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {bool required = false, bool isNum = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNum
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null
          : null,
    );
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final s = Shelter(
      id: widget.shelter?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      address: _address.text.trim(),
      phone: _phone.text.trim().isEmpty ? '-' : _phone.text.trim(),
      type: _type,
      capacity: int.tryParse(_cap.text) ?? 100,
      currentOccupancy: int.tryParse(_occ.text) ?? 0,
      distance: double.tryParse(_dist.text) ?? 0.0,
      lat: widget.shelter?.lat ?? -6.9175,
      lng: widget.shelter?.lng ?? 107.6191,
    );
    Navigator.pop(context);
    widget.onSave(s);
  }
}

// Card shelter di admin
class _ShelterAdminCard extends StatefulWidget {
  final Shelter shelter;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(int) onUpdateOccupancy;

  const _ShelterAdminCard({
    required this.shelter,
    required this.onEdit,
    required this.onDelete,
    required this.onUpdateOccupancy,
  });
  @override
  State<_ShelterAdminCard> createState() => _ShelterAdminCardState();
}

class _ShelterAdminCardState extends State<_ShelterAdminCard> {
  late TextEditingController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: '${widget.shelter.currentOccupancy}');
  }

  @override
  void didUpdateWidget(_ShelterAdminCard old) {
    super.didUpdateWidget(old);
    if (old.shelter.currentOccupancy != widget.shelter.currentOccupancy) {
      _ctrl.text = '${widget.shelter.currentOccupancy}';
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.shelter;
    final pct = (s.currentOccupancy / s.capacity).clamp(0.0, 1.0);
    final c = pct >= 1.0
        ? AppTheme.statusBahaya
        : pct >= 0.8
            ? AppTheme.statusWaspada
            : AppTheme.statusAman;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + actions
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10)),
              child: const Text('🏘️', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text('${s.type} • ${s.distance} km',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            // Edit
            IconButton(
              onPressed: widget.onEdit,
              icon: const Icon(Icons.edit_outlined,
                  size: 18, color: AppTheme.primary),
              tooltip: 'Edit',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            // Hapus
            IconButton(
              onPressed: widget.onDelete,
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: AppTheme.statusBahaya),
              tooltip: 'Hapus',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ]),
          const SizedBox(height: 10),
          // Address + phone
          Row(children: [
            const Icon(Icons.location_on_outlined,
                size: 12, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Expanded(
                child: Text(s.address,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary),
                    overflow: TextOverflow.ellipsis)),
          ]),
          if (s.phone != '-') ...[
            const SizedBox(height: 2),
            Row(children: [
              const Icon(Icons.phone_outlined,
                  size: 12, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(s.phone,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
            ]),
          ],
          const SizedBox(height: 10),
          // Progress
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
                value: pct,
                minHeight: 6,
                backgroundColor: AppTheme.borderLight,
                color: c),
          ),
          const SizedBox(height: 6),
          Row(children: [
            Text('Kapasitas: ${s.capacity} orang',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
            const Spacer(),
            Text('${(pct * 100).toInt()}% terisi',
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: c)),
          ]),
          const SizedBox(height: 10),
          // Update occupancy
          Row(children: [
            const Text('Update isi:',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(width: 8),
            SizedBox(
              width: 64,
              child: TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                ),
              ),
            ),
            const Text(' orang',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final val =
                    (int.tryParse(_ctrl.text) ?? 0).clamp(0, s.capacity);
                widget.onUpdateOccupancy(val);
                _showSnack(
                    context, '✅ Kapasitas diperbarui', AppTheme.statusAman);
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Simpan', style: TextStyle(fontSize: 12)),
            ),
          ]),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// TAB 3 — Laporan Warga
// ══════════════════════════════════════════════════════════════════
class _TabLaporan extends StatelessWidget {
  final AppProvider provider;
  const _TabLaporan({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.reports.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📭', style: TextStyle(fontSize: 40)),
            SizedBox(height: 8),
            Text('Belum ada laporan masuk',
                style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.reports.length,
      itemBuilder: (ctx, i) {
        final r = provider.reports[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: r.isVerified
                  ? AppTheme.statusAman.withOpacity(0.3)
                  : AppTheme.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: r.isVerified
                        ? AppTheme.statusAman.withOpacity(0.1)
                        : AppTheme.statusWaspada.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    r.isVerified ? '✅ Terverifikasi' : '⏳ Menunggu',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: r.isVerified
                            ? AppTheme.statusAman
                            : AppTheme.statusWaspada),
                  ),
                ),
                const Spacer(),
                Text(_ago(r.time),
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textSecondary)),
              ]),
              const SizedBox(height: 8),
              Text(r.description,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              Text('📍 ${r.location} • oleh ${r.reporterName}',
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Row(children: [
                if (!r.isVerified)
                  GestureDetector(
                    onTap: () {
                      provider.verifyReport(r.id);
                      _showSnack(
                          ctx, '✅ Laporan diverifikasi', AppTheme.statusAman);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppTheme.statusAman,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text('✓ Verifikasi',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                  )
                else
                  const Text('✅ Sudah terverifikasi',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.statusAman,
                          fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => showDialog(
                    context: ctx,
                    builder: (d) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: const Text('Hapus Laporan?',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      content: const Text('Laporan ini akan dihapus permanen.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(d),
                            child: const Text('Batal')),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(d);
                            provider.deleteReport(r.id);
                            _showSnack(ctx, '🗑 Laporan dihapus.',
                                AppTheme.statusBahaya);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.statusBahaya),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.statusBahaya.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('🗑 Hapus',
                        style: TextStyle(
                            color: AppTheme.statusBahaya,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ],
          ),
        );
      },
    );
  }

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes} mnt lalu';
    if (d.inHours < 24) return '${d.inHours} jam lalu';
    return '${d.inDays} hari lalu';
  }
}

// ── Shared helper ─────────────────────────────────────────────────────────
void _showSnack(BuildContext ctx, String msg, Color color) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    duration: const Duration(seconds: 2),
  ));
}
