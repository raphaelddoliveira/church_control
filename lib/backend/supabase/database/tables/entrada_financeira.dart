import '../database.dart';

class EntradaFinanceiraTable extends SupabaseTable<EntradaFinanceiraRow> {
  @override
  String get tableName => 'entrada_financeira';

  @override
  EntradaFinanceiraRow createRow(Map<String, dynamic> data) =>
      EntradaFinanceiraRow(data);
}

class EntradaFinanceiraRow extends SupabaseDataRow {
  EntradaFinanceiraRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EntradaFinanceiraTable();

  int get idEntrada => getField<int>('id_entrada')!;
  set idEntrada(int value) => setField<int>('id_entrada', value);

  int? get idOrganizacao => getField<int>('id_organizacao');
  set idOrganizacao(int? value) => setField<int>('id_organizacao', value);

  String? get idMembro => getField<String>('id_membro');
  set idMembro(String? value) => setField<String>('id_membro', value);

  String? get descricao => getField<String>('descricao');
  set descricao(String? value) => setField<String>('descricao', value);

  double? get valorEntrada => getField<double>('valor_entrada');
  set valorEntrada(double? value) => setField<double>('valor_entrada', value);

  String? get tipoEntrada => getField<String>('tipo_entrada');
  set tipoEntrada(String? value) => setField<String>('tipo_entrada', value);

  int? get idCaixa => getField<int>('id_caixa');
  set idCaixa(int? value) => setField<int>('id_caixa', value);

  DateTime? get dataEntrada => getField<DateTime>('data_entrada');
  set dataEntrada(DateTime? value) => setField<DateTime>('data_entrada', value);
}
