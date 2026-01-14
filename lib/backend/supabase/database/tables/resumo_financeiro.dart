import '../database.dart';

class ResumoFinanceiroTable extends SupabaseTable<ResumoFinanceiroRow> {
  @override
  String get tableName => 'resumo_financeiro';

  @override
  ResumoFinanceiroRow createRow(Map<String, dynamic> data) =>
      ResumoFinanceiroRow(data);
}

class ResumoFinanceiroRow extends SupabaseDataRow {
  ResumoFinanceiroRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ResumoFinanceiroTable();

  DateTime? get mesReferencia => getField<DateTime>('mes_referencia');
  set mesReferencia(DateTime? value) =>
      setField<DateTime>('mes_referencia', value);

  double? get totalEntradas => getField<double>('total_entradas');
  set totalEntradas(double? value) => setField<double>('total_entradas', value);

  double? get totalSaidas => getField<double>('total_saidas');
  set totalSaidas(double? value) => setField<double>('total_saidas', value);

  double? get saldoFinal => getField<double>('saldo_final');
  set saldoFinal(double? value) => setField<double>('saldo_final', value);

  double? get saldoTotal => getField<double>('saldo_total');
  set saldoTotal(double? value) => setField<double>('saldo_total', value);
}
