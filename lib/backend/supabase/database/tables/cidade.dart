import '../database.dart';

class CidadeTable extends SupabaseTable<CidadeRow> {
  @override
  String get tableName => 'cidade';

  @override
  CidadeRow createRow(Map<String, dynamic> data) => CidadeRow(data);
}

class CidadeRow extends SupabaseDataRow {
  CidadeRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CidadeTable();

  int get idCidade => getField<int>('id_cidade')!;
  set idCidade(int value) => setField<int>('id_cidade', value);

  String get nomeCidade => getField<String>('nome_cidade')!;
  set nomeCidade(String value) => setField<String>('nome_cidade', value);

  int? get idEstado => getField<int>('id_estado');
  set idEstado(int? value) => setField<int>('id_estado', value);
}
