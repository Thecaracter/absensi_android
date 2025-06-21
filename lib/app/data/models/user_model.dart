import 'package:sistem_presensi/app/data/models/shift_model.dart';

class UserProfile {
  final int id;
  final String idKaryawan;
  final String name;
  final String email;
  final String? noHp;
  final String? alamat;
  final String? tanggalMasuk;
  final String? fotoUrl;
  final Shift? shift;

  UserProfile({
    required this.id,
    required this.idKaryawan,
    required this.name,
    required this.email,
    this.noHp,
    this.alamat,
    this.tanggalMasuk,
    this.fotoUrl,
    this.shift,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      idKaryawan: json['id_karyawan'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      noHp: json['no_hp'],
      alamat: json['alamat'],
      tanggalMasuk: json['tanggal_masuk'],
      fotoUrl: json['foto_url'],
      shift: json['shift'] != null ? Shift.fromJson(json['shift']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_karyawan': idKaryawan,
      'name': name,
      'email': email,
      'no_hp': noHp,
      'alamat': alamat,
      'tanggal_masuk': tanggalMasuk,
      'foto_url': fotoUrl,
      'shift': shift?.toJson(),
    };
  }

  UserProfile copyWith({
    int? id,
    String? idKaryawan,
    String? name,
    String? email,
    String? noHp,
    String? alamat,
    String? tanggalMasuk,
    String? fotoUrl,
    Shift? shift,
  }) {
    return UserProfile(
      id: id ?? this.id,
      idKaryawan: idKaryawan ?? this.idKaryawan,
      name: name ?? this.name,
      email: email ?? this.email,
      noHp: noHp ?? this.noHp,
      alamat: alamat ?? this.alamat,
      tanggalMasuk: tanggalMasuk ?? this.tanggalMasuk,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      shift: shift ?? this.shift,
    );
  }

  @override
  String toString() {
    return 'UserProfile{id: $id, idKaryawan: $idKaryawan, name: $name, email: $email, noHp: $noHp, alamat: $alamat, tanggalMasuk: $tanggalMasuk, fotoUrl: $fotoUrl, shift: $shift}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          idKaryawan == other.idKaryawan &&
          name == other.name &&
          email == other.email;

  @override
  int get hashCode =>
      id.hashCode ^ idKaryawan.hashCode ^ name.hashCode ^ email.hashCode;
}
