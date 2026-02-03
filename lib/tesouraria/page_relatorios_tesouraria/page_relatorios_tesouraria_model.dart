import '/flutter_flow/flutter_flow_util.dart';
import 'page_relatorios_tesouraria_widget.dart' show PageRelatoriosTesourariaWidget;
import 'package:flutter/material.dart';

class PageRelatoriosTesourariaModel extends FlutterFlowModel<PageRelatoriosTesourariaWidget> {
  // Tab controller
  TabController? tabController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabController?.dispose();
  }
}
