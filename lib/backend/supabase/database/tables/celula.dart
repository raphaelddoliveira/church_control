import '../database.dart';

class CelulaTable extends SupabaseTable<CelulaRow> {
  @override
  String get tableName => 'celula';

  @override
  CelulaRow createRow(Map<String, dynamic> data) => CelulaRow(data);
}

class CelulaRow extends SupabaseDataRow {
  CelulaRow(super.data);

  @override
  SupabaseTable get table => CelulaTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get nomeCelula => getField<String>('nome_celula');
  set nomeCelula(String? value) => setField<String>('nome_celula', value);

  String? get idLider => getField<String>('id_lider');
  set idLider(String? value) => setField<String>('id_lider', value);

  int? get idOrganizacao => getField<int>('id_organizacao');
  set idOrganizacao(int? value) => setField<int>('id_organizacao', value);
}
