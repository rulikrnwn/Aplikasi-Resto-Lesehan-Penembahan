// lib/controllers/ruangan_controller.dart
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/ruangan.dart';

class RuanganController extends GetxController {
  var ruanganList = <Ruangan>[].obs;

  // SESUAIKAN DENGAN URL API LARAVEL ANDA
  final String apiUrl = 'http://127.0.0.1:8000/api/ruangan';
  // Untuk emulator Android: 'http://10.0.2.2:8000/api/ruangan'

  @override
  void onInit() {
    super.onInit();
    fetchRuangan(); // Ambil data saat controller diinisialisasi
  }

  Future<void> fetchRuangan() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        ruanganList.value = data.map((item) => Ruangan.fromJson(item)).toList();
      } else {
        throw Exception('Gagal mengambil data ruangan');
      }
    } catch (e) {
      print('Error fetchRuangan: $e');
      Get.snackbar('Error', 'Gagal mengambil data ruangan');
    }
  }

  Future<void> addRuangan(Ruangan ruangan) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(ruangan.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh data setelah berhasil tambah
        fetchRuangan();
        Get.back(); // Kembali ke halaman list
        Get.snackbar('Sukses', 'Ruangan berhasil ditambahkan');
      } else {
        throw Exception('Gagal menambahkan ruangan');
      }
    } catch (e) {
      print('Error addRuangan: $e');
      Get.snackbar('Error', 'Gagal menambahkan ruangan');
    }
  }

  Future<void> updateRuangan(int id, Ruangan ruangan) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(ruangan.toJson()),
      );

      if (response.statusCode == 200) {
        // Update data di list
        final index = ruanganList.indexWhere((r) => r.id_ruangan == id);
        if (index != -1) {
          ruanganList[index] = Ruangan.fromJson(json.decode(response.body));
        }
        Get.back(); // Kembali ke halaman list
        Get.snackbar('Sukses', 'Ruangan berhasil diperbarui');
      } else {
        throw Exception('Gagal memperbarui ruangan');
      }
    } catch (e) {
      print('Error updateRuangan: $e');
      Get.snackbar('Error', 'Gagal memperbarui ruangan');
    }
  }

  Future<void> deleteRuangan(int id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Hapus dari list
        ruanganList.removeWhere((r) => r.id_ruangan == id);
        Get.snackbar('Sukses', 'Ruangan berhasil dihapus');
      } else {
        throw Exception('Gagal menghapus ruangan');
      }
    } catch (e) {
      print('Error deleteRuangan: $e');
      Get.snackbar('Error', 'Gagal menghapus ruangan');
    }
  }
}
