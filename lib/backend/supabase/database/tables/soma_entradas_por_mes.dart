import '../database.dart';

class SomaEntradasPorMesTable extends SupabaseTable<SomaEntradasPorMesRow> {
  @override
  String get tableName => 'soma_entradas_por_mes';

  @override
  SomaEntradasPorMesRow createRow(Map<String, dynamic> data) =>
      SomaEntradasPorMesRow(data);
}

class SomaEntradasPorMesRow extends SupabaseDataRow {
  SomaEntradasPorMesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SomaEntradasPorMesTable();

  double? get totalEntrada => getField<double>('total_entrada');
  set totalEntrada(double? value) => setField<double>('total_entrada', value);

  String? get mes => getField<String>('mes');
  set mes(String? value) => setField<String>('mes', value);

  double? get ano => getField<double>('ano');
  set ano(double? value) => setField<double>('ano', value);
}
