import '../database.dart';

class OrganizacaoTable extends SupabaseTable<OrganizacaoRow> {
  @override
  String get tableName => 'organizacao';

  @override
  OrganizacaoRow createRow(Map<String, dynamic> data) => OrganizacaoRow(data);
}

class OrganizacaoRow extends SupabaseDataRow {
  OrganizacaoRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => OrganizacaoTable();

  int get idOrganizacao => getField<int>('id_organizacao')!;
  set idOrganizacao(int value) => setField<int>('id_organizacao', value);

  String get nomeOrganizacao => getField<String>('nome_organizacao')!;
  set nomeOrganizacao(String value) =>
      setField<String>('nome_organizacao', value);

  String? get cnpj => getField<String>('cnpj');
  set cnpj(String? value) => setField<String>('cnpj', value);

  int? get idEndereco => getField<int>('id_endereco');
  set idEndereco(int? value) => setField<int>('id_endereco', value);

  String? get slug => getField<String>('slug');
  set slug(String? value) => setField<String>('slug', value);

  int? get idPlano => getField<int>('id_plano');
  set idPlano(int? value) => setField<int>('id_plano', value);

  bool? get ativo => getField<bool>('ativo');
  set ativo(bool? value) => setField<bool>('ativo', value);

  DateTime? get dataCadastro => getField<DateTime>('data_cadastro');
  set dataCadastro(DateTime? value) =>
      setField<DateTime>('data_cadastro', value);
}
