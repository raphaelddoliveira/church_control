import '/admin/menu_admin/menu_admin_widget.dart';
import '/admin/page_comunidade_admin_nova/page_comunidade_admin_nova_widget.dart';
import '/admin/page_comunidade_admin_detalhes/page_comunidade_admin_detalhes_widget.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_comunidades_admin_model.dart';
export 'page_comunidades_admin_model.dart';

class PageComunidadesAdminWidget extends StatefulWidget {
  const PageComunidadesAdminWidget({super.key});

  static String routeName = 'PageComunidades_Admin';
  static String routePath = '/pageComunidadesAdmin';

  @override
  State<PageComunidadesAdminWidget> createState() =>
      _PageComunidadesAdminWidgetState();
}

class _PageComunidadesAdminWidgetState
    extends State<PageComunidadesAdminWidget> {
  late PageComunidadesAdminModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<ComunidadeRow> _comunidades = [];
  Map<int, MembrosRow?> _lideres = {};
  Map<int, int> _membrosCount = {};
  bool _isLoading = true;
  int _totalMembros = 0;
  int _totalLideres = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageComunidadesAdminModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      // Buscar comunidades
      final comunidades = await ComunidadeTable().queryRows(
        queryFn: (q) => q.order('nome_comunidade'),
      );

      // Buscar lideres e contar membros por comunidade
      Map<int, MembrosRow?> lideres = {};
      Map<int, int> membrosCount = {};
      Set<String> lideresUnicos = {};
      int totalMembrosComunidades = 0;

      for (var comunidade in comunidades) {
        // Buscar lider
        if (comunidade.liderComunidade != null) {
          final liderRows = await MembrosTable().queryRows(
            queryFn: (q) => q.eq('id_membro', comunidade.liderComunidade!),
          );
          if (liderRows.isNotEmpty) {
            lideres[comunidade.id] = liderRows.first;
            lideresUnicos.add(comunidade.liderComunidade!);
          }
        }

        // Contar membros da comunidade
        final membrosComunidade = await MembroComunidadeTable().queryRows(
          queryFn: (q) => q.eq('id_comunidade', comunidade.id),
        );
        membrosCount[comunidade.id] = membrosComunidade.length;
        totalMembrosComunidades += membrosComunidade.length;
      }

      setState(() {
        _comunidades = comunidades;
        _lideres = lideres;
        _membrosCount = membrosCount;
        _totalMembros = totalMembrosComunidades;
        _totalLideres = lideresUnicos.length;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() => _isLoading = false);
    }
  }

  List<ComunidadeRow> get _comunidadesFiltradas {
    final query = _model.textController?.text.toLowerCase() ?? '';
    if (query.isEmpty) return _comunidades;
    return _comunidades.where((c) =>
      (c.nomeComunidade ?? '').toLowerCase().contains(query)
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
                                            'Comunidades',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 32.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            'Gerencie as comunidades da igreja',
                                            style: GoogleFonts.inter(
                                              color: Color(0xFF999999),
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      FFButtonWidget(
                                        onPressed: () async {
                                          final result = await showDialog(
                                            context: context,
                                            builder: (dialogContext) {
                                              return Dialog(
                                                elevation: 0,
                                                insetPadding: EdgeInsets.zero,
                                                backgroundColor: Colors.transparent,
                                                child: PageComunidadeAdminNovaWidget(),
                                              );
                                            },
                                          );
                                          if (result == true) {
                                            setState(() => _isLoading = true);
                                            _carregarDados();
                                          }
                                        },
                                        text: 'Nova Comunidade',
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
                                          icon: Icons.groups_rounded,
                                          title: 'Comunidades',
                                          value: _comunidades.length.toString(),
                                          color: Color(0xFF4CAF50),
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
                                      hintText: 'Buscar comunidade...',
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

                                // Lista de comunidades
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Todas as Comunidades',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 16.0),

                                      if (_comunidadesFiltradas.isEmpty)
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
                                                  Icons.groups_outlined,
                                                  size: 64.0,
                                                  color: Color(0xFF666666),
                                                ),
                                                SizedBox(height: 16.0),
                                                Text(
                                                  'Nenhuma comunidade encontrada',
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
                                          itemCount: _comunidadesFiltradas.length,
                                          itemBuilder: (context, index) {
                                            final comunidade = _comunidadesFiltradas[index];
                                            final lider = _lideres[comunidade.id];
                                            final numMembros = _membrosCount[comunidade.id] ?? 0;

                                            return _buildComunidadeCard(
                                              comunidade: comunidade,
                                              liderNome: lider?.nomeMembro ?? 'Sem lider',
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

  Widget _buildComunidadeCard({
    required ComunidadeRow comunidade,
    required String liderNome,
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
              PageComunidadeAdminDetalhesWidget.routeName,
              queryParameters: {
                'idcomunidade': serializeParam(
                  comunidade.id,
                  ParamType.int,
                ),
              }.withoutNulls,
            );
          },
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Foto ou icone da comunidade
                Container(
                  width: 64.0,
                  height: 64.0,
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: comunidade.fotoUrl != null && comunidade.fotoUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(
                            comunidade.fotoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.groups_rounded,
                              color: Color(0xFF4CAF50),
                              size: 32.0,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.groups_rounded,
                          color: Color(0xFF4CAF50),
                          size: 32.0,
                        ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comunidade.nomeComunidade ?? 'Sem nome',
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
                            'Lider: $liderNome',
                            style: GoogleFonts.inter(
                              color: Color(0xFF999999),
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                      if (comunidade.descricaoComunidade != null &&
                          comunidade.descricaoComunidade!.isNotEmpty) ...[
                        SizedBox(height: 4.0),
                        Text(
                          comunidade.descricaoComunidade!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Color(0xFF666666),
                            fontSize: 13.0,
                          ),
                        ),
                      ],
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
