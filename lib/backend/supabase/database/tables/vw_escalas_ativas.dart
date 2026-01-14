import '../database.dart';

class VwEscalasAtivasTable extends SupabaseTable<VwEscalasAtivasRow> {
  @override
  String get tableName => 'vw_escalas_ativas';

  @override
  VwEscalasAtivasRow createRow(Map<String, dynamic> data) =>
      VwEscalasAtivasRow(data);
}

class VwEscalasAtivasRow extends SupabaseDataRow {
  VwEscalasAtivasRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VwEscalasAtivasTable();

  int? get idEscala => getField<int>('id_escala');
  set idEscala(int? value) => setField<int>('id_escala', value);

  int? get idOrganizacao => getField<int>('id_organizacao');
  set idOrganizacao(int? value) => setField<int>('id_organizacao', value);

  int? get idMinisterio => getField<int>('id_ministerio');
  set idMinisterio(int? value) => setField<int>('id_ministerio', value);

  String? get idResponsavel => getField<String>('id_responsavel');
  set idResponsavel(String? value) => setField<String>('id_responsavel', value);

  DateTime? get dataHoraEscala => getField<DateTime>('data_hora_escala');
  set dataHoraEscala(DateTime? value) =>
      setField<DateTime>('data_hora_escala', value);

  String? get nomeEscala => getField<String>('nome_escala');
  set nomeEscala(String? value) => setField<String>('nome_escala', value);

  String? get descricao => getField<String>('descricao');
  set descricao(String? value) => setField<String>('descricao', value);
}
