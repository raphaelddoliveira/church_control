import 'dart:typed_data';
import '/admin/menu_admin/menu_admin_widget.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_comunidade_admin_detalhes_model.dart';
export 'page_comunidade_admin_detalhes_model.dart';

class PageComunidadeAdminDetalhesWidget extends StatefulWidget {
  const PageComunidadeAdminDetalhesWidget({
    super.key,
    required this.idcomunidade,
  });

  final int? idcomunidade;

  static String routeName = 'PageComunidade_Admin_Detalhes';
  static String routePath = '/pageComunidadeAdminDetalhes';

  @override
  State<PageComunidadeAdminDetalhesWidget> createState() =>
      _PageComunidadeAdminDetalhesWidgetState();
}

class _PageComunidadeAdminDetalhesWidgetState
    extends State<PageComunidadeAdminDetalhesWidget> {
  late PageComunidadeAdminDetalhesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  ComunidadeRow? _comunidade;
  MembrosRow? _lider;
  List<MembroComunidadeRow> _membrosComunidade = [];
  Map<String, MembrosRow> _membrosData = {};
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageComunidadeAdminDetalhesModel());
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final comunidadeRows = await ComunidadeTable().queryRows(
        queryFn: (q) => q.eq('id', widget.idcomunidade!),
      );

      if (comunidadeRows.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final comunidade = comunidadeRows.first;

      MembrosRow? lider;
      if (comunidade.liderComunidade != null) {
        final liderRows = await MembrosTable().queryRows(
          queryFn: (q) => q.eq('id_membro', comunidade.liderComunidade!),
        );
        if (liderRows.isNotEmpty) {
          lider = liderRows.first;
        }
      }

      final membrosComunidade = await MembroComunidadeTable().queryRows(
        queryFn: (q) => q.eq('id_comunidade', widget.idcomunidade!),
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

      setState(() {
        _comunidade = comunidade;
        _lider = lider;
        _membrosComunidade = membrosComunidade;
        _membrosData = membrosData;
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

  Future<void> _removerMembro(MembroComunidadeRow membroComunidade) async {
    try {
      await MembroComunidadeTable().delete(
        matchingRows: (q) => q.eq('id', membroComunidade.id),
      );
      await _carregarDados();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Membro removido da comunidade'),
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
                final idsNaComunidade = _membrosComunidade
                    .map((mc) => mc.idMembro)
                    .whereType<String>()
                    .toSet();
                final membrosDisponiveis = membros
                    .where((m) => !idsNaComunidade.contains(m.idMembro))
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
                                        backgroundColor: Color(0xFF4CAF50).withOpacity(0.2),
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: Color(0xFF4CAF50),
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
                                          await MembroComunidadeTable().insert({
                                            'id_membro': membro.idMembro,
                                            'id_comunidade': widget.idcomunidade,
                                          });
                                          Navigator.pop(context);
                                          await _carregarDados();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Membro adicionado à comunidade'),
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

  void _mostrarModalEditar() {
    final nomeController = TextEditingController(text: _comunidade?.nomeComunidade ?? '');
    final descricaoController = TextEditingController(text: _comunidade?.descricaoComunidade ?? '');
    String? selectedLider = _comunidade?.liderComunidade;
    List<MembrosRow> membrosLideres = [];
    bool isLoadingLideres = true;
    bool isSaving = false;
    Uint8List? novaImagemBytes;
    String? novaImagemNome;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (isLoadingLideres && membrosLideres.isEmpty) {
              MembrosTable().queryRows(
                queryFn: (q) => q.order('nome_membro'),
              ).then((membros) {
                setDialogState(() {
                  membrosLideres = membros;
                  isLoadingLideres = false;
                });
              });
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: 520,
                decoration: BoxDecoration(
                  color: Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isLoadingLideres
                    ? Container(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF4CAF50).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.edit_rounded,
                                      color: Color(0xFF4CAF50),
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Editar Comunidade',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Altere as informações da comunidade',
                                          style: GoogleFonts.inter(
                                            color: Color(0xFF999999),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => Navigator.pop(context),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF3A3A3A),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: Color(0xFF999999),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24),
                              Divider(color: Color(0xFF3A3A3A), height: 1),
                              SizedBox(height: 24),

                              // Nome
                              Text(
                                'Nome da Comunidade',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: nomeController,
                                decoration: InputDecoration(
                                  hintText: 'Nome da comunidade',
                                  hintStyle: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 14),
                                  filled: true,
                                  fillColor: Color(0xFF1E1E1E),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                              ),

                              SizedBox(height: 20),

                              // Descricao
                              Text(
                                'Descricao (opcional)',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: descricaoController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'Descricao da comunidade',
                                  hintStyle: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 14),
                                  filled: true,
                                  fillColor: Color(0xFF1E1E1E),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                              ),

                              SizedBox(height: 20),

                              // Lider
                              Text(
                                'Líder da Comunidade',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              FlutterFlowDropDown<String>(
                                controller: FormFieldController<String>(selectedLider ?? ''),
                                options: List<String>.from(membrosLideres.map((e) => e.idMembro).toList()),
                                optionLabels: membrosLideres.map((e) => e.nomeMembro).toList(),
                                onChanged: (val) => setDialogState(() => selectedLider = val),
                                width: double.infinity,
                                height: 48,
                                textStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                                hintText: 'Selecione um líder...',
                                icon: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF999999), size: 24),
                                fillColor: Color(0xFF1E1E1E),
                                elevation: 2,
                                borderColor: Colors.transparent,
                                borderWidth: 0,
                                borderRadius: 10,
                                margin: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                                hidesUnderline: true,
                                isOverButton: false,
                                isSearchable: false,
                                isMultiSelect: false,
                              ),

                              SizedBox(height: 20),

                              // Foto
                              Text(
                                'Foto da Comunidade (opcional)',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final selectedMedia = await selectMediaWithSourceBottomSheet(
                                    context: context,
                                    allowPhoto: true,
                                    allowVideo: false,
                                    backgroundColor: Color(0xFF2A2A2A),
                                    textColor: Colors.white,
                                    pickerFontFamily: 'Inter',
                                  );
                                  if (selectedMedia != null && selectedMedia.isNotEmpty) {
                                    setDialogState(() {
                                      novaImagemBytes = selectedMedia.first.bytes;
                                      novaImagemNome = selectedMedia.first.originalFilename;
                                    });
                                  }
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: double.infinity,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1E1E1E),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Color(0xFF3A3A3A), width: 1),
                                  ),
                                  child: novaImagemBytes != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.memory(novaImagemBytes!, fit: BoxFit.contain),
                                        )
                                      : _comunidade?.fotoUrl != null && _comunidade!.fotoUrl!.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.network(_comunidade!.fotoUrl!, fit: BoxFit.contain),
                                            )
                                          : Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.cloud_upload_outlined, color: Color(0xFF666666), size: 40),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Clique para selecionar uma imagem',
                                                  style: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 14),
                                                ),
                                              ],
                                            ),
                                ),
                              ),

                              SizedBox(height: 28),

                              // Botoes
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: isSaving
                                          ? null
                                          : () async {
                                              if (nomeController.text.trim().isEmpty) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Informe o nome'), backgroundColor: Colors.red),
                                                );
                                                return;
                                              }

                                              setDialogState(() => isSaving = true);

                                              try {
                                                String? fotoUrl = _comunidade?.fotoUrl;

                                                if (novaImagemBytes != null) {
                                                  setDialogState(() => isUploading = true);
                                                  final timestamp = DateTime.now().microsecondsSinceEpoch;
                                                  final ext = novaImagemNome?.split('.').last ?? 'jpg';
                                                  final storagePath = 'comunidades/$timestamp.$ext';

                                                  final selectedFile = SelectedFile(
                                                    storagePath: storagePath,
                                                    bytes: novaImagemBytes!,
                                                    originalFilename: novaImagemNome ?? 'imagem.jpg',
                                                  );

                                                  fotoUrl = await uploadSupabaseStorageFile(
                                                    bucketName: 'arquivos',
                                                    selectedFile: selectedFile,
                                                  );
                                                  setDialogState(() => isUploading = false);
                                                }

                                                await ComunidadeTable().update(
                                                  data: {
                                                    'nome_comunidade': nomeController.text.trim(),
                                                    'descricao_comunidade': descricaoController.text.trim().isNotEmpty
                                                        ? descricaoController.text.trim()
                                                        : null,
                                                    'lider_comunidade': selectedLider,
                                                    'foto_url': fotoUrl,
                                                  },
                                                  matchingRows: (q) => q.eq('id', widget.idcomunidade!),
                                                );

                                                Navigator.pop(context, true);
                                                await _carregarDados();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Comunidade atualizada'), backgroundColor: Colors.green),
                                                );
                                              } catch (e) {
                                                setDialogState(() {
                                                  isSaving = false;
                                                  isUploading = false;
                                                });
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Erro ao atualizar'), backgroundColor: Colors.red),
                                                );
                                              }
                                            },
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 14),
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context).primary,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: isSaving
                                              ? Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      isUploading ? 'Enviando...' : 'Salvando...',
                                                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                                    ),
                                                  ],
                                                )
                                              : Text(
                                                  'Salvar Alterações',
                                                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  InkWell(
                                    onTap: () => Navigator.pop(context),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF3A3A3A),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'Cancelar',
                                        style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 14, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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
          decoration: BoxDecoration(color: Color(0xFF14181B)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (responsiveVisibility(context: context, phone: false, tablet: false, tabletLandscape: false))
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16, 16, 0, 16),
                  child: Container(
                    width: 250,
                    height: MediaQuery.sizeOf(context).height * 1.0,
                    decoration: BoxDecoration(
                      color: Color(0xFF3C3D3E),
                      borderRadius: BorderRadius.circular(12),
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
                  padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
                  child: Container(
                    width: 100,
                    height: MediaQuery.sizeOf(context).height * 1.0,
                    decoration: BoxDecoration(
                      color: Color(0xFF3C3D3E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(FlutterFlowTheme.of(context).primary),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Padding(
                                  padding: EdgeInsets.all(32),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () => context.pushNamed(PageComunidadesAdminWidget.routeName),
                                            borderRadius: BorderRadius.circular(12),
                                            child: Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF2A2A2A),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _comunidade?.nomeComunidade ?? 'Comunidade',
                                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Detalhes da comunidade',
                                                style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          FFButtonWidget(
                                            onPressed: _mostrarModalEditar,
                                            text: 'Editar',
                                            icon: Icon(Icons.edit_rounded, size: 18),
                                            options: FFButtonOptions(
                                              height: 48,
                                              padding: EdgeInsets.symmetric(horizontal: 20),
                                              color: FlutterFlowTheme.of(context).accent2,
                                              textStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                              elevation: 0,
                                              borderRadius: BorderRadius.circular(12),
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
                                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Foto e Descricao
                                if (_comunidade?.fotoUrl != null || _comunidade?.descricaoComunidade != null)
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 32),
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF2A2A2A),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          if (_comunidade?.fotoUrl != null && _comunidade!.fotoUrl!.isNotEmpty)
                                            Container(
                                              width: 120,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: Color(0xFF1E1E1E),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.network(_comunidade!.fotoUrl!, fit: BoxFit.contain),
                                              ),
                                            ),
                                          if (_comunidade?.fotoUrl != null && _comunidade?.descricaoComunidade != null)
                                            SizedBox(width: 20),
                                          if (_comunidade?.descricaoComunidade != null && _comunidade!.descricaoComunidade!.isNotEmpty)
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Descricao',
                                                    style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 14),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    _comunidade!.descricaoComunidade!,
                                                    style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),

                                SizedBox(height: 24),

                                // Cards de estatísticas
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32),
                                  child: Row(
                                    children: [
                                      Expanded(child: _buildStatCard(icon: Icons.people_rounded, title: 'Participantes', value: _membrosComunidade.length.toString(), color: Color(0xFF2196F3))),
                                      SizedBox(width: 24),
                                      Expanded(child: _buildStatCard(icon: Icons.person_rounded, title: 'Líder', value: _lider?.nomeMembro ?? 'Não definido', color: Color(0xFFFF9800), isText: true)),
                                      SizedBox(width: 24),
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: Icons.calendar_today_rounded,
                                          title: 'Criado em',
                                          value: _comunidade?.createdAt != null ? DateFormat('dd/MM/yyyy').format(_comunidade!.createdAt!) : 'N/A',
                                          color: Color(0xFF4CAF50),
                                          isText: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 32),

                                // Campo de busca
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (value) => setState(() => _searchQuery = value),
                                    decoration: InputDecoration(
                                      hintText: 'Buscar membro...',
                                      hintStyle: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 16),
                                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF666666)),
                                      filled: true,
                                      fillColor: Color(0xFF2A2A2A),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFF3A3A3A), width: 1)),
                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary, width: 2)),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    ),
                                    style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                                  ),
                                ),

                                SizedBox(height: 24),

                                // Lista de membros
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Membros da Comunidade', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(color: Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(8)),
                                            child: Text('${_membrosFiltrados.length} membros', style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 14)),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      if (_membrosFiltrados.isEmpty)
                                        Container(
                                          padding: EdgeInsets.all(48),
                                          decoration: BoxDecoration(color: Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(16)),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Icon(Icons.people_outline_rounded, size: 64, color: Color(0xFF666666)),
                                                SizedBox(height: 16),
                                                Text('Nenhum membro encontrado', style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 16)),
                                                SizedBox(height: 8),
                                                Text('Adicione membros à comunidade', style: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 14)),
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
                                            final membroComunidade = _membrosFiltrados[index];
                                            final membro = _membrosData[membroComunidade.idMembro];
                                            return _buildMembroCard(membro: membro, membroComunidade: membroComunidade);
                                          },
                                        ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 32),
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

  Widget _buildStatCard({required IconData icon, required String title, required String value, required Color color, bool isText = false}) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(color: Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 28, color: color),
          ),
          SizedBox(height: 16),
          Text(title, style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 14)),
          SizedBox(height: 8),
          Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: isText ? 18 : 32, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildMembroCard({required MembrosRow? membro, required MembroComunidadeRow membroComunidade}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: Color(0xFF4CAF50).withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.person_rounded, color: Color(0xFF4CAF50), size: 24),
            ),
            SizedBox(width: 16),
            Expanded(child: Text(membro?.nomeMembro ?? 'Membro', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Color(0xFF2A2A2A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Text('Remover Membro', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                    content: Text('Deseja remover ${membro?.nomeMembro ?? 'este membro'} da comunidade?', style: GoogleFonts.inter(color: Color(0xFF999999))),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar', style: GoogleFonts.inter(color: Color(0xFF999999)))),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _removerMembro(membroComunidade);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: Text('Remover', style: GoogleFonts.inter(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.remove_circle_outline_rounded, color: Colors.red, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
