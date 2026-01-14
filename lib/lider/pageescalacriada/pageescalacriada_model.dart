import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/lider/menu_lider/menu_lider_widget.dart';
import '/lider/menu_lider_mobile/menu_lider_mobile_widget.dart';
import '/lider/ve_arquivo/ve_arquivo_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'pageescalacriada_widget.dart' show PageescalacriadaWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PageescalacriadaModel extends FlutterFlowModel<PageescalacriadaWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Menu_Lider component.
  late MenuLiderModel menuLiderModel;
  Stream<List<MembrosEscalasRow>>? listViewSupabaseStream1;
  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;
  Stream<List<MembrosEscalasRow>>? listViewSupabaseStream2;

  @override
  void initState(BuildContext context) {
    menuLiderModel = createModel(context, () => MenuLiderModel());
  }

  @override
  void dispose() {
    menuLiderModel.dispose();
  }
}
