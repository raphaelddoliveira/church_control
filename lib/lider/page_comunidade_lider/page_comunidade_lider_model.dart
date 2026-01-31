import '/flutter_flow/flutter_flow_util.dart';
import '/lider/menu_lider/menu_lider_widget.dart';
import 'page_comunidade_lider_widget.dart' show PageComunidadeLiderWidget;
import 'package:flutter/material.dart';

class PageComunidadeLiderModel extends FlutterFlowModel<PageComunidadeLiderWidget> {
  // State fields for stateful widgets in this page.
  late MenuLiderModel menuLiderModel;

  // Campo de busca
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;

  // Campo de busca de avisos
  FocusNode? searchAvisosFocusNode;
  TextEditingController? searchAvisosController;

  @override
  void initState(BuildContext context) {
    menuLiderModel = createModel(context, () => MenuLiderModel());
  }

  @override
  void dispose() {
    menuLiderModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
    searchAvisosFocusNode?.dispose();
    searchAvisosController?.dispose();
  }
}
