import '/flutter_flow/flutter_flow_util.dart';
import '/secretaria/menu_secretaria/menu_secretaria_widget.dart';
import 'page_celulas_secretaria_widget.dart' show PageCelulasSecretariaWidget;
import 'package:flutter/material.dart';

class PageCelulasSecretariaModel
    extends FlutterFlowModel<PageCelulasSecretariaWidget> {
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
