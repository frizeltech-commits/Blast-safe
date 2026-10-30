// lib/data/app_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

class AppProvider extends ChangeNotifier {
  AppState _state = AppState();
  List<Shelter> _shelters = [];
  List<WargaReport> _reports = [];
  List<ChecklistItem> _checklist = [];
  List<EmergencyContact> _customContacts = [];
  List<CctvCamera> _cctvs = [];
  WaterLevelSensor _waterSensor = WaterLevelSensor(
    location: 'Pintu Air Sungai Way Belau, Teluk Betung',
    currentLevelCm: 85,
    trend: 'Stabil',
    lastChecked: DateTime.now(),
  );

  bool _warningDismissed = false;
  bool _isLoading = true;

  // Getters
  AppState get state => _state;
  List<Shelter> get shelters => List.unmodifiable(_shelters);
  List<WargaReport> get reports => List.unmodifiable(_reports);
  List<ChecklistItem> get checklist => List.unmodifiable(_checklist);
  List<EmergencyContact> get customContacts =>
      List.unmodifiable(_customContacts);
  List<CctvCamera> get cctvs => List.unmodifiable(_cctvs);
  WaterLevelSensor get waterSensor => _waterSensor;
  bool get isLoading => _isLoading;
  bool get showWarningBanner =>
      !_warningDismissed && _state.status != FloodStatus.aman;

  // Computed Checklist Progress
  int get checklistCompletedCount =>
      _checklist.where((item) => item.isChecked).length;
  double get checklistProgress =>
      _checklist.isEmpty ? 0.0 : (checklistCompletedCount / _checklist.length);

  AppProvider() {
    _initData();
  }

  Future<void> _initData() async {
    _initDefaults();
    await _loadFromStorage();
    _isLoading = false;
    notifyListeners();
  }

