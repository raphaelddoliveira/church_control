import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/tesouraria/menu_tesouraria/menu_tesouraria_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'page_relatorios_tesouraria_model.dart';
export 'page_relatorios_tesouraria_model.dart';

class PageRelatoriosTesourariaWidget extends StatefulWidget {
  const PageRelatoriosTesourariaWidget({super.key});

  static String routeName = 'PageRelatoriosTesouraria';
  static String routePath = '/pageRelatoriosTesouraria';

  @override
  State<PageRelatoriosTesourariaWidget> createState() => _PageRelatoriosTesourariaWidgetState();
}

class _PageRelatoriosTesourariaWidgetState extends State<PageRelatoriosTesourariaWidget>
    with SingleTickerProviderStateMixin {
  late PageRelatoriosTesourariaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<EntradaFinanceiraRow> _entradas = [];
  List<SaidaFinanceiraRow> _saidas = [];
  bool _isLoading = true;
  DateTime _dataInicio = DateTime.now().subtract(Duration(days: 30));
  DateTime _dataFim = DateTime.now();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageRelatoriosTesourariaModel());
    _model.tabController = TabController(length: 3, vsync: this);
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final entradas = await EntradaFinanceiraTable().queryRows(queryFn: (q) => q);
      final saidas = await SaidaFinanceiraTable().queryRows(queryFn: (q) => q);

      setState(() {
        _entradas = entradas;
        _saidas = saidas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<EntradaFinanceiraRow> get _entradasFiltradas {
    return _entradas.where((e) {
      if (e.dataEntrada == null) return false;
      return e.dataEntrada!.isAfter(_dataInicio.subtract(Duration(days: 1))) &&
             e.dataEntrada!.isBefore(_dataFim.add(Duration(days: 1)));
    }).toList()
      ..sort((a, b) => b.dataEntrada!.compareTo(a.dataEntrada!));
  }

  List<SaidaFinanceiraRow> get _saidasFiltradas {
    return _saidas.where((s) {
      if (s.dataSaida == null) return false;
      return s.dataSaida!.isAfter(_dataInicio.subtract(Duration(days: 1))) &&
             s.dataSaida!.isBefore(_dataFim.add(Duration(days: 1)));
    }).toList()
      ..sort((a, b) => b.dataSaida!.compareTo(a.dataSaida!));
  }

  double get _totalEntradas => _entradasFiltradas.fold(0.0, (sum, e) => sum + (e.valorEntrada ?? 0.0));
  double get _totalSaidas => _saidasFiltradas.fold(0.0, (sum, s) => sum + (s.valorDespesa ?? 0.0));
  double get _saldo => _totalEntradas - _totalSaidas;

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF14181B),
        body: Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          decoration: BoxDecoration(
            color: Color(0xFF14181B),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Menu lateral (desktop)
              if (responsiveVisibility(
                context: context,
                phone: false,
                tablet: false,
                tabletLandscape: false,
              ))
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 0.0, 16.0),
                  child: Container(
                    width: 250.0,
                    height: MediaQuery.sizeOf(context).height,
                    decoration: BoxDecoration(
                      color: Color(0xFF3C3D3E),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: MenuTesourariaWidget(),
                  ),
                ),
              // Conteúdo principal
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height,
                    decoration: BoxDecoration(
                      color: Color(0xFF3C3D3E),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHeader(),
                                    SizedBox(height: 24.0),
                                    _buildFiltros(),
                                    SizedBox(height: 24.0),
                                    _buildResumoGeral(),
                                  ],
                                ),
                              ),
                              _buildTabs(),
                              Expanded(
                                child: TabBarView(
                                  controller: _model.tabController,
                                  children: [
                                    _buildTabelaEntradas(),
                                    _buildTabelaSaidas(),
                                    _buildTabelaFluxoCaixa(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Relatórios',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              'Exporte e analise os dados financeiros',
              style: GoogleFonts.inter(
                color: Color(0xFF999999),
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildExportButton(
              icon: Icons.picture_as_pdf_rounded,
              label: 'Exportar PDF',
              color: Color(0xFFE53935),
              onTap: () => _exportarPDF(),
            ),
            SizedBox(width: 12.0),
            _buildExportButton(
              icon: Icons.table_chart_rounded,
              label: 'Exportar CSV',
              color: Color(0xFF4CAF50),
              onTap: () => _exportarCSV(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExportButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20.0),
            SizedBox(width: 8.0),
            Text(
              label,
              style: GoogleFonts.inter(
                color: color,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color(0xFF404040)),
      ),
      child: Row(
        children: [
          Text(
            'Período:',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.w600),
          ),
          SizedBox(width: 16.0),
          InkWell(
            onTap: () => _selecionarData(isInicio: true),
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: Color(0xFF666666), size: 18.0),
                  SizedBox(width: 8.0),
                  Text(
                    dateTimeFormat('dd/MM/yyyy', _dataInicio),
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text('até', style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 14.0)),
          ),
          InkWell(
            onTap: () => _selecionarData(isInicio: false),
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: Color(0xFF666666), size: 18.0),
                  SizedBox(width: 8.0),
                  Text(
                    dateTimeFormat('dd/MM/yyyy', _dataFim),
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16.0),
          _buildQuickFilter('7 dias', 7),
          SizedBox(width: 8.0),
          _buildQuickFilter('30 dias', 30),
          SizedBox(width: 8.0),
          _buildQuickFilter('90 dias', 90),
        ],
      ),
    );
  }

  Widget _buildQuickFilter(String label, int days) {
    return InkWell(
      onTap: () {
        setState(() {
          _dataFim = DateTime.now();
          _dataInicio = DateTime.now().subtract(Duration(days: days));
        });
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: FlutterFlowTheme.of(context).primary,
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _selecionarData({required bool isInicio}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isInicio ? _dataInicio : _dataFim,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: FlutterFlowTheme.of(context).primary,
              surface: Color(0xFF2D2D2D),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isInicio) {
          _dataInicio = picked;
        } else {
          _dataFim = picked;
        }
      });
    }
  }

  Widget _buildResumoGeral() {
    return Row(
      children: [
        Expanded(
          child: _buildResumoCard(
            'Total Entradas',
            _formatarMoeda(_totalEntradas),
            Icons.trending_up_rounded,
            Color(0xFF4CAF50),
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: _buildResumoCard(
            'Total Saídas',
            _formatarMoeda(_totalSaidas),
            Icons.trending_down_rounded,
            Color(0xFFE53935),
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: _buildResumoCard(
            'Saldo do Período',
            _formatarMoeda(_saldo),
            Icons.account_balance_wallet_rounded,
            _saldo >= 0 ? Color(0xFF4CAF50) : Color(0xFFE53935),
          ),
        ),
      ],
    );
  }

  Widget _buildResumoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color(0xFF404040)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(icon, color: color, size: 24.0),
          ),
          SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 12.0),
              ),
              SizedBox(height: 4.0),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TabBar(
        controller: _model.tabController,
        indicator: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary,
          borderRadius: BorderRadius.circular(12.0),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Color(0xFF999999),
        labelStyle: GoogleFonts.inter(fontSize: 14.0, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 14.0),
        tabs: [
          Tab(text: 'Entradas'),
          Tab(text: 'Saídas'),
          Tab(text: 'Fluxo de Caixa'),
        ],
      ),
    );
  }

  Widget _buildTabelaEntradas() {
    if (_entradasFiltradas.isEmpty) {
      return _buildEmptyState('Nenhuma entrada no período selecionado');
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Color(0xFF404040)),
        ),
        child: Column(
          children: [
            _buildTableHeader(['Data', 'Tipo', 'Descrição', 'Valor']),
            ..._entradasFiltradas.map((e) => _buildTableRow([
              e.dataEntrada != null ? dateTimeFormat('dd/MM/yyyy', e.dataEntrada!) : '-',
              e.tipoEntrada ?? '-',
              e.descricao ?? '-',
              _formatarMoeda(e.valorEntrada ?? 0),
            ], isPositive: true)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabelaSaidas() {
    if (_saidasFiltradas.isEmpty) {
      return _buildEmptyState('Nenhuma saída no período selecionado');
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Color(0xFF404040)),
        ),
        child: Column(
          children: [
            _buildTableHeader(['Data', 'Categoria', 'Descrição', 'Situação', 'Valor']),
            ..._saidasFiltradas.map((s) => _buildTableRow([
              s.dataSaida != null ? dateTimeFormat('dd/MM/yyyy', s.dataSaida!) : '-',
              s.categoria ?? '-',
              s.descricao ?? '-',
              s.situacao ?? '-',
              _formatarMoeda(s.valorDespesa ?? 0),
            ], isPositive: false)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabelaFluxoCaixa() {
    // Combina entradas e saídas ordenadas por data
    final List<Map<String, dynamic>> fluxo = [];

    for (var e in _entradasFiltradas) {
      fluxo.add({
        'data': e.dataEntrada,
        'tipo': 'Entrada',
        'categoria': e.tipoEntrada,
        'descricao': e.descricao,
        'valor': e.valorEntrada ?? 0.0,
        'isPositive': true,
      });
    }

    for (var s in _saidasFiltradas) {
      fluxo.add({
        'data': s.dataSaida,
        'tipo': 'Saída',
        'categoria': s.categoria,
        'descricao': s.descricao,
        'valor': s.valorDespesa ?? 0.0,
        'isPositive': false,
      });
    }

    fluxo.sort((a, b) {
      if (a['data'] == null && b['data'] == null) return 0;
      if (a['data'] == null) return 1;
      if (b['data'] == null) return -1;
      return (b['data'] as DateTime).compareTo(a['data'] as DateTime);
    });

    if (fluxo.isEmpty) {
      return _buildEmptyState('Nenhuma movimentação no período selecionado');
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Color(0xFF404040)),
        ),
        child: Column(
          children: [
            _buildTableHeader(['Data', 'Tipo', 'Categoria', 'Descrição', 'Valor']),
            ...fluxo.map((item) => _buildTableRow([
              item['data'] != null ? dateTimeFormat('dd/MM/yyyy', item['data']) : '-',
              item['tipo'],
              item['categoria'] ?? '-',
              item['descricao'] ?? '-',
              (item['isPositive'] ? '+ ' : '- ') + _formatarMoeda(item['valor']),
            ], isPositive: item['isPositive'])).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(List<String> columns) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Row(
        children: columns.map((col) => Expanded(
          child: Text(
            col,
            style: GoogleFonts.inter(
              color: Color(0xFF999999),
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildTableRow(List<String> cells, {required bool isPositive}) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF404040), width: 0.5)),
      ),
      child: Row(
        children: cells.asMap().entries.map((entry) {
          final isLast = entry.key == cells.length - 1;
          return Expanded(
            child: Text(
              entry.value,
              style: GoogleFonts.inter(
                color: isLast
                    ? (isPositive ? Color(0xFF4CAF50) : Color(0xFFE53935))
                    : Colors.white,
                fontSize: 14.0,
                fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, color: Color(0xFF666666), size: 64.0),
            SizedBox(height: 16.0),
            Text(
              message,
              style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportarPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Relatório Financeiro', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Paragraph(text: 'Período: ${dateTimeFormat('dd/MM/yyyy', _dataInicio)} até ${dateTimeFormat('dd/MM/yyyy', _dataFim)}'),
          pw.SizedBox(height: 20),

          // Resumo
          pw.Container(
            padding: pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(border: pw.Border.all()),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Resumo', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('Total de Entradas: ${_formatarMoeda(_totalEntradas)}'),
                pw.Text('Total de Saídas: ${_formatarMoeda(_totalSaidas)}'),
                pw.Text('Saldo do Período: ${_formatarMoeda(_saldo)}'),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Entradas
          pw.Header(level: 1, child: pw.Text('Entradas')),
          if (_entradasFiltradas.isEmpty)
            pw.Text('Nenhuma entrada no período.')
          else
            pw.Table.fromTextArray(
              headers: ['Data', 'Tipo', 'Descrição', 'Valor'],
              data: _entradasFiltradas.map((e) => [
                e.dataEntrada != null ? dateTimeFormat('dd/MM/yyyy', e.dataEntrada!) : '-',
                e.tipoEntrada ?? '-',
                e.descricao ?? '-',
                _formatarMoeda(e.valorEntrada ?? 0),
              ]).toList(),
            ),
          pw.SizedBox(height: 20),

          // Saídas
          pw.Header(level: 1, child: pw.Text('Saídas')),
          if (_saidasFiltradas.isEmpty)
            pw.Text('Nenhuma saída no período.')
          else
            pw.Table.fromTextArray(
              headers: ['Data', 'Categoria', 'Descrição', 'Situação', 'Valor'],
              data: _saidasFiltradas.map((s) => [
                s.dataSaida != null ? dateTimeFormat('dd/MM/yyyy', s.dataSaida!) : '-',
                s.categoria ?? '-',
                s.descricao ?? '-',
                s.situacao ?? '-',
                _formatarMoeda(s.valorDespesa ?? 0),
              ]).toList(),
            ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> _exportarCSV() async {
    try {
      // Criar dados do CSV
      List<List<dynamic>> rows = [
        ['Relatório Financeiro - ${dateTimeFormat('dd/MM/yyyy', _dataInicio)} até ${dateTimeFormat('dd/MM/yyyy', _dataFim)}'],
        [],
        ['RESUMO'],
        ['Total Entradas', _totalEntradas],
        ['Total Saídas', _totalSaidas],
        ['Saldo', _saldo],
        [],
        ['ENTRADAS'],
        ['Data', 'Tipo', 'Descrição', 'Valor'],
        ..._entradasFiltradas.map((e) => [
          e.dataEntrada != null ? dateTimeFormat('dd/MM/yyyy', e.dataEntrada!) : '-',
          e.tipoEntrada ?? '-',
          e.descricao ?? '-',
          e.valorEntrada ?? 0,
        ]),
        [],
        ['SAÍDAS'],
        ['Data', 'Categoria', 'Descrição', 'Situação', 'Valor'],
        ..._saidasFiltradas.map((s) => [
          s.dataSaida != null ? dateTimeFormat('dd/MM/yyyy', s.dataSaida!) : '-',
          s.categoria ?? '-',
          s.descricao ?? '-',
          s.situacao ?? '-',
          s.valorDespesa ?? 0,
        ]),
      ];

      String csv = const ListToCsvConverter().convert(rows);

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/relatorio_financeiro.csv');
      await file.writeAsString(csv);

      await Share.shareXFiles([XFile(file.path)], text: 'Relatório Financeiro');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV exportado com sucesso!'), backgroundColor: Color(0xFF4CAF50)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao exportar CSV: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
