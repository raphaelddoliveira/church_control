import '../database.dart';

class MembrosEscalasTable extends SupabaseTable<MembrosEscalasRow> {
  @override
  String get tableName => 'membros_escalas';

  @override
  MembrosEscalasRow createRow(Map<String, dynamic> data) =>
      MembrosEscalasRow(data);
}

class MembrosEscalasRow extends SupabaseDataRow {
  MembrosEscalasRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MembrosEscalasTable();

  int get idMembroEscala => getField<int>('id_membro_escala')!;
  set idMembroEscala(int value) => setField<int>('id_membro_escala', value);

  String? get idMembro => getField<String>('id_membro');
  set idMembro(String? value) => setField<String>('id_membro', value);

  int? get idEscala => getField<int>('id_escala');
  set idEscala(int? value) => setField<int>('id_escala', value);

  String? get funcaoEscala => getField<String>('funcao_escala');
  set funcaoEscala(String? value) => setField<String>('funcao_escala', value);

  String? get aceitouEscala => getField<String>('aceitou_escala');
  set aceitouEscala(String? value) => setField<String>('aceitou_escala', value);
}
