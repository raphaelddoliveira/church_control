import '/flutter_flow/flutter_flow_util.dart';
import '/pastor/menu_pastor/menu_pastor_widget.dart';
import 'homepage_pastor_widget.dart' show HomepagePastorWidget;
import 'package:flutter/material.dart';

class HomepagePastorModel extends FlutterFlowModel<HomepagePastorWidget> {
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
