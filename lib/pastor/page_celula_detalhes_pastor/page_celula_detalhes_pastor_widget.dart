import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pastor/menu_pastor/menu_pastor_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_celula_detalhes_pastor_model.dart';
export 'page_celula_detalhes_pastor_model.dart';

class PageCelulaDetalhesPastorWidget extends StatefulWidget {
  const PageCelulaDetalhesPastorWidget({
    super.key,
    required this.celulaId,
  });

  final int celulaId;

  static String routeName = 'PageCelulaDetalhesPastor';
  static String routePath = '/pageCelulaDetalhesPastor';

  @override
  State<PageCelulaDetalhesPastorWidget> createState() =>
      _PageCelulaDetalhesPastorWidgetState();
}

class _PageCelulaDetalhesPastorWidgetState
    extends State<PageCelulaDetalhesPastorWidget> {
  late PageCelulaDetalhesPastorModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  CelulaRow? _celula;
  MembrosRow? _lider;
  List<MembrosRow> _membrosCelula = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageCelulaDetalhesPastorModel());
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final celulas = await CelulaTable().queryRows(
        queryFn: (q) => q.eq('id', widget.celulaId),
      );

      if (celulas.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final celula = celulas.first;

      MembrosRow? lider;
      if (celula.idLider != null) {
        final lideres = await MembrosTable().queryRows(
          queryFn: (q) => q.eq('id_membro', celula.idLider!),
        );
        if (lideres.isNotEmpty) {
          lider = lideres.first;
        }
      }

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

      setState(() {
        _celula = celula;
        _lider = lider;
        _membrosCelula = membrosCelula;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() => _isLoading = false);
    }
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
                      model: _model.menuPastorModel,
                      updateCallback: () => safeSetState(() {}),
                      child: MenuPastorWidget(),
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
                                  'Célula não encontrada',
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
                                                _celula!.nomeCelula ?? 'Célula',
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
                                                    'Líder: ${_lider?.nomeMembro ?? 'Não definido'}',
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
                                                'Membros da Célula',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 6.0,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF2A2A2A),
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                child: Text(
                                                  '${_membrosCelula.length} membros',
                                                  style: GoogleFonts.inter(
                                                    color: Color(0xFF999999),
                                                    fontSize: 14.0,
                                                  ),
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
                                                      'Nenhum membro nesta célula',
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
                                                        Expanded(
                                                          child: Text(
                                                            membro.nomeMembro,
                                                            style: GoogleFonts.inter(
                                                              color: Colors.white,
                                                              fontSize: 16.0,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                        if (isLider)
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
                                                              'LÍDER',
                                                              style: GoogleFonts.inter(
                                                                color: Colors.white,
                                                                fontSize: 10.0,
                                                                fontWeight: FontWeight.w700,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    subtitle: membro.email != null
                                                        ? Padding(
                                                            padding: EdgeInsets.only(top: 4.0),
                                                            child: Text(
                                                              membro.email!,
                                                              style: GoogleFonts.inter(
                                                                color: Color(0xFF666666),
                                                                fontSize: 14.0,
                                                              ),
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