  void _initDefaults() {
    // Real CCTV in Bandar Lampung
    _cctvs = [
      CctvCamera(
        id: 'cctv_1',
        code: 'CCTV-BL01',
        name: 'Pintu Air Way Belau (Pasar Bawah)',
        locationDescription: 'Aliran Utama Way Belau, Teluk Betung Selatan',
        lat: -5.4490,
        lng: 105.2605,
        isOnline: true,
        currentStatus: 'Aman (Normal)',
        waterLevelCm: 85,
        resolution: '1080p FHD • 30 FPS',
        bitrateKbps: 2680,
        lastPing: DateTime.now(),
      ),
      CctvCamera(
        id: 'cctv_2',
        code: 'CCTV-BL02',
        name: 'Underpass Unila - Rajabasa',
        locationDescription: 'Jl. ZA Pagar Alam, Rajabasa, Bandar Lampung',
        lat: -5.3650,
        lng: 105.2440,
        isOnline: true,
        currentStatus: 'Normal (Lancar)',
        waterLevelCm: 25,
        resolution: '1080p FHD • 30 FPS',
        bitrateKbps: 2420,
        lastPing: DateTime.now(),
      ),
      CctvCamera(
        id: 'cctv_3',
        code: 'CCTV-BL03',
        name: 'Jembatan Way Kuripan - Garuntang',
        locationDescription: 'Jalan Yos Sudarso, Bumi Waras, Bandar Lampung',
        lat: -5.4410,
        lng: 105.2750,
        isOnline: true,
        currentStatus: 'Normal',
        waterLevelCm: 70,
        resolution: '1080p FHD • 25 FPS',
        bitrateKbps: 2150,
        lastPing: DateTime.now(),
      ),
      CctvCamera(
        id: 'cctv_4',
        code: 'CCTV-BL04',
        name: 'Posko Pusdalops BPBD Bandar Lampung',
        locationDescription: 'Kupang Teba, Teluk Betung Utara, Bandar Lampung',
        lat: -5.4320,
        lng: 105.2680,
        isOnline: true,
        currentStatus: 'Siaga Siap Tanggap',
        waterLevelCm: 10,
        resolution: '1080p FHD • 30 FPS',
        bitrateKbps: 3100,
        lastPing: DateTime.now(),
      ),
    ];

    // Real Shelters in Bandar Lampung
    _shelters = [
      const Shelter(
        id: '1',
        name: 'GSG Universitas Lampung (Unila)',
        address: 'Jl. Prof. Dr. Sumantri Brojonegoro No. 1, Rajabasa',
        distance: 2.1,
        capacity: 450,
        currentOccupancy: 85,
        phone: '0721-701609',
        lat: -5.3675,
        lng: 105.2425,
        type: 'Gedung Serbaguna Kampus',
        facilities: [
          'Dapur Umum Skala Besar',
          'Posko Medis Unila & P3K',
          'Genset 25 KVa',
          'Toilet & Sanitasi',
          'Air Bersih PDAM'
        ],
      ),
      const Shelter(
        id: '2',
        name: 'Kantor BPBD Kota Bandar Lampung',
        address: 'Jl. Mayor Salim Batubara No. 44, Kupang Teba',
        distance: 1.4,
        capacity: 250,
        currentOccupancy: 60,
        phone: '0721-252741',
        lat: -5.4320,
        lng: 105.2680,
        type: 'Kantor Pemerintahan / BPBD',
        facilities: [
          'Pusdalops 24 Jam',
          'Perahu Karet Evakuasi',
          'Ambulans Standby',
          'Logistik Makanan Siap Saji',
          'Komunikasi Radio VHF/UHF'
        ],
      ),
      const Shelter(
        id: '3',
        name: 'GOR Saburai / Lapangan Enggal',
        address: 'Kecamatan Enggal, Pusat Kota Bandar Lampung',
        distance: 0.9,
        capacity: 350,
        currentOccupancy: 40,
        phone: '081279011900',
        lat: -5.4265,
        lng: 105.2595,
        type: 'Gelanggang Olahraga',
        facilities: [
          'Area Terbuka Evakuasi',
          'Dapur Lapangan TNI/Polri',
          'Toilet Bersih',
          'Posko Relawan PMI'
        ],
      ),
      const Shelter(
        id: '4',
        name: 'Balai Kelurahan Garuntang',
        address: 'Jl. Yos Sudarso No. 12, Bumi Waras, Bandar Lampung',
        distance: 3.2,
        capacity: 180,
        currentOccupancy: 25,
        phone: '0721-482201',
        lat: -5.4435,
        lng: 105.2780,
        type: 'Balai Kelurahan',
        facilities: [
          'Aula Lantai 2 Aman Genangan',
          'Dapur Warga',
          'Posko Medis Puskesmas',
          'Genset Cadangan'
        ],
      ),
      const Shelter(
        id: '5',
        name: 'Kantor Camat Teluk Betung Selatan',
        address: 'Jl. Ikan Hiu No. 8, Teluk Betung, Bandar Lampung',
        distance: 3.8,
        capacity: 220,
        currentOccupancy: 0,
        phone: '0721-483502',
        lat: -5.4520,
        lng: 105.2580,
        type: 'Kantor Kecamatan',
        facilities: [
          'Ruang Evakuasi Luas',
          'Parkir Kendaraan Rescue',
          'Dapur Umum Tagana',
          'Akses Dekat Pesisir Teluk'
        ],
      ),
    ];

    // Real Reports in Bandar Lampung
    _reports = [
      WargaReport(
        id: '1',
        description:
            'Genangan air setinggi ±50 cm di depan Underpass Unila Jl. ZA Pagar Alam. Kendaraan roda dua dialihkan lewat jalur atas.',
        location: 'Jl. ZA Pagar Alam, Rajabasa, Bandar Lampung',
        time: DateTime.now().subtract(const Duration(minutes: 20)),
        reporterName: 'Rian Pratama',
        isVerified: true,
        category: 'Jalan Terputus',
        waterDepth: '30-70 cm',
        urgency: 'Penting',
        confirmations: 12,
        lat: -5.3655,
        lng: 105.2435,
      ),
      WargaReport(
        id: '2',
        description:
            'Debit air Sungai Way Belau mulai meluap mendekati bibir tanggul permukiman RT 03 Pasir Gintung.',
        location: 'Pasir Gintung, Tanjung Karang Pusat, Bandar Lampung',
        time: DateTime.now().subtract(const Duration(hours: 1)),
        reporterName: 'Ibu Ratna',
        isVerified: true,
        category: 'Ketinggian Air',
        waterDepth: '10-30 cm',
        urgency: 'Penting',
        confirmations: 8,
        lat: -5.4180,
        lng: 105.2530,
      ),
      WargaReport(
        id: '3',
        description:
            'Tiga keluarga lansia di Jl. Ikan Pari memerlukan perahu karet untuk evakuasi ke kantor camat terdekat.',
        location: 'Jl. Ikan Pari No. 24, Pesawahan, Teluk Betung Selatan',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        reporterName: 'Fajar (Relawan Tagana)',
        isVerified: true,
        category: 'Butuh Evakuasi',
        waterDepth: '70-120 cm',
        urgency: 'Darurat Kritis',
        confirmations: 15,
        lat: -5.4510,
        lng: 105.2590,
      ),
    ];

    _checklist = [
      const ChecklistItem(
        id: 'c1',
        title: 'Dokumen Penting (Waterproof)',
        subtitle: 'KTP, KK, Ijazah, Buku Nikah, Sertifikat dalam kantong kedap air',
        category: 'Dokumen & Finansial',
        isChecked: true,
      ),
      const ChecklistItem(
        id: 'c2',
        title: 'Uang Tunai Pecahan Kecil',
        subtitle: 'ATM & sistem digital berpotensi offline saat banjir',
        category: 'Dokumen & Finansial',
        isChecked: true,
      ),
      const ChecklistItem(
        id: 'c3',
        title: 'Air Minum Bersih (3 Hari)',
        subtitle: 'Minimal 2-3 liter per orang per hari',
        category: 'Pangan & Nutrisi',
        isChecked: false,
      ),
      const ChecklistItem(
        id: 'c4',
        title: 'Makanan Siap Saji Tahan Lama',
        subtitle: 'Biskuit energi, makanan kaleng, madu, susu bayi',
        category: 'Pangan & Nutrisi',
        isChecked: false,
      ),
      const ChecklistItem(
        id: 'c5',
        title: 'Kotak P3K & Obat Rutin',
        subtitle: 'Perban, antiseptik, parasetamol, oralit, dan obat resep',
        category: 'Medis & Kesehatan',
        isChecked: true,
      ),
      const ChecklistItem(
        id: 'c6',
        title: 'Senter LED & Baterai Cadangan',
        subtitle: 'Lampu darurat tahan air untuk sinyal penjemputan SAR',
        category: 'Peralatan Bertahan',
        isChecked: false,
      ),
      const ChecklistItem(
        id: 'c7',
        title: 'Powerbank 100% Penuh',
        subtitle: 'Daya baterai cadangan untuk komunikasi darurat',
        category: 'Peralatan Bertahan',
        isChecked: false,
      ),
      const ChecklistItem(
        id: 'c8',
        title: 'Peluit Tanda Bantuan',
        subtitle: 'Untuk sinyal meminta pertolongan regu evakuasi',
        category: 'Peralatan Bertahan',
        isChecked: false,
      ),
      const ChecklistItem(
        id: 'c9',
        title: 'Pakaian Ganti & Jas Hujan',
        subtitle: 'Pakaian hangat tahan angin, selimut ringan',
        category: 'Sandang',
        isChecked: false,
      ),
      const ChecklistItem(
        id: 'c10',
        title: 'Peralatan Higienis & Masker',
        subtitle: 'Sabun, sikat gigi, masker medis, pembalut, hand sanitizer',
        category: 'Medis & Kesehatan',
        isChecked: false,
      ),
    ];
  }

