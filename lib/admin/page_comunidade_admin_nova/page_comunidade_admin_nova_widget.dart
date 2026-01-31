import 'dart:typed_data';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/upload_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_comunidade_admin_nova_model.dart';
export 'page_comunidade_admin_nova_model.dart';

class PageComunidadeAdminNovaWidget extends StatefulWidget {
  const PageComunidadeAdminNovaWidget({super.key});

  static String routeName = 'PageComunidade_Admin_Nova';
  static String routePath = '/pageComunidadeAdminNova';

  @override
  State<PageComunidadeAdminNovaWidget> createState() =>
      _PageComunidadeAdminNovaWidgetState();
}

class _PageComunidadeAdminNovaWidgetState
    extends State<PageComunidadeAdminNovaWidget> {
  final _nomeController = TextEditingController();
  final _nomeFocusNode = FocusNode();
  final _descricaoController = TextEditingController();
  final _descricaoFocusNode = FocusNode();

  List<MembrosRow> _membrosLideres = [];
  String? _selectedLider;
  FormFieldController<String>? _dropDownController;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploading = false;

  // Variáveis para upload de imagem
  Uint8List? _imagemBytes;
  String? _imagemNome;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final membros = await MembrosTable().queryRows(
        queryFn: (q) => q.order('nome_membro'),
      );
      setState(() {
        _membrosLideres = membros;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selecionarImagem() async {
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      allowPhoto: true,
      allowVideo: false,
      backgroundColor: Color(0xFF2A2A2A),
      textColor: Colors.white,
      pickerFontFamily: 'Inter',
    );

    if (selectedMedia != null && selectedMedia.isNotEmpty) {
      setState(() {
        _imagemBytes = selectedMedia.first.bytes;
        _imagemNome = selectedMedia.first.originalFilename;
      });
    }
  }

  void _removerImagem() {
    setState(() {
      _imagemBytes = null;
      _imagemNome = null;
    });
  }

  Future<void> _salvarComunidade() async {
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Informe o nome da comunidade'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? fotoUrl;

      // Upload da imagem se houver
      if (_imagemBytes != null) {
        setState(() => _isUploading = true);

        final timestamp = DateTime.now().microsecondsSinceEpoch;
        final ext = _imagemNome?.split('.').last ?? 'jpg';
        final storagePath = 'comunidades/$timestamp.$ext';

        final selectedFile = SelectedFile(
          storagePath: storagePath,
          bytes: _imagemBytes!,
          originalFilename: _imagemNome ?? 'imagem.jpg',
        );

        fotoUrl = await uploadSupabaseStorageFile(
          bucketName: 'arquivos',
          selectedFile: selectedFile,
        );

        setState(() => _isUploading = false);
      }

      await ComunidadeTable().insert({
        'nome_comunidade': _nomeController.text.trim(),
        'descricao_comunidade': _descricaoController.text.trim().isNotEmpty
            ? _descricaoController.text.trim()
            : null,
        'lider_comunidade': _selectedLider,
        'foto_url': fotoUrl,
      });

      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _isSaving = false;
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar comunidade'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _nomeFocusNode.dispose();
    _descricaoController.dispose();
    _descricaoFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black54,
        child: GestureDetector(
          onTap: () {},
          child: Center(
            child: Container(
              width: 520,
              margin: EdgeInsets.symmetric(horizontal: 24.0),
              decoration: BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: _isLoading
                  ? Container(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(28.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF4CAF50).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Icon(
                                    Icons.groups_rounded,
                                    color: Color(0xFF4CAF50),
                                    size: 24.0,
                                  ),
                                ),
                                SizedBox(width: 14.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nova Comunidade',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Criar uma nova comunidade na igreja',
                                        style: GoogleFonts.inter(
                                          color: Color(0xFF999999),
                                          fontSize: 13.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => Navigator.of(context).pop(),
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Container(
                                    padding: EdgeInsets.all(6.0),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF3A3A3A),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: Color(0xFF999999),
                                      size: 18.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 24.0),
                            Divider(color: Color(0xFF3A3A3A), height: 1),
                            SizedBox(height: 24.0),

                            // Nome da Comunidade
                            Text(
                              'Nome da Comunidade',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            TextFormField(
                              controller: _nomeController,
                              focusNode: _nomeFocusNode,
                              autofocus: false,
                              decoration: InputDecoration(
                                hintText: 'Ex: Comunidade Jovem',
                                hintStyle: GoogleFonts.inter(
                                  color: Color(0xFF666666),
                                  fontSize: 14.0,
                                ),
                                filled: true,
                                fillColor: Color(0xFF1E1E1E),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).primary,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                              ),
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                            ),

                            SizedBox(height: 20.0),

                            // Descricao
                            Text(
                              'Descricao (opcional)',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            TextFormField(
                              controller: _descricaoController,
                              focusNode: _descricaoFocusNode,
                              autofocus: false,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Descreva a comunidade...',
                                hintStyle: GoogleFonts.inter(
                                  color: Color(0xFF666666),
                                  fontSize: 14.0,
                                ),
                                filled: true,
                                fillColor: Color(0xFF1E1E1E),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).primary,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                              ),
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                            ),

                            SizedBox(height: 20.0),

                            // Lider
                            Text(
                              'Lider da Comunidade',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            FlutterFlowDropDown<String>(
                              controller: _dropDownController ??=
                                  FormFieldController<String>(_selectedLider ?? ''),
                              options: List<String>.from(
                                  _membrosLideres.map((e) => e.idMembro).toList()),
                              optionLabels:
                                  _membrosLideres.map((e) => e.nomeMembro).toList(),
                              onChanged: (val) => setState(() => _selectedLider = val),
                              width: double.infinity,
                              height: 48.0,
                              textStyle: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                              hintText: 'Selecione um lider...',
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF999999),
                                size: 24.0,
                              ),
                              fillColor: Color(0xFF1E1E1E),
                              elevation: 2.0,
                              borderColor: Colors.transparent,
                              borderWidth: 0.0,
                              borderRadius: 10.0,
                              margin: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                              hidesUnderline: true,
                              isOverButton: false,
                              isSearchable: false,
                              isMultiSelect: false,
                            ),

                            SizedBox(height: 20.0),

                            // Upload de Foto
                            Text(
                              'Foto da Comunidade (opcional)',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.0),

                            // Área de upload
                            InkWell(
                              onTap: _imagemBytes == null ? _selecionarImagem : null,
                              borderRadius: BorderRadius.circular(10.0),
                              child: Container(
                                width: double.infinity,
                                height: _imagemBytes != null ? 180.0 : 120.0,
                                decoration: BoxDecoration(
                                  color: Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: Color(0xFF3A3A3A),
                                    width: 1.0,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: _imagemBytes != null
                                    ? Stack(
                                        children: [
                                          // Preview da imagem
                                          Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF1E1E1E),
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10.0),
                                              child: Image.memory(
                                                _imagemBytes!,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                          // Botões de ação
                                          Positioned(
                                            top: 8.0,
                                            right: 8.0,
                                            child: Row(
                                              children: [
                                                // Botão trocar
                                                InkWell(
                                                  onTap: _selecionarImagem,
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  child: Container(
                                                    padding: EdgeInsets.all(8.0),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF4CAF50),
                                                      borderRadius: BorderRadius.circular(8.0),
                                                    ),
                                                    child: Icon(
                                                      Icons.edit_rounded,
                                                      color: Colors.white,
                                                      size: 18.0,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8.0),
                                                // Botão remover
                                                InkWell(
                                                  onTap: _removerImagem,
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  child: Container(
                                                    padding: EdgeInsets.all(8.0),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius: BorderRadius.circular(8.0),
                                                    ),
                                                    child: Icon(
                                                      Icons.delete_rounded,
                                                      color: Colors.white,
                                                      size: 18.0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Nome do arquivo
                                          Positioned(
                                            bottom: 8.0,
                                            left: 8.0,
                                            right: 8.0,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.6),
                                                borderRadius: BorderRadius.circular(6.0),
                                              ),
                                              child: Text(
                                                _imagemNome ?? 'imagem.jpg',
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 12.0,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.cloud_upload_outlined,
                                            color: Color(0xFF666666),
                                            size: 40.0,
                                          ),
                                          SizedBox(height: 12.0),
                                          Text(
                                            'Clique para selecionar uma imagem',
                                            style: GoogleFonts.inter(
                                              color: Color(0xFF666666),
                                              fontSize: 14.0,
                                            ),
                                          ),
                                          SizedBox(height: 4.0),
                                          Text(
                                            'PNG, JPG ou GIF',
                                            style: GoogleFonts.inter(
                                              color: Color(0xFF555555),
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            SizedBox(height: 28.0),

                            // Botoes
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: _isSaving ? null : _salvarComunidade,
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 14.0),
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).primary,
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: Center(
                                        child: _isSaving
                                            ? Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 20.0,
                                                    height: 20.0,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2.0,
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10.0),
                                                  Text(
                                                    _isUploading ? 'Enviando imagem...' : 'Salvando...',
                                                    style: GoogleFonts.inter(
                                                      color: Colors.white,
                                                      fontSize: 14.0,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Text(
                                                'Criar Comunidade',
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.0),
                                InkWell(
                                  onTap: () => Navigator.of(context).pop(),
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF3A3A3A),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Text(
                                      'Cancelar',
                                      style: GoogleFonts.inter(
                                        color: Color(0xFF999999),
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
