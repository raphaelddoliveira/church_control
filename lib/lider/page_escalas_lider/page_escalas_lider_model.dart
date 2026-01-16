import '/flutter_flow/flutter_flow_util.dart';
import '/lider/menu_lider/menu_lider_widget.dart';
import 'page_escalas_lider_widget.dart' show PageEscalasLiderWidget;
import 'package:flutter/material.dart';

class PageEscalasLiderModel extends FlutterFlowModel<PageEscalasLiderWidget> {
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  // Model for Menu_Lider component.
  late MenuLiderModel menuLiderModel;

  @override
  void initState(BuildContext context) {
    menuLiderModel = createModel(context, () => MenuLiderModel());
  }

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
    menuLiderModel.dispose();
  }
}
