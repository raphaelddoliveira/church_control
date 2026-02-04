import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> downloadCsv(String csvContent, String filename) async {
  // Adiciona BOM para UTF-8 (para Excel reconhecer acentos)
  final bytes = utf8.encode('\uFEFF$csvContent');
  final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
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
