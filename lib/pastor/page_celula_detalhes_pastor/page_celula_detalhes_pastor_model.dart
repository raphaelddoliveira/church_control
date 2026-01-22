import '/flutter_flow/flutter_flow_util.dart';
import '/pastor/menu_pastor/menu_pastor_widget.dart';
import 'page_celula_detalhes_pastor_widget.dart' show PageCelulaDetalhesPastorWidget;
import 'package:flutter/material.dart';

class PageCelulaDetalhesPastorModel
    extends FlutterFlowModel<PageCelulaDetalhesPastorWidget> {
  // Model for MenuPastor component.
  late MenuPastorModel menuPastorModel;

  @override
  void initState(BuildContext context) {
    menuPastorModel = createModel(context, () => MenuPastorModel());
  }

  @override
  void dispose() {
    menuPastorModel.dispose();
  }
}
