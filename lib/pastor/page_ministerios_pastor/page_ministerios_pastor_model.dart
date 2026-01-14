import '/backend/supabase/supabase.dart';
import '/components/meu_perfil_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pastor/menu_pastor/menu_pastor_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'page_ministerios_pastor_widget.dart' show PageMinisteriosPastorWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PageMinisteriosPastorModel
    extends FlutterFlowModel<PageMinisteriosPastorWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Menu_Pastor component.
  late MenuPastorModel menuPastorModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {
    menuPastorModel = createModel(context, () => MenuPastorModel());
  }

  @override
  void dispose() {
    menuPastorModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
