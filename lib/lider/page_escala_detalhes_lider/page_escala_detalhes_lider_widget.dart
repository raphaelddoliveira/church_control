import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/lider/menu_lider/menu_lider_widget.dart';
import '/lider/menu_lider_mobile/menu_lider_mobile_widget.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_escala_detalhes_lider_model.dart';
export 'page_escala_detalhes_lider_model.dart';

class PageEscalaDetalhesLiderWidget extends StatefulWidget {
  const PageEscalaDetalhesLiderWidget({
    super.key,
    required this.idministerio,
    required this.idescala,
  });

  final int? idministerio;
  final int? idescala;

  static String routeName = 'PageEscalaDetalhesLider';
  static String routePath = '/pageEscalaDetalhesLider';

  @override
  State<PageEscalaDetalhesLiderWidget> createState() => _PageEscalaDetalhesLiderWidgetState();
}

class _PageEscalaDetalhesLiderWidgetState extends State<PageEscalaDetalhesLiderWidget> {
  late PageEscalaDetalhesLiderModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  EscalasRow? _escala;
  MinisterioRow? _ministerio;
  List<MembrosEscalasRow> _membrosEscala = [];
  Map<String, MembrosRow> _membrosData = {};
  List<MembrosRow> _membrosDisponiveis = [];
  List<ArquivosRow> _arquivos = [];
  List<Map<String, dynamic>> _musicasEscala = [];
  List<MusicasRow> _todasMusicas = [];
  bool _isLoading = true;
  bool _modoEdicaoMusicas = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageEscalaDetalhesLiderModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      // Carregar escala
      final escalaRows = await EscalasTable().queryRows(
        queryFn: (q) => q.eq('id_escala', widget.idescala!),
      );

      EscalasRow? escala;
      if (escalaRows.isNotEmpty) {
        escala = escalaRows.first;
      }

      // Carregar ministério
      final ministerioRows = await MinisterioTable().queryRows(
        queryFn: (q) => q.eq('id_ministerio', widget.idministerio!),
      );

      MinisterioRow? ministerio;
      if (ministerioRows.isNotEmpty) {
        ministerio = ministerioRows.first;
      }

      // Carregar membros da escala
      final membrosEscala = await MembrosEscalasTable().queryRows(
        queryFn: (q) => q.eq('id_escala', widget.idescala!),
      );

      // Carregar dados dos membros
      Map<String, MembrosRow> membrosData = {};
      for (var me in membrosEscala) {
        if (me.idMembro != null) {
          final membroRows = await MembrosTable().queryRows(
            queryFn: (q) => q.eq('id_membro', me.idMembro!),
          );
          if (membroRows.isNotEmpty) {
            membrosData[me.idMembro!] = membroRows.first;
          }
        }
      }

      // Carregar membros disponíveis do ministério (que não estão na escala)
      final membrosMinisterio = await MembrosMinisteriosTable().queryRows(
        queryFn: (q) => q.eq('id_ministerio', widget.idministerio!),
      );

      List<MembrosRow> membrosDisponiveis = [];
      final idsJaNaEscala = membrosEscala.map((me) => me.idMembro).toSet();

      for (var mm in membrosMinisterio) {
        if (mm.idMembro != null && !idsJaNaEscala.contains(mm.idMembro)) {
          final membroRows = await MembrosTable().queryRows(
            queryFn: (q) => q.eq('id_membro', mm.idMembro!),
          );
          if (membroRows.isNotEmpty) {
            membrosDisponiveis.add(membroRows.first);
          }
        }
      }

      // Carregar arquivos da escala
      final arquivos = await ArquivosTable().queryRows(
        queryFn: (q) => q.eq('id_escala', widget.idescala!),
      );

      // Carregar músicas da escala (se for ministério de louvor - id 1)
      List<Map<String, dynamic>> musicasEscala = [];
      List<MusicasRow> todasMusicas = [];
      if (widget.idministerio == 1) {
        final escalaMusicasRows = await EscalaMusicasTable().queryRows(
          queryFn: (q) => q.eq('id_escala', widget.idescala!).order('ordem'),
        );

        for (var em in escalaMusicasRows) {
          if (em.idMusica != null) {
            final musicaRows = await MusicasTable().queryRows(
              queryFn: (q) => q.eq('id', em.idMusica!),
            );
            if (musicaRows.isNotEmpty) {
              final musica = musicaRows.first;
              musicasEscala.add({
                'escala_musica': em,
                'musica': musica,
              });
            }
          }
        }

        // Carregar todas as músicas para o modal de adicionar
        todasMusicas = await MusicasTable().queryRows(
          queryFn: (q) => q.order('nome'),
        );
      }

