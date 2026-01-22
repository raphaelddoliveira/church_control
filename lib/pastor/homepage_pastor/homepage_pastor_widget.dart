import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pastor/menu_pastor/menu_pastor_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'homepage_pastor_model.dart';
export 'homepage_pastor_model.dart';

class HomepagePastorWidget extends StatefulWidget {
  const HomepagePastorWidget({super.key});

  static String routeName = 'Homepage_Pastor';
  static String routePath = '/homepagePastor';

  @override
  State<HomepagePastorWidget> createState() => _HomepagePastorWidgetState();
}

class _HomepagePastorWidgetState extends State<HomepagePastorWidget> {
  late HomepagePastorModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Dados do dashboard
  int _membrosAtivos = 0;
  int _membrosInativos = 0;
  int _totalMinisterios = 0;
  double _saldoIgreja = 0.0;
  double _totalDizimos = 0.0;
  double _totalOfertas = 0.0;
  List<SaidaFinanceiraRow> _contasPagar = [];
  List<MembrosRow> _ultimosMembros = [];
  List<MapEntry<String, int>> _membrosPorMes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomepagePastorModel());
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      // Buscar membros
      final membros = await MembrosTable().queryRows(queryFn: (q) => q);
      final ativos = membros.where((m) => m.ativo == true).length;
      final inativos = membros.where((m) => m.ativo != true).length;

      // Ordenar membros por data de criacao (mais recentes primeiro)
      final membrosOrdenados = List<MembrosRow>.from(membros);
      membrosOrdenados.sort((a, b) {
        if (a.criadoEm == null && b.criadoEm == null) return 0;
        if (a.criadoEm == null) return 1;
        if (b.criadoEm == null) return -1;
        return b.criadoEm!.compareTo(a.criadoEm!);
      });

      // Buscar ministerios
      final ministerios = await MinisterioTable().queryRows(queryFn: (q) => q);

      // Buscar dados financeiros
      final entradas = await EntradaFinanceiraTable().queryRows(queryFn: (q) => q);
      final saidas = await SaidaFinanceiraTable().queryRows(queryFn: (q) => q);

      double dizimos = 0.0;
      double ofertas = 0.0;
      for (var e in entradas) {
        final tipo = e.tipoEntrada?.toLowerCase() ?? '';
        if (tipo == 'dizimo' || tipo == 'dízimo') {
          dizimos += e.valorEntrada ?? 0.0;
        } else if (tipo == 'oferta') {
          ofertas += e.valorEntrada ?? 0.0;
        }
      }

      double totalSaidas = 0.0;
      for (var s in saidas) {
        totalSaidas += s.valorDespesa ?? 0.0;
      }

      // Filtrar contas a pagar (saidas com situacao pendente)
      final contasPendentes = saidas.where((s) =>
        s.situacao?.toLowerCase() != 'pago' &&
        s.situacao?.toLowerCase() != 'paga'
      ).toList();
      contasPendentes.sort((a, b) {
        if (a.dataVencimento == null && b.dataVencimento == null) return 0;
        if (a.dataVencimento == null) return 1;
        if (b.dataVencimento == null) return -1;
        return a.dataVencimento!.compareTo(b.dataVencimento!);
      });

      // Calcular membros por mes
      final membrosPorMesMap = <String, int>{};
      for (var m in membros) {
        if (m.criadoEm != null) {
          final mesNome = _getNomeMes(m.criadoEm!.month);
          final ano = m.criadoEm!.year.toString();
          final chave = '$mesNome $ano';
          membrosPorMesMap[chave] = (membrosPorMesMap[chave] ?? 0) + 1;
        }
      }

      final membrosPorMesList = membrosPorMesMap.entries.toList();
      membrosPorMesList.sort((a, b) {
        final partsA = a.key.split(' ');
        final partsB = b.key.split(' ');
        final mesIndexA = _getMesIndex(partsA[0]);
        final mesIndexB = _getMesIndex(partsB[0]);
        final anoA = int.tryParse(partsA[1]) ?? 0;
        final anoB = int.tryParse(partsB[1]) ?? 0;

        if (anoA != anoB) return anoA.compareTo(anoB);
        return mesIndexA.compareTo(mesIndexB);
      });

      setState(() {
        _membrosAtivos = ativos;
        _membrosInativos = inativos;
        _totalMinisterios = ministerios.length;
        _totalDizimos = dizimos;
        _totalOfertas = ofertas;
        _saldoIgreja = (dizimos + ofertas) - totalSaidas;
        _contasPagar = contasPendentes.take(5).toList();
        _ultimosMembros = membrosOrdenados.take(6).toList();
        _membrosPorMes = membrosPorMesList;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('[Dashboard Pastor] ERRO ao carregar dados: $e');
      debugPrint('[Dashboard Pastor] StackTrace: $stackTrace');
      setState(() => _isLoading = false);
    }
  }

  String _getNomeMes(int mes) {
    const meses = ['', 'Janeiro', 'Fevereiro', 'Marco', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];
    return meses[mes];
  }

  int _getMesIndex(String mesNome) {
    const meses = ['Janeiro', 'Fevereiro', 'Marco', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];
    return meses.indexOf(mesNome);
  }

  String _formatCurrency(double value) {
    return 'R\$${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
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
                  if (onTap != null)
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16.0, color: Color(0xFF666666)),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: color == const Color(0xFF4CAF50) ? color : Colors.white,
                  fontSize: 28.0,
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
                    color: color,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onVerTodos}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (onVerTodos != null)
          TextButton(
            onPressed: onVerTodos,
            child: Text(
              'Ver todos',
              style: GoogleFonts.inter(
                color: FlutterFlowTheme.of(context).primary,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGraficoPizza() {
    final total = _totalDizimos + _totalOfertas;
    final percentDizimo = total > 0 ? (_totalDizimos / total * 100) : 0.0;
    final percentOferta = total > 0 ? (_totalOfertas / total * 100) : 0.0;

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
            'Grafico de Entradas Financeiras',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24.0),
          if (total == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text(
                  'Sem dados para exibir',
                  style: GoogleFonts.inter(color: const Color(0xFF666666)),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 200.0,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        sections: [
                          PieChartSectionData(
                            color: const Color(0xFF7C4DFF),
                            value: _totalDizimos,
                            title: '${percentDizimo.toStringAsFixed(0)}%',
                            radius: 60,
                            titleStyle: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          PieChartSectionData(
                            color: const Color(0xFF4DD0E1),
                            value: _totalOfertas,
                            title: '${percentOferta.toStringAsFixed(0)}%',
                            radius: 60,
                            titleStyle: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 16.0,
                          height: 16.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C4DFF),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          'Dizimo',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    Row(
                      children: [
                        Container(
                          width: 16.0,
                          height: 16.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4DD0E1),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          'Oferta',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildContasPagar() {
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
          _buildSectionHeader('Contas a Pagar', onVerTodos: () => context.pushNamed(PastorFinancasWidget.routeName)),
          const SizedBox(height: 16.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nome:',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF999999),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Valor',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF999999),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (_contasPagar.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: Text(
                  'Nenhuma conta pendente',
                  style: GoogleFonts.inter(color: const Color(0xFF666666)),
                ),
              ),
            )
          else
            ..._contasPagar.map((conta) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF333333), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      conta.descricao ?? '-',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatCurrency(conta.valorDespesa ?? 0.0),
                    style: GoogleFonts.inter(
                      color: const Color(0xFFFF5252),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildUltimosMembros() {
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
          _buildSectionHeader('Ultimos Membros Criados', onVerTodos: () => context.pushNamed(PageMembrosPastorWidget.routeName)),
          const SizedBox(height: 16.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nome:',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF999999),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Data de Cadastro',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF999999),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (_ultimosMembros.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: Text(
                  'Nenhum membro cadastrado',
                  style: GoogleFonts.inter(color: const Color(0xFF666666)),
                ),
              ),
            )
          else
            ..._ultimosMembros.map((membro) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF333333), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      membro.nomeMembro,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    membro.criadoEm != null
                        ? '${membro.criadoEm!.day.toString().padLeft(2, '0')}/${membro.criadoEm!.month.toString().padLeft(2, '0')}/${membro.criadoEm!.year}'
                        : '-',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF999999),
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildGraficoEvolucao() {
    if (_membrosPorMes.isEmpty) {
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
              'Evolucao de Membros',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 40.0),
            Center(
              child: Text(
                'Sem dados para exibir',
                style: GoogleFonts.inter(color: const Color(0xFF666666)),
              ),
            ),
            const SizedBox(height: 40.0),
          ],
        ),
      );
    }

    final maxValue = _membrosPorMes.map((e) => e.value).reduce((a, b) => a > b ? a : b);

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
            'Evolucao de Membros',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24.0),
          SizedBox(
            height: 200.0,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue.toDouble() * 1.3,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${_membrosPorMes[groupIndex].value} membros',
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
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < _membrosPorMes.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _membrosPorMes[index].key,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 10.0,
                              ),
                              textAlign: TextAlign.center,
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
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.inter(
                            color: const Color(0xFF666666),
                            fontSize: 12.0,
                          ),
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
                  horizontalInterval: maxValue > 0 ? (maxValue / 4).ceilToDouble().clamp(1, double.infinity) : 1,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Color(0xFF404040),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(_membrosPorMes.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: _membrosPorMes[index].value.toDouble(),
                        color: const Color(0xFF7C4DFF),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
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
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: MediaQuery.sizeOf(context).height * 1.0,
              decoration: const BoxDecoration(
                color: Color(0xFF14181B),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
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
                        height: MediaQuery.sizeOf(context).height * 1.0,
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
                      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                      child: Container(
                        width: 100.0,
                        height: MediaQuery.sizeOf(context).height * 1.0,
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
                                child: Padding(
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
                                                    'Dashboard',
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: 28.0,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Bem-vindo a area do pastor',
                                                    style: GoogleFonts.inter(
                                                      color: const Color(0xFF999999),
                                                      fontSize: 14.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2D2D2D),
                                              borderRadius: BorderRadius.circular(10.0),
                                              border: Border.all(color: const Color(0xFF404040)),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.calendar_today_rounded, color: Color(0xFF999999), size: 18.0),
                                                const SizedBox(width: 8.0),
                                                Text(
                                                  '${DateTime.now().day} de ${_getNomeMes(DateTime.now().month)} de ${DateTime.now().year}',
                                                  style: GoogleFonts.inter(
                                                    color: Colors.white,
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 32.0),

                                      // Cards de estatisticas
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
                                                child: _buildStatCard(
                                                  icon: Icons.people_rounded,
                                                  title: 'N Membros Ativos',
                                                  value: _membrosAtivos.toString(),
                                                  color: const Color(0xFF2196F3),
                                                  onTap: () => context.pushNamed(PageMembrosPastorWidget.routeName),
                                                ),
                                              ),
                                              SizedBox(
                                                width: cardWidth,
                                                child: _buildStatCard(
                                                  icon: Icons.person_off_rounded,
                                                  title: 'N Membros Inativos',
                                                  value: _membrosInativos.toString(),
                                                  color: const Color(0xFFFF9800),
                                                  onTap: () => context.pushNamed(PageMembrosPastorWidget.routeName),
                                                ),
                                              ),
                                              SizedBox(
                                                width: cardWidth,
                                                child: _buildStatCard(
                                                  icon: Icons.church_rounded,
                                                  title: 'N Ministerios',
                                                  value: _totalMinisterios.toString(),
                                                  color: FlutterFlowTheme.of(context).primary,
                                                  onTap: () => context.pushNamed(PageMinisteriosPastorWidget.routeName),
                                                ),
                                              ),
                                              SizedBox(
                                                width: cardWidth,
                                                child: _buildStatCard(
                                                  icon: Icons.attach_money_rounded,
                                                  title: 'Saldo Igreja',
                                                  value: _formatCurrency(_saldoIgreja),
                                                  color: const Color(0xFF4CAF50),
                                                  onTap: () => context.pushNamed(PastorFinancasWidget.routeName),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 32.0),

                                      // Secao do meio - Contas, Grafico Pizza, Membros
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          if (constraints.maxWidth > 1000) {
                                            return Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(child: _buildContasPagar()),
                                                const SizedBox(width: 24.0),
                                                Expanded(child: _buildGraficoPizza()),
                                                const SizedBox(width: 24.0),
                                                Expanded(child: _buildUltimosMembros()),
                                              ],
                                            );
                                          }
                                          // Layout mobile/tablet
                                          return Column(
                                            children: [
                                              _buildContasPagar(),
                                              const SizedBox(height: 24.0),
                                              _buildGraficoPizza(),
                                              const SizedBox(height: 24.0),
                                              _buildUltimosMembros(),
                                            ],
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 32.0),

                                      // Grafico de evolucao
                                      _buildGraficoEvolucao(),

                                      const SizedBox(height: 32.0),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
