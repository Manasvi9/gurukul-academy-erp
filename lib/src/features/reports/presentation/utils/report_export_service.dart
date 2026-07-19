import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/report_data.dart';

class ReportExportService {
  static Future<void> exportToCsv(ReportData data) async {
    final csvRows = [
      data.headers.join(','),
      ...data.rows.map((row) => row.map((cell) => cell.toString()).join(',')),
    ];
    final csvString = csvRows.join('\n');

    final directory = await getTemporaryDirectory();
    final file = File(
        '${directory.path}/${data.title}_${DateTime.now().millisecondsSinceEpoch}.csv',);
    await file.writeAsString(csvString);

    // Using Share.shareXFiles and suppressing deprecation
    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(file.path)],
        text: 'Exported ${data.title} report',);
  }

  static Future<void> exportToPdf(ReportData data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(data.title, style: const pw.TextStyle(fontSize: 20)),
              // Using TableHelper
              pw.TableHelper.fromTextArray(
                headers: data.headers,
                data: data.rows
                    .map((row) => row.map((cell) => cell.toString()).toList())
                    .toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
