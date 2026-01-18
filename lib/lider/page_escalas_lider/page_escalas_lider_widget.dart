import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/lider/menu_lider/menu_lider_widget.dart';
import '/lider/menu_lider_mobile/menu_lider_mobile_widget.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'page_escalas_lider_model.dart';
export 'page_escalas_lider_model.dart';

class PageEscalasLiderWidget extends StatefulWidget {
  const PageEscalasLiderWidget({
    super.key,
    required this.idministerio,
  });

  final int? idministerio;

  static String routeName = 'PageEscalasLider';
  static String routePath = '/pageEscalasLider';

  @override
  State<PageEscalasLiderWidget> createState() => _PageEscalasLiderWidgetState();
}

class _PageEscalasLiderWidgetState extends State<PageEscalasLiderWidget> {
  late PageEscalasLiderModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  MinisterioRow? _ministerio;
  List<EscalasRow> _escalas = [];
  Map<int, int> _membrosCount = {};
  List<VwParticipacoesMesRow> _participacoes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageEscalasLiderModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      // Carregar ministério
      final ministerioRows = await MinisterioTable().queryRows(
        queryFn: (q) => q.eq('id_ministerio', widget.idministerio!),
      );

      MinisterioRow? ministerio;
      if (ministerioRows.isNotEmpty) {
        ministerio = ministerioRows.first;
      }

      // Carregar escalas do ministério
      final escalas = await EscalasTable().queryRows(
        queryFn: (q) => q.eq('id_ministerio', widget.idministerio!),
      );

      // Ordenar por data (mais recentes primeiro)
      escalas.sort((a, b) {
        if (a.dataHoraEscala == null && b.dataHoraEscala == null) return 0;
        if (a.dataHoraEscala == null) return 1;
        if (b.dataHoraEscala == null) return -1;
        return b.dataHoraEscala!.compareTo(a.dataHoraEscala!);
      });

      // Carregar contagem de membros por escala
      Map<int, int> membrosCount = {};
      for (var escala in escalas) {
        final membros = await MembrosEscalasTable().queryRows(
          queryFn: (q) => q.eq('id_escala', escala.idEscala),
        );
        membrosCount[escala.idEscala] = membros.length;
      }

      // Carregar participações do mês
      final participacoes = await VwParticipacoesMesTable().queryRows(
        queryFn: (q) => q.eq('id_ministerio', widget.idministerio!),
      );

      // Ordenar participações por quantidade (maior para menor)
      participacoes.sort((a, b) => (b.qtdParticipacoes ?? 0).compareTo(a.qtdParticipacoes ?? 0));

