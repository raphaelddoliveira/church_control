import '/admin/menu_admin/menu_admin_widget.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/random_data_util.dart' as random_data;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_membros_admin_detalhes_model.dart';
export 'page_membros_admin_detalhes_model.dart';

class PageMembrosAdminDetalhesWidget extends StatefulWidget {
  const PageMembrosAdminDetalhesWidget({
    super.key,
    required this.idmembro,
    required this.emailmembro,
    required this.nomemembro,
  });

  final String? idmembro;
  final String? emailmembro;
  final String? nomemembro;

  static String routeName = 'PageMembros_Admin_detalhes';
  static String routePath = '/pageMembrosAdminDetalhes';

  @override
  State<PageMembrosAdminDetalhesWidget> createState() =>
      _PageMembrosAdminDetalhesWidgetState();
}

class _PageMembrosAdminDetalhesWidgetState
    extends State<PageMembrosAdminDetalhesWidget> {
  late PageMembrosAdminDetalhesModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<NiveisAcessoRow> _niveisAcesso = [];
  MembrosRow? _membro;
  int? _selectedNivelAcesso;
  String _senhaGerada = '';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageMembrosAdminDetalhesModel());
    _carregarDados();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    try {
      final membroRows = await MembrosTable().querySingleRow(
        queryFn: (q) => q.eqOrNull('id_membro', widget.idmembro),
      );

      final niveis = await NiveisAcessoTable().queryRows(
        queryFn: (q) => q.order('id_nivel'),
      );

      setState(() {
        _membro = membroRows.isNotEmpty ? membroRows.first : null;
        _niveisAcesso = niveis;
        _selectedNivelAcesso = _membro?.idNivelAcesso;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _gerarSenha() {
    setState(() {
      _senhaGerada = random_data.randomString(6, 8, true, true, true);
    });
  }

  Future<void> _salvar() async {
    if (_selectedNivelAcesso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecione um nivel de acesso'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final membroJaTemAuth = _membro?.idAuth != null && _membro!.idAuth!.isNotEmpty;

      if (membroJaTemAuth) {
        // Membro ja tem auth - apenas atualizar nivel de acesso e pode_acessar_area_membro
        await MembrosTable().update(
          data: {
            'id_nivel_acesso': _selectedNivelAcesso,
            'pode_acessar_area_membro': true,
          },
          matchingRows: (rows) => rows.eqOrNull(
            'id_membro',
            widget.idmembro,
          ),
        );

        setState(() => _isSaving = false);

        await showDialog(
          context: context,
          builder: (alertDialogContext) {
            return AlertDialog(
              backgroundColor: Color(0xFF2A2A2A),
              title: Text('Sucesso!', style: TextStyle(color: Colors.white)),
              content: Text(
                'Nivel de acesso atualizado com sucesso.',
                style: TextStyle(color: Color(0xFF999999)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(alertDialogContext),
                  child: Text('Ok', style: TextStyle(color: FlutterFlowTheme.of(context).primary)),
                ),
              ],
            );
          },
        );
      } else {
        // Membro nao tem auth - criar auth com senha gerada
        if (_senhaGerada.isEmpty) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gere uma senha antes de salvar'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Criar usuario via API
        final apiResult = await CriarUsuarioCall.call(
          email: widget.emailmembro,
          senha: _senhaGerada,
        );

        if (apiResult.succeeded) {
          final userId = getJsonField(
            apiResult.jsonBody ?? '',
            r'''$.user.id''',
          ).toString();

          // Atualizar membro com id_auth, nivel de acesso e pode_acessar_area_membro
          await MembrosTable().update(
            data: {
              'id_auth': userId,
              'id_nivel_acesso': _selectedNivelAcesso,
              'pode_acessar_area_membro': true,
            },
            matchingRows: (rows) => rows.eqOrNull(
              'id_membro',
              widget.idmembro,
            ),
          );

          // Enviar email com credenciais via N8N
          await EnvioDadosEscalaCall.call(
            infomembro: 'SIM',
            emailenvio: widget.emailmembro,
            password: _senhaGerada,
            nivelacesso: _selectedNivelAcesso,
            nome: widget.nomemembro,
          );

          setState(() => _isSaving = false);

          await showDialog(
            context: context,
            builder: (alertDialogContext) {
              return AlertDialog(
                backgroundColor: Color(0xFF2A2A2A),
                title: Text('Sucesso!', style: TextStyle(color: Colors.white)),
                content: Text(
                  'Acesso criado e notificacao enviada para o membro!',
                  style: TextStyle(color: Color(0xFF999999)),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(alertDialogContext),
                    child: Text('Ok', style: TextStyle(color: FlutterFlowTheme.of(context).primary)),
                  ),
                ],
              );
            },
          );
        } else {
          // Usuario ja existe no auth - apenas atualizar nivel de acesso
          await MembrosTable().update(
            data: {
              'id_nivel_acesso': _selectedNivelAcesso,
              'pode_acessar_area_membro': true,
            },
            matchingRows: (rows) => rows.eqOrNull(
              'id_membro',
              widget.idmembro,
            ),
          );

          setState(() => _isSaving = false);

          await showDialog(
            context: context,
            builder: (alertDialogContext) {
              return AlertDialog(
                backgroundColor: Color(0xFF2A2A2A),
                title: Text('Sucesso!', style: TextStyle(color: Colors.white)),
                content: Text(
                  'Nivel de acesso atualizado com sucesso.',
                  style: TextStyle(color: Color(0xFF999999)),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(alertDialogContext),
                    child: Text('Ok', style: TextStyle(color: FlutterFlowTheme.of(context).primary)),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar alteracoes'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final membroJaTemAuth = _membro?.idAuth != null && (_membro?.idAuth?.isNotEmpty ?? false);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF14181B),
        body: Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          decoration: BoxDecoration(color: Color(0xFF14181B)),
          child: Row(
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
                    height: MediaQuery.sizeOf(context).height,
                    decoration: BoxDecoration(
                      color: Color(0xFF3C3D3E),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: wrapWithModel(
                      model: _model.menuAdminModel,
                      updateCallback: () => setState(() {}),
                      child: MenuAdminWidget(),
                    ),
                  ),
                ),

              // Conteudo principal
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    height: MediaQuery.sizeOf(context).height,
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
                        : SingleChildScrollView(
                            padding: EdgeInsets.all(32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header com botao voltar
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () => Navigator.of(context).pop(),
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Container(
                                        padding: EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF2A2A2A),
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: Icon(
                                          Icons.arrow_back_rounded,
                                          color: Colors.white,
                                          size: 22.0,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Definir Nivel de Acesso',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 28.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4.0),
                                          Text(
                                            'Configure as permissoes do membro',
                                            style: GoogleFonts.inter(
                                              color: Color(0xFF999999),
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Badge de status auth
                                    if (!_isLoading)
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                                        decoration: BoxDecoration(
                                          color: membroJaTemAuth
                                              ? Color(0xFF027941).withOpacity(0.15)
                                              : Color(0xFFFF9800).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              membroJaTemAuth ? Icons.verified_rounded : Icons.warning_rounded,
                                              color: membroJaTemAuth ? Color(0xFF027941) : Color(0xFFFF9800),
                                              size: 18.0,
                                            ),
                                            SizedBox(width: 8.0),
                                            Text(
                                              membroJaTemAuth ? 'Acesso Ativo' : 'Sem Acesso',
                                              style: GoogleFonts.inter(
                                                color: membroJaTemAuth ? Color(0xFF027941) : Color(0xFFFF9800),
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),

                                SizedBox(height: 32.0),

                                // Card de informacoes do membro
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(24.0),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF2A2A2A),
                                    borderRadius: BorderRadius.circular(16.0),
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
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            child: Icon(
                                              Icons.person_rounded,
                                              color: FlutterFlowTheme.of(context).primary,
                                              size: 22.0,
                                            ),
                                          ),
                                          SizedBox(width: 14.0),
                                          Text(
                                            'Informacoes do Membro',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20.0),
                                      // Nome
                                      _buildInfoField(
                                        label: 'Nome Completo',
                                        value: widget.nomemembro ?? '',
                                        icon: Icons.badge_rounded,
                                      ),
                                      SizedBox(height: 16.0),
                                      // Email
                                      _buildInfoField(
                                        label: 'Email',
                                        value: widget.emailmembro ?? '',
                                        icon: Icons.email_rounded,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 24.0),

                                // Card de configuracao de acesso
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(24.0),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF2A2A2A),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(10.0),
                                            decoration: BoxDecoration(
                                              color: Color(0xFF4B39EF).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            child: Icon(
                                              Icons.security_rounded,
                                              color: Color(0xFF4B39EF),
                                              size: 22.0,
                                            ),
                                          ),
                                          SizedBox(width: 14.0),
                                          Text(
                                            'Configuracao de Acesso',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20.0),

                                      // Nivel de Acesso
                                      Text(
                                        'Nivel de Acesso',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF1E1E1E),
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: DropdownButtonFormField<int>(
                                          value: _selectedNivelAcesso,
                                          items: _niveisAcesso.map((nivel) {
                                            return DropdownMenuItem<int>(
                                              value: nivel.idNivel,
                                              child: Text(
                                                nivel.nomeNivel,
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (val) => setState(() => _selectedNivelAcesso = val),
                                          dropdownColor: Color(0xFF1E1E1E),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                            hintText: 'Selecione um nivel...',
                                            hintStyle: GoogleFonts.inter(
                                              color: Color(0xFF666666),
                                              fontSize: 14.0,
                                            ),
                                          ),
                                          icon: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: Color(0xFF999999),
                                            size: 24.0,
                                          ),
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),

                                      // Senha - so mostra se membro NAO tem auth
                                      if (!membroJaTemAuth) ...[
                                        SizedBox(height: 20.0),
                                        Text(
                                          'Senha de Acesso',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          'Gere uma senha que sera enviada ao membro por email',
                                          style: GoogleFonts.inter(
                                            color: Color(0xFF666666),
                                            fontSize: 12.0,
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF1E1E1E),
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.lock_rounded,
                                                      color: Color(0xFF666666),
                                                      size: 18.0,
                                                    ),
                                                    SizedBox(width: 10.0),
                                                    Expanded(
                                                      child: Text(
                                                        _senhaGerada.isEmpty ? 'Clique em gerar...' : _senhaGerada,
                                                        style: GoogleFonts.inter(
                                                          color: _senhaGerada.isEmpty ? Color(0xFF666666) : Colors.white,
                                                          fontSize: 14.0,
                                                          fontWeight: _senhaGerada.isEmpty ? FontWeight.normal : FontWeight.w600,
                                                          letterSpacing: _senhaGerada.isEmpty ? 0.0 : 2.0,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12.0),
                                            InkWell(
                                              onTap: _gerarSenha,
                                              borderRadius: BorderRadius.circular(10.0),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF4B39EF).withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.refresh_rounded,
                                                      color: Color(0xFF4B39EF),
                                                      size: 18.0,
                                                    ),
                                                    SizedBox(width: 8.0),
                                                    Text(
                                                      'Gerar',
                                                      style: GoogleFonts.inter(
                                                        color: Color(0xFF4B39EF),
                                                        fontSize: 14.0,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],

                                      // Info se ja tem auth
                                      if (membroJaTemAuth) ...[
                                        SizedBox(height: 20.0),
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF027941).withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(10.0),
                                            border: Border.all(
                                              color: Color(0xFF027941).withOpacity(0.2),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline_rounded,
                                                color: Color(0xFF027941),
                                                size: 20.0,
                                              ),
                                              SizedBox(width: 12.0),
                                              Expanded(
                                                child: Text(
                                                  'Este membro ja possui acesso ativo. Apenas o nivel de acesso sera atualizado.',
                                                  style: GoogleFonts.inter(
                                                    color: Color(0xFF027941),
                                                    fontSize: 13.0,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                SizedBox(height: 32.0),

                                // Botoes
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: _isSaving ? null : _salvar,
                                        borderRadius: BorderRadius.circular(12.0),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 16.0),
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context).primary,
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                          child: Center(
                                            child: _isSaving
                                                ? SizedBox(
                                                    width: 22.0,
                                                    height: 22.0,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                    ),
                                                  )
                                                : Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.save_rounded,
                                                        color: Colors.white,
                                                        size: 20.0,
                                                      ),
                                                      SizedBox(width: 8.0),
                                                      Text(
                                                        'Salvar',
                                                        style: GoogleFonts.inter(
                                                          color: Colors.white,
                                                          fontSize: 15.0,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16.0),
                                    InkWell(
                                      onTap: () => Navigator.of(context).pop(),
                                      borderRadius: BorderRadius.circular(12.0),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF2A2A2A),
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                        child: Text(
                                          'Voltar',
                                          style: GoogleFonts.inter(
                                            color: Color(0xFF999999),
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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

  Widget _buildInfoField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Color(0xFF999999),
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.0),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            children: [
              Icon(icon, color: Color(0xFF666666), size: 18.0),
              SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  value.isEmpty ? 'Nao informado' : value,
                  style: GoogleFonts.inter(
                    color: value.isEmpty ? Color(0xFF666666) : Color(0xFFCCCCCC),
                    fontSize: 14.0,
                  ),
                ),
              ),
              Icon(Icons.lock_rounded, color: Color(0xFF555555), size: 16.0),
            ],
          ),
        ),
      ],
    );
  }
}
