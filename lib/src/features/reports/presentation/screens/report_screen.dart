import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/report_data.dart';
import '../../domain/repositories/report_repository.dart';
import '../providers/report_providers.dart';
import '../utils/report_export_service.dart';

final reportDataControllerProvider =
    FutureProvider.family<ReportData, ReportType>((ref, type) async {
  return ref.watch(reportRepositoryProvider).getReportData(type);
});

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key, required this.type});
  final ReportType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(reportDataControllerProvider(type));

    return Scaffold(
      appBar: AppBar(title: Text('${type.name.toUpperCase()} Report')),
      body: reportAsync.when(
        data: (data) => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () => ReportExportService.exportToCsv(data),
                      icon: const Icon(Icons.table_chart),),
                  IconButton(
                      onPressed: () => ReportExportService.exportToPdf(data),
                      icon: const Icon(Icons.picture_as_pdf),),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: data.headers
                    .map((h) => DataColumn(label: Text(h)))
                    .toList(),
                rows: data.rows
                    .map((r) => DataRow(
                        cells: r
                            .map((c) => DataCell(Text(c.toString())))
                            .toList(),),)
                    .toList(),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
