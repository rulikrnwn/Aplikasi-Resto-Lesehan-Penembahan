// lib/views/pesanan/pesanan_view.dart - VERSI DIPERBAIKI (TANPA PENCARIAN)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.pesananList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text("Tidak ada data pesanan"),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => controller.fetchPesanan(),
                        child: Text("Refresh"),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.pesananList.length,
                itemBuilder: (context, index) {
                  final pesanan = controller.pesananList[index];
                  final hasBukti = pesanan
                      .bukti.isNotEmpty; // Check jika string tidak kosong

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
                          // Tampilkan status file bukti
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
                                  color:
                                      hasBukti ? Colors.green : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tombol Lihat File (jika ada file)
                          if (hasBukti)
                            IconButton(
                              icon: Icon(
                                Icons.remove_red_eye,
                                color: Colors.green,
                                size: 20,
                              ),
                              onPressed: () {
                                // Langsung buka file viewer
                                String fileUrl = controller.getBuktiUrl(
                                  pesanan.bukti,
                                );
                                Get.to(
                                  () => FileViewerScreen(
                                    fileUrl: fileUrl,
                                    fileName: pesanan.bukti,
                                  ),
                                );
                              },
                              tooltip: 'Lihat File Bukti',
                            ),
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Colors.blue,
                              size: 20,
                            ),
                            onPressed: () {
                              Get.to(() => EditPesananView(pesanan: pesanan));
                            },
                            tooltip: 'Edit Pesanan',
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () {
                              _showDeleteDialog(pesanan.id_pesanan!);
                            },
                            tooltip: 'Hapus Pesanan',
                          ),
                        ],
                      ),
                      onTap: () {
                        // Show detail dialog
                        _showDetailDialog(pesanan);
                      },
                      onLongPress: () {
                        // Quick view file on long press
                        if (hasBukti) {
                          String fileUrl = controller.getBuktiUrl(
                            pesanan.bukti,
                          );
                          Get.to(
                            () => FileViewerScreen(
                              fileUrl: fileUrl,
                              fileName: pesanan.bukti,
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              );
            }),
          ),

          // Tombol tambah
          Container(
            padding: EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                Get.to(() => TambahPesananView());
              },
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

  void _showDeleteDialog(int id) {
    Get.defaultDialog(
      title: "Konfirmasi Hapus",
      middleText: "Apakah Anda yakin ingin menghapus pesanan ini?",
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deletePesanan(id);
        Get.back();
      },
      onCancel: () => Get.back(),
    );
  }

  void _showDetailDialog(Pesanan pesanan) {
    final hasBukti = pesanan.bukti.isNotEmpty;

    Get.defaultDialog(
      title: "Detail Pesanan",
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informasi Dasar
            _buildInfoRow("ID Pesanan", "${pesanan.id_pesanan}"),
            _buildInfoRow(
              "Ruangan",
              pesanan.ruangan?.nama ?? "Tidak diketahui",
            ),
            _buildInfoRow("Pengguna", pesanan.id_pengguna),
            _buildInfoRow("Tanggal", pesanan.tanggal),
            _buildInfoRow("Total", "Rp ${pesanan.total}"),

            // Section Bukti Pembayaran
            SizedBox(height: 16),
            Text(
              "Bukti Pembayaran:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),

            if (hasBukti)
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.description, color: Colors.blue),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pesanan.bukti,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Klik tombol di bawah untuk melihat file",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.back(); // Tutup dialog dulu
                            String fileUrl = controller.getBuktiUrl(
                              pesanan.bukti,
                            );
                            Get.to(
                              () => FileViewerScreen(
                                fileUrl: fileUrl,
                                fileName: pesanan.bukti,
                              ),
                            );
                          },
                          icon: Icon(Icons.remove_red_eye),
                          label: Text("Lihat File"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 10),
                    Text(
                      "Tidak ada file bukti pembayaran",
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            // Section Info Ruangan (jika ada)
            if (pesanan.ruangan != null) ...[
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 8),
              Text(
                "Info Ruangan:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              _buildInfoRow("Nama", pesanan.ruangan!.nama),
              _buildInfoRow("Status", pesanan.ruangan!.status),
              _buildInfoRow("Harga", "Rp ${pesanan.ruangan!.harga}"),

              // Status badge
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(pesanan.ruangan!.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  pesanan.ruangan!.status.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],

            SizedBox(height: 10),
          ],
        ),
      ),
      contentPadding: EdgeInsets.all(20),
      titlePadding: EdgeInsets.only(top: 20, left: 20, right: 20),
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

  // Helper function untuk membuat row info
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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

  // Helper function untuk warna status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'tersedia':
        return Colors.green;
      case 'dipakai':
        return Colors.orange;
      case 'maintenance':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
