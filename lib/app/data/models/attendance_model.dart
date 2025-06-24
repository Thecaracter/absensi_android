class AttendanceModel {
  final int? id;
  final String? tanggalAbsen;
  final ShiftModel? shift;
  final String? jamMasuk;
  final String? jamKeluar;
  final String? fotoMasukUrl;
  final String? fotoKeluarUrl;
  final double? latitudeMasuk;
  final double? longitudeMasuk;
  final double? latitudeKeluar;
  final double? longitudeKeluar;
  final String? statusAbsen;
  final String? statusMasuk;
  final String? statusKeluar;
  final int? menitTerlambat;
  final int? menitLembur;
  final String? catatanAdmin;
  final bool sudahCheckIn;
  final bool sudahCheckOut;
  final bool dapatCheckOut;
  final String? statusAbsenText;
  final String? jamMasukFormatted;
  final String? jamKeluarFormatted;
  final String? durasiKerjaFormatted;
  final String? terlambatText;
  final bool? isComplete;
  final String? attendanceStage;

  AttendanceModel({
    this.id,
    this.tanggalAbsen,
    this.shift,
    this.jamMasuk,
    this.jamKeluar,
    this.fotoMasukUrl,
    this.fotoKeluarUrl,
    this.latitudeMasuk,
    this.longitudeMasuk,
    this.latitudeKeluar,
    this.longitudeKeluar,
    this.statusAbsen,
    this.statusMasuk,
    this.statusKeluar,
    this.menitTerlambat,
    this.menitLembur,
    this.catatanAdmin,
    this.sudahCheckIn = false,
    this.sudahCheckOut = false,
    this.dapatCheckOut = false,
    this.statusAbsenText,
    this.jamMasukFormatted,
    this.jamKeluarFormatted,
    this.durasiKerjaFormatted,
    this.terlambatText,
    this.isComplete,
    this.attendanceStage,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔥 ATTENDANCE MODEL: Parsing JSON...');
      print('🔥 ATTENDANCE MODEL: Raw shift data: ${json['shift']}');
      print(
          '🔥 ATTENDANCE MODEL: latitude_masuk type: ${json['latitude_masuk'].runtimeType}');
      print(
          '🔥 ATTENDANCE MODEL: latitude_masuk value: ${json['latitude_masuk']}');

      return AttendanceModel(
        id: _parseToInt(json['id']),
        tanggalAbsen: json['tanggal_absen']?.toString(),
        shift:
            json['shift'] != null ? ShiftModel.fromJson(json['shift']) : null,
        jamMasuk: json['jam_masuk']?.toString(),
        jamKeluar: json['jam_keluar']?.toString(),
        fotoMasukUrl: json['foto_masuk_url']?.toString(),
        fotoKeluarUrl: json['foto_keluar_url']?.toString(),

        // FIXED: Extra safe parsing for latitude/longitude
        latitudeMasuk: _safeParseMappedDouble(json['latitude_masuk']),
        longitudeMasuk: _safeParseMappedDouble(json['longitude_masuk']),
        latitudeKeluar: _safeParseMappedDouble(json['latitude_keluar']),
        longitudeKeluar: _safeParseMappedDouble(json['longitude_keluar']),

        statusAbsen: json['status_absen']?.toString(),
        statusMasuk: json['status_masuk']?.toString(),
        statusKeluar: json['status_keluar']?.toString(),
        menitTerlambat: _parseToInt(json['menit_terlambat']),
        menitLembur: _parseToInt(json['menit_lembur']),
        catatanAdmin: json['catatan_admin']?.toString(),
        sudahCheckIn: json['sudah_check_in'] == true,
        sudahCheckOut: json['sudah_check_out'] == true,
        dapatCheckOut: json['dapat_check_out'] == true,
        statusAbsenText: json['status_absen_text']?.toString(),
        jamMasukFormatted: json['jam_masuk_formatted']?.toString(),
        jamKeluarFormatted: json['jam_keluar_formatted']?.toString(),
        durasiKerjaFormatted: json['durasi_kerja_formatted']?.toString(),
        terlambatText: json['terlambat_text']?.toString(),
        isComplete: json['is_complete'],
        attendanceStage: json['attendance_stage']?.toString(),
      );
    } catch (e) {
      print('🔥 ATTENDANCE MODEL: ❌ Error parsing: $e');
      print('🔥 ATTENDANCE MODEL: ❌ Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // EXTRA SAFE DOUBLE PARSING - specifically for coordinates
  static double? _safeParseMappedDouble(dynamic value) {
    print('🔥 PARSE DOUBLE: Input value: $value (${value.runtimeType})');

    if (value == null) {
      print('🔥 PARSE DOUBLE: Value is null, returning null');
      return null;
    }

    // Direct double
    if (value is double) {
      print('🔥 PARSE DOUBLE: Value is already double: $value');
      return value;
    }

    // Convert int to double
    if (value is int) {
      print('🔥 PARSE DOUBLE: Converting int to double: $value');
      return value.toDouble();
    }

    // Parse string
    if (value is String) {
      if (value.isEmpty || value.trim().isEmpty) {
        print('🔥 PARSE DOUBLE: String is empty, returning null');
        return null;
      }

      final trimmed = value.trim();
      print('🔥 PARSE DOUBLE: Attempting to parse string: "$trimmed"');

      try {
        final result = double.parse(trimmed);
        print('🔥 PARSE DOUBLE: ✅ Successfully parsed: $result');
        return result;
      } catch (e) {
        print('🔥 PARSE DOUBLE: ❌ Failed to parse "$trimmed": $e');
        return null;
      }
    }

    // Handle boolean (edge case)
    if (value is bool) {
      print('🔥 PARSE DOUBLE: Value is boolean, returning null');
      return null;
    }

    // Unexpected type
    print(
        '🔥 PARSE DOUBLE: ❌ Unexpected type ${value.runtimeType}, returning null');
    return null;
  }

  // SAFE DOUBLE PARSING - handles String, int, double, null
  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;
    if (value is int) return value.toDouble();

    if (value is String) {
      if (value.isEmpty) return null;
      try {
        return double.parse(value);
      } catch (e) {
        print('🔥 ATTENDANCE MODEL: ❌ Cannot parse "$value" to double: $e');
        return null;
      }
    }

    print(
        '🔥 ATTENDANCE MODEL: ❌ Unexpected type ${value.runtimeType} for double parsing');
    return null;
  }

  // SAFE INT PARSING - handles String, int, double, null
  static int? _parseToInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;
    if (value is double) return value.toInt();

    if (value is String) {
      if (value.isEmpty) return null;
      try {
        return int.parse(value);
      } catch (e) {
        try {
          return double.parse(value).toInt();
        } catch (e2) {
          print('🔥 ATTENDANCE MODEL: ❌ Cannot parse "$value" to int: $e');
          return null;
        }
      }
    }

    print(
        '🔥 ATTENDANCE MODEL: ❌ Unexpected type ${value.runtimeType} for int parsing');
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal_absen': tanggalAbsen,
      'shift': shift?.toJson(),
      'jam_masuk': jamMasuk,
      'jam_keluar': jamKeluar,
      'foto_masuk_url': fotoMasukUrl,
      'foto_keluar_url': fotoKeluarUrl,
      'latitude_masuk': latitudeMasuk,
      'longitude_masuk': longitudeMasuk,
      'latitude_keluar': latitudeKeluar,
      'longitude_keluar': longitudeKeluar,
      'status_absen': statusAbsen,
      'status_masuk': statusMasuk,
      'status_keluar': statusKeluar,
      'menit_terlambat': menitTerlambat,
      'menit_lembur': menitLembur,
      'catatan_admin': catatanAdmin,
      'sudah_check_in': sudahCheckIn,
      'sudah_check_out': sudahCheckOut,
      'dapat_check_out': dapatCheckOut,
      'status_absen_text': statusAbsenText,
      'jam_masuk_formatted': jamMasukFormatted,
      'jam_keluar_formatted': jamKeluarFormatted,
      'durasi_kerja_formatted': durasiKerjaFormatted,
      'terlambat_text': terlambatText,
      'is_complete': isComplete,
      'attendance_stage': attendanceStage,
    };
  }
}

