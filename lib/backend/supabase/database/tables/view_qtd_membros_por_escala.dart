import '../database.dart';

class ViewQtdMembrosPorEscalaTable
    extends SupabaseTable<ViewQtdMembrosPorEscalaRow> {
  @override
  String get tableName => 'view_qtd_membros_por_escala';

  @override
  ViewQtdMembrosPorEscalaRow createRow(Map<String, dynamic> data) =>
      ViewQtdMembrosPorEscalaRow(data);
}

class ViewQtdMembrosPorEscalaRow extends SupabaseDataRow {
  ViewQtdMembrosPorEscalaRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ViewQtdMembrosPorEscalaTable();

  int? get idEscala => getField<int>('id_escala');
  set idEscala(int? value) => setField<int>('id_escala', value);

  int? get totalMembros => getField<int>('total_membros');
  set totalMembros(int? value) => setField<int>('total_membros', value);
}
