class EstadisticasCliente {
  final int totalPedidos;
  final double totalGastado;
  final double promedioPorPedido;
  final Map<String, dynamic> productoMasComprado;
  final List<dynamic> productosFrecuentes;
  final Map<String, dynamic> ultimoPedido;
  final List<dynamic> pedidosPorEstado;
  final String fechaConsulta;
  final String miembroDesde; // NUEVO CAMPO
  final int mesesComoCliente; // NUEVO CAMPO

  EstadisticasCliente({
    required this.totalPedidos,
    required this.totalGastado,
    required this.promedioPorPedido,
    required this.productoMasComprado,
    required this.productosFrecuentes,
    required this.ultimoPedido,
    required this.pedidosPorEstado,
    required this.fechaConsulta,
    required this.miembroDesde, // NUEVO
    required this.mesesComoCliente, // NUEVO
  });

  factory EstadisticasCliente.fromJson(Map<String, dynamic> json) {
    final estadisticas = json['estadisticas'] ?? {};
    return EstadisticasCliente(
      totalPedidos: estadisticas['total_pedidos'] ?? 0,
      totalGastado: (estadisticas['total_gastado'] ?? 0).toDouble(),
      promedioPorPedido: (estadisticas['promedio_por_pedido'] ?? 0).toDouble(),
      productoMasComprado: json['producto_mas_comprado'] ?? {},
      productosFrecuentes: json['productos_frecuentes'] ?? [],
      ultimoPedido: json['ultimo_pedido'] ?? {},
      pedidosPorEstado: json['pedidos_por_estado'] ?? [],
      fechaConsulta: json['fecha_consulta'] ?? '',
      miembroDesde: estadisticas['miembro_desde'] ?? 'N/A', // NUEVO
      mesesComoCliente: estadisticas['meses_como_cliente'] ?? 0, // NUEVO
    );
  }
}

class RespuestaConsultaIA {
  final String respuesta;
  final List<dynamic> datos;
  final String tipoConsulta;
  final int totalResultados;
  final Map<String, dynamic> datosCliente;

  RespuestaConsultaIA({
    required this.respuesta,
    required this.datos,
    required this.tipoConsulta,
    required this.totalResultados,
    required this.datosCliente,
  });

  factory RespuestaConsultaIA.fromJson(Map<String, dynamic> json) {
    return RespuestaConsultaIA(
      respuesta: json['respuesta'] ?? '',
      datos: json['datos'] ?? [],
      tipoConsulta: json['tipo_consulta'] ?? '',
      totalResultados: json['total_resultados'] ?? 0,
      datosCliente: json['datos_cliente'] ?? {},
    );
  }
}

class RespuestaVoz {
  final String textoTranscrito;
  final String respuesta;
  final List<dynamic> datos;
  final String accionSugerida;

  RespuestaVoz({
    required this.textoTranscrito,
    required this.respuesta,
    required this.datos,
    required this.accionSugerida,
  });

  factory RespuestaVoz.fromJson(Map<String, dynamic> json) {
    return RespuestaVoz(
      textoTranscrito: json['texto_transcrito'] ?? '',
      respuesta: json['respuesta'] ?? '',
      datos: json['datos'] ?? [],
      accionSugerida: json['accion_sugerida'] ?? '',
    );
  }
}
