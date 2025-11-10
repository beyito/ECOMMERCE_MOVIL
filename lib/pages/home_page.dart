import 'package:ecommerce_movil/views/producto/producto_view.dart';
import 'package:ecommerce_movil/views/venta/carrito_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce_movil/shared/custom_appbar.dart';
import 'package:ecommerce_movil/shared/custom_bottom_navigation.dart';
// import 'package:ecommerce_movil/views/producto/producto_view.dart';
// import 'package:movil_condominio/views/area_comun/areacomun_view.dart';
// import '../views/control_ingreso/control_ingreso_view.dart';
// import '../views/pago/pago_view.dart';
// import '../views/reserva/reservasCopropietario_view.dart';
// import '../views/tarea/tarea_views.dart';
import 'package:ecommerce_movil/config/config_db.dart';
//import '../views/areas_comunes/areas_comunes_view.dart';
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

  @override
  void initState() {
    super.initState();
    _setupHomePage();
    _setupFirebaseMessaging();
  }

  Future<void> _setupHomePage() async {
    final prefs = await SharedPreferences.getInstance();
    final rol = prefs.getString('rol') ?? '';
    setState(() {
      _rol = rol;
      // Definir las vistas según el rol
      _viewRoutes = [
        ProductosView(),
        // ReservaCopropietarioView(),
        // AreasComunesView(),
        // PagoView(),
        // const Placeholder(), // muestra un recuadro gris temporal
        Scaffold(
          appBar: AppBar(title: const Text('Ejemplo de vista')),
          body: const Center(child: Text('Aquí irá una vista real')),
        ),
        CarritoView(),
      ];
    });
  }

  // -------------------------------
  // 🔹 Configurar Firebase Messaging
  // -------------------------------
  // Pedir permisos en iOS
  Future<void> _setupFirebaseMessaging() async {
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

    // Guardar token en backend
    if (tokenMensaje != null) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      await http.post(
        Uri.parse("${Config.baseUrl}/usuario/registrar-token/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: '{"token": "$tokenMensaje", "plataforma": "android"}',
      );
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
  }

  //nada
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(),
      body: _viewRoutes.isNotEmpty
          ? IndexedStack(index: widget.pageIndex, children: _viewRoutes)
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: _rol.isNotEmpty
          ? CustomBottomNavigation(currentIndex: widget.pageIndex)
          : null,
    );
  }
}
