import '../database.dart';

class VwEstatisticaEscalasMensalTable
    extends SupabaseTable<VwEstatisticaEscalasMensalRow> {
  @override
  String get tableName => 'vw_estatistica_escalas_mensal';

  @override
  VwEstatisticaEscalasMensalRow createRow(Map<String, dynamic> data) =>
      VwEstatisticaEscalasMensalRow(data);
}

class VwEstatisticaEscalasMensalRow extends SupabaseDataRow {
  VwEstatisticaEscalasMensalRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VwEstatisticaEscalasMensalTable();

  int? get idMinisterio => getField<int>('id_ministerio');
  set idMinisterio(int? value) => setField<int>('id_ministerio', value);

  DateTime? get mes => getField<DateTime>('mes');
  set mes(DateTime? value) => setField<DateTime>('mes', value);

  int? get totalAceitos => getField<int>('total_aceitos');
  set totalAceitos(int? value) => setField<int>('total_aceitos', value);

  int? get totalRecusados => getField<int>('total_recusados');
  set totalRecusados(int? value) => setField<int>('total_recusados', value);
}
