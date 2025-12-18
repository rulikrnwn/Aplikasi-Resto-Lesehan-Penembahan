// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/ruangan/ruangan_view.dart';
import 'views/pesanan/pesanan_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Resto Lesehan Penembahan',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resto Lesehan Penembahan'),
        centerTitle: true, // Tambahkan ini untuk membuat judul di tengah
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Get.to(() => RuanganView());
              },
              icon: Icon(Icons.meeting_room, size: 24),
              label: Text("Kelola Ruangan", style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(250, 60),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Get.to(() => PesananView());
              },
              icon: Icon(Icons.receipt_long, size: 24),
              label: Text("Kelola Pesanan", style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(250, 60),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
