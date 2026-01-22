import '/admin/menu_admin/menu_admin_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'page_membros_admin_widget.dart' show PageMembrosAdminWidget;
import 'package:flutter/material.dart';

class PageMembrosAdminModel extends FlutterFlowModel<PageMembrosAdminWidget> {
  // Model for Menu_Admin component.
  late MenuAdminModel menuAdminModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;

  // Filtros
  String? filtroStatus;

  @override
  void initState(BuildContext context) {
    menuAdminModel = createModel(context, () => MenuAdminModel());
  }

  @override
  void dispose() {
    menuAdminModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
