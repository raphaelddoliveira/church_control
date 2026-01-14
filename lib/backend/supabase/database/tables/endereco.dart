import '../database.dart';

class EnderecoTable extends SupabaseTable<EnderecoRow> {
  @override
  String get tableName => 'endereco';

  @override
  EnderecoRow createRow(Map<String, dynamic> data) => EnderecoRow(data);
}

class EnderecoRow extends SupabaseDataRow {
  EnderecoRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EnderecoTable();

  int get idEndereco => getField<int>('id_endereco')!;
  set idEndereco(int value) => setField<int>('id_endereco', value);

  String? get nomeEndereco => getField<String>('nome_endereco');
  set nomeEndereco(String? value) => setField<String>('nome_endereco', value);

  String? get numero => getField<String>('numero');
  set numero(String? value) => setField<String>('numero', value);

  String? get complemento => getField<String>('complemento');
  set complemento(String? value) => setField<String>('complemento', value);

  String? get bairro => getField<String>('bairro');
  set bairro(String? value) => setField<String>('bairro', value);

  String? get cep => getField<String>('cep');
  set cep(String? value) => setField<String>('cep', value);

  int? get idCidade => getField<int>('id_cidade');
  set idCidade(int? value) => setField<int>('id_cidade', value);
}
