// lib/controllers/pesanan_controller.dart - VERSI SIMPLE
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'dart:convert';
import '../models/pesanan.dart';
import '../models/ruangan.dart';

class PesananController extends GetxController {
  var pesananList = <Pesanan>[].obs;
  var ruanganList = <Ruangan>[].obs;
  var isUploading = false.obs;

  final String baseUrl = 'http://127.0.0.1:8000';
  final String apiUrl = 'http://127.0.0.1:8000/api/pesanan';
  final String ruanganApiUrl = 'http://127.0.0.1:8000/api/ruangan';
  final String uploadApiUrl = 'http://127.0.0.1:8000/api/upload-bukti';

  @override
  void onInit() {
    super.onInit();
    fetchPesanan();
    fetchRuangan();
  }

  Future<void> fetchPesanan() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        pesananList.value = data.map((item) => Pesanan.fromJson(item)).toList();
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetchPesanan: $e');
      Get.snackbar('Error', 'Gagal mengambil data pesanan');
    }
  }

  Future<void> fetchRuangan() async {
    try {
      final response = await http.get(Uri.parse(ruanganApiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        ruanganList.value = data.map((item) => Ruangan.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error fetchRuangan: $e');
    }
  }

  Future<String?> uploadFile(File file) async {
    try {
      print('Mulai upload file: ${file.path}');

      // Buat request multipart
      var request = http.MultipartRequest('POST', Uri.parse(uploadApiUrl));

      // Tambahkan file
      request.files.add(
        await http.MultipartFile.fromPath(
          'bukti',
          file.path,
          filename: file.path.split('/').last,
        ),
      );

      print('Mengirim request ke: $uploadApiUrl');

      // Kirim request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      print('Response status: ${response.statusCode}');
      print('Response body: $responseData');

      var jsonResponse = json.decode(responseData);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return jsonResponse['filename'];
      } else {
        throw Exception(jsonResponse['message'] ?? 'Gagal upload file');
      }
    } catch (e) {
      print('Error uploadFile: $e');
      rethrow;
    }
  }

  Future<void> addPesanan(Pesanan pesanan) async {
    try {
      isUploading.value = true;

      String? fileName;

      // Upload file jika ada
      if (pesanan.buktiFile != null) {
        print('Ada file yang akan diupload: ${pesanan.buktiFile!.path}');
        fileName = await uploadFile(pesanan.buktiFile!);
        print('File berhasil diupload dengan nama: $fileName');
      } else {
        print('Tidak ada file yang akan diupload');
      }

      // Buat data untuk dikirim
      Map<String, dynamic> data = {
        'id_sewa': pesanan.id_sewa,
        'id_pengguna': pesanan.id_pengguna,
        'tanggal': pesanan.tanggal,
        'total': pesanan.total,
        'bukti': fileName ?? pesanan.bukti,
      };

      print('Data yang akan dikirim: $data');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchPesanan();
        Get.back();
        Get.snackbar('Sukses', 'Pesanan berhasil ditambahkan');
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error addPesanan: $e');
      Get.snackbar('Error', 'Gagal menambahkan pesanan: ${e.toString()}');
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> updatePesanan(int id, Pesanan pesanan) async {
    try {
      isUploading.value = true;

      String? fileName;

      // Upload file baru jika ada
      if (pesanan.buktiFile != null) {
        fileName = await uploadFile(pesanan.buktiFile!);
      }

      Map<String, dynamic> data = {
        'id_sewa': pesanan.id_sewa,
        'id_pengguna': pesanan.id_pengguna,
        'tanggal': pesanan.tanggal,
        'total': pesanan.total,
        'bukti': fileName ?? pesanan.bukti,
      };

      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        fetchPesanan();
        Get.back();
        Get.snackbar('Sukses', 'Pesanan berhasil diperbarui');
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updatePesanan: $e');
      Get.snackbar('Error', 'Gagal memperbarui pesanan');
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> deletePesanan(int id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        pesananList.removeWhere((p) => p.id_pesanan == id);
        Get.snackbar('Sukses', 'Pesanan berhasil dihapus');
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deletePesanan: $e');
      Get.snackbar('Error', 'Gagal menghapus pesanan');
    }
  }

  // Fungsi untuk mendapatkan URL file bukti
  String getBuktiUrl(String filename) {
    return '$baseUrl/storage/bukti_pembayaran/$filename';
  }
}
