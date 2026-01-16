import '/admin/menu_admin/menu_admin_widget.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_ministerios_admin_detalhes_model.dart';
export 'page_ministerios_admin_detalhes_model.dart';

class PageMinisteriosAdminDetalhesWidget extends StatefulWidget {
  const PageMinisteriosAdminDetalhesWidget({
    super.key,
    required this.idministerio,
  });

  final int? idministerio;

  static String routeName = 'PageMinisterios_Admin_Detalhes';
  static String routePath = '/pageMinisteriosAdminDetalhes';

  @override
  State<PageMinisteriosAdminDetalhesWidget> createState() =>
      _PageMinisteriosAdminDetalhesWidgetState();
}

class _PageMinisteriosAdminDetalhesWidgetState
    extends State<PageMinisteriosAdminDetalhesWidget> {
  late PageMinisteriosAdminDetalhesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  MinisterioRow? _ministerio;
  MembrosRow? _lider;
  List<MembrosMinisteriosRow> _membrosMinisterio = [];
  Map<String, MembrosRow> _membrosData = {};
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageMinisteriosAdminDetalhesModel());

    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final ministerioRows = await MinisterioTable().queryRows(
        queryFn: (q) => q.eq('id_ministerio', widget.idministerio!),
      );

      if (ministerioRows.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final ministerio = ministerioRows.first;

      MembrosRow? lider;
      if (ministerio.idLider != null) {
        final liderRows = await MembrosTable().queryRows(
          queryFn: (q) => q.eq('id_membro', ministerio.idLider!),
        );
        if (liderRows.isNotEmpty) {
          lider = liderRows.first;
        }
      }

      final membrosMinisterio = await MembrosMinisteriosTable().queryRows(
        queryFn: (q) => q.eq('id_ministerio', widget.idministerio!),
      );

      Map<String, MembrosRow> membrosData = {};
      for (var mm in membrosMinisterio) {
        if (mm.idMembro != null) {
          final membroRows = await MembrosTable().queryRows(
            queryFn: (q) => q.eq('id_membro', mm.idMembro!),
          );
          if (membroRows.isNotEmpty) {
            membrosData[mm.idMembro!] = membroRows.first;
          }
        }
      }

      setState(() {
        _ministerio = ministerio;
        _lider = lider;
        _membrosMinisterio = membrosMinisterio;
        _membrosData = membrosData;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() => _isLoading = false);
    }
  }

  List<MembrosMinisteriosRow> get _membrosFiltrados {
    if (_searchQuery.isEmpty) return _membrosMinisterio;
    return _membrosMinisterio.where((mm) {
      final membro = _membrosData[mm.idMembro];
      if (membro == null) return false;
      return membro.nomeMembro.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _removerMembro(MembrosMinisteriosRow membroMinisterio) async {
    try {
      await MembrosMinisteriosTable().delete(
        matchingRows: (q) => q.eq('id_membro_ministerio', membroMinisterio.idMembroMinisterio),
      );
      await _carregarDados();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Membro removido do ministério'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao remover membro'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarModalAdicionarMembro() {
    final searchMembroController = TextEditingController();
    List<MembrosRow> todosOsMembros = [];
    List<MembrosRow> membrosFiltrados = [];
    bool isLoadingMembros = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            if (isLoadingMembros && todosOsMembros.isEmpty) {
              MembrosTable().queryRows(
                queryFn: (q) => q.order('nome_membro'),
              ).then((membros) {
                final idsNoMinisterio = _membrosMinisterio
                    .map((mm) => mm.idMembro)
                    .whereType<String>()
                    .toSet();
                final membrosDisponiveis = membros
                    .where((m) => !idsNoMinisterio.contains(m.idMembro))
                    .toList();
                setModalState(() {
                  todosOsMembros = membrosDisponiveis;
                  membrosFiltrados = membrosDisponiveis;
                  isLoadingMembros = false;
                });
              });
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Color(0xFF666666),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Adicionar Membro',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: Color(0xFF999999)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: searchMembroController,
                      onChanged: (value) {
                        setModalState(() {
                          membrosFiltrados = todosOsMembros
                              .where((m) => m.nomeMembro
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar membro...',
                        hintStyle: GoogleFonts.inter(
                          color: Color(0xFF666666),
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Color(0xFF666666),
                        ),
                        filled: true,
                        fillColor: Color(0xFF3A3A3A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: isLoadingMembros
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          )
                        : membrosFiltrados.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_search_rounded,
                                      size: 48,
                                      color: Color(0xFF666666),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Nenhum membro encontrado',
                                      style: GoogleFonts.inter(
                                        color: Color(0xFF999999),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                itemCount: membrosFiltrados.length,
                                itemBuilder: (context, index) {
                                  final membro = membrosFiltrados[index];
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF3A3A3A),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Color(0xFF9C27B0).withOpacity(0.2),
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: Color(0xFF9C27B0),
                                        ),
                                      ),
                                      title: Text(
                                        membro.nomeMembro,
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: Icon(
                                        Icons.add_circle_outline_rounded,
                                        color: FlutterFlowTheme.of(context).primary,
                                      ),
                                      onTap: () async {
                                        try {
                                          await MembrosMinisteriosTable().insert({
                                            'id_membro': membro.idMembro,
                                            'id_ministerio': widget.idministerio,
                                          });
                                          Navigator.pop(context);
                                          await _carregarDados();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Membro adicionado ao ministério'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Erro ao adicionar membro'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _model.dispose();
    _searchController.dispose();
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
                                // Header com botão voltar
                                Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              context.pushNamed(
                                                PageMinisteriosAdminWidget.routeName,
                                              );
                                            },
                                            borderRadius: BorderRadius.circular(12),
                                            child: Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF2A2A2A),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.arrow_back_rounded,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _ministerio?.nomeMinisterio ?? 'Ministério',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 28.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4.0),
                                              Text(
                                                'Detalhes do ministério',
                                                style: GoogleFonts.inter(
                                                  color: Color(0xFF999999),
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          FFButtonWidget(
                                            onPressed: () {
                                              context.pushNamed(
                                                PageMinisterioAdminEditarWidget.routeName,
                                                queryParameters: {
                                                  'idministerio': serializeParam(
                                                    widget.idministerio,
                                                    ParamType.int,
                                                  ),
                                                }.withoutNulls,
                                              );
                                            },
                                            text: 'Editar Líder',
                                            icon: Icon(
                                              Icons.edit_rounded,
                                              size: 18,
                                            ),
                                            options: FFButtonOptions(
                                              height: 48.0,
                                              padding: EdgeInsets.symmetric(horizontal: 20.0),
                                              color: FlutterFlowTheme.of(context).accent2,
                                              textStyle: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              elevation: 0.0,
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          ElevatedButton.icon(
                                            onPressed: _mostrarModalAdicionarMembro,
                                            icon: Icon(Icons.person_add_rounded, size: 20),
                                            label: Text('Adicionar Membro'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: FlutterFlowTheme.of(context).primary,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 16,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
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
                                          icon: Icons.people_rounded,
                                          title: 'Participantes',
                                          value: _membrosMinisterio.length.toString(),
                                          color: Color(0xFF2196F3),
                                        ),
                                      ),
                                      SizedBox(width: 24.0),
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: Icons.person_rounded,
                                          title: 'Líder',
                                          value: _lider?.nomeMembro ?? 'Não definido',
                                          color: Color(0xFFFF9800),
                                          isText: true,
                                        ),
                                      ),
                                      SizedBox(width: 24.0),
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: Icons.calendar_today_rounded,
                                          title: 'Criado em',
                                          value: _ministerio?.criadoEm != null
                                              ? DateFormat('dd/MM/yyyy').format(_ministerio!.criadoEm!)
                                              : 'N/A',
                                          color: Color(0xFF9C27B0),
                                          isText: true,
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
                                    controller: _searchController,
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Buscar membro...',
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

                                // Lista de membros
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Membros do Ministério',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Color(0xFF2A2A2A),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${_membrosFiltrados.length} membros',
                                              style: GoogleFonts.inter(
                                                color: Color(0xFF999999),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16.0),

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
                                                Icon(
                                                  Icons.people_outline_rounded,
                                                  size: 64.0,
                                                  color: Color(0xFF666666),
                                                ),
                                                SizedBox(height: 16.0),
                                                Text(
                                                  'Nenhum membro encontrado',
                                                  style: GoogleFonts.inter(
                                                    color: Color(0xFF999999),
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                                SizedBox(height: 8.0),
                                                Text(
                                                  'Adicione membros ao ministério',
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
                                          itemCount: _membrosFiltrados.length,
                                          itemBuilder: (context, index) {
                                            final membroMinisterio = _membrosFiltrados[index];
                                            final membro = _membrosData[membroMinisterio.idMembro];

                                            return _buildMembroCard(
                                              membro: membro,
                                              membroMinisterio: membroMinisterio,
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
    bool isText = false,
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
              size: 28.0,
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
              fontSize: isText ? 18.0 : 32.0,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMembroCard({
    required MembrosRow? membro,
    required MembrosMinisteriosRow membroMinisterio,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                color: Color(0xFF9C27B0).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                color: Color(0xFF9C27B0),
                size: 24.0,
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Text(
                membro?.nomeMembro ?? 'Membro',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Color(0xFF2A2A2A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      'Remover Membro',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    content: Text(
                      'Deseja remover ${membro?.nomeMembro ?? 'este membro'} do ministério?',
                      style: GoogleFonts.inter(
                        color: Color(0xFF999999),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.inter(
                            color: Color(0xFF999999),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _removerMembro(membroMinisterio);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Remover',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.remove_circle_outline_rounded,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
