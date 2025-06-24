class OfficeLocationModel {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final String description;

  OfficeLocationModel({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.description,
  });

  factory OfficeLocationModel.fromJson(Map<String, dynamic> json) {
    return OfficeLocationModel(
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      radiusMeters: _parseInt(json['radius_meters']),
      description: json['description']?.toString() ?? '',
    );
  }

  // Safe double parsing - FIXED toDouble() error
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('🔥 WARNING: Could not parse "$value" to double, using 0.0');
        return 0.0;
      }
    }
    print(
        '🔥 WARNING: Unexpected type ${value.runtimeType} for double parsing, using 0.0');
    return 0.0;
  }

  // Safe int parsing
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        try {
          return double.parse(value).toInt();
        } catch (e2) {
          print('🔥 WARNING: Could not parse "$value" to int, using 0');
          return 0;
        }
      }
    }
    print(
        '🔥 WARNING: Unexpected type ${value.runtimeType} for int parsing, using 0');
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'radius_meters': radiusMeters,
      'description': description,
    };
  }
}

class BranchLocationModel {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final String description;

  BranchLocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.description,
  });

  factory BranchLocationModel.fromJson(Map<String, dynamic> json) {
    return BranchLocationModel(
      id: OfficeLocationModel._parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: OfficeLocationModel._parseDouble(json['latitude']),
      longitude: OfficeLocationModel._parseDouble(json['longitude']),
      radiusMeters: OfficeLocationModel._parseInt(json['radius_meters']),
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'radius_meters': radiusMeters,
      'description': description,
    };
  }
}

class LocationSettingsModel {
  final bool enableLocationValidation;
  final int defaultRadiusMeters;
  final bool allowManualLocation;
  final bool strictMode;
  final Map<String, String> notificationMessage;

  LocationSettingsModel({
    required this.enableLocationValidation,
    required this.defaultRadiusMeters,
    required this.allowManualLocation,
    required this.strictMode,
    required this.notificationMessage,
  });

  factory LocationSettingsModel.fromJson(Map<String, dynamic> json) {
    // Safe map parsing
    Map<String, String> parseNotificationMessage(dynamic value) {
      if (value is Map) {
        return Map<String, String>.from(
            value.map((k, v) => MapEntry(k.toString(), v.toString())));
      }
      return <String, String>{};
    }

    return LocationSettingsModel(
      enableLocationValidation: json['enable_location_validation'] == true ||
          json['enable_location_validation'] == 'true',
      defaultRadiusMeters:
          OfficeLocationModel._parseInt(json['default_radius_meters'] ?? 800),
      allowManualLocation: json['allow_manual_location'] == true ||
          json['allow_manual_location'] == 'true',
      strictMode: json['strict_mode'] == true || json['strict_mode'] == 'true',
      notificationMessage:
          parseNotificationMessage(json['notification_message']),
    );
  }

  String get outsideAreaMessage =>
      notificationMessage['outside_area'] ?? 'Anda berada di luar area kantor';

  String get locationNotFoundMessage =>
      notificationMessage['location_not_found'] ??
      'Tidak dapat mendeteksi lokasi';
}

class LocationConfigModel {
  final OfficeLocationModel officeLocation;
  final List<BranchLocationModel> branchLocations;
  final LocationSettingsModel settings;

  LocationConfigModel({
    required this.officeLocation,
    required this.branchLocations,
    required this.settings,
  });

  factory LocationConfigModel.fromJson(Map<String, dynamic> json) {
    try {
      // Safe branch locations parsing
      List<BranchLocationModel> parseBranchLocations(dynamic value) {
        if (value is List) {
          return value
              .map((branch) {
                try {
                  return BranchLocationModel.fromJson(
                      branch is Map ? Map<String, dynamic>.from(branch) : {});
                } catch (e) {
                  print('🔥 WARNING: Failed to parse branch location: $e');
                  return null;
                }
              })
              .where((branch) => branch != null)
              .cast<BranchLocationModel>()
              .toList();
        }
        return <BranchLocationModel>[];
      }

      return LocationConfigModel(
        officeLocation: OfficeLocationModel.fromJson(
          json['office_location'] is Map
              ? Map<String, dynamic>.from(json['office_location'])
              : {},
        ),
        branchLocations: parseBranchLocations(json['branch_locations']),
        settings: LocationSettingsModel.fromJson(
          json['settings'] is Map
              ? Map<String, dynamic>.from(json['settings'])
              : {},
        ),
      );
    } catch (e) {
      print('🔥 ERROR: Failed to parse LocationConfigModel: $e');
      print('🔥 Using default configuration...');

      // Return safe default config
      return LocationConfigModel(
        officeLocation: OfficeLocationModel(
          name: 'Kantor Pusat',
          address: 'Default Office Location',
          latitude: -6.200000,
          longitude: 106.816666,
          radiusMeters: 800,
          description: 'Default office location',
        ),
        branchLocations: [],
        settings: LocationSettingsModel(
          enableLocationValidation: true,
          defaultRadiusMeters: 800,
          allowManualLocation: false,
          strictMode: true,
          notificationMessage: {
            'outside_area': 'Anda berada di luar area kantor',
            'location_not_found': 'Tidak dapat mendeteksi lokasi',
          },
        ),
      );
    }
  }

  List<Map<String, dynamic>> get allLocations {
    List<Map<String, dynamic>> locations = [];

    // Add office location
    locations.add({
      'type': 'office',
      'id': 0,
      'name': officeLocation.name,
      'address': officeLocation.address,
      'latitude': officeLocation.latitude,
      'longitude': officeLocation.longitude,
      'radius': officeLocation.radiusMeters,
      'description': officeLocation.description,
    });

    // Add branch locations
    for (var branch in branchLocations) {
      locations.add({
        'type': 'branch',
        'id': branch.id,
        'name': branch.name,
        'address': branch.address,
        'latitude': branch.latitude,
        'longitude': branch.longitude,
        'radius': branch.radiusMeters,
        'description': branch.description,
      });
    }

    return locations;
  }
}

class LocationValidationResult {
  final bool isValid;
  final String message;
  final double? distanceMeters;
  final String? nearestLocationName;
  final String? nearestLocationType;

  LocationValidationResult({
    required this.isValid,
    required this.message,
    this.distanceMeters,
    this.nearestLocationName,
    this.nearestLocationType,
  });

  factory LocationValidationResult.valid({
    required String locationName,
    required double distance,
    required String locationType,
  }) {
    return LocationValidationResult(
      isValid: true,
      message:
          'Anda berada di area $locationName (${distance.toStringAsFixed(0)}m)',
      distanceMeters: distance,
      nearestLocationName: locationName,
      nearestLocationType: locationType,
    );
  }

  factory LocationValidationResult.invalid({
    required String message,
    double? distance,
    String? nearestLocationName,
    String? locationType,
  }) {
    return LocationValidationResult(
      isValid: false,
      message: message,
      distanceMeters: distance,
      nearestLocationName: nearestLocationName,
      nearestLocationType: locationType,
    );
  }
}
