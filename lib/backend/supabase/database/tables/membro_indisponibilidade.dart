import '../database.dart';

class MembroIndisponibilidadeTable
    extends SupabaseTable<MembroIndisponibilidadeRow> {
  @override
  String get tableName => 'membro_indisponibilidade';

  @override
  MembroIndisponibilidadeRow createRow(Map<String, dynamic> data) =>
      MembroIndisponibilidadeRow(data);
}

class MembroIndisponibilidadeRow extends SupabaseDataRow {
  MembroIndisponibilidadeRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MembroIndisponibilidadeTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String? get idMembro => getField<String>('id_membro');
  set idMembro(String? value) => setField<String>('id_membro', value);

  DateTime? get dataInicio => getField<DateTime>('data_inicio');
  set dataInicio(DateTime? value) => setField<DateTime>('data_inicio', value);

  DateTime? get dataFim => getField<DateTime>('data_fim');
  set dataFim(DateTime? value) => setField<DateTime>('data_fim', value);

  String? get motivo => getField<String>('motivo');
  set motivo(String? value) => setField<String>('motivo', value);

  DateTime? get criadoEm => getField<DateTime>('criado_em');
  set criadoEm(DateTime? value) => setField<DateTime>('criado_em', value);
}
