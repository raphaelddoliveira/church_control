import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/tesouraria/menu_tesouraria/menu_tesouraria_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'home_tesouraria_model.dart';
export 'home_tesouraria_model.dart';

class HomeTesourariaWidget extends StatefulWidget {
  const HomeTesourariaWidget({super.key});

  static String routeName = 'HomeTesouraria';
  static String routePath = '/homeTesouraria';

  @override
  State<HomeTesourariaWidget> createState() => _HomeTesourariaWidgetState();
}

class _HomeTesourariaWidgetState extends State<HomeTesourariaWidget> {
  late HomeTesourariaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Dados financeiros
  double _saldoAtual = 0.0;
  double _totalEntradasMes = 0.0;
  double _totalSaidasMes = 0.0;
  int _contasAVencer = 0;
  List<SaidaFinanceiraRow> _proximasContas = [];
  List<EntradaFinanceiraRow> _ultimasEntradas = [];
  Map<String, double> _entradasPorMes = {};
  Map<String, double> _saidasPorMes = {};
  bool _isLoading = true;

  // Alertas de contas
  List<SaidaFinanceiraRow> _contasVencidas = [];
  List<SaidaFinanceiraRow> _contasVencemHoje = [];
  List<SaidaFinanceiraRow> _contasVencem1Dia = [];
  List<SaidaFinanceiraRow> _contasVencem2Dias = [];
  List<SaidaFinanceiraRow> _contasVencem3Dias = [];
  bool _alertasJaMostrados = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeTesourariaModel());
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final agora = DateTime.now();
      final primeiroDiaMes = DateTime(agora.year, agora.month, 1);
      final ultimoDiaMes = DateTime(agora.year, agora.month + 1, 0);

      // Buscar todas as entradas
      final entradas = await EntradaFinanceiraTable().queryRows(
        queryFn: (q) => q,
      );

      // Buscar todas as saídas
      final saidas = await SaidaFinanceiraTable().queryRows(
        queryFn: (q) => q,
      );

      // Calcular saldo total da igreja (todas entradas - todas saídas)
      final totalTodasEntradas = entradas.fold(0.0, (sum, e) => sum + (e.valorEntrada ?? 0.0));
      final totalTodasSaidas = saidas.fold(0.0, (sum, s) => sum + (s.valorDespesa ?? 0.0));
      final saldo = totalTodasEntradas - totalTodasSaidas;

      // Filtrar entradas do mês atual
      final entradasMes = entradas.where((e) {
        if (e.dataEntrada == null) return false;
        return e.dataEntrada!.isAfter(primeiroDiaMes.subtract(Duration(days: 1))) &&
               e.dataEntrada!.isBefore(ultimoDiaMes.add(Duration(days: 1)));
      }).toList();
      final totalEntradas = entradasMes.fold(0.0, (sum, e) => sum + (e.valorEntrada ?? 0.0));

      // Filtrar saídas do mês atual
      final saidasMes = saidas.where((s) {
        if (s.dataSaida == null) return false;
        return s.dataSaida!.isAfter(primeiroDiaMes.subtract(Duration(days: 1))) &&
               s.dataSaida!.isBefore(ultimoDiaMes.add(Duration(days: 1)));
      }).toList();
      final totalSaidas = saidasMes.fold(0.0, (sum, s) => sum + (s.valorDespesa ?? 0.0));

      // Buscar contas a vencer (próximos 30 dias)
      final limite = agora.add(Duration(days: 30));
      final contasVencer = saidas.where((s) {
        if (s.dataVencimento == null) return false;
        if (s.situacao == 'Pago') return false;
        return s.dataVencimento!.isAfter(agora.subtract(Duration(days: 1))) &&
               s.dataVencimento!.isBefore(limite);
      }).toList();
      contasVencer.sort((a, b) => a.dataVencimento!.compareTo(b.dataVencimento!));

      // Calcular entradas e saídas por mês (últimos 6 meses)
      final entradasMesMap = <String, double>{};
      final saidasMesMap = <String, double>{};

      for (var i = 5; i >= 0; i--) {
        final mes = DateTime(agora.year, agora.month - i, 1);
        final chave = _getNomeMes(mes.month);
        entradasMesMap[chave] = 0.0;
        saidasMesMap[chave] = 0.0;
      }

      for (var e in entradas) {
        if (e.dataEntrada != null) {
          final diffMeses = (agora.year - e.dataEntrada!.year) * 12 + (agora.month - e.dataEntrada!.month);
          if (diffMeses >= 0 && diffMeses < 6) {
            final chave = _getNomeMes(e.dataEntrada!.month);
            entradasMesMap[chave] = (entradasMesMap[chave] ?? 0.0) + (e.valorEntrada ?? 0.0);
          }
        }
      }

      for (var s in saidas) {
        if (s.dataSaida != null) {
          final diffMeses = (agora.year - s.dataSaida!.year) * 12 + (agora.month - s.dataSaida!.month);
          if (diffMeses >= 0 && diffMeses < 6) {
            final chave = _getNomeMes(s.dataSaida!.month);
            saidasMesMap[chave] = (saidasMesMap[chave] ?? 0.0) + (s.valorDespesa ?? 0.0);
          }
        }
      }

      // Últimas entradas
      entradas.sort((a, b) {
        if (a.dataEntrada == null && b.dataEntrada == null) return 0;
        if (a.dataEntrada == null) return 1;
        if (b.dataEntrada == null) return -1;
        return b.dataEntrada!.compareTo(a.dataEntrada!);
      });

      // Categorizar contas por vencimento para alertas
      final hoje = DateTime(agora.year, agora.month, agora.day);
      final contasNaoPagas = saidas.where((s) =>
        s.dataVencimento != null && s.situacao != 'Pago'
      ).toList();

      final vencidas = <SaidaFinanceiraRow>[];
      final vencemHoje = <SaidaFinanceiraRow>[];
      final vencem1Dia = <SaidaFinanceiraRow>[];
      final vencem2Dias = <SaidaFinanceiraRow>[];
      final vencem3Dias = <SaidaFinanceiraRow>[];

      for (var conta in contasNaoPagas) {
        final dataVenc = DateTime(
          conta.dataVencimento!.year,
          conta.dataVencimento!.month,
          conta.dataVencimento!.day,
        );
        final diffDias = dataVenc.difference(hoje).inDays;

        if (diffDias < 0) {
          vencidas.add(conta);
        } else if (diffDias == 0) {
          vencemHoje.add(conta);
        } else if (diffDias == 1) {
          vencem1Dia.add(conta);
        } else if (diffDias == 2) {
          vencem2Dias.add(conta);
        } else if (diffDias == 3) {
          vencem3Dias.add(conta);
        }
      }

      setState(() {
        _saldoAtual = saldo;
        _totalEntradasMes = totalEntradas;
        _totalSaidasMes = totalSaidas;
        _contasAVencer = contasVencer.length;
        _proximasContas = contasVencer.take(5).toList();
        _ultimasEntradas = entradas.take(5).toList();
        _entradasPorMes = entradasMesMap;
        _saidasPorMes = saidasMesMap;
        _contasVencidas = vencidas;
        _contasVencemHoje = vencemHoje;
        _contasVencem1Dia = vencem1Dia;
        _contasVencem2Dias = vencem2Dias;
        _contasVencem3Dias = vencem3Dias;
        _isLoading = false;
      });

      // Mostrar alertas se houver contas vencidas ou prestes a vencer
      if (!_alertasJaMostrados) {
        _alertasJaMostrados = true;
        final temAlertas = vencidas.isNotEmpty ||
                          vencemHoje.isNotEmpty ||
                          vencem1Dia.isNotEmpty ||
                          vencem2Dias.isNotEmpty ||
                          vencem3Dias.isNotEmpty;
        if (temAlertas) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mostrarDialogoAlertas();
          });
        }
      }
    } catch (e) {
      print('[Tesouraria] Erro ao carregar dados: $e');
      setState(() => _isLoading = false);
    }
  }

  String _getNomeMes(int mes) {
    const meses = ['', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return meses[mes];
  }

  void _mostrarDialogoAlertas() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            width: 500,
            constraints: BoxConstraints(maxHeight: 600),
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFE53935).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFE53935),
                        size: 28.0,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alertas de Contas',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Atenção às contas pendentes',
                            style: GoogleFonts.inter(
                              color: Color(0xFF999999),
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: Color(0xFF999999)),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Divider(color: Color(0xFF404040)),
                SizedBox(height: 16.0),
                // Lista de alertas
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Contas vencidas
                        if (_contasVencidas.isNotEmpty)
                          _buildSecaoAlerta(
                            titulo: 'Contas Vencidas',
                            subtitulo: '${_contasVencidas.length} conta(s) em atraso',
                            cor: Color(0xFFE53935),
                            icone: Icons.error_rounded,
                            contas: _contasVencidas,
                            mensagem: 'VENCIDA',
                          ),
                        // Vence hoje
                        if (_contasVencemHoje.isNotEmpty)
                          _buildSecaoAlerta(
                            titulo: 'Vencem Hoje',
                            subtitulo: '${_contasVencemHoje.length} conta(s)',
                            cor: Color(0xFFFF5722),
                            icone: Icons.today_rounded,
                            contas: _contasVencemHoje,
                            mensagem: 'VENCE HOJE',
                          ),
                        // Vence em 1 dia
                        if (_contasVencem1Dia.isNotEmpty)
                          _buildSecaoAlerta(
                            titulo: 'Vencem Amanhã',
                            subtitulo: '${_contasVencem1Dia.length} conta(s)',
                            cor: Color(0xFFFF9800),
                            icone: Icons.schedule_rounded,
                            contas: _contasVencem1Dia,
                            mensagem: 'VENCE EM 1 DIA',
                          ),
                        // Vence em 2 dias
                        if (_contasVencem2Dias.isNotEmpty)
                          _buildSecaoAlerta(
                            titulo: 'Vencem em 2 dias',
                            subtitulo: '${_contasVencem2Dias.length} conta(s)',
                            cor: Color(0xFFFFC107),
                            icone: Icons.schedule_rounded,
                            contas: _contasVencem2Dias,
                            mensagem: 'VENCE EM 2 DIAS',
                          ),
                        // Vence em 3 dias
                        if (_contasVencem3Dias.isNotEmpty)
                          _buildSecaoAlerta(
                            titulo: 'Vencem em 3 dias',
                            subtitulo: '${_contasVencem3Dias.length} conta(s)',
                            cor: Color(0xFF8BC34A),
                            icone: Icons.schedule_rounded,
                            contas: _contasVencem3Dias,
                            mensagem: 'VENCE EM 3 DIAS',
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                // Botão fechar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FlutterFlowTheme.of(context).primary,
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'Entendi',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecaoAlerta({
    required String titulo,
    required String subtitulo,
    required Color cor,
    required IconData icone,
    required List<SaidaFinanceiraRow> contas,
    required String mensagem,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: cor, size: 20.0),
              SizedBox(width: 8.0),
              Text(
                titulo,
                style: GoogleFonts.poppins(
                  color: cor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  subtitulo,
                  style: GoogleFonts.inter(
                    color: cor,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          ...contas.map((conta) => _buildItemAlerta(conta, cor, mensagem)).toList(),
        ],
      ),
    );
  }

  Widget _buildItemAlerta(SaidaFinanceiraRow conta, Color cor, String mensagem) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conta.descricao ?? 'Sem descrição',
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
                    Text(
                      'Vencimento: ${dateTimeFormat('dd/MM/yyyy', conta.dataVencimento!)}',
                      style: GoogleFonts.inter(
                        color: Color(0xFF999999),
                        fontSize: 12.0,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: cor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        mensagem,
                        style: GoogleFonts.inter(
                          color: cor,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            _formatarMoeda(conta.valorDespesa ?? 0),
            style: GoogleFonts.poppins(
              color: cor,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

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
                        : SingleChildScrollView(
                            padding: EdgeInsets.all(32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                _buildHeader(),
                                SizedBox(height: 24.0),
                                // Cards de estatísticas
                                _buildCardsEstatisticas(),
                                SizedBox(height: 24.0),
                                // Gráfico e contas a vencer
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _buildGraficoMensal(),
                                    ),
                                    SizedBox(width: 24.0),
                                    Expanded(
                                      child: _buildContasAVencer(),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24.0),
                                // Últimas entradas
                                _buildUltimasEntradas(),
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
    final agora = DateTime.now();
    final meses = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
                   'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];

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
              '${meses[agora.month - 1]} de ${agora.year}',
              style: GoogleFonts.inter(
                color: Color(0xFF999999),
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildQuickActionButton(
              icon: Icons.add_rounded,
              label: 'Nova Entrada',
              color: Color(0xFF4CAF50),
              onTap: () => context.pushNamed(PageEntradasTesourariaWidget.routeName),
            ),
            SizedBox(width: 12.0),
            _buildQuickActionButton(
              icon: Icons.remove_rounded,
              label: 'Nova Saída',
              color: Color(0xFFE53935),
              onTap: () => context.pushNamed(PageSaidasTesourariaWidget.routeName),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
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

  Widget _buildCardsEstatisticas() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Saldo da Igreja',
            value: _formatarMoeda(_saldoAtual),
            color: Color(0xFF4CAF50),
            subtitle: 'Total geral',
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up_rounded,
            title: 'Entradas do Mês',
            value: _formatarMoeda(_totalEntradasMes),
            color: Color(0xFF2196F3),
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_down_rounded,
            title: 'Saídas do Mês',
            value: _formatarMoeda(_totalSaidasMes),
            color: Color(0xFFE53935),
          ),
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: _buildStatCard(
            icon: Icons.event_note_rounded,
            title: 'Contas a Vencer',
            value: _contasAVencer.toString(),
            color: Color(0xFFFF9800),
            subtitle: 'Próximos 30 dias',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    String? subtitle,
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
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(icon, size: 24.0, color: color),
          ),
          SizedBox(height: 16.0),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24.0,
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
    );
  }

  Widget _buildGraficoMensal() {
    final labels = _entradasPorMes.keys.toList();
    final entradasValues = _entradasPorMes.values.toList();
    final saidasValues = labels.map((l) => _saidasPorMes[l] ?? 0.0).toList();

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
                'Fluxo Financeiro',
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
            height: 250.0,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxValue(entradasValues, saidasValues) * 1.2,
                barTouchData: BarTouchData(enabled: false),
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
                                fontSize: 12.0,
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
                  horizontalInterval: _getMaxValue(entradasValues, saidasValues) / 4,
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
                        width: 16,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: saidasValues[index],
                        color: Color(0xFFE53935),
                        width: 16,
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

  double _getMaxValue(List<double> list1, List<double> list2) {
    double max = 0;
    for (var v in list1) {
      if (v > max) max = v;
    }
    for (var v in list2) {
      if (v > max) max = v;
    }
    return max > 0 ? max : 1000;
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

  Widget _buildContasAVencer() {
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
                'Contas a Vencer',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Color(0xFFFF9800).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  '$_contasAVencer pendentes',
                  style: GoogleFonts.inter(
                    color: Color(0xFFFF9800),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.0),
          if (_proximasContas.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, color: Color(0xFF4CAF50), size: 48.0),
                    SizedBox(height: 12.0),
                    Text(
                      'Nenhuma conta a vencer',
                      style: GoogleFonts.inter(
                        color: Color(0xFF999999),
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...(_proximasContas.map((conta) => _buildContaItem(conta)).toList()),
        ],
      ),
    );
  }

  Widget _buildContaItem(SaidaFinanceiraRow conta) {
    final diasRestantes = conta.dataVencimento!.difference(DateTime.now()).inDays;
    final isVencendo = diasRestantes <= 7;

    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      padding: EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isVencendo ? Color(0xFFFF9800).withOpacity(0.5) : Color(0xFF404040),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isVencendo
                  ? Color(0xFFFF9800).withOpacity(0.15)
                  : Color(0xFF2196F3).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: isVencendo ? Color(0xFFFF9800) : Color(0xFF2196F3),
              size: 20.0,
            ),
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conta.descricao ?? 'Sem descrição',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.0),
                Text(
                  'Vence em ${dateTimeFormat('dd/MM/yyyy', conta.dataVencimento!)}',
                  style: GoogleFonts.inter(
                    color: isVencendo ? Color(0xFFFF9800) : Color(0xFF999999),
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatarMoeda(conta.valorDespesa ?? 0),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUltimasEntradas() {
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
                'Últimas Entradas',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              InkWell(
                onTap: () => context.pushNamed(PageEntradasTesourariaWidget.routeName),
                child: Text(
                  'Ver todas',
                  style: GoogleFonts.inter(
                    color: FlutterFlowTheme.of(context).primary,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.0),
          if (_ultimasEntradas.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Nenhuma entrada registrada',
                  style: GoogleFonts.inter(
                    color: Color(0xFF999999),
                    fontSize: 14.0,
                  ),
                ),
              ),
            )
          else
            ...(_ultimasEntradas.map((entrada) => _buildEntradaItem(entrada)).toList()),
        ],
      ),
    );
  }

  Widget _buildEntradaItem(EntradaFinanceiraRow entrada) {
    final isDizimo = entrada.tipoEntrada?.toLowerCase() == 'dízimo' ||
                     entrada.tipoEntrada?.toLowerCase() == 'dizimo';

    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      padding: EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isDizimo
                  ? Color(0xFF4CAF50).withOpacity(0.15)
                  : Color(0xFF9C27B0).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              isDizimo ? Icons.volunteer_activism : Icons.card_giftcard,
              color: isDizimo ? Color(0xFF4CAF50) : Color(0xFF9C27B0),
              size: 20.0,
            ),
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entrada.tipoEntrada ?? 'Entrada',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  entrada.dataEntrada != null
                      ? dateTimeFormat('dd/MM/yyyy', entrada.dataEntrada!)
                      : 'Sem data',
                  style: GoogleFonts.inter(
                    color: Color(0xFF999999),
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatarMoeda(entrada.valorEntrada ?? 0),
            style: GoogleFonts.poppins(
              color: Color(0xFF4CAF50),
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
