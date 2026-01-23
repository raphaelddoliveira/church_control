import '/pastor/menu_pastor/menu_pastor_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'page_devocional_pastor_editar_widget.dart' show PageDevocionalPastorEditarWidget;
import 'package:flutter/material.dart';

class PageDevocionalPastorEditarModel
    extends FlutterFlowModel<PageDevocionalPastorEditarWidget> {
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
