import '../database.dart';

class CurtidasTable extends SupabaseTable<CurtidasRow> {
  @override
  String get tableName => 'curtidas';

  @override
  CurtidasRow createRow(Map<String, dynamic> data) => CurtidasRow(data);
}

class CurtidasRow extends SupabaseDataRow {
  CurtidasRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CurtidasTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int? get avisoId => getField<int>('aviso_id');
  set avisoId(int? value) => setField<int>('aviso_id', value);

  String? get membroId => getField<String>('membro_id');
  set membroId(String? value) => setField<String>('membro_id', value);
}
