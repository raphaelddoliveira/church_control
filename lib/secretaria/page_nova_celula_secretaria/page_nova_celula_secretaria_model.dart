import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/secretaria/menu_secretaria/menu_secretaria_widget.dart';
import 'page_nova_celula_secretaria_widget.dart' show PageNovaCelulaSecretariaWidget;
import 'package:flutter/material.dart';

class PageNovaCelulaSecretariaModel
    extends FlutterFlowModel<PageNovaCelulaSecretariaWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();

  // Model for MenuSecretaria component.
  late MenuSecretariaModel menuSecretariaModel;

  // State field(s) for nomeCelula widget.
  FocusNode? nomeCelulaFocusNode;
  TextEditingController? nomeCelulaTextController;
  String? Function(BuildContext, String?)? nomeCelulaTextControllerValidator;

  // State field(s) for liderDropDown widget.
  String? liderDropDownValue;
  FormFieldController<String>? liderDropDownValueController;

  @override
  void initState(BuildContext context) {
    menuSecretariaModel = createModel(context, () => MenuSecretariaModel());

    nomeCelulaTextControllerValidator = (context, val) {
      if (val == null || val.isEmpty) {
        return 'Nome da célula é obrigatório';
      }
      return null;
    };
  }

  @override
  void dispose() {
    menuSecretariaModel.dispose();
    nomeCelulaFocusNode?.dispose();
    nomeCelulaTextController?.dispose();
  }
}
