// lib/utils/pdf_generator.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class PesananPdfGenerator {
  static Future<pw.Document> generatePesananPdf({
    required String title,
    required List<Map<String, dynamic>> data,
    required int totalData,
  }) async {
    final pdf = pw.Document();

    // Format tanggal
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    // Header
    final headerStyle = pw.TextStyle(
      fontSize: 20,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue,
    );

    final subHeaderStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.normal,
      color: PdfColors.grey,
    );

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(20),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Judul Laporan
              pw.Text(
                title.toUpperCase(),
                style: headerStyle,
              ),
              pw.SizedBox(height: 5),

              // Informasi tanggal dan total data
              pw.Row(
                children: [
                  pw.Text(
                    'Tanggal Cetak: $formattedDate',
                    style: subHeaderStyle,
                  ),
                  pw.Spacer(),
                  pw.Text(
                    'Total Data: $totalData',
                    style: subHeaderStyle.copyWith(
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Garis pemisah
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 20),

              // Tabel
              if (data.isNotEmpty)
                _buildTable(data)
              else
                pw.Center(
                  child: pw.Text(
                    'Tidak ada data pesanan',
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.grey),
                  ),
                ),

              pw.SizedBox(height: 40),

              // Footer
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  '© ${now.year} - Sistem Manajemen Pesanan Ruangan',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildTable(List<Map<String, dynamic>> data) {
    // Definisikan header tabel
    final headers = [
      'NO',
      'NAMA RUANGAN',
      'PENGGUNA',
      'TANGGAL',
      'TOTAL',
      'BUKTI'
    ];

    // Buat list data untuk tabel
    final tableData = data.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final item = entry.value;

      return [
        index.toString(),
        item['nama_ruangan']?.toString() ?? '-',
        item['pengguna']?.toString() ?? '-',
        item['tanggal']?.toString() ?? '-',
        'Rp ${item['total']?.toString() ?? '0'}',
        (item['bukti']?.toString() ?? '').isNotEmpty ? 'Ada' : 'Tidak Ada',
      ];
    }).toList();

    return pw.Table.fromTextArray(
      border: null,
      headerDecoration: pw.BoxDecoration(
        color: PdfColors.blueGrey100,
      ),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 11,
        color: PdfColors.blueGrey800,
      ),
      cellStyle: pw.TextStyle(
        fontSize: 10,
        color: PdfColors.black,
      ),
      rowDecoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.grey300,
            width: 0.5,
          ),
        ),
      ),
      headers: headers,
      data: tableData,
      columnWidths: {
        0: pw.FlexColumnWidth(0.5), // NO
        1: pw.FlexColumnWidth(2.0), // NAMA RUANGAN
        2: pw.FlexColumnWidth(1.5), // PENGGUNA
        3: pw.FlexColumnWidth(1.0), // TANGGAL
        4: pw.FlexColumnWidth(1.2), // TOTAL
        5: pw.FlexColumnWidth(1.0), // BUKTI
      },
      headerPadding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      cellPadding: pw.EdgeInsets.symmetric(vertical: 6, horizontal: 5),
      cellAlignment: pw.Alignment.centerLeft,
    );
  }
}
