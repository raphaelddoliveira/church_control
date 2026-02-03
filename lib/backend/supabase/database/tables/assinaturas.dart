import '../database.dart';

class AssinaturasTable extends SupabaseTable<AssinaturasRow> {
  @override
  String get tableName => 'assinaturas';

  @override
  AssinaturasRow createRow(Map<String, dynamic> data) => AssinaturasRow(data);
}

class AssinaturasRow extends SupabaseDataRow {
  AssinaturasRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AssinaturasTable();

  int get idAssinatura => getField<int>('id_assinatura')!;
  set idAssinatura(int value) => setField<int>('id_assinatura', value);

  int? get idOrganizacao => getField<int>('id_organizacao');
  set idOrganizacao(int? value) => setField<int>('id_organizacao', value);

  int? get idPlano => getField<int>('id_plano');
  set idPlano(int? value) => setField<int>('id_plano', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  DateTime? get dataInicio => getField<DateTime>('data_inicio');
  set dataInicio(DateTime? value) => setField<DateTime>('data_inicio', value);

  DateTime? get dataFim => getField<DateTime>('data_fim');
  set dataFim(DateTime? value) => setField<DateTime>('data_fim', value);

  String? get stripeSubscriptionId => getField<String>('stripe_subscription_id');
  set stripeSubscriptionId(String? value) =>
      setField<String>('stripe_subscription_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
