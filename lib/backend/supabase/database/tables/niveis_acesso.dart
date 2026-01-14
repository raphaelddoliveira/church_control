import '../database.dart';

class NiveisAcessoTable extends SupabaseTable<NiveisAcessoRow> {
  @override
  String get tableName => 'niveis_acesso';

  @override
  NiveisAcessoRow createRow(Map<String, dynamic> data) => NiveisAcessoRow(data);
}

class NiveisAcessoRow extends SupabaseDataRow {
  NiveisAcessoRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => NiveisAcessoTable();

  int get idNivel => getField<int>('id_nivel')!;
  set idNivel(int value) => setField<int>('id_nivel', value);

  String get nomeNivel => getField<String>('nome_nivel')!;
  set nomeNivel(String value) => setField<String>('nome_nivel', value);

  String? get descricao => getField<String>('descricao');
  set descricao(String? value) => setField<String>('descricao', value);
}
