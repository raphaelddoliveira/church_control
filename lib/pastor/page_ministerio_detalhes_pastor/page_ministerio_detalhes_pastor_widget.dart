import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pastor/menu_pastor/menu_pastor_widget.dart';
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_ministerio_detalhes_pastor_model.dart';
export 'page_ministerio_detalhes_pastor_model.dart';

class PageMinisterioDetalhesPastorWidget extends StatefulWidget {
  const PageMinisterioDetalhesPastorWidget({
    super.key,
    required this.idministerio,
  });

  final int? idministerio;

  static String routeName = 'PageMinisterio_Detalhes_Pastor';
  static String routePath = '/pageMinisterioDetalhesPastor';

  @override
  State<PageMinisterioDetalhesPastorWidget> createState() =>
      _PageMinisterioDetalhesPastorWidgetState();
}

class _PageMinisterioDetalhesPastorWidgetState
    extends State<PageMinisterioDetalhesPastorWidget> {
  late PageMinisterioDetalhesPastorModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  MinisterioRow? _ministerio;
  MembrosRow? _lider;
  List<MembrosMinisteriosRow> _membrosMinisterio = [];
  Map<String, MembrosRow> _membrosData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageMinisterioDetalhesPastorModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final ministerioRows = await MinisterioTable().queryRows(
        queryFn: (q) => q.eq('id_ministerio', widget.idministerio!),
      );

      MinisterioRow? ministerio;
      MembrosRow? lider;

      if (ministerioRows.isNotEmpty) {
        ministerio = ministerioRows.first;

        if (ministerio.idLider != null) {
          final liderRows = await MembrosTable().queryRows(
            queryFn: (q) => q.eq('id_membro', ministerio!.idLider!),
          );
          if (liderRows.isNotEmpty) {
            lider = liderRows.first;
          }
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
    final query = _model.textController.text.toLowerCase();
    if (query.isEmpty) return _membrosMinisterio;
    return _membrosMinisterio.where((mm) {
      final membro = _membrosData[mm.idMembro];
      if (membro == null) return false;
      return membro.nomeMembro.toLowerCase().contains(query);
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
                      model: _model.menuPastorModel,
                      updateCallback: () => safeSetState(() {}),
                      child: MenuPastorWidget(),
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              context.pushNamed(
                                                  PageMinisteriosPastorWidget.routeName);
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
                                                size: 24.0,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16.0),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _ministerio?.nomeMinisterio ?? 'Ministério',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 32.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 4.0),
                                                Text(
                                                  'Detalhes do ministério',
                                                  style: GoogleFonts.inter(
                                                    color: Color(0xFF999999),
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                              ],
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
                                          value: _lider?.nomeMembro ?? 'Sem líder',
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
                                              ? DateFormat('dd/MM/yyyy')
                                                  .format(_ministerio!.criadoEm!)
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

                                // Lista de participantes
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Participantes',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w600,
                                        ),
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
                                                  'Nenhum participante encontrado',
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
                                          itemCount: _membrosFiltrados.length,
                                          itemBuilder: (context, index) {
                                            final membroMinisterio = _membrosFiltrados[index];
                                            final membro = _membrosData[membroMinisterio.idMembro];

                                            return _buildMembroCard(
                                              nome: membro?.nomeMembro ?? 'Membro',
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
    required String nome,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                color: Color(0xFF2196F3).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                color: Color(0xFF2196F3),
                size: 24.0,
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Text(
                nome,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
