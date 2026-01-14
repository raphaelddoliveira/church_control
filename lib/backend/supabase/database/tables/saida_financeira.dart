import '../database.dart';

class SaidaFinanceiraTable extends SupabaseTable<SaidaFinanceiraRow> {
  @override
  String get tableName => 'saida_financeira';

  @override
  SaidaFinanceiraRow createRow(Map<String, dynamic> data) =>
      SaidaFinanceiraRow(data);
}

class SaidaFinanceiraRow extends SupabaseDataRow {
  SaidaFinanceiraRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SaidaFinanceiraTable();

  int get idSaida => getField<int>('id_saida')!;
  set idSaida(int value) => setField<int>('id_saida', value);

  String? get idMembro => getField<String>('id_membro');
  set idMembro(String? value) => setField<String>('id_membro', value);

  String? get descricao => getField<String>('descricao');
  set descricao(String? value) => setField<String>('descricao', value);

  double? get valorDespesa => getField<double>('valor_despesa');
  set valorDespesa(double? value) => setField<double>('valor_despesa', value);

  String? get categoria => getField<String>('categoria');
  set categoria(String? value) => setField<String>('categoria', value);

  DateTime? get dataSaida => getField<DateTime>('data_saida');
  set dataSaida(DateTime? value) => setField<DateTime>('data_saida', value);

  DateTime? get dataVencimento => getField<DateTime>('data_vencimento');
  set dataVencimento(DateTime? value) =>
      setField<DateTime>('data_vencimento', value);

  String? get situacao => getField<String>('situacao');
  set situacao(String? value) => setField<String>('situacao', value);
}