      setState(() {
        _ministerio = ministerio;
        _escalas = escalas;
        _membrosCount = membrosCount;
        _participacoes = participacoes;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() => _isLoading = false);
    }
  }

  List<EscalasRow> get _escalasFiltradas {
    final query = _model.textController?.text.toLowerCase() ?? '';
    if (query.isEmpty) return _escalas;
    return _escalas.where((escala) {
      return (escala.nomeEscala?.toLowerCase().contains(query) ?? false) ||
          (escala.descricao?.toLowerCase().contains(query) ?? false);
    }).toList();
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
              // Menu lateral (desktop)
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Escalas',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 32.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 4.0),
                                                Text(
                                                  _ministerio?.nomeMinisterio ?? 'Ministério',
                                                  style: GoogleFonts.inter(
                                                    color: Color(0xFF39D2C0),
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              // Botão menu mobile
                                              if (responsiveVisibility(
                                                context: context,
                                                tablet: false,
                                                tabletLandscape: false,
                                                desktop: false,
                                              ))
                                                Padding(
                                                  padding: EdgeInsets.only(right: 12.0),
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
                                              // Botão Nova Escala
                                              InkWell(
                                                onTap: () {
                                                  _mostrarModalNovaEscala(context);
                                                },
                                                borderRadius: BorderRadius.circular(12.0),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 20.0,
                                                    vertical: 12.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(context).primary,
                                                    borderRadius: BorderRadius.circular(12.0),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.add_rounded,
                                                        color: Colors.white,
                                                        size: 20.0,
                                                      ),
                                                      SizedBox(width: 8.0),
                                                      Text(
                                                        'Nova Escala',
                                                        style: GoogleFonts.inter(
                                                          color: Colors.white,
                                                          fontSize: 14.0,
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
                                          icon: Icons.event_rounded,
                                          title: 'Total de Escalas',
                                          value: _escalas.length.toString(),
                                          color: Color(0xFF2196F3),
                                        ),
                                      ),
                                      SizedBox(width: 24.0),
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: Icons.upcoming_rounded,
                                          title: 'Próximas',
                                          value: _escalas.where((e) =>
                                            e.dataHoraEscala != null &&
                                            e.dataHoraEscala!.isAfter(DateTime.now())
                                          ).length.toString(),
                                          color: Color(0xFFFF9800),
                                        ),
                                      ),
                                      SizedBox(width: 24.0),
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: Icons.history_rounded,
                                          title: 'Realizadas',
                                          value: _escalas.where((e) =>
                                            e.dataHoraEscala != null &&
                                            e.dataHoraEscala!.isBefore(DateTime.now())
                                          ).length.toString(),
                                          color: Color(0xFF9C27B0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 32.0),

                                // Card de Histórico de Participações
                                if (_participacoes.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                                    child: _buildParticipacaoCard(),
                                  ),

                                if (_participacoes.isNotEmpty)
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
                                      hintText: 'Buscar escala...',
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

                                // Lista de escalas
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (_escalasFiltradas.isEmpty)
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
                                                  Icons.event_busy_rounded,
                                                  size: 64.0,
                                                  color: Color(0xFF666666),
                                                ),
                                                SizedBox(height: 16.0),
                                                Text(
                                                  'Nenhuma escala encontrada',
                                                  style: GoogleFonts.inter(
                                                    color: Color(0xFF999999),
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                                SizedBox(height: 8.0),
                                                Text(
                                                  'Clique em "Nova Escala" para criar',
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
                                          itemCount: _escalasFiltradas.length,
                                          itemBuilder: (context, index) {
                                            final escala = _escalasFiltradas[index];
                                            final membrosCount = _membrosCount[escala.idEscala] ?? 0;
                                            final isPassada = escala.dataHoraEscala != null &&
                                                escala.dataHoraEscala!.isBefore(DateTime.now());

                                            return _buildEscalaCard(
                                              escala: escala,
                                              membrosCount: membrosCount,
                                              isPassada: isPassada,
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

  Widget _buildParticipacaoCard() {
    // Separar os que mais participaram e os que menos participaram
    final maisParticiparam = _participacoes.take(3).toList();
    final menosParticiparam = _participacoes.length > 3
        ? _participacoes.reversed.take(3).toList()
        : <VwParticipacoesMesRow>[];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Color(0xFF4B39EF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  Icons.leaderboard_rounded,
                  color: Color(0xFF4B39EF),
                  size: 24.0,
                ),
              ),
              SizedBox(width: 12.0),
              Text(
                'Participações do Mês',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.0),

          // Mais participaram
          if (maisParticiparam.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: Color(0xFF4CAF50),
                  size: 20.0,
                ),
                SizedBox(width: 8.0),
                Text(
                  'Mais participaram',
                  style: GoogleFonts.inter(
                    color: Color(0xFF4CAF50),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.0),
            ...maisParticiparam.asMap().entries.map((entry) {
              final index = entry.key;
              final p = entry.value;
              return _buildParticipanteItem(
                iniciais: p.iniciais ?? '??',
                nome: p.nomeMembro ?? 'Membro',
                participacoes: p.qtdParticipacoes ?? 0,
                posicao: index + 1,
                isTop: true,
              );
            }).toList(),
          ],

          // Menos participaram
          if (menosParticiparam.isNotEmpty) ...[
            SizedBox(height: 24.0),
            Row(
              children: [
                Icon(
                  Icons.trending_down_rounded,
                  color: Color(0xFFFF5722),
                  size: 20.0,
                ),
                SizedBox(width: 8.0),
                Text(
                  'Menos participaram',
                  style: GoogleFonts.inter(
                    color: Color(0xFFFF5722),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.0),
            ...menosParticiparam.map((p) {
              return _buildParticipanteItem(
                iniciais: p.iniciais ?? '??',
                nome: p.nomeMembro ?? 'Membro',
                participacoes: p.qtdParticipacoes ?? 0,
                posicao: null,
                isTop: false,
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildParticipanteItem({
    required String iniciais,
    required String nome,
    required int participacoes,
    int? posicao,
    required bool isTop,
  }) {
    Color avatarColor;
    if (posicao == 1) {
      avatarColor = Color(0xFFFFD700); // Ouro
    } else if (posicao == 2) {
      avatarColor = Color(0xFFC0C0C0); // Prata
    } else if (posicao == 3) {
      avatarColor = Color(0xFFCD7F32); // Bronze
    } else {
      avatarColor = Color(0xFF666666);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: avatarColor.withOpacity(0.2),
              shape: BoxShape.circle,
              border: isTop && posicao != null && posicao <= 3
                  ? Border.all(color: avatarColor, width: 2.0)
                  : null,
            ),
            child: Center(
              child: Text(
                iniciais,
                style: GoogleFonts.poppins(
                  color: isTop ? avatarColor : Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.0),
          // Nome
          Expanded(
            child: Text(
              nome,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Contagem
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: isTop ? Color(0xFF4CAF50).withOpacity(0.2) : Color(0xFFFF5722).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              '$participacoes',
              style: GoogleFonts.poppins(
                color: isTop ? Color(0xFF4CAF50) : Color(0xFFFF5722),
                fontSize: 14.0,
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

  Widget _buildEscalaCard({
    required EscalasRow escala,
    required int membrosCount,
    required bool isPassada,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.pushNamed(
              'PageEscalaDetalhesLider',
              queryParameters: {
                'idministerio': serializeParam(widget.idministerio, ParamType.int),
                'idescala': serializeParam(escala.idEscala, ParamType.int),
              },
            );
          },
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: isPassada ? Color(0xFF3A3A3A) : FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                // Ícone
                Container(
                  width: 56.0,
                  height: 56.0,
                  decoration: BoxDecoration(
                    color: isPassada
                        ? Color(0xFF666666).withOpacity(0.1)
                        : FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Icon(
                    Icons.event_rounded,
                    color: isPassada
                        ? Color(0xFF666666)
                        : FlutterFlowTheme.of(context).primary,
                    size: 28.0,
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
                              escala.nomeEscala ?? 'Escala',
                              style: GoogleFonts.poppins(
                                color: isPassada ? Color(0xFF999999) : Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isPassada)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Color(0xFF666666).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                'Realizada',
                                style: GoogleFonts.inter(
                                  color: Color(0xFF999999),
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: Color(0xFF666666),
                            size: 14.0,
                          ),
                          SizedBox(width: 6.0),
                          Text(
                            escala.dataHoraEscala != null
                                ? DateFormat('dd/MM/yyyy - HH:mm').format(escala.dataHoraEscala!)
                                : 'Data não definida',
                            style: GoogleFonts.inter(
                              color: Color(0xFF999999),
                              fontSize: 13.0,
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Icon(
                            Icons.people_rounded,
                            color: Color(0xFF666666),
                            size: 14.0,
                          ),
                          SizedBox(width: 6.0),
                          Text(
                            '$membrosCount participantes',
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
                // Seta
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

  void _mostrarModalNovaEscala(BuildContext context) {
    final nomeController = TextEditingController();
    final descricaoController = TextEditingController();
    DateTime? dataSelecionada;
    TimeOfDay? horaSelecionada;
    List<PlatformFile> arquivosSelecionados = [];
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
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
                          Icons.add_rounded,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 28.0,
                        ),
                        SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            'Nova Escala',
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
                          // Nome da escala
                          Text(
                            'Nome da Escala *',
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
                              hintText: 'Ex: Culto de Domingo',
                              hintStyle: GoogleFonts.inter(
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
                            ),
                            style: GoogleFonts.inter(color: Colors.white),
                          ),

                          SizedBox(height: 24.0),

                          // Data e Hora
                          Text(
                            'Data e Hora *',
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
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
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
                                      border: Border.all(
                                        color: Color(0xFF3A3A3A),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          color: Color(0xFF666666),
                                          size: 20.0,
                                        ),
                                        SizedBox(width: 12.0),
                                        Text(
                                          dataSelecionada != null
                                              ? DateFormat('dd/MM/yyyy').format(dataSelecionada!)
                                              : 'Selecionar data',
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
                                      initialTime: TimeOfDay.now(),
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
                                      border: Border.all(
                                        color: Color(0xFF3A3A3A),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          color: Color(0xFF666666),
                                          size: 20.0,
                                        ),
                                        SizedBox(width: 12.0),
                                        Text(
                                          horaSelecionada != null
                                              ? '${horaSelecionada!.hour.toString().padLeft(2, '0')}:${horaSelecionada!.minute.toString().padLeft(2, '0')}'
                                              : 'Selecionar hora',
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
                            'Descrição (opcional)',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          TextField(
                            controller: descricaoController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Informações adicionais sobre a escala...',
                              hintStyle: GoogleFonts.inter(
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
                            ),
                            style: GoogleFonts.inter(color: Colors.white),
                          ),

                          SizedBox(height: 24.0),

                          // Arquivos
                          Text(
                            'Arquivos (opcional)',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.0),

                          // Botão de adicionar arquivo
                          InkWell(
                            onTap: () async {
                              final result = await FilePicker.platform.pickFiles(
                                allowMultiple: true,
                                type: FileType.custom,
                                allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'doc', 'docx'],
                              );
                              if (result != null) {
                                setModalState(() {
                                  arquivosSelecionados.addAll(result.files);
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(12.0),
                            child: Container(
                              padding: EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                color: Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: Color(0xFF3A3A3A),
                                  width: 1.0,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload_rounded,
                                    color: FlutterFlowTheme.of(context).primary,
                                    size: 24.0,
                                  ),
                                  SizedBox(width: 12.0),
                                  Text(
                                    'Adicionar arquivos',
                                    style: GoogleFonts.inter(
                                      color: FlutterFlowTheme.of(context).primary,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 8.0),

                          Text(
                            'PDF, PNG, JPG, DOC (máx. 10MB cada)',
                            style: GoogleFonts.inter(
                              color: Color(0xFF666666),
                              fontSize: 12.0,
                            ),
                          ),

                          // Lista de arquivos selecionados
                          if (arquivosSelecionados.isNotEmpty) ...[
                            SizedBox(height: 16.0),
                            ...arquivosSelecionados.asMap().entries.map((entry) {
                              final index = entry.key;
                              final arquivo = entry.value;
                              final extensao = arquivo.extension?.toLowerCase() ?? '';
                              IconData icone;
                              Color corIcone;

                              if (extensao == 'pdf') {
                                icone = Icons.picture_as_pdf_rounded;
                                corIcone = Colors.red;
                              } else if (['png', 'jpg', 'jpeg'].contains(extensao)) {
                                icone = Icons.image_rounded;
                                corIcone = Colors.blue;
                              } else {
                                icone = Icons.description_rounded;
                                corIcone = Colors.orange;
                              }

                              return Container(
                                margin: EdgeInsets.only(bottom: 8.0),
                                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFF3A3A3A),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Row(
                                  children: [
                                    Icon(icone, color: corIcone, size: 20.0),
                                    SizedBox(width: 10.0),
                                    Expanded(
                                      child: Text(
                                        arquivo.name,
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 13.0,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8.0),
                                    Text(
                                      '${(arquivo.size / 1024).toStringAsFixed(0)} KB',
                                      style: GoogleFonts.inter(
                                        color: Color(0xFF999999),
                                        fontSize: 12.0,
                                      ),
                                    ),
                                    SizedBox(width: 8.0),
                                    InkWell(
                                      onTap: () {
                                        setModalState(() {
                                          arquivosSelecionados.removeAt(index);
                                        });
                                      },
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: Color(0xFF999999),
                                        size: 20.0,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Botão criar
                  Container(
                    padding: EdgeInsets.all(24.0),
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
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () async {
                            if (nomeController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Informe o nome da escala'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (dataSelecionada == null || horaSelecionada == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Selecione a data e hora'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            setModalState(() => isLoading = true);

                            try {
                              // Combinar data e hora
                              final dataHora = DateTime(
                                dataSelecionada!.year,
                                dataSelecionada!.month,
                                dataSelecionada!.day,
                                horaSelecionada!.hour,
                                horaSelecionada!.minute,
                              );

                              // Buscar o id_membro do usuário logado pelo id_auth
                              String? idMembroResponsavel;
                              if (currentUserUid.isNotEmpty) {
                                final membroLogado = await MembrosTable().queryRows(
                                  queryFn: (q) => q.eq('id_auth', currentUserUid),
                                );
                                if (membroLogado.isNotEmpty) {
                                  idMembroResponsavel = membroLogado.first.idMembro;
                                }
                              }

                              print('ID Auth: $currentUserUid');
                              print('ID Membro Responsável: $idMembroResponsavel');
                              print('ID Ministerio: ${widget.idministerio}');

                              // Criar escala diretamente no Supabase
                              final response = await SupaFlow.client
                                  .from('escalas')
                                  .insert({
                                    'id_ministerio': widget.idministerio,
                                    'nome_escala': nomeController.text.trim(),
                                    'data_hora_escala': dataHora.toIso8601String(),
                                    'descricao': descricaoController.text.trim().isNotEmpty
                                        ? descricaoController.text.trim()
                                        : null,
                                    'id_responsavel': idMembroResponsavel,
                                  })
                                  .select()
                                  .single();

                              print('Resposta do insert: $response');

                              final novaEscala = EscalasRow(response);
                              print('Escala criada com ID: ${novaEscala.idEscala}');

                              // Upload de arquivos se houver
                              if (arquivosSelecionados.isNotEmpty) {
                                for (var arquivo in arquivosSelecionados) {
                                  if (arquivo.bytes != null) {
                                    // Sanitizar nome do arquivo (remover acentos e caracteres especiais)
                                    String nomeOriginal = arquivo.name;
                                    String nomeSanitizado = nomeOriginal
                                        .replaceAll(RegExp(r'[áàâãäå]'), 'a')
                                        .replaceAll(RegExp(r'[ÁÀÂÃÄÅ]'), 'A')
                                        .replaceAll(RegExp(r'[éèêë]'), 'e')
                                        .replaceAll(RegExp(r'[ÉÈÊË]'), 'E')
                                        .replaceAll(RegExp(r'[íìîï]'), 'i')
                                        .replaceAll(RegExp(r'[ÍÌÎÏ]'), 'I')
                                        .replaceAll(RegExp(r'[óòôõö]'), 'o')
                                        .replaceAll(RegExp(r'[ÓÒÔÕÖ]'), 'O')
                                        .replaceAll(RegExp(r'[úùûü]'), 'u')
                                        .replaceAll(RegExp(r'[ÚÙÛÜ]'), 'U')
                                        .replaceAll(RegExp(r'[ç]'), 'c')
                                        .replaceAll(RegExp(r'[Ç]'), 'C')
                                        .replaceAll(RegExp(r'[ñ]'), 'n')
                                        .replaceAll(RegExp(r'[Ñ]'), 'N')
                                        .replaceAll(' ', '_')
                                        .replaceAll(RegExp(r'[^a-zA-Z0-9_.-]'), '');

                                    // Gerar nome único para o arquivo
                                    final nomeArquivo = '${DateTime.now().millisecondsSinceEpoch}_$nomeSanitizado';
                                    final path = 'escalas/${novaEscala.idEscala}/$nomeArquivo';

                                    // Upload para o Storage do Supabase
                                    final response = await SupaFlow.client.storage
                                        .from('arquivos')
                                        .uploadBinary(path, arquivo.bytes!);

                                    // Pegar URL pública do arquivo
                                    final urlPublica = SupaFlow.client.storage
                                        .from('arquivos')
                                        .getPublicUrl(path);

                                    // Salvar referência na tabela arquivos
                                    await ArquivosTable().insert({
                                      'link_arquivo': urlPublica,
                                      'id_escala': novaEscala.idEscala,
                                      'nome_arquivo': nomeOriginal,
                                    });
                                  }
                                }
                              }

                              Navigator.pop(modalContext);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Escala criada com sucesso!'),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              // Recarregar dados
                              await _carregarDados();

                              // Navegar para página de detalhes da escala criada
                              context.pushNamed(
                                'PageEscalaDetalhesLider',
                                queryParameters: {
                                  'idministerio': serializeParam(widget.idministerio, ParamType.int),
                                  'idescala': serializeParam(novaEscala.idEscala, ParamType.int),
                                },
                              );
                            } catch (e) {
                              print('Erro ao criar escala: $e');
                              setModalState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro ao criar escala: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FlutterFlowTheme.of(context).primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.0,
                                  ),
                                )
                              : Text(
                                  'Criar Escala',
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
}
