import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/backend/supabase/storage/storage.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/lider/menu_lider/menu_lider_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_cria_escala_lider_model.dart';
export 'page_cria_escala_lider_model.dart';

class PageCriaEscalaLiderWidget extends StatefulWidget {
  const PageCriaEscalaLiderWidget({
    super.key,
    required this.idministerio,
  });

  final int? idministerio;

  static String routeName = 'PageCriaEscala_Lider';
  static String routePath = '/pageMinisterios_SecretariaCopy';

  @override
  State<PageCriaEscalaLiderWidget> createState() =>
      _PageCriaEscalaLiderWidgetState();
}

class _PageCriaEscalaLiderWidgetState extends State<PageCriaEscalaLiderWidget> {
  late PageCriaEscalaLiderModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  MinisterioRow? _ministerio;
  bool _isLoading = true;
  bool _isSaving = false;
  DateTime? _dataSelecionada;
  TimeOfDay? _horaSelecionada;
  List<SelectedFile> _arquivosSelecionados = [];
  bool _isUploadingFiles = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageCriaEscalaLiderModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textFieldDataTextController ??= TextEditingController();
    _model.textFieldDataFocusNode ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textFieldArquivosTextController ??= TextEditingController();
    _model.textFieldArquivosFocusNode ??= FocusNode();

    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      if (widget.idministerio != null) {
        final ministerioRows = await MinisterioTable().queryRows(
          queryFn: (q) => q.eq('id_ministerio', widget.idministerio!),
        );
        if (ministerioRows.isNotEmpty) {
          setState(() {
            _ministerio = ministerioRows.first;
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: FlutterFlowTheme.of(context).primary,
              surface: Color(0xFF2A2A2A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (data != null) {
      setState(() {
        _dataSelecionada = data;
        _model.textFieldDataTextController?.text =
            dateTimeFormat('d/M/y', data);
      });

      // Selecionar hora após a data
      final hora = await showTimePicker(
        context: context,
        initialTime: _horaSelecionada ?? TimeOfDay(hour: 19, minute: 0),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: FlutterFlowTheme.of(context).primary,
                surface: Color(0xFF2A2A2A),
              ),
            ),
            child: child!,
          );
        },
      );

      if (hora != null) {
        setState(() {
          _horaSelecionada = hora;
          _model.textFieldDataTextController?.text =
              '${dateTimeFormat('d/M/y', data)} às ${hora.format(context)}';
        });
      }
    }
  }

  Future<void> _selecionarArquivos() async {
    final arquivos = await selectFiles(
      storageFolderPath: 'escalas',
      multiFile: true,
    );
    if (arquivos != null && arquivos.isNotEmpty) {
      setState(() {
        _arquivosSelecionados.addAll(arquivos);
      });
    }
  }

  void _removerArquivo(int index) {
    setState(() {
      _arquivosSelecionados.removeAt(index);
    });
  }

