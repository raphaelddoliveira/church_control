import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_teste_model.dart';
export 'login_teste_model.dart';

class LoginTesteWidget extends StatefulWidget {
  const LoginTesteWidget({super.key});

  static String routeName = 'Login_Teste';
  static String routePath = '/loginTeste';

  @override
  State<LoginTesteWidget> createState() => _LoginTesteWidgetState();
}

class _LoginTesteWidgetState extends State<LoginTesteWidget> {
  late LoginTesteModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  bool _senhaVisivel = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginTesteModel());

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    if (_model.emailAddressTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, informe seu email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_model.passwordTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, informe sua senha'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      GoRouter.of(context).prepareAuthEvent();

      final user = await authManager.signInWithEmail(
        context,
        _model.emailAddressTextController.text.trim(),
        _model.passwordTextController.text,
      );

      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      context.goNamedAuth(
        PaginadetransicaoWidget.routeName,
        context.mounted,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer login: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF0D0D0D),
        body: SafeArea(
          top: true,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Espaçamento do topo
                      SizedBox(height: 32.0),
                      // Logo e título
                      Container(
                        padding: EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.church_rounded,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 64.0,
                        ),
                      ),
                      SizedBox(height: 24.0),
                      Text(
                        'ChurchControl',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Sistema de Gestão Eclesiástica',
                        style: GoogleFonts.inter(
                          color: Color(0xFF666666),
                          fontSize: 14.0,
                        ),
                      ),
                      SizedBox(height: 48.0),

                      // Card de login
                      Container(
                        padding: EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: Color(0xFF2A2A2A),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bem-vindo de volta',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 22.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Faça login para continuar',
                              style: GoogleFonts.inter(
                                color: Color(0xFF666666),
                                fontSize: 14.0,
                              ),
                            ),
                            SizedBox(height: 32.0),

                            // Campo Email
                            Text(
                              'Email',
                              style: GoogleFonts.inter(
                                color: Color(0xFF999999),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            TextFormField(
                              controller: _model.emailAddressTextController,
                              focusNode: _model.emailAddressFocusNode,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: [AutofillHints.email],
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 15.0,
                              ),
                              decoration: InputDecoration(
                                hintText: 'seu@email.com',
                                hintStyle: GoogleFonts.inter(
                                  color: Color(0xFF444444),
                                  fontSize: 15.0,
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: Color(0xFF666666),
                                  size: 20.0,
                                ),
                                filled: true,
                                fillColor: Color(0xFF0D0D0D),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: Color(0xFF2A2A2A),
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: Color(0xFF2A2A2A),
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
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 16.0,
                                ),
                              ),
                            ),
                            SizedBox(height: 20.0),

                            // Campo Senha
                            Text(
                              'Senha',
                              style: GoogleFonts.inter(
                                color: Color(0xFF999999),
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            TextFormField(
                              controller: _model.passwordTextController,
                              focusNode: _model.passwordFocusNode,
                              obscureText: !_senhaVisivel,
                              autofillHints: [AutofillHints.password],
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 15.0,
                              ),
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                hintStyle: GoogleFonts.inter(
                                  color: Color(0xFF444444),
                                  fontSize: 15.0,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline_rounded,
                                  color: Color(0xFF666666),
                                  size: 20.0,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _senhaVisivel
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Color(0xFF666666),
                                    size: 20.0,
                                  ),
                                  onPressed: () {
                                    setState(() => _senhaVisivel = !_senhaVisivel);
                                  },
                                ),
                                filled: true,
                                fillColor: Color(0xFF0D0D0D),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: Color(0xFF2A2A2A),
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: Color(0xFF2A2A2A),
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
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 16.0,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.0),

                            // Esqueci a senha
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  context.pushNamed(RecuperacaodeSenhaWidget.routeName);
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Esqueci minha senha',
                                  style: GoogleFonts.inter(
                                    color: FlutterFlowTheme.of(context).primary,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24.0),

                            // Botão Entrar
                            SizedBox(
                              width: double.infinity,
                              height: 52.0,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _fazerLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: FlutterFlowTheme.of(context).primary,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: FlutterFlowTheme.of(context).primary.withOpacity(0.5),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        width: 24.0,
                                        height: 24.0,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        'Entrar',
                                        style: GoogleFonts.inter(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.0),

                      // Divisor
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1.0,
                              color: Color(0xFF2A2A2A),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'ou',
                              style: GoogleFonts.inter(
                                color: Color(0xFF666666),
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1.0,
                              color: Color(0xFF2A2A2A),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.0),

                      // Botão Criar Conta
                      SizedBox(
                        width: double.infinity,
                        height: 52.0,
                        child: OutlinedButton(
                          onPressed: () {
                            context.pushNamed(RegistroMembroWidget.routeName);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: FlutterFlowTheme.of(context).primary,
                            side: BorderSide(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: Text(
                            'Criar Conta de Membro',
                            style: GoogleFonts.inter(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 48.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
