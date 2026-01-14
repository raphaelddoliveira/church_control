import '../database.dart';

class MinisterioTable extends SupabaseTable<MinisterioRow> {
  @override
  String get tableName => 'ministerio';

  @override
  MinisterioRow createRow(Map<String, dynamic> data) => MinisterioRow(data);
}

class MinisterioRow extends SupabaseDataRow {
  MinisterioRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MinisterioTable();

  int get idMinisterio => getField<int>('id_ministerio')!;
  set idMinisterio(int value) => setField<int>('id_ministerio', value);

  String get nomeMinisterio => getField<String>('nome_ministerio')!;
  set nomeMinisterio(String value) =>
      setField<String>('nome_ministerio', value);

  int? get idOrganizacao => getField<int>('id_organizacao');
  set idOrganizacao(int? value) => setField<int>('id_organizacao', value);

  String? get idLider => getField<String>('id_lider');
  set idLider(String? value) => setField<String>('id_lider', value);

  DateTime? get criadoEm => getField<DateTime>('criado_em');
  set criadoEm(DateTime? value) => setField<DateTime>('criado_em', value);

  String? get idAuthLider => getField<String>('id_auth_lider');
  set idAuthLider(String? value) => setField<String>('id_auth_lider', value);

  DateTime? get atualizadoEm => getField<DateTime>('atualizado_em');
  set atualizadoEm(DateTime? value) =>
      setField<DateTime>('atualizado_em', value);
}
