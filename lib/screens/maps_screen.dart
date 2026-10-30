// lib/screens/maps_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/app_provider.dart';
import '../models/app_models.dart';
import '../theme.dart';
import 'cctv_screen.dart';

enum MapLayerStyle {
  googleRoadmap,
  googleSatellite,
  googleHybrid,
  googleTerrain,
  cartoVoyager,
  cartoDark,
  osmStandard,
}

class MapsScreen extends StatefulWidget {
  final LatLng? initialFocusLocation;
  const MapsScreen({super.key, this.initialFocusLocation});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final MapController _mapController = MapController();
  MapLayerStyle _layerStyle = MapLayerStyle.googleRoadmap;

  bool _showShelters = true;
  bool _showCctv = true;
  bool _showSensors = true;
  bool _showReports = true;
  bool _showFloodHazardZones = true;

  dynamic _selectedItem;

  // Center of Bandar Lampung (Tugu Adipura / Enggal)
  static const LatLng _bandarLampungCenter = LatLng(-5.4292, 105.2625);

  @override
  void initState() {
    super.initState();
    if (widget.initialFocusLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(widget.initialFocusLocation!, 15.0);
      });
    }
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1.0);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1.0);
  }

  void _centerToBandarLampung() {
    _mapController.move(_bandarLampungCenter, 13.0);
    setState(() => _selectedItem = null);
  }

  Future<void> _launchGoogleMaps({
    required double lat,
    required double lng,
    String? label,
    bool navigate = false,
  }) async {
    final String query = label != null && label.isNotEmpty
        ? Uri.encodeComponent('$label, Bandar Lampung')
        : '$lat,$lng';

    final String url = navigate
        ? 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving'
        : 'https://www.google.com/maps/search/?api=1&query=$query';

    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    final fallbackUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    if (await canLaunchUrl(fallbackUri)) {
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
    }
  }

  void _openCurrentViewInGoogleMaps() {
    if (_selectedItem != null) {
      if (_selectedItem is Shelter) {
        final s = _selectedItem as Shelter;
        _launchGoogleMaps(lat: s.lat, lng: s.lng, label: s.name, navigate: true);
        return;
      } else if (_selectedItem is CctvCamera) {
        final c = _selectedItem as CctvCamera;
        _launchGoogleMaps(lat: c.lat, lng: c.lng, label: c.name, navigate: false);
        return;
      } else if (_selectedItem is WaterLevelSensor) {
        _launchGoogleMaps(
          lat: -5.4485,
          lng: 105.2610,
          label: 'Pintu Air Way Belau',
          navigate: true,
        );
        return;
      } else if (_selectedItem is WargaReport) {
        final r = _selectedItem as WargaReport;
        if (r.lat != null && r.lng != null) {
          _launchGoogleMaps(lat: r.lat!, lng: r.lng!, label: r.location, navigate: true);
          return;
        }
      }
    }
    final center = _mapController.camera.center;
    _launchGoogleMaps(
      lat: center.latitude,
      lng: center.longitude,
      label: 'Kota Bandar Lampung',
      navigate: false,
    );
  }

  String _getTileUrl() {
    switch (_layerStyle) {
      case MapLayerStyle.googleRoadmap:
        return 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}';
      case MapLayerStyle.googleSatellite:
        return 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}';
      case MapLayerStyle.googleHybrid:
        return 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}';
      case MapLayerStyle.googleTerrain:
        return 'https://mt1.google.com/vt/lyrs=p&x={x}&y={y}&z={z}';
      case MapLayerStyle.cartoVoyager:
        return 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
      case MapLayerStyle.cartoDark:
        return 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
      case MapLayerStyle.osmStandard:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final shelters = provider.shelters;
        final cctvs = provider.cctvs;
        final sensor = provider.waterSensor;
        final reports = provider.reports;

        // Build Real Markers
        final List<Marker> mapMarkers = [];

        // 1. Shelter Markers
        if (_showShelters) {
          for (final s in shelters) {
            mapMarkers.add(
              Marker(
                point: LatLng(s.lat, s.lng),
                width: 44,
                height: 44,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedItem = s;
                    });
                    _mapController.move(LatLng(s.lat, s.lng), 14.5);
                  },
                  child: _MapPinBadge(
                    icon: Icons.night_shelter_rounded,
                    color: const Color(0xFF10B981),
                    isSelected: _selectedItem == s,
                    label: s.statusLabel,
                  ),
                ),
              ),
            );
          }
        }

        // 2. CCTV Markers
        if (_showCctv) {
          for (final c in cctvs) {
            mapMarkers.add(
              Marker(
                point: LatLng(c.lat, c.lng),
                width: 44,
                height: 44,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedItem = c;
                    });
                    _mapController.move(LatLng(c.lat, c.lng), 15.0);
                  },
                  child: _MapPinBadge(
                    icon: Icons.videocam_rounded,
                    color: const Color(0xFF0284C7),
                    isSelected: _selectedItem == c,
                    label: c.code,
                  ),
                ),
              ),
            );
          }
        }

        // 3. Sensor TMA Marker
        if (_showSensors) {
          mapMarkers.add(
            Marker(
              point: const LatLng(-5.4485, 105.2610),
              width: 44,
              height: 44,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedItem = sensor;
                  });
                  _mapController.move(const LatLng(-5.4485, 105.2610), 15.0);
                },
                child: _MapPinBadge(
                  icon: Icons.waves_rounded,
                  color: const Color(0xFFD97706),
                  isSelected: _selectedItem == sensor,
                  label: '${sensor.currentLevelCm} cm',
                ),
              ),
            ),
          );
        }

        // 4. Reports Markers
        if (_showReports) {
          for (final r in reports) {
            if (r.lat != null && r.lng != null) {
              mapMarkers.add(
                Marker(
                  point: LatLng(r.lat!, r.lng!),
                  width: 44,
                  height: 44,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedItem = r;
                      });
                      _mapController.move(LatLng(r.lat!, r.lng!), 15.0);
                    },
                    child: _MapPinBadge(
                      icon: Icons.warning_amber_rounded,
                      color: const Color(0xFFDC2626),
                      isSelected: _selectedItem == r,
                      label: r.category,
                    ),
                  ),
                ),
              );
            }
          }
        }

        // Real Flood Risk Polygons in Bandar Lampung
        final List<Polygon> floodPolygons = [];
        if (_showFloodHazardZones) {
          // Polygon 1: DAS Sungai Way Belau (Pasir Gintung - Teluk Betung)
          floodPolygons.add(
            Polygon(
              points: const [
                LatLng(-5.4200, 105.2500),
                LatLng(-5.4350, 105.2550),
                LatLng(-5.4520, 105.2620),
                LatLng(-5.4560, 105.2570),
                LatLng(-5.4380, 105.2480),
                LatLng(-5.4220, 105.2450),
              ],
              color: const Color(0xFFEF4444).withOpacity(0.25),
              borderColor: const Color(0xFFDC2626).withOpacity(0.8),
              borderStrokeWidth: 2,
            ),
          );

          // Polygon 2: Rajabasa / Underpass Unila Basins
          floodPolygons.add(
            Polygon(
              points: const [
                LatLng(-5.3620, 105.2400),
                LatLng(-5.3680, 105.2480),
                LatLng(-5.3720, 105.2430),
                LatLng(-5.3650, 105.2360),
              ],
              color: const Color(0xFFF97316).withOpacity(0.25),
              borderColor: const Color(0xFFEA580C).withOpacity(0.8),
              borderStrokeWidth: 2,
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0C2340),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0C2340),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peta Real-Time Kota Bandar Lampung',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Pusdalops BPBD Kota Bandar Lampung • Live GIS',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.navigation_rounded, color: Colors.white),
                tooltip: 'Buka Navigasi di Aplikasi Google Maps',
                onPressed: _openCurrentViewInGoogleMaps,
              ),
              PopupMenuButton<MapLayerStyle>(
                icon: const Icon(Icons.layers_outlined, color: Colors.white),
                tooltip: 'Ganti Layer Peta',
                onSelected: (style) => setState(() => _layerStyle = style),
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: MapLayerStyle.googleRoadmap,
                    child: Row(
                      children: [
                        Icon(Icons.map_rounded, size: 18, color: Color(0xFF1A73E8)),
                        SizedBox(width: 10),
                        Text(
                          'Google Maps (Jalan Resmi)',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: MapLayerStyle.googleSatellite,
                    child: Row(
                      children: [
                        Icon(Icons.satellite_alt_rounded, size: 18, color: Color(0xFF1A73E8)),
                        SizedBox(width: 10),
                        Text('Google Maps (Foto Satelit)'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: MapLayerStyle.googleHybrid,
                    child: Row(
                      children: [
                        Icon(Icons.layers_rounded, size: 18, color: Color(0xFF1A73E8)),
                        SizedBox(width: 10),
                        Text('Google Maps (Satelit + Jalan)'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: MapLayerStyle.googleTerrain,
                    child: Row(
                      children: [
                        Icon(Icons.terrain_rounded, size: 18, color: Color(0xFF1A73E8)),
                        SizedBox(width: 10),
                        Text('Google Maps (Kontur Topografi)'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: MapLayerStyle.cartoVoyager,
                    child: Row(
                      children: [
                        Icon(Icons.explore_outlined, size: 18),
                        SizedBox(width: 10),
                        Text('Carto Voyager'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: MapLayerStyle.osmStandard,
                    child: Row(
                      children: [
                        Icon(Icons.public, size: 18),
                        SizedBox(width: 10),
                        Text('OpenStreetMap Standar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: MapLayerStyle.cartoDark,
                    child: Row(
                      children: [
                        Icon(Icons.dark_mode_outlined, size: 18),
                        SizedBox(width: 10),
                        Text('Mode Pusdalops Gelap'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Stack(
            children: [
              // ── REAL-TIME OPENSTREETMAP / CARTO ENGINE ───────────────────
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: _bandarLampungCenter,
                  initialZoom: 13.0,
                  minZoom: 10.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: _getTileUrl(),
                    userAgentPackageName: 'com.blastsafe.bandarlampung',
                  ),
                  PolygonLayer(polygons: floodPolygons),
                  MarkerLayer(markers: mapMarkers),
                ],
              ),

              // ── Top Horizontal Filter Chips ──────────────────────────────
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _MapFilterChip(
                        label: 'Shelter (${shelters.length})',
                        icon: Icons.night_shelter_rounded,
                        color: const Color(0xFF10B981),
                        isSelected: _showShelters,
                        onTap: () =>
                            setState(() => _showShelters = !_showShelters),
                      ),
                      const SizedBox(width: 8),
                      _MapFilterChip(
                        label: 'CCTV Live (${cctvs.length})',
                        icon: Icons.videocam_rounded,
                        color: const Color(0xFF0284C7),
                        isSelected: _showCctv,
                        onTap: () => setState(() => _showCctv = !_showCctv),
                      ),
                      const SizedBox(width: 8),
                      _MapFilterChip(
                        label: 'Sensor TMA',
                        icon: Icons.waves_rounded,
                        color: const Color(0xFFD97706),
                        isSelected: _showSensors,
                        onTap: () =>
                            setState(() => _showSensors = !_showSensors),
                      ),
                      const SizedBox(width: 8),
                      _MapFilterChip(
                        label: 'Laporan Warga (${reports.length})',
                        icon: Icons.warning_amber_rounded,
                        color: const Color(0xFFDC2626),
                        isSelected: _showReports,
                        onTap: () =>
                            setState(() => _showReports = !_showReports),
                      ),
                      const SizedBox(width: 8),
                      _MapFilterChip(
                        label: 'Zona Bahaya',
                        icon: Icons.shield_outlined,
                        color: Colors.redAccent,
                        isSelected: _showFloodHazardZones,
                        onTap: () => setState(() =>
                            _showFloodHazardZones = !_showFloodHazardZones),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Map Action Floating Buttons ──────────────────────────────
              Positioned(
                right: 14,
                bottom: _selectedItem != null ? 210 : 20,
                child: Column(
                  children: [
                    _MapActionButton(
                      icon: Icons.add,
                      tooltip: 'Perbesar Peta',
                      onTap: _zoomIn,
                    ),
                    const SizedBox(height: 6),
                    _MapActionButton(
                      icon: Icons.remove,
                      tooltip: 'Perkecil Peta',
                      onTap: _zoomOut,
                    ),
                    const SizedBox(height: 6),
                    _MapActionButton(
                      icon: Icons.my_location,
                      tooltip: 'Fokus Bandar Lampung',
                      onTap: _centerToBandarLampung,
                    ),
                    const SizedBox(height: 6),
                    _MapActionButton(
                      icon: Icons.near_me_rounded,
                      tooltip: 'Buka di Aplikasi Google Maps',
                      onTap: _openCurrentViewInGoogleMaps,
                    ),
                  ],
                ),
              ),

              // ── Selected Marker Bottom Detail Card ───────────────────────
              if (_selectedItem != null)
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 16,
                  child: _buildDetailCard(context),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailCard(BuildContext context) {
    if (_selectedItem is Shelter) {
      final s = _selectedItem as Shelter;
      return _DetailContainer(
        title: s.name,
        subtitle: s.address,
        tag: 'POSKO SHELTER • SISA ${s.remainingSlots} SLOT',
        tagColor: const Color(0xFF10B981),
        icon: Icons.night_shelter_rounded,
        onClose: () => setState(() => _selectedItem = null),
        actionButton: ElevatedButton.icon(
          onPressed: () => _launchGoogleMaps(
            lat: s.lat,
            lng: s.lng,
            label: s.name,
            navigate: true,
          ),
          icon: const Icon(Icons.navigation, size: 16),
          label: const Text('Rute Navigasi Google Maps'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A73E8),
            foregroundColor: Colors.white,
          ),
        ),
        secondaryActionButton: OutlinedButton.icon(
          onPressed: () => _launchGoogleMaps(
            lat: s.lat,
            lng: s.lng,
            label: s.name,
            navigate: false,
          ),
          icon: const Icon(Icons.pin_drop_outlined, size: 16),
          label: const Text('Buka Titik di Google Maps'),
        ),
      );
    } else if (_selectedItem is CctvCamera) {
      final c = _selectedItem as CctvCamera;
      return _DetailContainer(
        title: '${c.code}: ${c.name}',
        subtitle: '${c.locationDescription} • TMA: ${c.waterLevelCm} cm',
        tag: 'CCTV REAL-TIME STREAM • ${c.currentStatus.toUpperCase()}',
        tagColor: const Color(0xFF0284C7),
        icon: Icons.videocam_rounded,
        onClose: () => setState(() => _selectedItem = null),
        actionButton: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CctvScreen(initialCameraId: c.id),
              ),
            );
          },
          icon: const Icon(Icons.play_circle_fill, size: 16),
          label: const Text('Tonton Siaran CCTV Langsung'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0284C7),
            foregroundColor: Colors.white,
          ),
        ),
        secondaryActionButton: OutlinedButton.icon(
          onPressed: () => _launchGoogleMaps(
            lat: c.lat,
            lng: c.lng,
            label: c.name,
            navigate: false,
          ),
          icon: const Icon(Icons.map_outlined, size: 16),
          label: const Text('Lihat Lokasi di Google Maps'),
        ),
      );
    } else if (_selectedItem is WaterLevelSensor) {
      final w = _selectedItem as WaterLevelSensor;
      return _DetailContainer(
        title: 'Sensor TMA: ${w.location}',
        subtitle:
            'Ketinggian Air: ${w.currentLevelCm} cm • Tren: ${w.trend} • Level: ${w.statusLabel}',
        tag: 'TELEMETRI SENSOR SUNGAI',
        tagColor: const Color(0xFFD97706),
        icon: Icons.waves_rounded,
        onClose: () => setState(() => _selectedItem = null),
        actionButton: ElevatedButton.icon(
          onPressed: () => _launchGoogleMaps(
            lat: -5.4485,
            lng: 105.2610,
            label: 'Pintu Air Way Belau',
            navigate: true,
          ),
          icon: const Icon(Icons.directions_car_rounded, size: 16),
          label: const Text('Petunjuk Arah Google Maps'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A73E8),
            foregroundColor: Colors.white,
          ),
        ),
        secondaryActionButton: OutlinedButton.icon(
          onPressed: () => _launchGoogleMaps(
            lat: -5.4485,
            lng: 105.2610,
            label: 'Sensor TMA Way Belau',
            navigate: false,
          ),
          icon: const Icon(Icons.pin_drop, size: 16),
          label: const Text('Buka Titik Sensor di Maps'),
        ),
      );
    } else if (_selectedItem is WargaReport) {
      final r = _selectedItem as WargaReport;
      return _DetailContainer(
        title: 'Laporan: ${r.category}',
        subtitle: '${r.location}\n"${r.description}"',
        tag: 'URGENSI: ${r.urgency.toUpperCase()} • AIR: ${r.waterDepth}',
        tagColor: const Color(0xFFDC2626),
        icon: Icons.warning_amber_rounded,
        onClose: () => setState(() => _selectedItem = null),
        actionButton: ElevatedButton.icon(
          onPressed: () {
            if (r.lat != null && r.lng != null) {
              _launchGoogleMaps(
                lat: r.lat!,
                lng: r.lng!,
                label: r.location,
                navigate: true,
              );
            }
          },
          icon: const Icon(Icons.directions_car_rounded, size: 16),
          label: const Text('Petunjuk Arah Google Maps'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
          ),
        ),
        secondaryActionButton: (r.lat != null && r.lng != null)
            ? OutlinedButton.icon(
                onPressed: () => _launchGoogleMaps(
                  lat: r.lat!,
                  lng: r.lng!,
                  label: r.location,
                  navigate: false,
                ),
                icon: const Icon(Icons.pin_drop_outlined, size: 16),
                label: const Text('Buka Titik di Google Maps'),
              )
            : null,
      );
    }
    return const SizedBox.shrink();
  }
}

// ── Detail Container ────────────────────────────────────────────────────────
class _DetailContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;
  final IconData icon;
  final VoidCallback onClose;
  final Widget actionButton;
  final Widget? secondaryActionButton;

  const _DetailContainer({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
    required this.icon,
    required this.onClose,
    required this.actionButton,
    this.secondaryActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: tagColor,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: actionButton,
          ),
          if (secondaryActionButton != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: secondaryActionButton!,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Map Pin Badge Widget ────────────────────────────────────────────────────
class _MapPinBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isSelected;
  final String label;

  const _MapPinBadge({
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isSelected ? 38 : 32,
          height: isSelected ? 38 : 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: isSelected ? 20 : 16,
          ),
        ),
      ],
    );
  }
}

// ── Filter Chip Widget ──────────────────────────────────────────────────────
class _MapFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _MapFilterChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppTheme.border,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? color : Colors.grey),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.textPrimary : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Map Floating Action Button ──────────────────────────────────────────────
class _MapActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _MapActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 20, color: const Color(0xFF0C2340)),
        ),
      ),
    );
  }
}
