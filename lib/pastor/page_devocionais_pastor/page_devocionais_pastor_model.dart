import '/pastor/menu_pastor/menu_pastor_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'page_devocionais_pastor_widget.dart' show PageDevocionaisPastorWidget;
import 'package:flutter/material.dart';

class PageDevocionaisPastorModel
    extends FlutterFlowModel<PageDevocionaisPastorWidget> {
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
