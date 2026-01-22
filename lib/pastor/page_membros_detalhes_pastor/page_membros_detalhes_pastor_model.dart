import '/flutter_flow/flutter_flow_util.dart';
import '/pastor/menu_pastor/menu_pastor_widget.dart';
import 'page_membros_detalhes_pastor_widget.dart'
    show PageMembrosDetalhesPastorWidget;
import 'package:flutter/material.dart';

class PageMembrosDetalhesPastorModel
    extends FlutterFlowModel<PageMembrosDetalhesPastorWidget> {
  // Model for Menu_Pastor component.
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
