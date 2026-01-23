import '../database.dart';

class DevocionalTable extends SupabaseTable<DevocionalRow> {
  @override
  String get tableName => 'devocional';

  @override
  DevocionalRow createRow(Map<String, dynamic> data) => DevocionalRow(data);
}

class DevocionalRow extends SupabaseDataRow {
  DevocionalRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => DevocionalTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get titulo => getField<String>('titulo');
  set titulo(String? value) => setField<String>('titulo', value);

  String? get textoDevocional => getField<String>('texto_devocional');
  set textoDevocional(String? value) => setField<String>('texto_devocional', value);

  String? get criadoPor => getField<String>('criado_por');
  set criadoPor(String? value) => setField<String>('criado_por', value);

  String? get linkMusica => getField<String>('link_música');
  set linkMusica(String? value) => setField<String>('link_música', value);

  String? get imagem => getField<String>('imagem');
  set imagem(String? value) => setField<String>('imagem', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);
}
