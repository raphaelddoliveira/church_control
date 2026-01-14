import '/backend/supabase/supabase.dart';
import '/components/meu_perfil_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/secretaria/menu_secretaria/menu_secretaria_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_saver/file_saver.dart';
import 'page_membros_secretaria_model.dart';
export 'page_membros_secretaria_model.dart';

class PageMembrosSecretariaWidget extends StatefulWidget {
  const PageMembrosSecretariaWidget({super.key});

  static String routeName = 'PageMembros_Secretaria';
  static String routePath = '/pageMembrosSecretaria';

  @override
  State<PageMembrosSecretariaWidget> createState() =>
      _PageMembrosSecretariaWidgetState();
}

class _PageMembrosSecretariaWidgetState
    extends State<PageMembrosSecretariaWidget> {
  late PageMembrosSecretariaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageMembrosSecretariaModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _getMembrosComDetalhes() async {
    // Buscar membros filtrados por nome
    final membros = await MembrosTable().queryRows(
      queryFn: (q) => q.ilike(
        'nome_membro',
        '%${_model.textController.text}%',
      ),
    );

    // Buscar todos os endereços e ministérios de uma vez
    final enderecos = await EnderecoTable().queryRows(queryFn: (q) => q);
    final membrosMinisterios =
        await MembrosMinisteriosTable().queryRows(queryFn: (q) => q);

    // Criar mapa para acesso rápido
    final enderecosMap = {for (var e in enderecos) e.idEndereco: e};
    final membrosMinisteriosMap = <String, List<int>>{};
    for (var mm in membrosMinisterios) {
      if (mm.idMembro != null && mm.idMinisterio != null) {
        membrosMinisteriosMap.putIfAbsent(mm.idMembro!, () => []);
        membrosMinisteriosMap[mm.idMembro!]!.add(mm.idMinisterio!);
      }
    }

    // Combinar dados
    final resultado = <Map<String, dynamic>>[];
    for (var membro in membros) {
      final endereco =
          membro.idEndereco != null ? enderecosMap[membro.idEndereco!] : null;
      final ministeriosDoMembro =
          membrosMinisteriosMap[membro.idMembro] ?? [];

      // Aplicar filtros
      bool passaFiltros = true;

      // Filtro de status
      if (_model.filtroStatus != null) {
        if (_model.filtroStatus == 'ativo' && membro.ativo != true) {
          passaFiltros = false;
        } else if (_model.filtroStatus == 'inativo' && membro.ativo != false) {
          passaFiltros = false;
        }
      }

      // Filtro de bairro
      if (_model.filtroBairro != null &&
          _model.filtroBairro!.isNotEmpty &&
          endereco?.bairro != _model.filtroBairro) {
        passaFiltros = false;
      }

      // Filtro de ministério
      if (_model.filtroMinisterio != null &&
          !ministeriosDoMembro.contains(_model.filtroMinisterio)) {
        passaFiltros = false;
      }

      // Filtro de data de nascimento
      if (_model.filtroDataNascimentoInicio != null &&
          membro.dataNascimento != null) {
        if (membro.dataNascimento!
            .isBefore(_model.filtroDataNascimentoInicio!)) {
          passaFiltros = false;
        }
      }
      if (_model.filtroDataNascimentoFim != null &&
          membro.dataNascimento != null) {
        if (membro.dataNascimento!.isAfter(_model.filtroDataNascimentoFim!)) {
          passaFiltros = false;
        }
      }

      if (passaFiltros) {
        resultado.add({
          'membro': membro,
          'endereco': endereco,
          'ministerios': ministeriosDoMembro,
        });
      }
    }

    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getMembrosComDetalhes(),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }
        List<Map<String, dynamic>> pageMembrosSecretariaDadosCompletos =
            snapshot.data!;
        List<MembrosRow> pageMembrosSecretariaMembrosRowList =
            pageMembrosSecretariaDadosCompletos
                .map((d) => d['membro'] as MembrosRow)
                .toList();

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
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
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 16.0, 0.0, 16.0),
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
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 16.0, 16.0, 16.0),
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        8.0, 8.0, 8.0, 8.0),
                                    child: Container(
                                      width: MediaQuery.sizeOf(context).width *
                                          1.0,
                                      height: 90.0,
                                      decoration: BoxDecoration(
                                        color: Color(0x00FFFFFF),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              width: 100.0,
                                              height: 100.0,
                                              decoration: BoxDecoration(
                                                color: Color(0x00FFFFFF),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Sua lista de Membros,',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primaryBackground,
                                                          fontSize: 18.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'PIB Santa Fé do Sul',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  font:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  fontSize:
                                                                      24.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                1.0, 0.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          8.0,
                                                                          0.0),
                                                              child:
                                                                  FFButtonWidget(
                                                                onPressed:
                                                                    () async {
                                                                  // Gera o PDF
                                                                  final pdfBytes =
                                                                      await functions
                                                                          .exportarMembrosPDF(
                                                                    pageMembrosSecretariaMembrosRowList,
                                                                  );

                                                                  // Salva o PDF
                                                                  await FileSaver
                                                                      .instance
                                                                      .saveFile(
                                                                    name:
                                                                        'lista_membros_${DateTime.now().millisecondsSinceEpoch}',
                                                                    bytes:
                                                                        pdfBytes,
                                                                    ext: 'pdf',
                                                                    mimeType:
                                                                        MimeType
                                                                            .pdf,
                                                                  );

                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content:
                                                                          Text(
                                                                        'PDF exportado com sucesso!',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                      backgroundColor:
                                                                          Color(
                                                                              0xFF027941),
                                                                    ),
                                                                  );
                                                                },
                                                                text:
                                                                    'Exportar PDF',
                                                                icon: Icon(
                                                                  Icons
                                                                      .picture_as_pdf,
                                                                  size: 15.0,
                                                                ),
                                                                options:
                                                                    FFButtonOptions(
                                                                  height: 40.0,
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          0.0),
                                                                  iconPadding:
                                                                      EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                              0.0,
                                                                              0.0,
                                                                              0.0,
                                                                              0.0),
                                                                  color: Color(
                                                                      0x4D5C3B8A),
                                                                  textStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .interTight(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                        color: Colors
                                                                            .white,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .fontStyle,
                                                                      ),
                                                                  elevation: 0.0,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          8.0,
                                                                          0.0),
                                                              child:
                                                                  FFButtonWidget(
                                                                onPressed:
                                                                    () async {
                                                                  context.pushNamed(
                                                                      PageMembrosNovoSecretariaWidget
                                                                          .routeName);
                                                                },
                                                                text:
                                                                    'Novo Membro',
                                                                icon: Icon(
                                                                  Icons.add,
                                                                  size: 15.0,
                                                                ),
                                                                options:
                                                                    FFButtonOptions(
                                                                  height: 40.0,
                                                                  padding: EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          0.0),
                                                                  iconPadding:
                                                                      EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                              0.0,
                                                                              0.0,
                                                                              0.0,
                                                                              0.0),
                                                                  color: Color(
                                                                      0x4D027941),
                                                                  textStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .interTight(
                                                                          fontWeight: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontWeight,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .titleSmall
                                                                              .fontStyle,
                                                                        ),
                                                                        color: Colors
                                                                            .white,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .titleSmall
                                                                            .fontStyle,
                                                                      ),
                                                                  elevation: 0.0,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                ),
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
                                          ),
                                          if (responsiveVisibility(
                                            context: context,
                                            desktop: false,
                                          ))
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Color(0x80000000),
                                                  enableDrag: false,
                                                  context: context,
                                                  builder: (context) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        FocusScope.of(context)
                                                            .unfocus();
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                      },
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child:
                                                            MeuPerfilWidget(),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Icon(
                                                Icons.menu,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                size: 30.0,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        8.0, 8.0, 8.0, 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _model.textController,
                                            focusNode: _model.textFieldFocusNode,
                                            onChanged: (_) => EasyDebounce.debounce(
                                              '_model.textController',
                                              Duration(milliseconds: 500),
                                              () => safeSetState(() {}),
                                            ),
                                            autofocus: false,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              labelStyle: FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight:
                                                          FlutterFlowTheme.of(context)
                                                              .labelMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(context)
                                                              .labelMedium
                                                              .fontStyle,
                                                    ),
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                        FlutterFlowTheme.of(context)
                                                            .labelMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(context)
                                                            .labelMedium
                                                            .fontStyle,
                                                  ),
                                              hintText: 'Coloque o nome do membro',
                                              hintStyle: FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .override(
                                                    font: GoogleFonts.inter(
                                                      fontWeight:
                                                          FlutterFlowTheme.of(context)
                                                              .labelMedium
                                                              .fontWeight,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(context)
                                                              .labelMedium
                                                              .fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                        FlutterFlowTheme.of(context)
                                                            .labelMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(context)
                                                            .labelMedium
                                                            .fontStyle,
                                                  ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(context)
                                                      .error,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              focusedErrorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(context)
                                                      .error,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              filled: true,
                                              fillColor: FlutterFlowTheme.of(context)
                                                  .primaryText,
                                              prefixIcon: Icon(
                                                Icons.search_sharp,
                                                color: FlutterFlowTheme.of(context)
                                                    .primaryBackground,
                                              ),
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.inter(
                                                    fontWeight:
                                                        FlutterFlowTheme.of(context)
                                                            .bodyMedium
                                                            .fontWeight,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(context)
                                                            .bodyMedium
                                                            .fontStyle,
                                                  ),
                                                  color: FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                                  letterSpacing: 0.0,
                                                  fontWeight:
                                                      FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                            cursorColor: FlutterFlowTheme.of(context)
                                                .primaryText,
                                            validator: _model.textControllerValidator
                                                .asValidator(context),
                                          ),
                                        ),
                                        // Botão de Filtro
                                        Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            8.0, 0.0, 0.0, 0.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                FlutterFlowTheme.of(context).primaryText,
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.filter_list,
                                              color: FlutterFlowTheme.of(context)
                                                  .primaryBackground,
                                              size: 24.0,
                                            ),
                                            onPressed: () async {
                                    await showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      enableDrag: false,
                                      context: context,
                                      builder: (context) {
                                        return GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: Padding(
                                            padding:
                                                MediaQuery.viewInsetsOf(context),
                                            child: Container(
                                              height: MediaQuery.sizeOf(context).height * 0.7,
                                              decoration: BoxDecoration(
                                                color: Color(0xFF3C3D3E),
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20.0),
                                                  topRight: Radius.circular(20.0),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Filtros',
                                                          style: FlutterFlowTheme.of(context)
                                                              .headlineSmall
                                                              .override(
                                                                font: GoogleFonts.inter(),
                                                                color: FlutterFlowTheme.of(context).primaryBackground,
                                                                letterSpacing: 0.0,
                                                              ),
                                                        ),
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.close,
                                                            color: FlutterFlowTheme.of(context).primaryBackground,
                                                            size: 24.0,
                                                          ),
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: ListView(
                                                      padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
                                                      children: [
                                                          // Filtro de Status
                                                          DropdownButtonFormField<
                                                              String>(
                                                            value: _model
                                                                .filtroStatus,
                                                            decoration:
                                                                InputDecoration(
                                                              labelText:
                                                                  'Status',
                                                              labelStyle: FlutterFlowTheme.of(
                                                                      context)
                                                                  .labelMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                              filled: true,
                                                              fillColor: FlutterFlowTheme.of(
                                                                      context)
                                                                  .primaryText,
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        8.0),
                                                              ),
                                                            ),
                                                            dropdownColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                            items: [
                                                              DropdownMenuItem(
                                                                value: null,
                                                                child: Text(
                                                                    'Todos',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font: GoogleFonts.inter(),
                                                                          color: FlutterFlowTheme.of(context).primaryBackground,
                                                                          letterSpacing: 0.0,
                                                                        )),
                                                              ),
                                                              DropdownMenuItem(
                                                                value: 'ativo',
                                                                child: Text(
                                                                    'Ativo',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font: GoogleFonts.inter(),
                                                                          color: FlutterFlowTheme.of(context).primaryBackground,
                                                                          letterSpacing: 0.0,
                                                                        )),
                                                              ),
                                                              DropdownMenuItem(
                                                                value: 'inativo',
                                                                child: Text(
                                                                    'Inativo',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          font: GoogleFonts.inter(),
                                                                          color: FlutterFlowTheme.of(context).primaryBackground,
                                                                          letterSpacing: 0.0,
                                                                        )),
                                                              ),
                                                            ],
                                                            onChanged: (value) {
                                                              safeSetState(() {
                                                                _model.filtroStatus =
                                                                    value;
                                                              });
                                                            },
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .inter(),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryBackground,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                          SizedBox(height: 16.0),
                                                          // Filtro de Bairro
                                                          FutureBuilder<
                                                              List<String>>(
                                                            future: EnderecoTable()
                                                                .queryRows(
                                                                    queryFn: (q) =>
                                                                        q)
                                                                .then((enderecos) =>
                                                                    enderecos
                                                                        .where((e) =>
                                                                            e.bairro !=
                                                                                null &&
                                                                            e.bairro!
                                                                                .isNotEmpty)
                                                                        .map((e) =>
                                                                            e.bairro!)
                                                                        .toSet()
                                                                        .toList()
                                                                      ..sort()),
                                                            builder: (context,
                                                                snapshot) {
                                                              final bairros =
                                                                  snapshot.data ??
                                                                      [];
                                                              // Verificar se o valor selecionado existe nos items
                                                              final valorValido = _model.filtroBairro != null && bairros.contains(_model.filtroBairro)
                                                                  ? _model.filtroBairro
                                                                  : null;
                                                              return DropdownButtonFormField<
                                                                  String>(
                                                                value: valorValido,
                                                                decoration:
                                                                    InputDecoration(
                                                                  labelText:
                                                                      'Bairro',
                                                                  labelStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts.inter(),
                                                                        color: FlutterFlowTheme.of(context).primaryBackground,
                                                                        letterSpacing: 0.0,
                                                                      ),
                                                                  filled: true,
                                                                  fillColor: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(8.0),
                                                                  ),
                                                                ),
                                                                dropdownColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                items: [
                                                                  DropdownMenuItem(
                                                                    value: null,
                                                                    child: Text(
                                                                        'Todos',
                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                              font: GoogleFonts.inter(),
                                                                              color: FlutterFlowTheme.of(context).primaryBackground,
                                                                              letterSpacing: 0.0,
                                                                            )),
                                                                  ),
                                                                  ...bairros.map((bairro) => DropdownMenuItem(
                                                                        value: bairro,
                                                                        child: Text(bairro, style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                              font: GoogleFonts.inter(),
                                                                              color: FlutterFlowTheme.of(context).primaryBackground,
                                                                              letterSpacing: 0.0,
                                                                            )),
                                                                      )),
                                                                ],
                                                                onChanged:
                                                                    (value) {
                                                                  safeSetState(
                                                                      () {
                                                                    _model.filtroBairro =
                                                                        value;
                                                                  });
                                                                },
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .inter(),
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground,
                                                                      letterSpacing:
                                                                          0.0,
                                                                    ),
                                                              );
                                                            },
                                                          ),
                                                          SizedBox(height: 16.0),
                                                          // Filtro de Ministério
                                                          FutureBuilder<
                                                              List<MinisterioRow>>(
                                                            future: MinisterioTable()
                                                                .queryRows(
                                                                    queryFn: (q) =>
                                                                        q),
                                                            builder: (context,
                                                                snapshot) {
                                                              final ministerios =
                                                                  snapshot.data ??
                                                                      [];
                                                              // Verificar se o valor selecionado existe nos items
                                                              final ministerioIds = ministerios.map((m) => m.idMinisterio).toList();
                                                              final valorValido = _model.filtroMinisterio != null && ministerioIds.contains(_model.filtroMinisterio)
                                                                  ? _model.filtroMinisterio
                                                                  : null;
                                                              return DropdownButtonFormField<
                                                                  int>(
                                                                value: valorValido,
                                                                decoration:
                                                                    InputDecoration(
                                                                  labelText:
                                                                      'Ministério',
                                                                  labelStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .labelMedium
                                                                      .override(
                                                                        font: GoogleFonts.inter(),
                                                                        color: FlutterFlowTheme.of(context).primaryBackground,
                                                                        letterSpacing: 0.0,
                                                                      ),
                                                                  filled: true,
                                                                  fillColor: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(8.0),
                                                                  ),
                                                                ),
                                                                dropdownColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                items: [
                                                                  DropdownMenuItem(
                                                                    value: null,
                                                                    child: Text(
                                                                        'Todos',
                                                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                              font: GoogleFonts.inter(),
                                                                              color: FlutterFlowTheme.of(context).primaryBackground,
                                                                              letterSpacing: 0.0,
                                                                            )),
                                                                  ),
                                                                  ...ministerios.map((ministerio) => DropdownMenuItem(
                                                                        value: ministerio.idMinisterio,
                                                                        child: Text(ministerio.nomeMinisterio, style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                              font: GoogleFonts.inter(),
                                                                              color: FlutterFlowTheme.of(context).primaryBackground,
                                                                              letterSpacing: 0.0,
                                                                            )),
                                                                      )),
                                                                ],
                                                                onChanged:
                                                                    (value) {
                                                                  safeSetState(
                                                                      () {
                                                                    _model.filtroMinisterio =
                                                                        value;
                                                                  });
                                                                },
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      font: GoogleFonts
                                                                          .inter(),
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground,
                                                                      letterSpacing:
                                                                          0.0,
                                                                    ),
                                                              );
                                                            },
                                                          ),
                                                          SizedBox(height: 24.0),
                                                          // Botão Aplicar Filtros
                                                          FFButtonWidget(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                            },
                                                            text: 'Aplicar Filtros',
                                                            icon: Icon(
                                                              Icons.check,
                                                              size: 15.0,
                                                            ),
                                                            options:
                                                                FFButtonOptions(
                                                              width: double
                                                                  .infinity,
                                                              height: 50.0,
                                                              padding: EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      16.0,
                                                                      0.0,
                                                                      16.0,
                                                                      0.0),
                                                              color: Color(
                                                                  0x4D027941),
                                                              textStyle: FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .interTight(),
                                                                    color: Colors
                                                                        .white,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                              elevation: 0.0,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                          ),
                                                          SizedBox(height: 12.0),
                                                          // Botão limpar filtros
                                                          FFButtonWidget(
                                                            onPressed: () {
                                                              safeSetState(() {
                                                                _model.filtroStatus =
                                                                    null;
                                                                _model.filtroBairro =
                                                                    null;
                                                                _model.filtroMinisterio =
                                                                    null;
                                                                _model.filtroDataNascimentoInicio =
                                                                    null;
                                                                _model.filtroDataNascimentoFim =
                                                                    null;
                                                              });
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            text: 'Limpar Filtros',
                                                            icon: Icon(
                                                              Icons.clear,
                                                              size: 15.0,
                                                            ),
                                                            options:
                                                                FFButtonOptions(
                                                              width: double
                                                                  .infinity,
                                                              height: 50.0,
                                                              padding: EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      16.0,
                                                                      0.0,
                                                                      16.0,
                                                                      0.0),
                                                              color: Color(
                                                                  0x4DFF5963),
                                                              textStyle: FlutterFlowTheme.of(
                                                                      context)
                                                                  .titleSmall
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .interTight(),
                                                                    color: Colors
                                                                        .white,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                              elevation: 0.0,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
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
                                    ).then((value) => safeSetState(() {}));
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 1.0, 0.0, 0.0),
                                    child: Builder(
                                      builder: (context) {
                                        final listamembros =
                                            pageMembrosSecretariaMembrosRowList
                                                .toList();

                                        return ListView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount: listamembros.length,
                                          itemBuilder:
                                              (context, listamembrosIndex) {
                                            final listamembrosItem =
                                                listamembros[listamembrosIndex];
                                            return Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 1.0),
                                              child: FutureBuilder<
                                                  List<TelefoneRow>>(
                                                future: TelefoneTable()
                                                    .querySingleRow(
                                                  queryFn: (q) => q.eqOrNull(
                                                    'id_membro',
                                                    listamembrosItem.idMembro,
                                                  ),
                                                ),
                                                builder: (context, snapshot) {
                                                  // Customize what your widget looks like when it's loading.
                                                  if (!snapshot.hasData) {
                                                    return Center(
                                                      child: SizedBox(
                                                        width: 50.0,
                                                        height: 50.0,
                                                        child:
                                                            CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                  Color>(
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  List<TelefoneRow>
                                                      containerTelefoneRowList =
                                                      snapshot.data!;

                                                  final containerTelefoneRow =
                                                      containerTelefoneRowList
                                                              .isNotEmpty
                                                          ? containerTelefoneRowList
                                                              .first
                                                          : null;

                                                  return InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    focusColor:
                                                        Colors.transparent,
                                                    hoverColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    onTap: () async {
                                                      context.pushNamed(
                                                        PageMembrosDetalhesSecretariaWidget
                                                            .routeName,
                                                        queryParameters: {
                                                          'idmembro':
                                                              serializeParam(
                                                            listamembrosItem
                                                                .idMembro,
                                                            ParamType.String,
                                                          ),
                                                          'idendereco':
                                                              serializeParam(
                                                            listamembrosItem
                                                                .idEndereco,
                                                            ParamType.int,
                                                          ),
                                                        }.withoutNulls,
                                                      );
                                                    },
                                                    child: Container(
                                                      width: 100.0,
                                                      height: 72.0,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFE0E3E7),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    16.0,
                                                                    0.0,
                                                                    16.0,
                                                                    0.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              width: 44.0,
                                                              height: 44.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryBackground,
                                                                shape: BoxShape
                                                                    .circle,
                                                                border:
                                                                    Border.all(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  width: 2.0,
                                                                ),
                                                              ),
                                                              child: Icon(
                                                                Icons.person,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primaryText,
                                                                size: 24.0,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            12.0,
                                                                            0.0,
                                                                            0.0,
                                                                            0.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          4.0),
                                                                      child:
                                                                          Text(
                                                                        listamembrosItem
                                                                            .nomeMembro,
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyLarge
                                                                            .override(
                                                                              font: GoogleFonts.inter(
                                                                                fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                                                                                fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                                              ),
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      valueOrDefault<
                                                                          String>(
                                                                        containerTelefoneRow
                                                                            ?.numeroTelefone,
                                                                        'Sem número',
                                                                      ),
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelMedium
                                                                          .override(
                                                                            font:
                                                                                GoogleFonts.inter(
                                                                              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                            ),
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                                            fontStyle:
                                                                                FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                                          ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            Icon(
                                                              Icons
                                                                  .chevron_right_rounded,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryText,
                                                              size: 24.0,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        );
                                      },
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
              ],
            ),
          ),
        );
      },
    );
  }
}
