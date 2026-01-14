import '/backend/supabase/supabase.dart';
import '/components/meu_perfil_widget.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pastor/info_conta_pastor/info_conta_pastor_widget.dart';
import '/pastor/menu_pastor/menu_pastor_widget.dart';
import 'dart:ui';
import 'homepage_pastor_widget.dart' show HomepagePastorWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomepagePastorModel extends FlutterFlowModel<HomepagePastorWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Menu_Pastor component.
  late MenuPastorModel menuPastorModel;

  @override
  void initState(BuildContext context) {
    menuPastorModel = createModel(context, () => MenuPastorModel());
  }

  @override
  void dispose() {
    menuPastorModel.dispose();
  }
}
