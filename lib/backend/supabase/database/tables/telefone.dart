import '../database.dart';

class TelefoneTable extends SupabaseTable<TelefoneRow> {
  @override
  String get tableName => 'telefone';

  @override
  TelefoneRow createRow(Map<String, dynamic> data) => TelefoneRow(data);
}

class TelefoneRow extends SupabaseDataRow {
  TelefoneRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => TelefoneTable();

  int get idTelefone => getField<int>('id_telefone')!;
  set idTelefone(int value) => setField<int>('id_telefone', value);

  String? get numeroTelefone => getField<String>('numero_telefone');
  set numeroTelefone(String? value) =>
      setField<String>('numero_telefone', value);

  String? get idMembro => getField<String>('id_membro');
  set idMembro(String? value) => setField<String>('id_membro', value);
}
