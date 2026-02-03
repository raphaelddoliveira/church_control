import '../database.dart';

class PlanosTable extends SupabaseTable<PlanosRow> {
  @override
  String get tableName => 'planos';

  @override
  PlanosRow createRow(Map<String, dynamic> data) => PlanosRow(data);
}

class PlanosRow extends SupabaseDataRow {
  PlanosRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PlanosTable();

  int get idPlano => getField<int>('id_plano')!;
  set idPlano(int value) => setField<int>('id_plano', value);

  String get nome => getField<String>('nome')!;
  set nome(String value) => setField<String>('nome', value);

  double? get precoMensal => getField<double>('preco_mensal');
  set precoMensal(double? value) => setField<double>('preco_mensal', value);

  int? get limiteMembros => getField<int>('limite_membros');
  set limiteMembros(int? value) => setField<int>('limite_membros', value);

  int? get limiteUsuarios => getField<int>('limite_usuarios');
  set limiteUsuarios(int? value) => setField<int>('limite_usuarios', value);

  bool? get permiteLogoCustom => getField<bool>('permite_logo_custom');
  set permiteLogoCustom(bool? value) =>
      setField<bool>('permite_logo_custom', value);

  bool? get permiteCoresCustom => getField<bool>('permite_cores_custom');
  set permiteCoresCustom(bool? value) =>
      setField<bool>('permite_cores_custom', value);

  List<String>? get modulosPermitidos =>
      getListField<String>('modulos_permitidos');
  set modulosPermitidos(List<String>? value) =>
      setListField<String>('modulos_permitidos', value);

  bool? get ativo => getField<bool>('ativo');
  set ativo(bool? value) => setField<bool>('ativo', value);
}
