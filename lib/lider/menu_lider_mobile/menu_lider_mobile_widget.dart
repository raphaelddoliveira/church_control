import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/components/meu_perfil_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import '/lider/page_comunidade_lider/page_comunidade_lider_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'menu_lider_mobile_model.dart';
export 'menu_lider_mobile_model.dart';

class MenuLiderMobileWidget extends StatefulWidget {
  const MenuLiderMobileWidget({
    super.key,
    this.parameter1,
  });

  final String? parameter1;

  @override
  State<MenuLiderMobileWidget> createState() => _MenuLiderMobileWidgetState();
}

class _MenuLiderMobileWidgetState extends State<MenuLiderMobileWidget> {
  late MenuLiderMobileModel _model;
  MembrosRow? _membro;
  MinisterioRow? _ministerio;
  bool _isLoading = true;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MenuLiderMobileModel());
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final membroRows = await MembrosTable().queryRows(
        queryFn: (q) => q.eq('id_auth', currentUserUid),
      );

      MembrosRow? membro;
      if (membroRows.isNotEmpty) {
        membro = membroRows.first;
      }

      MinisterioRow? ministerio;
      if (membro != null) {
        final ministerioRows = await MinisterioTable().queryRows(
          queryFn: (q) => q.eq('id_lider', membro!.idMembro),
        );
        if (ministerioRows.isNotEmpty) {
          ministerio = ministerioRows.first;
        }
      }

      setState(() {
        _membro = membro;
        _ministerio = ministerio;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black54,
        child: GestureDetector(
          onTap: () {}, // Prevent tap from closing
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.0),
              constraints: BoxConstraints(maxWidth: 360),
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: _isLoading
                  ? Container(
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header com botao fechar
                        _buildHeader(context),

                        // Info do usuario
                        _buildUserInfo(context),

                        Divider(
                          color: Color(0xFF3A3A3A),
                          height: 1,
                          indent: 24,
                          endIndent: 24,
                        ),

                        // Menu items
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: [
                              _buildMenuItem(
                                context: context,
                                icon: Icons.home_rounded,
                                title: 'Pagina Inicial',
                                subtitle: 'Voltar ao inicio',
                                color: Color(0xFF2196F3),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  context.pushNamed(
                                    HomepageLiderWidget.routeName,
                                    extra: <String, dynamic>{
                                      kTransitionInfoKey: TransitionInfo(
                                        hasTransition: true,
                                        transitionType: PageTransitionType.fade,
                                      ),
                                    },
                                  );
                                },
                              ),
                              _buildMenuItem(
                                context: context,
                                icon: Icons.groups_rounded,
                                title: 'Meu Ministerio',
                                subtitle: 'Gerenciar membros',
                                color: Color(0xFF00BFA5),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  if (_ministerio != null) {
                                    context.pushNamed(
                                      PageMinisterioDetalhesLiderWidget.routeName,
                                      queryParameters: {
                                        'idministerio': serializeParam(
                                          _ministerio!.idMinisterio,
                                          ParamType.int,
                                        ),
                                      }.withoutNulls,
                                    );
                                  }
                                },
                              ),
                              _buildMenuItem(
                                context: context,
                                icon: Icons.calendar_month_rounded,
                                title: 'Escalas',
                                subtitle: 'Ver todas as escalas',
                                color: Color(0xFFFF9800),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  if (_ministerio != null) {
                                    context.pushNamed(
                                      PageEscalasLiderWidget.routeName,
                                      queryParameters: {
                                        'idministerio': serializeParam(
                                          _ministerio!.idMinisterio,
                                          ParamType.int,
                                        ),
                                      }.withoutNulls,
                                    );
                                  }
                                },
                              ),
                              _buildMenuItem(
                                context: context,
                                icon: Icons.add_circle_rounded,
                                title: 'Nova Escala',
                                subtitle: 'Criar uma escala',
                                color: FlutterFlowTheme.of(context).primary,
                                onTap: () {
                                  Navigator.of(context).pop();
                                  if (_ministerio != null) {
                                    if (_ministerio!.idMinisterio == 1) {
                                      context.pushNamed(
                                        'PageCriaEscala_Louvor',
                                        queryParameters: {
                                          'idministerio': serializeParam(
                                            _ministerio!.idMinisterio,
                                            ParamType.int,
                                          ),
                                        },
                                      );
                                    } else {
                                      context.pushNamed(
                                        'PageCriaEscala_Lider',
                                        queryParameters: {
                                          'idministerio': serializeParam(
                                            _ministerio!.idMinisterio,
                                            ParamType.int,
                                          ),
                                        },
                                      );
                                    }
                                  }
                                },
                              ),
                              _buildMenuItem(
                                context: context,
                                icon: Icons.groups_3_rounded,
                                title: 'Minha Comunidade',
                                subtitle: 'Gerenciar comunidade e avisos',
                                color: Color(0xFF4CAF50),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  context.pushNamed(
                                    PageComunidadeLiderWidget.routeName,
                                    extra: <String, dynamic>{
                                      kTransitionInfoKey: TransitionInfo(
                                        hasTransition: true,
                                        transitionType: PageTransitionType.fade,
                                      ),
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        Divider(
                          color: Color(0xFF3A3A3A),
                          height: 1,
                          indent: 24,
                          endIndent: 24,
                        ),

                        // Perfil e Logout
                        _buildBottomSection(context),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.0, 20.0, 16.0, 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  Icons.menu_rounded,
                  color: FlutterFlowTheme.of(context).primary,
                  size: 20.0,
                ),
              ),
              SizedBox(width: 12.0),
              Text(
                'Menu',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Icon(
                Icons.close_rounded,
                color: Color(0xFF999999),
                size: 20.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 20.0),
      child: Row(
        children: [
          Container(
            width: 56.0,
            height: 56.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FlutterFlowTheme.of(context).primary,
                  FlutterFlowTheme.of(context).primary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Center(
              child: Text(
                _membro?.nomeMembro?.substring(0, 1).toUpperCase() ?? 'L',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _membro?.nomeMembro ?? 'Lider',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.0),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    _ministerio?.nomeMinisterio ?? 'Ministerio',
                    style: GoogleFonts.inter(
                      color: FlutterFlowTheme.of(context).primary,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Container(
          padding: EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(14.0),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22.0,
                ),
              ),
              SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.0),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: Color(0xFF888888),
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF555555),
                size: 22.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () async {
          Navigator.of(context).pop();
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
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.0),
          decoration: BoxDecoration(
            color: Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 20.0,
              ),
              SizedBox(width: 8.0),
              Text(
                'Meu Perfil',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
