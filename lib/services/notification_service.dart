import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Configuración inicial
  Future<void> initialize() async {
    // Solicitar permisos para iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configurar notificaciones locales
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Configurar canal de notificaciones para Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'saray_channel',
      'Saray Notifications',
      description: 'Notificaciones de la app Saray',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Obtener token FCM
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Configurar manejadores de mensajes
    FirebaseMessaging.onMessage.listen(_onMessageReceived);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Obtener token FCM
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Mostrar notificación local
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'saray_channel',
      'Saray Notifications',
      channelDescription: 'Notificaciones de la app Saray',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  // Mostrar notificación de pedido confirmado
  Future<void> showOrderConfirmationNotification(String orderId, double total) async {
    await showLocalNotification(
      title: '¡Pedido Confirmado! 🎉',
      body: 'Tu pedido #$orderId por \$${total.toStringAsFixed(2)} ha sido confirmado.',
      payload: 'order_$orderId',
    );
  }

  // Mostrar notificación de oferta
  Future<void> showOfferNotification(String productName, double discount) async {
    await showLocalNotification(
      title: '¡Oferta Especial! 🏷️',
      body: '$productName con ${discount.toStringAsFixed(0)}% de descuento.',
      payload: 'offer_$productName',
    );
  }

  // Mostrar notificación de producto agotado
  Future<void> showOutOfStockNotification(String productName) async {
    await showLocalNotification(
      title: 'Producto Agotado ⚠️',
      body: '$productName ya no está disponible.',
      payload: 'out_of_stock_$productName',
    );
  }

  // Manejador cuando se recibe mensaje en primer plano
  void _onMessageReceived(RemoteMessage message) {
    print('Mensaje recibido: ${message.notification?.title}');

    if (message.notification != null) {
      showLocalNotification(
        title: message.notification!.title ?? 'Notificación',
        body: message.notification!.body ?? '',
        payload: message.data['payload'],
      );
    }
  }

  // Manejador cuando se abre la app desde notificación
  void _onMessageOpenedApp(RemoteMessage message) {
    print('App abierta desde notificación: ${message.notification?.title}');
    // Aquí puedes navegar a una pantalla específica según el payload
    _handleNotificationPayload(message.data['payload']);
  }

  // Manejador de notificación en background
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Mensaje en background: ${message.notification?.title}');
  }

  // Manejador cuando se toca la notificación local
  void _onNotificationTapped(NotificationResponse response) {
    print('Notificación tocada: ${response.payload}');
    _handleNotificationPayload(response.payload);
  }

  // Manejar payload de notificación
  void _handleNotificationPayload(String? payload) {
    if (payload == null) return;

    if (payload.startsWith('order_')) {
      // Navegar a detalles del pedido
      String orderId = payload.substring(6);
      print('Navegar a pedido: $orderId');
      // TODO: Implementar navegación
    } else if (payload.startsWith('offer_')) {
      // Navegar al producto en oferta
      String productName = payload.substring(6);
      print('Navegar a oferta: $productName');
      // TODO: Implementar navegación
    }
  }

  // Suscribirse a tópicos
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // Desuscribirse de tópicos
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}