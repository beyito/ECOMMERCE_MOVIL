// widgets/grafica_historial_precios.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ecommerce_movil/models/producto/historial_precio_model.dart';

class GraficaHistorialPrecios extends StatefulWidget {
  final HistorialPrecioData historialData;

  const GraficaHistorialPrecios({Key? key, required this.historialData})
    : super(key: key);

  @override
  State<GraficaHistorialPrecios> createState() =>
      _GraficaHistorialPreciosState();
}

class _GraficaHistorialPreciosState extends State<GraficaHistorialPrecios> {
  String _tipoVisualizacion = 'precios';
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final datosGrafica = widget.historialData.datosGrafica;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con título y controles
            _buildHeader(),
            const SizedBox(height: 16),

            // Gráfica
            SizedBox(height: 300, child: _buildChart(datosGrafica)),
            const SizedBox(height: 16),

            // Leyenda
            _buildLegend(datosGrafica),
            const SizedBox(height: 16),

            // Estadísticas
            _buildEstadisticas(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Historial de Precios',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _tipoVisualizacion,
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(
                value: 'precios',
                child: Row(
                  children: [
                    Icon(Icons.trending_up, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    const Text('Precios'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'variaciones',
                child: Row(
                  children: [
                    Icon(Icons.percent, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    const Text('Variaciones %'),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _tipoVisualizacion = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChart(DatosGrafica datosGrafica) {
    return LineChart(
      _tipoVisualizacion == 'precios'
          ? _buildPreciosData(datosGrafica)
          : _buildVariacionesData(datosGrafica),
    );
  }

  LineChartData _buildPreciosData(DatosGrafica datosGrafica) {
    final spotsContado = <FlSpot>[];
    final spotsCuota = <FlSpot>[];

    if (datosGrafica.tieneDatosAmbos) {
      final contado = datosGrafica.datosPorTipo!['contado']!;
      final cuota = datosGrafica.datosPorTipo!['cuota']!;

      for (int i = 0; i < datosGrafica.labels.length; i++) {
        spotsContado.add(FlSpot(i.toDouble(), contado.precios[i]));
        spotsCuota.add(FlSpot(i.toDouble(), cuota.precios[i]));
      }
    } else if (datosGrafica.tieneDatosIndividual) {
      final datos = datosGrafica.datosIndividual!;
      for (int i = 0; i < datosGrafica.labels.length; i++) {
        spotsContado.add(FlSpot(i.toDouble(), datos.precios[i]));
      }
    }

    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (LineBarSpot touchedSpot) =>
              Colors.blueGrey.withOpacity(0.8),
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              final fecha = datosGrafica.labels[spot.x.toInt()];
              final valor = spot.y;
              return LineTooltipItem(
                '$fecha\nS/. ${valor.toStringAsFixed(2)}',
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: _buildBottomTitles(datosGrafica.labels),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text('S/. ${value.toInt()}');
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      minX: 0,
      maxX: (datosGrafica.labels.length - 1).toDouble(),
      minY: _getMinY(datosGrafica),
      maxY: _getMaxY(datosGrafica),
      lineBarsData: [
        if (spotsContado.isNotEmpty)
          LineChartBarData(
            spots: spotsContado,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        if (spotsCuota.isNotEmpty && datosGrafica.tieneDatosAmbos)
          LineChartBarData(
            spots: spotsCuota,
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
      ],
    );
  }

  LineChartData _buildVariacionesData(DatosGrafica datosGrafica) {
    final spotsContado = <FlSpot>[];
    final spotsCuota = <FlSpot>[];

    if (datosGrafica.tieneDatosAmbos) {
      final contado = datosGrafica.datosPorTipo!['contado']!;
      final cuota = datosGrafica.datosPorTipo!['cuota']!;

      for (int i = 0; i < datosGrafica.labels.length; i++) {
        spotsContado.add(
          FlSpot(i.toDouble(), contado.variacionesPorcentuales[i]),
        );
        spotsCuota.add(FlSpot(i.toDouble(), cuota.variacionesPorcentuales[i]));
      }
    } else if (datosGrafica.tieneDatosIndividual) {
      final datos = datosGrafica.datosIndividual!;
      for (int i = 0; i < datosGrafica.labels.length; i++) {
        spotsContado.add(
          FlSpot(i.toDouble(), datos.variacionesPorcentuales[i]),
        );
      }
    }

    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (LineBarSpot touchedSpot) =>
              Colors.blueGrey.withOpacity(0.8),
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              final fecha = datosGrafica.labels[spot.x.toInt()];
              final valor = spot.y;
              return LineTooltipItem(
                '$fecha\n${valor.toStringAsFixed(2)}%',
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: _buildBottomTitles(datosGrafica.labels),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text('${value.toInt()}%');
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      minX: 0,
      maxX: (datosGrafica.labels.length - 1).toDouble(),
      minY: _getMinYVariacion(datosGrafica),
      maxY: _getMaxYVariacion(datosGrafica),
      lineBarsData: [
        if (spotsContado.isNotEmpty)
          LineChartBarData(
            spots: spotsContado,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        if (spotsCuota.isNotEmpty && datosGrafica.tieneDatosAmbos)
          LineChartBarData(
            spots: spotsCuota,
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
      ],
    );
  }

  SideTitles _buildBottomTitles(List<String> labels) {
    return SideTitles(
      showTitles: true,
      reservedSize: 32,
      getTitlesWidget: (value, meta) {
        if (value.toInt() >= labels.length) return const Text('');

        final fecha = labels[value.toInt()];
        final fechaFormateada = _formatearFecha(fecha);

        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(fechaFormateada, style: const TextStyle(fontSize: 10)),
        );
      },
    );
  }

  double _getMinY(DatosGrafica datosGrafica) {
    double min = double.infinity;

    if (datosGrafica.tieneDatosAmbos) {
      final contado = datosGrafica.datosPorTipo!['contado']!;
      final cuota = datosGrafica.datosPorTipo!['cuota']!;
      min = [
        ...contado.precios,
        ...cuota.precios,
      ].reduce((a, b) => a < b ? a : b);
    } else if (datosGrafica.tieneDatosIndividual) {
      final datos = datosGrafica.datosIndividual!;
      min = datos.precios.reduce((a, b) => a < b ? a : b);
    }

    return min * 0.95; // Un poco menos para mejor visualización
  }

  double _getMaxY(DatosGrafica datosGrafica) {
    double max = double.negativeInfinity;

    if (datosGrafica.tieneDatosAmbos) {
      final contado = datosGrafica.datosPorTipo!['contado']!;
      final cuota = datosGrafica.datosPorTipo!['cuota']!;
      max = [
        ...contado.precios,
        ...cuota.precios,
      ].reduce((a, b) => a > b ? a : b);
    } else if (datosGrafica.tieneDatosIndividual) {
      final datos = datosGrafica.datosIndividual!;
      max = datos.precios.reduce((a, b) => a > b ? a : b);
    }

    return max * 1.05; // Un poco más para mejor visualización
  }

  double _getMinYVariacion(DatosGrafica datosGrafica) {
    double min = 0;

    if (datosGrafica.tieneDatosAmbos) {
      final contado = datosGrafica.datosPorTipo!['contado']!;
      final cuota = datosGrafica.datosPorTipo!['cuota']!;
      min = [
        ...contado.variacionesPorcentuales,
        ...cuota.variacionesPorcentuales,
      ].reduce((a, b) => a < b ? a : b);
    } else if (datosGrafica.tieneDatosIndividual) {
      final datos = datosGrafica.datosIndividual!;
      min = datos.variacionesPorcentuales.reduce((a, b) => a < b ? a : b);
    }

    return min - 2; // Un poco menos para mejor visualización
  }

  double _getMaxYVariacion(DatosGrafica datosGrafica) {
    double max = 0;

    if (datosGrafica.tieneDatosAmbos) {
      final contado = datosGrafica.datosPorTipo!['contado']!;
      final cuota = datosGrafica.datosPorTipo!['cuota']!;
      max = [
        ...contado.variacionesPorcentuales,
        ...cuota.variacionesPorcentuales,
      ].reduce((a, b) => a > b ? a : b);
    } else if (datosGrafica.tieneDatosIndividual) {
      final datos = datosGrafica.datosIndividual!;
      max = datos.variacionesPorcentuales.reduce((a, b) => a > b ? a : b);
    }

    return max + 2; // Un poco más para mejor visualización
  }

  String _formatearFecha(String fechaISO) {
    try {
      final fecha = DateTime.parse(fechaISO);
      return '${fecha.day}/${fecha.month}';
    } catch (e) {
      return fechaISO;
    }
  }

  Widget _buildLegend(DatosGrafica datosGrafica) {
    if (!datosGrafica.tieneDatosAmbos) return const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Contado', Colors.blue),
        const SizedBox(width: 16),
        _buildLegendItem('Cuota', Colors.orange),
      ],
    );
  }

  Widget _buildLegendItem(String texto, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(texto, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildEstadisticas() {
    final estadisticas = widget.historialData.estadisticas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estadísticas del Período:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        if (estadisticas.length == 1)
          _buildEstadisticasIndividual(estadisticas.values.first),

        if (estadisticas.length == 2)
          Column(
            children: [
              _buildEstadisticasTipo('Contado', estadisticas['contado']!),
              const SizedBox(height: 8),
              _buildEstadisticasTipo('Cuota', estadisticas['cuota']!),
            ],
          ),
      ],
    );
  }

  Widget _buildEstadisticasIndividual(EstadisticasPrecio stats) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildEstadisticaItem(
            'Máx',
            'S/. ${stats.precioMaximo.toStringAsFixed(2)}',
          ),
          _buildEstadisticaItem(
            'Mín',
            'S/. ${stats.precioMinimo.toStringAsFixed(2)}',
          ),
          _buildEstadisticaItem(
            'Prom',
            'S/. ${stats.precioPromedio.toStringAsFixed(2)}',
          ),
          _buildEstadisticaItem('Cambios', stats.totalCambios.toString()),
        ],
      ),
    );
  }

  Widget _buildEstadisticasTipo(String tipo, EstadisticasPrecio stats) {
    final color = tipo == 'Contado' ? Colors.blue : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            tipo,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          Row(
            children: [
              _buildEstadisticaItem(
                'Máx',
                'S/. ${stats.precioMaximo.toStringAsFixed(0)}',
              ),
              const SizedBox(width: 12),
              _buildEstadisticaItem(
                'Mín',
                'S/. ${stats.precioMinimo.toStringAsFixed(0)}',
              ),
              const SizedBox(width: 12),
              _buildEstadisticaItem('Cambios', stats.totalCambios.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticaItem(String titulo, String valor) {
    return Column(
      children: [
        Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          valor,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
