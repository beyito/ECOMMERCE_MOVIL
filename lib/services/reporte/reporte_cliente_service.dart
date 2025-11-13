import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecommerce_movil/models/reporte/reporte_cliente_model.dart';

import 'package:ecommerce_movil/config/config_db.dart';
// import 'package:ecommerce_movil/utils/api_config.dart';

import 'package:ecommerce_movil/services/auth_service.dart';

class ReporteClienteService {
  final String baseUrl = '${Config.baseUrl}/reportes';
  final AuthService authService = AuthService();
  Future<EstadisticasCliente> obtenerEstadisticas() async {
    try {
      final token = await authService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/estadisticas/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return EstadisticasCliente.fromJson(data);
      } else {
        throw Exception(
          'Error al obtener estadísticas: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<RespuestaConsultaIA> consultarIASeguro(String pregunta) async {
    try {
      final token = await authService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/consulta-ia/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'pregunta': pregunta}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RespuestaConsultaIA.fromJson(data);
      } else {
        throw Exception('Error en consulta IA: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // NUEVO: Obtener opciones de filtros
  Future<Map<String, dynamic>> obtenerOpcionesFiltros() async {
    try {
      final token = await authService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/opciones-filtros/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener opciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // NUEVO: Generar reporte con filtros
  Future<RespuestaConsultaIA> generarReporteConFiltros(
    Map<String, dynamic> filtros,
  ) async {
    try {
      final token = await authService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/generar-reporte/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'filtros': filtros}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RespuestaConsultaIA.fromJson(data);
      } else {
        throw Exception('Error al generar reporte: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // NUEVO: Procesar voz (opcional - si quieres mantener esta funcionalidad)
  Future<RespuestaVoz> procesarVoz() async {
    try {
      final token = await authService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/procesar-voz/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RespuestaVoz.fromJson(data);
      } else {
        throw Exception('Error al procesar voz: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  // En tu ReporteClienteService - Agrega estos métodos

  Future<http.Response> generarPDFReporte(Map<String, dynamic> filtros) async {
    final token = await authService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/generar-pdf-reporte/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'filtros': filtros}),
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Error al generar PDF: ${response.statusCode}');
    }
  }

  Future<http.Response> generarPDFConsulta(String pregunta) async {
    final token = await authService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/generar-pdf-consulta/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'pregunta': pregunta}),
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Error al generar PDF: ${response.statusCode}');
    }
  }
}
