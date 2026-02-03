import '../database.dart';

class OrganizacaoConfigTable extends SupabaseTable<OrganizacaoConfigRow> {
  @override
  String get tableName => 'organizacao_config';

  @override
  OrganizacaoConfigRow createRow(Map<String, dynamic> data) =>
      OrganizacaoConfigRow(data);
}

class OrganizacaoConfigRow extends SupabaseDataRow {
  OrganizacaoConfigRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => OrganizacaoConfigTable();

  int get idOrganizacao => getField<int>('id_organizacao')!;
  set idOrganizacao(int value) => setField<int>('id_organizacao', value);

  String? get logoUrl => getField<String>('logo_url');
  set logoUrl(String? value) => setField<String>('logo_url', value);

  String? get faviconUrl => getField<String>('favicon_url');
  set faviconUrl(String? value) => setField<String>('favicon_url', value);

  String? get corPrimaria => getField<String>('cor_primaria');
  set corPrimaria(String? value) => setField<String>('cor_primaria', value);

  String? get corSecundaria => getField<String>('cor_secundaria');
  set corSecundaria(String? value) => setField<String>('cor_secundaria', value);

  String? get corTerciaria => getField<String>('cor_terciaria');
  set corTerciaria(String? value) => setField<String>('cor_terciaria', value);

  String? get corBackground => getField<String>('cor_background');
  set corBackground(String? value) => setField<String>('cor_background', value);

  String? get nomeExibicao => getField<String>('nome_exibicao');
  set nomeExibicao(String? value) => setField<String>('nome_exibicao', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}
