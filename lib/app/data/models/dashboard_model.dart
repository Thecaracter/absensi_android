// File: lib/app/data/models/dashboard_model.dart

class DashboardResponse {
  final bool success;
  final String message;
  final DashboardData data;

  DashboardResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: DashboardData.fromJson(json['data'] ?? {}),
    );
  }
}

class DashboardData {
  final UserInfo user;
  final AttendanceToday absensiHariIni;
  final AttendanceStats statistikAbsensi;
  final LeaveStats statistikIzin;
  final List<RecentAttendance> riwayat7Hari;
  final List<NotificationItem> notifikasi;
  final QuickActions quickActions;

  DashboardData({
    required this.user,
    required this.absensiHariIni,
    required this.statistikAbsensi,
    required this.statistikIzin,
    required this.riwayat7Hari,
    required this.notifikasi,
    required this.quickActions,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      user: UserInfo.fromJson(json['user'] ?? {}),
      absensiHariIni: AttendanceToday.fromJson(json['absensi_hari_ini'] ?? {}),
      statistikAbsensi:
          AttendanceStats.fromJson(json['statistik_absensi'] ?? {}),
      statistikIzin: LeaveStats.fromJson(json['statistik_izin'] ?? {}),
      riwayat7Hari: (json['riwayat_7_hari'] as List<dynamic>?)
              ?.map((item) => RecentAttendance.fromJson(item))
              .toList() ??
          [],
      notifikasi: (json['notifikasi'] as List<dynamic>?)
              ?.map((item) => NotificationItem.fromJson(item))
              .toList() ??
          [],
      quickActions: QuickActions.fromJson(json['quick_actions'] ?? {}),
    );
  }
}

class UserInfo {
  final String name;
  final String idKaryawan;
  final String? fotoUrl;

  UserInfo({
    required this.name,
    required this.idKaryawan,
    this.fotoUrl,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      name: json['name']?.toString() ?? '',
      idKaryawan: json['id_karyawan']?.toString() ?? '',
      fotoUrl: json['foto_url']?.toString(),
    );
  }
}

class AttendanceToday {
  final bool sudahCheckIn;
  final bool sudahCheckOut;
  final String? jamMasuk;
  final String? jamKeluar;
  final String? statusAbsen;
  final int menitTerlambat;
  final ShiftInfo? shift;

  AttendanceToday({
    required this.sudahCheckIn,
    required this.sudahCheckOut,
    this.jamMasuk,
    this.jamKeluar,
    this.statusAbsen,
    required this.menitTerlambat,
    this.shift,
  });

  factory AttendanceToday.fromJson(Map<String, dynamic> json) {
    return AttendanceToday(
      sudahCheckIn: _parseBool(json['sudah_check_in']),
      sudahCheckOut: _parseBool(json['sudah_check_out']),
      jamMasuk: json['jam_masuk']?.toString(),
      jamKeluar: json['jam_keluar']?.toString(),
      statusAbsen: json['status_absen']?.toString(),
      menitTerlambat: _parseInt(json['menit_terlambat']),
      shift: json['shift'] != null ? ShiftInfo.fromJson(json['shift']) : null,
    );
  }
}

class ShiftInfo {
  final String nama;
  final String jamMasuk;
  final String jamKeluar;

  ShiftInfo({
    required this.nama,
    required this.jamMasuk,
    required this.jamKeluar,
  });

  factory ShiftInfo.fromJson(Map<String, dynamic> json) {
    return ShiftInfo(
      nama: json['nama']?.toString() ?? '',
      jamMasuk: json['jam_masuk']?.toString() ?? '',
      jamKeluar: json['jam_keluar']?.toString() ?? '',
    );
  }
}

class AttendanceStats {
  final int totalHariKerja;
  final int totalHadir;
  final int totalTerlambat;
  final double tingkatKehadiran;

  AttendanceStats({
    required this.totalHariKerja,
    required this.totalHadir,
    required this.totalTerlambat,
    required this.tingkatKehadiran,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      totalHariKerja: _parseInt(json['total_hari_kerja']),
      totalHadir: _parseInt(json['total_hadir']),
      totalTerlambat: _parseInt(json['total_terlambat']),
      tingkatKehadiran: _parseDouble(json['tingkat_kehadiran']),
    );
  }
}

class LeaveStats {
  final int totalPengajuanBulanIni;
  final int menungguApproval;
  final int totalHariIzinTahunIni;
  final int kuotaCuti;
  final int sisaKuota;

  LeaveStats({
    required this.totalPengajuanBulanIni,
    required this.menungguApproval,
    required this.totalHariIzinTahunIni,
    required this.kuotaCuti,
    required this.sisaKuota,
  });

  factory LeaveStats.fromJson(Map<String, dynamic> json) {
    return LeaveStats(
      totalPengajuanBulanIni: _parseInt(json['total_pengajuan_bulan_ini']),
      menungguApproval: _parseInt(json['menunggu_approval']),
      totalHariIzinTahunIni: _parseInt(json['total_hari_izin_tahun_ini']),
      kuotaCuti: _parseInt(json['kuota_cuti']),
      sisaKuota: _parseInt(json['sisa_kuota']),
    );
  }
}

class RecentAttendance {
  final String tanggal;
  final String hari;
  final String? statusAbsen;
  final String? jamMasuk;
  final String? jamKeluar;
  final bool terlambat;

  RecentAttendance({
    required this.tanggal,
    required this.hari,
    this.statusAbsen,
    this.jamMasuk,
    this.jamKeluar,
    required this.terlambat,
  });

  factory RecentAttendance.fromJson(Map<String, dynamic> json) {
    return RecentAttendance(
      tanggal: json['tanggal']?.toString() ?? '',
      hari: json['hari']?.toString() ?? '',
      statusAbsen: json['status']?.toString(),
      jamMasuk: json['jam_masuk']?.toString(),
      jamKeluar: json['jam_keluar']?.toString(),
      terlambat: _parseBool(json['terlambat']),
    );
  }
}

class NotificationItem {
  final String type;
  final String title;
  final String message;
  final String action;

  NotificationItem({
    required this.type,
    required this.title,
    required this.message,
    required this.action,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
    );
  }
}

class QuickActions {
  final bool canCheckIn;
  final bool canCheckOut;
  final bool canRequestLeave;

  QuickActions({
    required this.canCheckIn,
    required this.canCheckOut,
    required this.canRequestLeave,
  });

  factory QuickActions.fromJson(Map<String, dynamic> json) {
    return QuickActions(
      canCheckIn: _parseBool(json['can_check_in']),
      canCheckOut: _parseBool(json['can_check_out']),
      canRequestLeave: _parseBool(json['can_request_leave']),
    );
  }
}

// Helper functions for safe type conversion
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    try {
      return int.parse(value);
    } catch (e) {
      try {
        return double.parse(value).toInt();
      } catch (e) {
        return 0;
      }
    }
  }
  return 0;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    try {
      return double.parse(value);
    } catch (e) {
      return 0.0;
    }
  }
  return 0.0;
}

bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) {
    final lowercaseValue = value.toLowerCase();
    return lowercaseValue == 'true' ||
        lowercaseValue == '1' ||
        lowercaseValue == 'yes';
  }
  return false;
}
