import '../database.dart';

class VwCriacoesMesAtualTable extends SupabaseTable<VwCriacoesMesAtualRow> {
  @override
  String get tableName => 'vw_criacoes_mes_atual';

  @override
  VwCriacoesMesAtualRow createRow(Map<String, dynamic> data) =>
      VwCriacoesMesAtualRow(data);
}

class VwCriacoesMesAtualRow extends SupabaseDataRow {
  VwCriacoesMesAtualRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VwCriacoesMesAtualTable();

  String? get tipo => getField<String>('tipo');
  set tipo(String? value) => setField<String>('tipo', value);

  DateTime? get mes => getField<DateTime>('mes');
  set mes(DateTime? value) => setField<DateTime>('mes', value);

  String? get nome => getField<String>('nome');
  set nome(String? value) => setField<String>('nome', value);

  DateTime? get dataField => getField<DateTime>('data');
  set dataField(DateTime? value) => setField<DateTime>('data', value);
}
