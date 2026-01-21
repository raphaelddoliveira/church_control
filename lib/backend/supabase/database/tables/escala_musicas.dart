import '../database.dart';

class EscalaMusicasTable extends SupabaseTable<EscalaMusicasRow> {
  @override
  String get tableName => 'escala_musicas';

  @override
  EscalaMusicasRow createRow(Map<String, dynamic> data) => EscalaMusicasRow(data);
}

class EscalaMusicasRow extends SupabaseDataRow {
  EscalaMusicasRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => EscalaMusicasTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int? get idEscala => getField<int>('id_escala');
  set idEscala(int? value) => setField<int>('id_escala', value);

  int? get idMusica => getField<int>('id_musica');
  set idMusica(int? value) => setField<int>('id_musica', value);

  String? get tomEscala => getField<String>('tom_escala');
  set tomEscala(String? value) => setField<String>('tom_escala', value);

  int? get ordem => getField<int>('ordem');
  set ordem(int? value) => setField<int>('ordem', value);

  String? get observacoes => getField<String>('observacoes');
  set observacoes(String? value) => setField<String>('observacoes', value);
}
