import 'package:flutter/material.dart';
import 'organizacao_provider.dart';

/// Serviço para gerenciar branding dinâmico (cores e logo) da organização.
class BrandingService {
  static final BrandingService _instance = BrandingService._internal();
  factory BrandingService() => _instance;
  BrandingService._internal();

  static BrandingService get instance => _instance;

  // Cores padrão do ChurchControl
  static const String _corPrimariaPadrao = '#4B39EF';
  static const String _corSecundariaPadrao = '#39D2C0';
  static const String _corTerciariaPadrao = '#EE8B60';
  static const String _corBackgroundPadrao = '#14181B';

  // Logo padrão
  static const String _logoPadrao = 'assets/images/logo_igj.png';

  /// Retorna a cor primária da organização ou padrão
  Color get corPrimaria {
    final org = OrganizacaoProvider.instance;
    if (org.permiteCoresCustom && org.corPrimaria != null) {
      return _parseColor(org.corPrimaria!);
    }
    return _parseColor(_corPrimariaPadrao);
  }

  /// Retorna a cor secundária da organização ou padrão
  Color get corSecundaria {
    final org = OrganizacaoProvider.instance;
    if (org.permiteCoresCustom && org.corSecundaria != null) {
      return _parseColor(org.corSecundaria!);
    }
    return _parseColor(_corSecundariaPadrao);
  }

  /// Retorna a cor terciária da organização ou padrão
  Color get corTerciaria {
    final org = OrganizacaoProvider.instance;
    if (org.permiteCoresCustom && org.corTerciaria != null) {
      return _parseColor(org.corTerciaria!);
    }
    return _parseColor(_corTerciariaPadrao);
  }

  /// Retorna a cor de background da organização ou padrão
  Color get corBackground {
    final org = OrganizacaoProvider.instance;
    if (org.permiteCoresCustom && org.corBackground != null) {
      return _parseColor(org.corBackground!);
    }
    return _parseColor(_corBackgroundPadrao);
  }

  /// Retorna a URL do logo ou o caminho do asset padrão
  String get logoUrl {
    final org = OrganizacaoProvider.instance;
    if (org.permiteLogoCustom && org.logoUrl != null && org.logoUrl!.isNotEmpty) {
      return org.logoUrl!;
    }
    return _logoPadrao;
  }

  /// Verifica se está usando logo customizado (URL) ou padrão (asset)
  bool get isLogoCustom {
    final org = OrganizacaoProvider.instance;
    return org.permiteLogoCustom &&
           org.logoUrl != null &&
           org.logoUrl!.isNotEmpty &&
           org.logoUrl!.startsWith('http');
  }

  /// Retorna o nome de exibição da organização
  String get nomeExibicao {
    final org = OrganizacaoProvider.instance;
    return org.nomeExibicao ?? 'Church Control';
  }

  /// Widget para exibir o logo (Network ou Asset)
  Widget buildLogo({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    if (isLogoCustom) {
      return Image.network(
        logoUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          // Fallback para logo padrão se falhar
          return Image.asset(
            _logoPadrao,
            width: width,
            height: height,
            fit: fit,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: width,
            height: height,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: corPrimaria,
              ),
            ),
          );
        },
      );
    } else {
      return Image.asset(
        logoUrl,
        width: width,
        height: height,
        fit: fit,
      );
    }
  }

  /// Converte string hex para Color
  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  /// Gera um ThemeData baseado nas cores da organização
  ThemeData buildTheme({Brightness brightness = Brightness.dark}) {
    return ThemeData(
      brightness: brightness,
      primaryColor: corPrimaria,
      colorScheme: ColorScheme.fromSeed(
        seedColor: corPrimaria,
        brightness: brightness,
        primary: corPrimaria,
        secondary: corSecundaria,
        tertiary: corTerciaria,
        surface: corBackground,
      ),
      scaffoldBackgroundColor: corBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: corBackground,
        foregroundColor: Colors.white,
      ),
      useMaterial3: false,
    );
  }
}
