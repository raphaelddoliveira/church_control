import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'paginadetransicao_model.dart';
export 'paginadetransicao_model.dart';

class PaginadetransicaoWidget extends StatefulWidget {
  const PaginadetransicaoWidget({super.key});

  static String routeName = 'Paginadetransicao';
  static String routePath = '/paginadetransicao';

  @override
  State<PaginadetransicaoWidget> createState() =>
      _PaginadetransicaoWidgetState();
}

class _PaginadetransicaoWidgetState extends State<PaginadetransicaoWidget> {
  late PaginadetransicaoModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaginadetransicaoModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.returnlista = await MembrosTable().queryRows(
        queryFn: (q) => q.eqOrNull(
          'id_auth',
          currentUserUid,
        ),
      );

      final membro = _model.returnlista?.firstOrNull;

      if (membro == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Usuário não encontrado!',
              style: FlutterFlowTheme.of(context).titleLarge.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FlutterFlowTheme.of(context)
                          .titleLarge
                          .fontWeight,
                      fontStyle: FlutterFlowTheme.of(context)
                          .titleLarge
                          .fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FlutterFlowTheme.of(context)
                        .titleLarge
                        .fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleLarge.fontStyle,
                  ),
            ),
            duration: Duration(milliseconds: 4000),
            backgroundColor: FlutterFlowTheme.of(context).secondary,
          ),
        );
        return;
      }

      // Verifica se tem acesso administrativo e à área de membro
      final temAcessoAdmin = membro.idNivelAcesso != null &&
                             membro.idNivelAcesso != 5 &&
                             membro.idNivelAcesso != null;
      final podeAcessarMembro = membro.podeAcessarAreaMembro == true;

      // Se tem ambos os acessos, ir para tela de seleção
      if (temAcessoAdmin && podeAcessarMembro) {
        context.pushNamed('SelecionaPerfil');
        return;
      }

      // Roteamento baseado no nível de acesso
      switch (membro.idNivelAcesso) {
        case 1:
          context.pushNamed(PageHomeSecretariaWidget.routeName);
          break;
        case 2:
          context.pushNamed(HomeTesourariaWidget.routeName);
          break;
        case 3:
          context.pushNamed(HomePageAdminWidget.routeName);
          break;
        case 4:
          context.pushNamed(HomepagePastorWidget.routeName);
          break;
        case 5:
          // Membro comum - redirecionar direto para a página de avisos
          context.pushNamed(PageMembrosNovaWidget.routeName);
          break;
        case 6:
          context.pushNamed(HomepageLiderWidget.routeName);
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Nível de acesso inválido!',
                style: FlutterFlowTheme.of(context).titleLarge.override(
                      font: GoogleFonts.interTight(),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                    ),
              ),
              duration: Duration(milliseconds: 4000),
              backgroundColor: FlutterFlowTheme.of(context).error,
            ),
          );
      }
    });

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
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: SafeArea(
          top: true,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      GoRouter.of(context).prepareAuthEvent();
                      await authManager.signOut();
                      GoRouter.of(context).clearRedirectLocation();

                      context.goNamedAuth(
                          LoginTesteWidget.routeName, context.mounted);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/Screenshot_29.png',
                        width: 373.44,
                        height: 519.5,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
