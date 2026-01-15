import '/flutter_flow/flutter_flow_util.dart';
import '/secretaria/menu_secretaria/menu_secretaria_widget.dart';
import 'page_celula_detalhes_secretaria_widget.dart' show PageCelulaDetalhesSecretariaWidget;
import 'package:flutter/material.dart';

class PageCelulaDetalhesSecretariaModel
    extends FlutterFlowModel<PageCelulaDetalhesSecretariaWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for MenuSecretaria component.
  late MenuSecretariaModel menuSecretariaModel;

  @override
  void initState(BuildContext context) {
    menuSecretariaModel = createModel(context, () => MenuSecretariaModel());
  }

  @override
  void dispose() {
    menuSecretariaModel.dispose();
  }
}
