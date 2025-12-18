// lib/views/edit_ruangan_view.dart - VERSI RADIO BUTTON
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ruangan_controller.dart';
import '../../models/ruangan.dart';

class EditRuanganView extends StatefulWidget {
  final Ruangan ruangan;

  const EditRuanganView({required this.ruangan});

  @override
  State<EditRuanganView> createState() => _EditRuanganViewState();
}

class _EditRuanganViewState extends State<EditRuanganView> {
  final RuanganController controller = Get.find();

  final TextEditingController namaController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    // Inisialisasi dengan data yang ada
    namaController.text = widget.ruangan.nama;
    hargaController.text = widget.ruangan.harga;
    selectedStatus = widget.ruangan.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Ruangan"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Nama
            TextFormField(
              controller: namaController,
              decoration: InputDecoration(
                labelText: "Nama Ruangan",
                prefixIcon: Icon(Icons.meeting_room),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Input Harga
            TextFormField(
              controller: hargaController,
              decoration: InputDecoration(
                labelText: "Harga",
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),

            // Radio Button Status - VERSI BARU
            Text(
              "Status Ruangan",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),

            // Radio Button Group
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Radio Tersedia
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text("Tersedia"),
                      ],
                    ),
                    value: 'tersedia',
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value;
                      });
                    },
                    activeColor: Colors.green,
                  ),

                  Divider(height: 1),

                  // Radio Dipakai
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(Icons.people, color: Colors.orange),
                        SizedBox(width: 8),
                        Text("Dipakai"),
                      ],
                    ),
                    value: 'dipakai',
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value;
                      });
                    },
                    activeColor: Colors.orange,
                  ),

                  Divider(height: 1),

                  // Radio Maintenance
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(Icons.build, color: Colors.red),
                        SizedBox(width: 8),
                        Text("Maintenance"),
                      ],
                    ),
                    value: 'maintenance',
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value;
                      });
                    },
                    activeColor: Colors.red,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Tombol Simpan Perubahan
            ElevatedButton(
              onPressed: () {
                // Validasi input
                if (namaController.text.isEmpty ||
                    hargaController.text.isEmpty ||
                    selectedStatus == null ||
                    selectedStatus!.isEmpty) {
                  Get.snackbar(
                    'Error',
                    'Semua field harus diisi',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                // Update ruangan
                final updatedRuangan = Ruangan(
                  id_ruangan: widget.ruangan.id_ruangan,
                  nama: namaController.text,
                  harga: hargaController.text,
                  status: selectedStatus!,
                );

                controller.updateRuangan(
                  widget.ruangan.id_ruangan!,
                  updatedRuangan,
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Simpan Perubahan", style: TextStyle(fontSize: 16)),
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