class ShiftModel {
  final int id;
  final String nama;
  final String jamMasuk;
  final String jamKeluar;
  final int toleransiMenit;

  ShiftModel({
    required this.id,
    required this.nama,
    required this.jamMasuk,
    required this.jamKeluar,
    required this.toleransiMenit,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔥 SHIFT MODEL: Parsing shift JSON...');
      print('🔥 SHIFT MODEL: Full json: $json');
      print(
          '🔥 SHIFT MODEL: Shift ID: ${json['id']} (${json['id'].runtimeType})');
      print('🔥 SHIFT MODEL: Shift Name: ${json['nama']}');

      return ShiftModel(
        id: AttendanceModel._parseToInt(json['id']) ?? 0,
        nama: json['nama']?.toString() ?? '',
        jamMasuk: json['jam_masuk']?.toString() ?? '',
        jamKeluar: json['jam_keluar']?.toString() ?? '',
        toleransiMenit:
            AttendanceModel._parseToInt(json['toleransi_menit']) ?? 0,
      );
    } catch (e) {
      print('🔥 SHIFT MODEL: ❌ Error parsing shift: $e');
      print('🔥 SHIFT MODEL: ❌ Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'jam_masuk': jamMasuk,
      'jam_keluar': jamKeluar,
      'toleransi_menit': toleransiMenit,
    };
  }
}
