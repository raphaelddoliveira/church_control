import '../database.dart';

class MembrosPorMesTable extends SupabaseTable<MembrosPorMesRow> {
  @override
  String get tableName => 'membros_por_mes';

  @override
  MembrosPorMesRow createRow(Map<String, dynamic> data) =>
      MembrosPorMesRow(data);
}

class MembrosPorMesRow extends SupabaseDataRow {
  MembrosPorMesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MembrosPorMesTable();

  String? get mes => getField<String>('mes');
  set mes(String? value) => setField<String>('mes', value);

  int? get quantidadeMembros => getField<int>('quantidade_membros');
  set quantidadeMembros(int? value) =>
      setField<int>('quantidade_membros', value);
}
