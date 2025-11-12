// services/venta/pedido_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecommerce_movil/services/auth_service.dart';
import 'package:ecommerce_movil/config/config_db.dart';
import 'package:ecommerce_movil/models/venta/forma_pago_model.dart';
import 'package:ecommerce_movil/models/venta/pedido_model.dart';

class PedidoService {
  final String baseUrl = '${Config.baseUrl}/venta';
  final AuthService authService = AuthService();

  // Obtener formas de pago activas
  Future<FormaPagoResponse> listarFormasPagoActivos() async {
    try {
      final token = await authService.getToken();
      final uri = Uri.parse('$baseUrl/listar_formas_pago_activos');

      final respuesta = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (respuesta.statusCode == 200) {
        final jsonRespuesta = json.decode(respuesta.body);
        return FormaPagoResponse.fromJson(jsonRespuesta);
      } else {
        throw Exception(
          'Error al obtener formas de pago: ${respuesta.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Generar pedido
  Future<PedidoResponse> generarPedido(PedidoRequest pedidoRequest) async {
    try {
      final token = await authService.getToken();
      final uri = Uri.parse('$baseUrl/generar_pedido');

      final respuesta = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(pedidoRequest.toJson()),
      );

      if (respuesta.statusCode == 200) {
        final jsonRespuesta = json.decode(respuesta.body);
        return PedidoResponse.fromJson(jsonRespuesta);
      } else {
        throw Exception('Error al generar pedido: ${respuesta.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener lista de pedidos del usuario
  Future<PedidosResponse> listarMisPedidos() async {
    try {
      final token = await authService.getToken();
      final uri = Uri.parse('$baseUrl/listar_mis_pedidos');

      final respuesta = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (respuesta.statusCode == 200) {
        final jsonRespuesta = json.decode(respuesta.body);
        return PedidosResponse.fromJson(jsonRespuesta);
      } else {
        throw Exception('Error al obtener pedidos: ${respuesta.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener detalle de un pedido específico
  Future<PedidoDetalleResponse> obtenerPedido(int pedidoId) async {
    try {
      final token = await authService.getToken();
      final uri = Uri.parse('$baseUrl/obtener_pedido/$pedidoId/');

      final respuesta = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (respuesta.statusCode == 200) {
        final jsonRespuesta = json.decode(respuesta.body);
        return PedidoDetalleResponse.fromJson(jsonRespuesta);
      } else {
        throw Exception('Error al obtener pedido: ${respuesta.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
