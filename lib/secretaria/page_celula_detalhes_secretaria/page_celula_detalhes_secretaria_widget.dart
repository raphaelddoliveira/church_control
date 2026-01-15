import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/secretaria/menu_secretaria/menu_secretaria_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_celula_detalhes_secretaria_model.dart';
export 'page_celula_detalhes_secretaria_model.dart';

class PageCelulaDetalhesSecretariaWidget extends StatefulWidget {
  const PageCelulaDetalhesSecretariaWidget({
    super.key,
    required this.celulaId,
  });

  final int celulaId;

  static String routeName = 'PageCelulaDetalhesSecretaria';
  static String routePath = '/pageCelulaDetalhesSecretaria';

  @override
  State<PageCelulaDetalhesSecretariaWidget> createState() =>
      _PageCelulaDetalhesSecretariaWidgetState();
}

class _PageCelulaDetalhesSecretariaWidgetState
    extends State<PageCelulaDetalhesSecretariaWidget> {
  late PageCelulaDetalhesSecretariaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  CelulaRow? _celula;
  MembrosRow? _lider;
  List<MembrosRow> _membrosCelula = [];
  List<MembrosRow> _todosMembros = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageCelulaDetalhesSecretariaModel());
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      // Carregar dados da celula
      final celulas = await CelulaTable().queryRows(
        queryFn: (q) => q.eq('id', widget.celulaId),
      );

      if (celulas.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final celula = celulas.first;

      // Carregar lider
      MembrosRow? lider;
      if (celula.idLider != null) {
        final lideres = await MembrosTable().queryRows(
          queryFn: (q) => q.eq('id_membro', celula.idLider!),
        );
        if (lideres.isNotEmpty) {
          lider = lideres.first;
        }
      }

      // Carregar membros da celula
      final membrosCelulaRelacao = await MembrosCelulaTable().queryRows(
        queryFn: (q) => q.eq('id_celula', widget.celulaId),
      );

      List<MembrosRow> membrosCelula = [];
      for (var relacao in membrosCelulaRelacao) {
        if (relacao.idMembro != null) {
          final membros = await MembrosTable().queryRows(
            queryFn: (q) => q.eq('id_membro', relacao.idMembro!),
          );
          if (membros.isNotEmpty) {
            membrosCelula.add(membros.first);
          }
        }
      }

      // Carregar todos os membros ativos para o modal de adicionar
      final todosMembros = await MembrosTable().queryRows(
        queryFn: (q) => q.eq('ativo', true).order('nome_membro'),
      );

      setState(() {
        _celula = celula;
        _lider = lider;
        _membrosCelula = membrosCelula;
        _todosMembros = todosMembros;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _adicionarMembro(MembrosRow membro) async {
    try {
      // Verificar se ja esta na celula
      final existe = await MembrosCelulaTable().queryRows(
        queryFn: (q) => q
            .eq('id_celula', widget.celulaId)
            .eq('id_membro', membro.idMembro),
      );

      if (existe.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${membro.nomeMembro} ja esta nesta celula'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Adicionar membro a celula
      await MembrosCelulaTable().insert({
        'id_celula': widget.celulaId,
        'id_membro': membro.idMembro,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${membro.nomeMembro} adicionado a celula!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );

      // Recarregar dados
      _carregarDados();
    } catch (e) {
      print('Erro ao adicionar membro: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao adicionar membro: $e'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  Future<void> _removerMembro(MembrosRow membro) async {
    try {
      await MembrosCelulaTable().delete(
        matchingRows: (rows) => rows
            .eq('id_celula', widget.celulaId)
            .eq('id_membro', membro.idMembro),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${membro.nomeMembro} removido da celula'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );

      _carregarDados();
    } catch (e) {
      print('Erro ao remover membro: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao remover membro: $e'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  void _mostrarModalAdicionarMembro() {
    // Filtrar membros que nao estao na celula
    final membrosDisponiveis = _todosMembros.where((m) {
      return !_membrosCelula.any((mc) => mc.idMembro == m.idMembro);
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final membrosFiltrados = membrosDisponiveis.where((m) {
              return m.nomeMembro.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            return Container(
              height: MediaQuery.sizeOf(context).height * 0.7,
              decoration: BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: EdgeInsets.only(top: 12.0),
                    width: 40.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: Color(0xFF666666),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Adicionar Membro',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // Campo de busca
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: TextField(
                      onChanged: (value) {
                        setModalState(() => searchQuery = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar membro...',
                        hintStyle: GoogleFonts.inter(
                          color: Color(0xFF666666),
                        ),
                        prefixIcon: Icon(Icons.search, color: Color(0xFF666666)),
                        filled: true,
                        fillColor: Color(0xFF1A1A1A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                  ),

                  SizedBox(height: 16.0),

                  // Lista de membros
                  Expanded(
                    child: membrosFiltrados.isEmpty
                        ? Center(
                            child: Text(
                              'Nenhum membro disponivel',
                              style: GoogleFonts.inter(
                                color: Color(0xFF666666),
                                fontSize: 16.0,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                            itemCount: membrosFiltrados.length,
                            itemBuilder: (context, index) {
                              final membro = membrosFiltrados[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 8.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
                                    child: Text(
                                      membro.nomeMembro.substring(0, 1).toUpperCase(),
                                      style: GoogleFonts.inter(
                                        color: FlutterFlowTheme.of(context).primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    membro.nomeMembro,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: membro.email != null
                                      ? Text(
                                          membro.email!,
                                          style: GoogleFonts.inter(
                                            color: Color(0xFF666666),
                                            fontSize: 12.0,
                                          ),
                                        )
                                      : null,
                                  trailing: IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _adicionarMembro(membro);
                                    },
                                    icon: Icon(
                                      Icons.add_circle_rounded,
                                      color: FlutterFlowTheme.of(context).primary,
                                      size: 28.0,
                                    ),
                                  ),
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
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          )
                        : _celula == null
                            ? Center(
                                child: Text(
                                  'Celula nao encontrada',
                                  style: GoogleFonts.inter(
                                    color: Color(0xFF999999),
                                    fontSize: 16.0,
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header
                                    Padding(
                                      padding: EdgeInsets.all(32.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              FlutterFlowIconButton(
                                                borderColor: Colors.transparent,
                                                borderRadius: 8.0,
                                                buttonSize: 40.0,
                                                icon: Icon(
                                                  Icons.arrow_back_rounded,
                                                  color: Colors.white,
                                                  size: 24.0,
                                                ),
                                                onPressed: () {
                                                  context.safePop();
                                                },
                                              ),
                                              SizedBox(width: 16.0),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _celula!.nomeCelula ?? 'Celula',
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: 32.0,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8.0),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.person_rounded,
                                                        color: Color(0xFF999999),
                                                        size: 16.0,
                                                      ),
                                                      SizedBox(width: 6.0),
                                                      Text(
                                                        'Lider: ${_lider?.nomeMembro ?? 'Nao definido'}',
                                                        style: GoogleFonts.inter(
                                                          color: Color(0xFF999999),
                                                          fontSize: 16.0,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          FFButtonWidget(
                                            onPressed: () {
                                              context.pushNamed(
                                                'PageNovaCelulaSecretaria',
                                                queryParameters: {
                                                  'celulaId': serializeParam(
                                                    widget.celulaId,
                                                    ParamType.int,
                                                  ),
                                                },
                                              );
                                            },
                                            text: 'Editar',
                                            icon: Icon(
                                              Icons.edit_rounded,
                                              size: 20.0,
                                            ),
                                            options: FFButtonOptions(
                                              height: 48.0,
                                              padding: EdgeInsets.symmetric(horizontal: 24.0),
                                              color: Color(0xFF2A2A2A),
                                              textStyle: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              elevation: 0.0,
                                              borderSide: BorderSide(
                                                color: Color(0xFF666666),
                                                width: 1.0,
                                              ),
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
                                              icon: Icons.people_rounded,
                                              title: 'Membros',
                                              value: _membrosCelula.length.toString(),
                                              color: Color(0xFF2196F3),
                                            ),
                                          ),
                                          SizedBox(width: 24.0),
                                          Expanded(
                                            child: _buildStatCard(
                                              icon: Icons.calendar_today_rounded,
                                              title: 'Criada em',
                                              value: _celula!.createdAt != null
                                                  ? dateTimeFormat('dd/MM/yyyy', _celula!.createdAt!)
                                                  : '-',
                                              color: Color(0xFF4CAF50),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: 32.0),

                                    // Secao de membros
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Membros da Celula',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              FFButtonWidget(
                                                onPressed: _mostrarModalAdicionarMembro,
                                                text: 'Adicionar Membro',
                                                icon: Icon(
                                                  Icons.person_add_rounded,
                                                  size: 20.0,
                                                ),
                                                options: FFButtonOptions(
                                                  height: 44.0,
                                                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                                                  color: FlutterFlowTheme.of(context).primary,
                                                  textStyle: GoogleFonts.inter(
                                                    color: Colors.white,
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  elevation: 0.0,
                                                  borderRadius: BorderRadius.circular(12.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 16.0),

                                          // Lista de membros
                                          if (_membrosCelula.isEmpty)
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
                                                      'Nenhum membro nesta celula',
                                                      style: GoogleFonts.inter(
                                                        color: Color(0xFF999999),
                                                        fontSize: 16.0,
                                                      ),
                                                    ),
                                                    SizedBox(height: 8.0),
                                                    Text(
                                                      'Clique em "Adicionar Membro" para comecar',
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
                                              itemCount: _membrosCelula.length,
                                              itemBuilder: (context, index) {
                                                final membro = _membrosCelula[index];
                                                final isLider = _lider?.idMembro == membro.idMembro;

                                                return Container(
                                                  margin: EdgeInsets.only(bottom: 12.0),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF2A2A2A),
                                                    borderRadius: BorderRadius.circular(12.0),
                                                    border: isLider
                                                        ? Border.all(
                                                            color: FlutterFlowTheme.of(context).primary,
                                                            width: 2.0,
                                                          )
                                                        : null,
                                                  ),
                                                  child: ListTile(
                                                    contentPadding: EdgeInsets.symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 8.0,
                                                    ),
                                                    leading: CircleAvatar(
                                                      radius: 24.0,
                                                      backgroundColor: FlutterFlowTheme.of(context)
                                                          .primary
                                                          .withOpacity(0.2),
                                                      backgroundImage: membro.fotoUrl != null
                                                          ? NetworkImage(membro.fotoUrl!)
                                                          : null,
                                                      child: membro.fotoUrl == null
                                                          ? Text(
                                                              membro.nomeMembro
                                                                  .substring(0, 1)
                                                                  .toUpperCase(),
                                                              style: GoogleFonts.inter(
                                                                color: FlutterFlowTheme.of(context).primary,
                                                                fontSize: 18.0,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            )
                                                          : null,
                                                    ),
                                                    title: Row(
                                                      children: [
                                                        Text(
                                                          membro.nomeMembro,
                                                          style: GoogleFonts.inter(
                                                            color: Colors.white,
                                                            fontSize: 16.0,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                        if (isLider) ...[
                                                          SizedBox(width: 8.0),
                                                          Container(
                                                            padding: EdgeInsets.symmetric(
                                                              horizontal: 8.0,
                                                              vertical: 2.0,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: FlutterFlowTheme.of(context).primary,
                                                              borderRadius: BorderRadius.circular(4.0),
                                                            ),
                                                            child: Text(
                                                              'LIDER',
                                                              style: GoogleFonts.inter(
                                                                color: Colors.white,
                                                                fontSize: 10.0,
                                                                fontWeight: FontWeight.w700,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                    subtitle: membro.email != null
                                                        ? Text(
                                                            membro.email!,
                                                            style: GoogleFonts.inter(
                                                              color: Color(0xFF666666),
                                                              fontSize: 14.0,
                                                            ),
                                                          )
                                                        : null,
                                                    trailing: !isLider
                                                        ? IconButton(
                                                            onPressed: () => _confirmarRemocao(membro),
                                                            icon: Icon(
                                                              Icons.remove_circle_outline_rounded,
                                                              color: Color(0xFFE53935),
                                                              size: 24.0,
                                                            ),
                                                          )
                                                        : null,
                                                  ),
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

  void _confirmarRemocao(MembrosRow membro) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          'Remover Membro',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Deseja remover ${membro.nomeMembro} desta celula?',
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removerMembro(membro);
            },
            child: Text(
              'Remover',
              style: GoogleFonts.inter(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w600,
              ),
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
          SizedBox(height: 4.0),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
