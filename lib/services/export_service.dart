import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/feedback_entry.dart';
import '../models/field_config.dart';

class ExportService {
  Future<void> exportToExcel({
    required List<FeedbackEntry> entries,
    required List<FieldConfig> fields,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Feedbacks'];
    final activeFields = fields.where((f) => f.active).toList();

    sheet.appendRow([
      TextCellValue('Timestamp'),
      ...activeFields.map((f) => TextCellValue(f.label)),
    ]);

    for (final entry in entries) {
      final row = <CellValue?>[
        TextCellValue(entry.createdAt.toIso8601String()),
        ...activeFields.map((f) {
          final value = entry.payload[f.label];
          if (value == null) return TextCellValue('');
          if (value is double) return DoubleCellValue(value);
          if (value is int) return IntCellValue(value);
          return TextCellValue(value.toString());
        }),
      ];
      sheet.appendRow(row);
    }

    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${dir.path}/feedbacks_$timestamp.xlsx';
    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to encode Excel file');

    await File(path).writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(path)],
      text: 'Equilibrium Gaming Zone - Feedback Export',
    );
  }
}
