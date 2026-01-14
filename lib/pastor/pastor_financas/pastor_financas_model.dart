import '/backend/supabase/supabase.dart';
import '/components/meu_perfil_widget.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/pastor/menu_pastor/menu_pastor_widget.dart';
import 'dart:ui';
import 'pastor_financas_widget.dart' show PastorFinancasWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PastorFinancasModel extends FlutterFlowModel<PastorFinancasWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Menu_Pastor component.
  late MenuPastorModel menuPastorModel;
  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;

  @override
  void initState(BuildContext context) {
    menuPastorModel = createModel(context, () => MenuPastorModel());
  }

  @override
  void dispose() {
    menuPastorModel.dispose();
  }
}
