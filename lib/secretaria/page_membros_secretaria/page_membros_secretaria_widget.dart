import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/secretaria/menu_secretaria/menu_secretaria_widget.dart';
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_saver/file_saver.dart';
import 'page_membros_secretaria_model.dart';
export 'page_membros_secretaria_model.dart';

class PageMembrosSecretariaWidget extends StatefulWidget {
  const PageMembrosSecretariaWidget({super.key});

  static String routeName = 'PageMembros_Secretaria';
  static String routePath = '/pageMembrosSecretaria';

  @override
  State<PageMembrosSecretariaWidget> createState() =>
      _PageMembrosSecretariaWidgetState();
}

class _PageMembrosSecretariaWidgetState
    extends State<PageMembrosSecretariaWidget> {
  late PageMembrosSecretariaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, TelefoneRow?> _telefonesCache = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageMembrosSecretariaModel());
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    _carregarTelefones();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _carregarTelefones() async {
    final telefones = await TelefoneTable().queryRows(queryFn: (q) => q);
    setState(() {
      _telefonesCache = {
        for (var t in telefones)
          if (t.idMembro != null) t.idMembro!: t
      };
    });
  }

  Future<List<Map<String, dynamic>>> _getMembrosComDetalhes() async {
    final membros = await MembrosTable().queryRows(
      queryFn: (q) => q.ilike('nome_membro', '%${_model.textController.text}%'),
    );

    final enderecos = await EnderecoTable().queryRows(queryFn: (q) => q);
    final membrosMinisterios = await MembrosMinisteriosTable().queryRows(queryFn: (q) => q);

    final enderecosMap = {for (var e in enderecos) e.idEndereco: e};
    final membrosMinisteriosMap = <String, List<int>>{};
    for (var mm in membrosMinisterios) {
      if (mm.idMembro != null && mm.idMinisterio != null) {
        membrosMinisteriosMap.putIfAbsent(mm.idMembro!, () => []);
        membrosMinisteriosMap[mm.idMembro!]!.add(mm.idMinisterio!);
      }
    }

    final resultado = <Map<String, dynamic>>[];
    for (var membro in membros) {
      final endereco = membro.idEndereco != null ? enderecosMap[membro.idEndereco!] : null;
      final ministeriosDoMembro = membrosMinisteriosMap[membro.idMembro] ?? [];

      bool passaFiltros = true;

      if (_model.filtroStatus != null) {
        if (_model.filtroStatus == 'ativo' && membro.ativo != true) passaFiltros = false;
        else if (_model.filtroStatus == 'inativo' && membro.ativo != false) passaFiltros = false;
      }

      if (_model.filtroBairro != null && _model.filtroBairro!.isNotEmpty && endereco?.bairro != _model.filtroBairro) {
        passaFiltros = false;
      }

      if (_model.filtroMinisterio != null && !ministeriosDoMembro.contains(_model.filtroMinisterio)) {
        passaFiltros = false;
      }

      if (_model.filtroDataNascimentoInicio != null && membro.dataNascimento != null) {
        if (membro.dataNascimento!.isBefore(_model.filtroDataNascimentoInicio!)) passaFiltros = false;
      }
      if (_model.filtroDataNascimentoFim != null && membro.dataNascimento != null) {
        if (membro.dataNascimento!.isAfter(_model.filtroDataNascimentoFim!)) passaFiltros = false;
      }

      if (passaFiltros) {
        resultado.add({
          'membro': membro,
          'endereco': endereco,
          'ministerios': ministeriosDoMembro,
        });
      }
    }

    return resultado;
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.filter_list_rounded, color: FlutterFlowTheme.of(context).primary, size: 24.0),
                            SizedBox(width: 12.0),
                            Text(
                              'Filtros',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close_rounded, color: Color(0xFF999999)),
                        ),
                      ],
                    ),
                  ),
                  // Filtros
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(20.0),
                      children: [
                        _buildFilterDropdown(
                          'Status',
                          _model.filtroStatus,
                          [
                            DropdownMenuItem(value: null, child: Text('Todos', style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: 'ativo', child: Text('Ativo', style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: 'inativo', child: Text('Inativo', style: TextStyle(color: Colors.white))),
                          ],
                          (value) => setModalState(() => _model.filtroStatus = value),
                        ),
                        SizedBox(height: 16.0),
                        FutureBuilder<List<String>>(
                          future: EnderecoTable().queryRows(queryFn: (q) => q).then(
                            (enderecos) => enderecos.where((e) => e.bairro != null).map((e) => e.bairro!).toSet().toList(),
                          ),
                          builder: (context, snapshot) {
                            final bairros = snapshot.data ?? [];
                            return _buildFilterDropdown(
                              'Bairro',
                              _model.filtroBairro,
                              [
                                DropdownMenuItem(value: null, child: Text('Todos', style: TextStyle(color: Colors.white))),
                                ...bairros.map((b) => DropdownMenuItem(value: b, child: Text(b, style: TextStyle(color: Colors.white)))),
                              ],
                              (value) => setModalState(() => _model.filtroBairro = value),
                            );
                          },
                        ),
                        SizedBox(height: 16.0),
                        FutureBuilder<List<MinisterioRow>>(
                          future: MinisterioTable().queryRows(queryFn: (q) => q),
                          builder: (context, snapshot) {
                            final ministerios = snapshot.data ?? [];
                            return _buildFilterDropdown(
                              'Ministério',
                              _model.filtroMinisterio,
                              [
                                DropdownMenuItem(value: null, child: Text('Todos', style: TextStyle(color: Colors.white))),
                                ...ministerios.map((m) => DropdownMenuItem(value: m.idMinisterio, child: Text(m.nomeMinisterio ?? '', style: TextStyle(color: Colors.white)))),
                              ],
                              (value) => setModalState(() => _model.filtroMinisterio = value),
                            );
                          },
                        ),
                        SizedBox(height: 24.0),
                        // Botões
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setModalState(() {
                                    _model.filtroStatus = null;
                                    _model.filtroBairro = null;
                                    _model.filtroMinisterio = null;
                                    _model.filtroDataNascimentoInicio = null;
                                    _model.filtroDataNascimentoFim = null;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Color(0xFF999999),
                                  side: BorderSide(color: Color(0xFF444444)),
                                  padding: EdgeInsets.symmetric(vertical: 14.0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                ),
                                child: Text('Limpar', style: GoogleFonts.inter(fontSize: 15.0, fontWeight: FontWeight.w500)),
                              ),
                            ),
                            SizedBox(width: 12.0),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {});
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: FlutterFlowTheme.of(context).primary,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 14.0),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                ),
                                child: Text('Aplicar', style: GoogleFonts.inter(fontSize: 15.0, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterDropdown<T>(String label, T? value, List<DropdownMenuItem<T>> items, Function(T?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 13.0, fontWeight: FontWeight.w500)),
        SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF0D0D0D),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Color(0xFF2A2A2A)),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            dropdownColor: Color(0xFF1A1A1A),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            ),
            style: GoogleFonts.inter(color: Colors.white, fontSize: 15.0),
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF666666)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getMembrosComDetalhes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Color(0xFF0D0D0D),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(FlutterFlowTheme.of(context).primary),
              ),
            ),
          );
        }

        final dadosCompletos = snapshot.data!;
        final membros = dadosCompletos.map((d) => d['membro'] as MembrosRow).toList();

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: Color(0xFF0D0D0D),
            drawer: Drawer(
              backgroundColor: Color(0xFF1A1A1A),
              child: MenuSecretariaWidget(),
            ),
            body: Row(
              children: [
                // Menu lateral (desktop)
                if (responsiveVisibility(context: context, phone: false, tablet: false, tabletLandscape: false))
                  Container(
                    width: 250.0,
                    margin: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: wrapWithModel(
                      model: _model.menuSecretariaModel,
                      updateCallback: () => setState(() {}),
                      child: MenuSecretariaWidget(),
                    ),
                  ),
                // Conteúdo principal
                Expanded(
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    if (!responsiveVisibility(context: context, phone: false, tablet: false, tabletLandscape: false))
                                      IconButton(
                                        onPressed: () => scaffoldKey.currentState?.openDrawer(),
                                        icon: Icon(Icons.menu_rounded, color: Colors.white, size: 28.0),
                                      ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Membros',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 28.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${membros.length} membros cadastrados',
                                          style: GoogleFonts.inter(
                                            color: Color(0xFF666666),
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    // Botão Exportar PDF
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final pdfBytes = await functions.exportarMembrosPDF(membros);
                                        await FileSaver.instance.saveFile(
                                          name: 'lista_membros_${DateTime.now().millisecondsSinceEpoch}',
                                          bytes: pdfBytes,
                                          ext: 'pdf',
                                          mimeType: MimeType.pdf,
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('PDF exportado com sucesso!'),
                                            backgroundColor: FlutterFlowTheme.of(context).success,
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.picture_as_pdf_rounded, size: 18.0),
                                      label: Text('Exportar PDF'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: FlutterFlowTheme.of(context).primary,
                                        side: BorderSide(color: FlutterFlowTheme.of(context).primary),
                                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                      ),
                                    ),
                                    SizedBox(width: 12.0),
                                    // Botão Novo Membro
                                    ElevatedButton.icon(
                                      onPressed: () => context.pushNamed(PageMembrosNovoSecretariaWidget.routeName),
                                      icon: Icon(Icons.add_rounded, size: 20.0),
                                      label: Text('Novo Membro'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: FlutterFlowTheme.of(context).primary,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20.0),
                            // Barra de pesquisa e filtro
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1A1A1A),
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(color: Color(0xFF2A2A2A)),
                                    ),
                                    child: TextField(
                                      controller: _model.textController,
                                      focusNode: _model.textFieldFocusNode,
                                      onChanged: (_) => EasyDebounce.debounce(
                                        '_model.textController',
                                        Duration(milliseconds: 500),
                                        () => setState(() {}),
                                      ),
                                      style: GoogleFonts.inter(color: Colors.white, fontSize: 15.0),
                                      decoration: InputDecoration(
                                        hintText: 'Buscar membro por nome...',
                                        hintStyle: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 15.0),
                                        prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF666666), size: 22.0),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.0),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1A1A1A),
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(color: Color(0xFF2A2A2A)),
                                  ),
                                  child: IconButton(
                                    onPressed: _mostrarFiltros,
                                    icon: Icon(
                                      Icons.filter_list_rounded,
                                      color: (_model.filtroStatus != null || _model.filtroBairro != null || _model.filtroMinisterio != null)
                                          ? FlutterFlowTheme.of(context).primary
                                          : Color(0xFF666666),
                                      size: 24.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Lista de membros em cards
                      Expanded(
                        child: membros.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.people_outline_rounded, size: 64.0, color: Color(0xFF444444)),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Nenhum membro encontrado',
                                      style: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 16.0),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                padding: EdgeInsets.all(20.0),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : (MediaQuery.of(context).size.width > 800 ? 3 : (MediaQuery.of(context).size.width > 500 ? 2 : 1)),
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  childAspectRatio: 1.3,
                                ),
                                itemCount: membros.length,
                                itemBuilder: (context, index) {
                                  final membro = membros[index];
                                  final telefone = _telefonesCache[membro.idMembro];

                                  return InkWell(
                                    onTap: () {
                                      context.pushNamed(
                                        PageMembrosDetalhesSecretariaWidget.routeName,
                                        queryParameters: {
                                          'idmembro': serializeParam(membro.idMembro, ParamType.String),
                                          'idendereco': serializeParam(membro.idEndereco, ParamType.int),
                                        }.withoutNulls,
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(16.0),
                                    child: Container(
                                      padding: EdgeInsets.all(20.0),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF1A1A1A),
                                        borderRadius: BorderRadius.circular(16.0),
                                        border: Border.all(color: Color(0xFF2A2A2A)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 50.0,
                                                height: 50.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: membro.fotoUrl != null && membro.fotoUrl!.isNotEmpty
                                                    ? ClipOval(
                                                        child: Image.network(
                                                          membro.fotoUrl!,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (_, __, ___) => Icon(
                                                            Icons.person_rounded,
                                                            color: FlutterFlowTheme.of(context).primary,
                                                            size: 28.0,
                                                          ),
                                                        ),
                                                      )
                                                    : Icon(
                                                        Icons.person_rounded,
                                                        color: FlutterFlowTheme.of(context).primary,
                                                        size: 28.0,
                                                      ),
                                              ),
                                              SizedBox(width: 12.0),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      membro.nomeMembro,
                                                      style: GoogleFonts.inter(
                                                        color: Colors.white,
                                                        fontSize: 15.0,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(height: 4.0),
                                                    Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                                      decoration: BoxDecoration(
                                                        color: membro.ativo == true
                                                            ? Color(0xFF027941).withOpacity(0.2)
                                                            : Color(0xFFFF4444).withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(6.0),
                                                      ),
                                                      child: Text(
                                                        membro.ativo == true ? 'Ativo' : 'Inativo',
                                                        style: GoogleFonts.inter(
                                                          color: membro.ativo == true ? Color(0xFF027941) : Color(0xFFFF4444),
                                                          fontSize: 11.0,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          // Informações
                                          if (telefone?.numeroTelefone != null) ...[
                                            Row(
                                              children: [
                                                Icon(Icons.phone_rounded, color: Color(0xFF666666), size: 16.0),
                                                SizedBox(width: 8.0),
                                                Expanded(
                                                  child: Text(
                                                    telefone!.numeroTelefone!,
                                                    style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 13.0),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8.0),
                                          ],
                                          if (membro.email != null && membro.email!.isNotEmpty) ...[
                                            Row(
                                              children: [
                                                Icon(Icons.email_outlined, color: Color(0xFF666666), size: 16.0),
                                                SizedBox(width: 8.0),
                                                Expanded(
                                                  child: Text(
                                                    membro.email!,
                                                    style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 13.0),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                          if (telefone?.numeroTelefone == null && (membro.email == null || membro.email!.isEmpty))
                                            Row(
                                              children: [
                                                Icon(Icons.info_outline_rounded, color: Color(0xFF444444), size: 16.0),
                                                SizedBox(width: 8.0),
                                                Text(
                                                  'Sem informações de contato',
                                                  style: GoogleFonts.inter(color: Color(0xFF444444), fontSize: 13.0),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
