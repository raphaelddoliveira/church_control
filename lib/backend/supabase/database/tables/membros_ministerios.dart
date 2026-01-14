import '../database.dart';

class MembrosMinisteriosTable extends SupabaseTable<MembrosMinisteriosRow> {
  @override
  String get tableName => 'membros_ministerios';

  @override
  MembrosMinisteriosRow createRow(Map<String, dynamic> data) =>
      MembrosMinisteriosRow(data);
}

class MembrosMinisteriosRow extends SupabaseDataRow {
  MembrosMinisteriosRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MembrosMinisteriosTable();

  int get idMembroMinisterio => getField<int>('id_membro_ministerio')!;
  set idMembroMinisterio(int value) =>
      setField<int>('id_membro_ministerio', value);

  String? get cargo => getField<String>('cargo');
  set cargo(String? value) => setField<String>('cargo', value);

  String? get idMembro => getField<String>('id_membro');
  set idMembro(String? value) => setField<String>('id_membro', value);

  int? get idMinisterio => getField<int>('id_ministerio');
  set idMinisterio(int? value) => setField<int>('id_ministerio', value);
}
