import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/lider/menu_lider/menu_lider_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'page_cria_escala_lider_widget.dart' show PageCriaEscalaLiderWidget;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PageCriaEscalaLiderModel
    extends FlutterFlowModel<PageCriaEscalaLiderWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Menu_Lider component.
  late MenuLiderModel menuLiderModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextFieldData widget.
  FocusNode? textFieldDataFocusNode;
  TextEditingController? textFieldDataTextController;
  String? Function(BuildContext, String?)? textFieldDataTextControllerValidator;
  DateTime? datePicked;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;
  // State field(s) for TextFieldArquivos widget.
  FocusNode? textFieldArquivosFocusNode;
  TextEditingController? textFieldArquivosTextController;
  String? Function(BuildContext, String?)?
      textFieldArquivosTextControllerValidator;
  bool isDataUploading_uploadData915 = false;
  List<FFUploadedFile> uploadedLocalFiles_uploadData915 = [];
  List<String> uploadedFileUrls_uploadData915 = [];

  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<EscalasRow>? listaescala;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<EscalasRow>? listescala;

  @override
  void initState(BuildContext context) {
    menuLiderModel = createModel(context, () => MenuLiderModel());
  }

  @override
  void dispose() {
    menuLiderModel.dispose();
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldDataFocusNode?.dispose();
    textFieldDataTextController?.dispose();

    textFieldFocusNode2?.dispose();
    textController3?.dispose();

    textFieldArquivosFocusNode?.dispose();
    textFieldArquivosTextController?.dispose();
  }
}
