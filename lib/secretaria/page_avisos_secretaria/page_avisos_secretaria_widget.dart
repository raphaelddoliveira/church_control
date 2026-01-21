import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/secretaria/menu_secretaria/menu_secretaria_widget.dart';
import '/secretaria/page_novo_aviso_secretaria/page_novo_aviso_secretaria_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_avisos_secretaria_model.dart';
export 'page_avisos_secretaria_model.dart';

class PageAvisosSecretariaWidget extends StatefulWidget {
  const PageAvisosSecretariaWidget({super.key});

  static String routeName = 'PageAvisosSecretaria';
  static String routePath = '/PageAvisosSecretaria';

  @override
  State<PageAvisosSecretariaWidget> createState() =>
      _PageAvisosSecretariaWidgetState();
}

class _PageAvisosSecretariaWidgetState
    extends State<PageAvisosSecretariaWidget> {
  late PageAvisosSecretariaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<AvisoRow> _avisos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageAvisosSecretariaModel());
    _carregarAvisos();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _carregarAvisos() async {
    try {
      final avisos = await AvisoTable().queryRows(
        queryFn: (q) => q.order('created_at', ascending: false),
      );
      setState(() {
        _avisos = avisos;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar avisos: $e');
      setState(() => _isLoading = false);
    }
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
                                      'Avisos',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 32.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Gestão de avisos da igreja',
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
                                      PageNovoAvisoSecretariaWidget.routeName,
                                    );
                                  },
                                  text: 'Novo Aviso',
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
                            child: _isLoading
                                ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(32.0),
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          FlutterFlowTheme.of(context).primary,
                                        ),
                                      ),
                                    ),
                                  )
                                : _buildStatCards(),
                          ),

                          SizedBox(height: 32.0),

                          // Lista de avisos
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lista de Avisos',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 16.0),

                                // Campo de busca
                                TextFormField(
                                  controller: _model.searchController,
                                  focusNode: _model.searchFocusNode,
                                  onChanged: (value) => setState(() {}),
                                  decoration: InputDecoration(
                                    hintText: 'Buscar avisos...',
                                    hintStyle: GoogleFonts.inter(
                                      color: Color(0xFF666666),
                                    ),
                                    prefixIcon: Icon(Icons.search, color: Color(0xFF999999)),
                                    suffixIcon: _model.searchController!.text.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(Icons.clear, color: Color(0xFF999999)),
                                            onPressed: () {
                                              _model.searchController?.clear();
                                              setState(() {});
                                            },
                                          )
                                        : null,
                                    filled: true,
                                    fillColor: Color(0xFF2A2A2A),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                  ),
                                  style: GoogleFonts.inter(color: Colors.white),
                                ),

                                SizedBox(height: 16.0),

                                // Chips de filtro
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildFilterChip('Todos', null),
                                      SizedBox(width: 8.0),
                                      _buildFilterChip('Ativos', 'ativo', icon: Icons.visibility),
                                      SizedBox(width: 8.0),
                                      _buildFilterChip('Expirados', 'expirado', icon: Icons.event_busy),
                                      SizedBox(width: 8.0),
                                      _buildFilterChip('Fixados', 'fixado', icon: Icons.push_pin),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 16.0),

                                // Lista de avisos
                                _buildAvisosList(),
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

  Widget _buildStatCards() {
    final now = DateTime.now();
    final avisosAtivos = _avisos.where((a) =>
      a.expiraEm != null && a.expiraEm!.isAfter(now)
    ).length;
    final avisosExpirados = _avisos.where((a) =>
      a.expiraEm != null && a.expiraEm!.isBefore(now)
    ).length;
    final avisosFixados = _avisos.where((a) =>
      (a.fixado ?? false) && a.expiraEm != null && a.expiraEm!.isAfter(now)
    ).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.visibility_rounded,
            title: 'Avisos Ativos',
            value: avisosAtivos.toString(),
            color: Color(0xFF2196F3),
          ),
        ),
        SizedBox(width: 24.0),
        Expanded(
          child: _buildStatCard(
            icon: Icons.event_busy_rounded,
            title: 'Expirados',
            value: avisosExpirados.toString(),
            color: Color(0xFFF44336),
          ),
        ),
        SizedBox(width: 24.0),
        Expanded(
          child: _buildStatCard(
            icon: Icons.push_pin_rounded,
            title: 'Fixados',
            value: avisosFixados.toString(),
            color: Color(0xFF4CAF50),
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

  Widget _buildFilterChip(String label, String? filter, {IconData? icon}) {
    final isSelected = _model.filtroStatus == filter;
    return InkWell(
      onTap: () {
        setState(() {
          _model.filtroStatus = isSelected ? null : filter;
        });
      },
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected
              ? FlutterFlowTheme.of(context).primary
              : Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 16.0),
              SizedBox(width: 6.0),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvisosList() {
    final now = DateTime.now();

    // Aplicar filtros
    List<AvisoRow> avisosFiltrados = _avisos.where((aviso) {
      final isAtivo = aviso.expiraEm != null && aviso.expiraEm!.isAfter(now);

      // Filtro de busca
      if (_model.searchController!.text.isNotEmpty) {
        final searchLower = _model.searchController!.text.toLowerCase();
        final nomeAviso = (aviso.nomeAviso ?? '').toLowerCase();
        if (!nomeAviso.contains(searchLower)) {
          return false;
        }
      }

      // Filtro de status
      if (_model.filtroStatus != null) {
        switch (_model.filtroStatus) {
          case 'ativo':
            return isAtivo;
          case 'expirado':
            return !isAtivo;
          case 'fixado':
            return (aviso.fixado ?? false) && isAtivo;
        }
      }

      return true;
    }).toList();

    if (_isLoading) {
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

    if (avisosFiltrados.isEmpty) {
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
                Icons.notifications_off_rounded,
                size: 64.0,
                color: Color(0xFF666666),
              ),
              SizedBox(height: 16.0),
              Text(
                'Nenhum aviso encontrado',
                style: GoogleFonts.inter(
                  color: Color(0xFF999999),
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Clique em "Novo Aviso" para criar um',
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
      itemCount: avisosFiltrados.length,
      itemBuilder: (context, index) {
        final aviso = avisosFiltrados[index];
        return _buildAvisoCard(aviso);
      },
    );
  }

  Widget _buildAvisoCard(AvisoRow aviso) {
    final now = DateTime.now();
    final isAtivo = aviso.expiraEm != null && aviso.expiraEm!.isAfter(now);
    final isFixado = aviso.fixado ?? false;

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
            // Navegar para detalhes do aviso se necessário
          },
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              aviso.nomeAviso ?? 'Sem título',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.0),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: isAtivo
                                  ? Color(0xFF4CAF50).withOpacity(0.2)
                                  : Color(0xFFF44336).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              isAtivo ? 'ATIVO' : 'EXPIRADO',
                              style: GoogleFonts.inter(
                                color: isAtivo ? Color(0xFF4CAF50) : Color(0xFFF44336),
                                fontSize: 11.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          if (aviso.categoria != null) ...[
                            Text(
                              'Tipo: ${aviso.categoria}',
                              style: GoogleFonts.inter(
                                color: Color(0xFF999999),
                                fontSize: 13.0,
                              ),
                            ),
                            Text(
                              ' • ',
                              style: GoogleFonts.inter(
                                color: Color(0xFF666666),
                                fontSize: 13.0,
                              ),
                            ),
                          ],
                          Text(
                            'Criado: ${DateFormat('dd/MM/yyyy').format(aviso.createdAt)}',
                            style: GoogleFonts.inter(
                              color: Color(0xFF999999),
                              fontSize: 13.0,
                            ),
                          ),
                          Text(
                            ' • ',
                            style: GoogleFonts.inter(
                              color: Color(0xFF666666),
                              fontSize: 13.0,
                            ),
                          ),
                          Text(
                            'Expira: ${aviso.expiraEm != null ? DateFormat('dd/MM/yyyy').format(aviso.expiraEm!) : '-'}',
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
                SizedBox(width: 16.0),
                Row(
                  children: [
                    // Botão visualizar
                    FlutterFlowIconButton(
                      borderRadius: 10.0,
                      buttonSize: 40.0,
                      fillColor: Color(0xFF2196F3),
                      icon: Icon(
                        Icons.visibility_rounded,
                        color: Colors.white,
                        size: 20.0,
                      ),
                      onPressed: () {
                        // Visualizar aviso
                      },
                    ),
                    SizedBox(width: 8.0),
                    // Botão editar
                    FlutterFlowIconButton(
                      borderRadius: 10.0,
                      buttonSize: 40.0,
                      fillColor: Color(0xFFFF9800),
                      icon: Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 20.0,
                      ),
                      onPressed: () {
                        context.pushNamed(
                          'PageEditarAvisoSecretaria',
                          queryParameters: {
                            'avisoId': serializeParam(aviso.id, ParamType.int),
                          },
                        );
                      },
                    ),
                    SizedBox(width: 8.0),
                    // Botão fixar
                    FlutterFlowIconButton(
                      borderRadius: 10.0,
                      buttonSize: 40.0,
                      fillColor: isFixado ? Color(0xFF4CAF50) : Color(0xFF2A2A2A),
                      icon: Icon(
                        Icons.push_pin_rounded,
                        color: Colors.white,
                        size: 20.0,
                      ),
                      onPressed: () async {
                        await AvisoTable().update(
                          data: {'fixado': !isFixado},
                          matchingRows: (rows) => rows.eq('id', aviso.id),
                        );
                        _carregarAvisos();
                      },
                    ),
                    SizedBox(width: 8.0),
                    // Botão excluir
                    FlutterFlowIconButton(
                      borderRadius: 10.0,
                      buttonSize: 40.0,
                      fillColor: Color(0xFFF44336),
                      icon: Icon(
                        Icons.delete_rounded,
                        color: Colors.white,
                        size: 20.0,
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Color(0xFF2A2A2A),
                            title: Text(
                              'Excluir aviso?',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                            content: Text(
                              'Esta ação não pode ser desfeita.',
                              style: GoogleFonts.inter(color: Color(0xFF999999)),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  'Excluir',
                                  style: TextStyle(color: Color(0xFFF44336)),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await AvisoTable().delete(
                            matchingRows: (rows) => rows.eq('id', aviso.id),
                          );
                          _carregarAvisos();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
