import '/backend/supabase/supabase.dart';
import '/components/meu_perfil_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/secretaria/menu_secretaria/menu_secretaria_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'page_membros_secretaria_widget.dart' show PageMembrosSecretariaWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PageMembrosSecretariaModel
    extends FlutterFlowModel<PageMembrosSecretariaWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Menu_Secretaria component.
  late MenuSecretariaModel menuSecretariaModel;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  // Filtros
  String? filtroStatus;
  String? filtroBairro;
  int? filtroMinisterio;
  DateTime? filtroDataNascimentoInicio;
  DateTime? filtroDataNascimentoFim;

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
