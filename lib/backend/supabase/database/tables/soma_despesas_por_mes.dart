import '../database.dart';

class SomaDespesasPorMesTable extends SupabaseTable<SomaDespesasPorMesRow> {
  @override
  String get tableName => 'soma_despesas_por_mes';

  @override
  SomaDespesasPorMesRow createRow(Map<String, dynamic> data) =>
      SomaDespesasPorMesRow(data);
}

class SomaDespesasPorMesRow extends SupabaseDataRow {
  SomaDespesasPorMesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SomaDespesasPorMesTable();

  double? get totalDespesa => getField<double>('total_despesa');
  set totalDespesa(double? value) => setField<double>('total_despesa', value);

  String? get mes => getField<String>('mes');
  set mes(String? value) => setField<String>('mes', value);

  double? get ano => getField<double>('ano');
  set ano(double? value) => setField<double>('ano', value);
}
