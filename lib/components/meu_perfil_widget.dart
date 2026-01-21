import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'meu_perfil_model.dart';
export 'meu_perfil_model.dart';

class MeuPerfilWidget extends StatefulWidget {
  const MeuPerfilWidget({super.key});

  @override
  State<MeuPerfilWidget> createState() => _MeuPerfilWidgetState();
}

class _MeuPerfilWidgetState extends State<MeuPerfilWidget> {
  late MeuPerfilModel _model;
  bool _isUploading = false;
  String? _fotoUrlAtualizada;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MeuPerfilModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  Future<void> _uploadFotoPerfil(MembrosRow membro) async {
    final ImagePicker picker = ImagePicker();

    // Mostrar opcoes de camera ou galeria
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            SizedBox(height: 24.0),
            Text(
              'Escolher foto',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                _buildSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Galeria',
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isUploading = true);

      final bytes = await image.readAsBytes();
      final fileName = 'perfil_${membro.idMembro}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final selectedFile = SelectedFile(
        storagePath: fileName,
        filePath: image.path,
        bytes: bytes,
      );

      final publicUrl = await uploadSupabaseStorageFile(
        bucketName: 'fotos_perfil',
        selectedFile: selectedFile,
      );

      // Atualizar o membro com a nova URL da foto
      await MembrosTable().update(
        data: {'fotoUrl': publicUrl},
        matchingRows: (rows) => rows.eq('id_membro', membro.idMembro),
      );

      setState(() {
        _isUploading = false;
        _fotoUrlAtualizada = publicUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Foto atualizada com sucesso!'),
          backgroundColor: FlutterFlowTheme.of(context).success,
        ),
      );
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64.0,
            height: 64.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: FlutterFlowTheme.of(context).primary,
              size: 28.0,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Container(
          width: 380.0,
          decoration: BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(
              color: Color(0xFF2A2A2A),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20.0,
                spreadRadius: 5.0,
              ),
            ],
          ),
          child: FutureBuilder<List<MembrosRow>>(
            future: MembrosTable().querySingleRow(
              queryFn: (q) => q.eqOrNull('id_auth', currentUserUid),
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Padding(
                  padding: EdgeInsets.all(48.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                );
              }

              final membro = snapshot.data!.isNotEmpty ? snapshot.data!.first : null;
              final fotoUrl = _fotoUrlAtualizada ?? membro?.fotoUrl;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.0, 20.0, 16.0, 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Meu Perfil',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(20.0),
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.close_rounded,
                                color: Color(0xFF666666),
                                size: 24.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.0),

                  // Foto de Perfil
                  Stack(
                    children: [
                      Container(
                        width: 120.0,
                        height: 120.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              FlutterFlowTheme.of(context).primary,
                              FlutterFlowTheme.of(context).secondary,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                              blurRadius: 15.0,
                              spreadRadius: 2.0,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(3.0),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1A1A1A),
                          ),
                          padding: EdgeInsets.all(3.0),
                          child: _isUploading
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    FlutterFlowTheme.of(context).primary,
                                  ),
                                  strokeWidth: 2.0,
                                ),
                              )
                            : ClipOval(
                                child: fotoUrl != null && fotoUrl.isNotEmpty
                                  ? Image.network(
                                      fotoUrl,
                                      width: 114.0,
                                      height: 114.0,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildDefaultAvatar(membro?.nomeMembro ?? 'U');
                                      },
                                    )
                                  : _buildDefaultAvatar(membro?.nomeMembro ?? 'U'),
                              ),
                        ),
                      ),
                      // Botao de editar foto
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: membro != null ? () => _uploadFotoPerfil(membro) : null,
                          child: Container(
                            width: 36.0,
                            height: 36.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFF1A1A1A),
                                width: 3.0,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.0),

                  // Nome
                  Text(
                    membro?.nomeMembro ?? 'Usuario',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 4.0),

                  // Email
                  Text(
                    membro?.email ?? 'email@exemplo.com',
                    style: GoogleFonts.inter(
                      color: Color(0xFF999999),
                      fontSize: 14.0,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 32.0),

                  // Informacoes
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        _buildInfoTile(
                          icon: Icons.person_rounded,
                          label: 'Nome completo',
                          value: membro?.nomeMembro ?? 'Nao informado',
                        ),
                        SizedBox(height: 12.0),
                        _buildInfoTile(
                          icon: Icons.email_rounded,
                          label: 'Email',
                          value: membro?.email ?? 'Nao informado',
                        ),
                        if (membro?.dataNascimento != null) ...[
                          SizedBox(height: 12.0),
                          _buildInfoTile(
                            icon: Icons.cake_rounded,
                            label: 'Data de nascimento',
                            value: dateTimeFormat('dd/MM/yyyy', membro!.dataNascimento!),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 32.0),

                  // Botao Desconectar
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: FFButtonWidget(
                        onPressed: () async {
                          GoRouter.of(context).prepareAuthEvent();
                          await authManager.signOut();
                          GoRouter.of(context).clearRedirectLocation();
                          context.goNamedAuth(LoginTesteWidget.routeName, context.mounted);
                        },
                        text: 'Desconectar',
                        icon: Icon(
                          Icons.logout_rounded,
                          size: 20.0,
                        ),
                        options: FFButtonOptions(
                          height: 52.0,
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          color: Color(0xFFF44336).withOpacity(0.1),
                          textStyle: GoogleFonts.inter(
                            color: Color(0xFFF44336),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: 0.0,
                          borderSide: BorderSide(
                            color: Color(0xFFF44336).withOpacity(0.3),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initials = name.isNotEmpty
      ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
      : 'U';

    return Container(
      width: 114.0,
      height: 114.0,
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFF242424),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Color(0xFF2A2A2A),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(
              icon,
              color: FlutterFlowTheme.of(context).primary,
              size: 20.0,
            ),
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: Color(0xFF666666),
                    fontSize: 12.0,
                  ),
                ),
                SizedBox(height: 2.0),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
