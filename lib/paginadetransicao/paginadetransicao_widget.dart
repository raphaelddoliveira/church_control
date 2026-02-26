import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

      // Níveis que são somente web (1=Secretaria, 2=Tesouraria, 3=Admin, 4=Pastor)
      final niveisApenasWeb = [1, 2, 3, 4];
      final isNivelApenasWeb = niveisApenasWeb.contains(membro.idNivelAcesso);

      // BLOQUEIO MOBILE: Se não é web e o nível é apenas web
      if (!kIsWeb && isNivelApenasWeb) {
        // Se também pode acessar área de membro, redireciona direto
        if (podeAcessarMembro) {
          context.pushNamed(PageMembrosNovaWidget.routeName);
          return;
        }

        // Senão, mostra dialog informativo e faz logout
        if (mounted) {
          _mostrarDialogApenasWeb(context, membro.idNivelAcesso!);
        }
        return;
      }

      // Se tem ambos os acessos no mobile, ir direto para área de membro
      if (!kIsWeb && temAcessoAdmin && podeAcessarMembro) {
        context.pushNamed(PageMembrosNovaWidget.routeName);
        return;
      }

      // Se tem ambos os acessos na web, ir para tela de seleção
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

  String _getNomeNivel(int nivel) {
    switch (nivel) {
      case 1: return 'Secretaria';
      case 2: return 'Tesouraria';
      case 3: return 'Administração';
      case 4: return 'Pastor';
      default: return 'Administrativo';
    }
  }

  void _mostrarDialogApenasWeb(BuildContext context, int nivelAcesso) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 380.0),
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    color: Color(0xFF2196F3).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.computer_rounded,
                    color: Color(0xFF2196F3),
                    size: 40.0,
                  ),
                ),
                SizedBox(height: 24.0),
                // Título
                Text(
                  'Acesso apenas via Web',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.0),
                // Mensagem
                Text(
                  'A área de ${_getNomeNivel(nivelAcesso)} está disponível apenas pela versão web do ChurchControl.',
                  style: GoogleFonts.inter(
                    color: Color(0xFF999999),
                    fontSize: 14.0,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.0),
                Text(
                  'Acesse pelo navegador do seu computador ou celular.',
                  style: GoogleFonts.inter(
                    color: Color(0xFF666666),
                    fontSize: 13.0,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.0),
                // Botão Logout
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      GoRouter.of(context).prepareAuthEvent();
                      await authManager.signOut();
                      GoRouter.of(context).clearRedirectLocation();
                      context.goNamedAuth(
                        LoginTesteWidget.routeName,
                        context.mounted,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Voltar para o Login',
                      style: GoogleFonts.inter(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
