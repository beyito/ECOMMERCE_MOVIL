// models/producto/historial_precio_model.dart
class HistorialPrecioResponse {
  final int status;
  final int error;
  final String message;
  final HistorialPrecioData values;

  HistorialPrecioResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.values,
  });

  factory HistorialPrecioResponse.fromJson(Map<String, dynamic> json) {
    return HistorialPrecioResponse(
      status: json['status'],
      error: json['error'],
      message: json['message'],
      values: HistorialPrecioData.fromJson(json['values']),
    );
  }
}

class HistorialPrecioData {
  final ProductoHistorial producto;
  final PeriodoHistorial periodo;
  final Map<String, EstadisticasPrecio> estadisticas;
  final DatosGrafica datosGrafica;

  HistorialPrecioData({
    required this.producto,
    required this.periodo,
    required this.estadisticas,
    required this.datosGrafica,
  });

  factory HistorialPrecioData.fromJson(Map<String, dynamic> json) {
    return HistorialPrecioData(
      producto: ProductoHistorial.fromJson(json['producto']),
      periodo: PeriodoHistorial.fromJson(json['periodo']),
      estadisticas: (json['estadisticas'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, EstadisticasPrecio.fromJson(value)),
      ),
      datosGrafica: DatosGrafica.fromJson(json['datos_grafica']),
    );
  }
}

class ProductoHistorial {
  final int id;
  final String nombre;
  final double precioActualContado;
  final double precioActualCuota;

  ProductoHistorial({
    required this.id,
    required this.nombre,
    required this.precioActualContado,
    required this.precioActualCuota,
  });

  factory ProductoHistorial.fromJson(Map<String, dynamic> json) {
    return ProductoHistorial(
      id: json['id'],
      nombre: json['nombre'],
      precioActualContado: double.parse(
        json['precio_actual_contado'].toString(),
      ),
      precioActualCuota: double.parse(json['precio_actual_cuota'].toString()),
    );
  }
}

class PeriodoHistorial {
  final int meses;
  final String fechaInicio;
  final String fechaFin;

  PeriodoHistorial({
    required this.meses,
    required this.fechaInicio,
    required this.fechaFin,
  });

  factory PeriodoHistorial.fromJson(Map<String, dynamic> json) {
    return PeriodoHistorial(
      meses: json['meses'],
      fechaInicio: json['fecha_inicio'],
      fechaFin: json['fecha_fin'],
    );
  }
}

class EstadisticasPrecio {
  final double precioMaximo;
  final double precioMinimo;
  final double precioPromedio;
  final int totalCambios;
  final double variacionMaxima;
  final double variacionMinima;
  final double variacionPromedio;
  final String tendencia;

  EstadisticasPrecio({
    required this.precioMaximo,
    required this.precioMinimo,
    required this.precioPromedio,
    required this.totalCambios,
    required this.variacionMaxima,
    required this.variacionMinima,
    required this.variacionPromedio,
    required this.tendencia,
  });

  factory EstadisticasPrecio.fromJson(Map<String, dynamic> json) {
    return EstadisticasPrecio(
      precioMaximo: double.parse(json['precio_maximo'].toString()),
      precioMinimo: double.parse(json['precio_minimo'].toString()),
      precioPromedio: double.parse(json['precio_promedio'].toString()),
      totalCambios: json['total_cambios'],
      variacionMaxima: double.parse(json['variacion_maxima'].toString()),
      variacionMinima: double.parse(json['variacion_minima'].toString()),
      variacionPromedio: double.parse(json['variacion_promedio'].toString()),
      tendencia: json['tendencia'],
    );
  }
}

class DatosGrafica {
  final List<String> labels;
  final Map<String, DatosTipoPrecio>? datosPorTipo;
  final DatosTipoPrecio? datosIndividual;

  DatosGrafica({required this.labels, this.datosPorTipo, this.datosIndividual});

  bool get tieneDatosAmbos => datosPorTipo != null;
  bool get tieneDatosIndividual => datosIndividual != null;

  factory DatosGrafica.fromJson(Map<String, dynamic> json) {
    final labels = (json['labels'] as List).cast<String>();

    // Verificar si es formato "ambos" o individual
    if (json.containsKey('contado') && json.containsKey('cuota')) {
      return DatosGrafica(
        labels: labels,
        datosPorTipo: {
          'contado': DatosTipoPrecio.fromJson(json['contado']),
          'cuota': DatosTipoPrecio.fromJson(json['cuota']),
        },
      );
    } else {
      // Buscar el tipo individual (contado o cuota)
      final tipo = json.keys.firstWhere(
        (key) => key != 'labels',
        orElse: () => 'contado',
      );

      return DatosGrafica(
        labels: labels,
        datosIndividual: DatosTipoPrecio.fromJson(json[tipo]),
      );
    }
  }
}

class DatosTipoPrecio {
  final List<double> precios;
  final List<double> variacionesPorcentuales;

  DatosTipoPrecio({
    required this.precios,
    required this.variacionesPorcentuales,
  });

  factory DatosTipoPrecio.fromJson(Map<String, dynamic> json) {
    return DatosTipoPrecio(
      precios: (json['precios'] as List)
          .map((e) => double.parse(e.toString()))
          .toList(),
      variacionesPorcentuales: (json['variaciones_porcentuales'] as List)
          .map((e) => double.parse(e.toString()))
          .toList(),
    );
  }
}
