// lib/views/ruangan_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ruangan_controller.dart';
import 'tambah_ruangan_view.dart';
import 'edit_ruangan_view.dart';

class RuanganView extends StatelessWidget {
  final RuanganController controller = Get.put(RuanganController());

  RuanganView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data Ruangan"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => controller.fetchRuangan(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.ruanganList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.meeting_room, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text("Tidak ada data ruangan"),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => controller.fetchRuangan(),
                        child: Text("Refresh"),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.ruanganList.length,
                itemBuilder: (context, index) {
                  final ruangan = controller.ruanganList[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        children: [
                          // Icon ruangan
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _getStatusColor(ruangan.status),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getStatusIcon(ruangan.status),
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ruangan.nama,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(Icons.attach_money, size: 16),
                                    SizedBox(width: 5),
                                    Text("Harga: ${ruangan.harga}"),
                                  ],
                                ),
                                SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(Icons.circle, size: 10, color: _getStatusColor(ruangan.status)),
                                    SizedBox(width: 5),
                                    Text(
                                      "Status: ${ruangan.status}",
                                      style: TextStyle(
                                        color: _getStatusColor(ruangan.status),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Tombol edit dan delete
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Get.to(() => EditRuanganView(ruangan: ruangan));
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _showDeleteDialog(ruangan.id_ruangan!);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
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
                Get.to(() => TambahRuanganView());
              },
              icon: Icon(Icons.add),
              label: Text("Tambah Ruangan"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper functions
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'tersedia':
        return Icons.check_circle;
      case 'dipakai':
        return Icons.people;
      case 'maintenance':
        return Icons.build;
      default:
        return Icons.meeting_room;
    }
  }

  void _showDeleteDialog(int id) {
    Get.defaultDialog(
      title: "Konfirmasi Hapus",
      middleText: "Apakah Anda yakin ingin menghapus ruangan ini?",
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deleteRuangan(id);
        Get.back();
      },
      onCancel: () => Get.back(),
    );
  }
}