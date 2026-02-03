import 'dart:typed_data';
import '/auth/supabase_auth/auth_util.dart';
import '/lider/menu_lider/menu_lider_widget.dart';
import '/lider/menu_lider_mobile/menu_lider_mobile_widget.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_comunidade_lider_model.dart';
export 'page_comunidade_lider_model.dart';

class PageComunidadeLiderWidget extends StatefulWidget {
  const PageComunidadeLiderWidget({super.key});

  static String routeName = 'PageComunidade_Lider';
  static String routePath = '/pageComunidadeLider';

  @override
  State<PageComunidadeLiderWidget> createState() =>
      _PageComunidadeLiderWidgetState();
}

class _PageComunidadeLiderWidgetState extends State<PageComunidadeLiderWidget>
    with SingleTickerProviderStateMixin {
  late PageComunidadeLiderModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  ComunidadeRow? _comunidade;
  MembrosRow? _membroLogado;
  List<MembroComunidadeRow> _membrosComunidade = [];
  Map<String, MembrosRow> _membrosData = {};
  List<AvisoRow> _avisos = [];
  bool _isLoading = true;

  late TabController _tabController;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final TextEditingController _searchAvisosController = TextEditingController();
  String _searchAvisosQuery = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageComunidadeLiderModel());
    _tabController = TabController(length: 2, vsync: this);
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      // Buscar membro logado
      final membroRows = await MembrosTable().queryRows(
        queryFn: (q) => q.eq('id_auth', currentUserUid),
      );

      if (membroRows.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final membroLogado = membroRows.first;

      // Buscar comunidade onde o membro é líder
      final comunidadeRows = await ComunidadeTable().queryRows(
        queryFn: (q) => q.eq('lider_comunidade', membroLogado.idMembro),
      );

      if (comunidadeRows.isEmpty) {
        setState(() {
          _membroLogado = membroLogado;
          _isLoading = false;
        });
        return;
      }

      final comunidade = comunidadeRows.first;

      // Buscar membros da comunidade
      final membrosComunidade = await MembroComunidadeTable().queryRows(
        queryFn: (q) => q.eq('id_comunidade', comunidade.id),
      );

      Map<String, MembrosRow> membrosData = {};
      for (var mc in membrosComunidade) {
        if (mc.idMembro != null) {
          final membroRows = await MembrosTable().queryRows(
            queryFn: (q) => q.eq('id_membro', mc.idMembro!),
          );
          if (membroRows.isNotEmpty) {
            membrosData[mc.idMembro!] = membroRows.first;
          }
        }
      }

      // Buscar apenas avisos criados pelo líder
      final todosAvisos = await AvisoTable().queryRows(
        queryFn: (q) => q.order('created_at', ascending: false),
      );

      // Filtrar apenas avisos criados pelo líder logado
      final avisos = todosAvisos.where(
        (a) => a.criadoPor != null && a.criadoPor == membroLogado.idMembro
      ).toList();

      setState(() {
        _membroLogado = membroLogado;
        _comunidade = comunidade;
        _membrosComunidade = membrosComunidade;
        _membrosData = membrosData;
        _avisos = avisos;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() => _isLoading = false);
    }
  }

  List<MembroComunidadeRow> get _membrosFiltrados {
    if (_searchQuery.isEmpty) return _membrosComunidade;
    return _membrosComunidade.where((mc) {
      final membro = _membrosData[mc.idMembro];
      if (membro == null) return false;
      return membro.nomeMembro.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<AvisoRow> get _avisosFiltrados {
    if (_searchAvisosQuery.isEmpty) return _avisos;
    return _avisos.where((a) {
      return (a.nomeAviso ?? '').toLowerCase().contains(_searchAvisosQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _model.dispose();
    _tabController.dispose();
    _searchController.dispose();
    _searchAvisosController.dispose();
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
        drawer: null,
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

              // Conteudo principal
              Expanded(
                child: Builder(
                  builder: (context) {
                    final isMobile = MediaQuery.sizeOf(context).width < 600;
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        16.0,
                        16.0 + (isMobile ? MediaQuery.of(context).padding.top : 0),
                        16.0,
                        16.0,
                      ),
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
                        : _comunidade == null
                            ? _buildNoComunidade()
                            : _buildConteudo(),
                  ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoComunidade() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_outlined,
            size: 80.0,
            color: Color(0xFF666666),
          ),
          SizedBox(height: 24.0),
          Text(
            'Você não lidera nenhuma comunidade',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.0),
          Text(
            'Entre em contato com a administração\npara ser designado como líder de uma comunidade.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Color(0xFF999999),
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConteudo() {
    return Column(
      children: [
        // Header com informações da comunidade
        _buildHeader(),

        // Tabs
        Container(
          color: Color(0xFF2A2A2A),
          child: TabBar(
            controller: _tabController,
            indicatorColor: FlutterFlowTheme.of(context).primary,
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xFF999999),
            labelStyle: GoogleFonts.inter(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              Tab(
                icon: Icon(Icons.people_rounded),
                text: 'Membros',
              ),
              Tab(
                icon: Icon(Icons.campaign_rounded),
                text: 'Avisos',
              ),
            ],
          ),
        ),

        // Conteúdo das tabs
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMembrosTab(),
              _buildAvisosTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      child: isMobile
          ? Column(
              children: [
                // Foto e nome lado a lado no mobile
                Row(
                  children: [
                    // Botão menu
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
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Color(0xFF3C3D3E),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Icon(
                          Icons.menu_rounded,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Container(
                      width: 56.0,
                      height: 56.0,
                      decoration: BoxDecoration(
                        color: Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: _comunidade?.fotoUrl != null && _comunidade!.fotoUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.network(
                                _comunidade!.fotoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.groups_rounded,
                                  color: Color(0xFF4CAF50),
                                  size: 28.0,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.groups_rounded,
                              color: Color(0xFF4CAF50),
                              size: 28.0,
                            ),
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _comunidade?.nomeComunidade ?? 'Minha Comunidade',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_comunidade?.descricaoComunidade != null &&
                              _comunidade!.descricaoComunidade!.isNotEmpty) ...[
                            SizedBox(height: 4.0),
                            Text(
                              _comunidade!.descricaoComunidade!,
                              style: GoogleFonts.inter(
                                color: Color(0xFF999999),
                                fontSize: 12.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                // Cards de estatísticas abaixo no mobile
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniStatCard(
                        icon: Icons.people_rounded,
                        value: _membrosComunidade.length.toString(),
                        label: 'Membros',
                        color: Color(0xFF2196F3),
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: _buildMiniStatCard(
                        icon: Icons.campaign_rounded,
                        value: _avisos.where((a) =>
                          a.expiraEm != null && a.expiraEm!.isAfter(DateTime.now())
                        ).length.toString(),
                        label: 'Avisos Ativos',
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                // Foto da comunidade
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: _comunidade?.fotoUrl != null && _comunidade!.fotoUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.network(
                            _comunidade!.fotoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.groups_rounded,
                              color: Color(0xFF4CAF50),
                              size: 40.0,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.groups_rounded,
                          color: Color(0xFF4CAF50),
                          size: 40.0,
                        ),
                ),
                SizedBox(width: 20.0),

                // Informações
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _comunidade?.nomeComunidade ?? 'Minha Comunidade',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      if (_comunidade?.descricaoComunidade != null &&
                          _comunidade!.descricaoComunidade!.isNotEmpty)
                        Text(
                          _comunidade!.descricaoComunidade!,
                          style: GoogleFonts.inter(
                            color: Color(0xFF999999),
                            fontSize: 14.0,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),

                // Cards de estatísticas
                Row(
                  children: [
                    _buildMiniStatCard(
                      icon: Icons.people_rounded,
                      value: _membrosComunidade.length.toString(),
                      label: 'Membros',
                      color: Color(0xFF2196F3),
                    ),
                    SizedBox(width: 16.0),
                    _buildMiniStatCard(
                      icon: Icons.campaign_rounded,
                      value: _avisos.where((a) =>
                        a.expiraEm != null && a.expiraEm!.isAfter(DateTime.now())
                      ).length.toString(),
                      label: 'Avisos Ativos',
                      color: Color(0xFF4CAF50),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildMiniStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFF3C3D3E),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.0),
          SizedBox(height: 8.0),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Color(0xFF999999),
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembrosTab() {
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com botão adicionar
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Membros da Comunidade',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.0),
                    SizedBox(
                      width: double.infinity,
                      child: FFButtonWidget(
                        onPressed: () => _mostrarModalAdicionarMembro(),
                        text: 'Adicionar Membro',
                        icon: Icon(Icons.add_rounded, size: 18.0),
                        options: FFButtonOptions(
                          height: 44.0,
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Membros da Comunidade',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    FFButtonWidget(
                      onPressed: () => _mostrarModalAdicionarMembro(),
                      text: 'Adicionar',
                      icon: Icon(Icons.add_rounded, size: 18.0),
                      options: FFButtonOptions(
                        height: 40.0,
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ],
                ),

          SizedBox(height: 16.0),

          // Campo de busca
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Buscar membro...',
              hintStyle: GoogleFonts.inter(
                color: Color(0xFF666666),
                fontSize: 14.0,
              ),
              prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF666666)),
              filled: true,
              fillColor: Color(0xFF2A2A2A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            ),
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
          ),

          SizedBox(height: 16.0),

          // Lista de membros
          if (_membrosFiltrados.isEmpty)
            Container(
              padding: EdgeInsets.all(48.0),
              decoration: BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.people_outline, size: 48.0, color: Color(0xFF666666)),
                    SizedBox(height: 12.0),
                    Text(
                      'Nenhum membro na comunidade',
                      style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 14.0),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _membrosFiltrados.length,
              itemBuilder: (context, index) {
                final mc = _membrosFiltrados[index];
                final membro = _membrosData[mc.idMembro];
                return _buildMembroCard(mc, membro);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMembroCard(MembroComunidadeRow mc, MembrosRow? membro) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: membro?.fotoUrl != null && membro!.fotoUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      membro.fotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          (membro.nomeMembro).substring(0, 1).toUpperCase(),
                          style: GoogleFonts.poppins(
                            color: FlutterFlowTheme.of(context).primary,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      (membro?.nomeMembro ?? 'M').substring(0, 1).toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: FlutterFlowTheme.of(context).primary,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          SizedBox(width: 16.0),

          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  membro?.nomeMembro ?? 'Membro',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (membro?.email != null)
                  Text(
                    membro!.email!,
                    style: GoogleFonts.inter(
                      color: Color(0xFF999999),
                      fontSize: 13.0,
                    ),
                  ),
              ],
            ),
          ),

          // Botão remover
          IconButton(
            onPressed: () => _confirmarRemoverMembro(mc, membro),
            icon: Icon(Icons.remove_circle_outline, color: Color(0xFFF44336)),
            tooltip: 'Remover membro',
          ),
        ],
      ),
    );
  }

  Widget _buildAvisosTab() {
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com botão criar
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meus Avisos',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.0),
                    SizedBox(
                      width: double.infinity,
                      child: FFButtonWidget(
                        onPressed: () => _mostrarModalCriarAviso(),
                        text: 'Novo Aviso',
                        icon: Icon(Icons.add_rounded, size: 18.0),
                        options: FFButtonOptions(
                          height: 44.0,
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Meus Avisos',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    FFButtonWidget(
                      onPressed: () => _mostrarModalCriarAviso(),
                      text: 'Novo Aviso',
                      icon: Icon(Icons.add_rounded, size: 18.0),
                      options: FFButtonOptions(
                        height: 40.0,
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ],
                ),

          SizedBox(height: 16.0),

          // Campo de busca
          TextField(
            controller: _searchAvisosController,
            onChanged: (value) => setState(() => _searchAvisosQuery = value),
            decoration: InputDecoration(
              hintText: 'Buscar aviso...',
              hintStyle: GoogleFonts.inter(
                color: Color(0xFF666666),
                fontSize: 14.0,
              ),
              prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF666666)),
              filled: true,
              fillColor: Color(0xFF2A2A2A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            ),
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
          ),

          SizedBox(height: 16.0),

          // Lista de avisos
          if (_avisosFiltrados.isEmpty)
            Container(
              padding: EdgeInsets.all(48.0),
              decoration: BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.campaign_outlined, size: 48.0, color: Color(0xFF666666)),
                    SizedBox(height: 12.0),
                    Text(
                      'Nenhum aviso criado',
                      style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 14.0),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Clique em "Novo Aviso" para criar',
                      style: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 13.0),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _avisosFiltrados.length,
              itemBuilder: (context, index) {
                final aviso = _avisosFiltrados[index];
                return _buildAvisoCard(aviso);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAvisoCard(AvisoRow aviso) {
    final now = DateTime.now();
    final isAtivo = aviso.expiraEm != null && aviso.expiraEm!.isAfter(now);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isAtivo ? Color(0xFF4CAF50).withOpacity(0.3) : Color(0xFF3A3A3A),
          width: 1.0,
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: título e status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ícone
                    Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: isAtivo
                            ? Color(0xFF4CAF50).withOpacity(0.1)
                            : Color(0xFFF44336).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.campaign_rounded,
                        color: isAtivo ? Color(0xFF4CAF50) : Color(0xFFF44336),
                        size: 20.0,
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            aviso.nomeAviso ?? 'Sem título',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: isAtivo ? Color(0xFF4CAF50) : Color(0xFFF44336),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  isAtivo ? 'ATIVO' : 'EXPIRADO',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 9.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                aviso.categoria ?? 'Geral',
                                style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 11.0),
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                aviso.expiraEm != null
                                    ? dateTimeFormat('dd/MM/yy', aviso.expiraEm!)
                                    : '',
                                style: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 11.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                // Botões de ação
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(
                      icon: Icons.visibility_rounded,
                      color: Color(0xFF2196F3),
                      onTap: () => _mostrarDetalhesAviso(aviso),
                    ),
                    SizedBox(width: 8.0),
                    _buildActionButton(
                      icon: Icons.edit_rounded,
                      color: Color(0xFFFF9800),
                      onTap: () => _mostrarModalEditarAviso(aviso),
                    ),
                    SizedBox(width: 8.0),
                    _buildActionButton(
                      icon: Icons.delete_rounded,
                      color: Color(0xFFF44336),
                      onTap: () => _confirmarExcluirAviso(aviso),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                // Ícone
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: isAtivo
                        ? Color(0xFF4CAF50).withOpacity(0.1)
                        : Color(0xFFF44336).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.campaign_rounded,
                    color: isAtivo ? Color(0xFF4CAF50) : Color(0xFFF44336),
                    size: 24.0,
                  ),
                ),
                SizedBox(width: 16.0),

                // Informações
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
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: isAtivo ? Color(0xFF4CAF50) : Color(0xFFF44336),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              isAtivo ? 'ATIVO' : 'EXPIRADO',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.0),
                      Row(
                        children: [
                          Icon(Icons.category_rounded, color: Color(0xFF666666), size: 14.0),
                          SizedBox(width: 4.0),
                          Text(
                            aviso.categoria ?? 'Geral',
                            style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 12.0),
                          ),
                          SizedBox(width: 12.0),
                          Icon(Icons.event_rounded, color: Color(0xFF666666), size: 14.0),
                          SizedBox(width: 4.0),
                          Text(
                            aviso.expiraEm != null
                                ? dateTimeFormat('dd/MM/yyyy', aviso.expiraEm!)
                                : 'Sem data',
                            style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 12.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Botões de ação
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _mostrarDetalhesAviso(aviso),
                      icon: Icon(Icons.visibility_rounded, color: Color(0xFF2196F3), size: 20.0),
                      tooltip: 'Visualizar',
                    ),
                    IconButton(
                      onPressed: () => _mostrarModalEditarAviso(aviso),
                      icon: Icon(Icons.edit_rounded, color: Color(0xFFFF9800), size: 20.0),
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      onPressed: () => _confirmarExcluirAviso(aviso),
                      icon: Icon(Icons.delete_rounded, color: Color(0xFFF44336), size: 20.0),
                      tooltip: 'Excluir',
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Icon(icon, color: color, size: 18.0),
      ),
    );
  }

  Future<void> _mostrarModalAdicionarMembro() async {
    String? membroSelecionado;
    String searchQuery = '';
    final searchController = TextEditingController();

    // Buscar membros que não estão na comunidade
    final todosMembros = await MembrosTable().queryRows(
      queryFn: (q) => q.eq('ativo', true).order('nome_membro'),
    );

    final membrosNaComunidade = _membrosComunidade.map((mc) => mc.idMembro).toSet();
    final membrosDisponiveis = todosMembros
        .where((m) => !membrosNaComunidade.contains(m.idMembro))
        .toList();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final membrosFiltrados = searchQuery.isEmpty
                ? membrosDisponiveis
                : membrosDisponiveis.where((m) =>
                    m.nomeMembro.toLowerCase().contains(searchQuery.toLowerCase())
                  ).toList();

            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 450.0,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.8,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Icon(
                              Icons.person_add_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 24.0,
                            ),
                          ),
                          SizedBox(width: 14.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Adicionar Membro',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${membrosDisponiveis.length} membros disponíveis',
                                  style: GoogleFonts.inter(
                                    color: Color(0xFF888888),
                                    fontSize: 13.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(dialogContext),
                            borderRadius: BorderRadius.circular(10.0),
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Color(0xFF3A3A3A),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Icon(Icons.close_rounded, color: Color(0xFF999999), size: 20.0),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Campo de busca
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) => setDialogState(() => searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Buscar membro...',
                          hintStyle: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 14.0),
                          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF666666)),
                          filled: true,
                          fillColor: Color(0xFF2A2A2A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        ),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                      ),
                    ),

                    // Lista de membros
                    Flexible(
                      child: membrosFiltrados.isEmpty
                          ? Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search_off_rounded, size: 48.0, color: Color(0xFF555555)),
                                  SizedBox(height: 12.0),
                                  Text(
                                    'Nenhum membro encontrado',
                                    style: GoogleFonts.inter(color: Color(0xFF888888), fontSize: 14.0),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              itemCount: membrosFiltrados.length,
                              itemBuilder: (context, index) {
                                final membro = membrosFiltrados[index];
                                final isSelected = membroSelecionado == membro.idMembro;

                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8.0),
                                  child: InkWell(
                                    onTap: () => setDialogState(() => membroSelecionado = membro.idMembro),
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: Container(
                                      padding: EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? FlutterFlowTheme.of(context).primary.withOpacity(0.15)
                                            : Color(0xFF2A2A2A),
                                        borderRadius: BorderRadius.circular(12.0),
                                        border: Border.all(
                                          color: isSelected
                                              ? FlutterFlowTheme.of(context).primary
                                              : Colors.transparent,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 44.0,
                                            height: 44.0,
                                            decoration: BoxDecoration(
                                              color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: membro.fotoUrl != null && membro.fotoUrl!.isNotEmpty
                                                ? ClipOval(
                                                    child: Image.network(
                                                      membro.fotoUrl!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) => Center(
                                                        child: Text(
                                                          membro.nomeMembro.substring(0, 1).toUpperCase(),
                                                          style: GoogleFonts.poppins(
                                                            color: FlutterFlowTheme.of(context).primary,
                                                            fontSize: 16.0,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Center(
                                                    child: Text(
                                                      membro.nomeMembro.substring(0, 1).toUpperCase(),
                                                      style: GoogleFonts.poppins(
                                                        color: FlutterFlowTheme.of(context).primary,
                                                        fontSize: 16.0,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                          SizedBox(width: 12.0),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  membro.nomeMembro,
                                                  style: GoogleFonts.inter(
                                                    color: Colors.white,
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                if (membro.email != null)
                                                  Text(
                                                    membro.email!,
                                                    style: GoogleFonts.inter(
                                                      color: Color(0xFF888888),
                                                      fontSize: 12.0,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          if (isSelected)
                                            Container(
                                              padding: EdgeInsets.all(4.0),
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(context).primary,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(Icons.check_rounded, color: Colors.white, size: 16.0),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    // Botões
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 14.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: Text(
                                'Cancelar',
                                style: GoogleFonts.inter(color: Color(0xFF999999), fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.0),
                          Expanded(
                            flex: 2,
                            child: FFButtonWidget(
                              onPressed: membroSelecionado != null
                                  ? () async {
                                      await MembroComunidadeTable().insert({
                                        'id_comunidade': _comunidade!.id,
                                        'id_membro': membroSelecionado,
                                      });
                                      Navigator.pop(dialogContext);
                                      setState(() => _isLoading = true);
                                      _carregarDados();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Membro adicionado com sucesso!'),
                                          backgroundColor: FlutterFlowTheme.of(context).success,
                                        ),
                                      );
                                    }
                                  : null,
                              text: 'Adicionar Membro',
                              icon: Icon(Icons.add_rounded, size: 20.0),
                              options: FFButtonOptions(
                                height: 48.0,
                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                                disabledColor: Color(0xFF3A3A3A),
                                disabledTextColor: Color(0xFF666666),
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
          },
        );
      },
    );
  }

  Future<void> _confirmarRemoverMembro(MembroComunidadeRow mc, MembrosRow? membro) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Text(
            'Remover Membro',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Deseja remover ${membro?.nomeMembro ?? 'este membro'} da comunidade?',
            style: GoogleFonts.inter(color: Color(0xFF999999)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('Cancelar', style: GoogleFonts.inter(color: Color(0xFF999999))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(backgroundColor: Color(0xFFF44336).withOpacity(0.1)),
              child: Text('Remover', style: GoogleFonts.inter(color: Color(0xFFF44336), fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirmar) {
      await MembroComunidadeTable().delete(
        matchingRows: (rows) => rows.eq('id', mc.id),
      );
      setState(() => _isLoading = true);
      _carregarDados();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Membro removido com sucesso!'),
          backgroundColor: FlutterFlowTheme.of(context).success,
        ),
      );
    }
  }

  Future<void> _mostrarModalCriarAviso() async {
    final nomeController = TextEditingController();
    final descricaoController = TextEditingController();
    final descricaoResumidaController = TextEditingController();
    DateTime? dataHoraAviso;
    DateTime? dataExpiracao;
    Uint8List? imagemBytes;
    String? imagemNome;
    bool isUploading = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 600.0,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.9,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Novo Aviso',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: Icon(Icons.close_rounded, color: Color(0xFF666666)),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.0),

                      // Nome do aviso
                      _buildInputLabel('Nome do Aviso *'),
                      SizedBox(height: 8.0),
                      _buildTextField(nomeController, 'Digite o nome do aviso'),

                      SizedBox(height: 16.0),

                      // Data e hora do aviso
                      _buildInputLabel('Data e Hora do Evento'),
                      SizedBox(height: 8.0),
                      InkWell(
                        onTap: () async {
                          final data = await showDatePicker(
                            context: dialogContext,
                            initialDate: dataHoraAviso ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(Duration(days: 30)),
                            lastDate: DateTime.now().add(Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: ColorScheme.dark(
                                    primary: FlutterFlowTheme.of(context).primary,
                                    surface: Color(0xFF2A2A2A),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (data != null) {
                            final hora = await showTimePicker(
                              context: dialogContext,
                              initialTime: TimeOfDay.fromDateTime(dataHoraAviso ?? DateTime.now()),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme: ColorScheme.dark(
                                      primary: FlutterFlowTheme.of(context).primary,
                                      surface: Color(0xFF2A2A2A),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (hora != null) {
                              setDialogState(() {
                                dataHoraAviso = DateTime(
                                  data.year,
                                  data.month,
                                  data.day,
                                  hora.hour,
                                  hora.minute,
                                );
                              });
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                          decoration: BoxDecoration(
                            color: Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: Color(0xFF3A3A3A)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.event_rounded, color: Color(0xFF666666), size: 20.0),
                              SizedBox(width: 12.0),
                              Expanded(
                                child: Text(
                                  dataHoraAviso != null
                                      ? dateTimeFormat('dd/MM/yyyy \'às\' HH:mm', dataHoraAviso!)
                                      : 'Selecione data e hora',
                                  style: GoogleFonts.inter(
                                    color: dataHoraAviso != null ? Colors.white : Color(0xFF666666),
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                              if (dataHoraAviso != null)
                                InkWell(
                                  onTap: () => setDialogState(() => dataHoraAviso = null),
                                  child: Icon(Icons.clear_rounded, color: Color(0xFF666666), size: 18.0),
                                ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16.0),

                      // Data de expiração
                      _buildInputLabel('Data de Expiração'),
                      SizedBox(height: 8.0),
                      InkWell(
                        onTap: () async {
                          final data = await showDatePicker(
                            context: dialogContext,
                            initialDate: dataExpiracao ?? DateTime.now().add(Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: ColorScheme.dark(
                                    primary: FlutterFlowTheme.of(context).primary,
                                    surface: Color(0xFF2A2A2A),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (data != null) {
                            setDialogState(() => dataExpiracao = data);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                          decoration: BoxDecoration(
                            color: Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: Color(0xFF3A3A3A)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, color: Color(0xFF666666), size: 20.0),
                              SizedBox(width: 12.0),
                              Expanded(
                                child: Text(
                                  dataExpiracao != null
                                      ? dateTimeFormat('dd/MM/yyyy', dataExpiracao!)
                                      : 'Selecione uma data',
                                  style: GoogleFonts.inter(
                                    color: dataExpiracao != null ? Colors.white : Color(0xFF666666),
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                              if (dataExpiracao != null)
                                InkWell(
                                  onTap: () => setDialogState(() => dataExpiracao = null),
                                  child: Icon(Icons.clear_rounded, color: Color(0xFF666666), size: 18.0),
                                ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16.0),

                      // Descrição resumida
                      _buildInputLabel('Descrição Resumida'),
                      SizedBox(height: 8.0),
                      _buildTextField(descricaoResumidaController, 'Breve descrição do aviso', maxLines: 2),

                      SizedBox(height: 16.0),

                      // Descrição completa
                      _buildInputLabel('Descrição Completa'),
                      SizedBox(height: 8.0),
                      _buildTextField(descricaoController, 'Descrição detalhada do aviso', maxLines: 4),

                      SizedBox(height: 16.0),

                      // Imagem
                      _buildInputLabel('Imagem (opcional)'),
                      SizedBox(height: 8.0),
                      InkWell(
                        onTap: () async {
                          final selectedMedia = await selectMediaWithSourceBottomSheet(
                            context: dialogContext,
                            allowPhoto: true,
                            backgroundColor: Color(0xFF2A2A2A),
                            textColor: Colors.white,
                          );
                          if (selectedMedia != null && selectedMedia.isNotEmpty) {
                            setDialogState(() {
                              imagemBytes = selectedMedia.first.bytes;
                              imagemNome = selectedMedia.first.storagePath.split('/').last;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 120.0,
                          decoration: BoxDecoration(
                            color: Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Color(0xFF3A3A3A),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: imagemBytes != null
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(11.0),
                                      child: Image.memory(
                                        imagemBytes!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8.0,
                                      right: 8.0,
                                      child: IconButton(
                                        onPressed: () => setDialogState(() {
                                          imagemBytes = null;
                                          imagemNome = null;
                                        }),
                                        icon: Icon(Icons.close_rounded, color: Colors.white),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF666666), size: 32.0),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Clique para adicionar imagem',
                                      style: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 13.0),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      SizedBox(height: 24.0),

                      // Botões
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: Text('Cancelar', style: GoogleFonts.inter(color: Color(0xFF999999))),
                          ),
                          SizedBox(width: 12.0),
                          FFButtonWidget(
                            onPressed: isUploading
                                ? null
                                : () async {
                                    if (nomeController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                                        SnackBar(content: Text('Informe o nome do aviso'), backgroundColor: Colors.orange),
                                      );
                                      return;
                                    }

                                    setDialogState(() => isUploading = true);

                                    String? imagemUrl;
                                    if (imagemBytes != null) {
                                      final storagePath = 'avisos/${DateTime.now().microsecondsSinceEpoch}_${imagemNome ?? 'imagem.jpg'}';
                                      final selectedFile = SelectedFile(
                                        storagePath: storagePath,
                                        bytes: imagemBytes!,
                                        originalFilename: imagemNome ?? 'imagem.jpg',
                                      );
                                      imagemUrl = await uploadSupabaseStorageFile(
                                        bucketName: 'arquivos',
                                        selectedFile: selectedFile,
                                      );
                                    }

                                    await AvisoTable().insert({
                                      'nome_aviso': nomeController.text.trim(),
                                      'descricao': descricaoController.text.trim().isNotEmpty ? descricaoController.text.trim() : null,
                                      'descricao_resumida': descricaoResumidaController.text.trim().isNotEmpty ? descricaoResumidaController.text.trim() : null,
                                      'categoria': 'Comunidade',
                                      'criado_por': _membroLogado?.idMembro,
                                      'data_hora_aviso': dataHoraAviso?.add(Duration(hours: 3)).toIso8601String(),
                                      'expira_em': dataExpiracao?.add(Duration(hours: 3)).toIso8601String(),
                                      'imagem': imagemUrl,
                                      'fixado': false,
                                    });

                                    Navigator.pop(dialogContext);
                                    setState(() => _isLoading = true);
                                    _carregarDados();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Aviso criado com sucesso!'),
                                        backgroundColor: FlutterFlowTheme.of(context).success,
                                      ),
                                    );
                                  },
                            text: isUploading ? 'Salvando...' : 'Criar Aviso',
                            options: FFButtonOptions(
                              height: 44.0,
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                              borderRadius: BorderRadius.circular(10.0),
                              disabledColor: Color(0xFF3A3A3A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _mostrarModalEditarAviso(AvisoRow aviso) async {
    final nomeController = TextEditingController(text: aviso.nomeAviso ?? '');
    final descricaoController = TextEditingController(text: aviso.descricao ?? '');
    final descricaoResumidaController = TextEditingController(text: aviso.descricaoResumida ?? '');
    DateTime? dataHoraAviso = aviso.dataHoraAviso;
    DateTime? dataExpiracao = aviso.expiraEm;
    bool isUploading = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 600.0,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.9,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Editar Aviso',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: Icon(Icons.close_rounded, color: Color(0xFF666666)),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.0),

                      _buildInputLabel('Nome do Aviso *'),
                      SizedBox(height: 8.0),
                      _buildTextField(nomeController, 'Digite o nome do aviso'),

                      SizedBox(height: 16.0),

                      // Data e hora do aviso
                      _buildInputLabel('Data e Hora do Evento'),
                      SizedBox(height: 8.0),
                      InkWell(
                        onTap: () async {
                          final data = await showDatePicker(
                            context: dialogContext,
                            initialDate: dataHoraAviso ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(Duration(days: 30)),
                            lastDate: DateTime.now().add(Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: ColorScheme.dark(
                                    primary: FlutterFlowTheme.of(context).primary,
                                    surface: Color(0xFF2A2A2A),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (data != null) {
                            final hora = await showTimePicker(
                              context: dialogContext,
                              initialTime: TimeOfDay.fromDateTime(dataHoraAviso ?? DateTime.now()),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme: ColorScheme.dark(
                                      primary: FlutterFlowTheme.of(context).primary,
                                      surface: Color(0xFF2A2A2A),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (hora != null) {
                              setDialogState(() {
                                dataHoraAviso = DateTime(
                                  data.year,
                                  data.month,
                                  data.day,
                                  hora.hour,
                                  hora.minute,
                                );
                              });
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                          decoration: BoxDecoration(
                            color: Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: Color(0xFF3A3A3A)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.event_rounded, color: Color(0xFF666666), size: 20.0),
                              SizedBox(width: 12.0),
                              Expanded(
                                child: Text(
                                  dataHoraAviso != null
                                      ? dateTimeFormat('dd/MM/yyyy \'às\' HH:mm', dataHoraAviso!)
                                      : 'Selecione data e hora',
                                  style: GoogleFonts.inter(
                                    color: dataHoraAviso != null ? Colors.white : Color(0xFF666666),
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                              if (dataHoraAviso != null)
                                InkWell(
                                  onTap: () => setDialogState(() => dataHoraAviso = null),
                                  child: Icon(Icons.clear_rounded, color: Color(0xFF666666), size: 18.0),
                                ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16.0),

                      _buildInputLabel('Data de Expiração'),
                      SizedBox(height: 8.0),
                      InkWell(
                        onTap: () async {
                          final data = await showDatePicker(
                            context: dialogContext,
                            initialDate: dataExpiracao ?? DateTime.now().add(Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: ColorScheme.dark(
                                    primary: FlutterFlowTheme.of(context).primary,
                                    surface: Color(0xFF2A2A2A),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (data != null) {
                            setDialogState(() => dataExpiracao = data);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                          decoration: BoxDecoration(
                            color: Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: Color(0xFF3A3A3A)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, color: Color(0xFF666666), size: 20.0),
                              SizedBox(width: 12.0),
                              Expanded(
                                child: Text(
                                  dataExpiracao != null
                                      ? dateTimeFormat('dd/MM/yyyy', dataExpiracao!)
                                      : 'Selecione uma data',
                                  style: GoogleFonts.inter(
                                    color: dataExpiracao != null ? Colors.white : Color(0xFF666666),
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                              if (dataExpiracao != null)
                                InkWell(
                                  onTap: () => setDialogState(() => dataExpiracao = null),
                                  child: Icon(Icons.clear_rounded, color: Color(0xFF666666), size: 18.0),
                                ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16.0),

                      _buildInputLabel('Descrição Resumida'),
                      SizedBox(height: 8.0),
                      _buildTextField(descricaoResumidaController, 'Breve descrição do aviso', maxLines: 2),

                      SizedBox(height: 16.0),

                      _buildInputLabel('Descrição Completa'),
                      SizedBox(height: 8.0),
                      _buildTextField(descricaoController, 'Descrição detalhada do aviso', maxLines: 4),

                      SizedBox(height: 24.0),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: Text('Cancelar', style: GoogleFonts.inter(color: Color(0xFF999999))),
                          ),
                          SizedBox(width: 12.0),
                          FFButtonWidget(
                            onPressed: isUploading
                                ? null
                                : () async {
                                    if (nomeController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                                        SnackBar(content: Text('Informe o nome do aviso'), backgroundColor: Colors.orange),
                                      );
                                      return;
                                    }

                                    setDialogState(() => isUploading = true);

                                    await AvisoTable().update(
                                      data: {
                                        'nome_aviso': nomeController.text.trim(),
                                        'descricao': descricaoController.text.trim().isNotEmpty ? descricaoController.text.trim() : null,
                                        'descricao_resumida': descricaoResumidaController.text.trim().isNotEmpty ? descricaoResumidaController.text.trim() : null,
                                        'categoria': 'Comunidade',
                                        'data_hora_aviso': dataHoraAviso?.add(Duration(hours: 3)).toIso8601String(),
                                        'expira_em': dataExpiracao?.add(Duration(hours: 3)).toIso8601String(),
                                      },
                                      matchingRows: (rows) => rows.eq('id', aviso.id),
                                    );

                                    Navigator.pop(dialogContext);
                                    setState(() => _isLoading = true);
                                    _carregarDados();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Aviso atualizado com sucesso!'),
                                        backgroundColor: FlutterFlowTheme.of(context).success,
                                      ),
                                    );
                                  },
                            text: isUploading ? 'Salvando...' : 'Salvar',
                            options: FFButtonOptions(
                              height: 44.0,
                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                              borderRadius: BorderRadius.circular(10.0),
                              disabledColor: Color(0xFF3A3A3A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _mostrarDetalhesAviso(AvisoRow aviso) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 500.0,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16.0),
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
                            aviso.nomeAviso ?? 'Sem título',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: Icon(Icons.close_rounded, color: Color(0xFF666666)),
                        ),
                      ],
                    ),
                  ),

                  // Imagem
                  if (aviso.imagem != null && aviso.imagem!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(
                          aviso.imagem!,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => SizedBox.shrink(),
                        ),
                      ),
                    ),

                  // Conteúdo
                  Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: aviso.expiraEm != null && aviso.expiraEm!.isAfter(DateTime.now())
                                    ? Color(0xFF4CAF50)
                                    : Color(0xFFF44336),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                aviso.expiraEm != null && aviso.expiraEm!.isAfter(DateTime.now())
                                    ? 'ATIVO'
                                    : 'EXPIRADO',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.0),
                            if (aviso.categoria != null)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Text(
                                  aviso.categoria!,
                                  style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 12.0),
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: 20.0),

                        // Datas
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, color: Color(0xFF666666), size: 16.0),
                            SizedBox(width: 8.0),
                            Text(
                              'Criado: ${dateTimeFormat('dd/MM/yyyy', aviso.createdAt)}',
                              style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 13.0),
                            ),
                            SizedBox(width: 20.0),
                            Icon(Icons.event_busy_rounded, color: Color(0xFF666666), size: 16.0),
                            SizedBox(width: 8.0),
                            Text(
                              'Expira: ${aviso.expiraEm != null ? dateTimeFormat('dd/MM/yyyy', aviso.expiraEm!) : 'N/A'}',
                              style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 13.0),
                            ),
                          ],
                        ),

                        if (aviso.descricaoResumida != null && aviso.descricaoResumida!.isNotEmpty) ...[
                          SizedBox(height: 20.0),
                          Text('Resumo', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w600)),
                          SizedBox(height: 8.0),
                          Text(aviso.descricaoResumida!, style: GoogleFonts.inter(color: Color(0xFFCCCCCC), fontSize: 14.0, height: 1.5)),
                        ],

                        if (aviso.descricao != null && aviso.descricao!.isNotEmpty) ...[
                          SizedBox(height: 20.0),
                          Text('Descrição Completa', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w600)),
                          SizedBox(height: 8.0),
                          Text(aviso.descricao!, style: GoogleFonts.inter(color: Color(0xFFCCCCCC), fontSize: 14.0, height: 1.5)),
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

  Future<void> _confirmarExcluirAviso(AvisoRow aviso) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Text('Excluir Aviso', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          content: Text('Deseja realmente excluir este aviso?', style: GoogleFonts.inter(color: Color(0xFF999999))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('Cancelar', style: GoogleFonts.inter(color: Color(0xFF999999))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(backgroundColor: Color(0xFFF44336).withOpacity(0.1)),
              child: Text('Excluir', style: GoogleFonts.inter(color: Color(0xFFF44336), fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirmar) {
      try {
        // Deletar curtidas relacionadas
        await CurtidasTable().delete(
          matchingRows: (rows) => rows.eq('aviso_id', aviso.id),
        );
        // Deletar o aviso
        await AvisoTable().delete(
          matchingRows: (rows) => rows.eq('id', aviso.id),
        );

        setState(() => _isLoading = true);
        _carregarDados();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aviso excluído com sucesso!'), backgroundColor: FlutterFlowTheme.of(context).success),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 14.0),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 14.0),
        filled: true,
        fillColor: Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Color(0xFF3A3A3A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Color(0xFF3A3A3A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary, width: 2.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
    );
  }
}
