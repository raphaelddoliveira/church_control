import '../database.dart';

class ArquivosTable extends SupabaseTable<ArquivosRow> {
  @override
  String get tableName => 'arquivos';

  @override
  ArquivosRow createRow(Map<String, dynamic> data) => ArquivosRow(data);
}

class ArquivosRow extends SupabaseDataRow {
  ArquivosRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ArquivosTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get linkArquivo => getField<String>('link_arquivo');
  set linkArquivo(String? value) => setField<String>('link_arquivo', value);

  int? get idEscala => getField<int>('id_escala');
  set idEscala(int? value) => setField<int>('id_escala', value);

  String? get nomeArquivo => getField<String>('nome_arquivo');
  set nomeArquivo(String? value) => setField<String>('nome_arquivo', value);
}
