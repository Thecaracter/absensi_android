class Shift {
  final int id;
  final String nama;
  final String jamMasuk;
  final String jamKeluar;
  final int toleransiMenit;

  Shift({
    required this.id,
    required this.nama,
    required this.jamMasuk,
    required this.jamKeluar,
    required this.toleransiMenit,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      jamMasuk: json['jam_masuk'] ?? '',
      jamKeluar: json['jam_keluar'] ?? '',
      toleransiMenit: json['toleransi_menit'] ?? 0,
    );
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

  Shift copyWith({
    int? id,
    String? nama,
    String? jamMasuk,
    String? jamKeluar,
    int? toleransiMenit,
  }) {
    return Shift(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      jamMasuk: jamMasuk ?? this.jamMasuk,
      jamKeluar: jamKeluar ?? this.jamKeluar,
      toleransiMenit: toleransiMenit ?? this.toleransiMenit,
    );
  }

  String get durasiShift {
    try {
      final masuk = _parseTime(jamMasuk);
      final keluar = _parseTime(jamKeluar);

      int durasiMenit;
      if (keluar.isBefore(masuk)) {
        // Shift malam (melewati tengah malam)
        final endOfDay =
            DateTime(masuk.year, masuk.month, masuk.day, 23, 59, 59);
        final startOfNextDay =
            DateTime(masuk.year, masuk.month, masuk.day + 1, 0, 0, 0);
        final keluarNextDay = DateTime(
            masuk.year, masuk.month, masuk.day + 1, keluar.hour, keluar.minute);

        durasiMenit = endOfDay.difference(masuk).inMinutes +
            keluarNextDay.difference(startOfNextDay).inMinutes +
            1;
      } else {
        durasiMenit = keluar.difference(masuk).inMinutes;
      }

      final jam = durasiMenit ~/ 60;
      final menit = durasiMenit % 60;

      return '${jam}j ${menit}m';
    } catch (e) {
      return '-';
    }
  }

  bool get isShiftMalam {
    try {
      final masuk = _parseTime(jamMasuk);
      final keluar = _parseTime(jamKeluar);
      return keluar.isBefore(masuk);
    } catch (e) {
      return false;
    }
  }

  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  @override
  String toString() {
    return 'Shift{id: $id, nama: $nama, jamMasuk: $jamMasuk, jamKeluar: $jamKeluar, toleransiMenit: $toleransiMenit}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Shift &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nama == other.nama;

  @override
  int get hashCode => id.hashCode ^ nama.hashCode;
}