  // ── Storage Persistence (SharedPreferences) ────────────────────────────────
  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final stateStr = prefs.getString('blastsafe_state');
      if (stateStr != null) {
        final Map<String, dynamic> decoded = jsonDecode(stateStr);
        _state = AppState.fromJson(decoded);
      }

      _warningDismissed = prefs.getBool('blastsafe_warning_dismissed') ?? false;

      final sheltersStr = prefs.getString('blastsafe_shelters');
      if (sheltersStr != null) {
        final List<dynamic> decoded = jsonDecode(sheltersStr);
        final loaded = decoded.map((e) => Shelter.fromJson(e)).toList();
        if (loaded.isNotEmpty) _shelters = loaded;
      }

      final reportsStr = prefs.getString('blastsafe_reports');
      if (reportsStr != null) {
        final List<dynamic> decoded = jsonDecode(reportsStr);
        final loaded = decoded.map((e) => WargaReport.fromJson(e)).toList();
        if (loaded.isNotEmpty) _reports = loaded;
      }

      final checkStr = prefs.getString('blastsafe_checklist');
      if (checkStr != null) {
        final List<dynamic> decoded = jsonDecode(checkStr);
        final loaded = decoded.map((e) => ChecklistItem.fromJson(e)).toList();
        if (loaded.isNotEmpty) _checklist = loaded;
      }

