// lib/views/pesanan/tambah_pesanan_view.dart - VERSI FIX (HANYA UPLOAD DARI GALLERY)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../controllers/pesanan_controller.dart';
import '../../models/pesanan.dart';

class TambahPesananView extends StatefulWidget {
  const TambahPesananView({super.key});

  @override
  State<TambahPesananView> createState() => _TambahPesananViewState();
}

class _TambahPesananViewState extends State<TambahPesananView> {
  final PesananController controller = Get.find();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController idPenggunaController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  int? selectedRuanganId;

  // Untuk file bukti
  File? _buktiFile;
  String? _buktiFileName;

  @override
  void initState() {
    super.initState();
    tanggalController.text = DateTime.now().toLocal().toString().split(' ')[0];
  }

  Future<void> _pickFile() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery, // HANYA DARI GALLERY
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (file != null) {
        _processFile(file);
      }
    } catch (e) {
      print('Error pick from gallery: $e');
      Get.snackbar(
        'Error',
        'Gagal mengambil file dari gallery',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _processFile(XFile file) {
    try {
      setState(() {
        _buktiFile = File(file.path);
        _buktiFileName = file.name;
      });

      // Cek ukuran file
      int fileSize = _buktiFile!.lengthSync();
      double fileSizeKB = fileSize / 1024;

      Get.snackbar(
        '✅ Berhasil',
        'File dipilih: ${file.name} (${fileSizeKB.toStringAsFixed(2)} KB)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Warning jika file terlalu besar
      if (fileSize > 5 * 1024 * 1024) {
        Get.snackbar(
          '⚠️ Peringatan',
          'File mungkin terlalu besar (>5MB). Upload bisa gagal.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error process file: $e');
      Get.snackbar(
        'Error',
        'Gagal memproses file: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Pesanan"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Dropdown Pilih Ruangan
            Obx(() {
              if (controller.ruanganList.isEmpty) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      "Memuat data ruangan...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return DropdownButtonFormField<int>(
                value: selectedRuanganId,
                decoration: InputDecoration(
                  labelText: "Pilih Ruangan",
                  prefixIcon: Icon(Icons.meeting_room),
                  border: OutlineInputBorder(),
                ),
                items: controller.ruanganList.map((ruangan) {
                  return DropdownMenuItem<int>(
                    value: ruangan.id_ruangan,
                    child: Text(
                      "${ruangan.nama} - Rp ${ruangan.harga} (${ruangan.status})",
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRuanganId = value;
                  });
                },
              );
            }),
            SizedBox(height: 20),

            // Input ID Pengguna
            TextFormField(
              controller: idPenggunaController,
              decoration: InputDecoration(
                labelText: "ID Pengguna",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Input Tanggal
            TextFormField(
              controller: tanggalController,
              decoration: InputDecoration(
                labelText: "Tanggal (YYYY-MM-DD)",
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    tanggalController.text =
                        "${picked.toLocal()}".split(' ')[0];
                  });
                }
              },
            ),
            SizedBox(height: 20),

            // Input Total
            TextFormField(
              controller: totalController,
              decoration: InputDecoration(
                labelText: "Total",
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),

            // Upload Bukti File - HANYA UPLOAD DARI GALLERY
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.upload_file, color: Colors.blue),
                      SizedBox(width: 10),
                      Text(
                        "Bukti Pembayaran",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  if (_buktiFile != null) ...[
                    // File sudah dipilih
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _buktiFileName!,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (_buktiFile != null)
                                  Text(
                                    "${(_buktiFile!.lengthSync() / 1024).toStringAsFixed(2)} KB",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _buktiFile = null;
                                _buktiFileName = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                  ],

                  // Tombol Upload File
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: Icon(Icons.upload_file),
                    label: Text(
                      _buktiFile == null ? "Upload File" : "Ganti File",
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 45),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),

                  SizedBox(height: 5),
                  Text(
                    "💡 Pilih file bukti pembayaran dari gallery",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    "📱 Format: JPG/PNG, Maksimal: 5MB",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Tombol Simpan
            Obx(
              () => controller.isUploading.value
                  ? Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text("Mengupload file dan menyimpan..."),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        // Validasi input
                        if (selectedRuanganId == null ||
                            idPenggunaController.text.isEmpty ||
                            tanggalController.text.isEmpty ||
                            totalController.text.isEmpty ||
                            _buktiFile == null) {
                          Get.snackbar(
                            'Error',
                            'Semua field harus diisi termasuk file bukti',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        // Buat objek pesanan
                        final pesanan = Pesanan(
                          id_sewa: selectedRuanganId!,
                          id_pengguna: idPenggunaController.text,
                          tanggal: tanggalController.text,
                          total: totalController.text,
                          bukti: _buktiFileName ?? '',
                          buktiFile: _buktiFile,
                          buktiPath: _buktiFile?.path,
                        );

                        await controller.addPesanan(pesanan);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text("Simpan Pesanan",
                          style: TextStyle(fontSize: 16)),
                    ),
            ),

            SizedBox(height: 10),

            // Tombol Batal
            OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Batal"),
            ),
          ],
        ),
      ),
    );
  }
}
