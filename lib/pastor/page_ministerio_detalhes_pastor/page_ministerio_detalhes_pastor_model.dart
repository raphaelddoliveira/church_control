import '/flutter_flow/flutter_flow_util.dart';
import '/pastor/menu_pastor/menu_pastor_widget.dart';
import 'page_ministerio_detalhes_pastor_widget.dart'
    show PageMinisterioDetalhesPastorWidget;
import 'package:flutter/material.dart';

class PageMinisterioDetalhesPastorModel
    extends FlutterFlowModel<PageMinisterioDetalhesPastorWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  // Model for Menu_Pastor component.
  late MenuPastorModel menuPastorModel;

  @override
  void initState(BuildContext context) {
    menuPastorModel = createModel(context, () => MenuPastorModel());
  }

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
    menuPastorModel.dispose();
  }
}
