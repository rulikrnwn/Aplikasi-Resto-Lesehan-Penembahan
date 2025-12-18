// lib/views/pesanan/edit_pesanan_view.dart - VERSI FIX (HANYA UPLOAD DARI GALLERY)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../controllers/pesanan_controller.dart';
import '../../models/pesanan.dart';

class EditPesananView extends StatefulWidget {
  final Pesanan pesanan;

  const EditPesananView({required this.pesanan});

  @override
  State<EditPesananView> createState() => _EditPesananViewState();
}

class _EditPesananViewState extends State<EditPesananView> {
  final PesananController controller = Get.find();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController idPenggunaController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  int? selectedRuanganId;

  // Untuk file bukti
  File? _buktiFile;
  String? _buktiFileName;
  String? _currentBukti;

  @override
  void initState() {
    super.initState();
    selectedRuanganId = widget.pesanan.id_sewa;
    idPenggunaController.text = widget.pesanan.id_pengguna;
    tanggalController.text = widget.pesanan.tanggal;
    totalController.text = widget.pesanan.total;
    _currentBukti = widget.pesanan.bukti;
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
      File fileObj = File(file.path);

      // Cek ukuran file
      int fileSize = fileObj.lengthSync();
      double fileSizeKB = fileSize / 1024;

      // Warning jika file terlalu besar (> 5MB)
      if (fileSize > 5 * 1024 * 1024) {
        Get.snackbar(
          '⚠️ File Terlalu Besar',
          'File (${fileSizeKB.toStringAsFixed(2)} KB) melebihi batas 5MB',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }

      setState(() {
        _buktiFile = fileObj;
        _buktiFileName = file.name;
      });

      Get.snackbar(
        '✅ Berhasil',
        'File dipilih: ${file.name} (${fileSizeKB.toStringAsFixed(2)} KB)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error process file: $e');
      Get.snackbar(
        'Error',
        'Gagal memproses file',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showFilePreview() {
    if (_currentBukti == null || _currentBukti!.isEmpty) return;

    try {
      String fileUrl = controller.getBuktiUrl(_currentBukti!);

      // Show preview dialog
      Get.defaultDialog(
        title: "Preview File",
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file, size: 50, color: Colors.blue),
            SizedBox(height: 10),
            Text(
              _currentBukti!,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "URL: ${fileUrl.substring(0, 30)}...",
              style: TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Tutup"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Info',
                'Membuka file di browser...',
                snackPosition: SnackPosition.BOTTOM,
              );
              // TODO: Implement url_launcher
            },
            child: Text("Buka File"),
          ),
        ],
      );
    } catch (e) {
      print('Error show file preview: $e');
      Get.snackbar(
        'Error',
        'Tidak dapat menampilkan preview file',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Pesanan"),
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
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: controller.ruanganList.map((ruangan) {
                  return DropdownMenuItem<int>(
                    value: ruangan.id_ruangan,
                    child: Text(
                      "${ruangan.nama} - Rp ${ruangan.harga}",
                      style: TextStyle(fontSize: 14),
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
                prefixIcon: Icon(Icons.person, color: Colors.blue),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            SizedBox(height: 20),

            // Input Tanggal
            TextFormField(
              controller: tanggalController,
              decoration: InputDecoration(
                labelText: "Tanggal Pesanan",
                hintText: "YYYY-MM-DD",
                prefixIcon: Icon(Icons.calendar_today, color: Colors.blue),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              readOnly: true,
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialEntryMode: DatePickerEntryMode.calendar,
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
                labelText: "Total Pembayaran (Rp)",
                prefixIcon: Icon(Icons.attach_money, color: Colors.green),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),

            // Upload Bukti File
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt, color: Colors.blue),
                      SizedBox(width: 10),
                      Text(
                        "Bukti Pembayaran",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),

                  // Tampilkan file yang ada di server
                  if (_currentBukti != null && _currentBukti!.isNotEmpty)
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.attachment, color: Colors.blue),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "File saat ini:",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      _currentBukti!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[800],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Tombol untuk melihat file yang ada
                              if (_currentBukti!.isNotEmpty)
                                IconButton(
                                  icon: Icon(Icons.remove_red_eye, size: 20),
                                  color: Colors.green,
                                  onPressed: _showFilePreview,
                                  tooltip: 'Lihat file',
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Divider(),
                        SizedBox(height: 10),
                        Text(
                          "Pilih file baru untuk mengganti:",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),

                  // File baru yang dipilih
                  if (_buktiFile != null)
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[100]!),
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
                                      "File baru dipilih:",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      _buktiFileName!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[800],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "${(_buktiFile!.lengthSync() / 1024).toStringAsFixed(2)} KB",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, size: 20),
                                color: Colors.red,
                                onPressed: () {
                                  setState(() {
                                    _buktiFile = null;
                                    _buktiFileName = null;
                                  });
                                  Get.snackbar(
                                    'Dihapus',
                                    'File baru dihapus',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
                                tooltip: 'Hapus file baru',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
                      ],
                    ),

                  // Tombol Upload File
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: Icon(Icons.upload_file),
                    label: Text(
                      _buktiFile == null
                          ? (_currentBukti != null && _currentBukti!.isNotEmpty
                              ? "Ganti File"
                              : "Upload File Bukti")
                          : "Ganti File Lain",
                      style: TextStyle(fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                  ),

                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 14, color: Colors.grey),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          "Format: JPG/PNG • Maksimal: 5MB • Upload dari Gallery",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Tombol Simpan dengan Loading State
            Obx(
              () => controller.isUploading.value
                  ? Column(
                      children: [
                        CircularProgressIndicator(
                          color: Colors.blue,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 15),
                        Text(
                          "Mengupload file...",
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Mohon tunggu sebentar",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        // Tombol Simpan Perubahan
                        ElevatedButton(
                          onPressed: () async {
                            // Validasi input
                            if (selectedRuanganId == null ||
                                idPenggunaController.text.isEmpty ||
                                tanggalController.text.isEmpty ||
                                totalController.text.isEmpty) {
                              Get.snackbar(
                                '❌ Data Belum Lengkap',
                                'Harap isi semua field yang wajib',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            // Update pesanan
                            final updatedPesanan = Pesanan(
                              id_pesanan: widget.pesanan.id_pesanan,
                              id_sewa: selectedRuanganId!,
                              id_pengguna: idPenggunaController.text,
                              tanggal: tanggalController.text,
                              total: totalController.text,
                              bukti: _buktiFileName ?? _currentBukti ?? '',
                              buktiFile: _buktiFile,
                              buktiPath: _buktiFile?.path,
                            );

                            await controller.updatePesanan(
                              widget.pesanan.id_pesanan!,
                              updatedPesanan,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 55),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 3,
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Text(
                            "💾 SIMPAN PERUBAHAN",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),

                        // Tombol Batal
                        OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            side: BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "BATAL",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),

                        // Informasi
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lightbulb_outline,
                                  color: Colors.amber, size: 18),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Jika tidak memilih file baru, file lama akan tetap digunakan",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