      setState(() {
        _escala = escala;
        _ministerio = ministerio;
        _membrosEscala = membrosEscala;
        _membrosData = membrosData;
        _membrosDisponiveis = membrosDisponiveis;
        _arquivos = arquivos;
        _musicasEscala = musicasEscala;
        _todasMusicas = todasMusicas;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() => _isLoading = false);
    }
  }

  List<MembrosEscalasRow> get _membrosFiltrados {
    final query = _model.textController?.text.toLowerCase() ?? '';
    if (query.isEmpty) return _membrosEscala;
    return _membrosEscala.where((me) {
      final membro = _membrosData[me.idMembro];
      if (membro == null) return false;
      return membro.nomeMembro.toLowerCase().contains(query) ||
          (me.funcaoEscala?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;

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
              // Menu lateral (desktop)
              if (!isMobile)
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
                        : SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Padding(
                                  padding: EdgeInsets.all(!isMobile ? 32.0 : 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          // Botão voltar
                                          InkWell(
                                            onTap: () {
                                              context.pushNamed(
                                                'PageEscalasLider',
                                                queryParameters: {
                                                  'idministerio': serializeParam(
                                                    widget.idministerio,
                                                    ParamType.int,
                                                  ),
                                                },
                                              );
                                            },
                                            borderRadius: BorderRadius.circular(8.0),
                                            child: Container(
                                              padding: EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF2A2A2A),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              child: Icon(
                                                Icons.arrow_back_rounded,
                                                color: Colors.white,
                                                size: 20.0,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12.0),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _escala?.nomeEscala ?? 'Escala',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: !isMobile ? 28.0 : 18.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 4.0),
                                                Text(
                                                  _ministerio?.nomeMinisterio ?? 'Ministério',
                                                  style: GoogleFonts.inter(
                                                    color: Color(0xFF39D2C0),
                                                    fontSize: !isMobile ? 14.0 : 12.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Botão menu mobile
                                          if (isMobile)
                                            Padding(
                                              padding: EdgeInsets.only(right: 8.0),
                                              child: InkWell(
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
                                                child: Container(
                                                  padding: EdgeInsets.all(8.0),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF2A2A2A),
                                                    borderRadius: BorderRadius.circular(8.0),
                                                  ),
                                                  child: Icon(
                                                    Icons.menu_rounded,
                                                    color: Colors.white,
                                                    size: 24.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          // Botão editar
                                          InkWell(
                                            onTap: () => _mostrarModalEditarEscala(context),
                                            borderRadius: BorderRadius.circular(8.0),
                                            child: Container(
                                              padding: EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF2A2A2A),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              child: Icon(
                                                Icons.edit_rounded,
                                                color: FlutterFlowTheme.of(context).primary,
                                                size: 20.0,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.0),
                                          // Botão excluir
                                          InkWell(
                                            onTap: () => _confirmarExclusao(context),
                                            borderRadius: BorderRadius.circular(8.0),
                                            child: Container(
                                              padding: EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF2A2A2A),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              child: Icon(
                                                Icons.delete_rounded,
                                                color: Colors.red,
                                                size: 20.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Cards de informações
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: !isMobile ? 32.0 : 16.0),
                                  child: !isMobile
                                      ? Row(
                                          children: [
                                            Expanded(
                                              child: _buildInfoCard(
                                                icon: Icons.calendar_today_rounded,
                                                title: 'Data',
                                                value: _escala?.dataHoraEscala != null
                                                    ? DateFormat('dd/MM/yyyy').format(_escala!.dataHoraEscala!)
                                                    : 'Não definida',
                                                color: Color(0xFF2196F3),
                                              ),
                                            ),
                                            SizedBox(width: 16.0),
                                            Expanded(
                                              child: _buildInfoCard(
                                                icon: Icons.access_time_rounded,
                                                title: 'Horário',
                                                value: _escala?.dataHoraEscala != null
                                                    ? DateFormat('HH:mm').format(_escala!.dataHoraEscala!)
                                                    : 'Não definido',
                                                color: Color(0xFFFF9800),
                                              ),
                                            ),
                                            SizedBox(width: 16.0),
                                            Expanded(
                                              child: _buildInfoCard(
                                                icon: Icons.people_rounded,
                                                title: 'Participantes',
                                                value: _membrosEscala.length.toString(),
                                                color: Color(0xFF9C27B0),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Expanded(
                                              child: _buildInfoCardCompact(
                                                icon: Icons.calendar_today_rounded,
                                                title: 'Data',
                                                value: _escala?.dataHoraEscala != null
                                                    ? DateFormat('dd/MM/yyyy').format(_escala!.dataHoraEscala!)
                                                    : 'N/A',
                                                color: Color(0xFF2196F3),
                                              ),
                                            ),
                                            SizedBox(width: 8.0),
                                            Expanded(
                                              child: _buildInfoCardCompact(
                                                icon: Icons.access_time_rounded,
                                                title: 'Horário',
                                                value: _escala?.dataHoraEscala != null
                                                    ? DateFormat('HH:mm').format(_escala!.dataHoraEscala!)
                                                    : 'N/A',
                                                color: Color(0xFFFF9800),
                                              ),
                                            ),
                                            SizedBox(width: 8.0),
                                            Expanded(
                                              child: _buildInfoCardCompact(
                                                icon: Icons.people_rounded,
                                                title: 'Participantes',
                                                value: _membrosEscala.length.toString(),
                                                color: Color(0xFF9C27B0),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),

                                // Descrição
                                if (_escala?.descricao != null && _escala!.descricao!.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(!isMobile ? 32.0 : 16.0, !isMobile ? 24.0 : 16.0, !isMobile ? 32.0 : 16.0, 0.0),
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(20.0),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF2A2A2A),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline_rounded,
                                                color: Color(0xFF666666),
                                                size: 18.0,
                                              ),
                                              SizedBox(width: 8.0),
                                              Text(
                                                'Descrição',
                                                style: GoogleFonts.inter(
                                                  color: Color(0xFF999999),
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12.0),
                                          Text(
                                            _escala!.descricao!,
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                // Seção de Arquivos
                                if (_arquivos.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(!isMobile ? 32.0 : 16.0, !isMobile ? 24.0 : 16.0, !isMobile ? 32.0 : 16.0, 0.0),
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(20.0),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF2A2A2A),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.attach_file_rounded,
                                                color: Color(0xFF666666),
                                                size: 18.0,
                                              ),
                                              SizedBox(width: 8.0),
                                              Text(
                                                'Arquivos (${_arquivos.length})',
                                                style: GoogleFonts.inter(
                                                  color: Color(0xFF999999),
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12.0),
                                          Wrap(
                                            spacing: 8.0,
                                            runSpacing: 8.0,
                                            children: _arquivos.map((arquivo) {
                                              return InkWell(
                                                onTap: () async {
                                                  if (arquivo.linkArquivo != null) {
                                                    await launchURL(arquivo.linkArquivo!);
                                                  }
                                                },
                                                borderRadius: BorderRadius.circular(8.0),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12.0,
                                                    vertical: 8.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF3C3D3E),
                                                    borderRadius: BorderRadius.circular(8.0),
                                                    border: Border.all(
                                                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        _getIconForFile(arquivo.nomeArquivo ?? ''),
                                                        color: FlutterFlowTheme.of(context).primary,
                                                        size: 16.0,
                                                      ),
                                                      SizedBox(width: 8.0),
                                                      ConstrainedBox(
                                                        constraints: BoxConstraints(maxWidth: 200),
                                                        child: Text(
                                                          arquivo.nomeArquivo ?? 'Arquivo',
                                                          style: GoogleFonts.inter(
                                                            color: Colors.white,
                                                            fontSize: 13.0,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      SizedBox(width: 8.0),
                                                      Icon(
                                                        Icons.download_rounded,
                                                        color: Color(0xFF666666),
                                                        size: 16.0,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                // Seção de Repertório (apenas para ministério de louvor - id 1)
                                if (widget.idministerio == 1)
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(!isMobile ? 32.0 : 16.0, !isMobile ? 24.0 : 16.0, !isMobile ? 32.0 : 16.0, 0.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.music_note_rounded,
                                                  color: Color(0xFFFF5722),
                                                  size: 24.0,
                                                ),
                                                SizedBox(width: 8.0),
                                                Text(
                                                  'Repertório',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(width: 8.0),
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFFF5722).withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(12.0),
                                                  ),
                                                  child: Text(
                                                    '${_musicasEscala.length}',
                                                    style: GoogleFonts.inter(
                                                      color: Color(0xFFFF5722),
                                                      fontSize: 12.0,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                // Botão de editar (lápis)
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _modoEdicaoMusicas = !_modoEdicaoMusicas;
                                                    });
                                                  },
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  child: Container(
                                                    padding: EdgeInsets.all(10.0),
                                                    decoration: BoxDecoration(
                                                      color: _modoEdicaoMusicas
                                                          ? Color(0xFFFF5722)
                                                          : Color(0xFF2A2A2A),
                                                      borderRadius: BorderRadius.circular(8.0),
                                                      border: Border.all(
                                                        color: _modoEdicaoMusicas
                                                            ? Color(0xFFFF5722)
                                                            : Color(0xFF3A3A3A),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      Icons.edit_rounded,
                                                      color: _modoEdicaoMusicas
                                                          ? Colors.white
                                                          : Color(0xFF999999),
                                                      size: 18.0,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8.0),
                                                // Botão de adicionar
                                                InkWell(
                                                  onTap: () => _mostrarModalAdicionarMusica(context),
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFFF5722),
                                                      borderRadius: BorderRadius.circular(8.0),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.add_rounded, color: Colors.white, size: 18.0),
                                                        SizedBox(width: 6.0),
                                                        Text(
                                                          'Adicionar',
                                                          style: GoogleFonts.inter(
                                                            color: Colors.white,
                                                            fontSize: 13.0,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        if (_musicasEscala.isEmpty)
                                          Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.all(32.0),
                                            decoration: BoxDecoration(
                                              color: Color(0xFF2A2A2A),
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.music_off_rounded,
                                                  size: 48.0,
                                                  color: Color(0xFF666666),
                                                ),
                                                SizedBox(height: 12.0),
                                                Text(
                                                  'Nenhuma música adicionada',
                                                  style: GoogleFonts.inter(
                                                    color: Color(0xFF999999),
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          ...List.generate(_musicasEscala.length, (index) {
                                            final item = _musicasEscala[index];
                                            final EscalaMusicasRow escalaMusicaRow = item['escala_musica'];
                                            final MusicasRow musica = item['musica'];

                                            return Container(
                                              margin: EdgeInsets.only(bottom: 16.0),
                                              padding: EdgeInsets.all(16.0),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF1A1A1A),
                                                borderRadius: BorderRadius.circular(12.0),
                                                border: Border.all(color: Color(0xFF2A2A2A), width: 1),
                                              ),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Controles de ordem (subir/descer)
                                                  Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      // Botão subir
                                                      InkWell(
                                                        onTap: index > 0
                                                            ? () => _moverMusica(index, index - 1)
                                                            : null,
                                                        borderRadius: BorderRadius.circular(4.0),
                                                        child: Container(
                                                          padding: EdgeInsets.all(4.0),
                                                          child: Icon(
                                                            Icons.keyboard_arrow_up_rounded,
                                                            color: index > 0 ? Color(0xFF999999) : Color(0xFF444444),
                                                            size: 20.0,
                                                          ),
                                                        ),
                                                      ),
                                                      // Número ordinal
                                                      Container(
                                                        width: 36.0,
                                                        height: 36.0,
                                                        decoration: BoxDecoration(
                                                          color: Color(0xFFD84315),
                                                          borderRadius: BorderRadius.circular(8.0),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            '${index + 1}ª',
                                                            style: GoogleFonts.inter(
                                                              color: Colors.white,
                                                              fontSize: 13.0,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // Botão descer
                                                      InkWell(
                                                        onTap: index < _musicasEscala.length - 1
                                                            ? () => _moverMusica(index, index + 1)
                                                            : null,
                                                        borderRadius: BorderRadius.circular(4.0),
                                                        child: Container(
                                                          padding: EdgeInsets.all(4.0),
                                                          child: Icon(
                                                            Icons.keyboard_arrow_down_rounded,
                                                            color: index < _musicasEscala.length - 1 ? Color(0xFF999999) : Color(0xFF444444),
                                                            size: 20.0,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(width: 12.0),
                                                  // Informações da música
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          musica.nome ?? 'Música',
                                                          style: GoogleFonts.poppins(
                                                            color: Color(0xFFFFAB40),
                                                            fontSize: 16.0,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4.0),
                                                        Text(
                                                          musica.artista ?? 'Artista desconhecido',
                                                          style: GoogleFonts.inter(
                                                            color: Colors.white,
                                                            fontSize: 14.0,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4.0),
                                                        Text(
                                                          'Louvor, Tom: ${escalaMusicaRow.tomEscala ?? musica.tomOriginal ?? '-'}',
                                                          style: GoogleFonts.inter(
                                                            color: Color(0xFF888888),
                                                            fontSize: 13.0,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Ícones de ação à direita
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          // Ícone Letra (A) - editar tom
                                                          InkWell(
                                                            onTap: () => _mostrarModalEditarTom(context, escalaMusicaRow, musica),
                                                            borderRadius: BorderRadius.circular(4.0),
                                                            child: Container(
                                                              padding: EdgeInsets.all(4.0),
                                                              child: Text(
                                                                'A',
                                                                style: GoogleFonts.inter(
                                                                  color: Color(0xFFFFAB40),
                                                                  fontSize: 16.0,
                                                                  fontWeight: FontWeight.bold,
                                                                  decoration: TextDecoration.underline,
                                                                  decorationColor: Color(0xFFFFAB40),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 8.0),
                                                          // Ícone Cifra
                                                          if (musica.cifraLink != null && musica.cifraLink!.isNotEmpty)
                                                            InkWell(
                                                              onTap: () => launchURL(musica.cifraLink!),
                                                              borderRadius: BorderRadius.circular(4.0),
                                                              child: Container(
                                                                padding: EdgeInsets.all(4.0),
                                                                child: Icon(
                                                                  Icons.format_list_bulleted_rounded,
                                                                  color: Color(0xFFFFAB40),
                                                                  size: 18.0,
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 8.0),
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          // Ícone Música
                                                          Icon(
                                                            Icons.music_note_rounded,
                                                            color: Color(0xFF4CAF50),
                                                            size: 18.0,
                                                          ),
                                                          SizedBox(width: 8.0),
                                                          // Ícone YouTube
                                                          if (musica.youtubeLink != null && musica.youtubeLink!.isNotEmpty)
                                                            InkWell(
                                                              onTap: () => launchURL(musica.youtubeLink!),
                                                              borderRadius: BorderRadius.circular(4.0),
                                                              child: Container(
                                                                padding: EdgeInsets.all(4.0),
                                                                child: Icon(
                                                                  Icons.play_arrow_rounded,
                                                                  color: Color(0xFFFF0000),
                                                                  size: 18.0,
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                      // Botão de remover música (só aparece no modo edição)
                                                      if (_modoEdicaoMusicas) ...[
                                                        SizedBox(height: 8.0),
                                                        InkWell(
                                                          onTap: () => _removerMusica(escalaMusicaRow),
                                                          borderRadius: BorderRadius.circular(4.0),
                                                          child: Container(
                                                            padding: EdgeInsets.all(4.0),
                                                            child: Icon(
                                                              Icons.delete_outline_rounded,
                                                              color: Color(0xFFFF5252),
                                                              size: 18.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                      ],
                                    ),
                                  ),

                                SizedBox(height: !isMobile ? 32.0 : 16.0),

                                // Seção de participantes
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: !isMobile ? 32.0 : 16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Participantes',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => _mostrarModalAdicionarMembro(context),
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 8.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context).primary,
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.add_rounded,
                                                color: Colors.white,
                                                size: 18.0,
                                              ),
                                              SizedBox(width: 6.0),
                                              Text(
                                                'Adicionar',
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 12.0),

                                // Campo de busca
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: !isMobile ? 32.0 : 16.0),
                                  child: TextField(
                                    controller: _model.textController,
                                    focusNode: _model.textFieldFocusNode,
                                    onChanged: (_) => EasyDebounce.debounce(
                                      '_model.textController',
                                      Duration(milliseconds: 300),
                                      () => safeSetState(() {}),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Buscar participante...',
                                      hintStyle: GoogleFonts.inter(
                                        color: Color(0xFF666666),
                                        fontSize: 14.0,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search_rounded,
                                        color: Color(0xFF666666),
                                        size: 20.0,
                                      ),
                                      filled: true,
                                      fillColor: Color(0xFF2A2A2A),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 14.0,
                                      ),
                                    ),
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 12.0),

                                // Lista de participantes
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: !isMobile ? 32.0 : 16.0),
                                  child: Column(
                                    children: [
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
                                                  'Nenhum participante',
                                                  style: GoogleFonts.inter(
                                                    color: Color(0xFF999999),
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                                SizedBox(height: 8.0),
                                                Text(
                                                  'Adicione membros à escala',
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
                                            final membroEscala = _membrosFiltrados[index];
                                            final membro = _membrosData[membroEscala.idMembro];

                                            return _buildMembroCard(
                                              membroEscala: membroEscala,
                                              membro: membro,
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(
              icon,
              size: 24.0,
              color: color,
            ),
          ),
          SizedBox(height: 12.0),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Color(0xFF999999),
              fontSize: 12.0,
            ),
          ),
          SizedBox(height: 4.0),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCardCompact({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(
              icon,
              size: 20.0,
              color: color,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Color(0xFF999999),
              fontSize: 11.0,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.0),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMembroCard({
    required MembrosEscalasRow membroEscala,
    required MembrosRow? membro,
  }) {
    final statusColor = membroEscala.aceitouEscala == 'aceito'
        ? Colors.green
        : membroEscala.aceitouEscala == 'recusado'
            ? Colors.red
            : Color(0xFFFF9800);

    final statusText = membroEscala.aceitouEscala == 'aceito'
        ? 'Aceito'
        : membroEscala.aceitouEscala == 'recusado'
            ? 'Recusado'
            : 'Pendente';

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
            child: Icon(
              Icons.person_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 24.0,
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
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (membroEscala.funcaoEscala != null && membroEscala.funcaoEscala!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text(
                      membroEscala.funcaoEscala!,
                      style: GoogleFonts.inter(
                        color: Color(0xFF999999),
                        fontSize: 13.0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Status
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: statusColor.withOpacity(0.5),
                width: 1.0,
              ),
            ),
            child: Text(
              statusText,
              style: GoogleFonts.inter(
                color: statusColor,
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8.0),
          // Botão editar função
          InkWell(
            onTap: () => _mostrarModalEditarFuncao(context, membroEscala, membro),
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.edit_rounded,
                color: Color(0xFF666666),
                size: 18.0,
              ),
            ),
          ),
          // Botão remover
          InkWell(
            onTap: () => _removerMembro(membroEscala),
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.close_rounded,
                color: Colors.red.withOpacity(0.7),
                size: 18.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarModalEditarEscala(BuildContext context) {
    final nomeController = TextEditingController(text: _escala?.nomeEscala ?? '');
    final descricaoController = TextEditingController(text: _escala?.descricao ?? '');
    DateTime? dataSelecionada = _escala?.dataHoraEscala;
    TimeOfDay? horaSelecionada = _escala?.dataHoraEscala != null
        ? TimeOfDay.fromDateTime(_escala!.dataHoraEscala!)
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 28.0,
                        ),
                        SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            'Editar Escala',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(modalContext),
                          icon: Icon(Icons.close_rounded),
                          color: Color(0xFF999999),
                        ),
                      ],
                    ),
                  ),

                  // Conteúdo
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nome
                          Text(
                            'Nome da Escala',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          TextField(
                            controller: nomeController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xFF2A2A2A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: Color(0xFF3A3A3A)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).primary,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            style: GoogleFonts.inter(color: Colors.white),
                          ),

                          SizedBox(height: 24.0),

                          // Data e Hora
                          Text(
                            'Data e Hora',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: dataSelecionada ?? DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now().add(Duration(days: 365)),
                                      builder: (context, child) {
                                        return Theme(
                                          data: ThemeData.dark().copyWith(
                                            colorScheme: ColorScheme.dark(
                                              primary: FlutterFlowTheme.of(context).primary,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (date != null) {
                                      setModalState(() => dataSelecionada = date);
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF2A2A2A),
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(color: Color(0xFF3A3A3A)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today_rounded,
                                            color: Color(0xFF666666), size: 20.0),
                                        SizedBox(width: 12.0),
                                        Text(
                                          dataSelecionada != null
                                              ? DateFormat('dd/MM/yyyy').format(dataSelecionada!)
                                              : 'Selecionar',
                                          style: GoogleFonts.inter(
                                            color: dataSelecionada != null
                                                ? Colors.white
                                                : Color(0xFF666666),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.0),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: horaSelecionada ?? TimeOfDay.now(),
                                      builder: (context, child) {
                                        return Theme(
                                          data: ThemeData.dark().copyWith(
                                            colorScheme: ColorScheme.dark(
                                              primary: FlutterFlowTheme.of(context).primary,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (time != null) {
                                      setModalState(() => horaSelecionada = time);
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF2A2A2A),
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(color: Color(0xFF3A3A3A)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.access_time_rounded,
                                            color: Color(0xFF666666), size: 20.0),
                                        SizedBox(width: 12.0),
                                        Text(
                                          horaSelecionada != null
                                              ? '${horaSelecionada!.hour.toString().padLeft(2, '0')}:${horaSelecionada!.minute.toString().padLeft(2, '0')}'
                                              : 'Selecionar',
                                          style: GoogleFonts.inter(
                                            color: horaSelecionada != null
                                                ? Colors.white
                                                : Color(0xFF666666),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 24.0),

                          // Descrição
                          Text(
                            'Descrição',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          TextField(
                            controller: descricaoController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Informações adicionais...',
                              hintStyle: GoogleFonts.inter(color: Color(0xFF666666)),
                              filled: true,
                              fillColor: Color(0xFF2A2A2A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: Color(0xFF3A3A3A)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).primary,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Botão salvar
                  Container(
                    padding: EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
                    ),
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            DateTime? dataHora;
                            if (dataSelecionada != null && horaSelecionada != null) {
                              // Adicionar 3 horas para compensar o fuso horário (UTC-3 Brasília)
                              dataHora = DateTime(
                                dataSelecionada!.year,
                                dataSelecionada!.month,
                                dataSelecionada!.day,
                                horaSelecionada!.hour + 3,
                                horaSelecionada!.minute,
                              );
                            }

                            await EscalasTable().update(
                              data: {
                                'nome_escala': nomeController.text,
                                'data_hora_escala': dataHora?.toIso8601String(),
                                'descricao': descricaoController.text.isNotEmpty
                                    ? descricaoController.text
                                    : null,
                              },
                              matchingRows: (rows) => rows.eq('id_escala', widget.idescala!),
                            );

                            Navigator.pop(modalContext);
                            _carregarDados();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FlutterFlowTheme.of(context).primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: Text(
                            'Salvar Alterações',
                            style: GoogleFonts.inter(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
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

  void _mostrarModalAdicionarMembro(BuildContext context) {
    String? funcaoSelecionada;
    MembrosRow? membroSelecionado;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_add_rounded,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 28.0,
                        ),
                        SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            'Adicionar Participante',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(modalContext),
                          icon: Icon(Icons.close_rounded),
                          color: Color(0xFF999999),
                        ),
                      ],
                    ),
                  ),

                  // Lista de membros disponíveis
                  Expanded(
                    child: _membrosDisponiveis.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline_rounded,
                                  size: 64.0,
                                  color: Color(0xFF666666),
                                ),
                                SizedBox(height: 16.0),
                                Text(
                                  'Todos os membros já estão na escala',
                                  style: GoogleFonts.inter(
                                    color: Color(0xFF999999),
                                    fontSize: 16.0,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16.0),
                            itemCount: _membrosDisponiveis.length,
                            itemBuilder: (context, index) {
                              final membro = _membrosDisponiveis[index];
                              final isSelected = membroSelecionado?.idMembro == membro.idMembro;

                              return InkWell(
                                onTap: () {
                                  setModalState(() {
                                    membroSelecionado = isSelected ? null : membro;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 8.0),
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? FlutterFlowTheme.of(context).primary.withOpacity(0.1)
                                        : Color(0xFF2A2A2A),
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                      color: isSelected
                                          ? FlutterFlowTheme.of(context).primary
                                          : Color(0xFF3A3A3A),
                                      width: isSelected ? 2.0 : 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40.0,
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: FlutterFlowTheme.of(context).primary,
                                          size: 20.0,
                                        ),
                                      ),
                                      SizedBox(width: 12.0),
                                      Expanded(
                                        child: Text(
                                          membro.nomeMembro,
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: FlutterFlowTheme.of(context).primary,
                                          size: 24.0,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Campo de função e botão
                  if (membroSelecionado != null)
                    Container(
                      padding: EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Color(0xFF1A1A1A),
                        border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Função (opcional)',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            TextField(
                              onChanged: (value) => funcaoSelecionada = value,
                              decoration: InputDecoration(
                                hintText: 'Ex: Guitarrista, Vocalista...',
                                hintStyle: GoogleFonts.inter(color: Color(0xFF666666)),
                                filled: true,
                                fillColor: Color(0xFF2A2A2A),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: GoogleFonts.inter(color: Colors.white),
                            ),
                            SizedBox(height: 16.0),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await MembrosEscalasTable().insert({
                                    'id_escala': widget.idescala,
                                    'id_membro': membroSelecionado!.idMembro,
                                    'funcao_escala': funcaoSelecionada,
                                  });

                                  Navigator.pop(modalContext);
                                  _carregarDados();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: FlutterFlowTheme.of(context).primary,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                child: Text(
                                  'Adicionar',
                                  style: GoogleFonts.inter(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  void _mostrarModalEditarFuncao(BuildContext context, MembrosEscalasRow membroEscala, MembrosRow? membro) {
    final funcaoController = TextEditingController(text: membroEscala.funcaoEscala ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Editar Função',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    membro?.nomeMembro ?? 'Membro',
                    style: GoogleFonts.inter(
                      color: Color(0xFF999999),
                      fontSize: 14.0,
                    ),
                  ),
                  SizedBox(height: 24.0),
                  TextField(
                    controller: funcaoController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Ex: Guitarrista, Vocalista...',
                      hintStyle: GoogleFonts.inter(color: Color(0xFF666666)),
                      filled: true,
                      fillColor: Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).primary,
                          width: 2.0,
                        ),
                      ),
                    ),
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  SizedBox(height: 24.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await MembrosEscalasTable().update(
                          data: {
                            'funcao_escala': funcaoController.text.isNotEmpty
                                ? funcaoController.text
                                : null,
                          },
                          matchingRows: (rows) =>
                              rows.eq('id_membro_escala', membroEscala.idMembroEscala),
                        );

                        Navigator.pop(modalContext);
                        _carregarDados();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: Text(
                        'Salvar',
                        style: GoogleFonts.inter(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  void _removerMembro(MembrosEscalasRow membroEscala) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            'Remover participante?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'O participante será removido desta escala.',
            style: GoogleFonts.inter(
              color: Color(0xFF999999),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(
                  color: Color(0xFF999999),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await MembrosEscalasTable().delete(
                  matchingRows: (rows) =>
                      rows.eq('id_membro_escala', membroEscala.idMembroEscala),
                );

                Navigator.pop(dialogContext);
                _carregarDados();
              },
              child: Text(
                'Remover',
                style: GoogleFonts.inter(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            'Excluir escala?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Esta ação não pode ser desfeita. Todos os participantes serão removidos.',
            style: GoogleFonts.inter(
              color: Color(0xFF999999),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(
                  color: Color(0xFF999999),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Remover membros da escala primeiro
                await MembrosEscalasTable().delete(
                  matchingRows: (rows) => rows.eq('id_escala', widget.idescala!),
                );

                // Remover escala
                await EscalasTable().delete(
                  matchingRows: (rows) => rows.eq('id_escala', widget.idescala!),
                );

                Navigator.pop(dialogContext);

                // Voltar para lista de escalas
                context.pushNamed(
                  'PageEscalasLider',
                  queryParameters: {
                    'idministerio': serializeParam(widget.idministerio, ParamType.int),
                  },
                );
              },
              child: Text(
                'Excluir',
                style: GoogleFonts.inter(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getIconForFile(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image_rounded;
      case 'mp3':
      case 'wav':
      case 'aac':
        return Icons.audio_file_rounded;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  void _mostrarModalAdicionarMusica(BuildContext context) {
    String searchQuery = '';
    MusicasRow? musicaSelecionada;
    String? tomSelecionado;

    final tons = [
      'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
      'Cm', 'C#m', 'Dm', 'D#m', 'Em', 'Fm', 'F#m', 'Gm', 'G#m', 'Am', 'A#m', 'Bm'
    ];

    // Filtrar músicas que já estão na escala
    final musicasJaNaEscala = _musicasEscala.map((m) => (m['musica'] as MusicasRow).id).toSet();
    final musicasDisponiveis = _todasMusicas.where((m) => !musicasJaNaEscala.contains(m.id)).toList();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final musicasFiltradas = musicasDisponiveis.where((m) {
              final nome = m.nome?.toLowerCase() ?? '';
              final artista = m.artista?.toLowerCase() ?? '';
              final query = searchQuery.toLowerCase();
              return nome.contains(query) || artista.contains(query);
            }).toList();

            return Dialog(
              backgroundColor: Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(maxWidth: 500, maxHeight: 600),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF5722).withOpacity(0.1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.music_note_rounded, color: Color(0xFFFF5722), size: 24.0),
                          SizedBox(width: 12.0),
                          Expanded(
                            child: Text(
                              'Adicionar Música',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: Icon(Icons.close_rounded),
                            color: Color(0xFF999999),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ),

                    // Campo de busca
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: TextField(
                        onChanged: (value) {
                          setDialogState(() => searchQuery = value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar música...',
                          hintStyle: GoogleFonts.inter(color: Color(0xFF666666)),
                          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF666666), size: 20.0),
                          filled: true,
                          fillColor: Color(0xFF2A2A2A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        ),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                      ),
                    ),

                    // Lista de músicas
                    Expanded(
                      child: musicasFiltradas.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhuma música encontrada',
                                style: GoogleFonts.inter(color: Color(0xFF666666)),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              itemCount: musicasFiltradas.length,
                              itemBuilder: (context, index) {
                                final musica = musicasFiltradas[index];
                                final isSelected = musicaSelecionada?.id == musica.id;

                                return InkWell(
                                  onTap: () {
                                    setDialogState(() {
                                      musicaSelecionada = isSelected ? null : musica;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 8.0),
                                    padding: EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Color(0xFFFF5722).withOpacity(0.1)
                                          : Color(0xFF2A2A2A),
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color: isSelected ? Color(0xFFFF5722) : Color(0xFF3A3A3A),
                                        width: isSelected ? 2.0 : 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.music_note_rounded,
                                          color: isSelected ? Color(0xFFFF5722) : Color(0xFF666666),
                                          size: 20.0,
                                        ),
                                        SizedBox(width: 12.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                musica.nome ?? 'Música',
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                musica.artista ?? 'Artista',
                                                style: GoogleFonts.inter(
                                                  color: Color(0xFF999999),
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(Icons.check_circle_rounded, color: Color(0xFFFF5722), size: 20.0),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    // Seleção de tom e botão
                    if (musicaSelecionada != null)
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tom',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Wrap(
                              spacing: 6.0,
                              runSpacing: 6.0,
                              children: tons.map((tom) {
                                final isSelected = tomSelecionado == tom;
                                return InkWell(
                                  onTap: () {
                                    setDialogState(() => tomSelecionado = isSelected ? null : tom);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Color(0xFF4CAF50)
                                          : Color(0xFF2A2A2A),
                                      borderRadius: BorderRadius.circular(6.0),
                                      border: Border.all(
                                        color: isSelected ? Color(0xFF4CAF50) : Color(0xFF3A3A3A),
                                      ),
                                    ),
                                    child: Text(
                                      tom,
                                      style: GoogleFonts.inter(
                                        color: isSelected ? Colors.white : Color(0xFF999999),
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 16.0),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final novaOrdem = _musicasEscala.length + 1;

                                  await EscalaMusicasTable().insert({
                                    'id_escala': widget.idescala,
                                    'id_musica': musicaSelecionada!.id,
                                    'tom_escala': tomSelecionado,
                                    'ordem': novaOrdem,
                                  });

                                  Navigator.pop(dialogContext);
                                  _carregarDados();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFF5722),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 14.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: Text(
                                  'Adicionar',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                  ),
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

  void _mostrarModalEditarTom(BuildContext context, EscalaMusicasRow escalaMusicaRow, MusicasRow musica) {
    String? tomSelecionado = escalaMusicaRow.tomEscala;

    final tons = [
      'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
      'Cm', 'C#m', 'Dm', 'D#m', 'Em', 'Fm', 'F#m', 'Gm', 'G#m', 'Am', 'A#m', 'Bm'
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(maxWidth: 400),
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Editar Tom',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      musica.nome ?? 'Música',
                      style: GoogleFonts.inter(
                        color: Color(0xFF999999),
                        fontSize: 14.0,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: tons.map((tom) {
                        final isSelected = tomSelecionado == tom;
                        return InkWell(
                          onTap: () {
                            setDialogState(() => tomSelecionado = isSelected ? null : tom);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(0xFF4CAF50)
                                  : Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: isSelected ? Color(0xFF4CAF50) : Color(0xFF3A3A3A),
                              ),
                            ),
                            child: Text(
                              tom,
                              style: GoogleFonts.inter(
                                color: isSelected ? Colors.white : Color(0xFF999999),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 24.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(
                            'Cancelar',
                            style: GoogleFonts.inter(color: Color(0xFF999999)),
                          ),
                        ),
                        SizedBox(width: 12.0),
                        ElevatedButton(
                          onPressed: () async {
                            await EscalaMusicasTable().update(
                              data: {'tom_escala': tomSelecionado},
                              matchingRows: (rows) =>
                                  rows.eq('id', escalaMusicaRow.id),
                            );

                            Navigator.pop(dialogContext);
                            _carregarDados();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            'Salvar',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
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

  Future<void> _moverMusica(int fromIndex, int toIndex) async {
    if (fromIndex < 0 || toIndex < 0 ||
        fromIndex >= _musicasEscala.length || toIndex >= _musicasEscala.length) {
      return;
    }

    // Pegar os itens
    final itemFrom = _musicasEscala[fromIndex];
    final itemTo = _musicasEscala[toIndex];

    final EscalaMusicasRow escalaFrom = itemFrom['escala_musica'];
    final EscalaMusicasRow escalaTo = itemTo['escala_musica'];

    // Trocar as ordens no banco de dados
    final ordemFrom = escalaFrom.ordem ?? (fromIndex + 1);
    final ordemTo = escalaTo.ordem ?? (toIndex + 1);

    try {
      // Atualizar a ordem dos dois itens
      await EscalaMusicasTable().update(
        data: {'ordem': ordemTo},
        matchingRows: (rows) => rows.eq('id', escalaFrom.id),
      );

      await EscalaMusicasTable().update(
        data: {'ordem': ordemFrom},
        matchingRows: (rows) => rows.eq('id', escalaTo.id),
      );

      // Recarregar os dados
      await _carregarDados();
    } catch (e) {
      // Em caso de erro, mostrar mensagem
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao reordenar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removerMusica(EscalaMusicasRow escalaMusicaRow) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            'Remover música?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'A música será removida do repertório desta escala.',
            style: GoogleFonts.inter(
              color: Color(0xFF999999),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(
                  color: Color(0xFF999999),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await EscalaMusicasTable().delete(
                  matchingRows: (rows) =>
                      rows.eq('id', escalaMusicaRow.id),
                );

                Navigator.pop(dialogContext);
                _carregarDados();
              },
              child: Text(
                'Remover',
                style: GoogleFonts.inter(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
