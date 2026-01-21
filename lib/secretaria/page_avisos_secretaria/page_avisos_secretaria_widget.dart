// v2 - Force rebuild
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/secretaria/menu_secretaria/menu_secretaria_widget.dart';
import '/secretaria/page_novo_aviso_secretaria/page_novo_aviso_secretaria_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'page_avisos_secretaria_model.dart';
export 'page_avisos_secretaria_model.dart';

class PageAvisosSecretariaWidget extends StatefulWidget {
  const PageAvisosSecretariaWidget({super.key});

  static String routeName = 'PageAvisosSecretaria';
  static String routePath = '/PageAvisosSecretaria';

  @override
  State<PageAvisosSecretariaWidget> createState() =>
      _PageAvisosSecretariaWidgetState();
}

class _PageAvisosSecretariaWidgetState
    extends State<PageAvisosSecretariaWidget> {
  late PageAvisosSecretariaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageAvisosSecretariaModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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
                  padding:
                      EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 0.0, 16.0),
                  child: Container(
                    width: 250.0,
                    height: MediaQuery.sizeOf(context).height * 1.0,
                    decoration: BoxDecoration(
                      color: Color(0xFF3C3D3E),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: wrapWithModel(
                      model: _model.menuSecretariaModel,
                      updateCallback: () => safeSetState(() {}),
                      child: MenuSecretariaWidget(),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                  child: Container(
                    width: 100.0,
                    height: MediaQuery.sizeOf(context).height * 1.0,
                    decoration: BoxDecoration(
                      color: Color(0xFF3C3D3E),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                24.0, 0.0, 24.0, 0.0),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Avisos – PIB Santa Fé do Sul',
                                            style: FlutterFlowTheme.of(context)
                                                .displaySmall
                                                .override(
                                                  font: GoogleFonts.interTight(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .displaySmall
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .displaySmall
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .displaySmall
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .displaySmall
                                                          .fontStyle,
                                                ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 4.0, 0.0, 0.0),
                                            child: Text(
                                              'Gestão de Avisos da Igreja',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            Color(0xFFB0B0B0),
                                                        fontSize: 20.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 8.0, 0.0, 0.0),
                                            child: FFButtonWidget(
                                              onPressed: () {
                                                context.pushNamed(
                                                  PageNovoAvisoSecretariaWidget
                                                      .routeName,
                                                  extra: <String, dynamic>{
                                                    kTransitionInfoKey:
                                                        TransitionInfo(
                                                      hasTransition: true,
                                                      transitionType:
                                                          PageTransitionType.fade,
                                                    ),
                                                  },
                                                );
                                              },
                                              text: 'Novo Aviso',
                                              icon: Icon(
                                                Icons.add,
                                                size: 18.0,
                                              ),
                                              options: FFButtonOptions(
                                                height: 44.0,
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        20.0, 0.0, 20.0, 0.0),
                                                iconPadding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(
                                                            0.0, 0.0, 0.0, 0.0),
                                                iconColor: Colors.white,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .success,
                                                textStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          font: GoogleFonts
                                                              .interTight(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .fontStyle,
                                                          ),
                                                          color: Colors.white,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .fontStyle,
                                                        ),
                                                elevation: 0.0,
                                                borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  FutureBuilder<List<AvisoRow>>(
                                    key: ValueKey(_model.refreshKey),
                                    future: AvisoTable().queryRows(
                                      queryFn: (q) => q.order('created_at', ascending: false),
                                    ),
                                    builder: (context, snapshot) {
                                      // Customize what your widget looks like when it's loading.
                                      if (!snapshot.hasData) {
                                        return Center(
                                          child: SizedBox(
                                            width: 50.0,
                                            height: 50.0,
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                FlutterFlowTheme.of(context).primary,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      List<AvisoRow> avisos = snapshot.data!;

                                      // Calcular estatísticas
                                      final now = DateTime.now();
                                      final avisosAtivos = avisos.where((a) =>
                                        a.expiraEm != null && a.expiraEm!.isAfter(now)
                                      ).length;
                                      final avisosExpirados = avisos.where((a) =>
                                        a.expiraEm != null && a.expiraEm!.isBefore(now)
                                      ).length;
                                      final avisosFixados = avisos.where((a) =>
                                        (a.fixado ?? false) && a.expiraEm != null && a.expiraEm!.isAfter(now)
                                      ).length;

                                      return Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          GridView(
                                            padding: EdgeInsets.zero,
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 4,
                                              crossAxisSpacing: 1.0,
                                              childAspectRatio: 1.0,
                                            ),
                                            primary: false,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            children: [
                                      Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Container(
                                          width: 100.0,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF14181B),
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            border: Border.all(
                                              color: Color(0xFF333333),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 60.0,
                                                  height: 60.0,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF1976D2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Icon(
                                                      Icons.visibility,
                                                      color: Colors.white,
                                                      size: 30.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '$avisosAtivos',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .headlineSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .interTight(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .headlineSmall
                                                                  .fontStyle,
                                                        ),
                                                        color: Colors.white,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .headlineSmall
                                                                .fontStyle,
                                                      ),
                                                ),
                                                Text(
                                                  'Avisos Ativos',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodySmall
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            Color(0xFFB0B0B0),
                                                        fontSize: 20.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ].divide(SizedBox(height: 12.0)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Container(
                                          width: 69.9,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF14181B),
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            border: Border.all(
                                              color: Color(0xFF333333),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 60.0,
                                                  height: 60.0,
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Icon(
                                                      Icons.event_busy,
                                                      color: Colors.white,
                                                      size: 30.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '$avisosExpirados',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .headlineSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .interTight(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .headlineSmall
                                                                  .fontStyle,
                                                        ),
                                                        color: Colors.white,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .headlineSmall
                                                                .fontStyle,
                                                      ),
                                                ),
                                                Text(
                                                  'Expirados',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodySmall
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            Color(0xFFB0B0B0),
                                                        fontSize: 20.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ].divide(SizedBox(height: 12.0)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Container(
                                          width: 48.72,
                                          height: 0.0,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF14181B),
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            border: Border.all(
                                              color: Color(0xFF333333),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 60.0,
                                                  height: 60.0,
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Icon(
                                                      Icons.push_pin,
                                                      color: Colors.white,
                                                      size: 30.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '$avisosFixados',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .headlineSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .interTight(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .headlineSmall
                                                                  .fontStyle,
                                                        ),
                                                        color: Colors.white,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .headlineSmall
                                                                .fontStyle,
                                                      ),
                                                ),
                                                Text(
                                                  'Fixados',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodySmall
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            Color(0xFFB0B0B0),
                                                        fontSize: 20.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ].divide(SizedBox(height: 12.0)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Container(
                                          width: 48.7,
                                          height: 10.03,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF14181B),
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            border: Border.all(
                                              color: Color(0xFF333333),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 60.0,
                                                  height: 60.0,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFDE0E52),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    child: Icon(
                                                      Icons.favorite,
                                                      color: Colors.white,
                                                      size: 30.0,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '3',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .headlineSmall
                                                      .override(
                                                        font: GoogleFonts
                                                            .interTight(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .headlineSmall
                                                                  .fontStyle,
                                                        ),
                                                        color: Colors.white,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .headlineSmall
                                                                .fontStyle,
                                                      ),
                                                ),
                                                Text(
                                                  'Média de curtidas',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodySmall
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontWeight,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            Color(0xFFB0B0B0),
                                                        fontSize: 20.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .fontWeight,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ].divide(SizedBox(height: 12.0)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                                          Padding(
                                                            padding: EdgeInsets.all(20.0),
                                                            child: Container(
                                                              width: double.infinity,
                                                              decoration: BoxDecoration(
                                                                color: Color(0xFF14181B),
                                                                borderRadius:
                                                                    BorderRadius.circular(16.0),
                                                                border: Border.all(
                                                                  color: Color(0xFF333333),
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsets.all(16.0),
                                                                child: Column(
                                                                  mainAxisSize: MainAxisSize.max,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment.start,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisSize: MainAxisSize.max,
                                                                      children: [
                                                                        Text(
                                                                          'Lista de Avisos',
                                                                          style: FlutterFlowTheme.of(
                                                                                  context)
                                                                              .titleMedium
                                                                              .override(
                                                                                font: GoogleFonts
                                                                                    .interTight(
                                                                                  fontWeight:
                                                                                      FontWeight.w600,
                                                                                  fontStyle:
                                                                                      FlutterFlowTheme.of(
                                                                                              context)
                                                                                          .titleMedium
                                                                                          .fontStyle,
                                                                                ),
                                                                                color: Colors.white,
                                                                                fontSize: 24.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight:
                                                                                    FontWeight.w600,
                                                                                fontStyle:
                                                                                    FlutterFlowTheme.of(
                                                                                            context)
                                                                                        .titleMedium
                                                                                        .fontStyle,
                                                                              ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    // Campo de pesquisa (sempre visível)
                                                                    Padding(
                                                                      padding: EdgeInsets.only(top: 16.0),
                                                                      child: TextFormField(
                                                                        controller: _model.searchController,
                                                                        focusNode: _model.searchFocusNode,
                                                                        onChanged: (value) => setState(() {}),
                                                                        decoration: InputDecoration(
                                                                          hintText: 'Buscar avisos...',
                                                                          prefixIcon: Icon(Icons.search, color: Color(0xFFB0B0B0)),
                                                                          suffixIcon: _model.searchController!.text.isNotEmpty
                                                                            ? IconButton(
                                                                                icon: Icon(Icons.clear, color: Color(0xFFB0B0B0)),
                                                                                onPressed: () {
                                                                                  _model.searchController?.clear();
                                                                                  setState(() {});
                                                                                },
                                                                              )
                                                                            : null,
                                                                          filled: true,
                                                                          fillColor: Color(0xFF3C3D3E),
                                                                          border: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(8.0),
                                                                            borderSide: BorderSide.none,
                                                                          ),
                                                                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                                                        ),
                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                          font: GoogleFonts.inter(),
                                                                          color: Colors.white,
                                                                          letterSpacing: 0.0,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    // Chips de filtro
                                                                    Padding(
                                                                      padding: EdgeInsets.only(top: 16.0),
                                                                      child: SingleChildScrollView(
                                                                        scrollDirection: Axis.horizontal,
                                                                        child: Row(
                                                                          children: [
                                                                            // Botão Todos
                                                                            InkWell(
                                                                              onTap: () {
                                                                                setState(() {
                                                                                  _model.filtroStatus = null;
                                                                                });
                                                                              },
                                                                              child: Container(
                                                                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                                                                decoration: BoxDecoration(
                                                                                  color: _model.filtroStatus == null
                                                                                    ? FlutterFlowTheme.of(context).primary
                                                                                    : Color(0xFF3C3D3E),
                                                                                  borderRadius: BorderRadius.circular(20.0),
                                                                                ),
                                                                                child: Text(
                                                                                  'Todos',
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    font: GoogleFonts.inter(),
                                                                                    color: Colors.white,
                                                                                    letterSpacing: 0.0,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(width: 8.0),
                                                                            // Botão Ativos
                                                                            InkWell(
                                                                              onTap: () {
                                                                                setState(() {
                                                                                  _model.filtroStatus = _model.filtroStatus == 'ativo' ? null : 'ativo';
                                                                                });
                                                                              },
                                                                              child: Container(
                                                                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                                                                decoration: BoxDecoration(
                                                                                  color: _model.filtroStatus == 'ativo'
                                                                                    ? FlutterFlowTheme.of(context).primary
                                                                                    : Color(0xFF3C3D3E),
                                                                                  borderRadius: BorderRadius.circular(20.0),
                                                                                ),
                                                                                child: Row(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    Icon(Icons.visibility, color: Colors.white, size: 16.0),
                                                                                    SizedBox(width: 6.0),
                                                                                    Text(
                                                                                      'Ativos',
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        font: GoogleFonts.inter(),
                                                                                        color: Colors.white,
                                                                                        letterSpacing: 0.0,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(width: 8.0),
                                                                            // Botão Expirados
                                                                            InkWell(
                                                                              onTap: () {
                                                                                setState(() {
                                                                                  _model.filtroStatus = _model.filtroStatus == 'expirado' ? null : 'expirado';
                                                                                });
                                                                              },
                                                                              child: Container(
                                                                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                                                                decoration: BoxDecoration(
                                                                                  color: _model.filtroStatus == 'expirado'
                                                                                    ? FlutterFlowTheme.of(context).primary
                                                                                    : Color(0xFF3C3D3E),
                                                                                  borderRadius: BorderRadius.circular(20.0),
                                                                                ),
                                                                                child: Row(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    Icon(Icons.event_busy, color: Colors.white, size: 16.0),
                                                                                    SizedBox(width: 6.0),
                                                                                    Text(
                                                                                      'Expirados',
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        font: GoogleFonts.inter(),
                                                                                        color: Colors.white,
                                                                                        letterSpacing: 0.0,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(width: 8.0),
                                                                            // Botão Fixados
                                                                            InkWell(
                                                                              onTap: () {
                                                                                setState(() {
                                                                                  _model.filtroStatus = _model.filtroStatus == 'fixado' ? null : 'fixado';
                                                                                });
                                                                              },
                                                                              child: Container(
                                                                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                                                                decoration: BoxDecoration(
                                                                                  color: _model.filtroStatus == 'fixado'
                                                                                    ? FlutterFlowTheme.of(context).primary
                                                                                    : Color(0xFF3C3D3E),
                                                                                  borderRadius: BorderRadius.circular(20.0),
                                                                                ),
                                                                                child: Row(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    Icon(Icons.push_pin, color: Colors.white, size: 16.0),
                                                                                    SizedBox(width: 6.0),
                                                                                    Text(
                                                                                      'Fixados',
                                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        font: GoogleFonts.inter(),
                                                                                        color: Colors.white,
                                                                                        letterSpacing: 0.0,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Builder(
                                                                      builder: (context) {
                                                                        // Aplicar filtros
                                                                        List<AvisoRow> avisosFiltrados = avisos.where((aviso) {
                                                                          final now = DateTime.now();
                                                                          final isAtivo = aviso.expiraEm != null && aviso.expiraEm!.isAfter(now);

                                                                          // Filtro de busca
                                                                          if (_model.searchController!.text.isNotEmpty) {
                                                                            final searchLower = _model.searchController!.text.toLowerCase();
                                                                            final nomeAviso = (aviso.nomeAviso ?? '').toLowerCase();
                                                                            if (!nomeAviso.contains(searchLower)) {
                                                                              return false;
                                                                            }
                                                                          }

                                                                          // Filtro de status
                                                                          if (_model.filtroStatus != null) {
                                                                            if (_model.filtroStatus == 'ativo' && !isAtivo) {
                                                                              return false;
                                                                            }
                                                                            if (_model.filtroStatus == 'expirado' && isAtivo) {
                                                                              return false;
                                                                            }
                                                                            // Por enquanto fixados = ativos (poderia ter um campo separado no futuro)
                                                                            if (_model.filtroStatus == 'fixado' && !isAtivo) {
                                                                              return false;
                                                                            }
                                                                          }

                                                                          // Filtro de categoria
                                                                          if (_model.filtroCategoria != null && aviso.categoria != _model.filtroCategoria) {
                                                                            return false;
                                                                          }

                                                                          return true;
                                                                        }).toList();

                                                                        return avisosFiltrados.isEmpty
                                                                      ? Center(
                                                                          child: Padding(
                                                                            padding: EdgeInsets.all(32.0),
                                                                            child: Text(
                                                                              'Nenhum aviso encontrado',
                                                                              style: FlutterFlowTheme.of(context)
                                                                                  .bodyMedium
                                                                                  .override(
                                                                                    font: GoogleFonts.inter(),
                                                                                    color: Color(0xFFB0B0B0),
                                                                                    fontSize: 16.0,
                                                                                    letterSpacing: 0.0,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : ListView.separated(
                                                                          padding: EdgeInsets.zero,
                                                                          primary: false,
                                                                          shrinkWrap: true,
                                                                          scrollDirection: Axis.vertical,
                                                                          itemCount: avisosFiltrados.length,
                                                                          separatorBuilder: (context, index) => SizedBox(height: 12.0),
                                                                          itemBuilder: (context, index) {
                                                                            final aviso = avisosFiltrados[index];
                                                                            final isAtivo = aviso.expiraEm != null && aviso.expiraEm!.isAfter(DateTime.now());

                                                                            // Se o aviso está expirado e fixado, desfixar automaticamente
                                                                            if (!isAtivo && (aviso.fixado ?? false)) {
                                                                              WidgetsBinding.instance.addPostFrameCallback((_) async {
                                                                                await AvisoTable().update(
                                                                                  data: {'fixado': false},
                                                                                  matchingRows: (rows) => rows.eq('id', aviso.id),
                                                                                );
                                                                              });
                                                                            }

                                                                            return Padding(
                                                                              padding: EdgeInsets.all(16.0),
                                                                              child: Container(
                                                                                width: double.infinity,
                                                                                decoration: BoxDecoration(
                                                                                  color: Color(0xFF3C3D3E),
                                                                                  borderRadius:
                                                                                      BorderRadius.circular(
                                                                                          12.0),
                                                                                  border: Border.all(
                                                                                    color:
                                                                                        Color(0xFF333333),
                                                                                    width: 1.0,
                                                                                  ),
                                                                                ),
                                                                                child: Padding(
                                                                                  padding:
                                                                                      EdgeInsets.all(12.0),
                                                                                  child: Row(
                                                                                    mainAxisSize:
                                                                                        MainAxisSize.max,
                                                                                    mainAxisAlignment:
                                                                                        MainAxisAlignment
                                                                                            .spaceBetween,
                                                                                    crossAxisAlignment:
                                                                                        CrossAxisAlignment
                                                                                            .center,
                                                                                    children: [
                                                                                      Expanded(
                                                                                        child: Column(
                                                                                          mainAxisSize:
                                                                                              MainAxisSize
                                                                                                  .max,
                                                                                          crossAxisAlignment:
                                                                                              CrossAxisAlignment
                                                                                                  .start,
                                                                                          children: [
                                                                                            Row(
                                                                                              mainAxisSize:
                                                                                                  MainAxisSize
                                                                                                      .max,
                                                                                              children: [
                                                                                                Text(
                                                                                                  aviso.nomeAviso ?? 'Sem título',
                                                                                                  style: FlutterFlowTheme.of(
                                                                                                          context)
                                                                                                      .titleSmall
                                                                                                      .override(
                                                                                                        font:
                                                                                                            GoogleFonts.interTight(
                                                                                                          fontWeight: FontWeight.w600,
                                                                                                          fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                                        ),
                                                                                                        color:
                                                                                                            Colors.white,
                                                                                                        letterSpacing:
                                                                                                            0.0,
                                                                                                        fontWeight:
                                                                                                            FontWeight.w600,
                                                                                                        fontStyle:
                                                                                                            FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                                                                      ),
                                                                                                ),
                                                                                                Container(
                                                                                                  decoration:
                                                                                                      BoxDecoration(
                                                                                                    color: isAtivo ? Colors.green : Colors.red,
                                                                                                    borderRadius:
                                                                                                        BorderRadius.circular(10.0),
                                                                                                  ),
                                                                                                  child:
                                                                                                      Padding(
                                                                                                    padding:
                                                                                                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                                                                                    child:
                                                                                                        Text(
                                                                                                      isAtivo ? 'ATIVO' : 'EXPIRADO',
                                                                                                      textAlign:
                                                                                                          TextAlign.center,
                                                                                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                                                            font: GoogleFonts.inter(
                                                                                                              fontWeight: FontWeight.bold,
                                                                                                              fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                                                                                                            ),
                                                                                                            color: Colors.white,
                                                                                                            fontSize: 11.0,
                                                                                                            letterSpacing: 0.0,
                                                                                                            fontWeight: FontWeight.bold,
                                                                                                            fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                                                                                                          ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ].divide(SizedBox(
                                                                                                  width:
                                                                                                      12.0)),
                                                                                            ),
                                                                                            Text(
                                                                                              'Tipo: ${aviso.categoria ?? 'N/A'} • Criado: ${aviso.createdAt != null ? dateTimeFormat('dd/MM/yyyy', aviso.createdAt) : 'N/A'} • Expira: ${aviso.expiraEm != null ? dateTimeFormat('dd/MM/yyyy', aviso.expiraEm) : 'N/A'}',
                                                                                              style: FlutterFlowTheme.of(
                                                                                                      context)
                                                                                                  .bodySmall
                                                                                                  .override(
                                                                                                    font: GoogleFonts
                                                                                                        .inter(
                                                                                                      fontWeight: FlutterFlowTheme.of(context)
                                                                                                          .bodySmall
                                                                                                          .fontWeight,
                                                                                                      fontStyle: FlutterFlowTheme.of(context)
                                                                                                          .bodySmall
                                                                                                          .fontStyle,
                                                                                                    ),
                                                                                                    color: Color(
                                                                                                        0xFFB0B0B0),
                                                                                                    fontSize:
                                                                                                        12.0,
                                                                                                    letterSpacing:
                                                                                                        0.0,
                                                                                                    fontWeight: FlutterFlowTheme.of(context)
                                                                                                        .bodySmall
                                                                                                        .fontWeight,
                                                                                                    fontStyle: FlutterFlowTheme.of(context)
                                                                                                        .bodySmall
                                                                                                        .fontStyle,
                                                                                                  ),
                                                                                            ),
                                                                                          ].divide(SizedBox(
                                                                                              height: 8.0)),
                                                                                        ),
                                                                                      ),
                                                                                      Row(
                                                                                        mainAxisSize:
                                                                                            MainAxisSize
                                                                                                .max,
                                                                                        children: [
                                                                                          FlutterFlowIconButton(
                                                                                            borderRadius:
                                                                                                6.0,
                                                                                            buttonSize:
                                                                                                32.0,
                                                                                            fillColor: Color(
                                                                                                0xFF1976D2),
                                                                                            icon: Icon(
                                                                                              Icons
                                                                                                  .visibility,
                                                                                              color: Colors
                                                                                                  .white,
                                                                                              size: 16.0,
                                                                                            ),
                                                                                            onPressed: () async {
                                                                                              await showDialog(
                                                                                                context: context,
                                                                                                builder: (dialogContext) {
                                                                                                  return Dialog(
                                                                                                    backgroundColor: Colors.transparent,
                                                                                                    child: Container(
                                                                                                      constraints: BoxConstraints(
                                                                                                        maxWidth: 600.0,
                                                                                                        maxHeight: MediaQuery.of(dialogContext).size.height * 0.9,
                                                                                                      ),
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: Color(0xFF14181B),
                                                                                                        borderRadius: BorderRadius.circular(16.0),
                                                                                                        border: Border.all(
                                                                                                          color: Color(0xFF333333),
                                                                                                          width: 2.0,
                                                                                                        ),
                                                                                                      ),
                                                                                                      child: SingleChildScrollView(
                                                                                                        child: Column(
                                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                          children: [
                                                                                                            // Header com botão fechar
                                                                                                            Padding(
                                                                                                              padding: EdgeInsets.all(16.0),
                                                                                                              child: Row(
                                                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                children: [
                                                                                                                  Expanded(
                                                                                                                    child: Text(
                                                                                                                      aviso.nomeAviso ?? 'Sem título',
                                                                                                                      style: FlutterFlowTheme.of(dialogContext)
                                                                                                                          .headlineSmall
                                                                                                                          .override(
                                                                                                                            font: GoogleFonts.interTight(
                                                                                                                              fontWeight: FontWeight.bold,
                                                                                                                            ),
                                                                                                                            color: Colors.white,
                                                                                                                            letterSpacing: 0.0,
                                                                                                                          ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                  IconButton(
                                                                                                                    icon: Icon(Icons.close, color: Color(0xFFB0B0B0)),
                                                                                                                    onPressed: () => Navigator.pop(dialogContext),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            ),
                                                                                                            // Imagem
                                                                                                            if (aviso.imagem != null && aviso.imagem!.isNotEmpty)
                                                                                                              Container(
                                                                                                                width: double.infinity,
                                                                                                                height: 300.0,
                                                                                                                child: Image.network(
                                                                                                                  aviso.imagem!,
                                                                                                                  width: double.infinity,
                                                                                                                  height: 300.0,
                                                                                                                  fit: BoxFit.contain,
                                                                                                                  errorBuilder: (context, error, stackTrace) {
                                                                                                                    return Container(
                                                                                                                      color: Color(0xFF3C3D3E),
                                                                                                                      child: Center(
                                                                                                                        child: Icon(
                                                                                                                          Icons.image_not_supported,
                                                                                                                          color: Color(0xFFB0B0B0),
                                                                                                                          size: 48.0,
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    );
                                                                                                                  },
                                                                                                                ),
                                                                                                              ),
                                                                                                            // Conteúdo
                                                                                                            Padding(
                                                                                                              padding: EdgeInsets.all(16.0),
                                                                                                              child: Column(
                                                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                children: [
                                                                                                                  // Badge de status
                                                                                                                  Container(
                                                                                                                    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                                                                                                    decoration: BoxDecoration(
                                                                                                                      color: isAtivo ? Colors.green : Colors.red,
                                                                                                                      borderRadius: BorderRadius.circular(20.0),
                                                                                                                    ),
                                                                                                                    child: Text(
                                                                                                                      isAtivo ? 'ATIVO' : 'EXPIRADO',
                                                                                                                      style: FlutterFlowTheme.of(dialogContext)
                                                                                                                          .bodySmall
                                                                                                                          .override(
                                                                                                                            font: GoogleFonts.inter(
                                                                                                                              fontWeight: FontWeight.bold,
                                                                                                                            ),
                                                                                                                            color: Colors.white,
                                                                                                                            fontSize: 12.0,
                                                                                                                            letterSpacing: 0.0,
                                                                                                                          ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                  SizedBox(height: 16.0),
                                                                                                                  // Categoria
                                                                                                                  Row(
                                                                                                                    children: [
                                                                                                                      Icon(Icons.category, color: Color(0xFFB0B0B0), size: 16.0),
                                                                                                                      SizedBox(width: 8.0),
                                                                                                                      Text(
                                                                                                                        'Categoria: ${aviso.categoria ?? 'N/A'}',
                                                                                                                        style: FlutterFlowTheme.of(dialogContext)
                                                                                                                            .bodyMedium
                                                                                                                            .override(
                                                                                                                              font: GoogleFonts.inter(),
                                                                                                                              color: Color(0xFFB0B0B0),
                                                                                                                              fontSize: 14.0,
                                                                                                                              letterSpacing: 0.0,
                                                                                                                            ),
                                                                                                                      ),
                                                                                                                    ],
                                                                                                                  ),
                                                                                                                  SizedBox(height: 8.0),
                                                                                                                  // Data de criação
                                                                                                                  Row(
                                                                                                                    children: [
                                                                                                                      Icon(Icons.calendar_today, color: Color(0xFFB0B0B0), size: 16.0),
                                                                                                                      SizedBox(width: 8.0),
                                                                                                                      Text(
                                                                                                                        'Criado em: ${aviso.createdAt != null ? dateTimeFormat('dd/MM/yyyy HH:mm', aviso.createdAt) : 'N/A'}',
                                                                                                                        style: FlutterFlowTheme.of(dialogContext)
                                                                                                                            .bodyMedium
                                                                                                                            .override(
                                                                                                                              font: GoogleFonts.inter(),
                                                                                                                              color: Color(0xFFB0B0B0),
                                                                                                                              fontSize: 14.0,
                                                                                                                              letterSpacing: 0.0,
                                                                                                                            ),
                                                                                                                      ),
                                                                                                                    ],
                                                                                                                  ),
                                                                                                                  SizedBox(height: 8.0),
                                                                                                                  // Data de expiração
                                                                                                                  Row(
                                                                                                                    children: [
                                                                                                                      Icon(Icons.event_busy, color: Color(0xFFB0B0B0), size: 16.0),
                                                                                                                      SizedBox(width: 8.0),
                                                                                                                      Text(
                                                                                                                        'Expira em: ${aviso.expiraEm != null ? dateTimeFormat('dd/MM/yyyy HH:mm', aviso.expiraEm) : 'N/A'}',
                                                                                                                        style: FlutterFlowTheme.of(dialogContext)
                                                                                                                            .bodyMedium
                                                                                                                            .override(
                                                                                                                              font: GoogleFonts.inter(),
                                                                                                                              color: Color(0xFFB0B0B0),
                                                                                                                              fontSize: 14.0,
                                                                                                                              letterSpacing: 0.0,
                                                                                                                            ),
                                                                                                                      ),
                                                                                                                    ],
                                                                                                                  ),
                                                                                                                  SizedBox(height: 24.0),
                                                                                                                  // Descrição resumida
                                                                                                                  if (aviso.descricaoResumida != null && aviso.descricaoResumida!.isNotEmpty)
                                                                                                                    Column(
                                                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                      children: [
                                                                                                                        Text(
                                                                                                                          'Resumo',
                                                                                                                          style: FlutterFlowTheme.of(dialogContext)
                                                                                                                              .titleSmall
                                                                                                                              .override(
                                                                                                                                font: GoogleFonts.interTight(
                                                                                                                                  fontWeight: FontWeight.w600,
                                                                                                                                ),
                                                                                                                                color: Colors.white,
                                                                                                                                letterSpacing: 0.0,
                                                                                                                              ),
                                                                                                                        ),
                                                                                                                        SizedBox(height: 8.0),
                                                                                                                        Text(
                                                                                                                          aviso.descricaoResumida!,
                                                                                                                          style: FlutterFlowTheme.of(dialogContext)
                                                                                                                              .bodyMedium
                                                                                                                              .override(
                                                                                                                                font: GoogleFonts.inter(),
                                                                                                                                color: Color(0xFFD0D0D0),
                                                                                                                                fontSize: 14.0,
                                                                                                                                letterSpacing: 0.0,
                                                                                                                              ),
                                                                                                                        ),
                                                                                                                        SizedBox(height: 16.0),
                                                                                                                      ],
                                                                                                                    ),
                                                                                                                  // Descrição completa
                                                                                                                  if (aviso.descricao != null && aviso.descricao!.isNotEmpty)
                                                                                                                    Column(
                                                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                      children: [
                                                                                                                        Text(
                                                                                                                          'Descrição Completa',
                                                                                                                          style: FlutterFlowTheme.of(dialogContext)
                                                                                                                              .titleSmall
                                                                                                                              .override(
                                                                                                                                font: GoogleFonts.interTight(
                                                                                                                                  fontWeight: FontWeight.w600,
                                                                                                                                ),
                                                                                                                                color: Colors.white,
                                                                                                                                letterSpacing: 0.0,
                                                                                                                              ),
                                                                                                                        ),
                                                                                                                        SizedBox(height: 8.0),
                                                                                                                        Text(
                                                                                                                          aviso.descricao!,
                                                                                                                          style: FlutterFlowTheme.of(dialogContext)
                                                                                                                              .bodyMedium
                                                                                                                              .override(
                                                                                                                                font: GoogleFonts.inter(),
                                                                                                                                color: Color(0xFFD0D0D0),
                                                                                                                                fontSize: 14.0,
                                                                                                                                letterSpacing: 0.0,
                                                                                                                              ),
                                                                                                                        ),
                                                                                                                      ],
                                                                                                                    ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            ),
                                                                                                          ],
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  );
                                                                                                },
                                                                                              );
                                                                                            },
                                                                                          ),
                                                                                          FlutterFlowIconButton(
                                                                                            borderRadius:
                                                                                                6.0,
                                                                                            buttonSize:
                                                                                                32.0,
                                                                                            fillColor:
                                                                                                Colors
                                                                                                    .orange,
                                                                                            icon: Icon(
                                                                                              Icons.edit,
                                                                                              color: Colors
                                                                                                  .white,
                                                                                              size: 16.0,
                                                                                            ),
                                                                                            onPressed: () {
                                                                                              context.pushNamed(
                                                                                                PageNovoAvisoSecretariaWidget.routeName,
                                                                                                queryParameters: {
                                                                                                  'avisoId': serializeParam(aviso.id, ParamType.int),
                                                                                                }.withoutNulls,
                                                                                                extra: <String, dynamic>{
                                                                                                  kTransitionInfoKey: TransitionInfo(
                                                                                                    hasTransition: true,
                                                                                                    transitionType: PageTransitionType.fade,
                                                                                                  ),
                                                                                                },
                                                                                              );
                                                                                            },
                                                                                          ),
                                                                                          FlutterFlowIconButton(
                                                                                            borderRadius:
                                                                                                6.0,
                                                                                            buttonSize:
                                                                                                32.0,
                                                                                            fillColor:
                                                                                                (aviso.fixado ?? false) ? Colors.green : Color(0xFF555555),
                                                                                            icon: Icon(
                                                                                              Icons.push_pin,
                                                                                              color: Colors
                                                                                                  .white,
                                                                                              size: 16.0,
                                                                                            ),
                                                                                            onPressed: () async {
                                                                                              // Se o aviso está expirado, não permite fixar
                                                                                              if (!isAtivo) {
                                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                                  SnackBar(
                                                                                                    content: Text('Não é possível fixar um aviso expirado!'),
                                                                                                    backgroundColor: Colors.orange,
                                                                                                  ),
                                                                                                );
                                                                                                return;
                                                                                              }

                                                                                              // Alternar o estado de fixado
                                                                                              final novoEstadoFixado = !(aviso.fixado ?? false);

                                                                                              await AvisoTable().update(
                                                                                                data: {
                                                                                                  'fixado': novoEstadoFixado,
                                                                                                },
                                                                                                matchingRows: (rows) => rows.eq('id', aviso.id),
                                                                                              );

                                                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                                                SnackBar(
                                                                                                  content: Text(
                                                                                                    novoEstadoFixado
                                                                                                      ? 'Aviso fixado com sucesso!'
                                                                                                      : 'Aviso desfixado com sucesso!'
                                                                                                  ),
                                                                                                  backgroundColor: FlutterFlowTheme.of(context).success,
                                                                                                ),
                                                                                              );
                                                                                              setState(() {
                                                                                                _model.refreshKey++;
                                                                                              });
                                                                                            },
                                                                                          ),
                                                                                          FlutterFlowIconButton(
                                                                                            borderRadius:
                                                                                                6.0,
                                                                                            buttonSize:
                                                                                                32.0,
                                                                                            fillColor:
                                                                                                Colors.red,
                                                                                            icon: Icon(
                                                                                              Icons.delete,
                                                                                              color: Colors
                                                                                                  .white,
                                                                                              size: 16.0,
                                                                                            ),
                                                                                            onPressed: () async {
                                                                                              final confirmDelete = await showDialog<bool>(
                                                                                                context: context,
                                                                                                builder: (alertDialogContext) {
                                                                                                  return AlertDialog(
                                                                                                    title: Text('Confirmar exclusão'),
                                                                                                    content: Text('Deseja realmente excluir este aviso?'),
                                                                                                    actions: [
                                                                                                      TextButton(
                                                                                                        onPressed: () => Navigator.pop(
                                                                                                            alertDialogContext, false),
                                                                                                        child: Text('Cancelar'),
                                                                                                      ),
                                                                                                      TextButton(
                                                                                                        onPressed: () => Navigator.pop(
                                                                                                            alertDialogContext, true),
                                                                                                        child: Text('Excluir'),
                                                                                                      ),
                                                                                                    ],
                                                                                                  );
                                                                                                },
                                                                                              ) ?? false;

                                                                                              if (confirmDelete) {
                                                                                                await AvisoTable().delete(
                                                                                                  matchingRows: (rows) => rows.eq('id', aviso.id),
                                                                                                );
                                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                                  SnackBar(
                                                                                                    content: Text('Aviso excluído com sucesso!'),
                                                                                                    backgroundColor: FlutterFlowTheme.of(context).success,
                                                                                                  ),
                                                                                                );
                                                                                                setState(() {
                                                                                                  _model.refreshKey++;
                                                                                                });
                                                                                              }
                                                                                            },
                                                                                          ),
                                                                                        ].divide(SizedBox(
                                                                                            width: 8.0)),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        );
                                                                      },
                                                                    ),
                                                                  ].divide(SizedBox(height: 16.0)),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                ]
                                    .divide(SizedBox(height: 24.0))
                                    .addToStart(SizedBox(height: 24.0))
                                    .addToEnd(SizedBox(height: 24.0)),
                              ),
                            ),
                          ),
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
}
