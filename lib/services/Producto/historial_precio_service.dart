// services/producto/historial_precio_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecommerce_movil/services/auth_service.dart';
import 'package:ecommerce_movil/config/config_db.dart';
import 'package:ecommerce_movil/models/producto/historial_precio_model.dart';

class HistorialPrecioService {
  final String baseUrl = '${Config.baseUrl}/producto';
  final AuthService authService = AuthService();

  Future<HistorialPrecioResponse> obtenerHistorialPrecios({
    required int productoId,
    int meses = 12,
    String tipo = 'ambos', // 'contado', 'cuota', 'ambos'
  }) async {
    try {
      final token = await authService.getToken();
      final uri = Uri.parse(
        '$baseUrl/obtener_historial_precios_producto/$productoId/',
      ).replace(queryParameters: {'meses': meses.toString(), 'tipo': tipo});

      final respuesta = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (respuesta.statusCode == 200) {
        final jsonRespuesta = json.decode(respuesta.body);
        return HistorialPrecioResponse.fromJson(jsonRespuesta);
      } else {
        throw Exception(
          'Error al obtener historial de precios: ${respuesta.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
