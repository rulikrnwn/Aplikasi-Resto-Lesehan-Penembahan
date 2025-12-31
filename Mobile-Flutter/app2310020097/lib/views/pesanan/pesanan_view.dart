// lib/views/pesanan/pesanan_view.dart - VERSI SAVE DIALOG UNTUK SEMUA PLATFORM
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../controllers/pesanan_controller.dart';
import '../../models/pesanan.dart';
import 'tambah_pesanan_view.dart';
import 'edit_pesanan_view.dart';
import 'file_viewer_screen.dart';

class PesananView extends StatelessWidget {
  final PesananController controller = Get.put(PesananController());

  PesananView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data Pesanan"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => controller.fetchPesanan(),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header dengan Total Data dan Tombol Cetak
          _buildSimpleHeader(),
          
          Expanded(
            child: Obx(() {
              if (controller.pesananList.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                itemCount: controller.pesananList.length,
                itemBuilder: (context, index) {
                  final pesanan = controller.pesananList[index];
                  return _buildPesananCard(pesanan);
                },
              );
            }),
          ),

          // Tombol Tambah Pesanan
          Container(
            padding: EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => Get.to(() => TambahPesananView()),
              icon: Icon(Icons.add),
              label: Text("Tambah Pesanan"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Total Data
          Obx(() {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.list_alt, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Total: ${controller.pesananList.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }),
          
          // Tombol Download
          Obx(() {
            if (controller.pesananList.isEmpty) return SizedBox();
            return ElevatedButton.icon(
              onPressed: () => _showSaveDialog(),
              icon: Icon(Icons.download, size: 20),
              label: Text("Cetak"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 3,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text("Tidak ada data pesanan"),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => controller.fetchPesanan(),
            icon: Icon(Icons.refresh),
            label: Text("Refresh Data"),
          ),
        ],
      ),
    );
  }

  Widget _buildPesananCard(Pesanan pesanan) {
    final hasBukti = pesanan.bukti.isNotEmpty;
    
    return Card(
      margin: EdgeInsets.all(8),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.receipt, color: Colors.blue),
        ),
        title: Text(
          pesanan.ruangan?.nama ?? "Ruangan ${pesanan.id_sewa}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text("Pengguna: ${pesanan.id_pengguna}"),
            Text("Tanggal: ${pesanan.tanggal}"),
            Text("Total: Rp ${pesanan.total}"),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  hasBukti ? Icons.check_circle : Icons.warning,
                  size: 12,
                  color: hasBukti ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 4),
                Text(
                  hasBukti ? "Ada bukti" : "Tidak ada bukti",
                  style: TextStyle(
                    fontSize: 12,
                    color: hasBukti ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasBukti)
              IconButton(
                icon: Icon(Icons.remove_red_eye, color: Colors.green, size: 20),
                onPressed: () {
                  String fileUrl = controller.getBuktiUrl(pesanan.bukti);
                  Get.to(() => FileViewerScreen(fileUrl: fileUrl, fileName: pesanan.bukti));
                },
                tooltip: 'Lihat File Bukti',
              ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue, size: 20),
              onPressed: () => Get.to(() => EditPesananView(pesanan: pesanan)),
              tooltip: 'Edit Pesanan',
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _showDeleteDialog(pesanan.id_pesanan!),
              tooltip: 'Hapus Pesanan',
            ),
          ],
        ),
        onTap: () => _showDetailDialog(pesanan),
      ),
    );
  }

  // ========== SAVE DIALOG UNTUK SEMUA PLATFORM ==========
  
  void _showSaveDialog() {
    Get.defaultDialog(
      title: "Simpan Laporan",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.save_alt, size: 50, color: Colors.blue),
          SizedBox(height: 10),
          Text(
            "Pilih format file:",
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        // Simpan sebagai PDF
        ElevatedButton.icon(
          onPressed: () {
            Get.back();
            _saveAsPdf();
          },
          icon: Icon(Icons.picture_as_pdf, color: Colors.red),
          label: Text("Simpan sebagai PDF"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red,
            minimumSize: Size(double.infinity, 50),
          ),
        ),
        
        // Simpan dan Print
        ElevatedButton.icon(
          onPressed: () {
            Get.back();
            _saveAndPrint();
          },
          icon: Icon(Icons.print, color: Colors.blue),
          label: Text("Simpan & Print"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            minimumSize: Size(double.infinity, 50),
          ),
        ),
        
        // Batal
        OutlinedButton(
          onPressed: () => Get.back(),
          child: Text("Batal"),
        ),
      ],
    );
  }

  // Simpan sebagai PDF (akan muncul Save Dialog di semua platform)
  Future<void> _saveAsPdf() async {
    try {
      // Tampilkan loading
      Get.dialog(
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Menyiapkan file..."),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Generate PDF
      final pdf = await _generatePdfDocument();
      final pdfBytes = await pdf.save();
      
      // Format nama file
      final now = DateTime.now();
      final fileName = 'Laporan_Pesanan_${DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf';

      // Tutup loading
      Get.back();

      // Gunakan sharePdf untuk membuka Save Dialog
      // Ini akan muncul Save Dialog di Chrome dan Windows
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: fileName,
        subject: 'Laporan Data Pesanan Ruangan',
      );

      // Informasi ke user
      Get.snackbar(
        '💾 File Siap',
        'Pilih lokasi penyimpanan file',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

    } catch (e) {
      Get.back();
      Get.snackbar(
        '❌ Gagal',
        'Tidak bisa membuat file: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Simpan dan Print
  Future<void> _saveAndPrint() async {
    try {
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final pdf = await _generatePdfDocument();
      final pdfBytes = await pdf.save();
      final fileName = 'Laporan_Pesanan_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';

      Get.back();

      // Tampilkan dialog pilihan
      final result = await Get.defaultDialog<bool>(
        title: "Simpan atau Print",
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.print, size: 40, color: Colors.orange),
            SizedBox(height: 10),
            Text(
              "Pilih aksi yang diinginkan:",
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back(result: true); // Print
            },
            child: Text("Print Sekarang"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(result: false); // Save dulu
            },
            child: Text("Simpan dulu"),
          ),
          OutlinedButton(
            onPressed: () => Get.back(),
            child: Text("Batal"),
          ),
        ],
      );

      if (result == null) return;

      if (result == true) {
        // Print langsung
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfBytes,
          name: fileName,
        );
      } else {
        // Simpan dulu (Save Dialog)
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: fileName,
        );
      }

    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Gagal memproses: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ========== PDF GENERATION ==========
  Future<pw.Document> _generatePdfDocument() async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);
    final totalData = controller.pesananList.length;
    
    // Siapkan data untuk tabel DENGAN KOLOM BUKTI
    final tableData = controller.pesananList.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final pesanan = entry.value;
      final hasBukti = pesanan.bukti.isNotEmpty;
      
      return [
        index.toString(),
        pesanan.ruangan?.nama ?? 'Ruangan ${pesanan.id_sewa}',
        pesanan.id_pengguna,
        pesanan.tanggal,
        'Rp ${pesanan.total}',
        hasBukti ? ' ADA' : ' TIDAK ADA',
      ];
    }).toList();

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(25),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // JUDUL BESAR
              pw.Center(
                child: pw.Text(
                  'LAPORAN DATA PESANAN RUANGAN',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue,
                  ),
                ),
              ),
              
              pw.SizedBox(height: 8),
              
              // INFORMASI TANGGAL DAN TOTAL DATA
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Tanggal Cetak: $formattedDate',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey,
                    ),
                  ),
                  pw.SizedBox(width: 30),
                  pw.Text(
                    'Total Data: $totalData',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey,
                    ),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 25),
              
              // GARIS PEMISAH
              pw.Divider(thickness: 1, color: PdfColors.grey),
              
              pw.SizedBox(height: 20),
              
              // TABEL DATA DENGAN KOLOM BUKTI
              if (tableData.isNotEmpty)
                pw.Table.fromTextArray(
                  border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
                  headerDecoration: pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                    color: PdfColors.black,
                  ),
                  cellStyle: pw.TextStyle(
                    fontSize: 10,
                  ),
                  cellAlignments: {
                    0: pw.Alignment.center,     // NO
                    1: pw.Alignment.centerLeft, // NAMA RUANGAN
                    2: pw.Alignment.centerLeft, // PENGGUNA
                    3: pw.Alignment.center,     // TANGGAL
                    4: pw.Alignment.centerRight,// TOTAL
                    5: pw.Alignment.center,     // BUKTI
                  },
                  headers: ['NO', 'NAMA RUANGAN', 'PENGGUNA', 'TANGGAL', 'TOTAL (Rp)', 'BUKTI'],
                  data: tableData,
                  columnWidths: {
                    0: pw.FlexColumnWidth(0.5),  // NO
                    1: pw.FlexColumnWidth(2.0),  // NAMA RUANGAN
                    2: pw.FlexColumnWidth(1.5),  // PENGGUNA
                    3: pw.FlexColumnWidth(1.2),  // TANGGAL
                    4: pw.FlexColumnWidth(1.5),  // TOTAL
                    5: pw.FlexColumnWidth(1.2),  // BUKTI
                  },
                  headerPadding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  cellPadding: pw.EdgeInsets.symmetric(vertical: 6, horizontal: 5),
                )
              else
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Icon(
                        pw.IconData(0xf1c1), // Icon PDF
                        size: 50,
                        color: PdfColors.grey,
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'TIDAK ADA DATA PESANAN',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.grey,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              
              pw.SizedBox(height: 40),
              
              // FOOTER
              pw.Divider(thickness: 0.5, color: PdfColors.grey300),
              
              pw.SizedBox(height: 15),
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Halaman: 1/1',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey,
                    ),
                  ),
                  pw.Text(
                    'Dicetak: ${DateFormat('dd/MM/yyyy HH:mm').format(now)}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  // ========== DIALOGS ==========
  void _showDeleteDialog(int id) {
    Get.defaultDialog(
      title: "Konfirmasi Hapus",
      middleText: "Apakah Anda yakin ingin menghapus pesanan ini?",
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        controller.deletePesanan(id);
        Get.back();
      },
      onCancel: () => Get.back(),
    );
  }

  void _showDetailDialog(Pesanan pesanan) {
    Get.defaultDialog(
      title: "Detail Pesanan",
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("ID Pesanan", "${pesanan.id_pesanan}"),
            _buildInfoRow("Ruangan", pesanan.ruangan?.nama ?? "Tidak diketahui"),
            _buildInfoRow("Pengguna", pesanan.id_pengguna),
            _buildInfoRow("Tanggal", pesanan.tanggal),
            _buildInfoRow("Total", "Rp ${pesanan.total}"),
            _buildInfoRow("Status Bukti", pesanan.bukti.isNotEmpty ? "Ada" : "Tidak Ada"),
          ],
        ),
      ),
      contentPadding: EdgeInsets.all(20),
      confirm: Container(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Get.back(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: Text("Tutup"),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[800])),
          ),
        ],
      ),
    );
  }
}