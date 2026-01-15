import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/secretaria/menu_secretaria/menu_secretaria_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_nova_celula_secretaria_model.dart';
export 'page_nova_celula_secretaria_model.dart';

class PageNovaCelulaSecretariaWidget extends StatefulWidget {
  const PageNovaCelulaSecretariaWidget({
    super.key,
    this.celulaId,
  });

  final int? celulaId;

  static String routeName = 'PageNovaCelulaSecretaria';
  static String routePath = '/pageNovaCelulaSecretaria';

  @override
  State<PageNovaCelulaSecretariaWidget> createState() =>
      _PageNovaCelulaSecretariaWidgetState();
}

class _PageNovaCelulaSecretariaWidgetState
    extends State<PageNovaCelulaSecretariaWidget> {
  late PageNovaCelulaSecretariaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<MembrosRow> _membros = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageNovaCelulaSecretariaModel());

    _model.nomeCelulaTextController ??= TextEditingController();
    _model.nomeCelulaFocusNode ??= FocusNode();

    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      // Carregar lista de membros para o dropdown de líder
      final membros = await MembrosTable().queryRows(
        queryFn: (q) => q.eq('ativo', true).order('nome_membro'),
      );

      setState(() {
        _membros = membros;
        _isLoading = false;
      });

      // Se estiver editando, carregar dados da célula
      if (widget.celulaId != null) {
        final celulas = await CelulaTable().queryRows(
          queryFn: (q) => q.eq('id', widget.celulaId!),
        );

        if (celulas.isNotEmpty) {
          final celula = celulas.first;
          setState(() {
            _model.nomeCelulaTextController?.text = celula.nomeCelula ?? '';
            _model.liderDropDownValue = celula.idLider;
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _salvarCelula() async {
    if (!_model.formKey.currentState!.validate()) {
      return;
    }

    try {
      if (widget.celulaId != null) {
        // Atualizar célula existente
        await CelulaTable().update(
          data: {
            'nome_celula': _model.nomeCelulaTextController?.text,
            'id_lider': _model.liderDropDownValue,
          },
          matchingRows: (rows) => rows.eq('id', widget.celulaId!),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Célula atualizada com sucesso!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      } else {
        // Criar nova célula
        await CelulaTable().insert({
          'nome_celula': _model.nomeCelulaTextController?.text,
          'id_lider': _model.liderDropDownValue,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Célula criada com sucesso!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }

      context.safePop();
    } catch (e) {
      print('Erro ao salvar célula: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar célula: $e'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
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
                      model: _model.menuSecretariaModel,
                      updateCallback: () => safeSetState(() {}),
                      child: MenuSecretariaWidget(),
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
                    child: SingleChildScrollView(
                      child: Form(
                        key: _model.formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
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
                                            widget.celulaId != null
                                                ? 'Editar Celula'
                                                : 'Nova Celula',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 32.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            widget.celulaId != null
                                                ? 'Edite as informacoes da celula'
                                                : 'Preencha as informacoes para criar uma nova celula',
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

                            if (_isLoading)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      FlutterFlowTheme.of(context).primary,
                                    ),
                                  ),
                                ),
                              )
                            else
                              // Formulario
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Campo Nome da Celula
                                    Text(
                                      'Nome da Celula *',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    TextFormField(
                                      controller: _model.nomeCelulaTextController,
                                      focusNode: _model.nomeCelulaFocusNode,
                                      validator: (val) => _model.nomeCelulaTextControllerValidator?.call(context, val),
                                      decoration: InputDecoration(
                                        hintText: 'Digite o nome da celula',
                                        hintStyle: GoogleFonts.inter(
                                          color: Color(0xFF666666),
                                          fontSize: 16.0,
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
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context).error,
                                            width: 1.0,
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

                                    SizedBox(height: 24.0),

                                    // Campo Lider
                                    Text(
                                      'Lider da Celula',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    FlutterFlowDropDown<String>(
                                      controller: _model.liderDropDownValueController ??=
                                          FormFieldController<String>(
                                        _model.liderDropDownValue,
                                      ),
                                      options: _membros.map((m) => m.idMembro).toList(),
                                      optionLabels: _membros.map((m) => m.nomeMembro).toList(),
                                      onChanged: (val) => setState(() {
                                        _model.liderDropDownValue = val;
                                      }),
                                      width: double.infinity,
                                      height: 56.0,
                                      searchHintTextStyle: GoogleFonts.inter(
                                        color: Color(0xFF666666),
                                        fontSize: 14.0,
                                      ),
                                      searchTextStyle: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                      ),
                                      textStyle: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                      ),
                                      hintText: 'Selecione o lider',
                                      searchHintText: 'Buscar membro...',
                                      icon: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Color(0xFF999999),
                                        size: 24.0,
                                      ),
                                      fillColor: Color(0xFF2A2A2A),
                                      elevation: 2.0,
                                      borderColor: Color(0xFF3A3A3A),
                                      borderWidth: 1.0,
                                      borderRadius: 12.0,
                                      margin: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                      hidesUnderline: true,
                                      isOverButton: false,
                                      isSearchable: true,
                                      isMultiSelect: false,
                                    ),

                                    SizedBox(height: 48.0),

                                    // Botoes
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        FFButtonWidget(
                                          onPressed: () {
                                            context.safePop();
                                          },
                                          text: 'Cancelar',
                                          options: FFButtonOptions(
                                            height: 48.0,
                                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                                            color: Colors.transparent,
                                            textStyle: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            elevation: 0.0,
                                            borderSide: BorderSide(
                                              color: Color(0xFF666666),
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                        ),
                                        SizedBox(width: 16.0),
                                        FFButtonWidget(
                                          onPressed: _salvarCelula,
                                          text: widget.celulaId != null
                                              ? 'Salvar Alteracoes'
                                              : 'Criar Celula',
                                          icon: Icon(
                                            widget.celulaId != null
                                                ? Icons.save_rounded
                                                : Icons.add_rounded,
                                            size: 20.0,
                                          ),
                                          options: FFButtonOptions(
                                            height: 48.0,
                                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                                            color: FlutterFlowTheme.of(context).primary,
                                            textStyle: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            elevation: 0.0,
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 32.0),
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
            ],
          ),
        ),
      ),
    );
  }
}
