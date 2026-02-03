import '../database.dart';

class MembrosTable extends SupabaseTable<MembrosRow> {
  @override
  String get tableName => 'membros';

  @override
  MembrosRow createRow(Map<String, dynamic> data) => MembrosRow(data);
}

class MembrosRow extends SupabaseDataRow {
  MembrosRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MembrosTable();

  String get idMembro => getField<String>('id_membro')!;
  set idMembro(String value) => setField<String>('id_membro', value);

  String get nomeMembro => getField<String>('nome_membro')!;
  set nomeMembro(String value) => setField<String>('nome_membro', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  DateTime? get dataNascimento => getField<DateTime>('data_nascimento');
  set dataNascimento(DateTime? value) =>
      setField<DateTime>('data_nascimento', value);

  int? get idEndereco => getField<int>('id_endereco');
  set idEndereco(int? value) => setField<int>('id_endereco', value);

  int? get idNivelAcesso => getField<int>('id_nivel_acesso');
  set idNivelAcesso(int? value) => setField<int>('id_nivel_acesso', value);

  bool? get ativo => getField<bool>('ativo');
  set ativo(bool? value) => setField<bool>('ativo', value);

  String? get idAuth => getField<String>('id_auth');
  set idAuth(String? value) => setField<String>('id_auth', value);

  DateTime? get criadoEm => getField<DateTime>('criado_em');
  set criadoEm(DateTime? value) => setField<DateTime>('criado_em', value);

  String? get fotoUrl => getField<String>('fotoUrl');
  set fotoUrl(String? value) => setField<String>('fotoUrl', value);

  DateTime? get atualizadoEm => getField<DateTime>('atualizado_em');
  set atualizadoEm(DateTime? value) =>
      setField<DateTime>('atualizado_em', value);

  String? get dataNascimentoFlutterfow =>
      getField<String>('data_nascimento_flutterfow');
  set dataNascimentoFlutterfow(String? value) =>
      setField<String>('data_nascimento_flutterfow', value);

  bool? get podeAcessarAreaMembro => getField<bool>('pode_acessar_area_membro');
  set podeAcessarAreaMembro(bool? value) =>
      setField<bool>('pode_acessar_area_membro', value);

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String? get cpf => getField<String>('cpf');
  set cpf(String? value) => setField<String>('cpf', value);

  int? get idOrganizacao => getField<int>('id_organizacao');
  set idOrganizacao(int? value) => setField<int>('id_organizacao', value);
}
