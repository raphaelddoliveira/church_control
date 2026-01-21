import '../database.dart';

class MusicasTable extends SupabaseTable<MusicasRow> {
  @override
  String get tableName => 'musicas';

  @override
  MusicasRow createRow(Map<String, dynamic> data) => MusicasRow(data);
}

class MusicasRow extends SupabaseDataRow {
  MusicasRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MusicasTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get nome => getField<String>('nome');
  set nome(String? value) => setField<String>('nome', value);

  String? get artista => getField<String>('artista');
  set artista(String? value) => setField<String>('artista', value);

  String? get youtubeLink => getField<String>('youtube_link');
  set youtubeLink(String? value) => setField<String>('youtube_link', value);

  String? get cifraLink => getField<String>('cifra_link');
  set cifraLink(String? value) => setField<String>('cifra_link', value);

  String? get tomOriginal => getField<String>('tom_original');
  set tomOriginal(String? value) => setField<String>('tom_original', value);

  int? get idOrganizacao => getField<int>('id_organizacao');
  set idOrganizacao(int? value) => setField<int>('id_organizacao', value);
}
