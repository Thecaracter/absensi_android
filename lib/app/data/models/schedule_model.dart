// lib/app/data/models/schedule_models.dart
import 'package:flutter/material.dart';

// Main Response Model
class ScheduleResponse {
  final bool success;
  final String message;
  final ScheduleData data;

  ScheduleResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ScheduleData.fromJson(json['data'] ?? {}),
    );
  }
}

// Schedule Data Model
class ScheduleData {
  final PeriodInfo period;
  final List<CalendarDay> calendar;
  final ScheduleStatistics statistics;
  final UserInfo user;

  ScheduleData({
    required this.period,
    required this.calendar,
    required this.statistics,
    required this.user,
  });

  factory ScheduleData.fromJson(Map<String, dynamic> json) {
    return ScheduleData(
      period: PeriodInfo.fromJson(json['period'] ?? {}),
      calendar: (json['calendar'] as List<dynamic>?)
              ?.map((e) => CalendarDay.fromJson(e))
              .toList() ??
          [],
      statistics: ScheduleStatistics.fromJson(json['statistics'] ?? {}),
      user: UserInfo.fromJson(json['user'] ?? {}),
    );
  }
}

// Period Info Model
class PeriodInfo {
  final int year;
  final int month;
  final String monthName;
  final String monthNameId;
  final String periodText;
  final String periodTextId;
  final String startDate;
  final String endDate;
  final int totalDays;
  final bool isCurrentMonth;
  final bool? isCurrentWeek; // for weekly
  final String? weekText; // for weekly

  PeriodInfo({
    required this.year,
    required this.month,
    required this.monthName,
    required this.monthNameId,
    required this.periodText,
    required this.periodTextId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.isCurrentMonth,
    this.isCurrentWeek,
    this.weekText,
  });

  factory PeriodInfo.fromJson(Map<String, dynamic> json) {
    return PeriodInfo(
      year: _parseInt(json['year']),
      month: _parseInt(json['month']),
      monthName: json['month_name'] ?? '',
      monthNameId: json['month_name_id'] ?? '',
      periodText: json['period_text'] ?? '',
      periodTextId: json['period_text_id'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      totalDays: _parseInt(json['total_days']),
      isCurrentMonth: json['is_current_month'] ?? false,
      isCurrentWeek: json['is_current_week'],
      weekText: json['week_text'],
    );
  }
}

// Calendar Day Model
class CalendarDay {
  final String date;
  final int day;
  final String dayName;
  final String dayNameShort;
  final String dayNameId;
  final bool isWeekend;
  final bool isToday;
  final bool isPast;
  final bool isFuture;
  final bool hasSchedule;
  final int? attendanceId;
  final Shift? shift;
  final String? jamMasukActual;
  final String? jamKeluarActual;
  final String? statusAbsen;
  final String? statusMasuk;
  final String? statusKeluar;
  final int menitTerlambat;
  final int menitLembur;
  final bool sudahCheckIn;
  final bool sudahCheckOut;
  final bool isComplete;
  final String? durasiKerja;

  CalendarDay({
    required this.date,
    required this.day,
    required this.dayName,
    required this.dayNameShort,
    required this.dayNameId,
    required this.isWeekend,
    required this.isToday,
    required this.isPast,
    required this.isFuture,
    required this.hasSchedule,
    this.attendanceId,
    this.shift,
    this.jamMasukActual,
    this.jamKeluarActual,
    this.statusAbsen,
    this.statusMasuk,
    this.statusKeluar,
    this.menitTerlambat = 0,
    this.menitLembur = 0,
    this.sudahCheckIn = false,
    this.sudahCheckOut = false,
    this.isComplete = false,
    this.durasiKerja,
  });

  factory CalendarDay.fromJson(Map<String, dynamic> json) {
    return CalendarDay(
      date: json['date'] ?? '',
      day: _parseInt(json['day']),
      dayName: json['day_name'] ?? '',
      dayNameShort: json['day_name_short'] ?? '',
      dayNameId: json['day_name_id'] ?? '',
      isWeekend: json['is_weekend'] ?? false,
      isToday: json['is_today'] ?? false,
      isPast: json['is_past'] ?? false,
      isFuture: json['is_future'] ?? false,
      hasSchedule: json['has_schedule'] ?? false,
      attendanceId: _parseIntNullable(json['attendance_id']),
      shift: json['shift'] != null ? Shift.fromJson(json['shift']) : null,
      jamMasukActual: json['jam_masuk_actual'],
      jamKeluarActual: json['jam_keluar_actual'],
      statusAbsen: json['status_absen'],
      statusMasuk: json['status_masuk'],
      statusKeluar: json['status_keluar'],
      menitTerlambat: _parseInt(json['menit_terlambat']),
      menitLembur: _parseInt(json['menit_lembur']),
      sudahCheckIn: json['sudah_check_in'] ?? false,
      sudahCheckOut: json['sudah_check_out'] ?? false,
      isComplete: json['is_complete'] ?? false,
      durasiKerja: json['durasi_kerja'],
    );
  }

