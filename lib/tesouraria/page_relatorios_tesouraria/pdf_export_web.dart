import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> downloadPdf(Uint8List pdfBytes, String filename) async {
  final blob = html.Blob([pdfBytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement()
    ..href = url
    ..download = filename
    ..style.display = 'none';

  html.document.body?.children.add(anchor);
  anchor.click();

  // Limpar
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}
