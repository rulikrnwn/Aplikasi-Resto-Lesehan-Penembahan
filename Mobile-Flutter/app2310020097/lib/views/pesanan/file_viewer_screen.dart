// lib/views/pesanan/file_viewer_screen.dart - VERSI TANPA DOWNLOAD
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FileViewerScreen extends StatefulWidget {
  final String fileUrl;
  final String fileName;

  const FileViewerScreen({
    required this.fileUrl,
    required this.fileName,
    Key? key,
  }) : super(key: key);

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  bool _isImage = false;

  @override
  void initState() {
    super.initState();
    _checkFileType();
  }

  void _checkFileType() {
    final ext = widget.fileName.toLowerCase().split('.').last;
    setState(() {
      _isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(ext);
    });
  }

  Future<void> _launchUrl() async {
    try {
      if (!await launchUrl(
        Uri.parse(widget.fileUrl),
        mode: LaunchMode.externalApplication,
      )) {
        Get.snackbar(
          'Error',
          'Tidak dapat membuka file',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membuka file: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String _getFileType() {
    final ext = widget.fileName.toLowerCase().split('.').last;
    switch (ext) {
      case 'pdf':
        return 'PDF';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        return 'Gambar';
      default:
        return 'File';
    }
  }

  IconData _getFileIcon() {
    final type = _getFileType();
    switch (type) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'Gambar':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor() {
    final type = _getFileType();
    switch (type) {
      case 'PDF':
        return Colors.red;
      case 'Gambar':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preview File"),
        actions: [
          // HAPUS tombol download dari appbar
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isImage) {
      return _buildImagePreview();
    }
    return _buildFileInfo();
  }

  Widget _buildImagePreview() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Preview Gambar
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GestureDetector(
              onTap: _launchUrl,
              child: Column(
                children: [
                  Container(
                    height: 400,
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: widget.fileUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.blue,
                                strokeWidth: 2,
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Memuat gambar...",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "Gagal memuat gambar",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(12),
                    color: Colors.black54,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.touch_app, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          "Tap untuk membuka gambar ukuran penuh",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 20),

        // Info File
        _buildFileInfoCard(),
        SizedBox(height: 20),

        // Tombol Aksi (hanya Buka di Browser dan Kembali)
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildFileInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getFileColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    _getFileIcon(),
                    color: _getFileColor(),
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Informasi File",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Chip(
                        label: Text(
                          _getFileType().toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: _getFileColor(),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 12),
            _buildInfoRow("Nama File", widget.fileName),
            SizedBox(height: 8),
            _buildInfoRow("Tipe File", _getFileType()),
            SizedBox(height: 8),
            _buildInfoRow(
              "Status",
              "Klik tombol di bawah untuk membuka file di browser",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          child: Text(
            "$label:",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFileInfo() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: _getFileColor().withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_getFileIcon(), size: 70, color: _getFileColor()),
          ),
          SizedBox(height: 24),
          Chip(
            label: Text(
              _getFileType(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            backgroundColor: _getFileColor(),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Text(
                  "Nama File:",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.fileName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Tombol Buka di Browser (SATU-SATUNYA tombol aksi)
        ElevatedButton.icon(
          onPressed: _launchUrl,
          icon: Icon(Icons.open_in_browser),
          label: Text("Buka File di Browser"),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
            backgroundColor: _getFileColor(),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
        ),
        SizedBox(height: 12),

        // Tombol Kembali
        TextButton.icon(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back),
          label: Text("Kembali"),
          style: TextButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }
}
