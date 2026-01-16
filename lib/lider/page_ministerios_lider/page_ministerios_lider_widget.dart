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
import 'page_ministerios_lider_model.dart';
export 'page_ministerios_lider_model.dart';

class PageMinisteriosLiderWidget extends StatefulWidget {
  const PageMinisteriosLiderWidget({super.key});

  static String routeName = 'PageMinisteriosLider';
  static String routePath = '/pageMinisteriosLider';

  @override
  State<PageMinisteriosLiderWidget> createState() =>
      _PageMinisteriosLiderWidgetState();
}

class _PageMinisteriosLiderWidgetState
    extends State<PageMinisteriosLiderWidget> {
  late PageMinisteriosLiderModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  MembrosRow? _membro;
  MinisterioRow? _ministerio;
  List<EscalasRow> _escalas = [];
  List<VwParticipacoesMesRow> _participacoes = [];
  Map<int, int> _membrosCount = {};
  int _totalMembrosMinisterio = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageMinisteriosLiderModel());

    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      // Buscar membro logado
      final membroRows = await MembrosTable().queryRows(
        queryFn: (q) => q.eq('id_auth', currentUserUid),
      );

      MembrosRow? membro;
      if (membroRows.isNotEmpty) {
        membro = membroRows.first;
      }

      // Buscar ministério do líder
      MinisterioRow? ministerio;
      if (membro != null) {
        final ministerioRows = await MinisterioTable().queryRows(
          queryFn: (q) => q.eq('id_lider', membro!.idMembro),
        );
        if (ministerioRows.isNotEmpty) {
          ministerio = ministerioRows.first;
        }
      }

      // Buscar escalas do ministério
      List<EscalasRow> escalas = [];
      List<VwParticipacoesMesRow> participacoes = [];
      Map<int, int> membrosCount = {};
      int totalMembros = 0;

      if (ministerio != null) {
        // Buscar escalas
        escalas = await EscalasTable().queryRows(
          queryFn: (q) => q
              .eq('id_ministerio', ministerio!.idMinisterio)
              .order('data_hora_escala', ascending: false),
        );

        // Buscar participações no mês
        participacoes = await VwParticipacoesMesTable().queryRows(
          queryFn: (q) => q.eq('id_ministerio', ministerio!.idMinisterio),
        );

        // Contar membros por escala
        for (var escala in escalas) {
          final membrosEscala = await MembrosEscalasTable().queryRows(
            queryFn: (q) => q.eq('id_escala', escala.idEscala),
          );
          membrosCount[escala.idEscala] = membrosEscala.length;
        }

        // Contar total de membros do ministério
        final membrosMinisterio = await MembrosMinisteriosTable().queryRows(
          queryFn: (q) => q.eq('id_ministerio', ministerio!.idMinisterio),
        );
        totalMembros = membrosMinisterio.length;
      }

      setState(() {
        _membro = membro;
        _ministerio = ministerio;
        _escalas = escalas;
        _participacoes = participacoes;
        _membrosCount = membrosCount;
        _totalMembrosMinisterio = totalMembros;
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF14181B),
        body: Container(
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
                      model: _model.menuLiderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: MenuLiderWidget(),
                    ),
                  ),
                ),

              // Conteúdo principal
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
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _ministerio?.nomeMinisterio ?? 'Meu Ministério',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 32.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 8.0),
                                            Text(
                                              'Gerencie suas escalas e participantes',
                                              style: GoogleFonts.inter(
                                                color: Color(0xFF999999),
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          if (responsiveVisibility(
                                            context: context,
                                            desktop: false,
                                          ))
                                            InkWell(
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor: Color(0x80000000),
                                                  enableDrag: false,
                                                  context: context,
                                                  builder: (context) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        FocusScope.of(context).unfocus();
                                                        FocusManager.instance.primaryFocus?.unfocus();
                                                      },
                                                      child: Padding(
                                                        padding: MediaQuery.viewInsetsOf(context),
                                                        child: MenuLiderMobileWidget(),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) => safeSetState(() {}));
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(12.0),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF2A2A2A),
                                                  borderRadius: BorderRadius.circular(12.0),
                                                ),
                                                child: Icon(
                                                  Icons.menu,
                                                  color: Colors.white,
                                                  size: 24.0,
                                                ),
                                              ),
                                            ),
                                          SizedBox(width: 12.0),
                                          FFButtonWidget(
                                            onPressed: () {
                                              context.pushNamed(
                                                PageCriaEscalaLiderWidget.routeName,
                                                queryParameters: {
                                                  'idministerio': serializeParam(
                                                    _ministerio?.idMinisterio,
                                                    ParamType.int,
                                                  ),
                                                }.withoutNulls,
                                              );
                                            },
                                            text: 'Nova Escala',
                                            icon: Icon(
                                              Icons.add_rounded,
                                              size: 20.0,
                                            ),
                                            options: FFButtonOptions(
                                              height: 48.0,
                                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                                              color: FlutterFlowTheme.of(context).primary,
                                              textStyle: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              elevation: 0.0,
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Cards de estatísticas
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: Icons.event_rounded,
                                          title: 'Escalas',
                                          value: _escalas.length.toString(),
                                          color: Color(0xFF4B39EF),
                                        ),
                                      ),
                                      SizedBox(width: 24.0),
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: Icons.people_rounded,
                                          title: 'Membros',
                                          value: _totalMembrosMinisterio.toString(),
                                          color: Color(0xFF39D2C0),
                                        ),
                                      ),
                                      SizedBox(width: 24.0),
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: Icons.check_circle_rounded,
                                          title: 'Participações',
                                          value: _participacoes.fold<int>(
                                            0,
                                            (sum, p) => sum + (p.qtdParticipacoes ?? 0),
                                          ).toString(),
                                          color: Color(0xFFFF9800),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 32.0),

                                // Participações do mês
                                if (_participacoes.isNotEmpty) ...[
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Participações do Mês',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 16.0),
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(24.0),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF2A2A2A),
                                            borderRadius: BorderRadius.circular(16.0),
                                          ),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: _participacoes.map((p) {
                                                return Padding(
                                                  padding: EdgeInsets.only(right: 24.0),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: 60.0,
                                                        height: 60.0,
                                                        decoration: BoxDecoration(
                                                          color: Color(0xFF4B39EF),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            p.iniciais ?? '??',
                                                            style: GoogleFonts.poppins(
                                                              color: Colors.white,
                                                              fontSize: 18.0,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 8.0),
                                                      Text(
                                                        p.nomeMembro ?? '',
                                                        style: GoogleFonts.inter(
                                                          color: Colors.white,
                                                          fontSize: 14.0,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4.0),
                                                      Container(
                                                        padding: EdgeInsets.symmetric(
                                                          horizontal: 12.0,
                                                          vertical: 4.0,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: Color(0xFF39D2C0),
                                                          borderRadius: BorderRadius.circular(12.0),
                                                        ),
                                                        child: Text(
                                                          '${p.qtdParticipacoes ?? 0}',
                                                          style: GoogleFonts.inter(
                                                            color: Colors.white,
                                                            fontSize: 14.0,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 32.0),
                                ],

                                // Lista de escalas
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Escalas Recentes',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (_escalas.length > 5)
                                            TextButton(
                                              onPressed: () {
                                                context.pushNamed(
                                                  PageEscalasLiderWidget.routeName,
                                                  queryParameters: {
                                                    'idministerio': serializeParam(
                                                      _ministerio?.idMinisterio,
                                                      ParamType.int,
                                                    ),
                                                  }.withoutNulls,
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

                                      if (_escalas.isEmpty)
                                        Container(
                                          padding: EdgeInsets.all(48.0),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF2A2A2A),
                                            borderRadius: BorderRadius.circular(16.0),
                                          ),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.event_busy_rounded,
                                                  size: 64.0,
                                                  color: Color(0xFF666666),
                                                ),
                                                SizedBox(height: 16.0),
                                                Text(
                                                  'Nenhuma escala encontrada',
                                                  style: GoogleFonts.inter(
                                                    color: Color(0xFF999999),
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                                SizedBox(height: 8.0),
                                                Text(
                                                  'Clique em "Nova Escala" para criar',
                                                  style: GoogleFonts.inter(
                                                    color: Color(0xFF666666),
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      else
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: _escalas.length > 5 ? 5 : _escalas.length,
                                          itemBuilder: (context, index) {
                                            final escala = _escalas[index];
                                            final numMembros = _membrosCount[escala.idEscala] ?? 0;

                                            return _buildEscalaCard(
                                              escala: escala,
                                              numMembros: numMembros,
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 32.0),
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

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(
              icon,
              size: 32.0,
              color: color,
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Color(0xFF999999),
              fontSize: 14.0,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEscalaCard({
    required EscalasRow escala,
    required int numMembros,
  }) {
    final isPast = escala.dataHoraEscala != null &&
        escala.dataHoraEscala!.isBefore(DateTime.now());

    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.pushNamed(
              PageEscalaDetalhesLiderWidget.routeName,
              queryParameters: {
                'idministerio': serializeParam(_ministerio?.idMinisterio, ParamType.int),
                'idescala': serializeParam(escala.idEscala, ParamType.int),
              }.withoutNulls,
            );
          },
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Ícone/Data
                Container(
                  width: 56.0,
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: isPast
                        ? Color(0xFF666666).withOpacity(0.1)
                        : Color(0xFF4B39EF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        escala.dataHoraEscala != null
                            ? dateTimeFormat('d', escala.dataHoraEscala!)
                            : '--',
                        style: GoogleFonts.poppins(
                          color: isPast ? Color(0xFF666666) : Color(0xFF4B39EF),
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        escala.dataHoraEscala != null
                            ? dateTimeFormat('MMM', escala.dataHoraEscala!).toUpperCase()
                            : '--',
                        style: GoogleFonts.inter(
                          color: isPast ? Color(0xFF666666) : Color(0xFF4B39EF),
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        escala.nomeEscala ?? 'Sem nome',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: Color(0xFF999999),
                            size: 16.0,
                          ),
                          SizedBox(width: 6.0),
                          Text(
                            escala.dataHoraEscala != null
                                ? dateTimeFormat('Hm', escala.dataHoraEscala!)
                                : '--:--',
                            style: GoogleFonts.inter(
                              color: Color(0xFF999999),
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Badge de membros
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_rounded,
                        color: Color(0xFF39D2C0),
                        size: 16.0,
                      ),
                      SizedBox(width: 6.0),
                      Text(
                        '$numMembros',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.0),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF666666),
                  size: 24.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
