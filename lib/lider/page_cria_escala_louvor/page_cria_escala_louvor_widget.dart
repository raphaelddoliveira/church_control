import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/lider/menu_lider/menu_lider_widget.dart';
import '/lider/menu_lider_mobile/menu_lider_mobile_widget.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'page_cria_escala_louvor_model.dart';
export 'page_cria_escala_louvor_model.dart';

// Classe para representar uma musica na escala
class MusicaEscalaItem {
  final int? idMusica;
  final String nome;
  final String? artista;
  final String? youtubeLink;
  final String? cifraLink;
  final String tomOriginal;
  String tomEscala;
  int ordem;

  MusicaEscalaItem({
    this.idMusica,
    required this.nome,
    this.artista,
    this.youtubeLink,
    this.cifraLink,
    required this.tomOriginal,
    required this.tomEscala,
    required this.ordem,
  });
}

// Classe para representar um membro na escala
class MembroEscalaItem {
  final String idMembro;
  final String nome;
  String funcao;

  MembroEscalaItem({
    required this.idMembro,
    required this.nome,
    required this.funcao,
  });
}

class PageCriaEscalaLouvorWidget extends StatefulWidget {
  const PageCriaEscalaLouvorWidget({
    super.key,
    required this.idministerio,
  });

  final int? idministerio;

  static String routeName = 'PageCriaEscala_Louvor';
  static String routePath = '/pageCriaEscalaLouvor';

  @override
  State<PageCriaEscalaLouvorWidget> createState() =>
      _PageCriaEscalaLouvorWidgetState();
}

class _PageCriaEscalaLouvorWidgetState extends State<PageCriaEscalaLouvorWidget> {
  late PageCriaEscalaLouvorModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  MinisterioRow? _ministerio;
  bool _isLoading = true;
  bool _isSaving = false;
  DateTime? _dataSelecionada;
  TimeOfDay? _horaSelecionada;

  // Listas
  List<MusicaEscalaItem> _musicasSelecionadas = [];
  List<MembroEscalaItem> _membrosSelecionados = [];
  List<MembrosRow> _membrosDisponiveis = [];
  List<MusicasRow> _musicasCadastradas = [];

