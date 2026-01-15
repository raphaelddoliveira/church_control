import '../database.dart';

class MembrosCelulaTable extends SupabaseTable<MembrosCelulaRow> {
  @override
  String get tableName => 'membros_celula';

  @override
  MembrosCelulaRow createRow(Map<String, dynamic> data) => MembrosCelulaRow(data);
}

class MembrosCelulaRow extends SupabaseDataRow {
  MembrosCelulaRow(super.data);

  @override
  SupabaseTable get table => MembrosCelulaTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get idMembro => getField<String>('id_membro');
  set idMembro(String? value) => setField<String>('id_membro', value);

  int? get idCelula => getField<int>('id_celula');
  set idCelula(int? value) => setField<int>('id_celula', value);
}
