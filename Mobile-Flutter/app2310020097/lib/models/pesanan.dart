// lib/models/pesanan.dart - VERSI DIPERBAIKI
import 'dart:io'; // Tambahkan ini di bagian atas
import 'package:app2310020097/models/ruangan.dart';

class Pesanan {
  final int? id_pesanan;
  final int id_sewa;
  final String id_pengguna;
  final String tanggal;
  final String total;
  final String bukti; // Tetap String (non-nullable)
  final Ruangan? ruangan;
  final File? buktiFile; // Untuk file yang akan diupload
  final String? buktiPath; // Untuk path file lokal

  Pesanan({
    this.id_pesanan,
    required this.id_sewa,
    required this.id_pengguna,
    required this.tanggal,
    required this.total,
    required this.bukti, // Required, tidak nullable
    this.ruangan,
    this.buktiFile,
    this.buktiPath,
  });

  factory Pesanan.fromJson(Map<String, dynamic> json) {
    try {
      return Pesanan(
        id_pesanan: json['id_pesanan'] != null
            ? int.tryParse(json['id_pesanan'].toString())
            : null,
        id_sewa: int.tryParse(json['id_sewa'].toString()) ?? 0,
        id_pengguna: json['id_pengguna']?.toString() ?? '',
        tanggal: json['tanggal']?.toString() ?? '',
        total: json['total']?.toString() ?? '',
        bukti: json['bukti']?.toString() ?? '', // Default empty string
        ruangan: json['ruangan'] != null
            ? Ruangan.fromJson(json['ruangan'])
            : null,
      );
    } catch (e) {
      print('Error parsing Pesanan from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id_pesanan != null) 'id_pesanan': id_pesanan,
      'id_sewa': id_sewa,
      'id_pengguna': id_pengguna,
      'tanggal': tanggal,
      'total': total,
      'bukti': bukti,
    };
  }

  @override
  String toString() {
    return 'Pesanan{id_pesanan: $id_pesanan, id_sewa: $id_sewa, pengguna: $id_pengguna, total: $total, bukti: $bukti}';
  }
}
