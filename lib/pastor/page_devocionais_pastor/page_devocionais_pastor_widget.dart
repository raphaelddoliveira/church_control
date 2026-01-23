import '/pastor/menu_pastor/menu_pastor_widget.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'page_devocionais_pastor_model.dart';
export 'page_devocionais_pastor_model.dart';

class PageDevocionaisPastorWidget extends StatefulWidget {
  const PageDevocionaisPastorWidget({super.key});

  static String routeName = 'PageDevocionais_Pastor';
  static String routePath = '/pageDevocionaisPastor';

  @override
  State<PageDevocionaisPastorWidget> createState() =>
      _PageDevocionaisPastorWidgetState();
}

class _PageDevocionaisPastorWidgetState
    extends State<PageDevocionaisPastorWidget> {
  late PageDevocionaisPastorModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<DevocionalRow> _devocionais = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageDevocionaisPastorModel());
    _carregarDados();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    try {
      final devocionais = await DevocionalTable().queryRows(
        queryFn: (q) => q.order('created_at', ascending: false),
      );

      setState(() {
        _devocionais = devocionais;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _buildDevocionalItem(DevocionalRow devocional) {
    final isPublicado = devocional.status == 'publicado';

    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await context.pushNamed(
              PageDevocionalPastorEditarWidget.routeName,
              queryParameters: {
                'iddevocional': serializeParam(devocional.id, ParamType.int),
              }.withoutNulls,
            );
            _carregarDados();
          },
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Imagem ou icone
                Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: devocional.imagem != null && devocional.imagem!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(
                            devocional.imagem!,
                            fit: BoxFit.cover,
                            width: 60.0,
                            height: 60.0,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.menu_book_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 28.0,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.menu_book_rounded,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 28.0,
                        ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              devocional.titulo ?? 'Sem titulo',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: isPublicado
                                  ? Color(0xFF027941).withOpacity(0.2)
                                  : Color(0xFFFF9800).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Text(
                              isPublicado ? 'Publicado' : 'Rascunho',
                              style: GoogleFonts.inter(
                                color: isPublicado ? Color(0xFF027941) : Color(0xFFFF9800),
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.0),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, color: Color(0xFF666666), size: 14.0),
                          SizedBox(width: 4.0),
                          Text(
                            _formatDate(devocional.createdAt),
                            style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 13.0),
                          ),
                          if (devocional.linkMusica != null && devocional.linkMusica!.isNotEmpty) ...[
                            SizedBox(width: 16.0),
                            Icon(Icons.music_note_rounded, color: Color(0xFF666666), size: 14.0),
                            SizedBox(width: 4.0),
                            Text(
                              'Com musica',
                              style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 13.0),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.0),
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

  @override
  Widget build(BuildContext context) {
    final totalPublicados = _devocionais.where((d) => d.status == 'publicado').length;
    final totalRascunhos = _devocionais.where((d) => d.status != 'publicado').length;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF14181B),
        body: Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          decoration: BoxDecoration(color: Color(0xFF14181B)),
          child: Row(
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
                    height: MediaQuery.sizeOf(context).height,
                    decoration: BoxDecoration(
                      color: Color(0xFF3C3D3E),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: wrapWithModel(
                      model: _model.menuPastorModel,
                      updateCallback: () => setState(() {}),
                      child: MenuPastorWidget(),
                    ),
                  ),
                ),

              // Conteudo principal
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    height: MediaQuery.sizeOf(context).height,
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
                                            'Devocionais',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 32.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            'Gerencie os devocionais publicados',
                                            style: GoogleFonts.inter(
                                              color: Color(0xFF999999),
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          await context.pushNamed(
                                            PageDevocionalPastorNovoWidget.routeName,
                                          );
                                          _carregarDados();
                                        },
                                        borderRadius: BorderRadius.circular(12.0),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context).primary,
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.add_rounded, color: Colors.white, size: 20.0),
                                              SizedBox(width: 8.0),
                                              Text(
                                                'Novo Devocional',
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
                                ),

                                // Cards de estatisticas
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: Icons.menu_book_rounded,
                                          title: 'Total',
                                          value: _devocionais.length.toString(),
                                          color: Color(0xFF2196F3),
                                        ),
                                      ),
                                      SizedBox(width: 24.0),
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: Icons.check_circle_rounded,
                                          title: 'Publicados',
                                          value: totalPublicados.toString(),
                                          color: Color(0xFF027941),
                                        ),
                                      ),
                                      SizedBox(width: 24.0),
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: Icons.edit_note_rounded,
                                          title: 'Rascunhos',
                                          value: totalRascunhos.toString(),
                                          color: Color(0xFFFF9800),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 32.0),

                                // Lista de devocionais
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ultimos Devocionais',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 16.0),

                                      if (_devocionais.isEmpty)
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
                                                  Icons.menu_book_rounded,
                                                  size: 64.0,
                                                  color: Color(0xFF666666),
                                                ),
                                                SizedBox(height: 16.0),
                                                Text(
                                                  'Nenhum devocional criado ainda',
                                                  style: GoogleFonts.inter(
                                                    color: Color(0xFF999999),
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                                SizedBox(height: 8.0),
                                                Text(
                                                  'Clique em "Novo Devocional" para comecar',
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
                                          itemCount: _devocionais.length,
                                          itemBuilder: (context, index) {
                                            return _buildDevocionalItem(_devocionais[index]);
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
            child: Icon(icon, size: 32.0, color: color),
          ),
          SizedBox(height: 16.0),
          Text(
            title,
            style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 14.0),
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
}
