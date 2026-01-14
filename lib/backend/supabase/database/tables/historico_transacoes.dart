import '../database.dart';

class HistoricoTransacoesTable extends SupabaseTable<HistoricoTransacoesRow> {
  @override
  String get tableName => 'historico_transacoes';

  @override
  HistoricoTransacoesRow createRow(Map<String, dynamic> data) =>
      HistoricoTransacoesRow(data);
}

class HistoricoTransacoesRow extends SupabaseDataRow {
  HistoricoTransacoesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => HistoricoTransacoesTable();

  int get idTransacao => getField<int>('id_transacao')!;
  set idTransacao(int value) => setField<int>('id_transacao', value);

  String? get relatorio => getField<String>('relatorio');
  set relatorio(String? value) => setField<String>('relatorio', value);

  int? get idCaixa => getField<int>('id_caixa');
  set idCaixa(int? value) => setField<int>('id_caixa', value);

  String? get idResponsavel => getField<String>('id_responsavel');
  set idResponsavel(String? value) => setField<String>('id_responsavel', value);

  DateTime? get dataHistorico => getField<DateTime>('data_historico');
  set dataHistorico(DateTime? value) =>
      setField<DateTime>('data_historico', value);
}
