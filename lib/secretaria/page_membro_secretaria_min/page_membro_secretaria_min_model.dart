import '/backend/supabase/supabase.dart';
import '/components/meu_perfil_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/secretaria/menu_secretaria/menu_secretaria_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'page_membro_secretaria_min_widget.dart'
    show PageMembroSecretariaMinWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PageMembroSecretariaMinModel
    extends FlutterFlowModel<PageMembroSecretariaMinWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Menu_Secretaria component.
  late MenuSecretariaModel menuSecretariaModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;

  @override
  void initState(BuildContext context) {
    menuSecretariaModel = createModel(context, () => MenuSecretariaModel());
  }

  @override
  void dispose() {
    menuSecretariaModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
