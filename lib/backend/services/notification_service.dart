import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '/backend/supabase/supabase.dart';
import '/auth/supabase_auth/auth_util.dart';

/// Serviço para gerenciar notificações push via Firebase Cloud Messaging.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static NotificationService get instance => _instance;

  FirebaseMessaging? _messaging;
  String? _fcmToken;
  bool _initialized = false;

  // VAPID key para Web
  static const String _vapidKey =
      'BJrQKygKr0HluhtsQ6QwpjClZaqBV40-0zQp6sk6n5IK68-0y_r-LYvjjZteDUoZtxgNYF9h9BzypPYtds5be2s';

  // Getters
  String? get fcmToken => _fcmToken;
  bool get isInitialized => _initialized;

  /// Inicializa o Firebase e o serviço de notificações
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Inicializar Firebase
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyDVpo_KOv4lorUEXrCIbHhT983MGQqMTKI',
          authDomain: 'churchcontrol-1dff9.firebaseapp.com',
          projectId: 'churchcontrol-1dff9',
          storageBucket: 'churchcontrol-1dff9.firebasestorage.app',
          messagingSenderId: '176781023738',
          appId: '1:176781023738:web:4fddabc3c1dab16edeec43',
          measurementId: 'G-HVYF9NBMD8',
        ),
      );

      _messaging = FirebaseMessaging.instance;

      // Solicitar permissão
      await _requestPermission();

      // Obter token FCM
      await _getToken();

      // Configurar listeners
      _setupMessageListeners();

      _initialized = true;
      debugPrint('[NotificationService] Inicializado com sucesso');
    } catch (e) {
      debugPrint('[NotificationService] Erro ao inicializar: $e');
    }
  }

  /// Solicita permissão para notificações
  Future<bool> _requestPermission() async {
    if (_messaging == null) return false;

    try {
      final settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      debugPrint('[NotificationService] Permissão: ${settings.authorizationStatus}');
      return granted;
    } catch (e) {
      debugPrint('[NotificationService] Erro ao solicitar permissão: $e');
      return false;
    }
  }

  /// Obtém o token FCM do dispositivo
  Future<String?> _getToken() async {
    if (_messaging == null) return null;

    try {
      // Para Web, precisa passar a VAPID key
      if (kIsWeb) {
        _fcmToken = await _messaging!.getToken(vapidKey: _vapidKey);
      } else {
        _fcmToken = await _messaging!.getToken();
      }

      debugPrint('[NotificationService] Token FCM: $_fcmToken');

      // Salvar token no banco de dados
      if (_fcmToken != null) {
        await _saveTokenToDatabase(_fcmToken!);
      }

      // Listener para atualização de token
      _messaging!.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _saveTokenToDatabase(newToken);
        debugPrint('[NotificationService] Token atualizado: $newToken');
      });

      return _fcmToken;
    } catch (e) {
      debugPrint('[NotificationService] Erro ao obter token: $e');
      return null;
    }
  }

  /// Salva o token FCM na tabela membros
  Future<void> _saveTokenToDatabase(String token) async {
    try {
      // Buscar membro logado
      final membroRows = await MembrosTable().queryRows(
        queryFn: (q) => q.eq('id_auth', currentUserUid),
      );

      if (membroRows.isEmpty) {
        debugPrint('[NotificationService] Membro nao encontrado para salvar token');
        return;
      }

      final membro = membroRows.first;

      // Atualizar token FCM
      await MembrosTable().update(
        data: {'fcm_token': token},
        matchingRows: (rows) => rows.eq('id_membro', membro.idMembro),
      );

      debugPrint('[NotificationService] Token salvo para membro: ${membro.idMembro}');
    } catch (e) {
      debugPrint('[NotificationService] Erro ao salvar token: $e');
    }
  }

  /// Configura listeners para mensagens recebidas
  void _setupMessageListeners() {
    // Mensagens em foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[NotificationService] Mensagem em foreground: ${message.notification?.title}');
      _handleMessage(message);
    });

    // Quando o app é aberto através da notificação
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[NotificationService] App aberto pela notificacao: ${message.notification?.title}');
      _handleMessageOpenedApp(message);
    });

    // Verificar se o app foi aberto por uma notificação inicial
    _checkInitialMessage();
  }

  /// Verifica se o app foi aberto por uma notificação
  Future<void> _checkInitialMessage() async {
    final message = await _messaging?.getInitialMessage();
    if (message != null) {
      debugPrint('[NotificationService] Mensagem inicial: ${message.notification?.title}');
      _handleMessageOpenedApp(message);
    }
  }

  /// Processa mensagem recebida em foreground
  void _handleMessage(RemoteMessage message) {
    // Aqui pode exibir um snackbar, dialog, etc
    // O comportamento pode ser customizado conforme necessário
    debugPrint('Titulo: ${message.notification?.title}');
    debugPrint('Corpo: ${message.notification?.body}');
    debugPrint('Dados: ${message.data}');
  }

  /// Processa quando app é aberto pela notificação
  void _handleMessageOpenedApp(RemoteMessage message) {
    // Navegar para tela específica baseado nos dados da mensagem
    final data = message.data;
    debugPrint('Navegando com dados: $data');

    // Exemplo: navegar para escalas se for convite de escala
    // if (data['type'] == 'escala_convite') {
    //   navigatorKey.currentState?.pushNamed('/escalas');
    // }
  }

  /// Remove o token FCM (logout)
  Future<void> removeToken() async {
    try {
      // Limpar token do banco
      final membroRows = await MembrosTable().queryRows(
        queryFn: (q) => q.eq('id_auth', currentUserUid),
      );

      if (membroRows.isNotEmpty) {
        await MembrosTable().update(
          data: {'fcm_token': null},
          matchingRows: (rows) => rows.eq('id_membro', membroRows.first.idMembro),
        );
      }

      // Deletar token do Firebase
      await _messaging?.deleteToken();
      _fcmToken = null;

      debugPrint('[NotificationService] Token removido');
    } catch (e) {
      debugPrint('[NotificationService] Erro ao remover token: $e');
    }
  }
}
