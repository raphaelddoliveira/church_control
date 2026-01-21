import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/secretaria/menu_secretaria/menu_secretaria_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
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
        'cep': _model.textFieldCEPTextController.text.trim(),
        'rua': _model.textFieldRuaTextController.text.trim(),
        'numero': _model.textFieldNumeroTextController.text.trim(),
        'bairro': _model.textFieldBairroTextController.text.trim(),
        'id_cidade': _cidadeSelecionada,
      });

      // Parsear data de nascimento
      DateTime? dataNascimento;
      if (_model.textController3.text.isNotEmpty) {
        try {
          final parts = _model.textController3.text.split('/');
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
        'nome_membro': _model.textFieldNomeTextController.text.trim(),
        'email': _model.textFieldEmailTextController.text.trim().isNotEmpty
            ? _model.textFieldEmailTextController.text.trim()
            : null,
        'data_nascimento': dataNascimento?.toIso8601String(),
        'ativo': _ativo,
        'id_endereco': endereco.idEndereco,
        'id_nivel_acesso': 6,
      });

      // Criar telefone se preenchido
      if (_model.textFieldTelefoneTextController.text.trim().isNotEmpty) {
        await TelefoneTable().insert({
          'numero_telefone': _model.textFieldTelefoneTextController.text.trim(),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool required = false,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: Color(0xFF999999),
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (required)
              Text(' *', style: TextStyle(color: Colors.red, fontSize: 13.0)),
          ],
        ),
        SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 15.0),
          validator: required
              ? (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: Color(0xFF444444), fontSize: 15.0),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Color(0xFF666666), size: 20.0)
                : null,
            filled: true,
            fillColor: Color(0xFF0D0D0D),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Color(0xFF2A2A2A)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Color(0xFF2A2A2A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary, width: 2.0),
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
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF0D0D0D),
        drawer: Drawer(
          backgroundColor: Color(0xFF1A1A1A),
          child: MenuSecretariaWidget(),
        ),
        body: Row(
          children: [
            // Menu lateral (desktop)
            if (responsiveVisibility(context: context, phone: false, tablet: false, tabletLandscape: false))
              Container(
                width: 250.0,
                margin: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: wrapWithModel(
                  model: _model.menuSecretariaModel,
                  updateCallback: () => setState(() {}),
                  child: MenuSecretariaWidget(),
                ),
              ),
            // Conteúdo principal
            Expanded(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (!responsiveVisibility(context: context, phone: false, tablet: false, tabletLandscape: false))
                              IconButton(
                                onPressed: () => scaffoldKey.currentState?.openDrawer(),
                                icon: Icon(Icons.menu_rounded, color: Colors.white, size: 28.0),
                              ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Novo Membro',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 28.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Preencha os dados do novo membro',
                                  style: GoogleFonts.inter(
                                    color: Color(0xFF666666),
                                    fontSize: 14.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () => context.pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Color(0xFF999999),
                                side: BorderSide(color: Color(0xFF444444)),
                                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_back_rounded, size: 18.0),
                                  SizedBox(width: 8.0),
                                  Text('Voltar'),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.0),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _salvarMembro,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FlutterFlowTheme.of(context).primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
                                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 20.0,
                                      height: 20.0,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
                                    )
                                  : Row(
                                      children: [
                                        Icon(Icons.save_rounded, size: 18.0),
                                        SizedBox(width: 8.0),
                                        Text('Salvar'),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Formulário
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Dados Pessoais
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(24.0),
                              decoration: BoxDecoration(
                                color: Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(color: Color(0xFF2A2A2A)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: FlutterFlowTheme.of(context).primary,
                                          size: 24.0,
                                        ),
                                      ),
                                      SizedBox(width: 12.0),
                                      Text(
                                        'Dados Pessoais',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 24.0),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      if (constraints.maxWidth > 600) {
                                        return Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: _buildTextField(
                                                controller: _model.textFieldNomeTextController,
                                                focusNode: _model.textFieldNomeFocusNode,
                                                label: 'Nome Completo',
                                                hint: 'Digite o nome completo',
                                                prefixIcon: Icons.person_outline_rounded,
                                                required: true,
                                              ),
                                            ),
                                            SizedBox(width: 16.0),
                                            Expanded(
                                              child: _buildTextField(
                                                controller: _model.textFieldEmailTextController,
                                                focusNode: _model.textFieldEmailFocusNode,
                                                label: 'Email',
                                                hint: 'email@exemplo.com',
                                                keyboardType: TextInputType.emailAddress,
                                                prefixIcon: Icons.email_outlined,
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      return Column(
                                        children: [
                                          _buildTextField(
                                            controller: _model.textFieldNomeTextController,
                                            focusNode: _model.textFieldNomeFocusNode,
                                            label: 'Nome Completo',
                                            hint: 'Digite o nome completo',
                                            prefixIcon: Icons.person_outline_rounded,
                                            required: true,
                                          ),
                                          SizedBox(height: 16.0),
                                          _buildTextField(
                                            controller: _model.textFieldEmailTextController,
                                            focusNode: _model.textFieldEmailFocusNode,
                                            label: 'Email',
                                            hint: 'email@exemplo.com',
                                            keyboardType: TextInputType.emailAddress,
                                            prefixIcon: Icons.email_outlined,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  SizedBox(height: 16.0),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      if (constraints.maxWidth > 600) {
                                        return Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: _buildTextField(
                                                controller: _model.textController3,
                                                focusNode: _model.textFieldFocusNode,
                                                label: 'Data de Nascimento',
                                                hint: 'DD/MM/AAAA',
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [_dataMask],
                                                prefixIcon: Icons.calendar_today_rounded,
                                              ),
                                            ),
                                            SizedBox(width: 16.0),
                                            Expanded(
                                              child: _buildTextField(
                                                controller: _model.textFieldTelefoneTextController,
                                                focusNode: _model.textFieldTelefoneFocusNode,
                                                label: 'Telefone',
                                                hint: '(00) 00000-0000',
                                                keyboardType: TextInputType.phone,
                                                prefixIcon: Icons.phone_rounded,
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      return Column(
                                        children: [
                                          _buildTextField(
                                            controller: _model.textController3,
                                            focusNode: _model.textFieldFocusNode,
                                            label: 'Data de Nascimento',
                                            hint: 'DD/MM/AAAA',
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [_dataMask],
                                            prefixIcon: Icons.calendar_today_rounded,
                                          ),
                                          SizedBox(height: 16.0),
                                          _buildTextField(
                                            controller: _model.textFieldTelefoneTextController,
                                            focusNode: _model.textFieldTelefoneFocusNode,
                                            label: 'Telefone',
                                            hint: '(00) 00000-0000',
                                            keyboardType: TextInputType.phone,
                                            prefixIcon: Icons.phone_rounded,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  SizedBox(height: 16.0),
                                  // Status ativo
                                  Row(
                                    children: [
                                      Text(
                                        'Status:',
                                        style: GoogleFonts.inter(
                                          color: Color(0xFF999999),
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 16.0),
                                      InkWell(
                                        onTap: () => setState(() => _ativo = !_ativo),
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                          decoration: BoxDecoration(
                                            color: _ativo
                                                ? Color(0xFF027941).withOpacity(0.2)
                                                : Color(0xFFFF4444).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8.0),
                                            border: Border.all(
                                              color: _ativo ? Color(0xFF027941) : Color(0xFFFF4444),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _ativo ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                                color: _ativo ? Color(0xFF027941) : Color(0xFFFF4444),
                                                size: 18.0,
                                              ),
                                              SizedBox(width: 8.0),
                                              Text(
                                                _ativo ? 'Ativo' : 'Inativo',
                                                style: GoogleFonts.inter(
                                                  color: _ativo ? Color(0xFF027941) : Color(0xFFFF4444),
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.0),
                            // Endereço
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(24.0),
                              decoration: BoxDecoration(
                                color: Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(color: Color(0xFF2A2A2A)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE67700).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: Icon(
                                          Icons.location_on_rounded,
                                          color: Color(0xFFE67700),
                                          size: 24.0,
                                        ),
                                      ),
                                      SizedBox(width: 12.0),
                                      Text(
                                        'Endereço',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 24.0),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      if (constraints.maxWidth > 600) {
                                        return Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 150.0,
                                              child: _buildTextField(
                                                controller: _model.textFieldCEPTextController,
                                                focusNode: _model.textFieldCEPFocusNode,
                                                label: 'CEP',
                                                hint: '00000-000',
                                                keyboardType: TextInputType.number,
                                              ),
                                            ),
                                            SizedBox(width: 16.0),
                                            Expanded(
                                              child: _buildTextField(
                                                controller: _model.textFieldRuaTextController,
                                                focusNode: _model.textFieldRuaFocusNode,
                                                label: 'Rua',
                                                hint: 'Nome da rua',
                                              ),
                                            ),
                                            SizedBox(width: 16.0),
                                            SizedBox(
                                              width: 100.0,
                                              child: _buildTextField(
                                                controller: _model.textFieldNumeroTextController,
                                                focusNode: _model.textFieldNumeroFocusNode,
                                                label: 'Número',
                                                hint: 'Nº',
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      return Column(
                                        children: [
                                          _buildTextField(
                                            controller: _model.textFieldCEPTextController,
                                            focusNode: _model.textFieldCEPFocusNode,
                                            label: 'CEP',
                                            hint: '00000-000',
                                            keyboardType: TextInputType.number,
                                          ),
                                          SizedBox(height: 16.0),
                                          _buildTextField(
                                            controller: _model.textFieldRuaTextController,
                                            focusNode: _model.textFieldRuaFocusNode,
                                            label: 'Rua',
                                            hint: 'Nome da rua',
                                          ),
                                          SizedBox(height: 16.0),
                                          _buildTextField(
                                            controller: _model.textFieldNumeroTextController,
                                            focusNode: _model.textFieldNumeroFocusNode,
                                            label: 'Número',
                                            hint: 'Nº',
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  SizedBox(height: 16.0),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      if (constraints.maxWidth > 600) {
                                        return Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: _buildTextField(
                                                controller: _model.textFieldBairroTextController,
                                                focusNode: _model.textFieldBairroFocusNode,
                                                label: 'Bairro',
                                                hint: 'Nome do bairro',
                                              ),
                                            ),
                                            SizedBox(width: 16.0),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Cidade',
                                                    style: GoogleFonts.inter(
                                                      color: Color(0xFF999999),
                                                      fontSize: 13.0,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8.0),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF0D0D0D),
                                                      borderRadius: BorderRadius.circular(12.0),
                                                      border: Border.all(color: Color(0xFF2A2A2A)),
                                                    ),
                                                    child: DropdownButtonFormField<int>(
                                                      value: _cidadeSelecionada,
                                                      items: _cidades.map((c) => DropdownMenuItem(
                                                        value: c.idCidade,
                                                        child: Text(c.nomeCidade ?? '', style: TextStyle(color: Colors.white)),
                                                      )).toList(),
                                                      onChanged: (value) => setState(() => _cidadeSelecionada = value),
                                                      dropdownColor: Color(0xFF1A1A1A),
                                                      decoration: InputDecoration(
                                                        border: InputBorder.none,
                                                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                                      ),
                                                      style: GoogleFonts.inter(color: Colors.white, fontSize: 15.0),
                                                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF666666)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      return Column(
                                        children: [
                                          _buildTextField(
                                            controller: _model.textFieldBairroTextController,
                                            focusNode: _model.textFieldBairroFocusNode,
                                            label: 'Bairro',
                                            hint: 'Nome do bairro',
                                          ),
                                          SizedBox(height: 16.0),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Cidade',
                                                style: GoogleFonts.inter(
                                                  color: Color(0xFF999999),
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 8.0),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF0D0D0D),
                                                  borderRadius: BorderRadius.circular(12.0),
                                                  border: Border.all(color: Color(0xFF2A2A2A)),
                                                ),
                                                child: DropdownButtonFormField<int>(
                                                  value: _cidadeSelecionada,
                                                  items: _cidades.map((c) => DropdownMenuItem(
                                                    value: c.idCidade,
                                                    child: Text(c.nomeCidade ?? '', style: TextStyle(color: Colors.white)),
                                                  )).toList(),
                                                  onChanged: (value) => setState(() => _cidadeSelecionada = value),
                                                  dropdownColor: Color(0xFF1A1A1A),
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                                  ),
                                                  style: GoogleFonts.inter(color: Colors.white, fontSize: 15.0),
                                                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF666666)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 40.0),
                          ],
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
