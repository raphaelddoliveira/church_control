import '/flutter_flow/flutter_flow_util.dart';
import 'page_entradas_tesouraria_widget.dart' show PageEntradasTesourariaWidget;
import 'package:flutter/material.dart';

class PageEntradasTesourariaModel extends FlutterFlowModel<PageEntradasTesourariaWidget> {
  FocusNode? searchFocusNode;
  TextEditingController? searchController;

  @override
  void initState(BuildContext context) {
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchFocusNode?.dispose();
    searchController?.dispose();
  }
}
