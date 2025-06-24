import 'package:flutter/material.dart';

class LeaveRequest {
  final int? id;
  final String jenisIzin;
  final String jenisIzinText;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String tanggalMulaiFormatted;
  final String tanggalSelesaiFormatted;
  final int totalHari;
  final String durasiText;
  final String alasan;
  final String status;
  final String statusText;
  final String? lampiranUrl;
  final String tanggalPengajuan;
  final String tanggalPengajuanFormatted;
  final String? disetujuiOleh;
  final String? tanggalPersetujuan;
  final String? tanggalPersetujuanFormatted;
  final String? catatanAdmin;
  final bool bisaDiedit;
  final bool bisaDibatalkan;

  const LeaveRequest({
    this.id,
    required this.jenisIzin,
    required this.jenisIzinText,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.tanggalMulaiFormatted,
    required this.tanggalSelesaiFormatted,
    required this.totalHari,
    required this.durasiText,
    required this.alasan,
    required this.status,
    required this.statusText,
    this.lampiranUrl,
    required this.tanggalPengajuan,
    required this.tanggalPengajuanFormatted,
    this.disetujuiOleh,
    this.tanggalPersetujuan,
    this.tanggalPersetujuanFormatted,
    this.catatanAdmin,
    required this.bisaDiedit,
    required this.bisaDibatalkan,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      jenisIzin: json['jenis_izin'] ?? '',
      jenisIzinText: json['jenis_izin_text'] ?? '',
      tanggalMulai: json['tanggal_mulai'] ?? '',
      tanggalSelesai: json['tanggal_selesai'] ?? '',
      tanggalMulaiFormatted: json['tanggal_mulai_formatted'] ?? '',
      tanggalSelesaiFormatted: json['tanggal_selesai_formatted'] ?? '',
      totalHari: json['total_hari'] ?? 0,
      durasiText: json['durasi_text'] ?? '',
      alasan: json['alasan'] ?? '',
      status: json['status'] ?? '',
      statusText: json['status_text'] ?? '',
      lampiranUrl: json['lampiran_url'],
      tanggalPengajuan: json['tanggal_pengajuan'] ?? '',
      tanggalPengajuanFormatted: json['tanggal_pengajuan_formatted'] ?? '',
      disetujuiOleh: json['disetujui_oleh'],
      tanggalPersetujuan: json['tanggal_persetujuan'],
      tanggalPersetujuanFormatted: json['tanggal_persetujuan_formatted'],
      catatanAdmin: json['catatan_admin'],
      bisaDiedit: json['bisa_diedit'] ?? false,
      bisaDibatalkan: json['bisa_dibatalkan'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jenis_izin': jenisIzin,
      'jenis_izin_text': jenisIzinText,
      'tanggal_mulai': tanggalMulai,
      'tanggal_selesai': tanggalSelesai,
      'tanggal_mulai_formatted': tanggalMulaiFormatted,
      'tanggal_selesai_formatted': tanggalSelesaiFormatted,
      'total_hari': totalHari,
      'durasi_text': durasiText,
      'alasan': alasan,
      'status': status,
      'status_text': statusText,
      'lampiran_url': lampiranUrl,
      'tanggal_pengajuan': tanggalPengajuan,
      'tanggal_pengajuan_formatted': tanggalPengajuanFormatted,
      'disetujui_oleh': disetujuiOleh,
      'tanggal_persetujuan': tanggalPersetujuan,
      'tanggal_persetujuan_formatted': tanggalPersetujuanFormatted,
      'catatan_admin': catatanAdmin,
      'bisa_diedit': bisaDiedit,
      'bisa_dibatalkan': bisaDibatalkan,
    };
  }

  LeaveRequest copyWith({
    int? id,
    String? jenisIzin,
    String? jenisIzinText,
    String? tanggalMulai,
    String? tanggalSelesai,
    String? tanggalMulaiFormatted,
    String? tanggalSelesaiFormatted,
    int? totalHari,
    String? durasiText,
    String? alasan,
    String? status,
    String? statusText,
    String? lampiranUrl,
    String? tanggalPengajuan,
    String? tanggalPengajuanFormatted,
    String? disetujuiOleh,
    String? tanggalPersetujuan,
    String? tanggalPersetujuanFormatted,
    String? catatanAdmin,
    bool? bisaDiedit,
    bool? bisaDibatalkan,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      jenisIzin: jenisIzin ?? this.jenisIzin,
      jenisIzinText: jenisIzinText ?? this.jenisIzinText,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalSelesai: tanggalSelesai ?? this.tanggalSelesai,
      tanggalMulaiFormatted:
          tanggalMulaiFormatted ?? this.tanggalMulaiFormatted,
      tanggalSelesaiFormatted:
          tanggalSelesaiFormatted ?? this.tanggalSelesaiFormatted,
      totalHari: totalHari ?? this.totalHari,
      durasiText: durasiText ?? this.durasiText,
      alasan: alasan ?? this.alasan,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      lampiranUrl: lampiranUrl ?? this.lampiranUrl,
      tanggalPengajuan: tanggalPengajuan ?? this.tanggalPengajuan,
      tanggalPengajuanFormatted:
          tanggalPengajuanFormatted ?? this.tanggalPengajuanFormatted,
      disetujuiOleh: disetujuiOleh ?? this.disetujuiOleh,
      tanggalPersetujuan: tanggalPersetujuan ?? this.tanggalPersetujuan,
      tanggalPersetujuanFormatted:
          tanggalPersetujuanFormatted ?? this.tanggalPersetujuanFormatted,
      catatanAdmin: catatanAdmin ?? this.catatanAdmin,
      bisaDiedit: bisaDiedit ?? this.bisaDiedit,
      bisaDibatalkan: bisaDibatalkan ?? this.bisaDibatalkan,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaveRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'LeaveRequest(id: $id, jenisIzin: $jenisIzin, status: $status, tanggalMulai: $tanggalMulai, tanggalSelesai: $tanggalSelesai)';
  }

  Color getStatusColor() {
    switch (status) {
      case 'menunggu':
        return const Color(0xFFEAB308);
      case 'disetujui':
        return const Color(0xFF22C55E);
      case 'ditolak':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  IconData getStatusIcon() {
    switch (status) {
      case 'menunggu':
        return Icons.access_time;
      case 'disetujui':
        return Icons.check_circle;
      case 'ditolak':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  JenisIzin? get jenisIzinEnum {
    try {
      return JenisIzin.values.firstWhere((e) => e.value == jenisIzin);
    } catch (e) {
      return null;
    }
  }

  bool get hasAttachment => lampiranUrl != null && lampiranUrl!.isNotEmpty;

  bool get isPending => status == 'menunggu';

  bool get isApproved => status == 'disetujui';

  bool get isRejected => status == 'ditolak';
}

class LeaveRequestStats {
  final int totalPengajuan;
  final int menunggu;
  final int disetujui;
  final int ditolak;
  final int totalHariIzin;
  final int kuotaCuti;
  final int sisaKuota;

  const LeaveRequestStats({
    required this.totalPengajuan,
    required this.menunggu,
    required this.disetujui,
    required this.ditolak,
    required this.totalHariIzin,
    required this.kuotaCuti,
    required this.sisaKuota,
  });

  static int _parseIntSafely(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return defaultValue;
      }
    }
    if (value is double) return value.toInt();
    return defaultValue;
  }

  factory LeaveRequestStats.fromJson(Map<String, dynamic> json) {
    return LeaveRequestStats(
      totalPengajuan: _parseIntSafely(json['total_pengajuan'], 0),
      menunggu: _parseIntSafely(json['menunggu'], 0),
      disetujui: _parseIntSafely(json['disetujui'], 0),
      ditolak: _parseIntSafely(json['ditolak'], 0),
      totalHariIzin: _parseIntSafely(json['total_hari_izin'], 0),
      kuotaCuti: _parseIntSafely(json['kuota_cuti'], 0),
      sisaKuota: _parseIntSafely(json['sisa_kuota'], 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_pengajuan': totalPengajuan,
      'menunggu': menunggu,
      'disetujui': disetujui,
      'ditolak': ditolak,
      'total_hari_izin': totalHariIzin,
      'kuota_cuti': kuotaCuti,
      'sisa_kuota': sisaKuota,
    };
  }

  double get approvalRate {
    if (totalPengajuan == 0) return 0.0;
    return (disetujui / totalPengajuan) * 100;
  }

  double get quotaUsagePercentage {
    if (kuotaCuti == 0) return 0.0;
    return (totalHariIzin / kuotaCuti) * 100;
  }

  @override
  String toString() {
    return 'LeaveRequestStats(total: $totalPengajuan, disetujui: $disetujui, sisaKuota: $sisaKuota)';
  }
}

enum JenisIzin {
  sakit('sakit', 'Sakit'),
  cutiTahunan('cuti_tahunan', 'Cuti Tahunan'),
  keperluanPribadi('keperluan_pribadi', 'Keperluan Pribadi'),
  darurat('darurat', 'Darurat'),
  lainnya('lainnya', 'Lainnya');

  const JenisIzin(this.value, this.text);
  final String value;
  final String text;

  static JenisIzin? fromValue(String value) {
    try {
      return JenisIzin.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }

  static List<DropdownMenuItem<String>> get dropdownItems {
    return JenisIzin.values.map((jenisIzin) {
      return DropdownMenuItem<String>(
        value: jenisIzin.value,
        child: Text(jenisIzin.text),
      );
    }).toList();
  }
}
