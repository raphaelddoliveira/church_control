import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pastor/menu_pastor/menu_pastor_widget.dart';
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_membros_pastor_model.dart';
export 'page_membros_pastor_model.dart';

class PageMembrosPastorWidget extends StatefulWidget {
  const PageMembrosPastorWidget({super.key});

  static String routeName = 'PageMembros_Pastor';
  static String routePath = '/pageMembrosPastor';

  @override
  State<PageMembrosPastorWidget> createState() =>
      _PageMembrosPastorWidgetState();
}

class _PageMembrosPastorWidgetState extends State<PageMembrosPastorWidget> {
  late PageMembrosPastorModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<MembrosRow> _membros = [];
  Map<String, TelefoneRow?> _telefonesCache = {};
  Map<String, EnderecoRow?> _enderecosCache = {};
  Map<String, List<int>> _membrosMinisteriosCache = {};
  bool _isLoading = true;
  int _totalAtivos = 0;
  int _totalInativos = 0;
  int _paginaAtualMembros = 0;
  final int _itensPorPagina = 10;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageMembrosPastorModel());
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    _carregarDados();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    try {
      final membros = await MembrosTable().queryRows(
        queryFn: (q) => q.order('nome_membro'),
      );

      final telefones = await TelefoneTable().queryRows(queryFn: (q) => q);
      final telefonesMap = <String, TelefoneRow?>{
        for (var t in telefones)
          if (t.idMembro != null) t.idMembro!: t
      };

      final enderecos = await EnderecoTable().queryRows(queryFn: (q) => q);
      final enderecosMap = <int, EnderecoRow>{
        for (var e in enderecos) e.idEndereco: e
      };
      final membrosEnderecosMap = <String, EnderecoRow?>{};
      for (var m in membros) {
        if (m.idEndereco != null) {
          membrosEnderecosMap[m.idMembro] = enderecosMap[m.idEndereco];
        }
      }

      final membrosMinisterios = await MembrosMinisteriosTable().queryRows(queryFn: (q) => q);
      final membrosMinisteriosMap = <String, List<int>>{};
      for (var mm in membrosMinisterios) {
        if (mm.idMembro != null && mm.idMinisterio != null) {
          membrosMinisteriosMap.putIfAbsent(mm.idMembro!, () => []);
          membrosMinisteriosMap[mm.idMembro!]!.add(mm.idMinisterio!);
        }
      }

      int ativos = 0;
      int inativos = 0;
      for (var m in membros) {
        if (m.ativo == true) {
          ativos++;
        } else {
          inativos++;
        }
      }

      setState(() {
        _membros = membros;
        _telefonesCache = telefonesMap;
        _enderecosCache = membrosEnderecosMap;
        _membrosMinisteriosCache = membrosMinisteriosMap;
        _totalAtivos = ativos;
        _totalInativos = inativos;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() => _isLoading = false);
    }
  }

  List<MembrosRow> get _membrosFiltrados {
    final query = _model.textController!.text.toLowerCase();

    return _membros.where((membro) {
      if (query.isNotEmpty && !membro.nomeMembro.toLowerCase().contains(query)) {
        return false;
      }

      if (_model.filtroStatus != null) {
        if (_model.filtroStatus == 'ativo' && membro.ativo != true) return false;
        if (_model.filtroStatus == 'inativo' && membro.ativo != false) return false;
      }

      if (_model.filtroBairro != null && _model.filtroBairro!.isNotEmpty) {
        final endereco = _enderecosCache[membro.idMembro];
        if (endereco?.bairro != _model.filtroBairro) return false;
      }

      if (_model.filtroMinisterio != null) {
        final ministerios = _membrosMinisteriosCache[membro.idMembro] ?? [];
        if (!ministerios.contains(_model.filtroMinisterio)) return false;
      }

      return true;
    }).toList();
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
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: Column(
                children: [
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
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setModalState(() {
                                    _model.filtroStatus = null;
                                    _model.filtroBairro = null;
                                    _model.filtroMinisterio = null;
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
                                  setState(() => _paginaAtualMembros = 0);
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

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(
              icon,
              size: 32.0,
              color: color,
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Color(0xFF999999),
              fontSize: 14.0,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembroItem(MembrosRow membro) {
    final telefone = _telefonesCache[membro.idMembro];

    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.pushNamed(
              PageMembrosDetalhesPastorWidget.routeName,
              queryParameters: {
                'idmembro': serializeParam(membro.idMembro, ParamType.String),
                'idendereco': serializeParam(membro.idEndereco, ParamType.int),
              }.withoutNulls,
            );
          },
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
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
                            width: 50.0,
                            height: 50.0,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.person_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 26.0,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.person_rounded,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 26.0,
                        ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              membro.nomeMembro,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
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
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.0),
                      Row(
                        children: [
                          if (telefone?.numeroTelefone != null) ...[
                            Icon(Icons.phone_rounded, color: Color(0xFF666666), size: 14.0),
                            SizedBox(width: 4.0),
                            Text(
                              telefone!.numeroTelefone!,
                              style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 13.0),
                            ),
                            SizedBox(width: 16.0),
                          ],
                          if (membro.email != null && membro.email!.isNotEmpty) ...[
                            Icon(Icons.email_outlined, color: Color(0xFF666666), size: 14.0),
                            SizedBox(width: 4.0),
                            Expanded(
                              child: Text(
                                membro.email!,
                                style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 13.0),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          if (telefone?.numeroTelefone == null && (membro.email == null || membro.email!.isEmpty))
                            Text(
                              'Sem informações de contato',
                              style: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 13.0),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.0),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF666666),
                  size: 24.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        drawer: Drawer(
          backgroundColor: Color(0xFF1A1A1A),
          child: MenuPastorWidget(),
        ),
        body: Container(
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: MediaQuery.sizeOf(context).height * 1.0,
          decoration: BoxDecoration(
            color: Color(0xFF14181B),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
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
                      model: _model.menuPastorModel,
                      updateCallback: () => safeSetState(() {}),
                      child: MenuPastorWidget(),
                    ),
                  ),
                ),

              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
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
                                Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          if (!responsiveVisibility(context: context, phone: false, tablet: false, tabletLandscape: false))
                                            Padding(
                                              padding: EdgeInsets.only(right: 12.0),
                                              child: IconButton(
                                                onPressed: () => scaffoldKey.currentState?.openDrawer(),
                                                icon: Icon(Icons.menu_rounded, color: Colors.white, size: 28.0),
                                              ),
                                            ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Membros',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 32.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 8.0),
                                              Text(
                                                'Visualize os membros da igreja',
                                                style: GoogleFonts.inter(
                                                  color: Color(0xFF999999),
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: Icons.people_rounded,
                                          title: 'Total de Membros',
                                          value: _membros.length.toString(),
                                          color: Color(0xFF2196F3),
                                        ),
                                      ),
                                      SizedBox(width: 24.0),
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: Icons.check_circle_rounded,
                                          title: 'Membros Ativos',
                                          value: _totalAtivos.toString(),
                                          color: Color(0xFF027941),
                                        ),
                                      ),
                                      SizedBox(width: 24.0),
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: Icons.cancel_rounded,
                                          title: 'Membros Inativos',
                                          value: _totalInativos.toString(),
                                          color: Color(0xFFFF9800),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 32.0),

                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _model.textController,
                                          focusNode: _model.textFieldFocusNode,
                                          onChanged: (_) => EasyDebounce.debounce(
                                            '_model.textController',
                                            Duration(milliseconds: 300),
                                            () => safeSetState(() => _paginaAtualMembros = 0),
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Buscar membro por nome...',
                                            hintStyle: GoogleFonts.inter(
                                              color: Color(0xFF666666),
                                              fontSize: 16.0,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.search_rounded,
                                              color: Color(0xFF666666),
                                            ),
                                            filled: true,
                                            fillColor: Color(0xFF2A2A2A),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12.0),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12.0),
                                              borderSide: BorderSide(
                                                color: Color(0xFF3A3A3A),
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
                                              vertical: 16.0,
                                            ),
                                          ),
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12.0),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFF2A2A2A),
                                          borderRadius: BorderRadius.circular(12.0),
                                          border: Border.all(color: Color(0xFF3A3A3A)),
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
                                          padding: EdgeInsets.all(12.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 24.0),

                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Todos os Membros',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 16.0),

                                      if (_membrosFiltrados.isEmpty)
                                        Container(
                                          padding: EdgeInsets.all(48.0),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF2A2A2A),
                                            borderRadius: BorderRadius.circular(16.0),
                                          ),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.people_outline_rounded,
                                                  size: 64.0,
                                                  color: Color(0xFF666666),
                                                ),
                                                SizedBox(height: 16.0),
                                                Text(
                                                  'Nenhum membro encontrado',
                                                  style: GoogleFonts.inter(
                                                    color: Color(0xFF999999),
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      else ...[
                                        Builder(
                                          builder: (context) {
                                            final totalPaginas = (_membrosFiltrados.length / _itensPorPagina).ceil();
                                            if (_paginaAtualMembros >= totalPaginas && totalPaginas > 0) {
                                              _paginaAtualMembros = totalPaginas - 1;
                                            }
                                            final inicio = _paginaAtualMembros * _itensPorPagina;
                                            final fim = (inicio + _itensPorPagina).clamp(0, _membrosFiltrados.length);
                                            final membrosPaginados = _membrosFiltrados.sublist(inicio, fim);

                                            return Column(
                                              children: [
                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  physics: NeverScrollableScrollPhysics(),
                                                  itemCount: membrosPaginados.length,
                                                  itemBuilder: (context, index) {
                                                    return _buildMembroItem(membrosPaginados[index]);
                                                  },
                                                ),
                                                if (totalPaginas > 1) ...[
                                                  SizedBox(height: 16.0),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: List.generate(totalPaginas, (index) {
                                                      final isAtual = index == _paginaAtualMembros;
                                                      return GestureDetector(
                                                        onTap: () => setState(() => _paginaAtualMembros = index),
                                                        child: Container(
                                                          width: 32.0,
                                                          height: 32.0,
                                                          margin: EdgeInsets.symmetric(horizontal: 4.0),
                                                          decoration: BoxDecoration(
                                                            color: isAtual ? FlutterFlowTheme.of(context).primary : Color(0xFF2A2A2A),
                                                            borderRadius: BorderRadius.circular(8.0),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              '${index + 1}',
                                                              style: GoogleFonts.inter(
                                                                color: isAtual ? Colors.white : Color(0xFF999999),
                                                                fontSize: 13.0,
                                                                fontWeight: isAtual ? FontWeight.w600 : FontWeight.normal,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                ],
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                SizedBox(height: 32.0),
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
}
