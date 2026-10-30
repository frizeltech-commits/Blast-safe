// lib/screens/main_navigation.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_provider.dart';
import '../models/app_models.dart';
import '../theme.dart';
import '../widgets/sos_dialog.dart';
import 'home_screen.dart';
import 'maps_screen.dart';
import 'cctv_screen.dart';
import 'shelter_screen.dart';
import 'laporan_screen.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _idx;
  FloodStatus? _lastStatus;

  final _screens = const [
    HomeScreen(),
    MapsScreen(),
    CctvScreen(),
    ShelterScreen(),
    LaporanScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _idx = widget.initialIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkWarning();
    });
  }

  void _checkWarning() {
    if (!mounted) return;
    final p = context.read<AppProvider>();
    final cur = p.state.status;
    if (cur != FloodStatus.aman &&
        p.showWarningBanner &&
        cur != _lastStatus) {
      _lastStatus = cur;
      _showPopup(p);
    } else if (cur == FloodStatus.aman) {
      _lastStatus = cur;
    }
  }

  void _showPopup(AppProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final color = AppTheme.statusColor(provider.state.status);
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.white, size: 42),
                    const SizedBox(height: 6),
                    Text(
                      'PERINGATAN STATUS: ${provider.state.statusLabel}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      provider.state.warningMessage.isNotEmpty
                          ? provider.state.warningMessage
                          : 'Debit air meningkat. Dihimbau seluruh warga di kawasan bantaran sungai segera bersiaga.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pantau kamera CCTV dan jalur evakuasi shelter terdekat di aplikasi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              provider.dismissWarning();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Tutup'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              setState(() => _idx = 1); // Buka Peta
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Buka Peta'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        final cur = provider.state.status;
        if (cur != FloodStatus.aman &&
            provider.showWarningBanner &&
            cur != _lastStatus) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _lastStatus = cur;
              _showPopup(provider);
            }
          });
        } else if (cur == FloodStatus.aman && _lastStatus != FloodStatus.aman) {
          _lastStatus = cur;
        }

        final isDisasterWarning = cur != FloodStatus.aman;

        return Scaffold(
          body: IndexedStack(index: _idx, children: _screens),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => SosDialog.show(context),
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.emergency_share_outlined, size: 20),
            label: const Text(
              'SOS PANIC',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                fontSize: 12,
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: _idx,
              onDestinationSelected: (i) => setState(() => _idx = i),
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFF0F2942).withOpacity(0.1),
              elevation: 0,
              height: 66,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon:
                      Icon(Icons.dashboard, color: Color(0xFF0F2942)),
                  label: 'Beranda',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map, color: Color(0xFF0F2942)),
                  label: 'Peta Spasial',
                ),
                NavigationDestination(
                  icon: isDisasterWarning
                      ? const Badge(
                          backgroundColor: Colors.red,
                          smallSize: 8,
                          child: Icon(Icons.videocam_outlined),
                        )
                      : const Icon(Icons.videocam_outlined),
                  selectedIcon: const Icon(Icons.videocam,
                      color: Color(0xFF0F2942)),
                  label: 'CCTV Live',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.night_shelter_outlined),
                  selectedIcon:
                      Icon(Icons.night_shelter, color: Color(0xFF0F2942)),
                  label: 'Shelter',
                ),
                NavigationDestination(
                  icon: Badge(
                    label: Text('${provider.reports.length}'),
                    backgroundColor: AppTheme.statusWaspada,
                    child: const Icon(Icons.assignment_outlined),
                  ),
                  selectedIcon: Badge(
                    label: Text('${provider.reports.length}'),
                    backgroundColor: AppTheme.statusWaspada,
                    child: const Icon(Icons.assignment,
                        color: Color(0xFF0F2942)),
                  ),
                  label: 'Laporan',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
