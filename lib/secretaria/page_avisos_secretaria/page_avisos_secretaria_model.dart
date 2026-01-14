import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/secretaria/menu_secretaria/menu_secretaria_widget.dart';
import 'dart:ui';
import 'page_avisos_secretaria_widget.dart' show PageAvisosSecretariaWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PageAvisosSecretariaModel
    extends FlutterFlowModel<PageAvisosSecretariaWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Menu_Secretaria component.
  late MenuSecretariaModel menuSecretariaModel;

  // Search and filter states
  TextEditingController? searchController;
  FocusNode? searchFocusNode;
  bool isSearchVisible = false;
  String? filtroStatus; // null, 'ativo', 'expirado'
  String? filtroCategoria; // null ou categoria específica

  @override
  void initState(BuildContext context) {
    menuSecretariaModel = createModel(context, () => MenuSecretariaModel());
    searchController = TextEditingController();
    searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    menuSecretariaModel.dispose();
    searchController?.dispose();
    searchFocusNode?.dispose();
  }
}
