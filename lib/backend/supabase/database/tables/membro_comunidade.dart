import '../database.dart';

class MembroComunidadeTable extends SupabaseTable<MembroComunidadeRow> {
  @override
  String get tableName => 'membro_comunidade';

  @override
  MembroComunidadeRow createRow(Map<String, dynamic> data) => MembroComunidadeRow(data);
}

class MembroComunidadeRow extends SupabaseDataRow {
  MembroComunidadeRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MembroComunidadeTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  int? get idComunidade => getField<int>('id_comunidade');
  set idComunidade(int? value) => setField<int>('id_comunidade', value);

  String? get idMembro => getField<String>('id_membro');
  set idMembro(String? value) => setField<String>('id_membro', value);
}
