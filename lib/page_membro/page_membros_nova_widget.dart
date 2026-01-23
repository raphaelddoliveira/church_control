import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/meu_perfil_widget.dart';
import '/page_membro/page_devocional_membro_leitura/page_devocional_membro_leitura_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_membros_nova_model.dart';
export 'page_membros_nova_model.dart';

class PageMembrosNovaWidget extends StatefulWidget {
  const PageMembrosNovaWidget({super.key});

  static String routeName = 'PageMembrosNova';
  static String routePath = '/pageMembrosNova';

  @override
  State<PageMembrosNovaWidget> createState() => _PageMembrosNovaWidgetState();
}

class _PageMembrosNovaWidgetState extends State<PageMembrosNovaWidget> {
  late PageMembrosNovaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _paginaAtual = 0; // 0 = Feed, 1 = Devocionais, 2 = Escalas

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageMembrosNovaModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<bool> _verificarSeEhMembroMinisterio(String? idMembro) async {
    if (idMembro == null) return false;

    final ministerios = await MembrosMinisteriosTable().queryRows(
      queryFn: (q) => q.eqOrNull('id_membro', idMembro),
    );

    return ministerios.isNotEmpty;
  }

  Future<bool> _temEscalasPendentes(String? idMembro) async {
    if (idMembro == null) return false;

    final membrosEscalas = await MembrosEscalasTable().queryRows(
      queryFn: (q) => q.eqOrNull('id_membro', idMembro),
    );

    // Verifica se há alguma escala sem resposta (aceitou_escala é null ou vazio)
    return membrosEscalas.any((me) =>
      me.aceitouEscala == null || me.aceitouEscala!.isEmpty
    );
  }

