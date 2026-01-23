import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_devocional_membro_leitura_model.dart';
export 'page_devocional_membro_leitura_model.dart';

class PageDevocionalMembroLeituraWidget extends StatefulWidget {
  const PageDevocionalMembroLeituraWidget({
    super.key,
    this.idDevocional,
  });

  final int? idDevocional;

  static String routeName = 'PageDevocionalMembroLeitura';
  static String routePath = '/pageDevocionalMembroLeitura';

  @override
  State<PageDevocionalMembroLeituraWidget> createState() =>
      _PageDevocionalMembroLeituraWidgetState();
}

class _PageDevocionalMembroLeituraWidgetState
    extends State<PageDevocionalMembroLeituraWidget> {
  late PageDevocionalMembroLeituraModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageDevocionalMembroLeituraModel());
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
        backgroundColor: Color(0xFF0A0A0A),
        body: widget.idDevocional == null
          ? Center(
              child: Text(
                'Devocional não encontrado',
                style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 16.0),
              ),
            )
          : FutureBuilder<List<DevocionalRow>>(
          future: DevocionalTable().queryRows(
            queryFn: (q) => q.eqOrNull('id', widget.idDevocional!),
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              );
            }

            final devocional = snapshot.data!.first;

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

                return CustomScrollView(
                  slivers: [
                    // App Bar com imagem
                    SliverAppBar(
                      expandedHeight: devocional.imagem != null && devocional.imagem!.isNotEmpty
                          ? 280.0
                          : 0.0,
                      pinned: true,
                      backgroundColor: Color(0xFF1A1A1A),
                      leading: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20.0,
                          ),
                        ),
                      ),
                      flexibleSpace: devocional.imagem != null && devocional.imagem!.isNotEmpty
                          ? FlexibleSpaceBar(
                              background: Image.network(
                                devocional.imagem!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
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
                            )
                          : null,
                    ),

                    // Conteúdo
                    SliverToBoxAdapter(
                      child: Container(
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
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título
                              Text(
                                devocional.titulo ?? 'Sem título',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                              ),
                              SizedBox(height: 16.0),

                              // Autor e data
                              Container(
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
                                    Container(
                                      width: 40.0,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          nomeAutor.isNotEmpty ? nomeAutor[0].toUpperCase() : 'A',
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
                                            nomeAutor,
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 2.0),
                                          Text(
                                            dateTimeFormat('dd/MM/yyyy', devocional.createdAt),
                                            style: GoogleFonts.inter(
                                              color: Color(0xFF999999),
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24.0),

                              // Link de música
                              if (devocional.linkMusica != null && devocional.linkMusica!.isNotEmpty) ...[
                                InkWell(
                                  onTap: () => launchURL(devocional.linkMusica!),
                                  child: Container(
                                    padding: EdgeInsets.all(14.0),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1A1A1A),
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.music_note_rounded,
                                          color: FlutterFlowTheme.of(context).primary,
                                          size: 24.0,
                                        ),
                                        SizedBox(width: 12.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Música do Devocional',
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 2.0),
                                              Text(
                                                'Toque para ouvir',
                                                style: GoogleFonts.inter(
                                                  color: Color(0xFF999999),
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
                                SizedBox(height: 24.0),
                              ],

                              // Texto do devocional
                              if (devocional.textoDevocional != null && devocional.textoDevocional!.isNotEmpty)
                                Text(
                                  devocional.textoDevocional!,
                                  textAlign: TextAlign.justify,
                                  style: GoogleFonts.inter(
                                    color: Color(0xFFE0E0E0),
                                    fontSize: 16.0,
                                    height: 1.7,
                                  ),
                                ),

                              SizedBox(height: 40.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
