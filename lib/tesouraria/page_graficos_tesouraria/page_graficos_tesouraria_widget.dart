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
  State<PageGraficosTesourariaWidget> createState() => _PageGraficosTesourariaWidgetState();
}

class _PageGraficosTesourariaWidgetState extends State<PageGraficosTesourariaWidget> {
  late PageGraficosTesourariaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<EntradaFinanceiraRow> _entradas = [];
  List<SaidaFinanceiraRow> _saidas = [];
  bool _isLoading = true;
  int _periodoMeses = 6;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageGraficosTesourariaModel());
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

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _getNomeMes(int mes) {
    const meses = ['', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return meses[mes];
  }

  // Dados para o gráfico de barras (Entradas vs Saídas por mês)
  Map<String, Map<String, double>> _getDadosMensais() {
    final agora = DateTime.now();
    final dados = <String, Map<String, double>>{};

    for (var i = _periodoMeses - 1; i >= 0; i--) {
      final mes = DateTime(agora.year, agora.month - i, 1);
      final chave = '${_getNomeMes(mes.month)}/${mes.year.toString().substring(2)}';
      dados[chave] = {'entradas': 0.0, 'saidas': 0.0};
    }

    for (var e in _entradas) {
      if (e.dataEntrada != null) {
        final diffMeses = (agora.year - e.dataEntrada!.year) * 12 + (agora.month - e.dataEntrada!.month);
        if (diffMeses >= 0 && diffMeses < _periodoMeses) {
          final mes = e.dataEntrada!;
          final chave = '${_getNomeMes(mes.month)}/${mes.year.toString().substring(2)}';
          if (dados.containsKey(chave)) {
            dados[chave]!['entradas'] = (dados[chave]!['entradas'] ?? 0.0) + (e.valorEntrada ?? 0.0);
          }
        }
      }
    }

    for (var s in _saidas) {
      if (s.dataSaida != null) {
        final diffMeses = (agora.year - s.dataSaida!.year) * 12 + (agora.month - s.dataSaida!.month);
        if (diffMeses >= 0 && diffMeses < _periodoMeses) {
          final mes = s.dataSaida!;
          final chave = '${_getNomeMes(mes.month)}/${mes.year.toString().substring(2)}';
          if (dados.containsKey(chave)) {
            dados[chave]!['saidas'] = (dados[chave]!['saidas'] ?? 0.0) + (s.valorDespesa ?? 0.0);
          }
        }
      }
    }

    return dados;
  }

  // Dados para o gráfico de pizza de entradas
  Map<String, double> _getDadosEntradasPorTipo() {
    final dados = <String, double>{'Dízimo': 0.0, 'Oferta': 0.0};
    final agora = DateTime.now();

    for (var e in _entradas) {
      if (e.dataEntrada != null) {
        final diffMeses = (agora.year - e.dataEntrada!.year) * 12 + (agora.month - e.dataEntrada!.month);
        if (diffMeses >= 0 && diffMeses < _periodoMeses) {
          final tipo = e.tipoEntrada?.toLowerCase() ?? '';
          if (tipo.contains('dízimo') || tipo.contains('dizimo')) {
            dados['Dízimo'] = (dados['Dízimo'] ?? 0.0) + (e.valorEntrada ?? 0.0);
          } else {
            dados['Oferta'] = (dados['Oferta'] ?? 0.0) + (e.valorEntrada ?? 0.0);
          }
        }
      }
    }

    return dados;
  }

  // Dados para o gráfico de pizza de saídas por categoria
  Map<String, double> _getDadosSaidasPorCategoria() {
    final dados = <String, double>{};
    final agora = DateTime.now();

    for (var s in _saidas) {
      if (s.dataSaida != null) {
        final diffMeses = (agora.year - s.dataSaida!.year) * 12 + (agora.month - s.dataSaida!.month);
        if (diffMeses >= 0 && diffMeses < _periodoMeses) {
          final categoria = s.categoria ?? 'Outros';
          dados[categoria] = (dados[categoria] ?? 0.0) + (s.valorDespesa ?? 0.0);
        }
      }
    }

    return dados;
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
                                _buildFiltroPeriodo(),
                                SizedBox(height: 24.0),
                                _buildGraficoBarras(),
                                SizedBox(height: 24.0),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildGraficoPizzaEntradas()),
                                    SizedBox(width: 24.0),
                                    Expanded(child: _buildGraficoPizzaSaidas()),
                                  ],
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gráficos',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.0),
        Text(
          'Visualize os dados financeiros em gráficos',
          style: GoogleFonts.inter(
            color: Color(0xFF999999),
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  Widget _buildFiltroPeriodo() {
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
          _buildPeriodoChip(3, '3 meses'),
          SizedBox(width: 8.0),
          _buildPeriodoChip(6, '6 meses'),
          SizedBox(width: 8.0),
          _buildPeriodoChip(12, '12 meses'),
        ],
      ),
    );
  }

  Widget _buildPeriodoChip(int meses, String label) {
    final isSelected = _periodoMeses == meses;
    return InkWell(
      onTap: () => setState(() => _periodoMeses = meses),
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? FlutterFlowTheme.of(context).primary : Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : Color(0xFF999999),
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildGraficoBarras() {
    final dados = _getDadosMensais();
    final labels = dados.keys.toList();
    final entradasValues = labels.map((l) => dados[l]!['entradas']!).toList();
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
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = labels[groupIndex];
                      final value = rodIndex == 0 ? entradasValues[groupIndex] : saidasValues[groupIndex];
                      final tipo = rodIndex == 0 ? 'Entradas' : 'Saídas';
                      return BarTooltipItem(
                        '$label\n$tipo: ${_formatarMoeda(value)}',
                        GoogleFonts.inter(color: Colors.white, fontSize: 12.0),
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
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatarValorCurto(value),
                          style: GoogleFonts.inter(
                            color: Color(0xFF999999),
                            fontSize: 11.0,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Color(0xFF404040),
                      strokeWidth: 1,
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
                        color: Color(0xFF4CAF50),
                        width: 14,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: saidasValues[index],
                        color: Color(0xFFE53935),
                        width: 14,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatarValorCurto(double valor) {
    if (valor >= 1000000) {
      return '${(valor / 1000000).toStringAsFixed(1)}M';
    } else if (valor >= 1000) {
      return '${(valor / 1000).toStringAsFixed(1)}K';
    }
    return valor.toStringAsFixed(0);
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
            height: 200.0,
            child: total > 0
                ? PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: dados.entries.toList().asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final percentage = (item.value / total) * 100;
                        return PieChartSectionData(
                          color: colors[index % colors.length],
                          value: item.value,
                          title: '${percentage.toStringAsFixed(1)}%',
                          radius: 60,
                          titleStyle: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : Center(
                    child: Text(
                      'Sem dados no período',
                      style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 14.0),
                    ),
                  ),
          ),
          SizedBox(height: 24.0),
          ...dados.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
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
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                    ),
                  ),
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
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildGraficoPizzaSaidas() {
    final dados = _getDadosSaidasPorCategoria();
    final total = dados.values.fold(0.0, (sum, v) => sum + v);
    final colors = [
      Color(0xFFE53935),
      Color(0xFF2196F3),
      Color(0xFFFF9800),
      Color(0xFF9C27B0),
      Color(0xFF00BCD4),
      Color(0xFF4CAF50),
      Color(0xFFFF5722),
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
            height: 200.0,
            child: total > 0
                ? PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: dados.entries.toList().asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final percentage = (item.value / total) * 100;
                        return PieChartSectionData(
                          color: colors[index % colors.length],
                          value: item.value,
                          title: percentage >= 5 ? '${percentage.toStringAsFixed(0)}%' : '',
                          radius: 60,
                          titleStyle: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 11.0,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : Center(
                    child: Text(
                      'Sem dados no período',
                      style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 14.0),
                    ),
                  ),
          ),
          SizedBox(height: 24.0),
          ...dados.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
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
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
          }).toList(),
        ],
      ),
    );
  }
}
