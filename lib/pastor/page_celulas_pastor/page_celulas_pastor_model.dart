import '/flutter_flow/flutter_flow_util.dart';
import '/pastor/menu_pastor/menu_pastor_widget.dart';
import 'page_celulas_pastor_widget.dart' show PageCelulasPastorWidget;
import 'package:flutter/material.dart';

class PageCelulasPastorModel extends FlutterFlowModel<PageCelulasPastorWidget> {
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
