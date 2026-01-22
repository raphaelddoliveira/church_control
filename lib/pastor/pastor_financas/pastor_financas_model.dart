import '/flutter_flow/flutter_flow_util.dart';
import '/pastor/menu_pastor/menu_pastor_widget.dart';
import 'pastor_financas_widget.dart' show PastorFinancasWidget;
import 'package:flutter/material.dart';

class PastorFinancasModel extends FlutterFlowModel<PastorFinancasWidget> {
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