      final contactsStr = prefs.getString('blastsafe_custom_contacts');
      if (contactsStr != null) {
        final List<dynamic> decoded = jsonDecode(contactsStr);
        _customContacts =
            decoded.map((e) => EmergencyContact.fromJson(e)).toList();
      }

      final sensorStr = prefs.getString('blastsafe_water_sensor');
      if (sensorStr != null) {
        final Map<String, dynamic> decoded = jsonDecode(sensorStr);
        _waterSensor = WaterLevelSensor.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('Error loading from SharedPreferences: $e');
    }
  }

  Future<void> _saveStateToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('blastsafe_state', jsonEncode(_state.toJson()));
      await prefs.setBool('blastsafe_warning_dismissed', _warningDismissed);
    } catch (e) {
      debugPrint('Error saving state: $e');
    }
  }

  Future<void> _saveSheltersToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _shelters.map((s) => s.toJson()).toList();
      await prefs.setString('blastsafe_shelters', jsonEncode(list));
    } catch (e) {
      debugPrint('Error saving shelters: $e');
    }
  }

  Future<void> _saveReportsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _reports.map((r) => r.toJson()).toList();
      await prefs.setString('blastsafe_reports', jsonEncode(list));
    } catch (e) {
      debugPrint('Error saving reports: $e');
    }
  }

  Future<void> _saveChecklistToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _checklist.map((c) => c.toJson()).toList();
      await prefs.setString('blastsafe_checklist', jsonEncode(list));
    } catch (e) {
      debugPrint('Error saving checklist: $e');
    }
  }

  Future<void> _saveCustomContactsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _customContacts.map((c) => c.toJson()).toList();
      await prefs.setString('blastsafe_custom_contacts', jsonEncode(list));
    } catch (e) {
      debugPrint('Error saving custom contacts: $e');
    }
  }

  Future<void> _saveWaterSensorToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'blastsafe_water_sensor', jsonEncode(_waterSensor.toJson()));
    } catch (e) {
      debugPrint('Error saving sensor: $e');
    }
  }

  // ── Status Management ──────────────────────────────────────────────────────
  void updateStatus(FloodStatus newStatus, String message) {
    _state.status = newStatus;
    _state.warningMessage = message;
    _state.showWarning = newStatus != FloodStatus.aman;
    _state.lastUpdated = DateTime.now();
    _warningDismissed = false;

    int newLevel = _waterSensor.currentLevelCm;
    String trend = 'Stabil';
    if (newStatus == FloodStatus.aman) {
      newLevel = 85;
      trend = 'Turun';
    } else if (newStatus == FloodStatus.waspada) {
      newLevel = 145;
      trend = 'Naik';
    } else if (newStatus == FloodStatus.siaga) {
      newLevel = 210;
      trend = 'Naik';
    } else if (newStatus == FloodStatus.bahaya) {
      newLevel = 275;
      trend = 'Naik Cepat';
    }

    _waterSensor = WaterLevelSensor(
      location: _waterSensor.location,
      currentLevelCm: newLevel,
      trend: trend,
      lastChecked: DateTime.now(),
    );

    // Synchronize CCTV Status with Flood Severity
    _cctvs = _cctvs.map((cam) {
      String statusDesc = 'Aman (Normal)';
      int camLevel = 80;
      if (newStatus == FloodStatus.waspada) {
        statusDesc = cam.id == 'cctv_1' ? 'Waspada (Meningkat)' : 'Siaga 3';
        camLevel = 140;
      } else if (newStatus == FloodStatus.siaga) {
        statusDesc = 'Siaga 2 (Meluap)';
        camLevel = 205;
      } else if (newStatus == FloodStatus.bahaya) {
        statusDesc = 'Siaga 1 (KRITIS)';
        camLevel = 270;
      }
      return CctvCamera(
        id: cam.id,
        code: cam.code,
        name: cam.name,
        locationDescription: cam.locationDescription,
        lat: cam.lat,
        lng: cam.lng,
        isOnline: cam.isOnline,
        currentStatus: statusDesc,
        waterLevelCm: camLevel,
        resolution: cam.resolution,
        bitrateKbps: cam.bitrateKbps,
        lastPing: DateTime.now(),
      );
    }).toList();

    notifyListeners();
    _saveStateToStorage();
    _saveWaterSensorToStorage();
  }

  void dismissWarning() {
    _warningDismissed = true;
    notifyListeners();
    _saveStateToStorage();
  }

  void updateWaterSensor({
    required int levelCm,
    required String trend,
    String? location,
  }) {
    _waterSensor = WaterLevelSensor(
      location: location ?? _waterSensor.location,
      currentLevelCm: levelCm,
      trend: trend,
      lastChecked: DateTime.now(),
    );
    notifyListeners();
    _saveWaterSensorToStorage();
  }

  // ── Auth ──────────────────────────────────────────────────────────────────
  void login(String user) {
    _state.isLoggedIn = true;
    _state.adminUser = user;
    notifyListeners();
    _saveStateToStorage();
  }

  void logout() {
    _state.isLoggedIn = false;
    _state.adminUser = '';
    notifyListeners();
    _saveStateToStorage();
  }

  // ── Shelter Management ────────────────────────────────────────────────────
  void addShelter(Shelter shelter) {
    _shelters = [..._shelters, shelter];
    notifyListeners();
    _saveSheltersToStorage();
  }

  void editShelter(Shelter updated) {
    _shelters = _shelters.map((s) => s.id == updated.id ? updated : s).toList();
    notifyListeners();
    _saveSheltersToStorage();
  }

  void deleteShelter(String id) {
    _shelters = _shelters.where((s) => s.id != id).toList();
    notifyListeners();
    _saveSheltersToStorage();
  }

  void updateShelterOccupancy(String id, int occupancy) {
    final idx = _shelters.indexWhere((s) => s.id == id);
    if (idx != -1) {
      final s = _shelters[idx];
      final updated = s.copyWith(
        currentOccupancy: occupancy.clamp(0, s.capacity),
      );
      _shelters = [..._shelters];
      _shelters[idx] = updated;
      notifyListeners();
      _saveSheltersToStorage();
    }
  }

  void toggleShelterBookmark(String id) {
    _shelters = _shelters.map((s) {
      if (s.id == id) {
        return s.copyWith(isBookmarked: !s.isBookmarked);
      }
      return s;
    }).toList();
    notifyListeners();
    _saveSheltersToStorage();
  }

  // ── Reports Management ────────────────────────────────────────────────────
  void addReport(WargaReport report) {
    _reports = [report, ..._reports];
    notifyListeners();
    _saveReportsToStorage();
  }

  void verifyReport(String id) {
    _reports = _reports.map((r) {
      if (r.id == id) {
        return r.copyWith(isVerified: true);
      }
      return r;
    }).toList();
    notifyListeners();
    _saveReportsToStorage();
  }

  void confirmReport(String id) {
    _reports = _reports.map((r) {
      if (r.id == id) {
        return r.copyWith(confirmations: r.confirmations + 1);
      }
      return r;
    }).toList();
    notifyListeners();
    _saveReportsToStorage();
  }

  void deleteReport(String id) {
    _reports = _reports.where((r) => r.id != id).toList();
    notifyListeners();
    _saveReportsToStorage();
  }

  // ── Checklist Management ──────────────────────────────────────────────────
  void toggleChecklistItem(String id) {
    _checklist = _checklist.map((item) {
      if (item.id == id) {
        return item.copyWith(isChecked: !item.isChecked);
      }
      return item;
    }).toList();
    notifyListeners();
    _saveChecklistToStorage();
  }

  void resetChecklist() {
    _checklist =
        _checklist.map((item) => item.copyWith(isChecked: false)).toList();
    notifyListeners();
    _saveChecklistToStorage();
  }

  // ── Custom Contacts ───────────────────────────────────────────────────────
  void addCustomContact(EmergencyContact contact) {
    _customContacts = [..._customContacts, contact];
    notifyListeners();
    _saveCustomContactsToStorage();
  }

  void deleteCustomContact(String name) {
    _customContacts = _customContacts.where((c) => c.name != name).toList();
    notifyListeners();
    _saveCustomContactsToStorage();
  }

  // ── Official Bandar Lampung Emergency Contacts ────────────────────────────
  List<EmergencyContact> get allEmergencyContacts => [
        const EmergencyContact(
          name: 'Call Center Bandar Lampung Siaga 112',
          phone: '112',
          icon: '🚨',
          description: 'Layanan Darurat Terpadu Pemkot Bandar Lampung (Bebas Pulsa)',
        ),
        const EmergencyContact(
          name: 'BPBD Kota Bandar Lampung',
          phone: '0721252741',
          icon: '🚒',
          description: 'Jl. Mayor Salim Batubara No. 44, Kupang Teba (Pusdalops 24 Jam)',
        ),
        const EmergencyContact(
          name: 'Hotline WhatsApp BPBD Bandar Lampung',
          phone: '0811790119',
          icon: '💬',
          description: 'Layanan Laporan Cepat & Evakuasi Banjir BPBD',
        ),
        const EmergencyContact(
          name: 'Basarnas Kantor SAR Lampung',
          phone: '0721787400',
          icon: '🚁',
          description: 'Penyelamatan & Evakuasi Korban Terjebak Banjir Bandang',
        ),
        const EmergencyContact(
          name: 'Damkar & Penyelamatan Kota Bandar Lampung',
          phone: '113',
          icon: '🔥',
          description: 'Posko Induk Damkar & Penyelamatan Air',
        ),
        const EmergencyContact(
          name: 'PMI Kota Bandar Lampung',
          phone: '0721253452',
          icon: '🚑',
          description: 'Layanan Ambulans Darurat & Bantuan Medis Lapangan',
        ),
        const EmergencyContact(
          name: 'Polresta Bandar Lampung',
          phone: '110',
          icon: '👮',
          description: 'Pengamanan Jalur Lalu Lintas & Wilayah Terdampak',
        ),
        const EmergencyContact(
          name: 'Posko Relawan Tagana Bandar Lampung',
          phone: '081279888990',
          icon: '🤝',
          description: 'Taruna Siaga Bencana Dinsos Kota Bandar Lampung',
        ),
        ..._customContacts,
      ];

  // ── Safety Tips ───────────────────────────────────────────────────────────
  List<SafetyTip> get safetyTips => const [
        SafetyTip(
          icon: '⚡',
          title: 'Matikan Listrik & MCB Utama',
          description:
              'Segera matikan saklar MCB utama rumah dan cabut regulator gas untuk mencegah korsleting mematikan dan kebakaran saat air mulai masuk.',
        ),
        SafetyTip(
          icon: '📦',
          title: 'Amankan Dokumen ke Tempat Tinggi',
          description:
              'Simpan ijazah, sertifikat, buku tabungan, dan barang elektronik ke lantai 2 atau tempat setinggi mungkin dalam kantong plastik kedap air (waterproof).',
        ),
        SafetyTip(
          icon: '🎒',
          title: 'Bawa Tas Siaga Bencana (72 Jam)',
          description:
              'Pastikan Tas Siaga Bencana sudah siap dibawa. Berisi air minum, biskuit energi, obat-obatan esensial, pakaian ganti, senter, dan powerbank.',
        ),
        SafetyTip(
          icon: '🚫',
          title: 'Jangan Terobos Genangan Arus Deras',
          description:
              'Arus air setinggi 15 cm sudah mampu menjatuhkan orang dewasa. Arus 30 cm sanggup menyeret kendaraan mobil. Gunakan tongkat untuk mengecek kedalaman.',
        ),
        SafetyTip(
          icon: '🏠',
          title: 'Gunakan Jalur Evakuasi Resmi Bandar Lampung',
          description:
              'Ikuti petunjuk rambu evakuasi menuju shelter terdekat seperti GSG Unila, GOR Saburai, atau Balai Kelurahan. Hindari gorong-gorong terbuka.',
        ),
        SafetyTip(
          icon: '📱',
          title: 'Pantau Saluran Resmi BPBD Bandar Lampung',
          description:
              'Selalu perbarui informasi lewat aplikasi BlastSafe dan radio tanggap bencana. Hemat baterai ponsel Anda dengan mematikan aplikasi non-esensial.',
        ),
        SafetyTip(
          icon: '🐾',
          title: 'Evakuasi Hewan Peliharaan & Ternak',
          description:
              'Lepaskan ikatan atau bawa hewan peliharaan bersama Anda ke tempat aman. Jangan biarkan hewan terkunci di kandang saat banjir naik.',
        ),
        SafetyTip(
          icon: '💧',
          title: 'Waspada Air Tercemar Pasca Banjir',
          description:
              'Jangan minum air kran atau sumur yang terendam banjir sebelum disterilkan atau direbus hingga mendidih. Waspada gigitan ular di sela reruntuhan.',
        ),
      ];
}
