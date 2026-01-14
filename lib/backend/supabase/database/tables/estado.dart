import '../database.dart';

class EstadoTable extends SupabaseTable<EstadoRow> {
  @override
  String get tableName => 'estado';

  @override
  EstadoRow createRow(Map<String, dynamic> data) => EstadoRow(data);
}

class EstadoRow extends SupabaseDataRow {
  EstadoRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EstadoTable();

  int get idEstado => getField<int>('id_estado')!;
  set idEstado(int value) => setField<int>('id_estado', value);

  String? get sigla => getField<String>('sigla');
  set sigla(String? value) => setField<String>('sigla', value);

  String get nomeEstado => getField<String>('nome_estado')!;
  set nomeEstado(String value) => setField<String>('nome_estado', value);
}
