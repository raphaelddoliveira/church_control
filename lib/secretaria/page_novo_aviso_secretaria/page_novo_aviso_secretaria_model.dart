import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/secretaria/menu_secretaria/menu_secretaria_widget.dart';
import 'page_novo_aviso_secretaria_widget.dart'
    show PageNovoAvisoSecretariaWidget;
import 'package:flutter/material.dart';

class PageNovoAvisoSecretariaModel
    extends FlutterFlowModel<PageNovoAvisoSecretariaWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for MenuSecretaria component.
  late MenuSecretariaModel menuSecretariaModel;
  // State field(s) for nomeAviso widget.
  FocusNode? nomeAvisoFocusNode;
  TextEditingController? nomeAvisoTextController;
  String? Function(BuildContext, String?)? nomeAvisoTextControllerValidator;
  // State field(s) for categoria widget.
  String? categoriaValue;
  FormFieldController<String>? categoriaValueController;
  // State field(s) for dataHoraAviso widget.
  FocusNode? dataHoraAvisoFocusNode;
  TextEditingController? dataHoraAvisoTextController;
  String? Function(BuildContext, String?)? dataHoraAvisoTextControllerValidator;
  DateTime? pickedDate;
  // State field(s) for dataExpiracao widget.
  FocusNode? dataExpiracaoFocusNode;
  TextEditingController? dataExpiracaoTextController;
  String? Function(BuildContext, String?)? dataExpiracaoTextControllerValidator;
  DateTime? pickedDateExpiracao;
  // State field(s) for imagem widget.
  String uploadedFileUrl = '';
  // State field(s) for descricaoResumida widget.
  FocusNode? descricaoResumidaFocusNode;
  TextEditingController? descricaoResumidaTextController;
  String? Function(BuildContext, String?)?
      descricaoResumidaTextControllerValidator;
  // State field(s) for descricao widget.
  FocusNode? descricaoFocusNode;
  TextEditingController? descricaoTextController;
  String? Function(BuildContext, String?)? descricaoTextControllerValidator;

  @override
  void initState(BuildContext context) {
    menuSecretariaModel = createModel(context, () => MenuSecretariaModel());
  }

  @override
  void dispose() {
    menuSecretariaModel.dispose();
    nomeAvisoFocusNode?.dispose();
    nomeAvisoTextController?.dispose();

    dataHoraAvisoFocusNode?.dispose();
    dataHoraAvisoTextController?.dispose();

    dataExpiracaoFocusNode?.dispose();
    dataExpiracaoTextController?.dispose();

    descricaoResumidaFocusNode?.dispose();
    descricaoResumidaTextController?.dispose();

    descricaoFocusNode?.dispose();
    descricaoTextController?.dispose();
  }
}
