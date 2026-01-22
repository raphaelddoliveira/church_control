import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pastor/menu_pastor/menu_pastor_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'pastor_financas_model.dart';
export 'pastor_financas_model.dart';

class PastorFinancasWidget extends StatefulWidget {
  const PastorFinancasWidget({super.key});

  static String routeName = 'Pastor_Financas';
  static String routePath = '/pastorFinancas';

  @override
  State<PastorFinancasWidget> createState() => _PastorFinancasWidgetState();
}

class _PastorFinancasWidgetState extends State<PastorFinancasWidget> {
  late PastorFinancasModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Filtros
  String _periodoSelecionado = 'mes';
  int _anoSelecionado = DateTime.now().year;
  int _mesSelecionado = DateTime.now().month;

  // Dados financeiros
  double _saldoTotal = 0.0;
  double _entradasMes = 0.0;
  double _saidasMes = 0.0;
  double _totalDizimos = 0.0;
  double _totalOfertas = 0.0;
  double _totalOutrasEntradas = 0.0;
  List<EntradaFinanceiraRow> _entradas = [];
  List<SaidaFinanceiraRow> _saidas = [];
  List<Map<String, dynamic>> _transacoesRecentes = [];
  List<SaidaFinanceiraRow> _contasVencer = [];
  List<MapEntry<String, double>> _evolucaoMensal = [];
  List<MapEntry<String, Map<String, double>>> _comparativoMensal = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PastorFinancasModel());
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);

    try {
      final entradas = await EntradaFinanceiraTable().queryRows(queryFn: (q) => q);
      final saidas = await SaidaFinanceiraTable().queryRows(queryFn: (q) => q);

      // Filtrar por periodo
      DateTime dataInicio;
      DateTime dataFim = DateTime.now();

      switch (_periodoSelecionado) {
        case 'mes':
          dataInicio = DateTime(_anoSelecionado, _mesSelecionado, 1);
          dataFim = DateTime(_anoSelecionado, _mesSelecionado + 1, 0);
          break;
        case 'trimestre':
          dataInicio = DateTime.now().subtract(const Duration(days: 90));
          break;
        case 'ano':
          dataInicio = DateTime(_anoSelecionado, 1, 1);
          dataFim = DateTime(_anoSelecionado, 12, 31);
          break;
        case 'todos':
        default:
          dataInicio = DateTime(2000);
          break;
      }

      // Calcular totais gerais
      double totalEntradas = 0.0;
      double totalSaidas = 0.0;

      for (var e in entradas) {
        totalEntradas += e.valorEntrada ?? 0.0;
      }

      for (var s in saidas) {
        totalSaidas += s.valorDespesa ?? 0.0;
      }

      // Filtrar entradas do periodo
      final entradasPeriodo = entradas.where((e) {
        if (e.dataEntrada == null) return false;
        return e.dataEntrada!.isAfter(dataInicio.subtract(const Duration(days: 1))) &&
               e.dataEntrada!.isBefore(dataFim.add(const Duration(days: 1)));
      }).toList();

      // Filtrar saidas do periodo
      final saidasPeriodo = saidas.where((s) {
        if (s.dataSaida == null) return false;
        return s.dataSaida!.isAfter(dataInicio.subtract(const Duration(days: 1))) &&
               s.dataSaida!.isBefore(dataFim.add(const Duration(days: 1)));
      }).toList();

      // Calcular entradas do periodo
      double entradasMes = 0.0;
      double dizimos = 0.0;
      double ofertas = 0.0;
      double outras = 0.0;

      for (var e in entradasPeriodo) {
        final valor = e.valorEntrada ?? 0.0;
        entradasMes += valor;

        final tipo = e.tipoEntrada?.toLowerCase() ?? '';
        if (tipo.contains('dizimo') || tipo.contains('dízimo')) {
          dizimos += valor;
        } else if (tipo.contains('oferta')) {
          ofertas += valor;
        } else {
          outras += valor;
        }
      }

      // Calcular saidas do periodo
      double saidasMes = 0.0;
      for (var s in saidasPeriodo) {
        saidasMes += s.valorDespesa ?? 0.0;
      }

      // Contas a vencer (proximos 30 dias)
      final hoje = DateTime.now();
      final contasVencer = saidas.where((s) {
        if (s.dataVencimento == null) return false;
        final situacao = s.situacao?.toLowerCase() ?? '';
        if (situacao == 'pago' || situacao == 'paga') return false;
        return s.dataVencimento!.isAfter(hoje.subtract(const Duration(days: 1))) &&
               s.dataVencimento!.isBefore(hoje.add(const Duration(days: 30)));
      }).toList();
      contasVencer.sort((a, b) => a.dataVencimento!.compareTo(b.dataVencimento!));

      // Transacoes recentes (ultimas 10)
      List<Map<String, dynamic>> transacoes = [];
      for (var e in entradas) {
        transacoes.add({
          'tipo': 'entrada',
          'descricao': e.descricao ?? e.tipoEntrada ?? 'Entrada',
          'valor': e.valorEntrada ?? 0.0,
          'data': e.dataEntrada,
          'categoria': e.tipoEntrada,
        });
      }
      for (var s in saidas) {
        transacoes.add({
          'tipo': 'saida',
          'descricao': s.descricao ?? s.categoria ?? 'Saída',
          'valor': s.valorDespesa ?? 0.0,
          'data': s.dataSaida,
          'categoria': s.categoria,
        });
      }
      transacoes.sort((a, b) {
        final dataA = a['data'] as DateTime?;
        final dataB = b['data'] as DateTime?;
        if (dataA == null && dataB == null) return 0;
        if (dataA == null) return 1;
        if (dataB == null) return -1;
        return dataB.compareTo(dataA);
      });

      // Evolucao mensal (ultimos 6 meses)
      final evolucaoMap = <String, double>{};
      final comparativoMap = <String, Map<String, double>>{};

      for (int i = 5; i >= 0; i--) {
        final mes = DateTime(hoje.year, hoje.month - i, 1);
        final chave = '${_getNomeMesAbrev(mes.month)}/${mes.year.toString().substring(2)}';
        evolucaoMap[chave] = 0.0;
        comparativoMap[chave] = {'entradas': 0.0, 'saidas': 0.0};
      }

      for (var e in entradas) {
        if (e.dataEntrada != null) {
          final chave = '${_getNomeMesAbrev(e.dataEntrada!.month)}/${e.dataEntrada!.year.toString().substring(2)}';
          if (evolucaoMap.containsKey(chave)) {
            evolucaoMap[chave] = (evolucaoMap[chave] ?? 0) + (e.valorEntrada ?? 0);
            comparativoMap[chave]!['entradas'] = (comparativoMap[chave]!['entradas'] ?? 0) + (e.valorEntrada ?? 0);
          }
        }
      }

      for (var s in saidas) {
        if (s.dataSaida != null) {
          final chave = '${_getNomeMesAbrev(s.dataSaida!.month)}/${s.dataSaida!.year.toString().substring(2)}';
          if (comparativoMap.containsKey(chave)) {
            comparativoMap[chave]!['saidas'] = (comparativoMap[chave]!['saidas'] ?? 0) + (s.valorDespesa ?? 0);
          }
        }
      }

      setState(() {
        _saldoTotal = totalEntradas - totalSaidas;
        _entradasMes = entradasMes;
        _saidasMes = saidasMes;
        _totalDizimos = dizimos;
        _totalOfertas = ofertas;
        _totalOutrasEntradas = outras;
        _entradas = entradas;
        _saidas = saidas;
        _transacoesRecentes = transacoes.take(8).toList();
        _contasVencer = contasVencer.take(5).toList();
        _evolucaoMensal = evolucaoMap.entries.toList();
        _comparativoMensal = comparativoMap.entries.toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[Financas] Erro ao carregar dados: $e');
      setState(() => _isLoading = false);
    }
  }

  String _getNomeMesAbrev(int mes) {
    const meses = ['', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return meses[mes];
  }

  String _getNomeMes(int mes) {
    const meses = ['', 'Janeiro', 'Fevereiro', 'Marco', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];
    return meses[mes];
  }

  String _formatCurrency(double value) {
    final isNegative = value < 0;
    final absValue = value.abs();
    final formatted = 'R\$ ${absValue.toStringAsFixed(2).replaceAll('.', ',')}';
    return isNegative ? '-$formatted' : formatted;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _buildKPICard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    String? subtitle,
    double? percentChange,
  }) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF404040)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(icon, size: 24.0, color: color),
              ),
              if (percentChange != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: percentChange >= 0
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                        : const Color(0xFFFF5252).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        percentChange >= 0 ? Icons.trending_up : Icons.trending_down,
                        size: 14.0,
                        color: percentChange >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFFF5252),
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        '${percentChange.abs().toStringAsFixed(1)}%',
                        style: GoogleFonts.inter(
                          color: percentChange >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFFF5252),
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16.0),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            title,
            style: GoogleFonts.inter(
              color: const Color(0xFF999999),
              fontSize: 14.0,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4.0),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                color: const Color(0xFF666666),
                fontSize: 12.0,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => _periodoSelecionado = value);
        _carregarDados();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? FlutterFlowTheme.of(context).primary : const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? FlutterFlowTheme.of(context).primary : const Color(0xFF404040),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : const Color(0xFF999999),
            fontSize: 13.0,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildGraficoEvolucao() {
    if (_evolucaoMensal.isEmpty) {
      return _buildEmptyChart('Evolucao de Entradas');
    }

    final maxValue = _evolucaoMensal.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final spots = <FlSpot>[];
    for (int i = 0; i < _evolucaoMensal.length; i++) {
      spots.add(FlSpot(i.toDouble(), _evolucaoMensal[i].value));
    }

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF404040)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(Icons.show_chart_rounded, color: Color(0xFF4CAF50), size: 20.0),
              ),
              const SizedBox(width: 12.0),
              Text(
                'Evolucao de Entradas',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          SizedBox(
            height: 200.0,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue > 0 ? maxValue / 4 : 1000,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Color(0xFF404040),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        String text;
                        if (value >= 1000) {
                          text = '${(value / 1000).toStringAsFixed(0)}k';
                        } else {
                          text = value.toStringAsFixed(0);
                        }
                        return Text(
                          text,
                          style: GoogleFonts.inter(color: const Color(0xFF666666), fontSize: 11.0),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (value != index.toDouble()) return const SizedBox.shrink();
                        if (index >= 0 && index < _evolucaoMensal.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _evolucaoMensal[index].key,
                              style: GoogleFonts.inter(color: const Color(0xFF999999), fontSize: 11.0),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: maxValue * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF4CAF50),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: const Color(0xFF4CAF50),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoPizza() {
    final total = _totalDizimos + _totalOfertas + _totalOutrasEntradas;

    if (total == 0) {
      return _buildEmptyChart('Distribuicao de Entradas');
    }

    final percentDizimo = ((_totalDizimos / total) * 100);
    final percentOferta = ((_totalOfertas / total) * 100);
    final percentOutras = ((_totalOutrasEntradas / total) * 100);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF404040)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(Icons.pie_chart_rounded, color: Color(0xFF7C4DFF), size: 20.0),
              ),
              const SizedBox(width: 12.0),
              Text(
                'Distribuicao de Entradas',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 180.0,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 45,
                      sections: [
                        if (_totalDizimos > 0)
                          PieChartSectionData(
                            color: const Color(0xFF7C4DFF),
                            value: _totalDizimos,
                            title: '${percentDizimo.toStringAsFixed(0)}%',
                            radius: 50,
                            titleStyle: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (_totalOfertas > 0)
                          PieChartSectionData(
                            color: const Color(0xFF4DD0E1),
                            value: _totalOfertas,
                            title: '${percentOferta.toStringAsFixed(0)}%',
                            radius: 50,
                            titleStyle: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (_totalOutrasEntradas > 0)
                          PieChartSectionData(
                            color: const Color(0xFFFFB74D),
                            value: _totalOutrasEntradas,
                            title: '${percentOutras.toStringAsFixed(0)}%',
                            radius: 50,
                            titleStyle: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem('Dizimo', const Color(0xFF7C4DFF), _formatCurrency(_totalDizimos)),
                  const SizedBox(height: 12.0),
                  _buildLegendItem('Oferta', const Color(0xFF4DD0E1), _formatCurrency(_totalOfertas)),
                  const SizedBox(height: 12.0),
                  _buildLegendItem('Outras', const Color(0xFFFFB74D), _formatCurrency(_totalOutrasEntradas)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Row(
      children: [
        Container(
          width: 12.0,
          height: 12.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.0),
          ),
        ),
        const SizedBox(width: 8.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(color: const Color(0xFF999999), fontSize: 12.0),
            ),
            Text(
              value,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGraficoComparativo() {
    if (_comparativoMensal.isEmpty) {
      return _buildEmptyChart('Entradas vs Saidas');
    }

    double maxValue = 0;
    for (var entry in _comparativoMensal) {
      final entradas = entry.value['entradas'] ?? 0;
      final saidas = entry.value['saidas'] ?? 0;
      if (entradas > maxValue) maxValue = entradas;
      if (saidas > maxValue) maxValue = saidas;
    }

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF404040)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF2196F3), size: 20.0),
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    'Entradas vs Saidas',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildMiniLegend('Entradas', const Color(0xFF4CAF50)),
                  const SizedBox(width: 16.0),
                  _buildMiniLegend('Saidas', const Color(0xFFFF5252)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          SizedBox(
            height: 200.0,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final tipo = rodIndex == 0 ? 'Entradas' : 'Saidas';
                      return BarTooltipItem(
                        '$tipo\n${_formatCurrency(rod.toY)}',
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
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (value != index.toDouble()) return const SizedBox.shrink();
                        if (index >= 0 && index < _comparativoMensal.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _comparativoMensal[index].key,
                              style: GoogleFonts.inter(color: const Color(0xFF999999), fontSize: 10.0),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        String text;
                        if (value >= 1000) {
                          text = '${(value / 1000).toStringAsFixed(0)}k';
                        } else {
                          text = value.toStringAsFixed(0);
                        }
                        return Text(
                          text,
                          style: GoogleFonts.inter(color: const Color(0xFF666666), fontSize: 10.0),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue > 0 ? maxValue / 4 : 1000,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Color(0xFF404040),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(_comparativoMensal.length, (index) {
                  final data = _comparativoMensal[index].value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data['entradas'] ?? 0,
                        color: const Color(0xFF4CAF50),
                        width: 12,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: data['saidas'] ?? 0,
                        color: const Color(0xFFFF5252),
                        width: 12,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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

  Widget _buildMiniLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10.0,
          height: 10.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.0),
          ),
        ),
        const SizedBox(width: 6.0),
        Text(
          label,
          style: GoogleFonts.inter(color: const Color(0xFF999999), fontSize: 11.0),
        ),
      ],
    );
  }

  Widget _buildEmptyChart(String title) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF404040)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 60.0),
          Center(
            child: Text(
              'Sem dados para exibir',
              style: GoogleFonts.inter(color: const Color(0xFF666666)),
            ),
          ),
          const SizedBox(height: 60.0),
        ],
      ),
    );
  }

  Widget _buildTransacoesRecentes() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF404040)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(Icons.receipt_long_rounded, color: FlutterFlowTheme.of(context).primary, size: 20.0),
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    'Transacoes Recentes',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          if (_transacoesRecentes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Center(
                child: Text(
                  'Nenhuma transacao registrada',
                  style: GoogleFonts.inter(color: const Color(0xFF666666)),
                ),
              ),
            )
          else
            ..._transacoesRecentes.map((t) => _buildTransacaoItem(t)),
        ],
      ),
    );
  }

  Widget _buildTransacaoItem(Map<String, dynamic> transacao) {
    final isEntrada = transacao['tipo'] == 'entrada';
    final color = isEntrada ? const Color(0xFF4CAF50) : const Color(0xFFFF5252);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF404040), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(
              isEntrada ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: color,
              size: 20.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transacao['descricao'] ?? '-',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatDate(transacao['data']),
                  style: GoogleFonts.inter(
                    color: const Color(0xFF666666),
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isEntrada ? '+' : '-'} ${_formatCurrency((transacao['valor'] as double).abs())}',
            style: GoogleFonts.inter(
              color: color,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContasVencer() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF404040)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF9800), size: 20.0),
              ),
              const SizedBox(width: 12.0),
              Text(
                'Contas a Vencer',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          if (_contasVencer.isEmpty)
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Color(0xFF4CAF50), size: 40.0),
                    const SizedBox(height: 8.0),
                    Text(
                      'Nenhuma conta pendente!',
                      style: GoogleFonts.inter(color: const Color(0xFF666666)),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._contasVencer.map((conta) => _buildContaItem(conta)),
        ],
      ),
    );
  }

  Widget _buildContaItem(SaidaFinanceiraRow conta) {
    final diasRestantes = conta.dataVencimento!.difference(DateTime.now()).inDays;
    final isVencida = diasRestantes < 0;
    final isUrgente = diasRestantes <= 3 && !isVencida;

    Color statusColor;
    String statusText;

    if (isVencida) {
      statusColor = const Color(0xFFFF5252);
      statusText = 'Vencida';
    } else if (isUrgente) {
      statusColor = const Color(0xFFFF9800);
      statusText = diasRestantes == 0 ? 'Hoje' : '$diasRestantes dias';
    } else {
      statusColor = const Color(0xFF4CAF50);
      statusText = '$diasRestantes dias';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF404040), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conta.descricao ?? conta.categoria ?? '-',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Vence: ${_formatDate(conta.dataVencimento)}',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF666666),
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(conta.valorDespesa ?? 0),
                style: GoogleFonts.inter(
                  color: const Color(0xFFFF5252),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.inter(
                    color: statusColor,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        drawer: Drawer(
          backgroundColor: const Color(0xFF1A1A1A),
          child: MenuPastorWidget(parameter1: ''),
        ),
        body: Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          decoration: const BoxDecoration(color: Color(0xFF14181B)),
          child: Row(
            children: [
              // Menu lateral desktop
              if (responsiveVisibility(
                context: context,
                phone: false,
                tablet: false,
                tabletLandscape: false,
              ))
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 0.0, 16.0),
                  child: Container(
                    width: 250.0,
                    height: MediaQuery.sizeOf(context).height,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3C3D3E),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: wrapWithModel(
                      model: _model.menuPastorModel,
                      updateCallback: () => safeSetState(() {}),
                      child: MenuPastorWidget(parameter1: ''),
                    ),
                  ),
                ),
              // Conteudo principal
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF3C3D3E),
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
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        if (!responsiveVisibility(context: context, phone: false, tablet: false, tabletLandscape: false))
                                          Padding(
                                            padding: const EdgeInsets.only(right: 12.0),
                                            child: IconButton(
                                              onPressed: () => scaffoldKey.currentState?.openDrawer(),
                                              icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28.0),
                                            ),
                                          ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Painel Financeiro',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 28.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Gestao completa das financas da igreja',
                                              style: GoogleFonts.inter(
                                                color: const Color(0xFF999999),
                                                fontSize: 14.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24.0),

                                // Filtros de periodo
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildFilterChip('Este Mes', 'mes', _periodoSelecionado == 'mes'),
                                      const SizedBox(width: 8.0),
                                      _buildFilterChip('Trimestre', 'trimestre', _periodoSelecionado == 'trimestre'),
                                      const SizedBox(width: 8.0),
                                      _buildFilterChip('Este Ano', 'ano', _periodoSelecionado == 'ano'),
                                      const SizedBox(width: 8.0),
                                      _buildFilterChip('Todos', 'todos', _periodoSelecionado == 'todos'),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24.0),

                                // Cards KPI
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final cardWidth = constraints.maxWidth > 900
                                        ? (constraints.maxWidth - 72) / 4
                                        : constraints.maxWidth > 600
                                            ? (constraints.maxWidth - 48) / 2
                                            : constraints.maxWidth;

                                    return Wrap(
                                      spacing: 24.0,
                                      runSpacing: 24.0,
                                      children: [
                                        SizedBox(
                                          width: cardWidth,
                                          child: _buildKPICard(
                                            icon: Icons.account_balance_wallet_rounded,
                                            title: 'Saldo Total',
                                            value: _formatCurrency(_saldoTotal),
                                            color: _saldoTotal >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFFF5252),
                                            subtitle: 'Entradas - Saidas',
                                          ),
                                        ),
                                        SizedBox(
                                          width: cardWidth,
                                          child: _buildKPICard(
                                            icon: Icons.trending_up_rounded,
                                            title: 'Entradas do Periodo',
                                            value: _formatCurrency(_entradasMes),
                                            color: const Color(0xFF4CAF50),
                                            subtitle: 'Dizimos + Ofertas + Outros',
                                          ),
                                        ),
                                        SizedBox(
                                          width: cardWidth,
                                          child: _buildKPICard(
                                            icon: Icons.trending_down_rounded,
                                            title: 'Saidas do Periodo',
                                            value: _formatCurrency(_saidasMes),
                                            color: const Color(0xFFFF5252),
                                            subtitle: 'Despesas e pagamentos',
                                          ),
                                        ),
                                        SizedBox(
                                          width: cardWidth,
                                          child: _buildKPICard(
                                            icon: Icons.savings_rounded,
                                            title: 'Resultado do Periodo',
                                            value: _formatCurrency(_entradasMes - _saidasMes),
                                            color: (_entradasMes - _saidasMes) >= 0
                                                ? const Color(0xFF2196F3)
                                                : const Color(0xFFFF9800),
                                            subtitle: 'Entradas - Saidas',
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                const SizedBox(height: 32.0),

                                // Graficos linha e pizza
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    if (constraints.maxWidth > 900) {
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(flex: 2, child: _buildGraficoEvolucao()),
                                          const SizedBox(width: 24.0),
                                          Expanded(child: _buildGraficoPizza()),
                                        ],
                                      );
                                    }
                                    return Column(
                                      children: [
                                        _buildGraficoEvolucao(),
                                        const SizedBox(height: 24.0),
                                        _buildGraficoPizza(),
                                      ],
                                    );
                                  },
                                ),

                                const SizedBox(height: 32.0),

                                // Grafico comparativo
                                _buildGraficoComparativo(),

                                const SizedBox(height: 32.0),

                                // Transacoes e Contas a vencer
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    if (constraints.maxWidth > 900) {
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(flex: 2, child: _buildTransacoesRecentes()),
                                          const SizedBox(width: 24.0),
                                          Expanded(child: _buildContasVencer()),
                                        ],
                                      );
                                    }
                                    return Column(
                                      children: [
                                        _buildTransacoesRecentes(),
                                        const SizedBox(height: 24.0),
                                        _buildContasVencer(),
                                      ],
                                    );
                                  },
                                ),

                                const SizedBox(height: 32.0),
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
}
