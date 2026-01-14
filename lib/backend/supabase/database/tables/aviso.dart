import '../database.dart';

class AvisoTable extends SupabaseTable<AvisoRow> {
  @override
  String get tableName => 'aviso';

  @override
  AvisoRow createRow(Map<String, dynamic> data) => AvisoRow(data);
}

class AvisoRow extends SupabaseDataRow {
  AvisoRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AvisoTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get nomeAviso => getField<String>('nome_aviso');
  set nomeAviso(String? value) => setField<String>('nome_aviso', value);

  DateTime? get dataHoraAviso => getField<DateTime>('data_hora_aviso');
  set dataHoraAviso(DateTime? value) =>
      setField<DateTime>('data_hora_aviso', value);

  String? get descricao => getField<String>('descricao');
  set descricao(String? value) => setField<String>('descricao', value);

  String? get criadoPor => getField<String>('criado_por');
  set criadoPor(String? value) => setField<String>('criado_por', value);

  String? get imagem => getField<String>('imagem');
  set imagem(String? value) => setField<String>('imagem', value);

  String? get categoria => getField<String>('categoria');
  set categoria(String? value) => setField<String>('categoria', value);

  String? get descricaoResumida => getField<String>('descricao_resumida');
  set descricaoResumida(String? value) =>
      setField<String>('descricao_resumida', value);

  DateTime? get expiraEm => getField<DateTime>('expira_em');
  set expiraEm(DateTime? value) => setField<DateTime>('expira_em', value);

  bool? get fixado => getField<bool>('fixado');
  set fixado(bool? value) => setField<bool>('fixado', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);
}
