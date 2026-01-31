import '../database.dart';

class ComunidadeTable extends SupabaseTable<ComunidadeRow> {
  @override
  String get tableName => 'comunidade';

  @override
  ComunidadeRow createRow(Map<String, dynamic> data) => ComunidadeRow(data);
}

class ComunidadeRow extends SupabaseDataRow {
  ComunidadeRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ComunidadeTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get nomeComunidade => getField<String>('nome_comunidade');
  set nomeComunidade(String? value) => setField<String>('nome_comunidade', value);

  String? get liderComunidade => getField<String>('lider_comunidade');
  set liderComunidade(String? value) => setField<String>('lider_comunidade', value);

  String? get fotoUrl => getField<String>('foto_url');
  set fotoUrl(String? value) => setField<String>('foto_url', value);

  String? get descricaoComunidade => getField<String>('descricao_comunidade');
  set descricaoComunidade(String? value) => setField<String>('descricao_comunidade', value);
}
