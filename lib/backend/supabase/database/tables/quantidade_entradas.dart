import '../database.dart';

class QuantidadeEntradasTable extends SupabaseTable<QuantidadeEntradasRow> {
  @override
  String get tableName => 'quantidade_entradas';

  @override
  QuantidadeEntradasRow createRow(Map<String, dynamic> data) =>
      QuantidadeEntradasRow(data);
}

class QuantidadeEntradasRow extends SupabaseDataRow {
  QuantidadeEntradasRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => QuantidadeEntradasTable();

  String? get tipoEntrada => getField<String>('tipo_entrada');
  set tipoEntrada(String? value) => setField<String>('tipo_entrada', value);

  int? get quantidade => getField<int>('quantidade');
  set quantidade(int? value) => setField<int>('quantidade', value);
}
