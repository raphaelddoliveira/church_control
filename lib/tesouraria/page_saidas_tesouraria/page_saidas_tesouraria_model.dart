import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'page_saidas_tesouraria_widget.dart' show PageSaidasTesourariaWidget;
import 'package:flutter/material.dart';

class PageSaidasTesourariaModel extends FlutterFlowModel<PageSaidasTesourariaWidget> {
  // State fields for search
  FocusNode? searchFocusNode;
  TextEditingController? searchController;

  @override
  void initState(BuildContext context) {
    searchController = TextEditingController();
    searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    searchFocusNode?.dispose();
    searchController?.dispose();
  }
}
