import 'dart:async';
import 'dart:convert';
import 'package:ecommerce_movil/models/auth/login_response.dart';
import 'package:ecommerce_movil/models/usuario/usuario_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce_movil/config/config_db.dart';

class AuthService {
  final String baseUrl = '${Config.baseUrl}/usuario';

  // Login
  Future<LoginResponse> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      if (username.isEmpty && password.isEmpty) {
        return LoginResponse.failure("Usuario y Contraseña están vacíos");
      } else if (username.isEmpty) {
        return LoginResponse.failure("Usuario no puede estar vacío");
      } else {
        return LoginResponse.failure("Contraseña no puede estar vacía");
      }
    }
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 40)); // <-- aquí el timeout

      final data = jsonDecode(response.body);

      if (data['status'] == 1) {
        final values = data['values'];
        // Guardar token localmente
        final prefs = await SharedPreferences.getInstance();
        final id = values['id'];
        final token = values['access'];
        final usuario = values["username"];
        final rol = values["grupo_nombre"];

        await prefs.setString('token', token);
        await prefs.setInt('id', id);
        await prefs.setString('rol', rol);
        await prefs.setString('username', usuario ?? '');

        return LoginResponse.success(token: token, id: id, usuario: usuario);
      } else {
        final error = data['message']; //?? 'Error de login';
        return LoginResponse.failure(error);
      }
    } on TimeoutException {
      return LoginResponse.failure(
        "Tiempo de espera agotado. Intenta de nuevo.",
      );
    } catch (e) {
      return LoginResponse.failure("Error inesperado: $e");
    }
  }

  // Obtener token guardado
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<UsuarioModel?> getUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username != null) {
      return UsuarioModel(username: username);
    }
    return null;
  }
}
