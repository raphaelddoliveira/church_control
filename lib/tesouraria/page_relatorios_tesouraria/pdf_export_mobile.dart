import 'dart:typed_data';
import 'package:printing/printing.dart';

Future<void> downloadPdf(Uint8List pdfBytes, String filename) async {
  await Printing.layoutPdf(
    onLayout: (format) async => pdfBytes,
    name: filename,
  );
}
