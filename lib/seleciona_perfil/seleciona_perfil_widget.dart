import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'seleciona_perfil_model.dart';
export 'seleciona_perfil_model.dart';

class SelecionaPerfilWidget extends StatefulWidget {
  const SelecionaPerfilWidget({super.key});

  static String routeName = 'SelecionaPerfil';
  static String routePath = '/selecionaPerfil';

  @override
  State<SelecionaPerfilWidget> createState() => _SelecionaPerfilWidgetState();
}

class _SelecionaPerfilWidgetState extends State<SelecionaPerfilWidget> {
  late SelecionaPerfilModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  MembrosRow? _membroAtual;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SelecionaPerfilModel());

    // Buscar dados do membro atual
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final membros = await MembrosTable().queryRows(
        queryFn: (q) => q.eqOrNull('id_auth', currentUserUid),
      );

      final membro = membros.firstOrNull;

      setState(() {
        _membroAtual = membro;
      });
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _getNomeAreaAdmin() {
    switch (_membroAtual?.idNivelAcesso) {
      case 1:
        return 'Secretaria';
      case 3:
        return 'Administração';
      case 4:
        return 'Pastor';
      case 6:
        return 'Líder';
      default:
        return 'Administrativo';
    }
  }

  void _navegarParaAreaAdmin() {
    switch (_membroAtual?.idNivelAcesso) {
      case 1:
        context.pushReplacementNamed(PageHomeSecretariaWidget.routeName);
        break;
      case 3:
        context.pushReplacementNamed(HomePageAdminWidget.routeName);
        break;
      case 4:
        context.pushReplacementNamed(HomepagePastorWidget.routeName);
        break;
      case 6:
        context.pushReplacementNamed(HomepageLiderWidget.routeName);
        break;
    }
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
        backgroundColor: Color(0xFF0A0A0A),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A0A0A),
                Color(0xFF1A1A1A),
                Color(0xFF0A0A0A),
              ],
            ),
          ),
          child: SafeArea(
            top: true,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: isMobile ? 40.0 : 60.0),
                  // Logo e título modernos
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, isMobile ? 32.0 : 48.0),
                    child: Column(
                      children: [
                        // Logo com glassmorphism
                        Container(
                          width: isMobile ? 80.0 : 100.0,
                          height: isMobile ? 80.0 : 100.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                FlutterFlowTheme.of(context).primary,
                                FlutterFlowTheme.of(context).secondary,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                                blurRadius: 30.0,
                                spreadRadius: 10.0,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.church_rounded,
                            color: Colors.white,
                            size: isMobile ? 40.0 : 50.0,
                          ),
                        ),
                        SizedBox(height: isMobile ? 16.0 : 24.0),
                        Text(
                          'ChurchControl',
                          style: FlutterFlowTheme.of(context).displaySmall.override(
                                font: GoogleFonts.poppins(),
                                color: Colors.white,
                                fontSize: isMobile ? 26.0 : 32.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1.0,
                              ),
                        ),
                        SizedBox(height: 12.0),
                        Text(
                          'Olá, ${_membroAtual?.nomeMembro ?? 'Usuário'}! 👋',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context).headlineSmall.override(
                                font: GoogleFonts.inter(),
                                color: Color(0xFFE0E0E0),
                                fontSize: isMobile ? 18.0 : 20.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.0,
                              ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Como você gostaria de continuar?',
                          style: FlutterFlowTheme.of(context).bodyLarge.override(
                                font: GoogleFonts.inter(),
                                color: Color(0xFF999999),
                                fontSize: isMobile ? 14.0 : 16.0,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ],
                    ),
                  ),

                // Cards de seleção modernos
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(isMobile ? 16.0 : 24.0, 0.0, isMobile ? 16.0 : 24.0, 32.0),
                  child: isMobile
                      ? Column(
                          children: [
                            _buildAdminCard(context, isMobile),
                            SizedBox(height: 16.0),
                            _buildMembroCard(context, isMobile),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: _buildAdminCard(context, isMobile)),
                            SizedBox(width: 20.0),
                            Expanded(child: _buildMembroCard(context, isMobile)),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
        ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, bool isMobile) {
    return InkWell(
      onTap: () => _navegarParaAreaAdmin(),
      borderRadius: BorderRadius.circular(24.0),
      child: Container(
        height: isMobile ? 160.0 : 280.0,
        constraints: BoxConstraints(maxWidth: 350.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              FlutterFlowTheme.of(context).secondary.withOpacity(0.1),
              Color(0xFF1A1A1A),
            ],
          ),
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).secondary.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: FlutterFlowTheme.of(context).secondary.withOpacity(0.15),
              blurRadius: 20.0,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 20.0 : 36.0),
          child: isMobile
              ? Row(
                  children: [
                    Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        color: FlutterFlowTheme.of(context).secondary,
                        size: 30.0,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getNomeAreaAdmin(),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Ferramentas administrativas',
                            style: GoogleFonts.inter(
                              color: Color(0xFFAAAAAA),
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: FlutterFlowTheme.of(context).secondary,
                      size: 20.0,
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        color: FlutterFlowTheme.of(context).secondary,
                        size: 40.0,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      _getNomeAreaAdmin(),
                      style: FlutterFlowTheme.of(context)
                          .headlineMedium
                          .override(
                            font: GoogleFonts.poppins(),
                            color: Colors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Ferramentas\nadministrativas',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: FlutterFlowTheme.of(context)
                          .bodyMedium
                          .override(
                            font: GoogleFonts.inter(),
                            color: Color(0xFFAAAAAA),
                            fontSize: 14.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMembroCard(BuildContext context, bool isMobile) {
    return InkWell(
      onTap: () {
        context.pushReplacementNamed(PageMembrosNovaWidget.routeName);
      },
      borderRadius: BorderRadius.circular(24.0),
      child: Container(
        height: isMobile ? 160.0 : 280.0,
        constraints: BoxConstraints(maxWidth: 350.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              FlutterFlowTheme.of(context).primary.withOpacity(0.15),
              Color(0xFF1A1A1A),
            ],
          ),
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).primary.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
              blurRadius: 20.0,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 20.0 : 36.0),
          child: isMobile
              ? Row(
                  children: [
                    Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: FlutterFlowTheme.of(context).primary,
                        size: 30.0,
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Área do Membro',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Avisos, eventos e informações',
                            style: GoogleFonts.inter(
                              color: Color(0xFFAAAAAA),
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 20.0,
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: FlutterFlowTheme.of(context).primary,
                        size: 40.0,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Área do Membro',
                      style: FlutterFlowTheme.of(context)
                          .headlineMedium
                          .override(
                            font: GoogleFonts.poppins(),
                            color: Colors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Avisos, eventos e\ninformações',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: FlutterFlowTheme.of(context)
                          .bodyMedium
                          .override(
                            font: GoogleFonts.inter(),
                            color: Color(0xFFAAAAAA),
                            fontSize: 14.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
