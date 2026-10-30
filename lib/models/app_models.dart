// lib/models/app_models.dart

enum FloodStatus { aman, waspada, siaga, bahaya }

class AppState {
  FloodStatus status;
  String warningMessage;
  bool showWarning;
  String adminUser;
  bool isLoggedIn;
  DateTime lastUpdated;

  AppState({
    this.status = FloodStatus.aman,
    this.warningMessage = '',
    this.showWarning = false,
    this.adminUser = '',
    this.isLoggedIn = false,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  String get statusLabel {
    switch (status) {
      case FloodStatus.aman:
        return 'AMAN';
      case FloodStatus.waspada:
        return 'WASPADA';
      case FloodStatus.siaga:
        return 'SIAGA';
      case FloodStatus.bahaya:
        return 'BAHAYA';
    }
  }

  String get statusEmoji {
    switch (status) {
      case FloodStatus.aman:
        return '✅';
      case FloodStatus.waspada:
        return '⚠️';
      case FloodStatus.siaga:
        return '🔶';
      case FloodStatus.bahaya:
        return '🚨';
    }
  }

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'warningMessage': warningMessage,
        'showWarning': showWarning,
        'adminUser': adminUser,
        'isLoggedIn': isLoggedIn,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory AppState.fromJson(Map<String, dynamic> json) {
    FloodStatus parseStatus(String? s) {
      switch (s) {
        case 'waspada':
          return FloodStatus.waspada;
        case 'siaga':
          return FloodStatus.siaga;
        case 'bahaya':
          return FloodStatus.bahaya;
        default:
          return FloodStatus.aman;
      }
    }

    return AppState(
      status: parseStatus(json['status'] as String?),
      warningMessage: json['warningMessage'] as String? ?? '',
      showWarning: json['showWarning'] as bool? ?? false,
      adminUser: json['adminUser'] as String? ?? '',
      isLoggedIn: json['isLoggedIn'] as bool? ?? false,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class WaterLevelSensor {
  final String location;
  final int currentLevelCm;
  final int normalMaxCm;
  final int waspadaMaxCm;
  final int siagaMaxCm;
  final String trend; // 'Naik', 'Turun', 'Stabil'
  final DateTime lastChecked;

  const WaterLevelSensor({
    required this.location,
    required this.currentLevelCm,
    this.normalMaxCm = 120,
    this.waspadaMaxCm = 180,
    this.siagaMaxCm = 240,
    required this.trend,
    required this.lastChecked,
  });

  String get statusLabel {
    if (currentLevelCm >= siagaMaxCm) return 'Siaga 1 (Kritis)';
    if (currentLevelCm >= waspadaMaxCm) return 'Siaga 2 (Waspada)';
    if (currentLevelCm >= normalMaxCm) return 'Siaga 3 (Hati-hati)';
    return 'Normal';
  }

  FloodStatus get floodStatus {
    if (currentLevelCm >= siagaMaxCm) return FloodStatus.bahaya;
    if (currentLevelCm >= waspadaMaxCm) return FloodStatus.siaga;
    if (currentLevelCm >= normalMaxCm) return FloodStatus.waspada;
    return FloodStatus.aman;
  }

  double get levelFraction => (currentLevelCm / 300).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
        'location': location,
        'currentLevelCm': currentLevelCm,
        'normalMaxCm': normalMaxCm,
        'waspadaMaxCm': waspadaMaxCm,
        'siagaMaxCm': siagaMaxCm,
        'trend': trend,
        'lastChecked': lastChecked.toIso8601String(),
      };

  factory WaterLevelSensor.fromJson(Map<String, dynamic> json) =>
      WaterLevelSensor(
        location: json['location'] as String? ?? 'Pintu Air Sungai Cimanggu',
        currentLevelCm: json['currentLevelCm'] as int? ?? 85,
        normalMaxCm: json['normalMaxCm'] as int? ?? 120,
        waspadaMaxCm: json['waspadaMaxCm'] as int? ?? 180,
        siagaMaxCm: json['siagaMaxCm'] as int? ?? 240,
        trend: json['trend'] as String? ?? 'Stabil',
        lastChecked: json['lastChecked'] != null
            ? DateTime.tryParse(json['lastChecked'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

class CctvCamera {
  final String id;
  final String code;
  final String name;
  final String locationDescription;
  final double lat;
  final double lng;
  final bool isOnline;
  final String currentStatus;
  final int waterLevelCm;
  final String resolution;
  final int bitrateKbps;
  final DateTime lastPing;

  const CctvCamera({
    required this.id,
    required this.code,
    required this.name,
    required this.locationDescription,
    required this.lat,
    required this.lng,
    this.isOnline = true,
    required this.currentStatus,
    required this.waterLevelCm,
    this.resolution = '1080p FHD • 30 FPS',
    this.bitrateKbps = 2450,
    required this.lastPing,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'locationDescription': locationDescription,
        'lat': lat,
        'lng': lng,
        'isOnline': isOnline,
        'currentStatus': currentStatus,
        'waterLevelCm': waterLevelCm,
        'resolution': resolution,
        'bitrateKbps': bitrateKbps,
        'lastPing': lastPing.toIso8601String(),
      };

  factory CctvCamera.fromJson(Map<String, dynamic> json) => CctvCamera(
        id: json['id'] as String,
        code: json['code'] as String? ?? 'CCTV-01',
        name: json['name'] as String,
        locationDescription: json['locationDescription'] as String? ?? '',
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        isOnline: json['isOnline'] as bool? ?? true,
        currentStatus: json['currentStatus'] as String? ?? 'Aman (Normal)',
        waterLevelCm: json['waterLevelCm'] as int? ?? 80,
        resolution: json['resolution'] as String? ?? '1080p FHD • 30 FPS',
        bitrateKbps: json['bitrateKbps'] as int? ?? 2450,
        lastPing: json['lastPing'] != null
            ? DateTime.tryParse(json['lastPing'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

class Shelter {
  final String id;
  final String name;
  final String address;
  final double distance;
  final int capacity;
  final int currentOccupancy;
  final String phone;
  final double lat;
  final double lng;
  final String type;
  final List<String> facilities;
  final bool isBookmarked;

  const Shelter({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.capacity,
    required this.currentOccupancy,
    required this.phone,
    required this.lat,
    required this.lng,
    required this.type,
    this.facilities = const ['Dapur Umum', 'P3K & Medis', 'Listrik/Genset'],
    this.isBookmarked = false,
  });

  String get statusLabel {
    final pct = currentOccupancy / capacity;
    if (pct >= 1.0) return 'Penuh';
    if (pct >= 0.8) return 'Hampir Penuh';
    return 'Tersedia';
  }

  bool get isAvailable => currentOccupancy < capacity;
  double get occupancyPercent => (currentOccupancy / capacity).clamp(0.0, 1.0);
  int get remainingSlots => (capacity - currentOccupancy).clamp(0, capacity);

  Shelter copyWith({
    String? id,
    String? name,
    String? address,
    double? distance,
    int? capacity,
    int? currentOccupancy,
    String? phone,
    double? lat,
    double? lng,
    String? type,
    List<String>? facilities,
    bool? isBookmarked,
  }) {
    return Shelter(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      distance: distance ?? this.distance,
      capacity: capacity ?? this.capacity,
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
      phone: phone ?? this.phone,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      type: type ?? this.type,
      facilities: facilities ?? this.facilities,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'distance': distance,
        'capacity': capacity,
        'currentOccupancy': currentOccupancy,
        'phone': phone,
        'lat': lat,
        'lng': lng,
        'type': type,
        'facilities': facilities,
        'isBookmarked': isBookmarked,
      };

  factory Shelter.fromJson(Map<String, dynamic> json) => Shelter(
        id: json['id'] as String,
        name: json['name'] as String,
        address: json['address'] as String,
        distance: (json['distance'] as num).toDouble(),
        capacity: json['capacity'] as int,
        currentOccupancy: json['currentOccupancy'] as int,
        phone: json['phone'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        type: json['type'] as String,
        facilities: (json['facilities'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const ['Dapur Umum', 'P3K & Medis'],
        isBookmarked: json['isBookmarked'] as bool? ?? false,
      );
}

class WargaReport {
  final String id;
  final String description;
  final String location;
  final DateTime time;
  final String reporterName;
  final bool isVerified;
  final String category;
  final String waterDepth;
  final String urgency;
  final int confirmations;
  final double? lat;
  final double? lng;

  const WargaReport({
    required this.id,
    required this.description,
    required this.location,
    required this.time,
    required this.reporterName,
    this.isVerified = false,
    this.category = 'Ketinggian Air',
    this.waterDepth = '30-70 cm',
    this.urgency = 'Penting',
    this.confirmations = 1,
    this.lat,
    this.lng,
  });

  WargaReport copyWith({
    String? id,
    String? description,
    String? location,
    DateTime? time,
    String? reporterName,
    bool? isVerified,
    String? category,
    String? waterDepth,
    String? urgency,
    int? confirmations,
    double? lat,
    double? lng,
  }) {
    return WargaReport(
      id: id ?? this.id,
      description: description ?? this.description,
      location: location ?? this.location,
      time: time ?? this.time,
      reporterName: reporterName ?? this.reporterName,
      isVerified: isVerified ?? this.isVerified,
      category: category ?? this.category,
      waterDepth: waterDepth ?? this.waterDepth,
      urgency: urgency ?? this.urgency,
      confirmations: confirmations ?? this.confirmations,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'location': location,
        'time': time.toIso8601String(),
        'reporterName': reporterName,
        'isVerified': isVerified,
        'category': category,
        'waterDepth': waterDepth,
        'urgency': urgency,
        'confirmations': confirmations,
        'lat': lat,
        'lng': lng,
      };

  factory WargaReport.fromJson(Map<String, dynamic> json) => WargaReport(
        id: json['id'] as String,
        description: json['description'] as String,
        location: json['location'] as String,
        time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
        reporterName: json['reporterName'] as String? ?? 'Anonim',
        isVerified: json['isVerified'] as bool? ?? false,
        category: json['category'] as String? ?? 'Ketinggian Air',
        waterDepth: json['waterDepth'] as String? ?? '30-70 cm',
        urgency: json['urgency'] as String? ?? 'Penting',
        confirmations: json['confirmations'] as int? ?? 1,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
      );
}

class ChecklistItem {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final bool isChecked;

  const ChecklistItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.isChecked = false,
  });

  ChecklistItem copyWith({bool? isChecked}) {
    return ChecklistItem(
      id: id,
      title: title,
      subtitle: subtitle,
      category: category,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'category': category,
        'isChecked': isChecked,
      };

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String? ?? '',
        category: json['category'] as String? ?? 'Dokumen & Medis',
        isChecked: json['isChecked'] as bool? ?? false,
      );
}

class SafetyTip {
  final String icon;
  final String title;
  final String description;

  const SafetyTip({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class EmergencyContact {
  final String name;
  final String phone;
  final String icon;
  final String description;
  final bool isCustom;

  const EmergencyContact({
    required this.name,
    required this.phone,
    required this.icon,
    required this.description,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'icon': icon,
        'description': description,
        'isCustom': isCustom,
      };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      EmergencyContact(
        name: json['name'] as String,
        phone: json['phone'] as String,
        icon: json['icon'] as String? ?? '📞',
        description: json['description'] as String? ?? '',
        isCustom: json['isCustom'] as bool? ?? false,
      );
}
