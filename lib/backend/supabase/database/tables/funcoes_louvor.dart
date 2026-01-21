import '../database.dart';

class FuncoesLouvorTable extends SupabaseTable<FuncoesLouvorRow> {
  @override
  String get tableName => 'funcoes_louvor';

  @override
  FuncoesLouvorRow createRow(Map<String, dynamic> data) => FuncoesLouvorRow(data);
}

class FuncoesLouvorRow extends SupabaseDataRow {
  FuncoesLouvorRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FuncoesLouvorTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get nome => getField<String>('nome');
  set nome(String? value) => setField<String>('nome', value);

  String? get icone => getField<String>('icone');
  set icone(String? value) => setField<String>('icone', value);

  int? get ordem => getField<int>('ordem');
  set ordem(int? value) => setField<int>('ordem', value);

  bool? get ativo => getField<bool>('ativo');
  set ativo(bool? value) => setField<bool>('ativo', value);
}