  Future<void> _criarEscala() async {
    if (_model.textController1?.text.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Digite o título da escala'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_dataSelecionada == null || _horaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecione a data e hora da escala'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Buscar id_membro do usuário logado
      final membroRows = await MembrosTable().queryRows(
        queryFn: (q) => q.eq('id_auth', currentUserUid),
      );

      if (membroRows.isEmpty) {
        throw Exception('Membro não encontrado para o usuário logado');
      }

      final idMembroResponsavel = membroRows.first.idMembro;

      // Combinar data e hora
      final dataHora = DateTime(
        _dataSelecionada!.year,
        _dataSelecionada!.month,
        _dataSelecionada!.day,
        _horaSelecionada!.hour,
        _horaSelecionada!.minute,
      );

      // Upload de arquivos (se houver)
      List<String> urlsArquivos = [];
      if (_arquivosSelecionados.isNotEmpty) {
        setState(() => _isUploadingFiles = true);
        try {
          urlsArquivos = await uploadSupabaseStorageFiles(
            bucketName: 'escalas',
            selectedFiles: _arquivosSelecionados,
          );
        } catch (e) {
          print('Erro ao fazer upload de arquivos: $e');
        }
      }

      // Criar escala
      final novaEscala = await EscalasTable().insert({
        'id_ministerio': widget.idministerio,
        'nome_escala': _model.textController1!.text,
        'data_hora_escala': dataHora.toIso8601String(),
        'descricao': _model.textController3?.text.isNotEmpty == true
            ? _model.textController3!.text
            : null,
        'id_responsavel': idMembroResponsavel,
        if (urlsArquivos.isNotEmpty) 'arquivos': urlsArquivos,
      });

      // Navegar para página de detalhes
      context.pushNamed(
        PageEscalaDetalhesLiderWidget.routeName,
        queryParameters: {
          'idministerio': serializeParam(widget.idministerio, ParamType.int),
          'idescala': serializeParam(novaEscala.idEscala, ParamType.int),
        }.withoutNulls,
      );
    } catch (e) {
      print('Erro ao criar escala: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar escala'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
        _isUploadingFiles = false;
      });
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF14181B),
        body: Container(
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: MediaQuery.sizeOf(context).height * 1.0,
          decoration: BoxDecoration(
            color: Color(0xFF14181B),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Menu lateral
              if (responsiveVisibility(
                context: context,
                phone: false,
                tablet: false,
                tabletLandscape: false,
              ))
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 0.0, 16.0),
                  child: Container(
                    width: 250.0,
                    height: MediaQuery.sizeOf(context).height * 1.0,
                    decoration: BoxDecoration(
                      color: Color(0xFF3C3D3E),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: wrapWithModel(
                      model: _model.menuLiderModel,
                      updateCallback: () => safeSetState(() {}),
                      child: MenuLiderWidget(),
                    ),
                  ),
                ),

              // Conteúdo principal
              Expanded(
                child: Builder(
                  builder: (context) {
                    final isMobile = MediaQuery.sizeOf(context).width < 600;
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        16.0,
                        16.0 + (isMobile ? MediaQuery.of(context).padding.top : 0),
                        16.0,
                        16.0,
                      ),
                      child: Container(
                        width: 100.0,
                        height: MediaQuery.sizeOf(context).height * 1.0,
                        decoration: BoxDecoration(
                          color: Color(0xFF3C3D3E),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header com botão voltar
                                Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Row(
                                    children: [
                                      FlutterFlowIconButton(
                                        borderColor: Colors.transparent,
                                        borderRadius: 12.0,
                                        buttonSize: 48.0,
                                        fillColor: Color(0xFF2A2A2A),
                                        icon: Icon(
                                          Icons.arrow_back_rounded,
                                          color: Colors.white,
                                          size: 24.0,
                                        ),
                                        onPressed: () {
                                          context.safePop();
                                        },
                                      ),
                                      SizedBox(width: 16.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Criar Nova Escala',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 28.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4.0),
                                            Text(
                                              _ministerio?.nomeMinisterio ?? '',
                                              style: GoogleFonts.inter(
                                                color: Color(0xFF999999),
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Formulário
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                                  child: Container(
                                    width: double.infinity,
                                    constraints: BoxConstraints(maxWidth: 600.0),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF2A2A2A),
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(32.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Título da escala
                                          _buildLabel('Título da Escala', isRequired: true),
                                          SizedBox(height: 8.0),
                                          _buildTextField(
                                            controller: _model.textController1,
                                            focusNode: _model.textFieldFocusNode1,
                                            hintText: 'Ex: Culto de Domingo',
                                            icon: Icons.event_rounded,
                                          ),

                                          SizedBox(height: 24.0),

                                          // Data e hora
                                          _buildLabel('Data e Hora', isRequired: true),
                                          SizedBox(height: 8.0),
                                          InkWell(
                                            onTap: _selecionarData,
                                            child: Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.all(16.0),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF3A3A3A),
                                                borderRadius: BorderRadius.circular(12.0),
                                                border: Border.all(
                                                  color: Color(0xFF4A4A4A),
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.calendar_today_rounded,
                                                    color: Color(0xFF666666),
                                                    size: 24.0,
                                                  ),
                                                  SizedBox(width: 12.0),
                                                  Expanded(
                                                    child: Text(
                                                      _model.textFieldDataTextController?.text.isNotEmpty == true
                                                          ? _model.textFieldDataTextController!.text
                                                          : 'Selecione a data e hora',
                                                      style: GoogleFonts.inter(
                                                        color: _model.textFieldDataTextController?.text.isNotEmpty == true
                                                            ? Colors.white
                                                            : Color(0xFF666666),
                                                        fontSize: 16.0,
                                                      ),
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.arrow_drop_down_rounded,
                                                    color: Color(0xFF666666),
                                                    size: 28.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          SizedBox(height: 24.0),

                                          // Observações
                                          _buildLabel('Observações'),
                                          SizedBox(height: 8.0),
                                          _buildTextField(
                                            controller: _model.textController3,
                                            focusNode: _model.textFieldFocusNode2,
                                            hintText: 'Informações adicionais sobre a escala...',
                                            icon: Icons.notes_rounded,
                                            maxLines: 4,
                                          ),

                                          SizedBox(height: 24.0),

                                          // Arquivos
                                          _buildLabel('Arquivos'),
                                          SizedBox(height: 8.0),
                                          InkWell(
                                            onTap: _selecionarArquivos,
                                            borderRadius: BorderRadius.circular(12.0),
                                            child: Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.all(16.0),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF3A3A3A),
                                                borderRadius: BorderRadius.circular(12.0),
                                                border: Border.all(
                                                  color: Color(0xFF4A4A4A),
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.attach_file_rounded,
                                                    color: FlutterFlowTheme.of(context).primary,
                                                    size: 24.0,
                                                  ),
                                                  SizedBox(width: 8.0),
                                                  Text(
                                                    'Adicionar Arquivos',
                                                    style: GoogleFonts.inter(
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      fontSize: 16.0,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          // Lista de arquivos selecionados
                                          if (_arquivosSelecionados.isNotEmpty) ...[
                                            SizedBox(height: 12.0),
                                            ..._arquivosSelecionados.asMap().entries.map((entry) {
                                              final index = entry.key;
                                              final arquivo = entry.value;
                                              return Padding(
                                                padding: EdgeInsets.only(bottom: 8.0),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF3A3A3A),
                                                    borderRadius: BorderRadius.circular(8.0),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.insert_drive_file_rounded,
                                                        color: Color(0xFF999999),
                                                        size: 20.0,
                                                      ),
                                                      SizedBox(width: 10.0),
                                                      Expanded(
                                                        child: Text(
                                                          arquivo.originalFilename,
                                                          style: GoogleFonts.inter(
                                                            color: Colors.white,
                                                            fontSize: 14.0,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () => _removerArquivo(index),
                                                        borderRadius: BorderRadius.circular(4.0),
                                                        child: Padding(
                                                          padding: EdgeInsets.all(4.0),
                                                          child: Icon(
                                                            Icons.close_rounded,
                                                            color: Colors.red,
                                                            size: 18.0,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ],

                                          SizedBox(height: 32.0),

                                          // Botão criar
                                          SizedBox(
                                            width: double.infinity,
                                            child: FFButtonWidget(
                                              onPressed: _isSaving ? null : _criarEscala,
                                              text: _isUploadingFiles
                                                  ? 'Enviando arquivos...'
                                                  : (_isSaving ? 'Criando...' : 'Criar Escala'),
                                              icon: _isSaving
                                                  ? null
                                                  : Icon(
                                                      Icons.check_rounded,
                                                      size: 20.0,
                                                    ),
                                              options: FFButtonOptions(
                                                height: 56.0,
                                                padding: EdgeInsets.symmetric(horizontal: 32.0),
                                                color: FlutterFlowTheme.of(context).primary,
                                                textStyle: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                elevation: 0.0,
                                                borderRadius: BorderRadius.circular(12.0),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 32.0),
                              ],
                            ),
                          ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          text,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: GoogleFonts.inter(
              color: Colors.red,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController? controller,
    required FocusNode? focusNode,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.inter(
          color: Color(0xFF666666),
          fontSize: 16.0,
        ),
        prefixIcon: maxLines == 1
            ? Icon(
                icon,
                color: Color(0xFF666666),
              )
            : null,
        filled: true,
        fillColor: Color(0xFF3A3A3A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Color(0xFF4A4A4A),
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Color(0xFF4A4A4A),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: FlutterFlowTheme.of(context).primary,
            width: 2.0,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: maxLines > 1 ? 16.0 : 0.0,
        ),
      ),
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 16.0,
      ),
    );
  }
}
