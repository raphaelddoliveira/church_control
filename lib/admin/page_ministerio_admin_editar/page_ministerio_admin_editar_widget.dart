import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_ministerio_admin_editar_model.dart';
export 'page_ministerio_admin_editar_model.dart';

class PageMinisterioAdminEditarWidget extends StatefulWidget {
  const PageMinisterioAdminEditarWidget({
    super.key,
    required this.idministerio,
  });

  final int? idministerio;

  static String routeName = 'PageMinisterio_Admin_Editar';
  static String routePath = '/pageMinisterioAdminEditar';

  @override
  State<PageMinisterioAdminEditarWidget> createState() =>
      _PageMinisterioAdminEditarWidgetState();
}

class _PageMinisterioAdminEditarWidgetState
    extends State<PageMinisterioAdminEditarWidget> {
  MinisterioRow? _ministerio;
  List<MembrosRow> _membrosLideres = [];
  String? _selectedLider;
  FormFieldController<String>? _dropDownController;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final ministerioRows = await MinisterioTable().querySingleRow(
        queryFn: (q) => q.eqOrNull('id_ministerio', widget.idministerio),
      );

      MinisterioRow? ministerio;
      if (ministerioRows.isNotEmpty) {
        ministerio = ministerioRows.first;
      }

      final membros = await MembrosTable().queryRows(
        queryFn: (q) => q.eqOrNull('id_nivel_acesso', 6),
      );

      setState(() {
        _ministerio = ministerio;
        _membrosLideres = membros;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _salvarEdicao() async {
    setState(() => _isSaving = true);

    try {
      await MinisterioTable().update(
        data: {
          'id_lider': _selectedLider,
        },
        matchingRows: (rows) => rows.eqOrNull(
          'id_ministerio',
          widget.idministerio,
        ),
      );

      Navigator.of(context).pop(true); // return true to indicate success
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar alteracoes'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                                    color: Color(0xFFEE8B60).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Icon(
                                    Icons.edit_rounded,
                                    color: Color(0xFFEE8B60),
                                    size: 24.0,
                                  ),
                                ),
                                SizedBox(width: 14.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Editar Ministerio',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Alterar lider do ministerio',
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

                            // Nome (read-only info)
                            Text(
                              'Ministerio',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                              decoration: BoxDecoration(
                                color: Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.church_rounded,
                                    color: Color(0xFF666666),
                                    size: 18.0,
                                  ),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: Text(
                                      _ministerio?.nomeMinisterio ?? '',
                                      style: GoogleFonts.inter(
                                        color: Color(0xFF999999),
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.lock_rounded,
                                    color: Color(0xFF555555),
                                    size: 16.0,
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 20.0),

                            // Lider
                            Text(
                              'Novo Lider',
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

                            SizedBox(height: 28.0),

                            // Botoes
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: _isSaving ? null : _salvarEdicao,
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 14.0),
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).primary,
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: Center(
                                        child: _isSaving
                                            ? SizedBox(
                                                width: 20.0,
                                                height: 20.0,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.0,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              )
                                            : Text(
                                                'Salvar Alteracoes',
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
