import '../database.dart';

class CaixaTable extends SupabaseTable<CaixaRow> {
  @override
  String get tableName => 'caixa';

  @override
  CaixaRow createRow(Map<String, dynamic> data) => CaixaRow(data);
}

class CaixaRow extends SupabaseDataRow {
  CaixaRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CaixaTable();

  int get idCaixa => getField<int>('id_caixa')!;
  set idCaixa(int value) => setField<int>('id_caixa', value);

  double? get saldo => getField<double>('saldo');
  set saldo(double? value) => setField<double>('saldo', value);

  double? get extrato => getField<double>('extrato');
  set extrato(double? value) => setField<double>('extrato', value);

  DateTime? get dataSaldo => getField<DateTime>('data_saldo');
  set dataSaldo(DateTime? value) => setField<DateTime>('data_saldo', value);

  PostgresTime? get hora => getField<PostgresTime>('hora');
  set hora(PostgresTime? value) => setField<PostgresTime>('hora', value);

  double? get valorSaldo => getField<double>('valor_saldo');
  set valorSaldo(double? value) => setField<double>('valor_saldo', value);

  double? get saldoDiarioInicial => getField<double>('saldo_diario_inicial');
  set saldoDiarioInicial(double? value) =>
      setField<double>('saldo_diario_inicial', value);

  double? get saldoDiarioFinal => getField<double>('saldo_diario_final');
  set saldoDiarioFinal(double? value) =>
      setField<double>('saldo_diario_final', value);
}
