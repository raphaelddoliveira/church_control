import '../database.dart';

class EscalasTable extends SupabaseTable<EscalasRow> {
  @override
  String get tableName => 'escalas';

  @override
  EscalasRow createRow(Map<String, dynamic> data) => EscalasRow(data);
}

class EscalasRow extends SupabaseDataRow {
  EscalasRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EscalasTable();

  int get idEscala => getField<int>('id_escala')!;
  set idEscala(int value) => setField<int>('id_escala', value);

  int? get idOrganizacao => getField<int>('id_organizacao');
  set idOrganizacao(int? value) => setField<int>('id_organizacao', value);

  int? get idMinisterio => getField<int>('id_ministerio');
  set idMinisterio(int? value) => setField<int>('id_ministerio', value);

  DateTime? get dataHoraEscala => getField<DateTime>('data_hora_escala');
  set dataHoraEscala(DateTime? value) =>
      setField<DateTime>('data_hora_escala', value);

  String? get idResponsavel => getField<String>('id_responsavel');
  set idResponsavel(String? value) => setField<String>('id_responsavel', value);

  String? get descricao => getField<String>('descricao');
  set descricao(String? value) => setField<String>('descricao', value);

  List<String> get arquivos => getListField<String>('arquivos');
  set arquivos(List<String>? value) => setListField<String>('arquivos', value);

  String? get nomeEscala => getField<String>('nome_escala');
  set nomeEscala(String? value) => setField<String>('nome_escala', value);
}
