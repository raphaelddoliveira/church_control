import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/tesouraria/menu_tesouraria/menu_tesouraria_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'page_graficos_tesouraria_model.dart';
export 'page_graficos_tesouraria_model.dart';

class PageGraficosTesourariaWidget extends StatefulWidget {
  const PageGraficosTesourariaWidget({super.key});

  static String routeName = 'PageGraficosTesouraria';
  static String routePath = '/pageGraficosTesouraria';

  @override
  State<PageGraficosTesourariaWidget> createState() =>
      _PageGraficosTesourariaWidgetState();
}

class _PageGraficosTesourariaWidgetState
    extends State<PageGraficosTesourariaWidget> {
  late PageGraficosTesourariaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Dados
  List<EntradaFinanceiraRow> _entradas = [];
  List<SaidaFinanceiraRow> _saidas = [];
  List<ViewFluxoFinanceiroProjetadoRow> _fluxoProjetado = [];
  bool _isLoading = true;

  // Filtros
  int _periodoMeses = 6;
  String? _filtroCategoriaSaida;
  String? _filtroTipoEntrada;
  DateTime? _dataInicioCustom;
  DateTime? _dataFimCustom;
  bool _usandoPeriodoCustom = false;

  // Interação pie charts
  int _touchedIndexEntradas = -1;
  int _touchedIndexSaidas = -1;

  // Opções de filtro
  List<String> _categoriasDisponiveis = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageGraficosTesourariaModel());
    _carregarDados();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ============================================================
  // DATA LOADING & FILTERING
  // ============================================================

  Future<void> _carregarDados() async {
    try {
      final results = await Future.wait([
        EntradaFinanceiraTable().queryRows(queryFn: (q) => q),
        SaidaFinanceiraTable().queryRows(queryFn: (q) => q),
        ViewFluxoFinanceiroProjetadoTable().queryRows(queryFn: (q) => q),
      ]);

      final entradas = results[0] as List<EntradaFinanceiraRow>;
      final saidas = results[1] as List<SaidaFinanceiraRow>;
      final fluxo = results[2] as List<ViewFluxoFinanceiroProjetadoRow>;

      final categorias = saidas
          .map((s) => s.categoria)
          .where((c) => c != null && c!.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList()
        ..sort();

      setState(() {
        _entradas = entradas;
        _saidas = saidas;
        _fluxoProjetado = fluxo;
        _categoriasDisponiveis = categorias;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  DateTime _getDataInicio() {
    if (_usandoPeriodoCustom && _dataInicioCustom != null) {
      return _dataInicioCustom!;
    }
    final agora = DateTime.now();
    return DateTime(agora.year, agora.month - _periodoMeses + 1, 1);
  }

  DateTime _getDataFim() {
    if (_usandoPeriodoCustom && _dataFimCustom != null) {
      return _dataFimCustom!;
    }
    return DateTime.now();
  }

  List<EntradaFinanceiraRow> _getEntradasFiltradas() {
    final inicio = _getDataInicio();
    final fim = _getDataFim();
    return _entradas.where((e) {
      if (e.dataEntrada == null) return false;
      final data = e.dataEntrada!;
      if (data.isBefore(inicio) || data.isAfter(fim)) return false;
      if (_filtroTipoEntrada != null) {
        final tipo = e.tipoEntrada?.toLowerCase() ?? '';
        if (_filtroTipoEntrada == 'Dízimo') {
          if (!tipo.contains('dízimo') && !tipo.contains('dizimo')) {
            return false;
          }
        } else if (_filtroTipoEntrada == 'Oferta') {
          if (tipo.contains('dízimo') || tipo.contains('dizimo')) {
            return false;
          }
        }
      }
      return true;
    }).toList();
  }

  List<SaidaFinanceiraRow> _getSaidasFiltradas() {
    final inicio = _getDataInicio();
    final fim = _getDataFim();
    return _saidas.where((s) {
      if (s.dataSaida == null) return false;
      final data = s.dataSaida!;
      if (data.isBefore(inicio) || data.isAfter(fim)) return false;
      if (_filtroCategoriaSaida != null) {
        if (s.categoria != _filtroCategoriaSaida) return false;
      }
      return true;
    }).toList();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _formatarMoeda(double valor) {
    final isNegative = valor < 0;
    final absValor = valor.abs();
    final parts = absValor.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write('.');
      buffer.write(intPart[i]);
    }
    return '${isNegative ? '-' : ''}R\$ $buffer,$decPart';
  }

  String _formatarValorCurto(double valor) {
    if (valor >= 1000000) {
      return '${(valor / 1000000).toStringAsFixed(1)}M';
    } else if (valor >= 1000) {
      return '${(valor / 1000).toStringAsFixed(1)}K';
    }
    return valor.toStringAsFixed(0);
  }

  String _getNomeMes(int mes) {
    const meses = [
      '', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return meses[mes];
  }

  String _getNomeMesCompleto(int mes) {
    const meses = [
      '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return meses[mes];
  }

  // ============================================================
  // DATA COMPUTATION METHODS
  // ============================================================

  Map<String, double> _calcularKPIs() {
    final entradasFiltradas = _getEntradasFiltradas();
    final saidasFiltradas = _getSaidasFiltradas();

    final totalEntradas =
        entradasFiltradas.fold(0.0, (s, e) => s + (e.valorEntrada ?? 0.0));
    final totalSaidas =
        saidasFiltradas.fold(0.0, (s, e) => s + (e.valorDespesa ?? 0.0));
    final saldo = totalEntradas - totalSaidas;

    // Variação vs período anterior
    final inicio = _getDataInicio();
    final fim = _getDataFim();
    final duracao = fim.difference(inicio);
    final inicioAnterior = inicio.subtract(duracao);
    final fimAnterior = inicio.subtract(const Duration(days: 1));

    final entradasAnterior = _entradas.where((e) {
      if (e.dataEntrada == null) return false;
      return e.dataEntrada!.isAfter(inicioAnterior) &&
          e.dataEntrada!.isBefore(fimAnterior.add(const Duration(days: 1)));
    }).fold(0.0, (s, e) => s + (e.valorEntrada ?? 0.0));

    final saidasAnterior = _saidas.where((s) {
      if (s.dataSaida == null) return false;
      return s.dataSaida!.isAfter(inicioAnterior) &&
          s.dataSaida!.isBefore(fimAnterior.add(const Duration(days: 1)));
    }).fold(0.0, (s, e) => s + (e.valorDespesa ?? 0.0));

    final saldoAnterior = entradasAnterior - saidasAnterior;
    double variacao = 0.0;
    if (saldoAnterior.abs() > 0) {
      variacao = ((saldo - saldoAnterior) / saldoAnterior.abs()) * 100;
    } else if (saldo > 0) {
      variacao = 100.0;
    }

    return {
      'totalEntradas': totalEntradas,
      'totalSaidas': totalSaidas,
      'saldo': saldo,
      'variacao': variacao,
    };
  }

  Map<String, Map<String, double>> _getDadosMensais() {
    final agora = DateTime.now();
    final dados = <String, Map<String, double>>{};
    final entradasFiltradas = _getEntradasFiltradas();
    final saidasFiltradas = _getSaidasFiltradas();

    final mesesCount = _usandoPeriodoCustom
        ? ((_getDataFim().year - _getDataInicio().year) * 12 +
                _getDataFim().month -
                _getDataInicio().month +
                1)
            .clamp(1, 24)
        : _periodoMeses;

    final baseDate = _usandoPeriodoCustom ? _getDataInicio() : agora;

    for (var i = _usandoPeriodoCustom ? 0 : mesesCount - 1;
        _usandoPeriodoCustom ? i < mesesCount : i >= 0;
        _usandoPeriodoCustom ? i++ : i--) {
      final mes = _usandoPeriodoCustom
          ? DateTime(baseDate.year, baseDate.month + i, 1)
          : DateTime(agora.year, agora.month - i, 1);
      final chave =
          '${_getNomeMes(mes.month)}/${mes.year.toString().substring(2)}';
      dados[chave] = {'entradas': 0.0, 'saidas': 0.0};
    }

    for (var e in entradasFiltradas) {
      if (e.dataEntrada != null) {
        final mes = e.dataEntrada!;
        final chave =
            '${_getNomeMes(mes.month)}/${mes.year.toString().substring(2)}';
        if (dados.containsKey(chave)) {
          dados[chave]!['entradas'] =
              (dados[chave]!['entradas'] ?? 0.0) + (e.valorEntrada ?? 0.0);
        }
      }
    }

    for (var s in saidasFiltradas) {
      if (s.dataSaida != null) {
        final mes = s.dataSaida!;
        final chave =
            '${_getNomeMes(mes.month)}/${mes.year.toString().substring(2)}';
        if (dados.containsKey(chave)) {
          dados[chave]!['saidas'] =
              (dados[chave]!['saidas'] ?? 0.0) + (s.valorDespesa ?? 0.0);
        }
      }
    }

    return dados;
  }

  Map<String, double> _getDadosEntradasPorTipo() {
    final dados = <String, double>{'Dízimo': 0.0, 'Oferta': 0.0};
    final entradasFiltradas = _getEntradasFiltradas();

    for (var e in entradasFiltradas) {
      final tipo = e.tipoEntrada?.toLowerCase() ?? '';
      if (tipo.contains('dízimo') || tipo.contains('dizimo')) {
        dados['Dízimo'] = (dados['Dízimo'] ?? 0.0) + (e.valorEntrada ?? 0.0);
      } else {
        dados['Oferta'] = (dados['Oferta'] ?? 0.0) + (e.valorEntrada ?? 0.0);
      }
    }

    return dados;
  }

  Map<String, double> _getDadosSaidasPorCategoria() {
    final dados = <String, double>{};
    final saidasFiltradas = _getSaidasFiltradas();

    for (var s in saidasFiltradas) {
      final categoria = s.categoria ?? 'Outros';
      dados[categoria] = (dados[categoria] ?? 0.0) + (s.valorDespesa ?? 0.0);
    }

    return dados;
  }

  List<MapEntry<String, double>> _getTopCategorias() {
    final dados = _getDadosSaidasPorCategoria();
    final sorted = dados.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(8).toList();
  }

  Map<String, double> _calcularComparacaoMensal() {
    final agora = DateTime.now();
    final inicioMesAtual = DateTime(agora.year, agora.month, 1);
    final fimMesAtual = DateTime(agora.year, agora.month + 1, 0, 23, 59, 59);
    final inicioMesAnterior = DateTime(agora.year, agora.month - 1, 1);
    final fimMesAnterior = DateTime(agora.year, agora.month, 0, 23, 59, 59);

    double entradasAtual = 0, entradasAnterior = 0;
    double saidasAtual = 0, saidasAnterior = 0;

    for (var e in _entradas) {
      if (e.dataEntrada == null) continue;
      final d = e.dataEntrada!;
      if (!d.isBefore(inicioMesAtual) && !d.isAfter(fimMesAtual)) {
        entradasAtual += e.valorEntrada ?? 0.0;
      } else if (!d.isBefore(inicioMesAnterior) && !d.isAfter(fimMesAnterior)) {
        entradasAnterior += e.valorEntrada ?? 0.0;
      }
    }

    for (var s in _saidas) {
      if (s.dataSaida == null) continue;
      final d = s.dataSaida!;
      if (!d.isBefore(inicioMesAtual) && !d.isAfter(fimMesAtual)) {
        saidasAtual += s.valorDespesa ?? 0.0;
      } else if (!d.isBefore(inicioMesAnterior) && !d.isAfter(fimMesAnterior)) {
        saidasAnterior += s.valorDespesa ?? 0.0;
      }
    }

    double varEntradas = entradasAnterior > 0
        ? ((entradasAtual - entradasAnterior) / entradasAnterior) * 100
        : (entradasAtual > 0 ? 100.0 : 0.0);
    double varSaidas = saidasAnterior > 0
        ? ((saidasAtual - saidasAnterior) / saidasAnterior) * 100
        : (saidasAtual > 0 ? 100.0 : 0.0);
    final saldoAtual = entradasAtual - saidasAtual;
    final saldoAnterior = entradasAnterior - saidasAnterior;
    double varSaldo = saldoAnterior.abs() > 0
        ? ((saldoAtual - saldoAnterior) / saldoAnterior.abs()) * 100
        : (saldoAtual > 0 ? 100.0 : 0.0);

    return {
      'entradasAtual': entradasAtual,
      'entradasAnterior': entradasAnterior,
      'varEntradas': varEntradas,
      'saidasAtual': saidasAtual,
      'saidasAnterior': saidasAnterior,
      'varSaidas': varSaidas,
      'saldoAtual': saldoAtual,
      'saldoAnterior': saldoAnterior,
      'varSaldo': varSaldo,
    };
  }

  // ============================================================
  // BUILD
  // ============================================================

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
          decoration: BoxDecoration(color: Color(0xFF14181B)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (responsiveVisibility(
                context: context,
                phone: false,
                tablet: false,
                tabletLandscape: false,
              ))
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 0.0, 16.0),
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
                                _buildKPICards(),
                                SizedBox(height: 24.0),
                                _buildFiltrosAvancados(),
                                SizedBox(height: 24.0),
                                _buildGraficoBarras(),
                                SizedBox(height: 24.0),
                                _buildGraficoEvolucaoSaldo(),
                                SizedBox(height: 24.0),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    if (constraints.maxWidth > 900) {
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child:
                                                  _buildGraficoPizzaEntradas()),
                                          SizedBox(width: 24.0),
                                          Expanded(
                                              child:
                                                  _buildGraficoPizzaSaidas()),
                                        ],
                                      );
                                    }
                                    return Column(
                                      children: [
                                        _buildGraficoPizzaEntradas(),
                                        SizedBox(height: 24.0),
                                        _buildGraficoPizzaSaidas(),
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(height: 24.0),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    if (constraints.maxWidth > 900) {
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              flex: 3,
                                              child:
                                                  _buildTopCategoriasLista()),
                                          SizedBox(width: 24.0),
                                          Expanded(
                                              flex: 2,
                                              child:
                                                  _buildComparacaoMensal()),
                                        ],
                                      );
                                    }
                                    return Column(
                                      children: [
                                        _buildTopCategoriasLista(),
                                        SizedBox(height: 24.0),
                                        _buildComparacaoMensal(),
                                      ],
                                    );
                                  },
                                ),
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

  // ============================================================
  // SECTION 0: HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Financeiro',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              'Visualize e analise os dados financeiros da igreja',
              style: GoogleFonts.inter(
                color: Color(0xFF999999),
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // SECTION 1: KPI CARDS
  // ============================================================

  Widget _buildKPICards() {
    final kpis = _calcularKPIs();
    final totalEntradas = kpis['totalEntradas']!;
    final totalSaidas = kpis['totalSaidas']!;
    final saldo = kpis['saldo']!;
    final variacao = kpis['variacao']!;

    final cards = [
      _buildKPICard(
        icon: Icons.trending_up_rounded,
        titulo: 'Total Entradas',
        valor: _formatarMoeda(totalEntradas),
        cor: Color(0xFF4CAF50),
      ),
      _buildKPICard(
        icon: Icons.trending_down_rounded,
        titulo: 'Total Saídas',
        valor: _formatarMoeda(totalSaidas),
        cor: Color(0xFFE53935),
      ),
      _buildKPICard(
        icon: Icons.account_balance_wallet_rounded,
        titulo: 'Saldo',
        valor: _formatarMoeda(saldo),
        cor: saldo >= 0 ? Color(0xFF4CAF50) : Color(0xFFE53935),
      ),
      _buildKPICard(
        icon: variacao >= 0
            ? Icons.arrow_upward_rounded
            : Icons.arrow_downward_rounded,
        titulo: 'Variação vs Anterior',
        valor:
            '${variacao >= 0 ? '+' : ''}${variacao.toStringAsFixed(1)}%',
        cor: variacao >= 0 ? Color(0xFF4CAF50) : Color(0xFFE53935),
        subtitulo: 'vs período anterior',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            children: cards
                .map((card) => Expanded(child: card))
                .toList()
                .asMap()
                .entries
                .expand((entry) => [
                      if (entry.key > 0) SizedBox(width: 16.0),
                      entry.value,
                    ])
                .toList(),
          );
        }
        return Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: cards
              .map((card) => SizedBox(
                    width: (constraints.maxWidth - 16) / 2,
                    child: card,
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildKPICard({
    required IconData icon,
    required String titulo,
    required String valor,
    required Color cor,
    String? subtitulo,
  }) {
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color(0xFF404040)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(icon, color: cor, size: 24.0),
          ),
          SizedBox(height: 16.0),
          Text(
            valor,
            style: GoogleFonts.poppins(
              color: cor,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.0),
          Text(
            titulo,
            style: GoogleFonts.inter(
              color: Color(0xFF999999),
              fontSize: 14.0,
            ),
          ),
          if (subtitulo != null) ...[
            SizedBox(height: 4.0),
            Text(
              subtitulo,
              style: GoogleFonts.inter(
                color: cor.withOpacity(0.7),
                fontSize: 12.0,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // SECTION 2: FILTROS AVANÇADOS
  // ============================================================

  Widget _buildFiltrosAvancados() {
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color(0xFF404040)),
      ),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 12.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Período
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Período:',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 12.0),
              _buildFilterChip(
                '3 meses',
                !_usandoPeriodoCustom && _periodoMeses == 3,
                () => setState(() {
                  _usandoPeriodoCustom = false;
                  _periodoMeses = 3;
                }),
              ),
              SizedBox(width: 8.0),
              _buildFilterChip(
                '6 meses',
                !_usandoPeriodoCustom && _periodoMeses == 6,
                () => setState(() {
                  _usandoPeriodoCustom = false;
                  _periodoMeses = 6;
                }),
              ),
              SizedBox(width: 8.0),
              _buildFilterChip(
                '12 meses',
                !_usandoPeriodoCustom && _periodoMeses == 12,
                () => setState(() {
                  _usandoPeriodoCustom = false;
                  _periodoMeses = 12;
                }),
              ),
              SizedBox(width: 8.0),
              _buildFilterChip(
                _usandoPeriodoCustom && _dataInicioCustom != null
                    ? '${_dataInicioCustom!.day}/${_dataInicioCustom!.month} - ${_dataFimCustom!.day}/${_dataFimCustom!.month}'
                    : 'Personalizado',
                _usandoPeriodoCustom,
                () async {
                  final result = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDateRange: _dataInicioCustom != null
                        ? DateTimeRange(
                            start: _dataInicioCustom!,
                            end: _dataFimCustom ?? DateTime.now())
                        : null,
                    builder: (context, child) => Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: FlutterFlowTheme.of(context).primary,
                          surface: Color(0xFF2A2A2A),
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _usandoPeriodoCustom = true;
                      _dataInicioCustom = result.start;
                      _dataFimCustom = result.end;
                    });
                  }
                },
              ),
            ],
          ),
          // Tipo Entrada
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tipo:',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 12.0),
              _buildFilterChip(
                'Todas',
                _filtroTipoEntrada == null,
                () => setState(() => _filtroTipoEntrada = null),
              ),
              SizedBox(width: 8.0),
              _buildFilterChip(
                'Dízimo',
                _filtroTipoEntrada == 'Dízimo',
                () => setState(() => _filtroTipoEntrada = 'Dízimo'),
              ),
              SizedBox(width: 8.0),
              _buildFilterChip(
                'Oferta',
                _filtroTipoEntrada == 'Oferta',
                () => setState(() => _filtroTipoEntrada = 'Oferta'),
              ),
            ],
          ),
          // Categoria Saída
          if (_categoriasDisponiveis.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Categoria:',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 12.0),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _filtroCategoriaSaida,
                      dropdownColor: Color(0xFF2D2D2D),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14.0,
                      ),
                      hint: Text(
                        'Todas',
                        style: GoogleFonts.inter(
                          color: Color(0xFF999999),
                          fontSize: 14.0,
                        ),
                      ),
                      icon: Icon(Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF999999)),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Todas'),
                        ),
                        ..._categoriasDisponiveis.map((cat) =>
                            DropdownMenuItem<String?>(
                              value: cat,
                              child: Text(cat),
                            )),
                      ],
                      onChanged: (value) =>
                          setState(() => _filtroCategoriaSaida = value),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? FlutterFlowTheme.of(context).primary
              : Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected
                ? FlutterFlowTheme.of(context).primary
                : Color(0xFF404040),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : Color(0xFF999999),
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION 3: GRÁFICO DE BARRAS APRIMORADO
  // ============================================================

  Widget _buildGraficoBarras() {
    final dados = _getDadosMensais();
    final labels = dados.keys.toList();
    final entradasValues =
        labels.map((l) => dados[l]!['entradas']!).toList();
    final saidasValues = labels.map((l) => dados[l]!['saidas']!).toList();

    double maxValue = 0;
    for (var v in entradasValues) {
      if (v > maxValue) maxValue = v;
    }
    for (var v in saidasValues) {
      if (v > maxValue) maxValue = v;
    }
    if (maxValue == 0) maxValue = 1000;

    return Container(
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color(0xFF404040)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Entradas vs Saídas',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  _buildLegendItem('Entradas', Color(0xFF4CAF50)),
                  SizedBox(width: 16.0),
                  _buildLegendItem('Saídas', Color(0xFFE53935)),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.0),
          SizedBox(
            height: 300.0,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBorderRadius: BorderRadius.circular(8),
                    tooltipPadding: EdgeInsets.all(12),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (rodIndex != 0) return null;
                      final e = entradasValues[groupIndex];
                      final s = saidasValues[groupIndex];
                      final saldo = e - s;
                      return BarTooltipItem(
                        '${labels[groupIndex]}\n',
                        GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(
                            text: 'Entradas: ${_formatarMoeda(e)}\n',
                            style: GoogleFonts.inter(
                              color: Color(0xFF4CAF50),
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: 'Saídas: ${_formatarMoeda(s)}\n',
                            style: GoogleFonts.inter(
                              color: Color(0xFFE53935),
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: 'Saldo: ${_formatarMoeda(saldo)}',
                            style: GoogleFonts.inter(
                              color: Color(0xFF42A5F5),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              labels[index],
                              style: GoogleFonts.inter(
                                color: Color(0xFF999999),
                                fontSize: 11.0,
                              ),
                            ),
                          );
                        }
                        return Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: maxValue > 0 ? maxValue / 4 : 250,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Text(
                            _formatarValorCurto(value),
                            style: GoogleFonts.inter(
                              color: Color(0xFF999999),
                              fontSize: 11.0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue > 0 ? maxValue / 4 : 250,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Color(0xFF404040),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(labels.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: entradasValues[index],
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color(0xFF2E7D32),
                            Color(0xFF66BB6A),
                          ],
                        ),
                        width: 14,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                      BarChartRodData(
                        toY: saidasValues[index],
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color(0xFFC62828),
                            Color(0xFFEF5350),
                          ],
                        ),
                        width: 14,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }),
              ),
              duration: Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Color(0xFF999999),
            fontSize: 12.0,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION 4: EVOLUÇÃO DO SALDO COM PROJEÇÃO
  // ============================================================

  Widget _buildGraficoEvolucaoSaldo() {
    // Tenta usar ViewFluxoFinanceiroProjetado
    if (_fluxoProjetado.isEmpty) {
      return _buildGraficoEvolucaoSaldoFallback();
    }

    // Ordena por mes_ano
    final dadosOrdenados = List<ViewFluxoFinanceiroProjetadoRow>.from(
        _fluxoProjetado)
      ..sort((a, b) => (a.mesAno ?? '').compareTo(b.mesAno ?? ''));

    final spotsRealizados = <FlSpot>[];
    final spotsProjetados = <FlSpot>[];
    final labels = <String>[];
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (var i = 0; i < dadosOrdenados.length; i++) {
      final item = dadosOrdenados[i];
      final saldo = item.saldoMensal ?? 0.0;

      // Parse mes_ano (pode ser "YYYY-MM" ou "MM/YYYY")
      String labelMes = '';
      final mesAno = item.mesAno ?? '';
      if (mesAno.contains('-')) {
        final parts = mesAno.split('-');
        if (parts.length >= 2) {
          final mes = int.tryParse(parts[1]) ?? 1;
          final ano = parts[0].length >= 4 ? parts[0].substring(2) : parts[0];
          labelMes = '${_getNomeMes(mes)}/$ano';
        }
      } else if (mesAno.contains('/')) {
        final parts = mesAno.split('/');
        if (parts.length >= 2) {
          final mes = int.tryParse(parts[0]) ?? 1;
          final ano = parts[1].length >= 4 ? parts[1].substring(2) : parts[1];
          labelMes = '${_getNomeMes(mes)}/$ano';
        }
      } else {
        labelMes = mesAno;
      }

      labels.add(labelMes);
      if (saldo < minY) minY = saldo;
      if (saldo > maxY) maxY = saldo;

      final spot = FlSpot(i.toDouble(), saldo);
      if (item.isProjection == true) {
        if (spotsProjetados.isEmpty && spotsRealizados.isNotEmpty) {
          // Conecta as linhas: último ponto real também no projetado
          spotsProjetados.add(spotsRealizados.last);
        }
        spotsProjetados.add(spot);
      } else {
        spotsRealizados.add(spot);
      }
    }

    if (spotsRealizados.isEmpty && spotsProjetados.isEmpty) {
      return _buildGraficoEvolucaoSaldoFallback();
    }

    if (minY == maxY) {
      minY -= 100;
      maxY += 100;
    }
    final range = maxY - minY;
    minY -= range * 0.1;
    maxY += range * 0.1;

    return Container(
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color(0xFF404040)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Evolução do Saldo',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  _buildLegendItem('Realizado', Color(0xFF42A5F5)),
                  SizedBox(width: 16.0),
                  _buildLegendItemDashed('Projetado', Color(0xFFFFB74D)),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.0),
          SizedBox(
            height: 300.0,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  if (spotsRealizados.isNotEmpty)
                    LineChartBarData(
                      spots: spotsRealizados,
                      color: Color(0xFF42A5F5),
                      barWidth: 3,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: Color(0xFF42A5F5),
                          strokeWidth: 2,
                          strokeColor: Color(0xFF2A2A2A),
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF42A5F5).withOpacity(0.3),
                            Color(0xFF42A5F5).withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  if (spotsProjetados.isNotEmpty)
                    LineChartBarData(
                      spots: spotsProjetados,
                      color: Color(0xFFFFB74D),
                      barWidth: 2,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      dashArray: [8, 4],
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: Color(0xFFFFB74D),
                          strokeWidth: 2,
                          strokeColor: Color(0xFF2A2A2A),
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFFB74D).withOpacity(0.15),
                            Color(0xFFFFB74D).withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < labels.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              labels[idx],
                              style: GoogleFonts.inter(
                                color: Color(0xFF999999),
                                fontSize: 11.0,
                              ),
                            ),
                          );
                        }
                        return Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Text(
                            _formatarValorCurto(value),
                            style: GoogleFonts.inter(
                              color: Color(0xFF999999),
                              fontSize: 11.0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Color(0xFF404040),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBorderRadius: BorderRadius.circular(8),
                    tooltipPadding: EdgeInsets.all(12),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final isProjected = spot.barIndex == 1;
                        final idx = spot.x.toInt();
                        final label =
                            idx >= 0 && idx < labels.length
                                ? labels[idx]
                                : '';
                        return LineTooltipItem(
                          '$label\n${_formatarMoeda(spot.y)}${isProjected ? ' (projetado)' : ''}',
                          GoogleFonts.inter(
                            color: isProjected
                                ? Color(0xFFFFB74D)
                                : Color(0xFF42A5F5),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
              duration: Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoEvolucaoSaldoFallback() {
    // Fallback: computa saldo a partir dos dados brutos de entradas/saídas
    final agora = DateTime.now();
    final mesesCount = _usandoPeriodoCustom
        ? ((_getDataFim().year - _getDataInicio().year) * 12 +
                _getDataFim().month -
                _getDataInicio().month +
                1)
            .clamp(1, 24)
        : _periodoMeses;

    final spots = <FlSpot>[];
    final labels = <String>[];
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (var i = mesesCount - 1; i >= 0; i--) {
      final mes = DateTime(agora.year, agora.month - i, 1);
      final label =
          '${_getNomeMes(mes.month)}/${mes.year.toString().substring(2)}';
      labels.add(label);

      double entradas = 0, saidas = 0;
      for (var e in _entradas) {
        if (e.dataEntrada != null &&
            e.dataEntrada!.year == mes.year &&
            e.dataEntrada!.month == mes.month) {
          entradas += e.valorEntrada ?? 0.0;
        }
      }
      for (var s in _saidas) {
        if (s.dataSaida != null &&
            s.dataSaida!.year == mes.year &&
            s.dataSaida!.month == mes.month) {
          saidas += s.valorDespesa ?? 0.0;
        }
      }

      final saldo = entradas - saidas;
      spots.add(FlSpot((mesesCount - 1 - i).toDouble(), saldo));
      if (saldo < minY) minY = saldo;
      if (saldo > maxY) maxY = saldo;
    }

    if (spots.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Color(0xFF404040)),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(48.0),
            child: Column(
              children: [
                Icon(Icons.show_chart_rounded,
                    color: Color(0xFF666666), size: 64.0),
                SizedBox(height: 16.0),
                Text(
                  'Sem dados para exibir a evolução do saldo',
                  style: GoogleFonts.inter(
                      color: Color(0xFF999999), fontSize: 16.0),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (minY == maxY) {
      minY -= 100;
      maxY += 100;
    }
    final range = maxY - minY;
    minY -= range * 0.1;
    maxY += range * 0.1;

    return Container(
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color(0xFF404040)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Evolução do Saldo',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _buildLegendItem('Saldo Mensal', Color(0xFF42A5F5)),
            ],
          ),
          SizedBox(height: 24.0),
          SizedBox(
            height: 300.0,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    color: Color(0xFF42A5F5),
                    barWidth: 3,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: Color(0xFF42A5F5),
                        strokeWidth: 2,
                        strokeColor: Color(0xFF2A2A2A),
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF42A5F5).withOpacity(0.3),
                          Color(0xFF42A5F5).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < labels.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              labels[idx],
                              style: GoogleFonts.inter(
                                color: Color(0xFF999999),
                                fontSize: 11.0,
                              ),
                            ),
                          );
                        }
                        return Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Text(
                            _formatarValorCurto(value),
                            style: GoogleFonts.inter(
                              color: Color(0xFF999999),
                              fontSize: 11.0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Color(0xFF404040),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBorderRadius: BorderRadius.circular(8),
                    tooltipPadding: EdgeInsets.all(12),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final idx = spot.x.toInt();
                        final label =
                            idx >= 0 && idx < labels.length
                                ? labels[idx]
                                : '';
                        return LineTooltipItem(
                          '$label\n${_formatarMoeda(spot.y)}',
                          GoogleFonts.inter(
                            color: Color(0xFF42A5F5),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
              duration: Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItemDashed(String label, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 12,
          height: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 3, height: 3, color: color),
              Container(width: 3, height: 3, color: color),
              Container(width: 3, height: 3, color: color),
            ],
          ),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Color(0xFF999999),
            fontSize: 12.0,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SECTION 5: PIE CHARTS APRIMORADOS
  // ============================================================

  Widget _buildGraficoPizzaEntradas() {
    final dados = _getDadosEntradasPorTipo();
    final total = dados.values.fold(0.0, (sum, v) => sum + v);
    final colors = [Color(0xFF4CAF50), Color(0xFF9C27B0)];

    return Container(
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color(0xFF404040)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entradas por Tipo',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 24.0),
          SizedBox(
            height: 220.0,
            child: total > 0
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  _touchedIndexEntradas = -1;
                                  return;
                                }
                                _touchedIndexEntradas = pieTouchResponse
                                    .touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          sectionsSpace: 2,
                          centerSpaceRadius: 50,
                          sections: dados.entries
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final percentage = (item.value / total) * 100;
                            final isTouched =
                                index == _touchedIndexEntradas;
                            return PieChartSectionData(
                              color: colors[index % colors.length],
                              value: item.value,
                              title: isTouched
                                  ? '${item.key}\n${_formatarMoeda(item.value)}\n${percentage.toStringAsFixed(1)}%'
                                  : '${percentage.toStringAsFixed(1)}%',
                              radius: isTouched ? 75 : 60,
                              titleStyle: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: isTouched ? 12.0 : 11.0,
                                fontWeight: isTouched
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              titlePositionPercentageOffset: 0.55,
                            );
                          }).toList(),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.inter(
                              color: Color(0xFF999999),
                              fontSize: 12.0,
                            ),
                          ),
                          Text(
                            _formatarMoeda(total),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pie_chart_outline_rounded,
                            color: Color(0xFF666666), size: 48.0),
                        SizedBox(height: 12.0),
                        Text(
                          'Sem dados no período',
                          style: GoogleFonts.inter(
                              color: Color(0xFF999999), fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
          ),
          SizedBox(height: 24.0),
          ...dados.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final percentage =
                total > 0 ? (item.value / total * 100) : 0.0;
            return Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.key,
                      style: GoogleFonts.inter(
                          color: Colors.white, fontSize: 14.0),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors[index % colors.length].withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(
                        color: colors[index % colors.length],
                        fontSize: 11,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    _formatarMoeda(item.value),
                    style: GoogleFonts.poppins(
                      color: colors[index % colors.length],
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGraficoPizzaSaidas() {
    final dados = _getDadosSaidasPorCategoria();
    final total = dados.values.fold(0.0, (sum, v) => sum + v);
    final colorsPie = [
      Color(0xFFE53935),
      Color(0xFF42A5F5),
      Color(0xFFFFB74D),
      Color(0xFFAB47BC),
      Color(0xFF26C6DA),
      Color(0xFF66BB6A),
      Color(0xFFFF7043),
      Color(0xFF78909C),
      Color(0xFFD4E157),
    ];

    return Container(
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color(0xFF404040)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saídas por Categoria',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 24.0),
          SizedBox(
            height: 220.0,
            child: total > 0
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  _touchedIndexSaidas = -1;
                                  return;
                                }
                                _touchedIndexSaidas = pieTouchResponse
                                    .touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          sectionsSpace: 2,
                          centerSpaceRadius: 50,
                          sections: dados.entries
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final percentage = (item.value / total) * 100;
                            final isTouched =
                                index == _touchedIndexSaidas;
                            return PieChartSectionData(
                              color:
                                  colorsPie[index % colorsPie.length],
                              value: item.value,
                              title: isTouched
                                  ? '${item.key}\n${_formatarMoeda(item.value)}\n${percentage.toStringAsFixed(1)}%'
                                  : (percentage >= 5
                                      ? '${percentage.toStringAsFixed(0)}%'
                                      : ''),
                              radius: isTouched ? 75 : 60,
                              titleStyle: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: isTouched ? 11.0 : 11.0,
                                fontWeight: isTouched
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              titlePositionPercentageOffset: 0.55,
                            );
                          }).toList(),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.inter(
                              color: Color(0xFF999999),
                              fontSize: 12.0,
                            ),
                          ),
                          Text(
                            _formatarMoeda(total),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pie_chart_outline_rounded,
                            color: Color(0xFF666666), size: 48.0),
                        SizedBox(height: 12.0),
                        Text(
                          'Sem dados no período',
                          style: GoogleFonts.inter(
                              color: Color(0xFF999999), fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
          ),
          SizedBox(height: 24.0),
          ...dados.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final percentage =
                total > 0 ? (item.value / total * 100) : 0.0;
            return Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colorsPie[index % colorsPie.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.key,
                      style: GoogleFonts.inter(
                          color: Colors.white, fontSize: 14.0),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorsPie[index % colorsPie.length]
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(
                        color: colorsPie[index % colorsPie.length],
                        fontSize: 11,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    _formatarMoeda(item.value),
                    style: GoogleFonts.poppins(
                      color: colorsPie[index % colorsPie.length],
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION 6: TOP CATEGORIAS DE SAÍDA
  // ============================================================

  Widget _buildTopCategoriasLista() {
    final categorias = _getTopCategorias();
    final maxValor =
        categorias.isNotEmpty ? categorias.first.value : 1.0;
    final totalGeral = categorias.fold(0.0, (s, e) => s + e.value);

    return Container(
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color(0xFF404040)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Color(0xFFE53935).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(Icons.category_rounded,
                    color: Color(0xFFE53935), size: 24.0),
              ),
              SizedBox(width: 16.0),
              Text(
                'Top Categorias de Saída',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.0),
          if (categorias.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(48.0),
                child: Column(
                  children: [
                    Icon(Icons.inbox_rounded,
                        color: Color(0xFF666666), size: 64.0),
                    SizedBox(height: 16.0),
                    Text(
                      'Sem dados no período',
                      style: GoogleFonts.inter(
                          color: Color(0xFF999999), fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            )
          else
            ...categorias.asMap().entries.map((entry) {
              final index = entry.key;
              final cat = entry.value;
              final percent =
                  totalGeral > 0 ? (cat.value / totalGeral * 100) : 0.0;
              final barFraction = maxValor > 0 ? cat.value / maxValor : 0.0;

              return Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: GoogleFonts.inter(
                                    color: Color(0xFF999999),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              cat.key,
                              style: GoogleFonts.inter(
                                  color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              _formatarMoeda(cat.value),
                              style: GoogleFonts.poppins(
                                color: Color(0xFFE53935),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Color(0xFFE53935).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${percent.toStringAsFixed(1)}%',
                                style: GoogleFonts.inter(
                                  color: Color(0xFFE53935),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: barFraction,
                        minHeight: 6,
                        backgroundColor: Color(0xFF1E1E1E),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFE53935).withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION 7: COMPARAÇÃO MENSAL
  // ============================================================

  Widget _buildComparacaoMensal() {
    final comp = _calcularComparacaoMensal();
    final agora = DateTime.now();
    final nomeMesAtual = _getNomeMesCompleto(agora.month);
    final mesAnterior = agora.month == 1 ? 12 : agora.month - 1;
    final nomeMesAnterior = _getNomeMesCompleto(mesAnterior);

    return Container(
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color(0xFF404040)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Color(0xFF42A5F5).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(Icons.compare_arrows_rounded,
                    color: Color(0xFF42A5F5), size: 24.0),
              ),
              SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comparação Mensal',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$nomeMesAtual vs $nomeMesAnterior',
                    style: GoogleFonts.inter(
                      color: Color(0xFF999999),
                      fontSize: 13.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.0),
          _buildComparacaoItem(
            titulo: 'Entradas',
            valorAtual: comp['entradasAtual']!,
            valorAnterior: comp['entradasAnterior']!,
            variacao: comp['varEntradas']!,
            corBase: Color(0xFF4CAF50),
            invertido: false,
          ),
          SizedBox(height: 16.0),
          _buildComparacaoItem(
            titulo: 'Saídas',
            valorAtual: comp['saidasAtual']!,
            valorAnterior: comp['saidasAnterior']!,
            variacao: comp['varSaidas']!,
            corBase: Color(0xFFE53935),
            invertido: true,
          ),
          SizedBox(height: 16.0),
          Divider(color: Color(0xFF404040)),
          SizedBox(height: 16.0),
          _buildComparacaoItem(
            titulo: 'Saldo',
            valorAtual: comp['saldoAtual']!,
            valorAnterior: comp['saldoAnterior']!,
            variacao: comp['varSaldo']!,
            corBase: Color(0xFF42A5F5),
            invertido: false,
          ),
        ],
      ),
    );
  }

  Widget _buildComparacaoItem({
    required String titulo,
    required double valorAtual,
    required double valorAnterior,
    required double variacao,
    required Color corBase,
    required bool invertido,
  }) {
    final isPositiveChange = variacao >= 0;
    final isGood = invertido ? !isPositiveChange : isPositiveChange;
    final arrowColor = isGood ? Color(0xFF4CAF50) : Color(0xFFE53935);
    final arrowIcon = isPositiveChange
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              titulo,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: arrowColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(arrowIcon, color: arrowColor, size: 16),
                  SizedBox(width: 4),
                  Text(
                    '${isPositiveChange ? '+' : ''}${variacao.toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(
                      color: arrowColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Atual: ${_formatarMoeda(valorAtual)}',
              style: GoogleFonts.inter(
                color: corBase,
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Anterior: ${_formatarMoeda(valorAnterior)}',
              style: GoogleFonts.inter(
                color: Color(0xFF999999),
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