  // Tons musicais
  final List<String> _tons = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
    'Cm', 'C#m', 'Dm', 'D#m', 'Em', 'Fm', 'F#m', 'Gm', 'G#m', 'Am', 'A#m', 'Bm',
  ];

  // Funcoes/instrumentos predefinidos
  final List<Map<String, dynamic>> _funcoesLouvor = [
    {'nome': 'Voz Principal', 'icone': Icons.mic_rounded},
    {'nome': 'Backing Vocal', 'icone': Icons.mic_external_on_rounded},
    {'nome': 'Violao', 'icone': Icons.music_note_rounded},
    {'nome': 'Guitarra', 'icone': Icons.electric_bolt_rounded},
    {'nome': 'Baixo', 'icone': Icons.graphic_eq_rounded},
    {'nome': 'Bateria', 'icone': Icons.album_rounded},
    {'nome': 'Teclado', 'icone': Icons.piano_rounded},
    {'nome': 'Cajon', 'icone': Icons.sports_handball_rounded},
    {'nome': 'Percussao', 'icone': Icons.music_video_rounded},
    {'nome': 'Saxofone', 'icone': Icons.air_rounded},
    {'nome': 'Violino', 'icone': Icons.settings_input_svideo_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageCriaEscalaLouvorModel());
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      // Carregar ministerio
      if (widget.idministerio != null) {
        final ministerioRows = await MinisterioTable().queryRows(
          queryFn: (q) => q.eq('id_ministerio', widget.idministerio!),
        );
        if (ministerioRows.isNotEmpty) {
          _ministerio = ministerioRows.first;
        }
      }

      // Carregar membros do ministerio
      final membrosMinisterio = await MembrosMinisteriosTable().queryRows(
        queryFn: (q) => q.eq('id_ministerio', widget.idministerio!),
      );

      if (membrosMinisterio.isNotEmpty) {
        final idsMembrosList = membrosMinisterio
            .map((mm) => mm.idMembro)
            .where((id) => id != null)
            .toList();

        if (idsMembrosList.isNotEmpty) {
          _membrosDisponiveis = await MembrosTable().queryRows(
            queryFn: (q) => q.inFilter('id_membro', idsMembrosList),
          );
        }
      }

      // Carregar musicas cadastradas
      _musicasCadastradas = await MusicasTable().queryRows(
        queryFn: (q) => q.order('nome'),
      );

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
        _model.dataHoraController?.text = dateTimeFormat('d/M/y', data);
      });

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
          _model.dataHoraController?.text =
              '${dateTimeFormat('d/M/y', data)} as ${hora.format(context)}';
        });
      }
    }
  }

  void _mostrarModalAdicionarMusica() {
    String? tomSelecionado = 'C';
    MusicasRow? musicaExistenteSelecionada;
    bool criarNova = false;
    String buscaTexto = '';
    final buscaController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) {
          // Filtrar musicas baseado na busca
          final musicasFiltradas = _musicasCadastradas.where((m) {
            if (buscaTexto.isEmpty) return true;
            final busca = buscaTexto.toLowerCase();
            return (m.nome?.toLowerCase().contains(busca) ?? false) ||
                   (m.artista?.toLowerCase().contains(busca) ?? false);
          }).toList();

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Container(
              width: 500.0,
              constraints: BoxConstraints(maxHeight: 600.0),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: Color(0xFF2A2A2A)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.fromLTRB(24.0, 20.0, 16.0, 20.0),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.music_note_rounded, color: FlutterFlowTheme.of(context).primary, size: 24.0),
                        SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            'Adicionar Musica',
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: Icon(Icons.close_rounded, color: Color(0xFF666666)),
                        ),
                      ],
                    ),
                  ),

                  // Toggle criar/selecionar
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => criarNova = false),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              decoration: BoxDecoration(
                                color: !criarNova ? FlutterFlowTheme.of(context).primary : Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Center(
                                child: Text('Selecionar', style: GoogleFonts.inter(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => criarNova = true),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              decoration: BoxDecoration(
                                color: criarNova ? FlutterFlowTheme.of(context).primary : Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Center(
                                child: Text('Criar Nova', style: GoogleFonts.inter(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Conteudo
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!criarNova) ...[
                            // Campo de busca
                            TextField(
                              controller: buscaController,
                              onChanged: (value) => setModalState(() => buscaTexto = value),
                              decoration: InputDecoration(
                                hintText: 'Buscar musica ou artista...',
                                hintStyle: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 14.0),
                                prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF666666), size: 20.0),
                                suffixIcon: buscaTexto.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          buscaController.clear();
                                          setModalState(() => buscaTexto = '');
                                        },
                                        icon: Icon(Icons.close_rounded, color: Color(0xFF666666), size: 18.0),
                                      )
                                    : null,
                                filled: true,
                                fillColor: Color(0xFF2A2A2A),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Color(0xFF3A3A3A))),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary, width: 2.0)),
                              ),
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                            ),
                            SizedBox(height: 12.0),

                            // Contador de resultados
                            Text(
                              '${musicasFiltradas.length} musica${musicasFiltradas.length != 1 ? 's' : ''} encontrada${musicasFiltradas.length != 1 ? 's' : ''}',
                              style: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 12.0),
                            ),
                            SizedBox(height: 12.0),

                            // Lista de musicas
                            if (musicasFiltradas.isEmpty)
                              Container(
                                padding: EdgeInsets.all(24.0),
                                decoration: BoxDecoration(color: Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(12.0)),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.music_off_rounded, color: Color(0xFF666666), size: 32.0),
                                      SizedBox(height: 8.0),
                                      Text(
                                        buscaTexto.isNotEmpty ? 'Nenhuma musica encontrada' : 'Nenhuma musica cadastrada',
                                        style: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 14.0),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Container(
                                constraints: BoxConstraints(maxHeight: 220.0),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: musicasFiltradas.length,
                                  itemBuilder: (context, index) {
                                    final musica = musicasFiltradas[index];
                                    final isSelected = musicaExistenteSelecionada?.id == musica.id;
                                    return GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          musicaExistenteSelecionada = musica;
                                          tomSelecionado = musica.tomOriginal ?? 'C';
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 8.0),
                                        padding: EdgeInsets.all(12.0),
                                        decoration: BoxDecoration(
                                          color: isSelected ? FlutterFlowTheme.of(context).primary.withOpacity(0.15) : Color(0xFF242424),
                                          borderRadius: BorderRadius.circular(10.0),
                                          border: Border.all(
                                            color: isSelected ? FlutterFlowTheme.of(context).primary : Color(0xFF3A3A3A),
                                            width: isSelected ? 2.0 : 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 36.0,
                                              height: 36.0,
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              child: Icon(Icons.music_note_rounded, color: FlutterFlowTheme.of(context).primary, size: 18.0),
                                            ),
                                            SizedBox(width: 12.0),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(musica.nome ?? '', style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.w600)),
                                                  if (musica.artista != null)
                                                    Text(musica.artista!, style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 12.0)),
                                                ],
                                              ),
                                            ),
                                            if (musica.tomOriginal != null)
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                                                decoration: BoxDecoration(color: Color(0xFF3A3A3A), borderRadius: BorderRadius.circular(6.0)),
                                                child: Text(musica.tomOriginal!, style: GoogleFonts.inter(color: Colors.white, fontSize: 11.0, fontWeight: FontWeight.w600)),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                            // Tom selector quando musica selecionada
                            if (musicaExistenteSelecionada != null) ...[
                              SizedBox(height: 16.0),
                              Text('Tom para esta escala', style: GoogleFonts.inter(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.w600)),
                              SizedBox(height: 8.0),
                              _buildTomSelectorCompact(tomSelecionado, (tom) => setModalState(() => tomSelecionado = tom)),
                            ],
                          ] else ...[
                            // Formulario criar nova
                            _buildModalLabel('Nome da Musica *'),
                            SizedBox(height: 8.0),
                            _buildModalTextField(controller: _model.nomeMusicaController, hint: 'Ex: Lugar Secreto', icon: Icons.music_note_rounded),
                            SizedBox(height: 12.0),
                            _buildModalLabel('Artista'),
                            SizedBox(height: 8.0),
                            _buildModalTextField(controller: _model.artistaController, hint: 'Ex: Gabriela Rocha', icon: Icons.person_rounded),
                            SizedBox(height: 12.0),
                            _buildModalLabel('Link do YouTube'),
                            SizedBox(height: 8.0),
                            _buildModalTextField(controller: _model.youtubeController, hint: 'https://youtube.com/...', icon: Icons.play_circle_rounded),
                            SizedBox(height: 12.0),
                            _buildModalLabel('Link da Cifra'),
                            SizedBox(height: 8.0),
                            _buildModalTextField(controller: _model.cifraController, hint: 'https://cifraclub.com.br/...', icon: Icons.article_rounded),
                            SizedBox(height: 12.0),
                            _buildModalLabel('Tom'),
                            SizedBox(height: 8.0),
                            _buildTomSelectorCompact(tomSelecionado, (tom) => setModalState(() => tomSelecionado = tom)),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Botao adicionar
                  Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF2A2A2A)))),
                    child: SizedBox(
                      width: double.infinity,
                      child: FFButtonWidget(
                        onPressed: () async {
                          if (criarNova) {
                            if (_model.nomeMusicaController?.text.isEmpty ?? true) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Digite o nome da musica'), backgroundColor: Colors.red));
                              return;
                            }
                            try {
                              final novaMusica = await MusicasTable().insert({
                                'nome': _model.nomeMusicaController!.text,
                                'artista': _model.artistaController?.text.isNotEmpty == true ? _model.artistaController!.text : null,
                                'youtube_link': _model.youtubeController?.text.isNotEmpty == true ? _model.youtubeController!.text : null,
                                'cifra_link': _model.cifraController?.text.isNotEmpty == true ? _model.cifraController!.text : null,
                                'tom_original': tomSelecionado,
                              });
                              setState(() {
                                _musicasSelecionadas.add(MusicaEscalaItem(
                                  idMusica: novaMusica.id, nome: novaMusica.nome ?? '', artista: novaMusica.artista,
                                  youtubeLink: novaMusica.youtubeLink, cifraLink: novaMusica.cifraLink,
                                  tomOriginal: novaMusica.tomOriginal ?? 'C', tomEscala: tomSelecionado ?? 'C', ordem: _musicasSelecionadas.length + 1,
                                ));
                                _musicasCadastradas.add(novaMusica);
                              });
                              _model.nomeMusicaController?.clear();
                              _model.artistaController?.clear();
                              _model.youtubeController?.clear();
                              _model.cifraController?.clear();
                              Navigator.pop(dialogContext);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao criar musica: $e'), backgroundColor: Colors.red));
                            }
                          } else {
                            if (musicaExistenteSelecionada == null) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selecione uma musica'), backgroundColor: Colors.red));
                              return;
                            }
                            setState(() {
                              _musicasSelecionadas.add(MusicaEscalaItem(
                                idMusica: musicaExistenteSelecionada!.id, nome: musicaExistenteSelecionada!.nome ?? '',
                                artista: musicaExistenteSelecionada!.artista, youtubeLink: musicaExistenteSelecionada!.youtubeLink,
                                cifraLink: musicaExistenteSelecionada!.cifraLink, tomOriginal: musicaExistenteSelecionada!.tomOriginal ?? 'C',
                                tomEscala: tomSelecionado ?? musicaExistenteSelecionada!.tomOriginal ?? 'C', ordem: _musicasSelecionadas.length + 1,
                              ));
                            });
                            Navigator.pop(dialogContext);
                          }
                        },
                        text: 'Adicionar Musica',
                        icon: Icon(Icons.add_rounded, size: 18.0),
                        options: FFButtonOptions(
                          height: 48.0,
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: GoogleFonts.inter(color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.w600),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTomSelectorCompact(String? tomSelecionado, Function(String) onSelect) {
    return Wrap(
      spacing: 6.0,
      runSpacing: 6.0,
      children: _tons.map((tom) {
        final isSelected = tomSelecionado == tom;
        return GestureDetector(
          onTap: () => onSelect(tom),
          child: Container(
            width: 40.0,
            height: 32.0,
            decoration: BoxDecoration(
              color: isSelected ? FlutterFlowTheme.of(context).primary : Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(color: isSelected ? FlutterFlowTheme.of(context).primary : Color(0xFF3A3A3A)),
            ),
            child: Center(
              child: Text(tom, style: GoogleFonts.inter(color: isSelected ? Colors.white : Color(0xFF999999), fontSize: 11.0, fontWeight: FontWeight.w600)),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _mostrarModalAdicionarMembro() {
    MembrosRow? membroSelecionado;
    String? funcaoSelecionada;
    String buscaTexto = '';
    final buscaController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) {
          // Filtrar membros baseado na busca
          final membrosFiltrados = _membrosDisponiveis.where((m) {
            if (buscaTexto.isEmpty) return true;
            final busca = buscaTexto.toLowerCase();
            return (m.nomeMembro?.toLowerCase().contains(busca) ?? false);
          }).toList();

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Container(
              width: 500.0,
              constraints: BoxConstraints(maxHeight: 650.0),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: Color(0xFF2A2A2A)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.fromLTRB(24.0, 20.0, 16.0, 20.0),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person_add_rounded, color: FlutterFlowTheme.of(context).primary, size: 24.0),
                        SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            'Adicionar Membro',
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: Icon(Icons.close_rounded, color: Color(0xFF666666)),
                        ),
                      ],
                    ),
                  ),

                  // Conteudo
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Campo de busca
                          TextField(
                            controller: buscaController,
                            onChanged: (value) => setModalState(() => buscaTexto = value),
                            decoration: InputDecoration(
                              hintText: 'Buscar membro...',
                              hintStyle: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 14.0),
                              prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF666666), size: 20.0),
                              suffixIcon: buscaTexto.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        buscaController.clear();
                                        setModalState(() => buscaTexto = '');
                                      },
                                      icon: Icon(Icons.close_rounded, color: Color(0xFF666666), size: 18.0),
                                    )
                                  : null,
                              filled: true,
                              fillColor: Color(0xFF2A2A2A),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: Color(0xFF3A3A3A))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary, width: 2.0)),
                            ),
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 14.0),
                          ),
                          SizedBox(height: 12.0),

                          // Contador de resultados
                          Text(
                            '${membrosFiltrados.length} membro${membrosFiltrados.length != 1 ? 's' : ''} encontrado${membrosFiltrados.length != 1 ? 's' : ''}',
                            style: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 12.0),
                          ),
                          SizedBox(height: 12.0),

                          // Lista de membros
                          if (membrosFiltrados.isEmpty)
                            Container(
                              padding: EdgeInsets.all(24.0),
                              decoration: BoxDecoration(color: Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(12.0)),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.person_off_rounded, color: Color(0xFF666666), size: 32.0),
                                    SizedBox(height: 8.0),
                                    Text(
                                      buscaTexto.isNotEmpty ? 'Nenhum membro encontrado' : 'Nenhum membro disponivel',
                                      style: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 14.0),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Container(
                              constraints: BoxConstraints(maxHeight: 180.0),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: membrosFiltrados.length,
                                itemBuilder: (context, index) {
                                  final membro = membrosFiltrados[index];
                                  final isSelected = membroSelecionado?.idMembro == membro.idMembro;
                                  final jaAdicionado = _membrosSelecionados.any((m) => m.idMembro == membro.idMembro);

                                  return GestureDetector(
                                    onTap: jaAdicionado ? null : () => setModalState(() => membroSelecionado = membro),
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 8.0),
                                      padding: EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: jaAdicionado
                                            ? Color(0xFF1A1A1A)
                                            : isSelected
                                                ? FlutterFlowTheme.of(context).primary.withOpacity(0.15)
                                                : Color(0xFF242424),
                                        borderRadius: BorderRadius.circular(10.0),
                                        border: Border.all(
                                          color: isSelected ? FlutterFlowTheme.of(context).primary : Color(0xFF3A3A3A),
                                          width: isSelected ? 2.0 : 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36.0,
                                            height: 36.0,
                                            decoration: BoxDecoration(
                                              color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                            child: Center(
                                              child: Text(
                                                (membro.nomeMembro ?? 'M')[0].toUpperCase(),
                                                style: GoogleFonts.poppins(
                                                  color: FlutterFlowTheme.of(context).primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12.0),
                                          Expanded(
                                            child: Text(
                                              membro.nomeMembro ?? '',
                                              style: GoogleFonts.inter(
                                                color: jaAdicionado ? Color(0xFF666666) : Colors.white,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (jaAdicionado)
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                                              decoration: BoxDecoration(color: Color(0xFF3A3A3A), borderRadius: BorderRadius.circular(6.0)),
                                              child: Text('Adicionado', style: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 10.0)),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                          SizedBox(height: 20.0),

                          // Selecao de funcao
                          Text('Funcao/Instrumento', style: GoogleFonts.inter(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.w600)),
                          SizedBox(height: 10.0),
                          Wrap(
                            spacing: 6.0,
                            runSpacing: 6.0,
                            children: _funcoesLouvor.map((funcao) {
                              final isSelected = funcaoSelecionada == funcao['nome'];
                              return GestureDetector(
                                onTap: () => setModalState(() => funcaoSelecionada = funcao['nome']),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: isSelected ? FlutterFlowTheme.of(context).primary : Color(0xFF2A2A2A),
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(color: isSelected ? FlutterFlowTheme.of(context).primary : Color(0xFF3A3A3A)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(funcao['icone'] as IconData, color: isSelected ? Colors.white : Color(0xFF999999), size: 16.0),
                                      SizedBox(width: 6.0),
                                      Text(funcao['nome'] as String, style: GoogleFonts.inter(color: isSelected ? Colors.white : Color(0xFF999999), fontSize: 12.0, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Botao adicionar
                  Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF2A2A2A)))),
                    child: SizedBox(
                      width: double.infinity,
                      child: FFButtonWidget(
                        onPressed: () {
                          if (membroSelecionado == null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selecione um membro'), backgroundColor: Colors.red));
                            return;
                          }
                          if (funcaoSelecionada == null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selecione uma funcao'), backgroundColor: Colors.red));
                            return;
                          }
                          setState(() {
                            _membrosSelecionados.add(MembroEscalaItem(
                              idMembro: membroSelecionado!.idMembro!,
                              nome: membroSelecionado!.nomeMembro ?? '',
                              funcao: funcaoSelecionada!,
                            ));
                          });
                          Navigator.pop(dialogContext);
                        },
                        text: 'Adicionar Membro',
                        icon: Icon(Icons.person_add_rounded, size: 18.0),
                        options: FFButtonOptions(
                          height: 48.0,
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: GoogleFonts.inter(color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.w600),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _criarEscala() async {
    if (_model.nomeEscalaController?.text.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Digite o titulo da escala'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_dataSelecionada == null || _horaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecione a data e hora'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_musicasSelecionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Adicione pelo menos uma musica'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_membrosSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Adicione pelo menos um membro'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Buscar o id_membro do usuário logado pelo email
      final membroRows = await MembrosTable().queryRows(
        queryFn: (q) => q.eq('email', currentUserEmail),
      );

      if (membroRows.isEmpty) {
        throw Exception('Membro não encontrado para o usuário logado');
      }

      final idMembroResponsavel = membroRows.first.idMembro;

      // Combinar data e hora (adicionar 3 horas para compensar o fuso horário UTC-3 Brasília)
      final dataHora = DateTime(
        _dataSelecionada!.year,
        _dataSelecionada!.month,
        _dataSelecionada!.day,
        _horaSelecionada!.hour + 3,
        _horaSelecionada!.minute,
      );

      // Criar escala
      final novaEscala = await EscalasTable().insert({
        'id_ministerio': widget.idministerio,
        'nome_escala': _model.nomeEscalaController!.text,
        'data_hora_escala': dataHora.toIso8601String(),
        'descricao': _model.descricaoController?.text.isNotEmpty == true
            ? _model.descricaoController!.text
            : null,
        'id_responsavel': idMembroResponsavel,
      });

      // Inserir musicas da escala
      for (var musica in _musicasSelecionadas) {
        await EscalaMusicasTable().insert({
          'id_escala': novaEscala.idEscala,
          'id_musica': musica.idMusica,
          'tom_escala': musica.tomEscala,
          'ordem': musica.ordem,
        });
      }

      // Inserir membros da escala
      for (var membro in _membrosSelecionados) {
        await MembrosEscalasTable().insert({
          'id_escala': novaEscala.idEscala,
          'id_membro': membro.idMembro,
          'funcao_escala': membro.funcao,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Escala criada com sucesso!'),
          backgroundColor: FlutterFlowTheme.of(context).success,
        ),
      );

      // Navegar para detalhes
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
        SnackBar(content: Text('Erro ao criar escala: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildTomSelector(String? tomSelecionado, Function(String) onSelect) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _tons.map((tom) {
        final isSelected = tomSelecionado == tom;
        return GestureDetector(
          onTap: () => onSelect(tom),
          child: Container(
            width: 48.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: isSelected
                  ? FlutterFlowTheme.of(context).primary
                  : Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: isSelected
                    ? FlutterFlowTheme.of(context).primary
                    : Color(0xFF3A3A3A),
              ),
            ),
            child: Center(
              child: Text(
                tom,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : Color(0xFF999999),
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModalLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildModalTextField({
    required TextEditingController? controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 15.0),
        prefixIcon: Icon(icon, color: Color(0xFF666666)),
        filled: true,
        fillColor: Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Color(0xFF3A3A3A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Color(0xFF3A3A3A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary, width: 2.0),
        ),
      ),
      style: GoogleFonts.inter(color: Colors.white, fontSize: 15.0),
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;

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
          decoration: BoxDecoration(color: Color(0xFF14181B)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Menu lateral
              if (!isMobile)
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

              // Conteudo principal
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
                                // Header
                                Padding(
                                  padding: EdgeInsets.all(!isMobile ? 32.0 : 16.0),
                                  child: Row(
                                    children: [
                                      FlutterFlowIconButton(
                                        borderColor: Colors.transparent,
                                        borderRadius: 12.0,
                                        buttonSize: 40.0,
                                        fillColor: Color(0xFF2A2A2A),
                                        icon: Icon(
                                          Icons.arrow_back_rounded,
                                          color: Colors.white,
                                          size: 20.0,
                                        ),
                                        onPressed: () {
                                          context.pushNamed(
                                            PageEscalasLiderWidget.routeName,
                                            queryParameters: {
                                              'idministerio': serializeParam(
                                                widget.idministerio,
                                                ParamType.int,
                                              ),
                                            }.withoutNulls,
                                          );
                                        },
                                      ),
                                      SizedBox(width: 12.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.music_note_rounded,
                                                  color: FlutterFlowTheme.of(context).primary,
                                                  size: !isMobile ? 28.0 : 20.0,
                                                ),
                                                SizedBox(width: 8.0),
                                                Expanded(
                                                  child: Text(
                                                    !isMobile ? 'Nova Escala de Louvor' : 'Nova Escala',
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: !isMobile ? 28.0 : 18.0,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4.0),
                                            Text(
                                              _ministerio?.nomeMinisterio ?? 'Ministerio de Louvor',
                                              style: GoogleFonts.inter(
                                                color: Color(0xFF999999),
                                                fontSize: !isMobile ? 16.0 : 12.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Botao menu mobile
                                      if (isMobile)
                                        Padding(
                                          padding: EdgeInsets.only(left: 8.0),
                                          child: InkWell(
                                            onTap: () async {
                                              await showDialog(
                                                context: context,
                                                builder: (dialogContext) {
                                                  return Dialog(
                                                    elevation: 0,
                                                    insetPadding: EdgeInsets.zero,
                                                    backgroundColor: Colors.transparent,
                                                    child: MenuLiderMobileWidget(),
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF2A2A2A),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              child: Icon(
                                                Icons.menu_rounded,
                                                color: Colors.white,
                                                size: 24.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Formulario
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: !isMobile ? 32.0 : 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Secao: Informacoes da Escala
                                      _buildSectionHeader('Informacoes da Escala', Icons.info_outline_rounded),
                                      SizedBox(height: 16.0),
                                      Container(
                                        padding: EdgeInsets.all(24.0),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF2A2A2A),
                                          borderRadius: BorderRadius.circular(16.0),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildLabel('Titulo da Escala', isRequired: true),
                                            SizedBox(height: 8.0),
                                            _buildTextField(
                                              controller: _model.nomeEscalaController,
                                              focusNode: _model.nomeEscalaFocusNode,
                                              hintText: 'Ex: Culto de Domingo',
                                              icon: Icons.event_rounded,
                                            ),
                                            SizedBox(height: 20.0),
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
                                                  border: Border.all(color: Color(0xFF4A4A4A)),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.calendar_today_rounded, color: Color(0xFF666666), size: 24.0),
                                                    SizedBox(width: 12.0),
                                                    Expanded(
                                                      child: Text(
                                                        _model.dataHoraController?.text.isNotEmpty == true
                                                            ? _model.dataHoraController!.text
                                                            : 'Selecione a data e hora',
                                                        style: GoogleFonts.inter(
                                                          color: _model.dataHoraController?.text.isNotEmpty == true
                                                              ? Colors.white
                                                              : Color(0xFF666666),
                                                          fontSize: 16.0,
                                                        ),
                                                      ),
                                                    ),
                                                    Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF666666), size: 28.0),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 20.0),
                                            _buildLabel('Observacoes'),
                                            SizedBox(height: 8.0),
                                            _buildTextField(
                                              controller: _model.descricaoController,
                                              focusNode: _model.descricaoFocusNode,
                                              hintText: 'Informacoes adicionais...',
                                              icon: Icons.notes_rounded,
                                              maxLines: 3,
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(height: 32.0),

                                      // Secao: Musicas
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildSectionHeader('Repertorio Musical', Icons.queue_music_rounded),
                                          FFButtonWidget(
                                            onPressed: _mostrarModalAdicionarMusica,
                                            text: 'Adicionar',
                                            icon: Icon(Icons.add_rounded, size: 18.0),
                                            options: FFButtonOptions(
                                              height: 40.0,
                                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                                              color: FlutterFlowTheme.of(context).primary,
                                              textStyle: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16.0),
                                      if (_musicasSelecionadas.isEmpty)
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(32.0),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF2A2A2A),
                                            borderRadius: BorderRadius.circular(16.0),
                                            border: Border.all(color: Color(0xFF3A3A3A), style: BorderStyle.solid),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(Icons.music_off_rounded, color: Color(0xFF666666), size: 48.0),
                                              SizedBox(height: 12.0),
                                              Text(
                                                'Nenhuma musica adicionada',
                                                style: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 15.0),
                                              ),
                                              SizedBox(height: 4.0),
                                              Text(
                                                'Clique em "Adicionar" para incluir musicas',
                                                style: GoogleFonts.inter(color: Color(0xFF555555), fontSize: 13.0),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        ReorderableListView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: _musicasSelecionadas.length,
                                          onReorder: (oldIndex, newIndex) {
                                            setState(() {
                                              if (newIndex > oldIndex) newIndex--;
                                              final item = _musicasSelecionadas.removeAt(oldIndex);
                                              _musicasSelecionadas.insert(newIndex, item);
                                              // Atualizar ordem
                                              for (int i = 0; i < _musicasSelecionadas.length; i++) {
                                                _musicasSelecionadas[i].ordem = i + 1;
                                              }
                                            });
                                          },
                                          itemBuilder: (context, index) {
                                            final musica = _musicasSelecionadas[index];
                                            return Container(
                                              key: ValueKey(musica.idMusica ?? index),
                                              margin: EdgeInsets.only(bottom: 12.0),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF2A2A2A),
                                                borderRadius: BorderRadius.circular(12.0),
                                              ),
                                              child: ListTile(
                                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                                leading: Container(
                                                  width: 40.0,
                                                  height: 40.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(10.0),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${musica.ordem}',
                                                      style: GoogleFonts.poppins(
                                                        color: FlutterFlowTheme.of(context).primary,
                                                        fontSize: 16.0,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                title: Text(
                                                  musica.nome,
                                                  style: GoogleFonts.inter(
                                                    color: Colors.white,
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                subtitle: Row(
                                                  children: [
                                                    if (musica.artista != null)
                                                      Text(
                                                        musica.artista!,
                                                        style: GoogleFonts.inter(color: Color(0xFF999999), fontSize: 13.0),
                                                      ),
                                                    SizedBox(width: 8.0),
                                                    Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(4.0),
                                                      ),
                                                      child: Text(
                                                        'Tom: ${musica.tomEscala}',
                                                        style: GoogleFonts.inter(
                                                          color: FlutterFlowTheme.of(context).primary,
                                                          fontSize: 11.0,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                trailing: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    if (musica.youtubeLink != null && musica.youtubeLink!.isNotEmpty)
                                                      IconButton(
                                                        icon: Icon(Icons.play_circle_outline_rounded, color: Colors.red),
                                                        onPressed: () => launchURL(musica.youtubeLink!),
                                                      ),
                                                    if (musica.cifraLink != null && musica.cifraLink!.isNotEmpty)
                                                      IconButton(
                                                        icon: Icon(Icons.article_outlined, color: Colors.orange),
                                                        onPressed: () => launchURL(musica.cifraLink!),
                                                      ),
                                                    IconButton(
                                                      icon: Icon(Icons.delete_outline_rounded, color: Color(0xFF666666)),
                                                      onPressed: () {
                                                        setState(() {
                                                          _musicasSelecionadas.removeAt(index);
                                                          for (int i = 0; i < _musicasSelecionadas.length; i++) {
                                                            _musicasSelecionadas[i].ordem = i + 1;
                                                          }
                                                        });
                                                      },
                                                    ),
                                                    Icon(Icons.drag_handle_rounded, color: Color(0xFF666666)),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),

                                      SizedBox(height: 32.0),

                                      // Secao: Membros
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildSectionHeader('Equipe', Icons.group_rounded),
                                          FFButtonWidget(
                                            onPressed: _mostrarModalAdicionarMembro,
                                            text: 'Adicionar',
                                            icon: Icon(Icons.person_add_rounded, size: 18.0),
                                            options: FFButtonOptions(
                                              height: 40.0,
                                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                                              color: FlutterFlowTheme.of(context).primary,
                                              textStyle: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16.0),
                                      if (_membrosSelecionados.isEmpty)
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(32.0),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF2A2A2A),
                                            borderRadius: BorderRadius.circular(16.0),
                                            border: Border.all(color: Color(0xFF3A3A3A), style: BorderStyle.solid),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(Icons.group_off_rounded, color: Color(0xFF666666), size: 48.0),
                                              SizedBox(height: 12.0),
                                              Text(
                                                'Nenhum membro adicionado',
                                                style: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 15.0),
                                              ),
                                              SizedBox(height: 4.0),
                                              Text(
                                                'Clique em "Adicionar" para incluir membros',
                                                style: GoogleFonts.inter(color: Color(0xFF555555), fontSize: 13.0),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Wrap(
                                          spacing: 12.0,
                                          runSpacing: 12.0,
                                          children: _membrosSelecionados.map((membro) {
                                            final funcaoInfo = _funcoesLouvor.firstWhere(
                                              (f) => f['nome'] == membro.funcao,
                                              orElse: () => {'nome': membro.funcao, 'icone': Icons.person},
                                            );
                                            return Container(
                                              padding: EdgeInsets.all(16.0),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF2A2A2A),
                                                borderRadius: BorderRadius.circular(12.0),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 44.0,
                                                    height: 44.0,
                                                    decoration: BoxDecoration(
                                                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(10.0),
                                                    ),
                                                    child: Icon(
                                                      funcaoInfo['icone'] as IconData,
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      size: 22.0,
                                                    ),
                                                  ),
                                                  SizedBox(width: 12.0),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        membro.nome,
                                                        style: GoogleFonts.inter(
                                                          color: Colors.white,
                                                          fontSize: 14.0,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      Text(
                                                        membro.funcao,
                                                        style: GoogleFonts.inter(
                                                          color: Color(0xFF999999),
                                                          fontSize: 12.0,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(width: 12.0),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        _membrosSelecionados.remove(membro);
                                                      });
                                                    },
                                                    child: Icon(
                                                      Icons.close_rounded,
                                                      color: Color(0xFF666666),
                                                      size: 20.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),

                                      SizedBox(height: 40.0),

                                      // Botao criar escala
                                      SizedBox(
                                        width: double.infinity,
                                        child: FFButtonWidget(
                                          onPressed: _isSaving ? null : _criarEscala,
                                          text: _isSaving ? 'Criando...' : 'Criar Escala de Louvor',
                                          icon: _isSaving
                                              ? null
                                              : Icon(Icons.check_rounded, size: 22.0),
                                          options: FFButtonOptions(
                                            height: 60.0,
                                            padding: EdgeInsets.symmetric(horizontal: 32.0),
                                            color: FlutterFlowTheme.of(context).primary,
                                            textStyle: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            elevation: 0.0,
                                            borderRadius: BorderRadius.circular(14.0),
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 32.0),
                                    ],
                                  ),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: FlutterFlowTheme.of(context).primary, size: 24.0),
        SizedBox(width: 10.0),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
        hintStyle: GoogleFonts.inter(color: Color(0xFF666666), fontSize: 16.0),
        prefixIcon: maxLines == 1 ? Icon(icon, color: Color(0xFF666666)) : null,
        filled: true,
        fillColor: Color(0xFF3A3A3A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Color(0xFF4A4A4A), width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Color(0xFF4A4A4A), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: FlutterFlowTheme.of(context).primary, width: 2.0),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: maxLines > 1 ? 16.0 : 0.0,
        ),
      ),
      style: GoogleFonts.inter(color: Colors.white, fontSize: 16.0),
    );
  }
}
