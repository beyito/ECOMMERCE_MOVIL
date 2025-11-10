// services/servicio_carrito.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecommerce_movil/services/auth_service.dart';
import 'package:ecommerce_movil/config/config_db.dart';
import 'package:ecommerce_movil/models/venta/carrito_model.dart';

class CarritoService {
  final String baseUrl = '${Config.baseUrl}/venta';
  final AuthService authService = AuthService();

  // Obtener el carrito del usuario
  Future<CarritoResponse> obtenerCarrito() async {
    try {
      final token = await authService.getToken();
      final uri = Uri.parse('$baseUrl/obtener_mi_carrito');

      final respuesta = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (respuesta.statusCode == 200) {
        final jsonRespuesta = json.decode(respuesta.body);
        return CarritoResponse.fromJson(jsonRespuesta);
      } else {
        throw Exception('Error al obtener carrito: ${respuesta.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Agregar producto al carrito - usa CarritoBasicResponse
  Future<CarritoBasicResponse> agregarProductoCarrito({
    required int productoId,
    required int cantidad,
  }) async {
    try {
      final token = await authService.getToken();
      final uri = Uri.parse('$baseUrl/agregar_producto_carrito');

      final respuesta = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'producto_id': productoId, 'cantidad': cantidad}),
      );

      if (respuesta.statusCode == 200) {
        final jsonRespuesta = json.decode(respuesta.body);
        return CarritoBasicResponse.fromJson(jsonRespuesta);
      } else {
        throw Exception('Error al agregar al carrito: ${respuesta.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar cantidad de un producto en el carrito - usa CarritoBasicResponse
  Future<CarritoBasicResponse> actualizarCantidadProducto({
    required int productoId,
    required int nuevaCantidad,
  }) async {
    try {
      final token = await authService.getToken();
      final uri = Uri.parse('$baseUrl/actualizar_cantidad_carrito');

      final respuesta = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'producto_id': productoId,
          'cantidad': nuevaCantidad,
        }),
      );

      if (respuesta.statusCode == 200) {
        final jsonRespuesta = json.decode(respuesta.body);
        return CarritoBasicResponse.fromJson(jsonRespuesta);
      } else {
        throw Exception(
          'Error al actualizar cantidad: ${respuesta.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar producto del carrito - usa CarritoBasicResponse
  Future<CarritoBasicResponse> eliminarProductoCarrito(int productoId) async {
    try {
      final token = await authService.getToken();
      final uri = Uri.parse('$baseUrl/eliminar_producto_carrito');

      final respuesta = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'producto_id': productoId}),
      );

      if (respuesta.statusCode == 200) {
        final jsonRespuesta = json.decode(respuesta.body);
        return CarritoBasicResponse.fromJson(jsonRespuesta);
      } else {
        throw Exception('Error al eliminar producto: ${respuesta.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Vaciar todo el carrito - usa CarritoBasicResponse
  Future<CarritoBasicResponse> vaciarCarrito() async {
    try {
      final token = await authService.getToken();
      final uri = Uri.parse('$baseUrl/vaciar_carrito');

      final respuesta = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (respuesta.statusCode == 200) {
        final jsonRespuesta = json.decode(respuesta.body);
        return CarritoBasicResponse.fromJson(jsonRespuesta);
      } else {
        throw Exception('Error al vaciar carrito: ${respuesta.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
