import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ecommerce_movil/config/router/router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce_movil/views/usuario/login_view.dart'; // Asegúrate de tener esta importación

// Manejo de notificaciones en segundo plano
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔔 Notificación en segundo plano: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Configurar handler para notificaciones en background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _initialRouteFuture;

  @override
  void initState() {
    super.initState();
    _initialRouteFuture = _determineInitialRoute();
  }

  Future<String> _determineInitialRoute() async {
    try {
      final SharedPreferences prefs = await _prefs;
      final String? token = prefs.getString('token');
      final String? rol = prefs.getString('rol');

      // Verificar si el usuario está autenticado
      if (token != null && token.isNotEmpty && rol != null && rol.isNotEmpty) {
        return '/home/0'; // Usuario autenticado, ir al home
      } else {
        return '/login'; // Usuario no autenticado, ir al login
      }
    } catch (e) {
      print("❌ Error verificando autenticación: $e");
      return '/login'; // En caso de error, ir al login
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _initialRouteFuture,
      builder: (context, snapshot) {
        // Mientras verifica la autenticación, mostrar loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      'Cargando...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Si hay error, ir al login
        if (snapshot.hasError) {
          print("❌ Error en FutureBuilder: ${snapshot.error}");
          return MaterialApp(
            home: LoginView(), // Asegúrate de que LoginView esté importado
          );
        }

        // Cuando tiene la ruta inicial, configurar el router
        final initialRoute = snapshot.data ?? '/login';

        return MaterialApp.router(
          title: 'SmartSales365',
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter, // Tu router existente
        );
      },
    );
  }
}
