import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/secretaria/menu_secretaria/menu_secretaria_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_membros_detalhes_secretaria_model.dart';
export 'page_membros_detalhes_secretaria_model.dart';

class PageMembrosDetalhesSecretariaWidget extends StatefulWidget {
  const PageMembrosDetalhesSecretariaWidget({
    super.key,
    required this.idmembro,
    required this.idendereco,
  });

  final String? idmembro;
  final int? idendereco;

  static String routeName = 'PageMembros_Detalhes_Secretaria';
  static String routePath = '/pageMembrosDetalhesSecretaria';

  @override
  State<PageMembrosDetalhesSecretariaWidget> createState() =>
      _PageMembrosDetalhesSecretariaWidgetState();
}

class _PageMembrosDetalhesSecretariaWidgetState
    extends State<PageMembrosDetalhesSecretariaWidget> {
  late PageMembrosDetalhesSecretariaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  MembrosRow? _membro;
  EnderecoRow? _endereco;
  NiveisAcessoRow? _nivelAcesso;
  TelefoneRow? _telefone;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageMembrosDetalhesSecretariaModel());
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      // Buscar membro
      final membros = await MembrosTable().queryRows(
        queryFn: (q) => q.eq('id_membro', widget.idmembro!),
      );
      if (membros.isNotEmpty) {
        _membro = membros.first;
      }

      // Buscar endereco
      if (widget.idendereco != null) {
        final enderecos = await EnderecoTable().queryRows(
          queryFn: (q) => q.eq('id_endereco', widget.idendereco!),
        );
        if (enderecos.isNotEmpty) {
          _endereco = enderecos.first;
        }
      }

      // Buscar nivel de acesso
      if (_membro?.idNivelAcesso != null) {
        final niveis = await NiveisAcessoTable().queryRows(
          queryFn: (q) => q.eq('id_nivel', _membro!.idNivelAcesso!),
        );
        if (niveis.isNotEmpty) {
          _nivelAcesso = niveis.first;
        }
      }

      // Buscar telefone
      final telefones = await TelefoneTable().queryRows(
        queryFn: (q) => q.eq('id_membro', widget.idmembro!),
      );
      if (telefones.isNotEmpty) {
        _telefone = telefones.first;
      }

      setState(() => _isLoading = false);
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

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
        drawer: Drawer(
          backgroundColor: Color(0xFF1A1A1A),
          child: MenuSecretariaWidget(),
        ),
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
                        child: _isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    FlutterFlowTheme.of(context).primary,
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header
                                    Padding(
                                      padding: EdgeInsets.all(24.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              if (!responsiveVisibility(context: context, phone: false, tablet: false, tabletLandscape: false))
                                                Padding(
                                                  padding: EdgeInsets.only(right: 12.0),
                                                  child: IconButton(
                                                    onPressed: () => scaffoldKey.currentState?.openDrawer(),
                                                    icon: Icon(Icons.menu_rounded, color: Colors.white, size: 28.0),
                                                  ),
                                                ),
                                              Text(
                                                'Detalhes do Membro',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 28.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              FFButtonWidget(
                                                onPressed: () {
                                                  context.pushNamed(
                                                    PageMembrosEditarDetalhesSecretariaWidget.routeName,
                                                    queryParameters: {
                                                      'idmembro': serializeParam(widget.idmembro, ParamType.String),
                                                      'idendereco': serializeParam(widget.idendereco, ParamType.int),
                                                    }.withoutNulls,
                                                  );
                                                },
                                                text: 'Editar',
                                                icon: Icon(Icons.edit_rounded, size: 18.0),
                                                options: FFButtonOptions(
                                                  height: 44.0,
                                                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                                                  color: FlutterFlowTheme.of(context).primary,
                                                  textStyle: GoogleFonts.inter(
                                                    color: Colors.white,
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  elevation: 0,
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                              SizedBox(width: 12.0),
                                              FFButtonWidget(
                                                onPressed: () => context.pop(),
                                                text: 'Voltar',
                                                icon: Icon(Icons.arrow_back_rounded, size: 18.0),
                                                options: FFButtonOptions(
                                                  height: 44.0,
                                                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                                                  color: FlutterFlowTheme.of(context).accent2,
                                                  textStyle: GoogleFonts.inter(
                                                    color: Colors.white,
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  elevation: 0,
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Conteúdo
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                                      child: Column(
                                        children: [
                                          // Card Dados Pessoais
                                          Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.all(24.0),
                                            decoration: BoxDecoration(
                                              color: Color(0xFF2D2D2D),
                                              borderRadius: BorderRadius.circular(16.0),
                                              border: Border.all(color: Color(0xFF404040)),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Header do card
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.all(10.0),
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.15),
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
                                                    Spacer(),
                                                    // Badge de status
                                                    Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                                      decoration: BoxDecoration(
                                                        color: _membro?.ativo == true
                                                            ? Color(0xFF027941).withOpacity(0.2)
                                                            : Color(0xFFFF4444).withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(20.0),
                                                        border: Border.all(
                                                          color: _membro?.ativo == true ? Color(0xFF027941) : Color(0xFFFF4444),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            _membro?.ativo == true ? Icons.check_circle : Icons.cancel,
                                                            color: _membro?.ativo == true ? Color(0xFF027941) : Color(0xFFFF4444),
                                                            size: 16.0,
                                                          ),
                                                          SizedBox(width: 6.0),
                                                          Text(
                                                            _membro?.ativo == true ? 'Ativo' : 'Inativo',
                                                            style: GoogleFonts.inter(
                                                              color: _membro?.ativo == true ? Color(0xFF027941) : Color(0xFFFF4444),
                                                              fontSize: 13.0,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 24.0),
                                                // Campos em grid
                                                LayoutBuilder(
                                                  builder: (context, constraints) {
                                                    if (constraints.maxWidth > 600) {
                                                      return Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Expanded(child: _buildInfoItem('Nome Completo', _membro?.nomeMembro ?? '-')),
                                                          SizedBox(width: 24.0),
                                                          Expanded(child: _buildInfoItem('Email', _membro?.email ?? '-')),
                                                        ],
                                                      );
                                                    }
                                                    return Column(
                                                      children: [
                                                        _buildInfoItem('Nome Completo', _membro?.nomeMembro ?? '-'),
                                                        SizedBox(height: 16.0),
                                                        _buildInfoItem('Email', _membro?.email ?? '-'),
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
                                                          Expanded(child: _buildInfoItem('Data de Nascimento', _formatDate(_membro?.dataNascimento))),
                                                          SizedBox(width: 24.0),
                                                          Expanded(child: _buildInfoItem('Telefone', _telefone?.numeroTelefone ?? '-')),
                                                        ],
                                                      );
                                                    }
                                                    return Column(
                                                      children: [
                                                        _buildInfoItem('Data de Nascimento', _formatDate(_membro?.dataNascimento)),
                                                        SizedBox(height: 16.0),
                                                        _buildInfoItem('Telefone', _telefone?.numeroTelefone ?? '-'),
                                                      ],
                                                    );
                                                  },
                                                ),
                                                SizedBox(height: 16.0),
                                                _buildInfoItem('Nível de Acesso', _nivelAcesso?.nomeNivel ?? '-'),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 20.0),
                                          // Card Endereço
                                          Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.all(24.0),
                                            decoration: BoxDecoration(
                                              color: Color(0xFF2D2D2D),
                                              borderRadius: BorderRadius.circular(16.0),
                                              border: Border.all(color: Color(0xFF404040)),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Header do card
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.all(10.0),
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFFE67700).withOpacity(0.15),
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
                                                // Campos em grid
                                                LayoutBuilder(
                                                  builder: (context, constraints) {
                                                    if (constraints.maxWidth > 600) {
                                                      return Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          SizedBox(width: 150.0, child: _buildInfoItem('CEP', _endereco?.cep ?? '-')),
                                                          SizedBox(width: 24.0),
                                                          Expanded(child: _buildInfoItem('Rua', _endereco?.nomeEndereco ?? '-')),
                                                          SizedBox(width: 24.0),
                                                          SizedBox(width: 100.0, child: _buildInfoItem('Número', _endereco?.numero ?? '-')),
                                                        ],
                                                      );
                                                    }
                                                    return Column(
                                                      children: [
                                                        _buildInfoItem('CEP', _endereco?.cep ?? '-'),
                                                        SizedBox(height: 16.0),
                                                        _buildInfoItem('Rua', _endereco?.nomeEndereco ?? '-'),
                                                        SizedBox(height: 16.0),
                                                        _buildInfoItem('Número', _endereco?.numero ?? '-'),
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
                                                          Expanded(child: _buildInfoItem('Bairro', _endereco?.bairro ?? '-')),
                                                          SizedBox(width: 24.0),
                                                          Expanded(child: _buildInfoItemAsync('Cidade')),
                                                        ],
                                                      );
                                                    }
                                                    return Column(
                                                      children: [
                                                        _buildInfoItem('Bairro', _endereco?.bairro ?? '-'),
                                                        SizedBox(height: 16.0),
                                                        _buildInfoItemAsync('Cidade'),
                                                      ],
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
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Color(0xFF999999),
            fontSize: 13.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.0),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Color(0xFF333333)),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItemAsync(String label) {
    return FutureBuilder<List<CidadeRow>>(
      future: _endereco?.idCidade != null
          ? CidadeTable().queryRows(queryFn: (q) => q.eq('id_cidade', _endereco!.idCidade!))
          : Future.value([]),
      builder: (context, snapshot) {
        String value = '-';
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          value = snapshot.data!.first.nomeCidade ?? '-';
        }
        return _buildInfoItem(label, value);
      },
    );
  }
}
