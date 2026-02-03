import '/components/meu_perfil_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'menu_tesouraria_model.dart';
export 'menu_tesouraria_model.dart';

class MenuTesourariaWidget extends StatefulWidget {
  const MenuTesourariaWidget({super.key});

  @override
  State<MenuTesourariaWidget> createState() => _MenuTesourariaWidgetState();
}

class _MenuTesourariaWidgetState extends State<MenuTesourariaWidget> {
  late MenuTesourariaModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MenuTesourariaModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
          child: Container(
            width: 250.0,
            height: 500.0,
            decoration: BoxDecoration(
              color: Color(0xFF3C3D3E),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    'assets/images/logo_igj.png',
                    width: 300.0,
                    height: 75.05,
                    fit: BoxFit.cover,
                  ),
                ),
                // Página Inicial
                _buildMenuItem(
                  context,
                  icon: Icons.home,
                  label: 'Página Inicial',
                  onTap: () => context.pushNamed(HomeTesourariaWidget.routeName),
                ),
                // Entradas
                _buildMenuItem(
                  context,
                  icon: Icons.trending_up_rounded,
                  label: 'Entradas',
                  onTap: () => context.pushNamed(PageEntradasTesourariaWidget.routeName),
                ),
                // Saídas
                _buildMenuItem(
                  context,
                  icon: Icons.trending_down_rounded,
                  label: 'Saídas',
                  onTap: () => context.pushNamed(PageSaidasTesourariaWidget.routeName),
                ),
                // Relatórios
                _buildMenuItem(
                  context,
                  icon: Icons.description_rounded,
                  label: 'Relatórios',
                  onTap: () => context.pushNamed(PageRelatoriosTesourariaWidget.routeName),
                ),
                // Gráficos
                _buildMenuItem(
                  context,
                  icon: Icons.bar_chart_rounded,
                  label: 'Gráficos',
                  onTap: () => context.pushNamed(PageGraficosTesourariaWidget.routeName),
                ),
              ],
            ),
          ),
        ),
        // Configurações Conta
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 8.0),
          child: Container(
            width: 250.0,
            height: 80.0,
            decoration: BoxDecoration(
              color: Color(0xFF3C3D3E),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                await showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  enableDrag: false,
                  context: context,
                  builder: (context) {
                    return Padding(
                      padding: MediaQuery.viewInsetsOf(context),
                      child: MeuPerfilWidget(),
                    );
                  },
                ).then((value) => safeSetState(() {}));
              },
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/Screenshot_29.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                    child: Text(
                      'Configurações Conta',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).primaryBackground,
                            fontSize: 14.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                    child: Icon(
                      Icons.logout_sharp,
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      size: 24.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 8.0),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: Container(
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: 50.0,
          decoration: BoxDecoration(
            color: Color(0xFF14181B),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(
                  icon,
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  size: 25.0,
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                  child: Text(
                    label,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                          fontStyle: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontStyle,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