  Future<List<AvisoRow>> _carregarAvisos() async {
    // Buscar todos os avisos
    var query = AvisoTable().queryRows(
      queryFn: (q) => _model.categoriaValue == 'Todos'
          ? q
          : q.eqOrNull('categoria', _model.categoriaValue),
    );

    List<AvisoRow> todosAvisos = await query;
    final agora = DateTime.now();

    // Atualizar status dos avisos expirados
    for (var aviso in todosAvisos) {
      if (aviso.expiraEm != null && aviso.expiraEm!.isBefore(agora)) {
        // Se expirou e ainda está ativo, mudar para inativo
        if (aviso.status != 'inativo') {
          await AvisoTable().update(
            data: {'status': 'inativo'},
            matchingRows: (rows) => rows.eq('id', aviso.id),
          );
          aviso.status = 'inativo';
        }
      }
    }

    // Filtrar apenas avisos ativos (não expirados)
    List<AvisoRow> avisosAtivos = todosAvisos
        .where((aviso) =>
            aviso.status != 'inativo' &&
            (aviso.expiraEm == null || aviso.expiraEm!.isAfter(agora)))
        .toList();

    // Separar fixados e não fixados
    List<AvisoRow> fixados = avisosAtivos.where((a) => a.fixado == true).toList();
    List<AvisoRow> naoFixados = avisosAtivos.where((a) => a.fixado != true).toList();

    // Ordenar ambos por data
    fixados.sort((a, b) {
      if (a.dataHoraAviso == null && b.dataHoraAviso == null) return 0;
      if (a.dataHoraAviso == null) return 1;
      if (b.dataHoraAviso == null) return -1;
      return b.dataHoraAviso!.compareTo(a.dataHoraAviso!);
    });

    naoFixados.sort((a, b) {
      if (a.dataHoraAviso == null && b.dataHoraAviso == null) return 0;
      if (a.dataHoraAviso == null) return 1;
      if (b.dataHoraAviso == null) return -1;
      return b.dataHoraAviso!.compareTo(a.dataHoraAviso!);
    });

    // Retornar fixados primeiro, depois os não fixados
    return [...fixados, ...naoFixados];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: FutureBuilder<List<MembrosRow>>(
        future: MembrosTable().querySingleRow(
          queryFn: (q) => q.eqOrNull('email', currentUserEmail),
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              backgroundColor: Color(0xFF0A0A0A),
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            );
          }

          List<MembrosRow> membrosRowList = snapshot.data!;
          final membroAtual = membrosRowList.isNotEmpty ? membrosRowList.first : null;

          return Scaffold(
            key: scaffoldKey,
            backgroundColor: Color(0xFF0A0A0A),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A0A0A),
                    Color(0xFF121212),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Header Moderno
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF1A1A1A).withOpacity(0.95),
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF2A2A2A),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        FlutterFlowTheme.of(context).primary,
                                        FlutterFlowTheme.of(context).secondary,
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.church_rounded,
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                ),
                                SizedBox(width: 12.0),
                                Text(
                                  'ChurchControl',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                // Dropdown de Categorias
                                PopupMenuButton<String>(
                                  initialValue: _model.categoriaValue ?? 'Todos',
                                  onSelected: (String value) {
                                    setState(() {
                                      _model.categoriaValue = value;
                                    });
                                  },
                                  offset: Offset(0, 50),
                                  color: Color(0xFF1A1A1A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                    side: BorderSide(color: Color(0xFF2A2A2A)),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF2A2A2A),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.filter_list_rounded,
                                          color: Colors.white,
                                          size: 18.0,
                                        ),
                                        SizedBox(width: 6.0),
                                        Text(
                                          _model.categoriaValue ?? 'Todos',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(width: 4.0),
                                        Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Colors.white,
                                          size: 18.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                    _buildMenuItem('Todos'),
                                    _buildMenuItem('Evento'),
                                    _buildMenuItem('Aviso Geral'),
                                    _buildMenuItem('Culto'),
                                    _buildMenuItem('Retiro'),
                                    _buildMenuItem('Reunião'),
                                    _buildMenuItem('Outro'),
                                  ],
                                ),
                                SizedBox(width: 12.0),
                                Builder(
                                  builder: (context) => InkWell(
                                    onTap: () async {
                                      await showDialog(
                                        context: context,
                                        builder: (dialogContext) {
                                          return Dialog(
                                            elevation: 0,
                                            insetPadding: EdgeInsets.zero,
                                            backgroundColor: Colors.transparent,
                                            child: GestureDetector(
                                              onTap: () {
                                                FocusScope.of(dialogContext).unfocus();
                                                FocusManager.instance.primaryFocus?.unfocus();
                                              },
                                              child: MeuPerfilWidget(),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      width: 40.0,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF2A2A2A),
                                      ),
                                      child: Icon(
                                        Icons.person_rounded,
                                        color: Colors.white,
                                        size: 22.0,
                                      ),
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

                  // Conteúdo alternado entre Feed e Escalas
                  Expanded(
                    child: _paginaAtual == 0
                      ? FutureBuilder<List<AvisoRow>>(
                          future: _carregarAvisos(),
                          builder: (context, snapshotAvisos) {
                        if (!snapshotAvisos.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          );
                        }

                        List<AvisoRow> avisos = snapshotAvisos.data!;

                        if (avisos.isEmpty) {
                          return Center(
                            child: Text(
                              'Nenhum aviso encontrado',
                              style: GoogleFonts.inter(
                                color: Color(0xFF999999),
                                fontSize: 16.0,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          itemCount: avisos.length,
                          itemBuilder: (context, index) {
                            final aviso = avisos[index];

                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(
                                  color: Color(0xFF2A2A2A),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 15.0,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header do post
                                  Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48.0,
                                          height: 48.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                                                blurRadius: 8.0,
                                                spreadRadius: 2.0,
                                              ),
                                            ],
                                          ),
                                          child: ClipOval(
                                            child: Image.asset(
                                              'assets/images/logo_igj.png',
                                              width: 48.0,
                                              height: 48.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 14.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                aviso.descricaoResumida ?? aviso.categoria ?? 'Aviso',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 2.0),
                                              Text(
                                                aviso.dataHoraAviso != null
                                                    ? 'Data do evento: ${dateTimeFormat('dd/MM/yyyy - HH:mm', aviso.dataHoraAviso)}'
                                                    : 'Data do evento não informada',
                                                style: GoogleFonts.inter(
                                                  color: Color(0xFF999999),
                                                  fontSize: 13.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Imagem
                                  if (aviso.imagem != null && aviso.imagem!.isNotEmpty)
                                    Container(
                                      width: double.infinity,
                                      constraints: BoxConstraints(maxHeight: 400.0),
                                      child: Image.network(
                                        aviso.imagem!,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            height: 200.0,
                                            color: Color(0xFF2A2A2A),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  FlutterFlowTheme.of(context).primary,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            height: 200.0,
                                            color: Color(0xFF2A2A2A),
                                            child: Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: Color(0xFF666666),
                                                size: 48.0,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                  // Curtidas
                                  Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: FutureBuilder<List<CurtidasRow>>(
                                      future: CurtidasTable().queryRows(
                                        queryFn: (q) => q.eqOrNull('aviso_id', aviso.id),
                                      ),
                                      builder: (context, snapshotCurtidas) {
                                        final totalCurtidas = snapshotCurtidas.hasData ? snapshotCurtidas.data!.length : 0;
                                        final membroId = membroAtual?.idMembro;
                                        final jaCurtiu = snapshotCurtidas.hasData &&
                                            membroId != null &&
                                            snapshotCurtidas.data!.any((c) => c.membroId == membroId);

                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Botão de curtir
                                            InkWell(
                                              onTap: () async {
                                                if (membroId != null) {
                                                  if (jaCurtiu) {
                                                    final curtidaParaRemover = snapshotCurtidas.data!
                                                        .firstWhere((c) => c.membroId == membroId);
                                                    await CurtidasTable().delete(
                                                      matchingRows: (rows) => rows.eq('id', curtidaParaRemover.id),
                                                    );
                                                  } else {
                                                    await CurtidasTable().insert({
                                                      'aviso_id': aviso.id,
                                                      'membro_id': membroId,
                                                    });
                                                  }
                                                  setState(() {});
                                                }
                                              },
                                              child: Icon(
                                                jaCurtiu ? Icons.favorite : Icons.favorite_border,
                                                color: Colors.red,
                                                size: 28.0,
                                              ),
                                            ),

                                            // Contador de curtidas
                                            if (totalCurtidas > 0) ...[
                                              SizedBox(height: 8.0),
                                              Text(
                                                totalCurtidas == 1 ? '1 curtida' : '$totalCurtidas curtidas',
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ],
                                        );
                                      },
                                    ),
                                  ),

                                  // Descrição Completa
                                  if (aviso.descricao != null && aviso.descricao!.isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                                      child: Text(
                                        aviso.descricao!,
                                        textAlign: TextAlign.justify,
                                        style: GoogleFonts.inter(
                                          color: Color(0xFFE0E0E0),
                                          fontSize: 14.5,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    )
                    : _paginaAtual == 1
                      ? _buildTelaDevocionais()
                      : _buildTelaEscalas(membroAtual),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: FutureBuilder<bool>(
              future: _verificarSeEhMembroMinisterio(membroAtual?.idMembro),
              builder: (context, snapshotMinisterio) {
                final ehMembroMinisterio = snapshotMinisterio.data ?? false;

                return FutureBuilder<bool>(
                  future: _temEscalasPendentes(membroAtual?.idMembro),
                  builder: (context, snapshotPendentes) {
                    final temPendentes = snapshotPendentes.data ?? false;

                    return Container(
                      height: 60.0,
                      decoration: BoxDecoration(
                        color: Color(0xFF1A1A1A),
                        border: Border(
                          top: BorderSide(
                            color: Color(0xFF2A2A2A),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNavItem(
                              icon: Icons.home_rounded,
                              label: 'Feed',
                              index: 0,
                            ),
                            _buildNavItem(
                              icon: Icons.menu_book_rounded,
                              label: 'Devocionais',
                              index: 1,
                            ),
                            if (ehMembroMinisterio)
                              _buildNavItem(
                                icon: Icons.calendar_today_rounded,
                                label: 'Escalas',
                                index: 2,
                                showBadge: temPendentes,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _carregarEscalasDoMembro(String? idMembro) async {
    if (idMembro == null) return [];

    // Buscar os relacionamentos membros_escalas do membro
    final membrosEscalas = await MembrosEscalasTable().queryRows(
      queryFn: (q) => q.eqOrNull('id_membro', idMembro),
    );

    if (membrosEscalas.isEmpty) return [];

    // Buscar as escalas correspondentes
    List<Map<String, dynamic>> escalasCompletas = [];
    for (var membroEscala in membrosEscalas) {
      if (membroEscala.idEscala != null) {
        final escalas = await EscalasTable().queryRows(
          queryFn: (q) => q.eq('id_escala', membroEscala.idEscala!),
        );

        if (escalas.isNotEmpty) {
          final escala = escalas.first;

          // Buscar o nome do ministério
          String? nomeMinisterio;
          int? idMinisterio = escala.idMinisterio;
          if (idMinisterio != null) {
            final ministerios = await MinisterioTable().queryRows(
              queryFn: (q) => q.eq('id_ministerio', idMinisterio),
            );
            if (ministerios.isNotEmpty) {
              nomeMinisterio = ministerios.first.nomeMinisterio;
            }
          }

          // Buscar os arquivos da escala
          final arquivos = await ArquivosTable().queryRows(
            queryFn: (q) => q.eq('id_escala', escala.idEscala),
          );

          // Buscar as músicas da escala (se for ministério de louvor - id 1)
          List<Map<String, dynamic>> musicasEscala = [];
          if (idMinisterio == 1) {
            final escalaMusicasRows = await EscalaMusicasTable().queryRows(
              queryFn: (q) => q.eq('id_escala', escala.idEscala).order('ordem'),
            );

            for (var em in escalaMusicasRows) {
              if (em.idMusica != null) {
                final musicasRows = await MusicasTable().queryRows(
                  queryFn: (q) => q.eq('id', em.idMusica!),
                );
                if (musicasRows.isNotEmpty) {
                  final musica = musicasRows.first;
                  musicasEscala.add({
                    'musica': musica,
                    'tomEscala': em.tomEscala,
                    'ordem': em.ordem,
                    'observacoes': em.observacoes,
                  });
                }
              }
            }
          }

          // Buscar todos os membros da escala (para mostrar a equipe no modal)
          List<Map<String, dynamic>> membrosEscalaCompletos = [];
          final todosMembrosDaEscala = await MembrosEscalasTable().queryRows(
            queryFn: (q) => q.eq('id_escala', escala.idEscala),
          );
          for (var me in todosMembrosDaEscala) {
            if (me.idMembro != null) {
              final membroRows = await MembrosTable().queryRows(
                queryFn: (q) => q.eq('id_membro', me.idMembro!),
              );
              if (membroRows.isNotEmpty) {
                membrosEscalaCompletos.add({
                  'membro': membroRows.first,
                  'funcao': me.funcaoEscala,
                  'aceitou': me.aceitouEscala,
                });
              }
            }
          }

          escalasCompletas.add({
            'escala': escala,
            'funcao': membroEscala.funcaoEscala,
            'aceitou': membroEscala.aceitouEscala,
            'nomeMinisterio': nomeMinisterio,
            'idMinisterio': idMinisterio,
            'idMembroEscala': membroEscala.idMembroEscala,
            'arquivos': arquivos,
            'musicas': musicasEscala,
            'membrosEscala': membrosEscalaCompletos,
          });
        }
      }
    }

    // Filtrar somente escalas do mês corrente
    final agora = DateTime.now();
    escalasCompletas = escalasCompletas.where((item) {
      final data = (item['escala'] as EscalasRow).dataHoraEscala;
      if (data == null) return false;
      return data.year == agora.year && data.month == agora.month;
    }).toList();

    // Ordenar por data
    escalasCompletas.sort((a, b) {
      final dataA = (a['escala'] as EscalasRow).dataHoraEscala;
      final dataB = (b['escala'] as EscalasRow).dataHoraEscala;
      if (dataA == null && dataB == null) return 0;
      if (dataA == null) return 1;
      if (dataB == null) return -1;
      return dataB.compareTo(dataA);
    });

    return escalasCompletas;
  }

  void _mostrarModalEscala(
    BuildContext context,
    EscalasRow escala,
    String? funcao,
    String? aceitou,
    int idMembroEscala,
    String? nomeMinisterio,
    List<ArquivosRow> arquivos,
    {int? idMinisterio,
    List<Map<String, dynamic>>? musicas,
    List<Map<String, dynamic>>? membrosEscala}
  ) {
    final bool isMinisterioLouvor = idMinisterio == 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Color(0xFF0D0D0D),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
          ),
          child: Column(
            children: [
              // Header do modal
              Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFF2A2A2A),
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isMinisterioLouvor ? Icons.music_note_rounded : Icons.event_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 28.0,
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            escala.nomeEscala ?? 'Detalhes da Escala',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (nomeMinisterio != null)
                            Text(
                              nomeMinisterio,
                              style: GoogleFonts.inter(
                                color: FlutterFlowTheme.of(context).primary,
                                fontSize: 13.0,
                              ),
                            ),
                        ],
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

              // Conteúdo do modal
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Função e Data/Hora
                      Row(
                        children: [
                          if (funcao != null && funcao.isNotEmpty)
                            Expanded(
                              child: _buildCompactInfoCard(
                                icon: isMinisterioLouvor ? _getIconForFuncaoLouvor(funcao) : Icons.work_outline_rounded,
                                label: 'Sua Função',
                                value: funcao,
                              ),
                            ),
                          if (funcao != null && funcao.isNotEmpty)
                            SizedBox(width: 12.0),
                          Expanded(
                            child: _buildCompactInfoCard(
                              icon: Icons.calendar_today_rounded,
                              label: 'Data e Hora',
                              value: escala.dataHoraEscala != null
                                  ? dateTimeFormat('dd/MM - HH:mm', escala.dataHoraEscala)
                                  : '-',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),

                      // Informações adicionais
                      if (escala.descricao != null && escala.descricao!.isNotEmpty) ...[
                        _buildModalInfoSection(
                          icon: Icons.info_outline_rounded,
                          label: 'Observações',
                          value: escala.descricao!,
                        ),
                        SizedBox(height: 20.0),
                      ],

                      // === SEÇÃO DE MÚSICAS (apenas para ministério de louvor) ===
                      if (isMinisterioLouvor && musicas != null && musicas.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.queue_music_rounded, color: FlutterFlowTheme.of(context).primary, size: 22.0),
                            SizedBox(width: 8.0),
                            Text(
                              'Repertório (${musicas.length} música${musicas.length > 1 ? 's' : ''})',
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.0),
                        ...musicas.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final musica = item['musica'] as MusicasRow;
                          final tomEscala = item['tomEscala'] as String?;

                          return Container(
                            margin: EdgeInsets.only(bottom: 10.0),
                            decoration: BoxDecoration(
                              color: Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(14.0),
                              border: Border.all(color: Color(0xFF2A2A2A)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(14.0),
                              child: Row(
                                children: [
                                  // Número da ordem
                                  Container(
                                    width: 32.0,
                                    height: 32.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: GoogleFonts.poppins(
                                          color: FlutterFlowTheme.of(context).primary,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.0),
                                  // Info da música
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          musica.nome ?? 'Música',
                                          style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(height: 2.0),
                                        Row(
                                          children: [
                                            if (musica.artista != null)
                                              Flexible(
                                                child: Text(
                                                  musica.artista!,
                                                  style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 12.0),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            if (tomEscala != null) ...[
                                              SizedBox(width: 8.0),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(4.0),
                                                ),
                                                child: Text(
                                                  'Tom: $tomEscala',
                                                  style: GoogleFonts.inter(
                                                    color: FlutterFlowTheme.of(context).primary,
                                                    fontSize: 10.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Botões de ação
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (musica.youtubeLink != null && musica.youtubeLink!.isNotEmpty)
                                        IconButton(
                                          onPressed: () => launchURL(musica.youtubeLink!),
                                          icon: Icon(Icons.play_circle_filled_rounded, color: Colors.red, size: 28.0),
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(minWidth: 36.0),
                                          tooltip: 'Abrir no YouTube',
                                        ),
                                      if (musica.cifraLink != null && musica.cifraLink!.isNotEmpty)
                                        IconButton(
                                          onPressed: () => launchURL(musica.cifraLink!),
                                          icon: Icon(Icons.article_rounded, color: Colors.orange, size: 26.0),
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(minWidth: 36.0),
                                          tooltip: 'Ver Cifra',
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        SizedBox(height: 20.0),
                      ],

                      // === SEÇÃO DE EQUIPE ===
                      if (membrosEscala != null && membrosEscala.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.group_rounded, color: FlutterFlowTheme.of(context).primary, size: 22.0),
                            SizedBox(width: 8.0),
                            Text(
                              'Equipe (${membrosEscala.length})',
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.0),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: membrosEscala.map((item) {
                            final membro = item['membro'] as MembrosRow;
                            final funcaoMembro = item['funcao'] as String?;
                            final aceitouMembro = item['aceitou'] as String?;

                            Color statusColor;
                            IconData statusIcon;
                            if (aceitouMembro == 'aceito') {
                              statusColor = Colors.green;
                              statusIcon = Icons.check_circle_rounded;
                            } else if (aceitouMembro == 'recusado') {
                              statusColor = Colors.red;
                              statusIcon = Icons.cancel_rounded;
                            } else {
                              statusColor = Colors.orange;
                              statusIcon = Icons.schedule_rounded;
                            }

                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: Color(0xFF2A2A2A)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 28.0,
                                    height: 28.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        (membro.nomeMembro ?? 'M')[0].toUpperCase(),
                                        style: GoogleFonts.poppins(
                                          color: FlutterFlowTheme.of(context).primary,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.0),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        membro.nomeMembro ?? '',
                                        style: GoogleFonts.inter(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.w600),
                                      ),
                                      if (funcaoMembro != null)
                                        Text(
                                          funcaoMembro,
                                          style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 10.0),
                                        ),
                                    ],
                                  ),
                                  SizedBox(width: 8.0),
                                  Icon(statusIcon, color: statusColor, size: 16.0),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 20.0),
                      ],

                      // Arquivos
                      if (arquivos.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.attach_file_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 20.0,
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              'Arquivos (${arquivos.length})',
                              style: GoogleFonts.inter(
                                color: Color(0xFF999999),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.0),
                        ...arquivos.map((arquivo) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 8.0),
                            decoration: BoxDecoration(
                              color: Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: Color(0xFF2A2A2A),
                                width: 1.0,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  if (arquivo.linkArquivo != null) {
                                    await launchURL(arquivo.linkArquivo!);
                                  }
                                },
                                borderRadius: BorderRadius.circular(12.0),
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getIconForFile(arquivo.nomeArquivo ?? ''),
                                        color: FlutterFlowTheme.of(context).primary,
                                        size: 24.0,
                                      ),
                                      SizedBox(width: 12.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              arquivo.nomeArquivo ?? 'Arquivo',
                                              style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 2.0),
                                            Text(
                                              'Toque para abrir',
                                              style: GoogleFonts.inter(
                                                color: Color(0xFF666666),
                                                fontSize: 12.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.open_in_new_rounded,
                                        color: FlutterFlowTheme.of(context).primary,
                                        size: 20.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        SizedBox(height: 20.0),
                      ],
                    ],
                  ),
                ),
              ),

              // Botões de ação
              Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFF2A2A2A),
                      width: 1.0,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: aceitou == null || aceitou.isEmpty
                      ? Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  // Aceitar escala
                                  await MembrosEscalasTable().update(
                                    data: {'aceitou_escala': 'aceito'},
                                    matchingRows: (rows) => rows.eq('id_membro_escala', idMembroEscala),
                                  );
                                  Navigator.pop(modalContext);
                                  setState(() {});
                                },
                                icon: Icon(Icons.check_rounded, size: 20.0),
                                label: Text(
                                  'Aceitar',
                                  style: GoogleFonts.inter(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.0),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  // Recusar escala
                                  await MembrosEscalasTable().update(
                                    data: {'aceitou_escala': 'recusado'},
                                    matchingRows: (rows) => rows.eq('id_membro_escala', idMembroEscala),
                                  );
                                  Navigator.pop(modalContext);
                                  setState(() {});
                                },
                                icon: Icon(Icons.close_rounded, size: 20.0),
                                label: Text(
                                  'Recusar',
                                  style: GoogleFonts.inter(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          decoration: BoxDecoration(
                            color: aceitou == 'aceito' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: aceitou == 'aceito' ? Colors.green : Colors.red,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                aceitou == 'aceito' ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                color: aceitou == 'aceito' ? Colors.green : Colors.red,
                                size: 24.0,
                              ),
                              SizedBox(width: 12.0),
                              Text(
                                aceitou == 'aceito' ? 'Você aceitou esta escala' : 'Você recusou esta escala',
                                style: GoogleFonts.inter(
                                  color: aceitou == 'aceito' ? Colors.green : Colors.red,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactInfoCard({required IconData icon, required String label, required String value}) {
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: FlutterFlowTheme.of(context).primary, size: 18.0),
              SizedBox(width: 6.0),
              Expanded(
                child: Text(label, style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 11.0)),
              ),
            ],
          ),
          SizedBox(height: 6.0),
          Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  IconData _getIconForFuncaoLouvor(String funcao) {
    switch (funcao.toLowerCase()) {
      case 'voz principal':
        return Icons.mic_rounded;
      case 'backing vocal':
        return Icons.mic_external_on_rounded;
      case 'violao':
        return Icons.music_note_rounded;
      case 'guitarra':
        return Icons.electric_bolt_rounded;
      case 'baixo':
        return Icons.graphic_eq_rounded;
      case 'bateria':
        return Icons.album_rounded;
      case 'teclado':
        return Icons.piano_rounded;
      case 'cajon':
        return Icons.sports_handball_rounded;
      case 'percussao':
        return Icons.music_video_rounded;
      case 'saxofone':
        return Icons.air_rounded;
      case 'violino':
        return Icons.settings_input_svideo_rounded;
      default:
        return Icons.music_note_rounded;
    }
  }

  Widget _buildModalInfoSection({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: FlutterFlowTheme.of(context).primary,
              size: 20.0,
            ),
            SizedBox(width: 8.0),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Color(0xFF999999),
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.0),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: Color(0xFF2A2A2A),
              width: 1.0,
            ),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTelaDevocionais() {
    return FutureBuilder<List<DevocionalRow>>(
      future: DevocionalTable().queryRows(
        queryFn: (q) => q.eqOrNull('status', 'publicado').order('created_at', ascending: false),
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

        final devocionais = snapshot.data!;

        if (devocionais.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 64.0,
                  color: Color(0xFF666666),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Nenhum devocional disponível',
                  style: GoogleFonts.inter(
                    color: Color(0xFF999999),
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                'Devocionais',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: devocionais.length,
                itemBuilder: (context, index) {
                  final devocional = devocionais[index];

                  return FutureBuilder<List<MembrosRow>>(
                    future: devocional.criadoPor != null
                        ? MembrosTable().queryRows(
                            queryFn: (q) => q.eqOrNull('id_membro', devocional.criadoPor),
                          )
                        : Future.value([]),
                    builder: (context, snapshotAutor) {
                      final nomeAutor = snapshotAutor.hasData && snapshotAutor.data!.isNotEmpty
                          ? snapshotAutor.data!.first.nomeMembro
                          : 'Autor desconhecido';

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PageDevocionalMembroLeituraWidget(
                                idDevocional: devocional.id,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12.0),
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Color(0xFF2A2A2A),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Imagem quadrada à esquerda
                              Container(
                                width: 70.0,
                                height: 70.0,
                                decoration: BoxDecoration(
                                  color: Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: devocional.imagem != null && devocional.imagem!.isNotEmpty
                                      ? Image.network(
                                          devocional.imagem!,
                                          width: 70.0,
                                          height: 70.0,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Center(
                                              child: Icon(
                                                Icons.menu_book_rounded,
                                                color: Color(0xFF666666),
                                                size: 28.0,
                                              ),
                                            );
                                          },
                                        )
                                      : Center(
                                          child: Icon(
                                            Icons.menu_book_rounded,
                                            color: Color(0xFF666666),
                                            size: 28.0,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(width: 12.0),
                              // Informações à direita
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      devocional.titulo ?? 'Sem título',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 6.0),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline_rounded,
                                          color: Color(0xFF999999),
                                          size: 14.0,
                                        ),
                                        SizedBox(width: 4.0),
                                        Flexible(
                                          child: Text(
                                            nomeAutor,
                                            style: GoogleFonts.inter(
                                              color: Color(0xFF999999),
                                              fontSize: 12.0,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.0),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          color: Color(0xFF999999),
                                          size: 12.0,
                                        ),
                                        SizedBox(width: 4.0),
                                        Text(
                                          dateTimeFormat('dd/MM/yyyy', devocional.createdAt),
                                          style: GoogleFonts.inter(
                                            color: Color(0xFF999999),
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF666666),
                                size: 22.0,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTelaEscalas(MembrosRow? membroAtual) {
    if (membroAtual == null) {
      return Center(
        child: Text(
          'Membro não encontrado',
          style: GoogleFonts.inter(color: Color(0xFF999999)),
        ),
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _carregarEscalasDoMembro(membroAtual.idMembro),
      builder: (context, snapshotEscalas) {
        if (!snapshotEscalas.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary,
              ),
            ),
          );
        }

        final escalasCompletas = snapshotEscalas.data!;

        if (escalasCompletas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 64.0,
                  color: Color(0xFF666666),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Nenhuma escala disponível',
                  style: GoogleFonts.inter(
                    color: Color(0xFF999999),
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título "Escalas"
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                'Escalas',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Lista de escalas
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: escalasCompletas.length,
                itemBuilder: (context, index) {
                  final item = escalasCompletas[index];
                  final escala = item['escala'] as EscalasRow;
                  final funcao = item['funcao'] as String?;
                  final aceitou = item['aceitou'] as String?;
                  final nomeMinisterio = item['nomeMinisterio'] as String?;
                  final idMinisterio = item['idMinisterio'] as int?;
                  final idMembroEscala = item['idMembroEscala'] as int;
                  final arquivos = item['arquivos'] as List<ArquivosRow>? ?? [];
                  final musicas = item['musicas'] as List<Map<String, dynamic>>? ?? [];
                  final membrosEscala = item['membrosEscala'] as List<Map<String, dynamic>>? ?? [];
                  final bool isLouvor = idMinisterio == 1;

                  return InkWell(
                    onTap: () {
                      _mostrarModalEscala(
                        context, escala, funcao, aceitou, idMembroEscala, nomeMinisterio, arquivos,
                        idMinisterio: idMinisterio,
                        musicas: musicas,
                        membrosEscala: membrosEscala,
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: Color(0xFF2A2A2A),
                          width: 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Ícone (diferente para ministério de louvor)
                            Container(
                              width: 48.0,
                              height: 48.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isLouvor ? Icons.music_note_rounded : Icons.event_rounded,
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
                                    escala.nomeEscala ?? 'Escala',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  // Nome do ministério
                                  if (nomeMinisterio != null && nomeMinisterio.isNotEmpty) ...[
                                    Text(
                                      nomeMinisterio,
                                      style: GoogleFonts.inter(
                                        color: FlutterFlowTheme.of(context).primary,
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 2.0),
                                  ],
                                  Row(
                                    children: [
                                      Text(
                                        escala.dataHoraEscala != null
                                            ? dateTimeFormat('dd/MM/yyyy - HH:mm', escala.dataHoraEscala)
                                            : 'Data não informada',
                                        style: GoogleFonts.inter(
                                          color: Color(0xFF999999),
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      // Indicador de músicas para ministério de louvor
                                      if (isLouvor && musicas.isNotEmpty) ...[
                                        SizedBox(width: 8.0),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(4.0),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.queue_music_rounded, color: Colors.orange, size: 12.0),
                                              SizedBox(width: 4.0),
                                              Text(
                                                '${musicas.length}',
                                                style: GoogleFonts.inter(color: Colors.orange, fontSize: 11.0, fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Status badge (se já respondeu)
                            if (aceitou != null && aceitou.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                decoration: BoxDecoration(
                                  color: aceitou == 'aceito' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: Border.all(
                                    color: aceitou == 'aceito' ? Colors.green : Colors.red,
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  aceitou == 'aceito' ? 'Aceito' : 'Recusado',
                                  style: GoogleFonts.inter(
                                    color: aceitou == 'aceito' ? Colors.green : Colors.red,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            else
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF666666),
                                size: 24.0,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Color(0xFF999999),
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 8.0),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    bool showBadge = false,
  }) {
    final isSelected = _paginaAtual == index;

    return InkWell(
      onTap: () {
        setState(() {
          _paginaAtual = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? FlutterFlowTheme.of(context).primary : Color(0xFF666666),
                  size: 22.0,
                ),
                if (showBadge)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 10.0,
                      height: 10.0,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xFF1A1A1A),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.0),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? FlutterFlowTheme.of(context).primary : Color(0xFF666666),
                fontSize: 11.0,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value) {
    return PopupMenuItem<String>(
      value: value,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          value,
          style: GoogleFonts.inter(
            color: (_model.categoriaValue ?? 'Todos') == value
                ? FlutterFlowTheme.of(context).primary
                : Colors.white,
            fontSize: 14.0,
            fontWeight: (_model.categoriaValue ?? 'Todos') == value
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
      ),
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
}
