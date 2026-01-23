import 'dart:typed_data';
import '/pastor/menu_pastor/menu_pastor_widget.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/backend/supabase/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_devocional_pastor_novo_model.dart';
export 'page_devocional_pastor_novo_model.dart';

class PageDevocionalPastorNovoWidget extends StatefulWidget {
  const PageDevocionalPastorNovoWidget({super.key});

  static String routeName = 'PageDevocional_Pastor_Novo';
  static String routePath = '/pageDevocionalPastorNovo';

  @override
  State<PageDevocionalPastorNovoWidget> createState() =>
      _PageDevocionalPastorNovoWidgetState();
}

class _PageDevocionalPastorNovoWidgetState
    extends State<PageDevocionalPastorNovoWidget> {
  late PageDevocionalPastorNovoModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final _tituloController = TextEditingController();
  final _textoController = TextEditingController();
  final _linkMusicaController = TextEditingController();
  String _status = 'rascunho';
  bool _isSaving = false;

  // Image picker state
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageDevocionalPastorNovoModel());
  }

  @override
  void dispose() {
    _model.dispose();
    _tituloController.dispose();
    _textoController.dispose();
    _linkMusicaController.dispose();
    super.dispose();
  }

  Future<void> _selecionarImagem() async {
    final selectedMedia = await selectMedia(
      mediaSource: MediaSource.photoGallery,
      multiImage: false,
    );

    if (selectedMedia != null && selectedMedia.isNotEmpty) {
      setState(() {
        _selectedImageBytes = selectedMedia.first.bytes;
        _selectedImageName = selectedMedia.first.originalFilename;
      });
    }
  }

  Future<void> _salvar() async {
    if (_tituloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Informe o titulo do devocional'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_textoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Informe o texto do devocional'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Buscar id_membro do usuario logado
      final membros = await MembrosTable().queryRows(
        queryFn: (q) => q.eqOrNull('id_auth', currentUserUid),
      );

      if (membros.isEmpty) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Membro nao encontrado'), backgroundColor: Colors.red),
        );
        return;
      }

      final idMembro = membros.first.idMembro;

      // Upload imagem se selecionada
      String? imagemUrl;
      if (_selectedImageBytes != null) {
        final selectedFile = SelectedFile(
          storagePath: 'devocionais/${DateTime.now().microsecondsSinceEpoch}_${_selectedImageName ?? 'imagem.png'}',
          bytes: _selectedImageBytes!,
        );

        imagemUrl = await uploadSupabaseStorageFile(
          bucketName: 'arquivos',
          selectedFile: selectedFile,
        );
      }

      await DevocionalTable().insert({
        'titulo': _tituloController.text.trim(),
        'texto_devocional': _textoController.text.trim(),
        'link_música': _linkMusicaController.text.trim().isEmpty
            ? null
            : _linkMusicaController.text.trim(),
        'imagem': imagemUrl,
        'status': _status,
        'criado_por': idMembro,
      });

      setState(() => _isSaving = false);

      await showDialog(
        context: context,
        builder: (alertDialogContext) {
          return AlertDialog(
            backgroundColor: Color(0xFF2A2A2A),
            title: Text('Sucesso!', style: TextStyle(color: Colors.white)),
            content: Text(
              'Devocional criado com sucesso.',
              style: TextStyle(color: Color(0xFF999999)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(alertDialogContext),
                child: Text('Ok', style: TextStyle(color: FlutterFlowTheme.of(context).primary)),
              ),
            ],
          );
        },
      );

      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar devocional'), backgroundColor: Colors.red),
      );
    }
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
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          decoration: BoxDecoration(color: Color(0xFF14181B)),
          child: Row(
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
                    height: MediaQuery.sizeOf(context).height,
                    decoration: BoxDecoration(
                      color: Color(0xFF3C3D3E),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: wrapWithModel(
                      model: _model.menuPastorModel,
                      updateCallback: () => setState(() {}),
                      child: MenuPastorWidget(),
                    ),
                  ),
                ),

              // Conteudo principal
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    height: MediaQuery.sizeOf(context).height,
                    decoration: BoxDecoration(
                      color: Color(0xFF3C3D3E),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              InkWell(
                                onTap: () => Navigator.of(context).pop(),
                                borderRadius: BorderRadius.circular(10.0),
                                child: Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF2A2A2A),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22.0),
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Novo Devocional',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 28.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    'Crie um novo devocional para publicar',
                                    style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 15.0),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: 32.0),

                          // Formulario
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      child: Icon(Icons.edit_rounded, color: FlutterFlowTheme.of(context).primary, size: 22.0),
                                    ),
                                    SizedBox(width: 14.0),
                                    Text(
                                      'Conteudo do Devocional',
                                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24.0),

                                // Titulo
                                _buildLabel('Titulo'),
                                SizedBox(height: 8.0),
                                _buildTextField(_tituloController, 'Digite o titulo do devocional...'),

                                SizedBox(height: 20.0),

                                // Texto
                                _buildLabel('Texto do Devocional'),
                                SizedBox(height: 8.0),
                                _buildTextField(_textoController, 'Escreva o conteudo do devocional...', maxLines: 8),

                                SizedBox(height: 20.0),

                                // Link Musica
                                _buildLabel('Link da Musica (opcional)'),
                                SizedBox(height: 4.0),
                                Text(
                                  'Cole o link do YouTube ou Spotify',
                                  style: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 12.0),
                                ),
                                SizedBox(height: 8.0),
                                _buildTextField(_linkMusicaController, 'https://...'),

                                SizedBox(height: 20.0),

                                // Imagem
                                _buildLabel('Imagem de Capa (opcional)'),
                                SizedBox(height: 4.0),
                                Text(
                                  'Selecione uma imagem do seu computador',
                                  style: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 12.0),
                                ),
                                SizedBox(height: 8.0),
                                InkWell(
                                  onTap: _selecionarImagem,
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1E1E1E),
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color: _selectedImageBytes != null
                                            ? FlutterFlowTheme.of(context).primary.withOpacity(0.5)
                                            : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: _selectedImageBytes != null
                                        ? Column(
                                            children: [
                                              Container(
                                                height: 180.0,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF2A2A2A),
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  child: Image.memory(
                                                    _selectedImageBytes!,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 12.0),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.check_circle_rounded, color: FlutterFlowTheme.of(context).primary, size: 18.0),
                                                  SizedBox(width: 8.0),
                                                  Flexible(
                                                    child: Text(
                                                      _selectedImageName ?? 'Imagem selecionada',
                                                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13.0),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  SizedBox(width: 12.0),
                                                  InkWell(
                                                    onTap: () => setState(() {
                                                      _selectedImageBytes = null;
                                                      _selectedImageName = null;
                                                    }),
                                                    child: Icon(Icons.close_rounded, color: Color(0xFFFF4444), size: 18.0),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.image_rounded, color: Color(0xFF666666), size: 24.0),
                                              SizedBox(width: 12.0),
                                              Text(
                                                'Clique para selecionar uma imagem',
                                                style: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 14.0),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),

                                SizedBox(height: 20.0),

                                // Status
                                _buildLabel('Status'),
                                SizedBox(height: 8.0),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1E1E1E),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: _status,
                                    items: [
                                      DropdownMenuItem(value: 'rascunho', child: Text('Rascunho', style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0))),
                                      DropdownMenuItem(value: 'publicado', child: Text('Publicado', style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0))),
                                    ],
                                    onChanged: (val) => setState(() => _status = val ?? 'rascunho'),
                                    dropdownColor: Color(0xFF1E1E1E),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                    ),
                                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF999999), size: 24.0),
                                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 32.0),

                          // Botoes
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: _isSaving ? null : _salvar,
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context).primary,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Center(
                                      child: _isSaving
                                          ? SizedBox(
                                              width: 22.0,
                                              height: 22.0,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.save_rounded, color: Colors.white, size: 20.0),
                                                SizedBox(width: 8.0),
                                                Text('Salvar', style: GoogleFonts.inter(color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.w600)),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.0),
                              InkWell(
                                onTap: () => Navigator.of(context).pop(),
                                borderRadius: BorderRadius.circular(12.0),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF2A2A2A),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Text('Cancelar', style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 15.0, fontWeight: FontWeight.w600)),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 14.0),
        filled: true,
        fillColor: Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
    );
  }
}
