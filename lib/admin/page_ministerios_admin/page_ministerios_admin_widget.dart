import '/admin/menu_admin/menu_admin_widget.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_ministerios_admin_model.dart';
export 'page_ministerios_admin_model.dart';

class PageMinisteriosAdminWidget extends StatefulWidget {
  const PageMinisteriosAdminWidget({super.key});

  static String routeName = 'PageMinisterios_Admin';
  static String routePath = '/pageMinisteriosAdmin';

  @override
  State<PageMinisteriosAdminWidget> createState() =>
      _PageMinisteriosAdminWidgetState();
}

class _PageMinisteriosAdminWidgetState
    extends State<PageMinisteriosAdminWidget> {
  late PageMinisteriosAdminModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<MinisterioRow> _ministerios = [];
  Map<int, MembrosRow?> _lideres = {};
  Map<int, int> _membrosCount = {};
  bool _isLoading = true;
  int _totalMembros = 0;
  int _totalLideres = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageMinisteriosAdminModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      // Buscar ministerios
      final ministerios = await MinisterioTable().queryRows(
        queryFn: (q) => q.order('nome_ministerio'),
      );

      // Buscar lideres e contar membros por ministerio
      Map<int, MembrosRow?> lideres = {};
      Map<int, int> membrosCount = {};
      Set<String> lideresUnicos = {};
      int totalMembrosMinisterios = 0;

      for (var ministerio in ministerios) {
        // Buscar lider
        if (ministerio.idLider != null) {
          final liderRows = await MembrosTable().queryRows(
            queryFn: (q) => q.eq('id_membro', ministerio.idLider!),
          );
          if (liderRows.isNotEmpty) {
            lideres[ministerio.idMinisterio] = liderRows.first;
            lideresUnicos.add(ministerio.idLider!);
          }
        }

        // Contar membros do ministerio
        final membrosMinisterio = await MembrosMinisteriosTable().queryRows(
          queryFn: (q) => q.eq('id_ministerio', ministerio.idMinisterio),
        );
        membrosCount[ministerio.idMinisterio] = membrosMinisterio.length;
        totalMembrosMinisterios += membrosMinisterio.length;
      }

      setState(() {
        _ministerios = ministerios;
        _lideres = lideres;
        _membrosCount = membrosCount;
        _totalMembros = totalMembrosMinisterios;
        _totalLideres = lideresUnicos.length;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() => _isLoading = false);
    }
  }

  List<MinisterioRow> get _ministeriosFiltrados {
    final query = _model.textController.text.toLowerCase();
    if (query.isEmpty) return _ministerios;
    return _ministerios.where((m) =>
      m.nomeMinisterio.toLowerCase().contains(query)
    ).toList();
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
                      model: _model.menuAdminModel,
                      updateCallback: () => safeSetState(() {}),
                      child: MenuAdminWidget(),
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
                                            'Ministerios',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 32.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            'Gerencie os ministerios da igreja',
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
                                            PageMinisterioAdminNovoWidget.routeName,
                                          );
                                        },
                                        text: 'Novo Ministerio',
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

                                // Cards de estatisticas
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: Icons.church_rounded,
                                          title: 'Ministerios',
                                          value: _ministerios.length.toString(),
                                          color: Color(0xFF9C27B0),
                                        ),
                                      ),
                                      SizedBox(width: 24.0),
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: Icons.people_rounded,
                                          title: 'Participantes',
                                          value: _totalMembros.toString(),
                                          color: Color(0xFF2196F3),
                                        ),
                                      ),
                                      SizedBox(width: 24.0),
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: Icons.person_rounded,
                                          title: 'Lideres',
                                          value: _totalLideres.toString(),
                                          color: Color(0xFFFF9800),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 32.0),

                                // Campo de busca
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                                  child: TextField(
                                    controller: _model.textController,
                                    focusNode: _model.textFieldFocusNode,
                                    onChanged: (_) => EasyDebounce.debounce(
                                      '_model.textController',
                                      Duration(milliseconds: 300),
                                      () => safeSetState(() {}),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Buscar ministerio...',
                                      hintStyle: GoogleFonts.inter(
                                        color: Color(0xFF666666),
                                        fontSize: 16.0,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search_rounded,
                                        color: Color(0xFF666666),
                                      ),
                                      filled: true,
                                      fillColor: Color(0xFF2A2A2A),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                        borderSide: BorderSide(
                                          color: Color(0xFF3A3A3A),
                                          width: 1.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context).primary,
                                          width: 2.0,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 16.0,
                                      ),
                                    ),
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 24.0),

                                // Lista de ministerios
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Todos os Ministerios',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 16.0),

                                      if (_ministeriosFiltrados.isEmpty)
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
                                                  Icons.church_outlined,
                                                  size: 64.0,
                                                  color: Color(0xFF666666),
                                                ),
                                                SizedBox(height: 16.0),
                                                Text(
                                                  'Nenhum ministerio encontrado',
                                                  style: GoogleFonts.inter(
                                                    color: Color(0xFF999999),
                                                    fontSize: 16.0,
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
                                          itemCount: _ministeriosFiltrados.length,
                                          itemBuilder: (context, index) {
                                            final ministerio = _ministeriosFiltrados[index];
                                            final lider = _lideres[ministerio.idMinisterio];
                                            final numMembros = _membrosCount[ministerio.idMinisterio] ?? 0;

                                            return _buildMinisterioCard(
                                              ministerioId: ministerio.idMinisterio,
                                              nome: ministerio.nomeMinisterio,
                                              lider: lider?.nomeMembro ?? 'Sem lider',
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

  Widget _buildMinisterioCard({
    required int ministerioId,
    required String nome,
    required String lider,
    required int numMembros,
  }) {
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
              PageMinisteriosAdminDetalhesWidget.routeName,
              queryParameters: {
                'idministerio': serializeParam(ministerioId, ParamType.int),
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
                    color: Color(0xFF9C27B0).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.church_rounded,
                    color: Color(0xFF9C27B0),
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
                            'Lider: $lider',
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
                        color: FlutterFlowTheme.of(context).primary,
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
