import '../database.dart';

class ViewFluxoFinanceiroProjetadoTable
    extends SupabaseTable<ViewFluxoFinanceiroProjetadoRow> {
  @override
  String get tableName => 'view_fluxo_financeiro_projetado';

  @override
  ViewFluxoFinanceiroProjetadoRow createRow(Map<String, dynamic> data) =>
      ViewFluxoFinanceiroProjetadoRow(data);
}

class ViewFluxoFinanceiroProjetadoRow extends SupabaseDataRow {
  ViewFluxoFinanceiroProjetadoRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ViewFluxoFinanceiroProjetadoTable();

  String? get mesAno => getField<String>('mes_ano');
  set mesAno(String? value) => setField<String>('mes_ano', value);

  double? get totalEntradas => getField<double>('total_entradas');
  set totalEntradas(double? value) => setField<double>('total_entradas', value);

  double? get totalSaidas => getField<double>('total_saidas');
  set totalSaidas(double? value) => setField<double>('total_saidas', value);

  double? get saldoMensal => getField<double>('saldo_mensal');
  set saldoMensal(double? value) => setField<double>('saldo_mensal', value);

  bool? get isProjection => getField<bool>('is_projection');
  set isProjection(bool? value) => setField<bool>('is_projection', value);
}
