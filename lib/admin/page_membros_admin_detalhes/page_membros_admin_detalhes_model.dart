import '/admin/menu_admin/menu_admin_widget.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/meu_perfil_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/flutter_flow/random_data_util.dart' as random_data;
import '/index.dart';
import 'page_membros_admin_detalhes_widget.dart'
    show PageMembrosAdminDetalhesWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PageMembrosAdminDetalhesModel
    extends FlutterFlowModel<PageMembrosAdminDetalhesWidget> {
  ///  Local state fields for this page.

  String senhaaleatoria = '0';

  ///  State fields for stateful widgets in this page.

  // Model for Menu_Admin component.
  late MenuAdminModel menuAdminModel;
  // Stores action output result for [Backend Call - API (Criar Usuario)] action in Button widget.
  ApiCallResponse? apiResult02d;
  // Stores action output result for [Backend Call - API (Envio dados escala)] action in Button widget.
  ApiCallResponse? apiResultima;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // State field(s) for DropDown widget.
  int? dropDownValue;
  FormFieldController<int>? dropDownValueController;
  // State field(s) for Checkbox widget.
  bool? checkboxValue;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;

  @override
  void initState(BuildContext context) {
    menuAdminModel = createModel(context, () => MenuAdminModel());
  }

  @override
  void dispose() {
    menuAdminModel.dispose();
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    textFieldFocusNode3?.dispose();
    textController3?.dispose();
  }
}
