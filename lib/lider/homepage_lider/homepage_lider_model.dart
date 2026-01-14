import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/lider/menu_lider/menu_lider_widget.dart';
import '/lider/menu_lider_mobile/menu_lider_mobile_widget.dart';
import 'dart:ui';
import 'homepage_lider_widget.dart' show HomepageLiderWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomepageLiderModel extends FlutterFlowModel<HomepageLiderWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Menu_Lider component.
  late MenuLiderModel menuLiderModel;

  @override
  void initState(BuildContext context) {
    menuLiderModel = createModel(context, () => MenuLiderModel());
  }

  @override
  void dispose() {
    menuLiderModel.dispose();
  }
}
