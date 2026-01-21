import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageAvisosSecretariaModel());
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
                    child: FutureBuilder<List<AvisoRow>>(
                      key: ValueKey(_model.refreshKey),
                      future: AvisoTable().queryRows(
                        queryFn: (q) => q.order('created_at', ascending: false),
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          );
                        }

                        List<AvisoRow> avisos = snapshot.data!;

                        // Calcular estatisticas
                        final now = DateTime.now();
                        final avisosAtivos = avisos.where((a) =>
                          a.expiraEm != null && a.expiraEm!.isAfter(now)
                        ).length;
                        final avisosExpirados = avisos.where((a) =>
                          a.expiraEm != null && a.expiraEm!.isBefore(now)
                        ).length;
                        final avisosFixados = avisos.where((a) =>
                          (a.fixado ?? false) && a.expiraEm != null && a.expiraEm!.isAfter(now)
                        ).length;

                        // Aplicar filtros
                        List<AvisoRow> avisosFiltrados = avisos.where((aviso) {
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
                            if (_model.filtroStatus == 'ativo' && !isAtivo) {
                              return false;
                            }
                            if (_model.filtroStatus == 'expirado' && isAtivo) {
                              return false;
                            }
                            if (_model.filtroStatus == 'fixado' && !(aviso.fixado ?? false)) {
                              return false;
                            }
                          }

                          return true;
                        }).toList();

                        return SingleChildScrollView(
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
                                          'Gerencie os avisos da igreja',
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
                                          extra: <String, dynamic>{
                                            kTransitionInfoKey: TransitionInfo(
                                              hasTransition: true,
                                              transitionType: PageTransitionType.fade,
                                            ),
                                          },
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

                              // Cards de estatisticas
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        icon: Icons.visibility_rounded,
                                        title: 'Ativos',
                                        value: avisosAtivos.toString(),
                                        color: Color(0xFF4CAF50),
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
                                        color: Color(0xFF2196F3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 32.0),

                              // Campo de busca e filtros
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Campo de busca
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xFF1A1A1A),
                                        borderRadius: BorderRadius.circular(12.0),
                                        border: Border.all(
                                          color: Color(0xFF2A2A2A),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: TextFormField(
                                        controller: _model.searchController,
                                        focusNode: _model.searchFocusNode,
                                        onChanged: (value) => setState(() {}),
                                        decoration: InputDecoration(
                                          hintText: 'Buscar avisos...',
                                          hintStyle: GoogleFonts.inter(
                                            color: Color(0xFF666666),
                                            fontSize: 14.0,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.search_rounded,
                                            color: Color(0xFF666666),
                                          ),
                                          suffixIcon: _model.searchController!.text.isNotEmpty
                                            ? IconButton(
                                                icon: Icon(Icons.clear_rounded, color: Color(0xFF666666)),
                                                onPressed: () {
                                                  _model.searchController?.clear();
                                                  setState(() {});
                                                },
                                              )
                                            : null,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                        ),
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 16.0),

                                    // Chips de filtro
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          _buildFilterChip(
                                            label: 'Todos',
                                            isSelected: _model.filtroStatus == null,
                                            onTap: () {
                                              setState(() {
                                                _model.filtroStatus = null;
                                              });
                                            },
                                          ),
                                          SizedBox(width: 12.0),
                                          _buildFilterChip(
                                            label: 'Ativos',
                                            icon: Icons.visibility_rounded,
                                            isSelected: _model.filtroStatus == 'ativo',
                                            onTap: () {
                                              setState(() {
                                                _model.filtroStatus = _model.filtroStatus == 'ativo' ? null : 'ativo';
                                              });
                                            },
                                          ),
                                          SizedBox(width: 12.0),
                                          _buildFilterChip(
                                            label: 'Expirados',
                                            icon: Icons.event_busy_rounded,
                                            isSelected: _model.filtroStatus == 'expirado',
                                            onTap: () {
                                              setState(() {
                                                _model.filtroStatus = _model.filtroStatus == 'expirado' ? null : 'expirado';
                                              });
                                            },
                                          ),
                                          SizedBox(width: 12.0),
                                          _buildFilterChip(
                                            label: 'Fixados',
                                            icon: Icons.push_pin_rounded,
                                            isSelected: _model.filtroStatus == 'fixado',
                                            onTap: () {
                                              setState(() {
                                                _model.filtroStatus = _model.filtroStatus == 'fixado' ? null : 'fixado';
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 24.0),

                              // Lista de avisos
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Todos os Avisos',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 16.0),

                                    avisosFiltrados.isEmpty
                                      ? Container(
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
                                                  Icons.campaign_rounded,
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
                                                  'Clique em "Novo Aviso" para criar',
                                                  style: GoogleFonts.inter(
                                                    color: Color(0xFF666666),
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: avisosFiltrados.length,
                                          itemBuilder: (context, index) {
                                            final aviso = avisosFiltrados[index];
                                            return _buildAvisoCard(context, aviso);
                                          },
                                        ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 32.0),
                            ],
                          ),
                        );
                      },
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

  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? FlutterFlowTheme.of(context).primary : Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? FlutterFlowTheme.of(context).primary : Color(0xFF2A2A2A),
            width: 1.0,
          ),
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
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvisoCard(BuildContext context, AvisoRow aviso) {
    final now = DateTime.now();
    final isAtivo = aviso.expiraEm != null && aviso.expiraEm!.isAfter(now);
    final isFixado = aviso.fixado ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isFixado ? FlutterFlowTheme.of(context).primary.withOpacity(0.5) : Color(0xFF2A2A2A),
          width: isFixado ? 2.0 : 1.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Icone
            Container(
              width: 56.0,
              height: 56.0,
              decoration: BoxDecoration(
                color: isAtivo
                  ? Color(0xFF4CAF50).withOpacity(0.1)
                  : Color(0xFFF44336).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFixado ? Icons.push_pin_rounded : Icons.campaign_rounded,
                color: isAtivo ? Color(0xFF4CAF50) : Color(0xFFF44336),
                size: 28.0,
              ),
            ),
            SizedBox(width: 16.0),

            // Informacoes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          aviso.nomeAviso ?? 'Sem titulo',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 12.0),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: isAtivo ? Color(0xFF4CAF50) : Color(0xFFF44336),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          isAtivo ? 'ATIVO' : 'EXPIRADO',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 11.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.category_rounded, color: Color(0xFF666666), size: 14.0),
                      SizedBox(width: 6.0),
                      Text(
                        aviso.categoria ?? 'Geral',
                        style: GoogleFonts.inter(
                          color: Color(0xFF999999),
                          fontSize: 13.0,
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Icon(Icons.event_rounded, color: Color(0xFF666666), size: 14.0),
                      SizedBox(width: 6.0),
                      Text(
                        aviso.expiraEm != null
                          ? dateTimeFormat('dd/MM/yyyy', aviso.expiraEm!)
                          : 'Sem data',
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

            // Botoes de acao
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botao Visualizar
                _buildActionButton(
                  icon: Icons.visibility_rounded,
                  color: Color(0xFF2196F3),
                  onPressed: () => _showAvisoDetails(context, aviso, isAtivo),
                ),
                SizedBox(width: 8.0),
                // Botao Editar
                _buildActionButton(
                  icon: Icons.edit_rounded,
                  color: Color(0xFFFF9800),
                  onPressed: () {
                    context.pushNamed(
                      PageNovoAvisoSecretariaWidget.routeName,
                      queryParameters: {
                        'avisoId': serializeParam(aviso.id, ParamType.int),
                      }.withoutNulls,
                      extra: <String, dynamic>{
                        kTransitionInfoKey: TransitionInfo(
                          hasTransition: true,
                          transitionType: PageTransitionType.fade,
                        ),
                      },
                    );
                  },
                ),
                SizedBox(width: 8.0),
                // Botao Fixar
                _buildActionButton(
                  icon: Icons.push_pin_rounded,
                  color: isFixado ? Color(0xFF4CAF50) : Color(0xFF666666),
                  onPressed: () => _toggleFixado(context, aviso, isAtivo),
                ),
                SizedBox(width: 8.0),
                // Botao Excluir
                _buildActionButton(
                  icon: Icons.delete_rounded,
                  color: Color(0xFFF44336),
                  onPressed: () => _confirmDelete(context, aviso),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          width: 36.0,
          height: 36.0,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18.0,
          ),
        ),
      ),
    );
  }

  Future<void> _showAvisoDetails(BuildContext context, AvisoRow aviso, bool isAtivo) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 600.0,
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.9,
            ),
            decoration: BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: Color(0xFF2A2A2A),
                width: 1.0,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            aviso.nomeAviso ?? 'Sem titulo',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: Color(0xFF666666)),
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ],
                    ),
                  ),

                  // Imagem
                  if (aviso.imagem != null && aviso.imagem!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxHeight: 350.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: Color(0xFF2A2A2A),
                            width: 1.0,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11.0),
                          child: Image.network(
                            aviso.imagem!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200.0,
                                color: Color(0xFF2A2A2A),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported_rounded,
                                        color: Color(0xFF666666),
                                        size: 48.0,
                                      ),
                                      SizedBox(height: 8.0),
                                      Text(
                                        'Imagem indisponivel',
                                        style: GoogleFonts.inter(
                                          color: Color(0xFF666666),
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                  // Conteudo
                  Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge de status
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: isAtivo ? Color(0xFF4CAF50) : Color(0xFFF44336),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Text(
                            isAtivo ? 'ATIVO' : 'EXPIRADO',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),

                        // Informacoes
                        _buildDetailRow(Icons.category_rounded, 'Categoria', aviso.categoria ?? 'N/A'),
                        SizedBox(height: 12.0),
                        _buildDetailRow(Icons.calendar_today_rounded, 'Criado em',
                          dateTimeFormat('dd/MM/yyyy HH:mm', aviso.createdAt)),
                        SizedBox(height: 12.0),
                        _buildDetailRow(Icons.event_busy_rounded, 'Expira em',
                          aviso.expiraEm != null ? dateTimeFormat('dd/MM/yyyy HH:mm', aviso.expiraEm!) : 'N/A'),

                        // Descricao resumida
                        if (aviso.descricaoResumida != null && aviso.descricaoResumida!.isNotEmpty) ...[
                          SizedBox(height: 24.0),
                          Text(
                            'Resumo',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            aviso.descricaoResumida!,
                            style: GoogleFonts.inter(
                              color: Color(0xFFCCCCCC),
                              fontSize: 14.0,
                              height: 1.5,
                            ),
                          ),
                        ],

                        // Descricao completa
                        if (aviso.descricao != null && aviso.descricao!.isNotEmpty) ...[
                          SizedBox(height: 24.0),
                          Text(
                            'Descricao Completa',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            aviso.descricao!,
                            style: GoogleFonts.inter(
                              color: Color(0xFFCCCCCC),
                              fontSize: 14.0,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF666666), size: 18.0),
        SizedBox(width: 12.0),
        Text(
          '$label: ',
          style: GoogleFonts.inter(
            color: Color(0xFF999999),
            fontSize: 14.0,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14.0,
          ),
        ),
      ],
    );
  }

  Future<void> _toggleFixado(BuildContext context, AvisoRow aviso, bool isAtivo) async {
    // Se o aviso esta expirado, nao permite fixar
    if (!isAtivo) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nao e possivel fixar um aviso expirado!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Alternar o estado de fixado
    final novoEstadoFixado = !(aviso.fixado ?? false);

    await AvisoTable().update(
      data: {'fixado': novoEstadoFixado},
      matchingRows: (rows) => rows.eq('id', aviso.id),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          novoEstadoFixado
            ? 'Aviso fixado com sucesso!'
            : 'Aviso desfixado com sucesso!'
        ),
        backgroundColor: FlutterFlowTheme.of(context).success,
      ),
    );

    setState(() {
      _model.refreshKey++;
    });
  }

  Future<void> _confirmDelete(BuildContext context, AvisoRow aviso) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (alertDialogContext) {
        return AlertDialog(
          backgroundColor: Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            'Confirmar exclusao',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Deseja realmente excluir este aviso?',
            style: GoogleFonts.inter(
              color: Color(0xFF999999),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext, false),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(
                  color: Color(0xFF999999),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext, true),
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFFF44336).withOpacity(0.1),
              ),
              child: Text(
                'Excluir',
                style: GoogleFonts.inter(
                  color: Color(0xFFF44336),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirmDelete) {
      try {
        // Primeiro, deletar as curtidas relacionadas
        await CurtidasTable().delete(
          matchingRows: (rows) => rows.eq('aviso_id', aviso.id),
        );
        // Depois, deletar o aviso
        await AvisoTable().delete(
          matchingRows: (rows) => rows.eq('id', aviso.id),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aviso excluido com sucesso!'),
            backgroundColor: FlutterFlowTheme.of(context).success,
          ),
        );

        setState(() {
          _model.refreshKey++;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
