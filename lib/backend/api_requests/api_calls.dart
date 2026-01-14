import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class EnvioDadosEscalaCall {
  static Future<ApiCallResponse> call({
    String? nome = 'null',
    String? funcao = 'null',
    String? dataehoraescala = 'null',
    String? emailmembro = 'null',
    String? nomeescala = 'null',
    String? informacoes = 'null',
    String? escalaid = 'null',
    String? membroid = 'null',
    String? infomembro = 'null',
    String? emailenvio = 'null',
    String? password = 'null',
    int? nivelacesso,
    String? arquivosescala = 'null',
  }) async {
    final ffApiRequestBody = '''
{
  "nomemembro": "${escapeStringForJson(nome)}",
  "funcaoescala": "${escapeStringForJson(funcao)}",
  "dataescala": "${escapeStringForJson(dataehoraescala)}",
  "email": "${escapeStringForJson(emailmembro)}",
  "nomeescala": "${escapeStringForJson(nomeescala)}",
  "informacoes": "${escapeStringForJson(informacoes)}",
  "escalaid": "${escapeStringForJson(escalaid)}",
  "membro": "${escapeStringForJson(membroid)}",
  "infomembro": "${escapeStringForJson(infomembro)}",
  "emailenvio": "${escapeStringForJson(emailenvio)}",
  "password": "${escapeStringForJson(password)}",
  "nivelacesso": "${nivelacesso}",
  "arquivos": "${escapeStringForJson(arquivosescala)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Envio dados escala',
      apiUrl: 'https://automacao.journeyup.io/webhook/envioescala',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CriarUsuarioCall {
  static Future<ApiCallResponse> call({
    String? email = '',
    String? senha = '',
  }) async {
    final ffApiRequestBody = '''
{
  "email": "${escapeStringForJson(email)}",
  "password": "${escapeStringForJson(senha)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Criar Usuario',
      apiUrl:
          'https://eptvpknqixnhommqrcat.supabase.co/functions/v1/create-user',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVwdHZwa25xaXhuaG9tbXFyY2F0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwMzk2NjcsImV4cCI6MjA3MDYxNTY2N30.WQrbCEu2uJt4hKU7a_vzuSTxvj2OwjD3mbFC4j0HK6Q',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
