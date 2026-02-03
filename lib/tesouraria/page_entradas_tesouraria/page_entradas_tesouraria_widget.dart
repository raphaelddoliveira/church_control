import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/form_field_controller.dart';
import '/tesouraria/menu_tesouraria/menu_tesouraria_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'page_entradas_tesouraria_model.dart';
export 'page_entradas_tesouraria_model.dart';

class PageEntradasTesourariaWidget extends StatefulWidget {
  const PageEntradasTesourariaWidget({super.key});

  static String routeName = 'PageEntradasTesouraria';
  static String routePath = '/pageEntradasTesouraria';

  @override
  State<PageEntradasTesourariaWidget> createState() => _PageEntradasTesourariaWidgetState();
}

class _PageEntradasTesourariaWidgetState extends State<PageEntradasTesourariaWidget> {
  late PageEntradasTesourariaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<EntradaFinanceiraRow> _entradas = [];
  List<MembrosRow> _membros = [];
  bool _isLoading = true;
  String? _filtroTipo;
  DateTime? _filtroDataInicio;
  DateTime? _filtroDataFim;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageEntradasTesourariaModel());
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final entradas = await EntradaFinanceiraTable().queryRows(queryFn: (q) => q);
      final membros = await MembrosTable().queryRows(queryFn: (q) => q);

      entradas.sort((a, b) {
        if (a.dataEntrada == null && b.dataEntrada == null) return 0;
        if (a.dataEntrada == null) return 1;
        if (b.dataEntrada == null) return -1;
        return b.dataEntrada!.compareTo(a.dataEntrada!);
      });

      setState(() {
        _entradas = entradas;
        _membros = membros;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<EntradaFinanceiraRow> get _entradasFiltradas {
    return _entradas.where((entrada) {
      // Filtro por busca
      final query = _model.searchController?.text.toLowerCase() ?? '';
      if (query.isNotEmpty) {
        final descricao = entrada.descricao?.toLowerCase() ?? '';
        final tipo = entrada.tipoEntrada?.toLowerCase() ?? '';
        if (!descricao.contains(query) && !tipo.contains(query)) {
          return false;
        }
      }

      // Filtro por tipo
      if (_filtroTipo != null && _filtroTipo!.isNotEmpty) {
        if (entrada.tipoEntrada?.toLowerCase() != _filtroTipo!.toLowerCase()) {
          return false;
        }
      }

      // Filtro por data
      if (_filtroDataInicio != null && entrada.dataEntrada != null) {
        if (entrada.dataEntrada!.isBefore(_filtroDataInicio!)) return false;
      }
      if (_filtroDataFim != null && entrada.dataEntrada != null) {
        if (entrada.dataEntrada!.isAfter(_filtroDataFim!.add(Duration(days: 1)))) return false;
      }

      return true;
    }).toList();
  }

  double get _totalFiltrado {
    return _entradasFiltradas.fold(0.0, (sum, e) => sum + (e.valorEntrada ?? 0.0));
  }

  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _getNomeMembro(String? idMembro) {
    if (idMembro == null) return '-';
    final membro = _membros.where((m) => m.idMembro == idMembro).firstOrNull;
    return membro?.nomeMembro ?? '-';
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF14181B),
        body: Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          decoration: BoxDecoration(
            color: Color(0xFF14181B),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Menu lateral (desktop)
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
                    child: MenuTesourariaWidget(),
                  ),
                ),
              // Conteúdo principal
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height,
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
                            padding: EdgeInsets.all(32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(),
                                SizedBox(height: 24.0),
                                _buildFiltros(),
                                SizedBox(height: 16.0),
                                _buildResumo(),
                                SizedBox(height: 24.0),
                                _buildListaEntradas(),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entradas',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              'Gerencie os dízimos e ofertas da igreja',
              style: GoogleFonts.inter(
                color: Color(0xFF999999),
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        InkWell(
          onTap: () => _mostrarModalNovaEntrada(),
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 20.0),
                SizedBox(width: 8.0),
                Text(
                  'Nova Entrada',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color(0xFF404040)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _model.searchController,
              focusNode: _model.searchFocusNode,
              onChanged: (_) => EasyDebounce.debounce(
                'search',
                Duration(milliseconds: 300),
                () => setState(() {}),
              ),
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
              decoration: InputDecoration(
                hintText: 'Buscar por descrição...',
                hintStyle: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 14.0),
                prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF666666)),
                filled: true,
                fillColor: Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              ),
            ),
          ),
          SizedBox(width: 16.0),
          Container(
            width: 150,
            child: DropdownButtonFormField<String>(
              value: _filtroTipo,
              decoration: InputDecoration(
                hintText: 'Tipo',
                hintStyle: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 14.0),
                filled: true,
                fillColor: Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              ),
              dropdownColor: Color(0xFF2D2D2D),
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
              items: [
                DropdownMenuItem(value: null, child: Text('Todos')),
                DropdownMenuItem(value: 'Dízimo', child: Text('Dízimo')),
                DropdownMenuItem(value: 'Oferta', child: Text('Oferta')),
              ],
              onChanged: (value) => setState(() => _filtroTipo = value),
            ),
          ),
          SizedBox(width: 16.0),
          InkWell(
            onTap: () => _selecionarPeriodo(),
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: Color(0xFF666666), size: 18.0),
                  SizedBox(width: 8.0),
                  Text(
                    _filtroDataInicio != null
                        ? '${dateTimeFormat('dd/MM', _filtroDataInicio!)} - ${dateTimeFormat('dd/MM', _filtroDataFim ?? _filtroDataInicio!)}'
                        : 'Período',
                    style: GoogleFonts.inter(
                      color: _filtroDataInicio != null ? Colors.white : Color(0xFF666666),
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_filtroTipo != null || _filtroDataInicio != null) ...[
            SizedBox(width: 16.0),
            InkWell(
              onTap: () => setState(() {
                _filtroTipo = null;
                _filtroDataInicio = null;
                _filtroDataFim = null;
              }),
              child: Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Color(0xFFE53935).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(Icons.clear_rounded, color: Color(0xFFE53935), size: 20.0),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResumo() {
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Color(0xFF4CAF50).withOpacity(0.15),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Color(0xFF4CAF50).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(Icons.trending_up_rounded, color: Color(0xFF4CAF50), size: 24.0),
              ),
              SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Filtrado',
                    style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 14.0),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    _formatarMoeda(_totalFiltrado),
                    style: GoogleFonts.poppins(
                      color: Color(0xFF4CAF50),
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            '${_entradasFiltradas.length} registros',
            style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 14.0),
          ),
        ],
      ),
    );
  }

  Widget _buildListaEntradas() {
    if (_entradasFiltradas.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: Column(
            children: [
              Icon(Icons.inbox_rounded, color: Color(0xFF666666), size: 64.0),
              SizedBox(height: 16.0),
              Text(
                'Nenhuma entrada encontrada',
                style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 16.0),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Color(0xFF404040)),
      ),
      child: Column(
        children: [
          // Header da tabela
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('Data', style: _headerStyle())),
                Expanded(flex: 2, child: Text('Tipo', style: _headerStyle())),
                Expanded(flex: 3, child: Text('Descrição', style: _headerStyle())),
                Expanded(flex: 2, child: Text('Membro', style: _headerStyle())),
                Expanded(flex: 2, child: Text('Valor', style: _headerStyle())),
                SizedBox(width: 80),
              ],
            ),
          ),
          // Itens
          ..._entradasFiltradas.map((entrada) => _buildEntradaRow(entrada)).toList(),
        ],
      ),
    );
  }

  TextStyle _headerStyle() {
    return GoogleFonts.inter(
      color: Color(0xFF999999),
      fontSize: 12.0,
      fontWeight: FontWeight.w600,
    );
  }

  Widget _buildEntradaRow(EntradaFinanceiraRow entrada) {
    final isDizimo = entrada.tipoEntrada?.toLowerCase() == 'dízimo' ||
                     entrada.tipoEntrada?.toLowerCase() == 'dizimo';

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF404040), width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              entrada.dataEntrada != null ? dateTimeFormat('dd/MM/yyyy', entrada.dataEntrada!) : '-',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: isDizimo ? Color(0xFF4CAF50).withOpacity(0.15) : Color(0xFF9C27B0).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  entrada.tipoEntrada ?? '-',
                  style: GoogleFonts.inter(
                    color: isDizimo ? Color(0xFF4CAF50) : Color(0xFF9C27B0),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              entrada.descricao ?? '-',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _getNomeMembro(entrada.idMembro),
              style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 14.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatarMoeda(entrada.valorEntrada ?? 0),
              style: GoogleFonts.poppins(
                color: Color(0xFF4CAF50),
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () => _mostrarModalEditarEntrada(entrada),
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Color(0xFF2196F3).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(Icons.edit_rounded, color: Color(0xFF2196F3), size: 16.0),
                  ),
                ),
                SizedBox(width: 8.0),
                InkWell(
                  onTap: () => _confirmarExclusao(entrada),
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFE53935).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(Icons.delete_rounded, color: Color(0xFFE53935), size: 16.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selecionarPeriodo() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: _filtroDataInicio != null
          ? DateTimeRange(start: _filtroDataInicio!, end: _filtroDataFim ?? _filtroDataInicio!)
          : null,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: FlutterFlowTheme.of(context).primary,
              surface: Color(0xFF2D2D2D),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _filtroDataInicio = picked.start;
        _filtroDataFim = picked.end;
      });
    }
  }

  void _mostrarModalNovaEntrada() {
    final descricaoController = TextEditingController();
    final valorController = TextEditingController();
    String? tipoSelecionado = 'Dízimo';
    String? membroSelecionado;
    DateTime dataSelecionada = DateTime.now();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 500,
                padding: EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nova Entrada',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(dialogContext),
                          child: Icon(Icons.close_rounded, color: Color(0xFF999999)),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.0),
                    // Tipo
                    Text('Tipo de Entrada', style: _labelStyle()),
                    SizedBox(height: 8.0),
                    DropdownButtonFormField<String>(
                      value: tipoSelecionado,
                      decoration: _inputDecoration(),
                      dropdownColor: Color(0xFF1E1E1E),
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                      items: [
                        DropdownMenuItem(value: 'Dízimo', child: Text('Dízimo')),
                        DropdownMenuItem(value: 'Oferta', child: Text('Oferta')),
                      ],
                      onChanged: (value) => setDialogState(() => tipoSelecionado = value),
                    ),
                    SizedBox(height: 16.0),
                    // Membro (opcional)
                    Text('Membro (opcional)', style: _labelStyle()),
                    SizedBox(height: 8.0),
                    DropdownButtonFormField<String>(
                      value: membroSelecionado,
                      decoration: _inputDecoration(),
                      dropdownColor: Color(0xFF1E1E1E),
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                      items: [
                        DropdownMenuItem(value: null, child: Text('Nenhum')),
                        ..._membros.map((m) => DropdownMenuItem(
                          value: m.idMembro,
                          child: Text(m.nomeMembro),
                        )),
                      ],
                      onChanged: (value) => setDialogState(() => membroSelecionado = value),
                    ),
                    SizedBox(height: 16.0),
                    // Descrição
                    Text('Descrição (opcional)', style: _labelStyle()),
                    SizedBox(height: 8.0),
                    TextField(
                      controller: descricaoController,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                      decoration: _inputDecoration().copyWith(hintText: 'Ex: Dízimo mensal'),
                    ),
                    SizedBox(height: 16.0),
                    // Valor
                    Text('Valor', style: _labelStyle()),
                    SizedBox(height: 8.0),
                    TextField(
                      controller: valorController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                      decoration: _inputDecoration().copyWith(
                        hintText: '0,00',
                        prefixText: 'R\$ ',
                        prefixStyle: GoogleFonts.inter(color: Color(0xFF4CAF50), fontSize: 14.0),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    // Data
                    Text('Data', style: _labelStyle()),
                    SizedBox(height: 8.0),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dataSelecionada,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: FlutterFlowTheme.of(context).primary,
                                  surface: Color(0xFF2D2D2D),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() => dataSelecionada = picked);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        decoration: BoxDecoration(
                          color: Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dateTimeFormat('dd/MM/yyyy', dataSelecionada),
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                            ),
                            Icon(Icons.calendar_today_rounded, color: Color(0xFF666666), size: 18.0),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.0),
                    // Botões
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.pop(dialogContext),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 14.0),
                              decoration: BoxDecoration(
                                color: Color(0xFF404040),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Center(
                                child: Text(
                                  'Cancelar',
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
                        Expanded(
                          child: InkWell(
                            onTap: isSaving ? null : () async {
                              final valorTexto = valorController.text.replaceAll(',', '.');
                              final valor = double.tryParse(valorTexto) ?? 0;

                              if (valor <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Informe um valor válido'), backgroundColor: Colors.red),
                                );
                                return;
                              }

                              setDialogState(() => isSaving = true);

                              try {
                                await EntradaFinanceiraTable().insert({
                                  'tipo_entrada': tipoSelecionado,
                                  'id_membro': membroSelecionado,
                                  'descricao': descricaoController.text.trim().isNotEmpty ? descricaoController.text.trim() : null,
                                  'valor_entrada': valor,
                                  'data_entrada': dataSelecionada.toIso8601String(),
                                });

                                Navigator.pop(dialogContext);
                                _carregarDados();
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(content: Text('Entrada registrada com sucesso!'), backgroundColor: Color(0xFF4CAF50)),
                                );
                              } catch (e) {
                                setDialogState(() => isSaving = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erro ao salvar entrada'), backgroundColor: Colors.red),
                                );
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 14.0),
                              decoration: BoxDecoration(
                                color: Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Center(
                                child: isSaving
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Salvar',
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
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarModalEditarEntrada(EntradaFinanceiraRow entrada) {
    final descricaoController = TextEditingController(text: entrada.descricao ?? '');
    final valorController = TextEditingController(text: entrada.valorEntrada?.toStringAsFixed(2).replaceAll('.', ',') ?? '');
    String? tipoSelecionado = entrada.tipoEntrada ?? 'Dízimo';
    String? membroSelecionado = entrada.idMembro;
    DateTime dataSelecionada = entrada.dataEntrada ?? DateTime.now();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 500,
                padding: EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Editar Entrada',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(dialogContext),
                          child: Icon(Icons.close_rounded, color: Color(0xFF999999)),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.0),
                    Text('Tipo de Entrada', style: _labelStyle()),
                    SizedBox(height: 8.0),
                    DropdownButtonFormField<String>(
                      value: tipoSelecionado,
                      decoration: _inputDecoration(),
                      dropdownColor: Color(0xFF1E1E1E),
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                      items: [
                        DropdownMenuItem(value: 'Dízimo', child: Text('Dízimo')),
                        DropdownMenuItem(value: 'Oferta', child: Text('Oferta')),
                      ],
                      onChanged: (value) => setDialogState(() => tipoSelecionado = value),
                    ),
                    SizedBox(height: 16.0),
                    Text('Membro (opcional)', style: _labelStyle()),
                    SizedBox(height: 8.0),
                    DropdownButtonFormField<String>(
                      value: membroSelecionado,
                      decoration: _inputDecoration(),
                      dropdownColor: Color(0xFF1E1E1E),
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                      items: [
                        DropdownMenuItem(value: null, child: Text('Nenhum')),
                        ..._membros.map((m) => DropdownMenuItem(
                          value: m.idMembro,
                          child: Text(m.nomeMembro),
                        )),
                      ],
                      onChanged: (value) => setDialogState(() => membroSelecionado = value),
                    ),
                    SizedBox(height: 16.0),
                    Text('Descrição (opcional)', style: _labelStyle()),
                    SizedBox(height: 8.0),
                    TextField(
                      controller: descricaoController,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                      decoration: _inputDecoration().copyWith(hintText: 'Ex: Dízimo mensal'),
                    ),
                    SizedBox(height: 16.0),
                    Text('Valor', style: _labelStyle()),
                    SizedBox(height: 8.0),
                    TextField(
                      controller: valorController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                      decoration: _inputDecoration().copyWith(
                        hintText: '0,00',
                        prefixText: 'R\$ ',
                        prefixStyle: GoogleFonts.inter(color: Color(0xFF4CAF50), fontSize: 14.0),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text('Data', style: _labelStyle()),
                    SizedBox(height: 8.0),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dataSelecionada,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: FlutterFlowTheme.of(context).primary,
                                  surface: Color(0xFF2D2D2D),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() => dataSelecionada = picked);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        decoration: BoxDecoration(
                          color: Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dateTimeFormat('dd/MM/yyyy', dataSelecionada),
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                            ),
                            Icon(Icons.calendar_today_rounded, color: Color(0xFF666666), size: 18.0),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.0),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.pop(dialogContext),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 14.0),
                              decoration: BoxDecoration(
                                color: Color(0xFF404040),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Center(
                                child: Text(
                                  'Cancelar',
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
                        Expanded(
                          child: InkWell(
                            onTap: isSaving ? null : () async {
                              final valorTexto = valorController.text.replaceAll(',', '.');
                              final valor = double.tryParse(valorTexto) ?? 0;

                              if (valor <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Informe um valor válido'), backgroundColor: Colors.red),
                                );
                                return;
                              }

                              setDialogState(() => isSaving = true);

                              try {
                                await EntradaFinanceiraTable().update(
                                  data: {
                                    'tipo_entrada': tipoSelecionado,
                                    'id_membro': membroSelecionado,
                                    'descricao': descricaoController.text.trim().isNotEmpty ? descricaoController.text.trim() : null,
                                    'valor_entrada': valor,
                                    'data_entrada': dataSelecionada.toIso8601String(),
                                  },
                                  matchingRows: (rows) => rows.eq('id_entrada', entrada.idEntrada),
                                );

                                Navigator.pop(dialogContext);
                                _carregarDados();
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(content: Text('Entrada atualizada com sucesso!'), backgroundColor: Color(0xFF4CAF50)),
                                );
                              } catch (e) {
                                setDialogState(() => isSaving = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erro ao atualizar entrada'), backgroundColor: Colors.red),
                                );
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 14.0),
                              decoration: BoxDecoration(
                                color: Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Center(
                                child: isSaving
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Salvar',
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
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmarExclusao(EntradaFinanceiraRow entrada) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Color(0xFF2D2D2D),
          title: Text('Confirmar Exclusão', style: GoogleFonts.poppins(color: Colors.white)),
          content: Text(
            'Deseja realmente excluir esta entrada?',
            style: GoogleFonts.inter(color: Color(0xFF999999)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancelar', style: GoogleFonts.inter(color: Color(0xFF999999))),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await EntradaFinanceiraTable().delete(
                    matchingRows: (rows) => rows.eq('id_entrada', entrada.idEntrada),
                  );
                  _carregarDados();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Entrada excluída com sucesso!'), backgroundColor: Color(0xFF4CAF50)),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir entrada'), backgroundColor: Colors.red),
                  );
                }
              },
              child: Text('Excluir', style: GoogleFonts.inter(color: Color(0xFFE53935))),
            ),
          ],
        );
      },
    );
  }

  TextStyle _labelStyle() {
    return GoogleFonts.inter(
      color: Colors.white,
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      hintStyle: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 14.0),
      filled: true,
      fillColor: Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
    );
  }
}
