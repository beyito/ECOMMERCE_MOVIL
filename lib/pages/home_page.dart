import 'package:ecommerce_movil/views/producto/producto_view.dart';
import 'package:ecommerce_movil/views/venta/carrito_view.dart';
import 'package:ecommerce_movil/views/venta/pedidos_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce_movil/shared/custom_appbar.dart';
import 'package:ecommerce_movil/shared/custom_bottom_navigation.dart';
import 'package:ecommerce_movil/config/config_db.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Instancia global del plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HomePage extends StatefulWidget {
  static const name = 'home-screen';
  final int pageIndex;
  const HomePage({super.key, required this.pageIndex});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _rol = '';
  List<Widget> _viewRoutes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupHomePage();
  }

  Future<void> _setupHomePage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rol = prefs.getString('rol') ?? '';
      final token = prefs.getString('token') ?? '';

      setState(() {
        _rol = rol;
        // Definir las vistas según el rol
        _viewRoutes = [
          ProductosView(),
          // ReservaCopropietarioView(),
          // AreasComunesView(),
          // PagoView(),
          Scaffold(
            appBar: AppBar(title: const Text('Ejemplo de vista')),
            body: const Center(child: Text('Aquí irá una vista real')),
          ),
          CarritoView(),
          PedidosView(),
        ];
      });

      // Solo configurar FCM si el usuario está autenticado
      if (token.isNotEmpty) {
        await _setupFirebaseMessaging(token);
      }
    } catch (e) {
      print("Error en setupHomePage: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // -------------------------------
  // 🔹 Configurar Firebase Messaging
  // -------------------------------
  Future<void> _setupFirebaseMessaging(String userToken) async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Solicitar permisos (iOS)
      await messaging.requestPermission();

      // Inicializar flutter_local_notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      final InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // Obtener token FCM
      String? tokenMensaje = await messaging.getToken();
      print("Token FCM: $tokenMensaje");

      // Guardar token en backend solo si tenemos ambos tokens
      if (tokenMensaje != null && userToken.isNotEmpty) {
        await _registrarTokenEnBackend(userToken, tokenMensaje);
      }

      // 🔹 Foreground: mostrar notificación en barra
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print(
          "📩 Notificación recibida en foreground: ${message.notification?.title}",
        );

        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'canal_general', // ID del canal
                'Canal General', // nombre
                channelDescription: 'Notificaciones generales',
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
          );
        }
      });

      // Cuando el usuario abre la notificación
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("👉 Notificación abierta por el usuario: ${message.data}");
      });

      // App abierta desde notificación cerrada
      FirebaseMessaging.instance.getInitialMessage().then((
        RemoteMessage? message,
      ) {
        if (message != null) {
          print("🔔 App abierta desde notificación: ${message.data}");
        }
      });
    } catch (e) {
      print("Error en setupFirebaseMessaging: $e");
    }
  }

  Future<void> _registrarTokenEnBackend(
    String userToken,
    String fcmToken,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse("${Config.baseUrl}/usuario/registrar-token/"),
            headers: {
              "Authorization": "Bearer $userToken",
              "Content-Type": "application/json",
            },
            body: '{"token": "$fcmToken", "plataforma": "android"}',
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print("✅ Token FCM registrado exitosamente");
      } else {
        print("❌ Error al registrar token FCM: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error de conexión al registrar token FCM: $e");
      // No lanzar excepción, solo loggear el error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: const CustomAppbar(),
      body: _viewRoutes.isNotEmpty
          ? IndexedStack(index: widget.pageIndex, children: _viewRoutes)
          : const Center(child: Text('Error al cargar las vistas')),
      bottomNavigationBar: _rol.isNotEmpty
          ? CustomBottomNavigation(currentIndex: widget.pageIndex)
          : null,
    );
  }
}
