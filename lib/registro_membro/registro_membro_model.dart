import '/flutter_flow/flutter_flow_util.dart';
import 'registro_membro_widget.dart' show RegistroMembroWidget;
import 'package:flutter/material.dart';

class RegistroMembroModel extends FlutterFlowModel<RegistroMembroWidget> {
  // State fields
  final unfocusNode = FocusNode();
  FocusNode? emailFocusNode;
  TextEditingController? emailController;
  String? Function(BuildContext, String?)? emailControllerValidator;

  FocusNode? cpfFocusNode;
  TextEditingController? cpfController;
  String? Function(BuildContext, String?)? cpfControllerValidator;

  FocusNode? senhaFocusNode;
  TextEditingController? senhaController;
  String? Function(BuildContext, String?)? senhaControllerValidator;
  bool senhaVisibility = false;

  FocusNode? confirmSenhaFocusNode;
  TextEditingController? confirmSenhaController;
  String? Function(BuildContext, String?)? confirmSenhaControllerValidator;
  bool confirmSenhaVisibility = false;

  @override
  void initState(BuildContext context) {
    senhaVisibility = false;
    confirmSenhaVisibility = false;
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    emailFocusNode?.dispose();
    emailController?.dispose();
    cpfFocusNode?.dispose();
    cpfController?.dispose();
    senhaFocusNode?.dispose();
    senhaController?.dispose();
    confirmSenhaFocusNode?.dispose();
    confirmSenhaController?.dispose();
  }
}
