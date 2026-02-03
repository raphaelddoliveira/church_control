import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/tesouraria/menu_tesouraria/menu_tesouraria_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'page_saidas_tesouraria_model.dart';
export 'page_saidas_tesouraria_model.dart';

class PageSaidasTesourariaWidget extends StatefulWidget {
  const PageSaidasTesourariaWidget({super.key});

  static String routeName = 'PageSaidasTesouraria';
  static String routePath = '/pageSaidasTesouraria';

  @override
  State<PageSaidasTesourariaWidget> createState() => _PageSaidasTesourariaWidgetState();
}

class _PageSaidasTesourariaWidgetState extends State<PageSaidasTesourariaWidget> {
  late PageSaidasTesourariaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<SaidaFinanceiraRow> _saidas = [];
  bool _isLoading = true;
  String? _filtroCategoria;
  String? _filtroSituacao;
  DateTime? _filtroDataInicio;
  DateTime? _filtroDataFim;

  final List<String> _categorias = [
    'Despesa Fixa',
    'Manutenção',
    'Serviços',
    'Eventos',
    'Doações',
    'Contas',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageSaidasTesourariaModel());
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final saidas = await SaidaFinanceiraTable().queryRows(queryFn: (q) => q);

      saidas.sort((a, b) {
        if (a.dataSaida == null && b.dataSaida == null) return 0;
        if (a.dataSaida == null) return 1;
        if (b.dataSaida == null) return -1;
        return b.dataSaida!.compareTo(a.dataSaida!);
      });

