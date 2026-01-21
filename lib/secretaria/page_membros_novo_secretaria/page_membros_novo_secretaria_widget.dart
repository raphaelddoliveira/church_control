import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/secretaria/menu_secretaria/menu_secretaria_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'page_membros_novo_secretaria_model.dart';
export 'page_membros_novo_secretaria_model.dart';

class PageMembrosNovoSecretariaWidget extends StatefulWidget {
  const PageMembrosNovoSecretariaWidget({super.key});

  static String routeName = 'PageMembros_Novo_Secretaria';
  static String routePath = '/pageMembrosNovoSecretaria';

  @override
  State<PageMembrosNovoSecretariaWidget> createState() =>
      _PageMembrosNovoSecretariaWidgetState();
}

class _PageMembrosNovoSecretariaWidgetState
    extends State<PageMembrosNovoSecretariaWidget> {
  late PageMembrosNovoSecretariaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _ativo = true;
  int? _cidadeSelecionada = 1;
  List<CidadeRow> _cidades = [];
  final _dataMask = MaskTextInputFormatter(mask: '##/##/####');

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageMembrosNovoSecretariaModel());

    _model.textFieldNomeTextController ??= TextEditingController();
    _model.textFieldNomeFocusNode ??= FocusNode();
    _model.textFieldEmailTextController ??= TextEditingController();
    _model.textFieldEmailFocusNode ??= FocusNode();
    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    _model.textFieldTelefoneTextController ??= TextEditingController();
    _model.textFieldTelefoneFocusNode ??= FocusNode();
    _model.textFieldCEPTextController ??= TextEditingController();
    _model.textFieldCEPFocusNode ??= FocusNode();
    _model.textFieldRuaTextController ??= TextEditingController();
    _model.textFieldRuaFocusNode ??= FocusNode();
    _model.textFieldNumeroTextController ??= TextEditingController();
    _model.textFieldNumeroFocusNode ??= FocusNode();
    _model.textFieldBairroTextController ??= TextEditingController();
    _model.textFieldBairroFocusNode ??= FocusNode();

    _carregarCidades();
  }

  Future<void> _carregarCidades() async {
    final cidades = await CidadeTable().queryRows(queryFn: (q) => q);
    setState(() => _cidades = cidades);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _salvarMembro() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Criar endereço
      final endereco = await EnderecoTable().insert({
        'cep': _model.textFieldCEPTextController!.text.trim(),
        'rua': _model.textFieldRuaTextController!.text.trim(),
        'numero': _model.textFieldNumeroTextController!.text.trim(),
        'bairro': _model.textFieldBairroTextController!.text.trim(),
        'id_cidade': _cidadeSelecionada,
      });

      // Parsear data de nascimento
      DateTime? dataNascimento;
      if (_model.textController3!.text.isNotEmpty) {
        try {
          final parts = _model.textController3!.text.split('/');
          if (parts.length == 3) {
            dataNascimento = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        } catch (_) {}
      }

      // Criar membro
      final membro = await MembrosTable().insert({
        'nome_membro': _model.textFieldNomeTextController!.text.trim(),
        'email': _model.textFieldEmailTextController!.text.trim().isNotEmpty
            ? _model.textFieldEmailTextController!.text.trim()
            : null,
        'data_nascimento': dataNascimento?.toIso8601String(),
        'ativo': _ativo,
        'id_endereco': endereco.idEndereco,
        'id_nivel_acesso': 6,
      });

      // Criar telefone se preenchido
      if (_model.textFieldTelefoneTextController!.text.trim().isNotEmpty) {
        await TelefoneTable().insert({
          'numero_telefone': _model.textFieldTelefoneTextController!.text.trim(),
          'id_membro': membro.idMembro,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Membro cadastrado com sucesso!'),
          backgroundColor: FlutterFlowTheme.of(context).success,
        ),
      );

      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar membro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController? controller,
    required FocusNode? focusNode,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$label:',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.w500,
                    ),
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    letterSpacing: 0.0,
                  ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: isRequired
              ? (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null
              : null,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.interTight(
                  fontWeight: FontWeight.normal,
                ),
                color: FlutterFlowTheme.of(context).primaryBackground,
                letterSpacing: 0.0,
              ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFF57636C),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
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
              borderSide: BorderSide(color: Colors.red),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          ),
        ),
      ],
    );
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
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Header
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 8.0),
                                  child: Container(
                                    width: MediaQuery.sizeOf(context).width * 1.0,
                                    height: 90.0,
                                    decoration: BoxDecoration(
                                      color: Color(0x00FFFFFF),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional.fromSTEB(18.0, 0.0, 0.0, 0.0),
                                              child: Text(
                                                'Novo Membro',
                                                style: FlutterFlowTheme.of(context).headlineLarge.override(
                                                      font: GoogleFonts.interTight(
                                                        fontWeight: FlutterFlowTheme.of(context).headlineLarge.fontWeight,
                                                      ),
                                                      color: FlutterFlowTheme.of(context).primaryBackground,
                                                      letterSpacing: 0.0,
                                                    ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                                              child: Icon(
                                                Icons.person_add_rounded,
                                                color: FlutterFlowTheme.of(context).primaryBackground,
                                                size: 40.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            FFButtonWidget(
                                              onPressed: _isLoading ? null : _salvarMembro,
                                              text: _isLoading ? 'Salvando...' : 'Salvar',
                                              options: FFButtonOptions(
                                                height: 40.0,
                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                color: FlutterFlowTheme.of(context).primary,
                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                      font: GoogleFonts.interTight(
                                                        fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                      ),
                                                      color: Colors.white,
                                                      letterSpacing: 0.0,
                                                    ),
                                                elevation: 0.0,
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            SizedBox(width: 12.0),
                                            FFButtonWidget(
                                              onPressed: () => context.pop(),
                                              text: 'Voltar',
                                              icon: Icon(
                                                Icons.arrow_back_rounded,
                                                size: 20.0,
                                              ),
                                              options: FFButtonOptions(
                                                height: 40.0,
                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                color: FlutterFlowTheme.of(context).accent2,
                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                      font: GoogleFonts.interTight(
                                                        fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                      ),
                                                      color: Colors.white,
                                                      letterSpacing: 0.0,
                                                    ),
                                                elevation: 0.0,
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            SizedBox(width: 18.0),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Formulário
                                Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Container(
                                    width: double.infinity,
                                    constraints: BoxConstraints(maxWidth: 1200.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Coluna Esquerda - Dados Pessoais
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              _buildInfoField(
                                                label: 'Nome Completo',
                                                controller: _model.textFieldNomeTextController,
                                                focusNode: _model.textFieldNomeFocusNode,
                                                isRequired: true,
                                              ),
                                              SizedBox(height: 20.0),
                                              _buildInfoField(
                                                label: 'Email',
                                                controller: _model.textFieldEmailTextController,
                                                focusNode: _model.textFieldEmailFocusNode,
                                                keyboardType: TextInputType.emailAddress,
                                              ),
                                              SizedBox(height: 20.0),
                                              _buildInfoField(
                                                label: 'Data de Nascimento',
                                                controller: _model.textController3,
                                                focusNode: _model.textFieldFocusNode,
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [_dataMask],
                                              ),
                                              SizedBox(height: 20.0),
                                              _buildInfoField(
                                                label: 'Telefone',
                                                controller: _model.textFieldTelefoneTextController,
                                                focusNode: _model.textFieldTelefoneFocusNode,
                                                keyboardType: TextInputType.phone,
                                              ),
                                              SizedBox(height: 20.0),
                                              // Status Ativo
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Está Ativo?',
                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                          font: GoogleFonts.interTight(
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                          color: FlutterFlowTheme.of(context).primaryBackground,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                  SizedBox(height: 8.0),
                                                  Switch(
                                                    value: _ativo,
                                                    onChanged: (value) => setState(() => _ativo = value),
                                                    activeColor: FlutterFlowTheme.of(context).primary,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 48.0),
                                        // Coluna Direita - Endereço
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              _buildInfoField(
                                                label: 'CEP',
                                                controller: _model.textFieldCEPTextController,
                                                focusNode: _model.textFieldCEPFocusNode,
                                                keyboardType: TextInputType.number,
                                              ),
                                              SizedBox(height: 20.0),
                                              _buildInfoField(
                                                label: 'Rua',
                                                controller: _model.textFieldRuaTextController,
                                                focusNode: _model.textFieldRuaFocusNode,
                                              ),
                                              SizedBox(height: 20.0),
                                              _buildInfoField(
                                                label: 'Número',
                                                controller: _model.textFieldNumeroTextController,
                                                focusNode: _model.textFieldNumeroFocusNode,
                                              ),
                                              SizedBox(height: 20.0),
                                              _buildInfoField(
                                                label: 'Bairro',
                                                controller: _model.textFieldBairroTextController,
                                                focusNode: _model.textFieldBairroFocusNode,
                                              ),
                                              SizedBox(height: 20.0),
                                              // Cidade Dropdown
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Cidade:',
                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                          font: GoogleFonts.interTight(
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                          color: FlutterFlowTheme.of(context).primaryBackground,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                  SizedBox(height: 8.0),
                                                  Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF57636C),
                                                      borderRadius: BorderRadius.circular(12.0),
                                                    ),
                                                    child: DropdownButtonFormField<int>(
                                                      value: _cidadeSelecionada,
                                                      items: _cidades.map((c) => DropdownMenuItem(
                                                        value: c.idCidade,
                                                        child: Text(
                                                          c.nomeCidade ?? '',
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                      )).toList(),
                                                      onChanged: (value) => setState(() => _cidadeSelecionada = value),
                                                      dropdownColor: Color(0xFF57636C),
                                                      decoration: InputDecoration(
                                                        border: InputBorder.none,
                                                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                                      ),
                                                      style: TextStyle(color: Colors.white, fontSize: 14.0),
                                                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
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
          ],
        ),
      ),
    );
  }
}
