import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '/backend/supabase/supabase.dart';

import '/auth/base_auth_user_provider.dart';

import '/main.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'serialization_util.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) => appStateNotifier.loggedIn
          ? PaginadetransicaoWidget()
          : LoginTesteWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => appStateNotifier.loggedIn
              ? PaginadetransicaoWidget()
              : LoginTesteWidget(),
        ),
        FFRoute(
          name: PastorFinancasWidget.routeName,
          path: PastorFinancasWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PastorFinancasWidget(),
        ),
        FFRoute(
          name: PageMembrosPastorWidget.routeName,
          path: PageMembrosPastorWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageMembrosPastorWidget(),
        ),
        FFRoute(
          name: PageMembrosSecretariaWidget.routeName,
          path: PageMembrosSecretariaWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageMembrosSecretariaWidget(),
        ),
        FFRoute(
          name: HomepagePastorWidget.routeName,
          path: HomepagePastorWidget.routePath,
          requireAuth: true,
          builder: (context, params) => HomepagePastorWidget(),
        ),
        FFRoute(
          name: PageMinisteriosSecretariaWidget.routeName,
          path: PageMinisteriosSecretariaWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageMinisteriosSecretariaWidget(),
        ),
        FFRoute(
          name: PageCelulasSecretariaWidget.routeName,
          path: PageCelulasSecretariaWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageCelulasSecretariaWidget(),
        ),
        FFRoute(
          name: PageMinisteriosAdminWidget.routeName,
          path: PageMinisteriosAdminWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageMinisteriosAdminWidget(),
        ),
        FFRoute(
          name: PageMembrosDetalhesSecretariaWidget.routeName,
          path: PageMembrosDetalhesSecretariaWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageMembrosDetalhesSecretariaWidget(
            idmembro: params.getParam(
              'idmembro',
              ParamType.String,
            ),
            idendereco: params.getParam(
              'idendereco',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: HomepageLiderWidget.routeName,
          path: HomepageLiderWidget.routePath,
          requireAuth: true,
          builder: (context, params) => HomepageLiderWidget(),
        ),
        FFRoute(
          name: PageMembrosNovoSecretariaWidget.routeName,
          path: PageMembrosNovoSecretariaWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageMembrosNovoSecretariaWidget(),
        ),
        FFRoute(
          name: PageHomeSecretariaWidget.routeName,
          path: PageHomeSecretariaWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageHomeSecretariaWidget(),
        ),
        FFRoute(
          name: PageMinisteriosPastorWidget.routeName,
          path: PageMinisteriosPastorWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageMinisteriosPastorWidget(),
        ),
        FFRoute(
          name: PageMinisterioDetalhesSecretariaWidget.routeName,
          path: PageMinisterioDetalhesSecretariaWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageMinisterioDetalhesSecretariaWidget(
            idministerio: params.getParam(
              'idministerio',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: PageMinisterioDetalhesPastorWidget.routeName,
          path: PageMinisterioDetalhesPastorWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageMinisterioDetalhesPastorWidget(
            idministerio: params.getParam(
              'idministerio',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: PageMembrosDetalhesPastorWidget.routeName,
          path: PageMembrosDetalhesPastorWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageMembrosDetalhesPastorWidget(
            idmembro: params.getParam(
              'idmembro',
              ParamType.String,
            ),
            idendereco: params.getParam(
              'idendereco',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: PageMembrosAdminWidget.routeName,
          path: PageMembrosAdminWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageMembrosAdminWidget(),
        ),
        FFRoute(
          name: PageMembrosAdminDetalhesWidget.routeName,
          path: PageMembrosAdminDetalhesWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageMembrosAdminDetalhesWidget(
            idmembro: params.getParam(
              'idmembro',
              ParamType.String,
            ),
            emailmembro: params.getParam(
              'emailmembro',
              ParamType.String,
            ),
            nomemembro: params.getParam(
              'nomemembro',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: PageMinisteriosAdminDetalhesWidget.routeName,
          path: PageMinisteriosAdminDetalhesWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageMinisteriosAdminDetalhesWidget(
            idministerio: params.getParam(
              'idministerio',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: PageDevocionaisPastorWidget.routeName,
          path: PageDevocionaisPastorWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageDevocionaisPastorWidget(),
        ),
        FFRoute(
          name: PageDevocionalPastorNovoWidget.routeName,
          path: PageDevocionalPastorNovoWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageDevocionalPastorNovoWidget(),
        ),
        FFRoute(
          name: PageDevocionalPastorEditarWidget.routeName,
          path: PageDevocionalPastorEditarWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageDevocionalPastorEditarWidget(
            iddevocional: params.getParam(
              'iddevocional',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: PageMinisteriosLiderWidget.routeName,
          path: PageMinisteriosLiderWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageMinisteriosLiderWidget(),
        ),
        FFRoute(
          name: PageCriaEscalaLiderWidget.routeName,
          path: PageCriaEscalaLiderWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageCriaEscalaLiderWidget(
            idministerio: params.getParam(
              'idministerio',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: HomePageAdminWidget.routeName,
          path: HomePageAdminWidget.routePath,
          requireAuth: true,
          builder: (context, params) => HomePageAdminWidget(),
        ),
        FFRoute(
          name: LoginTesteWidget.routeName,
          path: LoginTesteWidget.routePath,
          builder: (context, params) => LoginTesteWidget(),
        ),
        FFRoute(
          name: PageMinisterioAdminNovoWidget.routeName,
          path: PageMinisterioAdminNovoWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageMinisterioAdminNovoWidget(),
        ),
        FFRoute(
          name: PaginadetransicaoWidget.routeName,
          path: PaginadetransicaoWidget.routePath,
          builder: (context, params) => PaginadetransicaoWidget(),
        ),
        FFRoute(
          name: PageMembroSecretariaMinWidget.routeName,
          path: PageMembroSecretariaMinWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageMembroSecretariaMinWidget(
            idministerio: params.getParam(
              'idministerio',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: PageEscalaLiderMembroWidget.routeName,
          path: PageEscalaLiderMembroWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageEscalaLiderMembroWidget(
            idministerio: params.getParam(
              'idministerio',
              ParamType.int,
            ),
            idescala: params.getParam(
              'idescala',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: PageescalacriadaWidget.routeName,
          path: PageescalacriadaWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageescalacriadaWidget(
            idministerio: params.getParam(
              'idministerio',
              ParamType.int,
            ),
            idescala: params.getParam(
              'idescala',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: PageMinisterioDetalhesLiderWidget.routeName,
          path: PageMinisterioDetalhesLiderWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageMinisterioDetalhesLiderWidget(
            idministerio: params.getParam(
              'idministerio',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: RecuperacaodeSenhaWidget.routeName,
          path: RecuperacaodeSenhaWidget.routePath,
          builder: (context, params) => RecuperacaodeSenhaWidget(),
        ),
        FFRoute(
          name: PageMembrosEditarDetalhesSecretariaWidget.routeName,
          path: PageMembrosEditarDetalhesSecretariaWidget.routePath,
          requireAuth: true,
          builder: (context, params) =>
              PageMembrosEditarDetalhesSecretariaWidget(
            idmembro: params.getParam(
              'idmembro',
              ParamType.String,
            ),
            idendereco: params.getParam(
              'idendereco',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: PageMinisterioAdminEditarWidget.routeName,
          path: PageMinisterioAdminEditarWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageMinisterioAdminEditarWidget(
            idministerio: params.getParam(
              'idministerio',
              ParamType.int,
            ),
          ),
        ),
        FFRoute(
          name: PageMembroWidget.routeName,
          path: PageMembroWidget.routePath,
          builder: (context, params) => PageMembroWidget(),
        ),
        FFRoute(
          name: PageMembrosNovaWidget.routeName,
          path: PageMembrosNovaWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageMembrosNovaWidget(),
        ),
        FFRoute(
          name: Home07InvoicesWidget.routeName,
          path: Home07InvoicesWidget.routePath,
          builder: (context, params) => Home07InvoicesWidget(),
        ),
        FFRoute(
          name: Home26ListFeaturesWidget.routeName,
          path: Home26ListFeaturesWidget.routePath,
          builder: (context, params) => Home26ListFeaturesWidget(),
        ),
        FFRoute(
          name: PageAvisosSecretariaWidget.routeName,
          path: PageAvisosSecretariaWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageAvisosSecretariaWidget(),
        ),
        FFRoute(
          name: PageNovoAvisoSecretariaWidget.routeName,
          path: PageNovoAvisoSecretariaWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageNovoAvisoSecretariaWidget(
            avisoId: params.getParam('avisoId', ParamType.int),
          ),
        ),
        FFRoute(
          name: SelecionaPerfilWidget.routeName,
          path: SelecionaPerfilWidget.routePath,
          requireAuth: true,
          builder: (context, params) => SelecionaPerfilWidget(),
        ),
        FFRoute(
          name: RegistroMembroWidget.routeName,
          path: RegistroMembroWidget.routePath,
          builder: (context, params) => RegistroMembroWidget(),
        ),
        FFRoute(
          name: PageNovaCelulaSecretariaWidget.routeName,
          path: PageNovaCelulaSecretariaWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageNovaCelulaSecretariaWidget(
            celulaId: params.getParam('celulaId', ParamType.int),
          ),
        ),
        FFRoute(
          name: PageCelulaDetalhesSecretariaWidget.routeName,
          path: PageCelulaDetalhesSecretariaWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageCelulaDetalhesSecretariaWidget(
            celulaId: params.getParam('celulaId', ParamType.int)!,
          ),
        ),
        FFRoute(
          name: PageEscalasLiderWidget.routeName,
          path: PageEscalasLiderWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageEscalasLiderWidget(
            idministerio: params.getParam('idministerio', ParamType.int),
          ),
        ),
        FFRoute(
          name: PageEscalaDetalhesLiderWidget.routeName,
          path: PageEscalaDetalhesLiderWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageEscalaDetalhesLiderWidget(
            idministerio: params.getParam('idministerio', ParamType.int),
            idescala: params.getParam('idescala', ParamType.int),
          ),
        ),
        FFRoute(
          name: PageCriaEscalaLouvorWidget.routeName,
          path: PageCriaEscalaLouvorWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageCriaEscalaLouvorWidget(
            idministerio: params.getParam('idministerio', ParamType.int),
          ),
        ),
        FFRoute(
          name: PageCelulasPastorWidget.routeName,
          path: PageCelulasPastorWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageCelulasPastorWidget(),
        ),
        FFRoute(
          name: PageCelulaDetalhesPastorWidget.routeName,
          path: PageCelulaDetalhesPastorWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageCelulaDetalhesPastorWidget(
            celulaId: params.getParam('celulaId', ParamType.int)!,
          ),
        ),
        FFRoute(
          name: PageDevocionalMembroLeituraWidget.routeName,
          path: PageDevocionalMembroLeituraWidget.routePath,
          requireAuth: true,
          builder: (context, params) => PageDevocionalMembroLeituraWidget(
            idDevocional: params.getParam('idDevocional', ParamType.int),
          ),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/loginTeste';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? Center(
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                )
              : page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