      setState(() {
        _saidas = saidas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<SaidaFinanceiraRow> get _saidasFiltradas {
    return _saidas.where((saida) {
      // Filtro por busca
      final query = _model.searchController?.text.toLowerCase() ?? '';
      if (query.isNotEmpty) {
        final descricao = saida.descricao?.toLowerCase() ?? '';
        final categoria = saida.categoria?.toLowerCase() ?? '';
        if (!descricao.contains(query) && !categoria.contains(query)) {
          return false;
        }
      }

      // Filtro por categoria
      if (_filtroCategoria != null && _filtroCategoria!.isNotEmpty) {
        if (saida.categoria != _filtroCategoria) {
          return false;
        }
      }

      // Filtro por situação
      if (_filtroSituacao != null && _filtroSituacao!.isNotEmpty) {
        if (saida.situacao != _filtroSituacao) {
          return false;
        }
      }

      // Filtro por data
      if (_filtroDataInicio != null && saida.dataSaida != null) {
        if (saida.dataSaida!.isBefore(_filtroDataInicio!)) return false;
      }
      if (_filtroDataFim != null && saida.dataSaida != null) {
        if (saida.dataSaida!.isAfter(_filtroDataFim!.add(Duration(days: 1)))) return false;
      }

      return true;
    }).toList();
  }

  double get _totalFiltrado {
    return _saidasFiltradas.fold(0.0, (sum, s) => sum + (s.valorDespesa ?? 0.0));
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Color _getStatusColor(SaidaFinanceiraRow saida) {
    if (saida.situacao == 'Pago') {
      return Color(0xFF4CAF50); // Verde
    }
    if (saida.dataVencimento != null && saida.dataVencimento!.isBefore(DateTime.now())) {
      return Color(0xFFE53935); // Vermelho - Vencido
    }
    return Color(0xFFFF9800); // Amarelo - Pendente
  }

  String _getStatusText(SaidaFinanceiraRow saida) {
    if (saida.situacao == 'Pago') return 'Pago';
    if (saida.dataVencimento != null && saida.dataVencimento!.isBefore(DateTime.now())) {
      return 'Vencido';
    }
    return 'Pendente';
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
                        : SingleChildScrollView(
                            padding: EdgeInsets.all(32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(),
                                SizedBox(height: 24.0),
                                _buildFiltros(),
                                SizedBox(height: 16.0),
                                _buildResumo(),
                                SizedBox(height: 24.0),
                                _buildListaSaidas(),
                              ],
                            ),
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
              'Saídas',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              'Gerencie as despesas e contas da igreja',
              style: GoogleFonts.inter(
                color: Color(0xFF999999),
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: () => _mostrarModalNovaSaida(),
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
            decoration: BoxDecoration(
              color: Color(0xFFE53935),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 20.0),
                SizedBox(width: 8.0),
                Text(
                  'Nova Saída',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
      child: Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        children: [
          SizedBox(
            width: 250,
            child: TextField(
              controller: _model.searchController,
              focusNode: _model.searchFocusNode,
              onChanged: (_) => EasyDebounce.debounce(
                'search',
                Duration(milliseconds: 300),
                () => setState(() {}),
              ),
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
              decoration: InputDecoration(
                hintText: 'Buscar por descrição...',
                hintStyle: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 14.0),
                prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF666666)),
                filled: true,
                fillColor: Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              ),
            ),
          ),
          Container(
            width: 180,
            child: DropdownButtonFormField<String>(
              value: _filtroCategoria,
              decoration: InputDecoration(
                hintText: 'Categoria',
                hintStyle: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 14.0),
                filled: true,
                fillColor: Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              ),
              dropdownColor: Color(0xFF2D2D2D),
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
              items: [
                DropdownMenuItem(value: null, child: Text('Todas')),
                ..._categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))),
              ],
              onChanged: (value) => setState(() => _filtroCategoria = value),
            ),
          ),
          Container(
            width: 150,
            child: DropdownButtonFormField<String>(
              value: _filtroSituacao,
              decoration: InputDecoration(
                hintText: 'Situação',
                hintStyle: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 14.0),
                filled: true,
                fillColor: Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              ),
              dropdownColor: Color(0xFF2D2D2D),
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
              items: [
                DropdownMenuItem(value: null, child: Text('Todas')),
                DropdownMenuItem(value: 'Pendente', child: Text('Pendente')),
                DropdownMenuItem(value: 'Pago', child: Text('Pago')),
              ],
              onChanged: (value) => setState(() => _filtroSituacao = value),
            ),
          ),
          InkWell(
            onTap: () => _selecionarPeriodo(),
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_rounded, color: Color(0xFF666666), size: 18.0),
                  SizedBox(width: 8.0),
                  Text(
                    _filtroDataInicio != null
                        ? '${dateTimeFormat('dd/MM', _filtroDataInicio!)} - ${dateTimeFormat('dd/MM', _filtroDataFim ?? _filtroDataInicio!)}'
                        : 'Período',
                    style: GoogleFonts.inter(
                      color: _filtroDataInicio != null ? Colors.white : Color(0xFF666666),
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_filtroCategoria != null || _filtroSituacao != null || _filtroDataInicio != null)
            InkWell(
              onTap: () => setState(() {
                _filtroCategoria = null;
                _filtroSituacao = null;
                _filtroDataInicio = null;
                _filtroDataFim = null;
              }),
              child: Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Color(0xFFE53935).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(Icons.clear_rounded, color: Color(0xFFE53935), size: 20.0),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResumo() {
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Color(0xFFE53935).withOpacity(0.15),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color(0xFFE53935).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Color(0xFFE53935).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(Icons.trending_down_rounded, color: Color(0xFFE53935), size: 24.0),
              ),
              SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Filtrado',
                    style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 14.0),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    _formatarMoeda(_totalFiltrado),
                    style: GoogleFonts.poppins(
                      color: Color(0xFFE53935),
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            '${_saidasFiltradas.length} registros',
            style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 14.0),
          ),
        ],
      ),
    );
  }

  Widget _buildListaSaidas() {
    if (_saidasFiltradas.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: Column(
            children: [
              Icon(Icons.inbox_rounded, color: Color(0xFF666666), size: 64.0),
              SizedBox(height: 16.0),
              Text(
                'Nenhuma saída encontrada',
                style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 16.0),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color(0xFF404040)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('Data', style: _headerStyle())),
                Expanded(flex: 2, child: Text('Categoria', style: _headerStyle())),
                Expanded(flex: 3, child: Text('Descrição', style: _headerStyle())),
                Expanded(flex: 2, child: Text('Vencimento', style: _headerStyle())),
                Expanded(flex: 1, child: Text('Status', style: _headerStyle())),
                Expanded(flex: 2, child: Text('Valor', style: _headerStyle())),
                SizedBox(width: 80),
              ],
            ),
          ),
          ..._saidasFiltradas.map((saida) => _buildSaidaRow(saida)).toList(),
        ],
      ),
    );
  }

  TextStyle _headerStyle() {
    return GoogleFonts.inter(
      color: Color(0xFF999999),
      fontSize: 12.0,
      fontWeight: FontWeight.w600,
    );
  }

  Widget _buildSaidaRow(SaidaFinanceiraRow saida) {
    final statusColor = _getStatusColor(saida);
    final statusText = _getStatusText(saida);

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF404040), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              saida.dataSaida != null ? dateTimeFormat('dd/MM/yyyy', saida.dataSaida!) : '-',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Color(0xFF2196F3).withOpacity(0.15),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text(
                saida.categoria ?? '-',
                style: GoogleFonts.inter(
                  color: Color(0xFF2196F3),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              saida.descricao ?? '-',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              saida.dataVencimento != null ? dateTimeFormat('dd/MM/yyyy', saida.dataVencimento!) : '-',
              style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 14.0),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text(
                statusText,
                style: GoogleFonts.inter(
                  color: statusColor,
                  fontSize: 11.0,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatarMoeda(saida.valorDespesa ?? 0),
              style: GoogleFonts.poppins(
                color: Color(0xFFE53935),
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () => _mostrarModalEditarSaida(saida),
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF2196F3).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(Icons.edit_rounded, color: Color(0xFF2196F3), size: 16.0),
                  ),
                ),
                SizedBox(width: 8.0),
                InkWell(
                  onTap: () => _confirmarExclusao(saida),
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFE53935).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(Icons.delete_rounded, color: Color(0xFFE53935), size: 16.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selecionarPeriodo() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: _filtroDataInicio != null
          ? DateTimeRange(start: _filtroDataInicio!, end: _filtroDataFim ?? _filtroDataInicio!)
          : null,
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
        _filtroDataInicio = picked.start;
        _filtroDataFim = picked.end;
      });
    }
  }

  void _mostrarModalNovaSaida() {
    final descricaoController = TextEditingController();
    final valorController = TextEditingController();
    final codigoBarrasController = TextEditingController();
    String? categoriaSelecionada = 'Contas';
    String situacaoSelecionada = 'Pendente';
    DateTime dataSaida = DateTime.now();
    DateTime? dataVencimento;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 550,
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
                padding: EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nova Saída',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(dialogContext),
                            child: Icon(Icons.close_rounded, color: Color(0xFF999999)),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.0),

                      // Seção de Código de Barras
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Color(0xFF404040)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.qr_code_scanner, color: Color(0xFF2196F3), size: 20.0),
                                SizedBox(width: 8.0),
                                Text(
                                  'Ler Código de Barras do Boleto',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.0),
                            TextField(
                              controller: codigoBarrasController,
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                              keyboardType: TextInputType.number,
                              maxLength: 47,
                              decoration: InputDecoration(
                                hintText: 'Digite os 47 números da linha digitável',
                                hintStyle: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 13.0),
                                filled: true,
                                fillColor: Color(0xFF2D2D2D),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                counterStyle: GoogleFonts.inter(color: Color(0xFF666666)),
                              ),
                            ),
                            SizedBox(height: 8.0),
                            InkWell(
                              onTap: () {
                                final codigo = codigoBarrasController.text.replaceAll(RegExp(r'\D'), '');
                                if (codigo.length == 47) {
                                  final dadosBoleto = _parseBoleto(codigo);
                                  if (dadosBoleto != null) {
                                    setDialogState(() {
                                      valorController.text = dadosBoleto['valor']!;
                                      if (dadosBoleto['vencimento'] != null) {
                                        dataVencimento = DateTime.tryParse(dadosBoleto['vencimento']!);
                                      }
                                      descricaoController.text = dadosBoleto['descricao'] ?? '';
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Dados do boleto preenchidos!'),
                                        backgroundColor: Color(0xFF4CAF50),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Código de barras inválido. Digite os 47 números.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(8.0),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFF2196F3).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: Color(0xFF2196F3).withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.auto_awesome, color: Color(0xFF2196F3), size: 18.0),
                                    SizedBox(width: 8.0),
                                    Text(
                                      'Preencher Automaticamente',
                                      style: GoogleFonts.inter(
                                        color: Color(0xFF2196F3),
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.0),
                      Divider(color: Color(0xFF404040)),
                      SizedBox(height: 20.0),

                      // Descrição
                      Text('Descrição', style: _labelStyle()),
                      SizedBox(height: 8.0),
                      TextField(
                        controller: descricaoController,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                        decoration: _inputDecoration().copyWith(hintText: 'Ex: Conta de luz'),
                      ),
                      SizedBox(height: 16.0),

                      // Valor
                      Text('Valor', style: _labelStyle()),
                      SizedBox(height: 8.0),
                      TextField(
                        controller: valorController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                        decoration: _inputDecoration().copyWith(
                          hintText: '0,00',
                          prefixText: 'R\$ ',
                          prefixStyle: GoogleFonts.inter(color: Color(0xFFE53935), fontSize: 14.0),
                        ),
                      ),
                      SizedBox(height: 16.0),

                      // Categoria
                      Text('Categoria', style: _labelStyle()),
                      SizedBox(height: 8.0),
                      DropdownButtonFormField<String>(
                        value: categoriaSelecionada,
                        decoration: _inputDecoration(),
                        dropdownColor: Color(0xFF1E1E1E),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                        items: _categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (value) => setDialogState(() => categoriaSelecionada = value),
                      ),
                      SizedBox(height: 16.0),

                      // Data da Saída
                      Text('Data da Saída', style: _labelStyle()),
                      SizedBox(height: 8.0),
                      _buildDatePicker(
                        value: dataSaida,
                        onChanged: (date) => setDialogState(() => dataSaida = date),
                      ),
                      SizedBox(height: 16.0),

                      // Data de Vencimento
                      Text('Data de Vencimento (opcional)', style: _labelStyle()),
                      SizedBox(height: 8.0),
                      _buildDatePicker(
                        value: dataVencimento,
                        placeholder: 'Selecionar vencimento',
                        onChanged: (date) => setDialogState(() => dataVencimento = date),
                      ),
                      SizedBox(height: 16.0),

                      // Situação
                      Text('Situação', style: _labelStyle()),
                      SizedBox(height: 8.0),
                      DropdownButtonFormField<String>(
                        value: situacaoSelecionada,
                        decoration: _inputDecoration(),
                        dropdownColor: Color(0xFF1E1E1E),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                        items: [
                          DropdownMenuItem(value: 'Pendente', child: Text('Pendente')),
                          DropdownMenuItem(value: 'Pago', child: Text('Pago')),
                        ],
                        onChanged: (value) => setDialogState(() => situacaoSelecionada = value ?? 'Pendente'),
                      ),
                      SizedBox(height: 24.0),

                      // Botões
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => Navigator.pop(dialogContext),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 14.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFF404040),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Center(
                                  child: Text(
                                    'Cancelar',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.0),
                          Expanded(
                            child: InkWell(
                              onTap: isSaving ? null : () async {
                                final valorTexto = valorController.text.replaceAll(',', '.');
                                final valor = double.tryParse(valorTexto) ?? 0;

                                if (valor <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Informe um valor válido'), backgroundColor: Colors.red),
                                  );
                                  return;
                                }

                                if (descricaoController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Informe uma descrição'), backgroundColor: Colors.red),
                                  );
                                  return;
                                }

                                setDialogState(() => isSaving = true);

                                try {
                                  await SaidaFinanceiraTable().insert({
                                    'descricao': descricaoController.text.trim(),
                                    'valor_despesa': valor,
                                    'categoria': categoriaSelecionada,
                                    'data_saida': dataSaida.toIso8601String(),
                                    'data_vencimento': dataVencimento?.toIso8601String(),
                                    'situacao': situacaoSelecionada,
                                  });

                                  Navigator.pop(dialogContext);
                                  _carregarDados();
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    SnackBar(content: Text('Saída registrada com sucesso!'), backgroundColor: Color(0xFF4CAF50)),
                                  );
                                } catch (e) {
                                  setDialogState(() => isSaving = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Erro ao salvar saída'), backgroundColor: Colors.red),
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 14.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE53935),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Center(
                                  child: isSaving
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          'Salvar',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDatePicker({
    DateTime? value,
    String? placeholder,
    required Function(DateTime) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(Duration(days: 365 * 2)),
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
          onChanged(picked);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value != null ? dateTimeFormat('dd/MM/yyyy', value) : (placeholder ?? 'Selecionar data'),
              style: GoogleFonts.inter(
                color: value != null ? Colors.white : Color(0xFF666666),
                fontSize: 14.0,
              ),
            ),
            Icon(Icons.calendar_today_rounded, color: Color(0xFF666666), size: 18.0),
          ],
        ),
      ),
    );
  }

  // Parser simples de boleto bancário brasileiro
  Map<String, String>? _parseBoleto(String codigo) {
    try {
      if (codigo.length != 47) return null;

      // Extrair valor (campos 4 e 5 do código de barras)
      // Posições 37-47 contém o valor
      final valorStr = codigo.substring(37, 47);
      final valorCentavos = int.tryParse(valorStr) ?? 0;
      final valor = valorCentavos / 100;

      // Extrair fator de vencimento (posições 33-36)
      final fatorStr = codigo.substring(33, 37);
      final fator = int.tryParse(fatorStr) ?? 0;

      DateTime? vencimento;
      if (fator > 0) {
        // Data base: 07/10/1997
        final dataBase = DateTime(1997, 10, 7);
        vencimento = dataBase.add(Duration(days: fator));
      }

      // Identificar banco pelo código (primeiros 3 dígitos)
      final codigoBanco = codigo.substring(0, 3);
      final nomeBanco = _getNomeBanco(codigoBanco);

      return {
        'valor': valor.toStringAsFixed(2).replaceAll('.', ','),
        if (vencimento != null) 'vencimento': vencimento.toIso8601String(),
        'descricao': 'Boleto $nomeBanco',
      };
    } catch (e) {
      return null;
    }
  }

  String _getNomeBanco(String codigo) {
    final bancos = {
      '001': 'Banco do Brasil',
      '033': 'Santander',
      '104': 'Caixa Econômica',
      '237': 'Bradesco',
      '341': 'Itaú',
      '356': 'Banco Real',
      '389': 'Mercantil do Brasil',
      '399': 'HSBC',
      '422': 'Safra',
      '453': 'Rural',
      '633': 'Rendimento',
      '652': 'Itaú Unibanco',
      '745': 'Citibank',
      '756': 'Sicoob',
    };
    return bancos[codigo] ?? 'Banco $codigo';
  }

  void _mostrarModalEditarSaida(SaidaFinanceiraRow saida) {
    final descricaoController = TextEditingController(text: saida.descricao ?? '');
    final valorController = TextEditingController(text: saida.valorDespesa?.toStringAsFixed(2).replaceAll('.', ',') ?? '');
    String? categoriaSelecionada = saida.categoria ?? 'Contas';
    String situacaoSelecionada = saida.situacao ?? 'Pendente';
    DateTime dataSaida = saida.dataSaida ?? DateTime.now();
    DateTime? dataVencimento = saida.dataVencimento;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 500,
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
                padding: EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Editar Saída',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(dialogContext),
                            child: Icon(Icons.close_rounded, color: Color(0xFF999999)),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.0),

                      Text('Descrição', style: _labelStyle()),
                      SizedBox(height: 8.0),
                      TextField(
                        controller: descricaoController,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                        decoration: _inputDecoration().copyWith(hintText: 'Ex: Conta de luz'),
                      ),
                      SizedBox(height: 16.0),

                      Text('Valor', style: _labelStyle()),
                      SizedBox(height: 8.0),
                      TextField(
                        controller: valorController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                        decoration: _inputDecoration().copyWith(
                          hintText: '0,00',
                          prefixText: 'R\$ ',
                          prefixStyle: GoogleFonts.inter(color: Color(0xFFE53935), fontSize: 14.0),
                        ),
                      ),
                      SizedBox(height: 16.0),

                      Text('Categoria', style: _labelStyle()),
                      SizedBox(height: 8.0),
                      DropdownButtonFormField<String>(
                        value: categoriaSelecionada,
                        decoration: _inputDecoration(),
                        dropdownColor: Color(0xFF1E1E1E),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                        items: _categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (value) => setDialogState(() => categoriaSelecionada = value),
                      ),
                      SizedBox(height: 16.0),

                      Text('Data da Saída', style: _labelStyle()),
                      SizedBox(height: 8.0),
                      _buildDatePicker(
                        value: dataSaida,
                        onChanged: (date) => setDialogState(() => dataSaida = date),
                      ),
                      SizedBox(height: 16.0),

                      Text('Data de Vencimento (opcional)', style: _labelStyle()),
                      SizedBox(height: 8.0),
                      _buildDatePicker(
                        value: dataVencimento,
                        placeholder: 'Selecionar vencimento',
                        onChanged: (date) => setDialogState(() => dataVencimento = date),
                      ),
                      SizedBox(height: 16.0),

                      Text('Situação', style: _labelStyle()),
                      SizedBox(height: 8.0),
                      DropdownButtonFormField<String>(
                        value: situacaoSelecionada,
                        decoration: _inputDecoration(),
                        dropdownColor: Color(0xFF1E1E1E),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                        items: [
                          DropdownMenuItem(value: 'Pendente', child: Text('Pendente')),
                          DropdownMenuItem(value: 'Pago', child: Text('Pago')),
                        ],
                        onChanged: (value) => setDialogState(() => situacaoSelecionada = value ?? 'Pendente'),
                      ),
                      SizedBox(height: 24.0),

                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => Navigator.pop(dialogContext),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 14.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFF404040),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Center(
                                  child: Text(
                                    'Cancelar',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.0),
                          Expanded(
                            child: InkWell(
                              onTap: isSaving ? null : () async {
                                final valorTexto = valorController.text.replaceAll(',', '.');
                                final valor = double.tryParse(valorTexto) ?? 0;

                                if (valor <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Informe um valor válido'), backgroundColor: Colors.red),
                                  );
                                  return;
                                }

                                setDialogState(() => isSaving = true);

                                try {
                                  await SaidaFinanceiraTable().update(
                                    data: {
                                      'descricao': descricaoController.text.trim().isNotEmpty ? descricaoController.text.trim() : null,
                                      'valor_despesa': valor,
                                      'categoria': categoriaSelecionada,
                                      'data_saida': dataSaida.toIso8601String(),
                                      'data_vencimento': dataVencimento?.toIso8601String(),
                                      'situacao': situacaoSelecionada,
                                    },
                                    matchingRows: (rows) => rows.eq('id_saida', saida.idSaida),
                                  );

                                  Navigator.pop(dialogContext);
                                  _carregarDados();
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                    SnackBar(content: Text('Saída atualizada com sucesso!'), backgroundColor: Color(0xFF4CAF50)),
                                  );
                                } catch (e) {
                                  setDialogState(() => isSaving = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Erro ao atualizar saída'), backgroundColor: Colors.red),
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 14.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE53935),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Center(
                                  child: isSaving
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          'Salvar',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmarExclusao(SaidaFinanceiraRow saida) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Color(0xFF2D2D2D),
          title: Text('Confirmar Exclusão', style: GoogleFonts.poppins(color: Colors.white)),
          content: Text(
            'Deseja realmente excluir esta saída?',
            style: GoogleFonts.inter(color: Color(0xFF999999)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancelar', style: GoogleFonts.inter(color: Color(0xFF999999))),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await SaidaFinanceiraTable().delete(
                    matchingRows: (rows) => rows.eq('id_saida', saida.idSaida),
                  );
                  _carregarDados();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Saída excluída com sucesso!'), backgroundColor: Color(0xFF4CAF50)),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir saída'), backgroundColor: Colors.red),
                  );
                }
              },
              child: Text('Excluir', style: GoogleFonts.inter(color: Color(0xFFE53935))),
            ),
          ],
        );
      },
    );
  }

  TextStyle _labelStyle() {
    return GoogleFonts.inter(
      color: Colors.white,
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      hintStyle: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 14.0),
      filled: true,
      fillColor: Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
    );
  }
}
