import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/secretaria/menu_secretaria/menu_secretaria_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'page_home_secretaria_model.dart';
export 'page_home_secretaria_model.dart';

class PageHomeSecretariaWidget extends StatefulWidget {
  const PageHomeSecretariaWidget({super.key});

  static String routeName = 'PageHome_Secretaria';
  static String routePath = '/pageHomeSecretaria';

  @override
  State<PageHomeSecretariaWidget> createState() =>
      _PageHomeSecretariaWidgetState();
}

class _PageHomeSecretariaWidgetState extends State<PageHomeSecretariaWidget> {
  late PageHomeSecretariaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Dados
  int _totalMembros = 0;
  int _membrosAtivos = 0;
  int _totalMinisterios = 0;
  int _totalAvisos = 0;
  int _totalCelulas = 0;
  List<MinisterioRow> _ultimosMinisterios = [];
  List<AvisoRow> _ultimosAvisos = [];
  List<MapEntry<String, int>> _membrosPorMes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageHomeSecretariaModel());
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      // Buscar membros
      final membros = await MembrosTable().queryRows(queryFn: (q) => q);
      final ativos = membros.where((m) => m.ativo == true).length;

      // Buscar ministérios ordenados por data
      final ministerios = await MinisterioTable().queryRows(queryFn: (q) => q);
      ministerios.sort((a, b) {
        if (a.criadoEm == null && b.criadoEm == null) return 0;
        if (a.criadoEm == null) return 1;
        if (b.criadoEm == null) return -1;
        return b.criadoEm!.compareTo(a.criadoEm!);
      });

      // Buscar avisos ordenados por data
      final avisos = await AvisoTable().queryRows(queryFn: (q) => q);
      avisos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Buscar células
      final celulas = await CelulaTable().queryRows(queryFn: (q) => q);

      // Calcular membros por mês (agrupar por mês/ano onde há membros)
      final membrosPorMesMap = <String, int>{};
      for (var m in membros) {
        if (m.criadoEm != null) {
          final mesNome = _getNomeMes(m.criadoEm!.month);
          final ano = m.criadoEm!.year.toString().substring(2); // Pega só os últimos 2 dígitos
          final chave = '$mesNome/$ano';
          membrosPorMesMap[chave] = (membrosPorMesMap[chave] ?? 0) + 1;
        }
      }

      // Converter para lista e ordenar por data
      final membrosPorMesList = membrosPorMesMap.entries.toList();
      membrosPorMesList.sort((a, b) {
        // Extrair mês e ano para ordenação
        final partsA = a.key.split('/');
        final partsB = b.key.split('/');
        final mesIndexA = _getMesIndex(partsA[0]);
        final mesIndexB = _getMesIndex(partsB[0]);
        final anoA = int.tryParse(partsA[1]) ?? 0;
        final anoB = int.tryParse(partsB[1]) ?? 0;

        if (anoA != anoB) return anoA.compareTo(anoB);
        return mesIndexA.compareTo(mesIndexB);
      });

      setState(() {
        _totalMembros = membros.length;
        _membrosAtivos = ativos;
        _totalMinisterios = ministerios.length;
        _totalAvisos = avisos.length;
        _totalCelulas = celulas.length;
        _ultimosMinisterios = ministerios.take(5).toList();
        _ultimosAvisos = avisos.take(5).toList();
        _membrosPorMes = membrosPorMesList;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('[Dashboard] ERRO ao carregar dados: $e');
      print('[Dashboard] StackTrace: $stackTrace');
      setState(() => _isLoading = false);
    }
  }

  String _getNomeMes(int mes) {
    const meses = ['', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return meses[mes];
  }

  int _getMesIndex(String mesNome) {
    const meses = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return meses.indexOf(mesNome);
  }

  String _getNomeMesCompleto(int mes) {
    const meses = ['', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];
    return meses[mes];
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
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Color(0xFF404040)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Icon(icon, size: 24.0, color: color),
                  ),
                  if (onTap != null)
                    Icon(Icons.arrow_forward_ios_rounded, size: 16.0, color: Color(0xFF666666)),
                ],
              ),
              SizedBox(height: 16.0),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                title,
                style: GoogleFonts.inter(
                  color: Color(0xFF999999),
                  fontSize: 14.0,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 4.0),
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

  Widget _buildGraficoMembros() {
    if (_membrosPorMes.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Color(0xFF2D2D2D),
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
                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Icon(
                    Icons.trending_up_rounded,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 24.0,
                  ),
                ),
                SizedBox(width: 12.0),
                Text(
                  'Evolução de Membros',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.0),
            Center(
              child: Text(
                'Sem dados para exibir',
                style: GoogleFonts.inter(color: Color(0xFF666666)),
              ),
            ),
            SizedBox(height: 40.0),
          ],
        ),
      );
    }

    final maxValue = _membrosPorMes.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final spots = <FlSpot>[];
    for (int i = 0; i < _membrosPorMes.length; i++) {
      spots.add(FlSpot(i.toDouble(), _membrosPorMes[i].value.toDouble()));
    }

    return Container(
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Color(0xFF2D2D2D),
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
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 24.0,
                ),
              ),
              SizedBox(width: 12.0),
              Text(
                'Evolução de Membros',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.0),
          SizedBox(
            height: 200.0,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue > 0 ? (maxValue / 4).ceilToDouble().clamp(1, double.infinity) : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Color(0xFF404040),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.inter(
                            color: Color(0xFF666666),
                            fontSize: 12.0,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < _membrosPorMes.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              _membrosPorMes[index].key,
                              style: GoogleFonts.inter(
                                color: Color(0xFF666666),
                                fontSize: 11.0,
                              ),
                            ),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (_membrosPorMes.length - 1).toDouble(),
                minY: 0,
                maxY: maxValue > 0 ? maxValue.toDouble() * 1.2 : 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: FlutterFlowTheme.of(context).primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: FlutterFlowTheme.of(context).primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
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

  Widget _buildMinisterioItem(MinisterioRow ministerio) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Navegar para detalhes do ministério
          context.pushNamed(
            PageMinisterioDetalhesSecretariaWidget.routeName,
            queryParameters: {'idMinisterio': ministerio.idMinisterio.toString()},
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          margin: EdgeInsets.only(bottom: 12.0),
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Color(0xFF333333)),
          ),
          child: Row(
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  Icons.church_rounded,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 22.0,
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ministerio.nomeMinisterio,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (ministerio.criadoEm != null)
                      Text(
                        'Criado em: ${ministerio.criadoEm!.day.toString().padLeft(2, '0')}/${ministerio.criadoEm!.month.toString().padLeft(2, '0')}/${ministerio.criadoEm!.year}',
                        style: GoogleFonts.inter(
                          color: Color(0xFF666666),
                          fontSize: 12.0,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Color(0xFF666666)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvisoItem(AvisoRow aviso) {
    Color getCategoriaColor(String? categoria) {
      switch (categoria?.toLowerCase()) {
        case 'evento':
          return Color(0xFF2196F3);
        case 'urgente':
          return Color(0xFFFF4444);
        case 'informativo':
          return Color(0xFF4CAF50);
        case 'celebração':
          return Color(0xFFE91E63);
        default:
          return Color(0xFF9E9E9E);
      }
    }

    final categoriaColor = getCategoriaColor(aviso.categoria);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Navegar para lista de avisos
          context.pushNamed(PageAvisosSecretariaWidget.routeName);
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          margin: EdgeInsets.only(bottom: 12.0),
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Color(0xFF333333)),
          ),
          child: Row(
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: BoxDecoration(
                  color: categoriaColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  Icons.campaign_rounded,
                  color: categoriaColor,
                  size: 22.0,
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aviso.nomeAviso ?? '-',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: categoriaColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            aviso.categoria ?? 'Geral',
                            style: GoogleFonts.inter(
                              color: categoriaColor,
                              fontSize: 10.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          '${aviso.createdAt.day.toString().padLeft(2, '0')}/${aviso.createdAt.month.toString().padLeft(2, '0')}',
                          style: GoogleFonts.inter(
                            color: Color(0xFF666666),
                            fontSize: 11.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Color(0xFF666666)),
            ],
          ),
        ),
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
          backgroundColor: Color(0xFF1A1A1A),
          child: MenuSecretariaWidget(),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: MediaQuery.sizeOf(context).width * 1.0,
              height: MediaQuery.sizeOf(context).height * 1.0,
              decoration: BoxDecoration(
                color: Color(0xFF14181B),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Menu lateral
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
                        height: MediaQuery.sizeOf(context).height * 1.0,
                        decoration: BoxDecoration(
                          color: Color(0xFF3C3D3E),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: wrapWithModel(
                          model: _model.menuSecretariaModel,
                          updateCallback: () => safeSetState(() {}),
                          child: MenuSecretariaWidget(),
                        ),
                      ),
                    ),
                  // Conteudo principal
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                      child: Container(
                        width: 100.0,
                        height: MediaQuery.sizeOf(context).height * 1.0,
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
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
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
                                                  padding: EdgeInsets.only(right: 12.0),
                                                  child: IconButton(
                                                    onPressed: () => scaffoldKey.currentState?.openDrawer(),
                                                    icon: Icon(Icons.menu_rounded, color: Colors.white, size: 28.0),
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
                                                    'Bem-vindo à área da secretaria',
                                                    style: GoogleFonts.inter(
                                                      color: Color(0xFF999999),
                                                      fontSize: 14.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                            decoration: BoxDecoration(
                                              color: Color(0xFF2D2D2D),
                                              borderRadius: BorderRadius.circular(10.0),
                                              border: Border.all(color: Color(0xFF404040)),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.calendar_today_rounded, color: Color(0xFF999999), size: 18.0),
                                                SizedBox(width: 8.0),
                                                Text(
                                                  '${DateTime.now().day} de ${_getNomeMesCompleto(DateTime.now().month)} de ${DateTime.now().year}',
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

                                      SizedBox(height: 32.0),

                                      // Cards de estatísticas
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
                                                  title: 'Total de Membros',
                                                  value: _totalMembros.toString(),
                                                  color: Color(0xFF2196F3),
                                                  subtitle: '$_membrosAtivos ativos',
                                                  onTap: () => context.pushNamed(PageMembrosSecretariaWidget.routeName),
                                                ),
                                              ),
                                              SizedBox(
                                                width: cardWidth,
                                                child: _buildStatCard(
                                                  icon: Icons.church_rounded,
                                                  title: 'Ministérios',
                                                  value: _totalMinisterios.toString(),
                                                  color: FlutterFlowTheme.of(context).primary,
                                                  onTap: () => context.pushNamed(PageMinisteriosSecretariaWidget.routeName),
                                                ),
                                              ),
                                              SizedBox(
                                                width: cardWidth,
                                                child: _buildStatCard(
                                                  icon: Icons.campaign_rounded,
                                                  title: 'Avisos',
                                                  value: _totalAvisos.toString(),
                                                  color: Color(0xFFFF9800),
                                                  onTap: () => context.pushNamed(PageAvisosSecretariaWidget.routeName),
                                                ),
                                              ),
                                              SizedBox(
                                                width: cardWidth,
                                                child: _buildStatCard(
                                                  icon: Icons.groups_rounded,
                                                  title: 'Células',
                                                  value: _totalCelulas.toString(),
                                                  color: Color(0xFF4CAF50),
                                                  onTap: () => context.pushNamed(PageCelulasSecretariaWidget.routeName),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),

                                      SizedBox(height: 32.0),

                                      // Gráfico de evolução
                                      _buildGraficoMembros(),

                                      SizedBox(height: 32.0),

                                      // Ministérios e Avisos lado a lado
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          if (constraints.maxWidth > 800) {
                                            return Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Últimos Ministérios
                                                Expanded(
                                                  child: Container(
                                                    padding: EdgeInsets.all(20.0),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF2D2D2D),
                                                      borderRadius: BorderRadius.circular(16.0),
                                                      border: Border.all(color: Color(0xFF404040)),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        _buildSectionHeader(
                                                          'Últimos Ministérios',
                                                          onVerTodos: () => context.pushNamed(PageMinisteriosSecretariaWidget.routeName),
                                                        ),
                                                        SizedBox(height: 16.0),
                                                        if (_ultimosMinisterios.isEmpty)
                                                          Padding(
                                                            padding: EdgeInsets.all(40.0),
                                                            child: Text(
                                                              'Nenhum ministério cadastrado',
                                                              style: GoogleFonts.inter(color: Color(0xFF666666)),
                                                            ),
                                                          )
                                                        else
                                                          ...(_ultimosMinisterios.map((m) => _buildMinisterioItem(m))),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 24.0),
                                                // Últimos Avisos
                                                Expanded(
                                                  child: Container(
                                                    padding: EdgeInsets.all(20.0),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF2D2D2D),
                                                      borderRadius: BorderRadius.circular(16.0),
                                                      border: Border.all(color: Color(0xFF404040)),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        _buildSectionHeader(
                                                          'Últimos Avisos',
                                                          onVerTodos: () => context.pushNamed(PageAvisosSecretariaWidget.routeName),
                                                        ),
                                                        SizedBox(height: 16.0),
                                                        if (_ultimosAvisos.isEmpty)
                                                          Padding(
                                                            padding: EdgeInsets.all(40.0),
                                                            child: Text(
                                                              'Nenhum aviso cadastrado',
                                                              style: GoogleFonts.inter(color: Color(0xFF666666)),
                                                            ),
                                                          )
                                                        else
                                                          ...(_ultimosAvisos.map((a) => _buildAvisoItem(a))),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                          // Layout mobile - um abaixo do outro
                                          return Column(
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                padding: EdgeInsets.all(20.0),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF2D2D2D),
                                                  borderRadius: BorderRadius.circular(16.0),
                                                  border: Border.all(color: Color(0xFF404040)),
                                                ),
                                                child: Column(
                                                  children: [
                                                    _buildSectionHeader(
                                                      'Últimos Ministérios',
                                                      onVerTodos: () => context.pushNamed(PageMinisteriosSecretariaWidget.routeName),
                                                    ),
                                                    SizedBox(height: 16.0),
                                                    if (_ultimosMinisterios.isEmpty)
                                                      Padding(
                                                        padding: EdgeInsets.all(20.0),
                                                        child: Text(
                                                          'Nenhum ministério cadastrado',
                                                          style: GoogleFonts.inter(color: Color(0xFF666666)),
                                                        ),
                                                      )
                                                    else
                                                      ...(_ultimosMinisterios.map((m) => _buildMinisterioItem(m))),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 24.0),
                                              Container(
                                                width: double.infinity,
                                                padding: EdgeInsets.all(20.0),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF2D2D2D),
                                                  borderRadius: BorderRadius.circular(16.0),
                                                  border: Border.all(color: Color(0xFF404040)),
                                                ),
                                                child: Column(
                                                  children: [
                                                    _buildSectionHeader(
                                                      'Últimos Avisos',
                                                      onVerTodos: () => context.pushNamed(PageAvisosSecretariaWidget.routeName),
                                                    ),
                                                    SizedBox(height: 16.0),
                                                    if (_ultimosAvisos.isEmpty)
                                                      Padding(
                                                        padding: EdgeInsets.all(20.0),
                                                        child: Text(
                                                          'Nenhum aviso cadastrado',
                                                          style: GoogleFonts.inter(color: Color(0xFF666666)),
                                                        ),
                                                      )
                                                    else
                                                      ...(_ultimosAvisos.map((a) => _buildAvisoItem(a))),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      SizedBox(height: 32.0),
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
