import 'package:flutter/material.dart';
import '/backend/supabase/supabase.dart';
import '/auth/supabase_auth/auth_util.dart';

/// Provider global para gerenciar o contexto da organização logada.
/// Carrega automaticamente os dados da organização do usuário logado.
class OrganizacaoProvider extends ChangeNotifier {
  static final OrganizacaoProvider _instance = OrganizacaoProvider._internal();
  factory OrganizacaoProvider() => _instance;
  OrganizacaoProvider._internal();

  static OrganizacaoProvider get instance => _instance;

  // Estado
  OrganizacaoRow? _organizacao;
  OrganizacaoConfigRow? _config;
  PlanosRow? _plano;
  MembrosRow? _membroLogado;
  bool _isLoading = false;
  String? _error;

  // Getters
  OrganizacaoRow? get organizacao => _organizacao;
  OrganizacaoConfigRow? get config => _config;
  PlanosRow? get plano => _plano;
  MembrosRow? get membroLogado => _membroLogado;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoaded => _organizacao != null;

  // Getters de conveniência
  int? get idOrganizacao => _organizacao?.idOrganizacao;
  String? get nomeOrganizacao => _organizacao?.nomeOrganizacao;
  String? get slug => _organizacao?.slug;

  // Branding
  String? get logoUrl => _config?.logoUrl;
  String? get corPrimaria => _config?.corPrimaria;
  String? get corSecundaria => _config?.corSecundaria;
  String? get corTerciaria => _config?.corTerciaria;
  String? get corBackground => _config?.corBackground;
  String? get nomeExibicao => _config?.nomeExibicao ?? _organizacao?.nomeOrganizacao;

  // Plano
  String? get nomePlano => _plano?.nome;
  int? get limiteMembros => _plano?.limiteMembros;
  int? get limiteUsuarios => _plano?.limiteUsuarios;
  bool get permiteLogoCustom => _plano?.permiteLogoCustom ?? false;
  bool get permiteCoresCustom => _plano?.permiteCoresCustom ?? false;
  List<String>? get modulosPermitidos => _plano?.modulosPermitidos;

  /// Carrega os dados da organização do usuário logado
  Future<void> carregar() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Buscar membro logado pelo id_auth
      final membroRows = await MembrosTable().queryRows(
        queryFn: (q) => q.eq('id_auth', currentUserUid),
      );

      if (membroRows.isEmpty) {
        _error = 'Membro não encontrado';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _membroLogado = membroRows.first;
      final idOrg = _membroLogado?.idOrganizacao;

      if (idOrg == null) {
        _error = 'Organização não definida para este membro';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 2. Buscar organização
      final orgRows = await OrganizacaoTable().queryRows(
        queryFn: (q) => q.eq('id_organizacao', idOrg),
      );

      if (orgRows.isNotEmpty) {
        _organizacao = orgRows.first;
      }

      // 3. Buscar configuração de branding (pode não existir ainda)
      try {
        final configRows = await OrganizacaoConfigTable().queryRows(
          queryFn: (q) => q.eq('id_organizacao', idOrg),
        );
        if (configRows.isNotEmpty) {
          _config = configRows.first;
        }
      } catch (e) {
        // Config não existe ainda, usar padrões
        _config = null;
      }

      // 4. Buscar plano da organização
      final idPlano = _organizacao?.idPlano ?? 1;
      try {
        final planoRows = await PlanosTable().queryRows(
          queryFn: (q) => q.eq('id_plano', idPlano),
        );
        if (planoRows.isNotEmpty) {
          _plano = planoRows.first;
        }
      } catch (e) {
        // Plano não encontrado, usar padrão
        _plano = null;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar organização: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Recarrega os dados
  Future<void> recarregar() async {
    _organizacao = null;
    _config = null;
    _plano = null;
    _membroLogado = null;
    await carregar();
  }

  /// Limpa os dados (logout)
  void limpar() {
    _organizacao = null;
    _config = null;
    _plano = null;
    _membroLogado = null;
    _error = null;
    notifyListeners();
  }

  /// Verifica se um módulo está disponível no plano atual
  bool moduloDisponivel(String modulo) {
    if (_plano == null) return true; // Sem plano definido, libera tudo
    final modulos = _plano!.modulosPermitidos;
    if (modulos == null || modulos.isEmpty) return true;
    if (modulos.contains('todos')) return true;
    return modulos.contains(modulo.toLowerCase());
  }

  /// Verifica se atingiu o limite de membros
  Future<bool> atingiuLimiteMembros() async {
    if (_plano?.limiteMembros == null) return false; // Sem limite

    try {
      final membros = await MembrosTable().queryRows(
        queryFn: (q) => q.eq('id_organizacao', idOrganizacao ?? 0),
      );
      return membros.length >= (_plano!.limiteMembros ?? 0);
    } catch (e) {
      return false;
    }
  }
}
