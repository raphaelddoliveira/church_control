import '/admin/menu_admin/menu_admin_widget.dart';
import '/backend/supabase/supabase.dart';
import '/components/meu_perfil_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'page_membros_admin_widget.dart' show PageMembrosAdminWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PageMembrosAdminModel extends FlutterFlowModel<PageMembrosAdminWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Menu_Admin component.
  late MenuAdminModel menuAdminModel;
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
    menuAdminModel = createModel(context, () => MenuAdminModel());
  }

  @override
  void dispose() {
    menuAdminModel.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
