import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'page_membros_nova_widget.dart' show PageMembrosNovaWidget;
import 'package:flutter/material.dart';

class PageMembrosNovaModel extends FlutterFlowModel<PageMembrosNovaWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for categoria widget.
  String? categoriaValue = 'Todos';
  FormFieldController<List<String>>? categoriaValueController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    categoriaValueController?.dispose();
  }
}
