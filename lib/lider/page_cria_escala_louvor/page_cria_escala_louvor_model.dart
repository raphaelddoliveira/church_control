import '/flutter_flow/flutter_flow_util.dart';
import '/lider/menu_lider/menu_lider_widget.dart';
import 'page_cria_escala_louvor_widget.dart' show PageCriaEscalaLouvorWidget;
import 'package:flutter/material.dart';

class PageCriaEscalaLouvorModel extends FlutterFlowModel<PageCriaEscalaLouvorWidget> {
  // Model for Menu_Lider component
  late MenuLiderModel menuLiderModel;

  // Text controllers
  TextEditingController? nomeEscalaController;
  FocusNode? nomeEscalaFocusNode;

  TextEditingController? dataHoraController;
  FocusNode? dataHoraFocusNode;

  TextEditingController? descricaoController;
  FocusNode? descricaoFocusNode;

  // Musica controllers
  TextEditingController? nomeMusicaController;
  FocusNode? nomeMusicaFocusNode;

  TextEditingController? artistaController;
  FocusNode? artistaFocusNode;

  TextEditingController? youtubeController;
  FocusNode? youtubeFocusNode;

  TextEditingController? cifraController;
  FocusNode? cifraFocusNode;

  @override
  void initState(BuildContext context) {
    menuLiderModel = createModel(context, () => MenuLiderModel());

    nomeEscalaController = TextEditingController();
    nomeEscalaFocusNode = FocusNode();

    dataHoraController = TextEditingController();
    dataHoraFocusNode = FocusNode();

    descricaoController = TextEditingController();
    descricaoFocusNode = FocusNode();

    nomeMusicaController = TextEditingController();
    nomeMusicaFocusNode = FocusNode();

    artistaController = TextEditingController();
    artistaFocusNode = FocusNode();

    youtubeController = TextEditingController();
    youtubeFocusNode = FocusNode();

    cifraController = TextEditingController();
    cifraFocusNode = FocusNode();
  }

  @override
  void dispose() {
    menuLiderModel.dispose();

    nomeEscalaController?.dispose();
    nomeEscalaFocusNode?.dispose();

    dataHoraController?.dispose();
    dataHoraFocusNode?.dispose();

    descricaoController?.dispose();
    descricaoFocusNode?.dispose();

    nomeMusicaController?.dispose();
    nomeMusicaFocusNode?.dispose();

    artistaController?.dispose();
    artistaFocusNode?.dispose();

    youtubeController?.dispose();
    youtubeFocusNode?.dispose();

    cifraController?.dispose();
    cifraFocusNode?.dispose();
  }
}
