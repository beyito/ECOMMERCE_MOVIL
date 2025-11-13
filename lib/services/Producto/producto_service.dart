// services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecommerce_movil/config/config_db.dart';
import 'package:ecommerce_movil/models/producto/producto_model.dart';
import 'package:ecommerce_movil/services/auth_service.dart';

class ProductoService {
  final String baseUrl =
      '${Config.baseUrl}/producto'; // Reemplaza con tu URL base
  final AuthService authService = AuthService();
  Future<ProductoResponse> getProducts({
    int? page,
    String? search,
    int? categoria,
    int? subcategoria,
    int? marca,
    double? minPrecio,
    double? maxPrecio,
    bool? enStock,
  }) async {
    try {
      final token = await authService.getToken();
      final Map<String, String> queryParams = {
        'page': page?.toString() ?? '1',
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoria != null) 'categoria': categoria.toString(),
        if (subcategoria != null) 'subcategoria': subcategoria.toString(),
        if (marca != null) 'marca': marca.toString(),
        if (minPrecio != null) 'min_precio': minPrecio.toString(),
        if (maxPrecio != null) 'max_precio': maxPrecio.toString(),
        if (enStock != null) 'en_stock': enStock.toString(),
      };

      final response = await http.get(
        Uri.parse(
          '$baseUrl/buscar_productos',
        ).replace(queryParameters: queryParams),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ProductoResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Error al cargar productos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Nuevo método para obtener detalle de un producto
  Future<DetalleProductoResponse> obtenerDetalleProducto(int idProducto) async {
    try {
      final token = await authService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/obtener_producto/$idProducto/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonRespuesta = json.decode(response.body);
        return DetalleProductoResponse.fromJson(jsonRespuesta);
      } else {
        throw Exception('Error al cargar el producto: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // En producto_service.dart - Agrega este método
  Future<ProductoListResponse> busquedaNatural({required String query}) async {
    try {
      final token = await authService.getToken();
      final id = await authService.getId();
      final response = await http.post(
        Uri.parse('$baseUrl/busqueda-natural'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'q': query, 'usuario_id': id}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ProductoListResponse.fromJson(data);
      } else {
        throw Exception('Error en búsqueda: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
