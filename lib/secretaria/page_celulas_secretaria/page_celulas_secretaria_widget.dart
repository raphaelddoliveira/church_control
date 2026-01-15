import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/secretaria/menu_secretaria/menu_secretaria_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_celulas_secretaria_model.dart';
export 'page_celulas_secretaria_model.dart';

class PageCelulasSecretariaWidget extends StatefulWidget {
  const PageCelulasSecretariaWidget({super.key});

  static String routeName = 'PageCelulasSecretaria';
  static String routePath = '/page-celulas-secretaria';

  @override
  State<PageCelulasSecretariaWidget> createState() =>
      _PageCelulasSecretariaWidgetState();
}

class _PageCelulasSecretariaWidgetState
    extends State<PageCelulasSecretariaWidget> {
  late PageCelulasSecretariaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageCelulasSecretariaModel());
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
                      model: _model.menuSecretariaModel,
                      updateCallback: () => safeSetState(() {}),
                      child: MenuSecretariaWidget(),
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
                    child: SingleChildScrollView(
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Células',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 32.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Gerencie as células da igreja',
                                    style: GoogleFonts.inter(
                                      color: Color(0xFF999999),
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                              FFButtonWidget(
                                onPressed: () {
                                  context.pushNamed(
                                    'PageNovaCelulaSecretaria',
                                  );
                                },
                                text: 'Nova Célula',
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
                        ),

                        // Cards de estatísticas
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.0),
                          child: FutureBuilder<Map<String, int>>(
                            future: _carregarEstatisticas(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        FlutterFlowTheme.of(context).primary,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final stats = snapshot.data!;
                              final numCelulas = stats['numCelulas'] ?? 0;
                              final totalParticipantes = stats['totalParticipantes'] ?? 0;
                              final numLideres = stats['numLideres'] ?? 0;

                              return Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      icon: Icons.groups_rounded,
                                      title: 'Células',
                                      value: numCelulas.toString(),
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                  SizedBox(width: 24.0),
                                  Expanded(
                                    child: _buildStatCard(
                                      icon: Icons.people_rounded,
                                      title: 'Participantes',
                                      value: totalParticipantes.toString(),
                                      color: Color(0xFF2196F3),
                                    ),
                                  ),
                                  SizedBox(width: 24.0),
                                  Expanded(
                                    child: _buildStatCard(
                                      icon: Icons.person_rounded,
                                      title: 'Líderes',
                                      value: numLideres.toString(),
                                      color: Color(0xFFFF9800),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 32.0),

                        // Lista de células
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Todas as Células',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 16.0),
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: _carregarCelulas(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(32.0),
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            FlutterFlowTheme.of(context).primary,
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  final celulas = snapshot.data!;

                                  if (celulas.isEmpty) {
                                    return Container(
                                      padding: EdgeInsets.all(48.0),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF1A1A1A),
                                        borderRadius: BorderRadius.circular(16.0),
                                        border: Border.all(
                                          color: Color(0xFF2A2A2A),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.groups_rounded,
                                              size: 64.0,
                                              color: Color(0xFF666666),
                                            ),
                                            SizedBox(height: 16.0),
                                            Text(
                                              'Nenhuma célula cadastrada',
                                              style: GoogleFonts.inter(
                                                color: Color(0xFF999999),
                                                fontSize: 16.0,
                                              ),
                                            ),
                                            SizedBox(height: 8.0),
                                            Text(
                                              'Clique em "Nova Célula" para começar',
                                              style: GoogleFonts.inter(
                                                color: Color(0xFF666666),
                                                fontSize: 14.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: celulas.length,
                                    itemBuilder: (context, index) {
                                      final item = celulas[index];
                                      final celula = item['celula'] as CelulaRow;
                                      final lider = item['lider'] as MembrosRow?;
                                      final numParticipantes = item['numParticipantes'] as int;

                                      return _buildCelulaCard(
                                        celulaId: celula.id,
                                        nome: celula.nomeCelula ?? 'Célula sem nome',
                                        lider: lider?.nomeMembro ?? 'Sem líder',
                                        numParticipantes: numParticipantes,
                                      );
                                    },
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
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Color(0xFF2A2A2A),
          width: 1.0,
        ),
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

  Widget _buildCelulaCard({
    required int celulaId,
    required String nome,
    required String lider,
    required int numParticipantes,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Color(0xFF2A2A2A),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.pushNamed(
              'PageCelulaDetalhesSecretaria',
              queryParameters: {
                'celulaId': serializeParam(celulaId, ParamType.int),
              },
            );
          },
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 56.0,
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.groups_rounded,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 28.0,
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
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
                            Icons.person_rounded,
                            color: Color(0xFF999999),
                            size: 16.0,
                          ),
                          SizedBox(width: 6.0),
                          Text(
                            'Líder: $lider',
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_rounded,
                            color: FlutterFlowTheme.of(context).primary,
                            size: 16.0,
                          ),
                          SizedBox(width: 6.0),
                          Text(
                            '$numParticipantes',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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

  Future<Map<String, int>> _carregarEstatisticas() async {
    try {
      // Buscar total de células
      final celulas = await CelulaTable().queryRows(queryFn: (q) => q);
      final numCelulas = celulas.length;

      // Buscar total de participantes (membros únicos em células)
      final participantes = await MembrosCelulaTable().queryRows(queryFn: (q) => q);
      final idsUnicos = participantes.map((p) => p.idMembro).toSet();
      final totalParticipantes = idsUnicos.length;

      // Buscar número de líderes (células únicas com líder)
      final lideresUnicos = celulas
          .where((c) => c.idLider != null && c.idLider!.isNotEmpty)
          .map((c) => c.idLider)
          .toSet();
      final numLideres = lideresUnicos.length;

      return {
        'numCelulas': numCelulas,
        'totalParticipantes': totalParticipantes,
        'numLideres': numLideres,
      };
    } catch (e) {
      print('Erro ao carregar estatísticas: $e');
      return {
        'numCelulas': 0,
        'totalParticipantes': 0,
        'numLideres': 0,
      };
    }
  }

  Future<List<Map<String, dynamic>>> _carregarCelulas() async {
    try {
      // Buscar todas as células
      final celulas = await CelulaTable().queryRows(
        queryFn: (q) => q.order('created_at', ascending: false),
      );

      List<Map<String, dynamic>> celulasCompletas = [];

      for (var celula in celulas) {
        // Buscar informações do líder
        MembrosRow? lider;
        if (celula.idLider != null) {
          final lideres = await MembrosTable().queryRows(
            queryFn: (q) => q.eq('id_membro', celula.idLider!),
          );
          if (lideres.isNotEmpty) {
            lider = lideres.first;
          }
        }

        // Buscar número de participantes da célula
        final participantes = await MembrosCelulaTable().queryRows(
          queryFn: (q) => q.eq('id_celula', celula.id),
        );

        celulasCompletas.add({
          'celula': celula,
          'lider': lider,
          'numParticipantes': participantes.length,
        });
      }

      return celulasCompletas;
    } catch (e) {
      print('Erro ao carregar células: $e');
      return [];
    }
  }
}
