import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/supabase/supabase.dart';
import '/auth/supabase_auth/auth_util.dart';

String fileNameFromUrl(String input) {
  // Aceita URL pública/assinada ou path do Storage e devolve só o nome do arquivo.
  try {
    final uri = Uri.parse(input);
    // Pega o último segmento do caminho (/a/b/c.docx -> c.docx)
    String last = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last
        : input.split('/').last;

    // Remove query string (?download=1, tokens, etc.)
    last = last.split('?').first;

    // Decodifica espaços e acentos (%20 -> espaço)
    return Uri.decodeComponent(last);
  } catch (_) {
    // Fallback simples caso o parse falhe
    final last = input.split('/').last.split('?').first;
    return Uri.decodeComponent(last);
  }
}

String fileExtFromUrl1(String input) {
  final noQuery = input.split('?').first;
  final dot = noQuery.lastIndexOf('.');
  if (dot == -1) return '';
  return noQuery.substring(dot); // ex.: ".pdf"
}

String? joinLinksList(List<String> links) {
  if (links.isEmpty) return '';
  return links.join(',');
}

String? abreviarNome(String nome) {
  if (nome.trim().isEmpty) return '';

  final partes = nome.trim().split(RegExp(r'\s+'));
  if (partes.length == 1) {
    return partes.first;
  } else {
    return '${partes[0]} ${partes[1]}';
  }
}

String? formatarMoeda(String? valor) {
  final moedaFormatada = NumberFormat.simpleCurrency(locale: 'pt_BR');
  return moedaFormatada.format(valor);
}

String? converterUtcParaLocal(String dataUtc) {
  try {
    // Converte a string da data UTC para o formato DateTime
    DateTime utcDateTime = DateTime.parse(dataUtc);

    // Ajusta a data adicionando 3 horas para corrigir o fuso horário
    DateTime adjustedDateTime = utcDateTime.add(Duration(hours: 3));

    // Formata a data para o formato desejado (yyyy-MM-dd HH:mm:ss)
    String formattedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(adjustedDateTime);

    return formattedDate;
  } catch (e) {
    // Se ocorrer algum erro, retorna uma mensagem de erro
    return 'Data inválida';
  }
}

Future<Uint8List> exportarMembrosPDF(List<MembrosRow> membros) async {
  final pdf = pw.Document();

  // Formata a data atual
  final dataAtual = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return [
          // Cabeçalho
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Lista de Membros',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'PIB Santa Fé do Sul',
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Gerado em: $dataAtual',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Total de membros: ${membros.length}',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.Divider(thickness: 2),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Tabela de membros
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
            columnWidths: {
              0: pw.FlexColumnWidth(1),
              1: pw.FlexColumnWidth(3),
              2: pw.FlexColumnWidth(3),
              3: pw.FlexColumnWidth(2),
            },
            children: [
              // Cabeçalho da tabela
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      '#',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Nome',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Email',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Data Nasc.',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),

              // Linhas de dados
              ...membros.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final membro = entry.value;

                // Formata a data de nascimento
                String dataNasc = '-';
                if (membro.dataNascimento != null) {
                  dataNasc = DateFormat('dd/MM/yyyy').format(membro.dataNascimento!);
                }

                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: index % 2 == 0 ? PdfColors.grey100 : PdfColors.white,
                  ),
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('$index'),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(membro.nomeMembro),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(membro.email ?? '-'),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(dataNasc),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),

          // Rodapé
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Text(
            'Documento gerado automaticamente pelo ChurchControl',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
        ];
      },
    ),
  );

  return pdf.save();
}
