// lib/models/ruangan.dart
class Ruangan {
  final int? id_ruangan;
  final String nama;
  final String status;
  final String harga;

  Ruangan({
    this.id_ruangan,
    required this.nama,
    required this.status,
    required this.harga,
  });

  factory Ruangan.fromJson(Map<String, dynamic> json) {
    try {
      return Ruangan(
        id_ruangan: json['id_ruangan'] != null
            ? int.tryParse(json['id_ruangan'].toString())
            : null,
        nama: json['nama']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        harga: json['harga']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing Ruangan from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id_ruangan != null) 'id_ruangan': id_ruangan,
      'nama': nama,
      'status': status,
      'harga': harga,
    };
  }

  @override
  String toString() {
    return 'Ruangan{id_ruangan: $id_ruangan, nama: $nama, status: $status, harga: $harga}';
  }
}
