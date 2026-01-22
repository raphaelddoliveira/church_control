import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/lider/menu_lider/menu_lider_widget.dart';
import '/lider/menu_lider_mobile/menu_lider_mobile_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'homepage_lider_model.dart';
export 'homepage_lider_model.dart';

class HomepageLiderWidget extends StatefulWidget {
  const HomepageLiderWidget({super.key});

  static String routeName = 'Homepage_Lider';
  static String routePath = '/homepageLider';

  @override
  State<HomepageLiderWidget> createState() => _HomepageLiderWidgetState();
}

class _HomepageLiderWidgetState extends State<HomepageLiderWidget> {
  late HomepageLiderModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  MembrosRow? _membro;
  MinisterioRow? _ministerio;
  List<MembrosMinisteriosRow> _membrosMinisterio = [];
  List<EscalasRow> _proximasEscalas = [];
  int _totalEscalasMes = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomepageLiderModel());
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      // Carregar membro atual
      final membroRows = await MembrosTable().queryRows(
        queryFn: (q) => q.eq('id_auth', currentUserUid),
      );

      MembrosRow? membro;
      if (membroRows.isNotEmpty) {
        membro = membroRows.first;
      }

      // Carregar ministério do líder
      MinisterioRow? ministerio;
      if (membro != null) {
        final ministerioRows = await MinisterioTable().queryRows(
          queryFn: (q) => q.eq('id_lider', membro!.idMembro),
        );
        if (ministerioRows.isNotEmpty) {
          ministerio = ministerioRows.first;
        }
      }

      // Carregar membros do ministério
      List<MembrosMinisteriosRow> membrosMinisterio = [];
      if (ministerio != null) {
        membrosMinisterio = await MembrosMinisteriosTable().queryRows(
          queryFn: (q) => q.eq('id_ministerio', ministerio!.idMinisterio),
        );
      }

      // Carregar próximas escalas
      List<EscalasRow> proximasEscalas = [];
      if (ministerio != null) {
        final escalas = await EscalasTable().queryRows(
          queryFn: (q) => q
              .eq('id_ministerio', ministerio!.idMinisterio)
              .gte('data_hora_escala', DateTime.now().toIso8601String())
              .order('data_hora_escala'),
        );
        proximasEscalas = escalas.take(5).toList();
      }

      // Contar escalas do mês
      int totalEscalasMes = 0;
      if (ministerio != null) {
        final now = DateTime.now();
        final inicioMes = DateTime(now.year, now.month, 1);
        final fimMes = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

        final escalasMes = await EscalasTable().queryRows(
          queryFn: (q) => q
              .eq('id_ministerio', ministerio!.idMinisterio)
              .gte('data_hora_escala', inicioMes.toIso8601String())
              .lte('data_hora_escala', fimMes.toIso8601String()),
        );
        totalEscalasMes = escalasMes.length;
      }

      setState(() {
        _membro = membro;
        _ministerio = ministerio;
        _membrosMinisterio = membrosMinisterio;
        _proximasEscalas = proximasEscalas;
        _totalEscalasMes = totalEscalasMes;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usar breakpoint explícito para mobile (< 600px)
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
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
                    child: wrapWithModel(
                      model: _model.menuLiderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: MenuLiderWidget(),
                    ),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                _buildHeader(context, isMobile),

                                // Stats Cards
                                _buildStatsSection(context, isMobile),

                                SizedBox(height: isMobile ? 16.0 : 24.0),

                                // Quick Actions
                                _buildQuickActions(context, isMobile),

                                SizedBox(height: isMobile ? 16.0 : 24.0),

                                // Próximas Escalas
                                _buildProximasEscalas(context, isMobile),

                                SizedBox(height: 24.0),
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

  Widget _buildHeader(BuildContext context, bool isMobile) {
    final hora = DateTime.now().hour;
    String saudacao;
    if (hora < 12) {
      saudacao = 'Bom dia';
    } else if (hora < 18) {
      saudacao = 'Boa tarde';
    } else {
      saudacao = 'Boa noite';
    }

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$saudacao,',
                  style: GoogleFonts.inter(
                    color: Color(0xFF999999),
                    fontSize: isMobile ? 14.0 : 16.0,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  _membro?.nomeMembro ?? 'Líder',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isMobile ? 22.0 : 28.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.0),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        _ministerio?.nomeMinisterio ?? 'Ministério',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Menu mobile
          if (isMobile)
            InkWell(
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (dialogContext) {
                    return Dialog(
                      elevation: 0,
                      insetPadding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      child: MenuLiderMobileWidget(),
                    );
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 24.0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 32.0),
      child: isMobile
          ? Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.people_rounded,
                        title: 'Membros',
                        value: _membrosMinisterio.length.toString(),
                        color: Color(0xFF2196F3),
                        isMobile: isMobile,
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.event_rounded,
                        title: 'Escalas do Mês',
                        value: _totalEscalasMes.toString(),
                        color: Color(0xFF00BFA5),
                        isMobile: isMobile,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.0),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.upcoming_rounded,
                        title: 'Próximas',
                        value: _proximasEscalas.length.toString(),
                        color: Color(0xFFFF9800),
                        isMobile: isMobile,
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.calendar_month_rounded,
                        title: DateFormat('MMMM', 'pt_BR').format(DateTime.now()),
                        value: DateTime.now().year.toString(),
                        color: Color(0xFF9C27B0),
                        isMobile: isMobile,
                        isText: true,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.people_rounded,
                    title: 'Membros do Ministério',
                    value: _membrosMinisterio.length.toString(),
                    color: Color(0xFF2196F3),
                    isMobile: isMobile,
                  ),
                ),
                SizedBox(width: 24.0),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.event_rounded,
                    title: 'Escalas este Mês',
                    value: _totalEscalasMes.toString(),
                    color: Color(0xFF00BFA5),
                    isMobile: isMobile,
                  ),
                ),
                SizedBox(width: 24.0),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.upcoming_rounded,
                    title: 'Próximas Escalas',
                    value: _proximasEscalas.length.toString(),
                    color: Color(0xFFFF9800),
                    isMobile: isMobile,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isMobile,
    bool isText = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 10.0 : 12.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(
              icon,
              size: isMobile ? 24.0 : 28.0,
              color: color,
            ),
          ),
          SizedBox(height: isMobile ? 12.0 : 16.0),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Color(0xFF999999),
              fontSize: isMobile ? 12.0 : 14.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.0),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: isText ? (isMobile ? 16.0 : 20.0) : (isMobile ? 28.0 : 32.0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acesso Rápido',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: isMobile ? 18.0 : 20.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.0),
          isMobile
              ? Column(
                  children: [
                    _buildActionCard(
                      context: context,
                      icon: Icons.calendar_today_rounded,
                      title: 'Ver Escalas',
                      subtitle: 'Gerenciar escalas do ministério',
                      color: Color(0xFF2196F3),
                      onTap: () {
                        if (_ministerio != null) {
                          context.pushNamed(
                            'PageEscalasLider',
                            queryParameters: {
                              'idministerio': serializeParam(_ministerio!.idMinisterio, ParamType.int),
                            },
                          );
                        }
                      },
                      isMobile: isMobile,
                    ),
                    SizedBox(height: 12.0),
                    _buildActionCard(
                      context: context,
                      icon: Icons.group_rounded,
                      title: 'Ver Membros',
                      subtitle: 'Gerenciar equipe do ministério',
                      color: Color(0xFF00BFA5),
                      onTap: () {
                        if (_ministerio != null) {
                          context.pushNamed(
                            PageMinisterioDetalhesLiderWidget.routeName,
                            queryParameters: {
                              'idministerio': serializeParam(_ministerio!.idMinisterio, ParamType.int),
                            }.withoutNulls,
                          );
                        }
                      },
                      isMobile: isMobile,
                    ),
                    SizedBox(height: 12.0),
                    _buildActionCard(
                      context: context,
                      icon: Icons.add_circle_rounded,
                      title: 'Nova Escala',
                      subtitle: 'Criar uma nova escala',
                      color: FlutterFlowTheme.of(context).primary,
                      onTap: () {
                        if (_ministerio != null) {
                          // Se for Ministério de Louvor (id = 1), usa a página especializada
                          if (_ministerio!.idMinisterio == 1) {
                            context.pushNamed(
                              'PageCriaEscala_Louvor',
                              queryParameters: {
                                'idministerio': serializeParam(_ministerio!.idMinisterio, ParamType.int),
                              },
                            );
                          } else {
                            context.pushNamed(
                              'PageCriaEscala_Lider',
                              queryParameters: {
                                'idministerio': serializeParam(_ministerio!.idMinisterio, ParamType.int),
                              },
                            );
                          }
                        }
                      },
                      isMobile: isMobile,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context: context,
                        icon: Icons.calendar_today_rounded,
                        title: 'Ver Escalas',
                        subtitle: 'Gerenciar escalas do ministério',
                        color: Color(0xFF2196F3),
                        onTap: () {
                          if (_ministerio != null) {
                            context.pushNamed(
                              'PageEscalasLider',
                              queryParameters: {
                                'idministerio': serializeParam(_ministerio!.idMinisterio, ParamType.int),
                              },
                            );
                          }
                        },
                        isMobile: isMobile,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: _buildActionCard(
                        context: context,
                        icon: Icons.group_rounded,
                        title: 'Ver Membros',
                        subtitle: 'Gerenciar equipe do ministério',
                        color: Color(0xFF00BFA5),
                        onTap: () {
                          if (_ministerio != null) {
                            context.pushNamed(
                              'PageMinisterioDetalhesLider',
                              queryParameters: {
                                'idministerio': serializeParam(_ministerio!.idMinisterio, ParamType.int),
                              },
                            );
                          }
                        },
                        isMobile: isMobile,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: _buildActionCard(
                        context: context,
                        icon: Icons.add_circle_rounded,
                        title: 'Nova Escala',
                        subtitle: 'Criar uma nova escala',
                        color: FlutterFlowTheme.of(context).primary,
                        onTap: () {
                          if (_ministerio != null) {
                            // Se for Ministério de Louvor (id = 1), usa a página especializada
                            if (_ministerio!.idMinisterio == 1) {
                              context.pushNamed(
                                'PageCriaEscala_Louvor',
                                queryParameters: {
                                  'idministerio': serializeParam(_ministerio!.idMinisterio, ParamType.int),
                                },
                              );
                            } else {
                              context.pushNamed(
                                'PageCriaEscala_Lider',
                                queryParameters: {
                                  'idministerio': serializeParam(_ministerio!.idMinisterio, ParamType.int),
                                },
                              );
                            }
                          }
                        },
                        isMobile: isMobile,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Color(0xFF3A3A3A),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                icon,
                size: 24.0,
                color: color,
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: Color(0xFF999999),
                      fontSize: 13.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF666666),
              size: 18.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProximasEscalas(BuildContext context, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Próximas Escalas',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: isMobile ? 18.0 : 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_ministerio != null)
                TextButton(
                  onPressed: () {
                    context.pushNamed(
                      'PageEscalasLider',
                      queryParameters: {
                        'idministerio': serializeParam(_ministerio!.idMinisterio, ParamType.int),
                      },
                    );
                  },
                  child: Text(
                    'Ver todas',
                    style: GoogleFonts.inter(
                      color: FlutterFlowTheme.of(context).primary,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.0),
          if (_proximasEscalas.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    color: Color(0xFF666666),
                    size: 48.0,
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    'Nenhuma escala agendada',
                    style: GoogleFonts.inter(
                      color: Color(0xFF999999),
                      fontSize: 15.0,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Crie uma nova escala para começar',
                    style: GoogleFonts.inter(
                      color: Color(0xFF666666),
                      fontSize: 13.0,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: _proximasEscalas.map((escala) {
                return _buildEscalaItem(context, escala, isMobile);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEscalaItem(BuildContext context, EscalasRow escala, bool isMobile) {
    final dataEscala = escala.dataHoraEscala;
    final isHoje = dataEscala != null &&
        dataEscala.day == DateTime.now().day &&
        dataEscala.month == DateTime.now().month &&
        dataEscala.year == DateTime.now().year;

    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          context.pushNamed(
            'PageEscalaDetalhesLider',
            queryParameters: {
              'idministerio': serializeParam(_ministerio?.idMinisterio, ParamType.int),
              'idescala': serializeParam(escala.idEscala, ParamType.int),
            },
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12.0),
            border: isHoje
                ? Border.all(color: FlutterFlowTheme.of(context).primary, width: 2.0)
                : null,
          ),
          child: Row(
            children: [
              // Data
              Container(
                width: isMobile ? 50.0 : 60.0,
                padding: EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: isHoje
                      ? FlutterFlowTheme.of(context).primary.withOpacity(0.2)
                      : Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    Text(
                      dataEscala != null ? DateFormat('dd').format(dataEscala) : '--',
                      style: GoogleFonts.poppins(
                        color: isHoje ? FlutterFlowTheme.of(context).primary : Colors.white,
                        fontSize: isMobile ? 20.0 : 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      dataEscala != null
                          ? DateFormat('MMM', 'pt_BR').format(dataEscala).toUpperCase()
                          : '',
                      style: GoogleFonts.inter(
                        color: isHoje ? FlutterFlowTheme.of(context).primary : Color(0xFF999999),
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.0),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isHoje)
                          Container(
                            margin: EdgeInsets.only(right: 8.0),
                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              'HOJE',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            escala.nomeEscala ?? 'Escala',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: Color(0xFF999999),
                          size: 14.0,
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          dataEscala != null ? DateFormat('HH:mm').format(dataEscala) : '--:--',
                          style: GoogleFonts.inter(
                            color: Color(0xFF999999),
                            fontSize: 13.0,
                          ),
                        ),
                        SizedBox(width: 12.0),
                        Icon(
                          Icons.calendar_today_rounded,
                          color: Color(0xFF999999),
                          size: 14.0,
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          dataEscala != null
                              ? DateFormat('EEEE', 'pt_BR').format(dataEscala)
                              : '',
                          style: GoogleFonts.inter(
                            color: Color(0xFF999999),
                            fontSize: 13.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF666666),
                size: 24.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
