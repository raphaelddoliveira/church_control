import '/admin/menu_admin/menu_admin_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'page_comunidade_admin_detalhes_widget.dart' show PageComunidadeAdminDetalhesWidget;
import 'package:flutter/material.dart';

class PageComunidadeAdminDetalhesModel
    extends FlutterFlowModel<PageComunidadeAdminDetalhesWidget> {
  // Model for Menu_Admin component.
  late MenuAdminModel menuAdminModel;

  @override
  void initState(BuildContext context) {
    menuAdminModel = createModel(context, () => MenuAdminModel());
  }

  @override
  void dispose() {
    menuAdminModel.dispose();
  }
}
