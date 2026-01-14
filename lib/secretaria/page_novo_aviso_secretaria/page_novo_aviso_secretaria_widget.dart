import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import '/secretaria/menu_secretaria/menu_secretaria_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'page_novo_aviso_secretaria_model.dart';
export 'page_novo_aviso_secretaria_model.dart';

class PageNovoAvisoSecretariaWidget extends StatefulWidget {
  const PageNovoAvisoSecretariaWidget({
    super.key,
    this.avisoId,
  });

  final int? avisoId;

  static String routeName = 'PageNovoAvisoSecretaria';
  static String routePath = '/pageNovoAvisoSecretaria';

  @override
  State<PageNovoAvisoSecretariaWidget> createState() =>
      _PageNovoAvisoSecretariaWidgetState();
}

class _PageNovoAvisoSecretariaWidgetState
    extends State<PageNovoAvisoSecretariaWidget> {
  late PageNovoAvisoSecretariaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageNovoAvisoSecretariaModel());

    // Inicializar controladores
    _model.nomeAvisoTextController ??= TextEditingController();
    _model.nomeAvisoFocusNode ??= FocusNode();

    _model.dataHoraAvisoTextController ??= TextEditingController();
    _model.dataHoraAvisoFocusNode ??= FocusNode();

    _model.dataExpiracaoTextController ??= TextEditingController();
    _model.dataExpiracaoFocusNode ??= FocusNode();

    _model.descricaoResumidaTextController ??= TextEditingController();
    _model.descricaoResumidaFocusNode ??= FocusNode();

    _model.descricaoTextController ??= TextEditingController();
    _model.descricaoFocusNode ??= FocusNode();

    // Se estiver editando, buscar dados do banco
    if (widget.avisoId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          print('Buscando aviso com ID: ${widget.avisoId}');
          final avisos = await AvisoTable().queryRows(
            queryFn: (q) => q.eq('id', widget.avisoId!),
          );

          print('Avisos encontrados: ${avisos.length}');

          if (avisos.isNotEmpty) {
            final aviso = avisos.first;
            print('Aviso encontrado: ${aviso.nomeAviso}');

            setState(() {
              _model.nomeAvisoTextController.text = aviso.nomeAviso ?? '';
              _model.categoriaValue = aviso.categoria;

              if (aviso.dataHoraAviso != null) {
                _model.dataHoraAvisoTextController.text =
                  dateTimeFormat('dd/MM/yyyy HH:mm', aviso.dataHoraAviso);
                _model.pickedDate = aviso.dataHoraAviso;
              }

              if (aviso.expiraEm != null) {
                _model.dataExpiracaoTextController.text =
                  dateTimeFormat('dd/MM/yyyy HH:mm', aviso.expiraEm);
                _model.pickedDateExpiracao = aviso.expiraEm;
              }

              if (aviso.imagem != null && aviso.imagem!.isNotEmpty) {
                _model.uploadedFileUrl = aviso.imagem!;
              }

              _model.descricaoResumidaTextController.text = aviso.descricaoResumida ?? '';
              _model.descricaoTextController.text = aviso.descricao ?? '';
            });

            print('Campos preenchidos com sucesso');
          } else {
            print('Nenhum aviso encontrado');
          }
        } catch (e) {
          print('Erro ao carregar aviso: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao carregar aviso: $e'),
              backgroundColor: FlutterFlowTheme.of(context).error,
            ),
          );
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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
                                24.0, 24.0, 24.0, 24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Cabeçalho
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Novo Aviso',
                                          style: FlutterFlowTheme.of(context)
                                              .displaySmall
                                              .override(
                                                font: GoogleFonts.interTight(),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        Text(
                                          'Cadastre um novo aviso para a igreja',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ],
                                    ),
                                    FFButtonWidget(
                                      onPressed: () {
                                        context.safePop();
                                      },
                                      text: 'Voltar',
                                      icon: Icon(
                                        Icons.arrow_back,
                                        size: 15.0,
                                      ),
                                      options: FFButtonOptions(
                                        height: 40.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        color: Color(0xFF3C3D3E),
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              font: GoogleFonts.interTight(),
                                              color: Colors.white,
                                              letterSpacing: 0.0,
                                            ),
                                        elevation: 0.0,
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24.0),
                                // Formulário
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF14181B),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        24.0, 24.0, 24.0, 24.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Informações do Aviso',
                                          style: FlutterFlowTheme.of(context)
                                              .headlineSmall
                                              .override(
                                                font: GoogleFonts.interTight(),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        SizedBox(height: 24.0),
                                        // Nome do Aviso
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Nome do Aviso *',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            SizedBox(height: 8.0),
                                            TextFormField(
                                              controller:
                                                  _model.nomeAvisoTextController,
                                              focusNode:
                                                  _model.nomeAvisoFocusNode,
                                              autofocus: false,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Ex: Culto de Celebração',
                                                hintStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .inter(),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          letterSpacing: 0.0,
                                                        ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                filled: true,
                                                fillColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                              ),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    letterSpacing: 0.0,
                                                  ),
                                              cursorColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              validator: _model
                                                  .nomeAvisoTextControllerValidator
                                                  .asValidator(context),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16.0),
                                        // Categoria
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Categoria *',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            SizedBox(height: 8.0),
                                            FlutterFlowDropDown<String>(
                                              controller: _model
                                                      .categoriaValueController ??=
                                                  FormFieldController<String>(
                                                      null),
                                              options: [
                                                'Evento',
                                                'Aviso Geral',
                                                'Culto',
                                                'Retiro',
                                                'Reunião',
                                                'Outro'
                                              ],
                                              onChanged: (val) => safeSetState(
                                                  () => _model.categoriaValue =
                                                      val),
                                              width: double.infinity,
                                              height: 50.0,
                                              textStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(),
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .primaryBackground,
                                                        letterSpacing: 0.0,
                                                      ),
                                              hintText: 'Selecione a categoria',
                                              icon: Icon(
                                                Icons.keyboard_arrow_down,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                size: 24.0,
                                              ),
                                              fillColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              elevation: 2.0,
                                              borderColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              borderWidth: 1.0,
                                              borderRadius: 8.0,
                                              margin: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      12.0, 0.0, 12.0, 0.0),
                                              hidesUnderline: true,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16.0),
                                        // Data e Hora do Aviso
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Data e Hora do Evento *',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            SizedBox(height: 8.0),
                                            TextFormField(
                                              controller: _model
                                                  .dataHoraAvisoTextController,
                                              focusNode:
                                                  _model.dataHoraAvisoFocusNode,
                                              autofocus: false,
                                              readOnly: true,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Selecione a data e hora',
                                                hintStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .inter(),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          letterSpacing: 0.0,
                                                        ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                filled: true,
                                                fillColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                suffixIcon: Icon(
                                                  Icons.calendar_today,
                                                  color:
                                                      FlutterFlowTheme.of(context)
                                                          .secondaryText,
                                                ),
                                              ),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    letterSpacing: 0.0,
                                                  ),
                                              onTap: () async {
                                                final datePicked =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate:
                                                      getCurrentTimestamp,
                                                  firstDate: DateTime(1900),
                                                  lastDate: DateTime(2050),
                                                  builder: (context, child) {
                                                    return Theme(
                                                      data: ThemeData.dark(),
                                                      child: child!,
                                                    );
                                                  },
                                                );

                                                if (datePicked != null) {
                                                  safeSetState(() {
                                                    _model.pickedDate =
                                                        DateTime(
                                                      datePicked.year,
                                                      datePicked.month,
                                                      datePicked.day,
                                                    );
                                                  });
                                                  _model
                                                      .dataHoraAvisoTextController
                                                      ?.text = dateTimeFormat(
                                                    "dd/MM/yyyy",
                                                    _model.pickedDate,
                                                    locale: FFLocalizations.of(
                                                            context)
                                                        .languageCode,
                                                  );
                                                }
                                              },
                                              cursorColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              validator: _model
                                                  .dataHoraAvisoTextControllerValidator
                                                  .asValidator(context),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16.0),
                                        // Data de Expiração
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Data de Expiração *',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            SizedBox(height: 8.0),
                                            TextFormField(
                                              controller: _model
                                                  .dataExpiracaoTextController,
                                              focusNode:
                                                  _model.dataExpiracaoFocusNode,
                                              autofocus: false,
                                              readOnly: true,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Quando o aviso expira',
                                                hintStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .inter(),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          letterSpacing: 0.0,
                                                        ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                filled: true,
                                                fillColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                suffixIcon: Icon(
                                                  Icons.calendar_today,
                                                  color:
                                                      FlutterFlowTheme.of(context)
                                                          .secondaryText,
                                                ),
                                              ),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    letterSpacing: 0.0,
                                                  ),
                                              onTap: () async {
                                                final datePicked =
                                                    await showDatePicker(
                                                  context: context,
                                                  initialDate:
                                                      getCurrentTimestamp,
                                                  firstDate: getCurrentTimestamp,
                                                  lastDate: DateTime(2050),
                                                  builder: (context, child) {
                                                    return Theme(
                                                      data: ThemeData.dark(),
                                                      child: child!,
                                                    );
                                                  },
                                                );

                                                if (datePicked != null) {
                                                  safeSetState(() {
                                                    _model.pickedDateExpiracao =
                                                        DateTime(
                                                      datePicked.year,
                                                      datePicked.month,
                                                      datePicked.day,
                                                    );
                                                  });
                                                  _model
                                                      .dataExpiracaoTextController
                                                      ?.text = dateTimeFormat(
                                                    "dd/MM/yyyy",
                                                    _model.pickedDateExpiracao,
                                                    locale: FFLocalizations.of(
                                                            context)
                                                        .languageCode,
                                                  );
                                                }
                                              },
                                              cursorColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              validator: _model
                                                  .dataExpiracaoTextControllerValidator
                                                  .asValidator(context),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16.0),
                                        // Upload de Imagem
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Imagem do Aviso',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            SizedBox(height: 8.0),
                                            // Preview da imagem se já foi carregada
                                            if (_model.uploadedFileUrl.isNotEmpty)
                                              Container(
                                                width: double.infinity,
                                                height: 200.0,
                                                margin: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12.0),
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(context).secondaryText,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  child: Image.network(
                                                    _model.uploadedFileUrl,
                                                    width: double.infinity,
                                                    height: 200.0,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        color: FlutterFlowTheme.of(context).primaryText,
                                                        child: Center(
                                                          child: Icon(
                                                            Icons.image_not_supported,
                                                            color: FlutterFlowTheme.of(context).secondaryText,
                                                            size: 48.0,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    loadingBuilder: (context, child, loadingProgress) {
                                                      if (loadingProgress == null) return child;
                                                      return Container(
                                                        color: FlutterFlowTheme.of(context).primaryText,
                                                        child: Center(
                                                          child: CircularProgressIndicator(
                                                            value: loadingProgress.expectedTotalBytes != null
                                                                ? loadingProgress.cumulativeBytesLoaded /
                                                                    loadingProgress.expectedTotalBytes!
                                                                : null,
                                                            valueColor: AlwaysStoppedAnimation<Color>(
                                                              FlutterFlowTheme.of(context).primary,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            FFButtonWidget(
                                              onPressed: () async {
                                                final selectedMedia =
                                                    await selectMedia(
                                                  mediaSource: MediaSource.photoGallery,
                                                  multiImage: false,
                                                );
                                                if (selectedMedia != null &&
                                                    selectedMedia.every((m) =>
                                                        validateFileFormat(
                                                            m.storagePath,
                                                            context))) {
                                                  safeSetState(() => _model
                                                      .uploadedFileUrl = '');

                                                  var downloadUrls = <String>[];
                                                  try {
                                                    downloadUrls =
                                                        await uploadSupabaseStorageFiles(
                                                      bucketName: 'arquivos',
                                                      selectedFiles:
                                                          selectedMedia,
                                                    );
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Erro ao fazer upload da imagem: $e',
                                                          style: FlutterFlowTheme.of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts.inter(),
                                                                color: Colors.white,
                                                                letterSpacing: 0.0,
                                                              ),
                                                        ),
                                                        duration: Duration(milliseconds: 3000),
                                                        backgroundColor: FlutterFlowTheme.of(context).error,
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  if (downloadUrls.length ==
                                                      selectedMedia.length) {
                                                    safeSetState(() => _model
                                                            .uploadedFileUrl =
                                                        downloadUrls.first);
                                                  } else {
                                                    safeSetState(() {});
                                                    return;
                                                  }
                                                }
                                              },
                                              text: _model.uploadedFileUrl
                                                      .isEmpty
                                                  ? 'Selecionar Imagem'
                                                  : 'Alterar Imagem',
                                              icon: Icon(
                                                _model.uploadedFileUrl.isEmpty
                                                    ? Icons.upload_file
                                                    : Icons.edit,
                                                size: 15.0,
                                              ),
                                              options: FFButtonOptions(
                                                width: double.infinity,
                                                height: 50.0,
                                                padding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(24.0, 0.0,
                                                            24.0, 0.0),
                                                color: _model.uploadedFileUrl
                                                        .isEmpty
                                                    ? Color(0xFF3C3D3E)
                                                    : Color(0xFF027941),
                                                textStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          font: GoogleFonts
                                                              .interTight(),
                                                          color: Colors.white,
                                                          letterSpacing: 0.0,
                                                        ),
                                                elevation: 0.0,
                                                borderSide: BorderSide(
                                                  color:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryText,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16.0),
                                        // Descrição Resumida
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Descrição Resumida *',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            SizedBox(height: 8.0),
                                            TextFormField(
                                              controller: _model
                                                  .descricaoResumidaTextController,
                                              focusNode: _model
                                                  .descricaoResumidaFocusNode,
                                              autofocus: false,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Breve descrição do aviso',
                                                hintStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .inter(),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          letterSpacing: 0.0,
                                                        ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                filled: true,
                                                fillColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                              ),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    letterSpacing: 0.0,
                                                  ),
                                              maxLines: 2,
                                              cursorColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              validator: _model
                                                  .descricaoResumidaTextControllerValidator
                                                  .asValidator(context),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16.0),
                                        // Descrição Completa
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Descrição Completa',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            SizedBox(height: 8.0),
                                            TextFormField(
                                              controller:
                                                  _model.descricaoTextController,
                                              focusNode:
                                                  _model.descricaoFocusNode,
                                              autofocus: false,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Descrição detalhada do aviso',
                                                hintStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .inter(),
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          letterSpacing: 0.0,
                                                        ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    width: 1.0,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                filled: true,
                                                fillColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                              ),
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .bodyMedium
                                                  .override(
                                                    font: GoogleFonts.inter(),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    letterSpacing: 0.0,
                                                  ),
                                              maxLines: 5,
                                              cursorColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              validator: _model
                                                  .descricaoTextControllerValidator
                                                  .asValidator(context),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 32.0),
                                        // Botões
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            FFButtonWidget(
                                              onPressed: () {
                                                context.safePop();
                                              },
                                              text: 'Cancelar',
                                              options: FFButtonOptions(
                                                height: 50.0,
                                                padding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(24.0, 0.0,
                                                            24.0, 0.0),
                                                color: Color(0xFF3C3D3E),
                                                textStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          font: GoogleFonts
                                                              .interTight(),
                                                          color: Colors.white,
                                                          letterSpacing: 0.0,
                                                        ),
                                                elevation: 0.0,
                                                borderSide: BorderSide(
                                                  color:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondaryText,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            SizedBox(width: 16.0),
                                            FFButtonWidget(
                                              onPressed: () async {
                                                // Validar campos obrigatórios
                                                if (_model.nomeAvisoTextController
                                                            .text.isEmpty ||
                                                    _model.categoriaValue ==
                                                        null ||
                                                    _model.pickedDate == null ||
                                                    _model.pickedDateExpiracao == null ||
                                                    _model.descricaoResumidaTextController
                                                        .text.isEmpty) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Por favor, preencha todos os campos obrigatórios (*)',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .inter(),
                                                                  color: Colors
                                                                      .white,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                      ),
                                                      duration: Duration(
                                                          milliseconds: 3000),
                                                      backgroundColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .error,
                                                    ),
                                                  );
                                                  return;
                                                }

                                                try {
                                                  final isEditing = widget.avisoId != null;

                                                  // Preparar dados do aviso
                                                  final Map<String, dynamic> avisoData = {
                                                    'nome_aviso': _model
                                                        .nomeAvisoTextController
                                                        .text,
                                                    'categoria':
                                                        _model.categoriaValue,
                                                    'data_hora_aviso': supaSerialize<
                                                            DateTime>(
                                                        _model.pickedDate),
                                                    'expira_em': supaSerialize<
                                                            DateTime>(
                                                        _model.pickedDateExpiracao),
                                                    'imagem': _model.uploadedFileUrl.isEmpty
                                                        ? null
                                                        : _model.uploadedFileUrl,
                                                    'descricao_resumida': _model
                                                        .descricaoResumidaTextController
                                                        .text,
                                                    'descricao': _model
                                                        .descricaoTextController
                                                        .text
                                                        .isEmpty ? null : _model
                                                        .descricaoTextController
                                                        .text,
                                                  };

                                                  // Se for criação, adicionar criado_por
                                                  if (!isEditing) {
                                                    final membroAtual = await MembrosTable().querySingleRow(
                                                      queryFn: (q) => q.eqOrNull(
                                                        'id_auth',
                                                        currentUserUid,
                                                      ),
                                                    );
                                                    if (membroAtual != null && membroAtual.isNotEmpty) {
                                                      avisoData['criado_por'] = membroAtual.first.idMembro;
                                                    }
                                                  }

                                                  // Inserir ou atualizar o aviso no banco
                                                  if (isEditing) {
                                                    await AvisoTable().update(
                                                      data: avisoData,
                                                      matchingRows: (rows) => rows.eq('id', widget.avisoId!),
                                                    );
                                                  } else {
                                                    await AvisoTable().insert(avisoData);
                                                  }

                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        isEditing ? 'Aviso atualizado com sucesso!' : 'Aviso criado com sucesso!',
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyMedium
                                                            .override(
                                                              font: GoogleFonts
                                                                  .inter(),
                                                              color: Colors.white,
                                                              letterSpacing: 0.0,
                                                            ),
                                                      ),
                                                      duration: Duration(
                                                          milliseconds: 3000),
                                                      backgroundColor:
                                                          Color(0xFF027941),
                                                    ),
                                                  );

                                                  context.safePop();
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        widget.avisoId != null ? 'Erro ao atualizar aviso: $e' : 'Erro ao criar aviso: $e',
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyMedium
                                                            .override(
                                                              font: GoogleFonts
                                                                  .inter(),
                                                              color: Colors.white,
                                                              letterSpacing: 0.0,
                                                            ),
                                                      ),
                                                      duration: Duration(
                                                          milliseconds: 5000),
                                                      backgroundColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .error,
                                                    ),
                                                  );
                                                }
                                              },
                                              text: widget.avisoId != null ? 'Atualizar Aviso' : 'Salvar Aviso',
                                              icon: Icon(
                                                widget.avisoId != null ? Icons.update : Icons.check,
                                                size: 15.0,
                                              ),
                                              options: FFButtonOptions(
                                                height: 50.0,
                                                padding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(24.0, 0.0,
                                                            24.0, 0.0),
                                                color: Color(0xFF027941),
                                                textStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          font: GoogleFonts
                                                              .interTight(),
                                                          color: Colors.white,
                                                          letterSpacing: 0.0,
                                                        ),
                                                elevation: 2.0,
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
