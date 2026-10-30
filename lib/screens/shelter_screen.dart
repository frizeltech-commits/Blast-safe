// lib/screens/shelter_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/app_provider.dart';
import '../models/app_models.dart';
import '../theme.dart';

class ShelterScreen extends StatefulWidget {
  const ShelterScreen({super.key});

  @override
  State<ShelterScreen> createState() => _ShelterScreenState();
}

class _ShelterScreenState extends State<ShelterScreen> {
  String _filter = 'Semua';
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _launchCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchMaps(double lat, double lng, String label) async {
    // Membuka navigasi rute mengemudi di aplikasi Google Maps
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    // Fallback search koordinat
    final fallback =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(fallback)) {
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final shelters = provider.shelters;

        // Filtering
        var list = shelters.where((s) {
          if (_filter == 'Tersedia') return s.isAvailable;
          if (_filter == 'Favorit') return s.isBookmarked;
          return true;
        }).where((s) {
          if (_searchQuery.isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          return s.name.toLowerCase().contains(q) ||
              s.address.toLowerCase().contains(q) ||
              s.type.toLowerCase().contains(q);
        }).toList();

        if (_filter == 'Terdekat') {
          list.sort((a, b) => a.distance.compareTo(b.distance));
        }

        final totalCapacity =
            shelters.fold(0, (sum, s) => sum + s.capacity);
        final totalOccupied =
            shelters.fold(0, (sum, s) => sum + s.currentOccupancy);
        final availableCount =
            shelters.where((s) => s.isAvailable).length;

        return Scaffold(
          backgroundColor: AppTheme.surface,
          appBar: AppBar(
            title: const Text('Lokasi Shelter & Posko Evakuasi'),
            backgroundColor: AppTheme.primary,
          ),
          body: Column(
            children: [
              // Header Summary Banner
              Container(
                color: AppTheme.primary,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    _StatChip(
                      label: 'Total Posko',
                      value: '${shelters.length}',
                      icon: '🏘️',
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'Tersedia',
                      value: '$availableCount Posko',
                      icon: '✅',
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'Sisa Daya Tampung',
                      value: '${totalCapacity - totalOccupied} Jiwa',
                      icon: '👥',
                    ),
                  ],
                ),
              ),

              // Search Box
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Cari nama posko, balai desa, atau sekolah...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                  ),
                ),
              ),

              // Filter Chips
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Semua (${shelters.length})',
                        selected: _filter == 'Semua',
                        onTap: () => setState(() => _filter = 'Semua'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Tersedia ($availableCount)',
                        selected: _filter == 'Tersedia',
                        onTap: () => setState(() => _filter = 'Tersedia'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Terdekat',
                        selected: _filter == 'Terdekat',
                        onTap: () => setState(() => _filter = 'Terdekat'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: '⭐ Ditandai',
                        selected: _filter == 'Favorit',
                        onTap: () => setState(() => _filter = 'Favorit'),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: AppTheme.border),

              // List of Shelters
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🏘️', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            const Text(
                              'Tidak ada shelter yang sesuai pencarian',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _filter = 'Semua';
                                });
                              },
                              child: const Text('Reset Pencarian'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (ctx, i) {
                          final s = list[i];
                          return _ShelterCard(
                            shelter: s,
                            onBookmarkToggle: () =>
                                provider.toggleShelterBookmark(s.id),
                            onCallTap: () => _launchCall(s.phone),
                            onDirectionsTap: () =>
                                _launchMaps(s.lat, s.lng, s.name),
                            onTap: () => _showShelterDetail(context, s),
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

  void _showShelterDetail(BuildContext context, Shelter shelter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('🏘️', style: TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shelter.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          shelter.type,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: shelter.statusLabel),
                ],
              ),
              const SizedBox(height: 20),
              _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Alamat Posko',
                  value: shelter.address),
              _DetailRow(
                  icon: Icons.straighten,
                  label: 'Jarak Tempuh',
                  value: '${shelter.distance} KM dari estimasi lokasi Anda'),
              _DetailRow(
                  icon: Icons.people_outline,
                  label: 'Daya Tampung',
                  value:
                      '${shelter.currentOccupancy} terisi / ${shelter.capacity} kapasitas (Sisa: ${shelter.remainingSlots} slot)'),
              _DetailRow(
                  icon: Icons.phone_outlined,
                  label: 'Kontak Posko',
                  value: shelter.phone),
              const SizedBox(height: 14),

              // Occupancy bar
              Text(
                'Tingkat Keterisian: ${(shelter.occupancyPercent * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: shelter.occupancyPercent,
                  backgroundColor: AppTheme.borderLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    shelter.occupancyPercent >= 1.0
                        ? AppTheme.statusBahaya
                        : shelter.occupancyPercent >= 0.8
                            ? AppTheme.statusWaspada
                            : AppTheme.statusAman,
                  ),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 18),

              // Facilities
              const Text(
                'Fasilitas Tersedia:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: shelter.facilities.map((fac) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      '✓ $fac',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _launchCall(shelter.phone);
                      },
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text('Telepon Posko'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _launchMaps(shelter.lat, shelter.lng, shelter.name);
                      },
                      icon: const Icon(Icons.navigation, size: 16),
                      label: const Text('Buka Navigasi'),
                    ),
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

// ── Shelter Card ───────────────────────────────────────────────────────────
class _ShelterCard extends StatelessWidget {
  final Shelter shelter;
  final VoidCallback onBookmarkToggle;
  final VoidCallback onCallTap;
  final VoidCallback onDirectionsTap;
  final VoidCallback onTap;

  const _ShelterCard({
    required this.shelter,
    required this.onBookmarkToggle,
    required this.onCallTap,
    required this.onDirectionsTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: shelter.isBookmarked
              ? AppTheme.primary.withOpacity(0.5)
              : AppTheme.border,
          width: shelter.isBookmarked ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('🏘️', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shelter.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          shelter.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      shelter.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: shelter.isBookmarked
                          ? AppTheme.primary
                          : AppTheme.textLight,
                      size: 22,
                    ),
                    onPressed: onBookmarkToggle,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Distance & Slots
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.straighten,
                            size: 13, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${shelter.distance} km',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people_outline,
                            size: 13, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Sisa ${shelter.remainingSlots} slot',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _StatusBadge(status: shelter.statusLabel),
                ],
              ),
              const SizedBox(height: 10),

              // Mini occupancy bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: shelter.occupancyPercent,
                  backgroundColor: AppTheme.borderLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    shelter.occupancyPercent >= 1.0
                        ? AppTheme.statusBahaya
                        : shelter.occupancyPercent >= 0.8
                            ? AppTheme.statusWaspada
                            : AppTheme.statusAman,
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 12),

              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCallTap,
                      icon: const Icon(Icons.phone, size: 14),
                      label: const Text('Hubungi',
                          style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDirectionsTap,
                      icon: const Icon(Icons.navigation, size: 14),
                      label: const Text('Navigasi',
                          style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
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

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case 'Tersedia':
        bg = AppTheme.statusAman.withOpacity(0.12);
        fg = AppTheme.statusAman;
        break;
      case 'Hampir Penuh':
        bg = AppTheme.statusWaspada.withOpacity(0.12);
        fg = AppTheme.statusWaspada;
        break;
      default:
        bg = AppTheme.statusBahaya.withOpacity(0.12);
        fg = AppTheme.statusBahaya;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value, icon;
  const _StatChip(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;

  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
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
