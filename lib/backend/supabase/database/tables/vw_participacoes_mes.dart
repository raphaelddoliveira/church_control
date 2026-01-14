import '../database.dart';

class VwParticipacoesMesTable extends SupabaseTable<VwParticipacoesMesRow> {
  @override
  String get tableName => 'vw_participacoes_mes';

  @override
  VwParticipacoesMesRow createRow(Map<String, dynamic> data) =>
      VwParticipacoesMesRow(data);
}

class VwParticipacoesMesRow extends SupabaseDataRow {
  VwParticipacoesMesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VwParticipacoesMesTable();

  String? get idMembro => getField<String>('id_membro');
  set idMembro(String? value) => setField<String>('id_membro', value);

  String? get nomeMembro => getField<String>('nome_membro');
  set nomeMembro(String? value) => setField<String>('nome_membro', value);

  int? get idMinisterio => getField<int>('id_ministerio');
  set idMinisterio(int? value) => setField<int>('id_ministerio', value);

  int? get qtdParticipacoes => getField<int>('qtd_participacoes');
  set qtdParticipacoes(int? value) => setField<int>('qtd_participacoes', value);

  String? get iniciais => getField<String>('iniciais');
  set iniciais(String? value) => setField<String>('iniciais', value);
}