  // Helper untuk warna status
  Color get statusColor {
    switch (statusAbsen) {
      case 'hadir':
        return const Color(0xFF10B981); // Green
      case 'terlambat':
        return const Color(0xFFF59E0B); // Yellow
      case 'tidak_hadir':
        return const Color(0xFFEF4444); // Red
      case 'izin':
        return const Color(0xFF3B82F6); // Blue
      case 'menunggu':
        return const Color(0xFFF97316); // Orange
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  // Helper untuk text status
  String get statusText {
    if (!hasSchedule) {
      return isWeekend ? 'Libur' : 'Tidak Ada Jadwal';
    }

    switch (statusAbsen) {
      case 'hadir':
        return 'Hadir';
      case 'terlambat':
        return 'Terlambat';
      case 'tidak_hadir':
        return 'Tidak Hadir';
      case 'izin':
        return 'Izin';
      case 'menunggu':
        return 'Menunggu';
      default:
        return 'Belum Absen';
    }
  }
}

// Shift Model
class Shift {
  final int id;
  final String nama;
  final String jamMasuk;
  final String jamKeluar;
  final int? toleransiMenit;

  Shift({
    required this.id,
    required this.nama,
    required this.jamMasuk,
    required this.jamKeluar,
    this.toleransiMenit,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: _parseInt(json['id']),
      nama: json['nama'] ?? '',
      jamMasuk: json['jam_masuk'] ?? '',
      jamKeluar: json['jam_keluar'] ?? '',
      toleransiMenit: _parseIntNullable(json['toleransi_menit']),
    );
  }

  String get jamKerja => '$jamMasuk - $jamKeluar';
}

// Schedule Statistics Model
class ScheduleStatistics {
  final int totalHariDalamBulan;
  final int totalHariKerja;
  final int totalWeekend;
  final int totalHadir;
  final int totalTerlambat;
  final int totalTidakHadir;
  final int totalIzin;
  final int totalMenunggu;
  final int? totalIncomplete;
  final double tingkatKehadiran;
  final double? tingkatKetepatan;

  ScheduleStatistics({
    required this.totalHariDalamBulan,
    required this.totalHariKerja,
    required this.totalWeekend,
    required this.totalHadir,
    required this.totalTerlambat,
    required this.totalTidakHadir,
    required this.totalIzin,
    required this.totalMenunggu,
    this.totalIncomplete,
    required this.tingkatKehadiran,
    this.tingkatKetepatan,
  });

  factory ScheduleStatistics.fromJson(Map<String, dynamic> json) {
    return ScheduleStatistics(
      totalHariDalamBulan: _parseInt(json['total_hari_dalam_bulan']),
      totalHariKerja: _parseInt(json['total_hari_kerja']),
      totalWeekend: _parseInt(json['total_weekend']),
      totalHadir: _parseInt(json['total_hadir']),
      totalTerlambat: _parseInt(json['total_terlambat']),
      totalTidakHadir: _parseInt(json['total_tidak_hadir']),
      totalIzin: _parseInt(json['total_izin']),
      totalMenunggu: _parseInt(json['total_menunggu']),
      totalIncomplete: _parseIntNullable(json['total_incomplete']),
      tingkatKehadiran: _parseDouble(json['tingkat_kehadiran']),
      tingkatKetepatan: _parseDoubleNullable(json['tingkat_ketepatan']),
    );
  }
}

// User Info Model
class UserInfo {
  final int id;
  final String name;
  final String idKaryawan;

  UserInfo({
    required this.id,
    required this.name,
    required this.idKaryawan,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      idKaryawan: json['id_karyawan'] ?? '',
    );
  }
}

// Helper functions untuk type conversion yang aman
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  if (value is double) return value.toInt();
  return 0;
}

int? _parseIntNullable(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) {
    return int.tryParse(value);
  }
  if (value is double) return value.toInt();
  return null;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

double? _parseDoubleNullable(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}
