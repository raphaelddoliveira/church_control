import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'page_membro_model.dart';
export 'page_membro_model.dart';

// DEPRECATED: Esta página foi substituída por PageMembrosNovaWidget
// Mantida apenas para compatibilidade de rotas antigas
class PageMembroWidget extends StatefulWidget {
  const PageMembroWidget({super.key});

  static String routeName = 'PageMembro';
  static String routePath = '/pageMembro';

  @override
  State<PageMembroWidget> createState() => _PageMembroWidgetState();
}

class _PageMembroWidgetState extends State<PageMembroWidget> {
  late PageMembroModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageMembroModel());

    // Redirecionar para a nova página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.goNamed('PageMembrosNova');
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(0xFF0A0A0A),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
