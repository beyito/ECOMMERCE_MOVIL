// views/cliente/reportes_cliente_view.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ecommerce_movil/models/reporte/reporte_cliente_model.dart';
import 'package:ecommerce_movil/services/reporte/reporte_cliente_service.dart';
import 'package:ecommerce_movil/services/voice_service.dart'; // SERVICIO CENTRALIZADO
import 'package:http/http.dart' as http;
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class ReportesClienteView extends StatefulWidget {
  const ReportesClienteView({Key? key}) : super(key: key);

  @override
  State<ReportesClienteView> createState() => _ReportesClienteViewState();
}

class _ReportesClienteViewState extends State<ReportesClienteView> {
  final VoiceService _voiceService = VoiceService(); // SERVICIO CENTRALIZADO
  final TextEditingController _textController = TextEditingController();
  bool _isListening = false;
  bool _cargando = false;
  String _respuestaIA = '';
  EstadisticasCliente? _estadisticas;

  // Variables para reportes
  List<dynamic>? _datosConsulta;
  String _tipoConsulta = '';
  int _totalResultados = 0;
  Map<String, dynamic>? _estadisticasCliente;

  // NUEVAS VARIABLES PARA FILTROS
  bool _mostrarFiltros = false;
  Map<String, dynamic> _filtrosActuales = {};
  Map<String, dynamic> _opcionesFiltros = {};
  final ReporteClienteService _service = ReporteClienteService();

  // Controladores para filtros
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _fechaFinController = TextEditingController();
  String? _estadoSeleccionado;
  String? _tipoPagoSeleccionado;
  final TextEditingController _montoMinimoController = TextEditingController();
  final TextEditingController _montoMaximoController = TextEditingController();

  // AÑADIR ESTA VARIABLE
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
    _cargarOpcionesFiltros();
    _inicializarVoz();
  }

  void _inicializarVoz() async {
    // Solo inicializamos, no hay problema si ya está inicializado
    await _voiceService.initialize();
  }

  void _cargarEstadisticas() async {
    setState(() => _cargando = true);
    try {
      final stats = await _service.obtenerEstadisticas();
      setState(() => _estadisticas = stats);
    } catch (e) {
      _mostrarErrorSnackBar('Error al cargar estadísticas: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  void _generarPDFReporte() async {
    if (_filtrosActuales.isEmpty && _datosConsulta == null) {
      _mostrarErrorSnackBar('No hay datos para generar PDF');
      return;
    }

    setState(() => _cargando = true);

    try {
      final response = await _service.generarPDFReporte(_filtrosActuales);

      // Descargar el PDF
      _descargarPDF(response);

      _mostrarMensajeSnackBar('PDF generado exitosamente');
    } catch (e) {
      _mostrarErrorSnackBar('Error al generar PDF: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  void _generarPDFConsulta() async {
    if (_textController.text.isEmpty) {
      _mostrarErrorSnackBar('No hay consulta para generar PDF');
      return;
    }

    setState(() => _cargando = true);

    try {
      final response = await _service.generarPDFConsulta(_textController.text);

      // Descargar el PDF
      _descargarPDF(response);

      _mostrarMensajeSnackBar('PDF de consulta generado exitosamente');
    } catch (e) {
      _mostrarErrorSnackBar('Error al generar PDF: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  void _descargarPDF(http.Response response) async {
    try {
      // Crear archivo temporal
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'Reporte_Compras_$timestamp.pdf';
      final filePath = '${directory.path}/$fileName';

      // Guardar el archivo temporalmente
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Compartir el archivo
      await Share.shareXFiles(
        [XFile(filePath)],
        text:
            '📊 Mi Reporte de Compras\n\n'
            'Fecha: ${DateTime.now().toString().split(' ').first}\n'
            'Generado desde Mi App Ecommerce',
        subject: 'Reporte de Compras - Mi App Ecommerce',
      );

      _mostrarMensajeSnackBar('📤 PDF listo para compartir');
      print('📄 PDF compartido desde: $filePath');

      // Opcional: Limpiar archivo temporal después de un tiempo
      Future.delayed(const Duration(minutes: 5), () {
        if (file.existsSync()) {
          file.delete();
        }
      });
    } catch (e) {
      _mostrarErrorSnackBar('❌ Error al compartir PDF: $e');
      print('❌ Error al compartir PDF: $e');
    }
  }

  // NUEVO: Cargar opciones para filtros
  void _cargarOpcionesFiltros() async {
    try {
      final opciones = await _service.obtenerOpcionesFiltros();
      setState(() => _opcionesFiltros = opciones);
    } catch (e) {
      print('Error cargando opciones de filtros: $e');
      // Opciones por defecto en caso de error
      setState(() {
        _opcionesFiltros = {
          'estados': ['pendiente', 'procesando', 'completado', 'cancelado'],
          'tipos_pago': ['contado', 'crédito'],
          'rango_fechas': {
            'min': '2023-01-01',
            'max': DateTime.now().toString().substring(0, 10),
          },
        };
      });
    }
  }

  void _toggleEscuchaVoz() async {
    if (!_isListening) {
      // Usar el servicio centralizado
      if (!_voiceService.isInitialized) {
        bool initialized = await _voiceService.initialize();
        if (!initialized) {
          _mostrarErrorSnackBar('El reconocimiento de voz no está disponible');
          return;
        }
      }

      if (_voiceService.isListening) {
        _stopListening();
        return;
      }

      setState(() => _isListening = true);

      _voiceService.listen(
        onResult: (text) {
          setState(() {
            _textController.text = text;
          });

          // DETECCIÓN AUTOMÁTICA: Si el texto no cambia después de un tiempo, asumimos que terminó
          if (text.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (_isListening && _textController.text == text) {
                _stopListening();
                _enviarConsulta(); // Enviar automáticamente después de detectar el final
              }
            });
          }
        },
        onError: () {
          setState(() {
            _isListening = false;
          });
          _mostrarErrorSnackBar('Error en el reconocimiento de voz');
        },
        // AGREGAR CONFIGURACIÓN PARA MEJOR DETECCIÓN
        // listenFor: const Duration(seconds: 10),
        // pauseFor: const Duration(seconds: 3),
      );
    } else {
      _stopListening();
    }
  }

  void _stopListening() {
    _voiceService.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _enviarConsulta() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _cargando = true;
      _respuestaIA = '';
      _datosConsulta = null;
      _tipoConsulta = '';
      _totalResultados = 0;
    });

    try {
      final respuesta = await _service.consultarIASeguro(_textController.text);

      setState(() {
        _respuestaIA = respuesta.respuesta;
        _datosConsulta = respuesta.datos;
        _tipoConsulta = respuesta.tipoConsulta;
        _totalResultados = respuesta.totalResultados;
        _estadisticasCliente = respuesta.datosCliente;
      });
    } catch (e) {
      _mostrarErrorSnackBar('Error en consulta: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  // NUEVO: Aplicar filtros personalizados
  void _aplicarFiltros() async {
    setState(() => _cargando = true);

    try {
      final Map<String, dynamic> filtros = {};

      // Construir filtros desde los controles
      if (_fechaInicioController.text.isNotEmpty) {
        filtros['fecha_desde'] = _fechaInicioController.text;
      }
      if (_fechaFinController.text.isNotEmpty) {
        filtros['fecha_hasta'] = _fechaFinController.text;
      }
      if (_estadoSeleccionado != null) {
        filtros['estado'] = _estadoSeleccionado;
      }
      if (_tipoPagoSeleccionado != null) {
        filtros['tipo_pago'] = _tipoPagoSeleccionado;
      }
      if (_montoMinimoController.text.isNotEmpty) {
        filtros['monto_minimo'] = double.parse(_montoMinimoController.text);
      }
      if (_montoMaximoController.text.isNotEmpty) {
        filtros['monto_maximo'] = double.parse(_montoMaximoController.text);
      }

      final respuesta = await _service.generarReporteConFiltros(filtros);

      setState(() {
        _respuestaIA = respuesta.respuesta;
        _datosConsulta = respuesta.datos;
        _tipoConsulta = respuesta.tipoConsulta;
        _totalResultados = respuesta.totalResultados;
        _filtrosActuales = filtros;
        _mostrarFiltros = false;
      });
    } catch (e) {
      _mostrarErrorSnackBar('Error al aplicar filtros: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  // NUEVO: Limpiar filtros
  void _limpiarFiltros() {
    _fechaInicioController.clear();
    _fechaFinController.clear();
    _montoMinimoController.clear();
    _montoMaximoController.clear();
    _estadoSeleccionado = null;
    _tipoPagoSeleccionado = null;
    _filtrosActuales = {};

    setState(() {
      _mostrarFiltros = false;
      _datosConsulta = null;
    });
  }

  // NUEVO: Métodos que no dependen de context
  void _mostrarErrorSnackBar(String mensaje) {
    // Usar un Future.microtask para asegurar que se ejecute después del build
    Future.microtask(() {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  void _mostrarMensajeSnackBar(String mensaje) {
    Future.microtask(() {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    _montoMinimoController.dispose();
    _montoMaximoController.dispose();

    // Detener la escucha si está activa
    if (_isListening) {
      _voiceService.stop();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AÑADIR key aquí
      key: _scaffoldMessengerKey,
      appBar: AppBar(
        title: const Text('Mis Reportes de Compras'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Botón para mostrar/ocultar filtros
          IconButton(
            icon: Icon(
              _mostrarFiltros ? Icons.filter_alt_off : Icons.filter_alt,
            ),
            onPressed: () {
              setState(() => _mostrarFiltros = !_mostrarFiltros);
            },
            tooltip: 'Filtros avanzados',
          ),
          if (_datosConsulta != null && _datosConsulta!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.table_chart),
              onPressed: () {
                _mostrarModalReporteCompleto();
              },
              tooltip: 'Ver reporte completo',
            ),
          // Botón para generar PDF
          if (_datosConsulta != null && _datosConsulta!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _generarPDFConsulta,
              tooltip: 'Generar PDF',
            ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Consulta por voz/texto
                  _buildConsultaInput(),

                  // Filtros avanzados (NUEVO)
                  if (_mostrarFiltros) _buildPanelFiltros(),

                  const SizedBox(height: 20),

                  // Respuesta de IA
                  if (_respuestaIA.isNotEmpty) _buildRespuestaIA(),

                  const SizedBox(height: 20),

                  // Filtros aplicados (NUEVO)
                  if (_filtrosActuales.isNotEmpty) _buildFiltrosAplicados(),

                  const SizedBox(height: 20),

                  // Reporte Tabular (si hay datos)
                  if (_datosConsulta != null && _datosConsulta!.isNotEmpty)
                    _buildReporteTabular(),

                  const SizedBox(height: 20),

                  // Estadísticas
                  if (_estadisticas != null) _buildEstadisticas(),

                  const SizedBox(height: 20),

                  // Reportes Predefinidos
                  _buildReportesPredefinidos(),

                  const SizedBox(height: 20),

                  // Sugerencias de consulta
                  _buildSugerencias(),
                ],
              ),
            ),
    );
  }

  // NUEVO: Panel de filtros avanzados
  Widget _buildPanelFiltros() {
    final estados =
        _opcionesFiltros['estados'] as List<dynamic>? ??
        ['pendiente', 'completado', 'cancelado'];
    final tiposPago =
        _opcionesFiltros['tipos_pago'] as List<dynamic>? ??
        ['contado', 'crédito'];
    final rangoFechas =
        _opcionesFiltros['rango_fechas'] as Map<String, dynamic>? ??
        {
          'min': '2023-01-01',
          'max': DateTime.now().toString().substring(0, 10),
        };

    return Card(
      elevation: 4,
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.tune, size: 20),
                SizedBox(width: 8),
                Text(
                  'Filtros Avanzados',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Información de rango de fechas disponible
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rango disponible: ${rangoFechas['min']} a ${rangoFechas['max']}',
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Fechas
            const Text(
              'Fechas:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fechaInicioController,
                    decoration: InputDecoration(
                      labelText: 'Fecha inicio',
                      hintText: rangoFechas['min'],
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today, size: 20),
                        onPressed: () =>
                            _seleccionarFecha(_fechaInicioController),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _fechaFinController,
                    decoration: InputDecoration(
                      labelText: 'Fecha fin',
                      hintText: rangoFechas['max'],
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today, size: 20),
                        onPressed: () => _seleccionarFecha(_fechaFinController),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Estado y Tipo de Pago
            const Text(
              'Estado y Tipo de Pago:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _estadoSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todos los estados'),
                      ),
                      ...estados.map((estado) {
                        return DropdownMenuItem(
                          value: estado.toString(),
                          child: Text(estado.toString().toTitleCase()),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() => _estadoSeleccionado = value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _tipoPagoSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Pago',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todos los tipos'),
                      ),
                      ...tiposPago.map((tipo) {
                        return DropdownMenuItem(
                          value: tipo.toString(),
                          child: Text(tipo.toString().toTitleCase()),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() => _tipoPagoSeleccionado = value);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Montos
            const Text(
              'Rango de Montos:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _montoMinimoController,
                    decoration: const InputDecoration(
                      labelText: 'Monto mínimo',
                      hintText: '0.00',
                      border: OutlineInputBorder(),
                      prefixText: 'Bs. ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _montoMaximoController,
                    decoration: const InputDecoration(
                      labelText: 'Monto máximo',
                      hintText: '1000.00',
                      border: OutlineInputBorder(),
                      prefixText: 'Bs. ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: const Text('Aplicar Filtros'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _aplicarFiltros,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpiar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _limpiarFiltros,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // NUEVO: Mostrar filtros aplicados
  Widget _buildFiltrosAplicados() {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.filter_list, color: Colors.green, size: 16),
            const SizedBox(width: 8),
            const Text(
              'Filtros aplicados:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Wrap(
                spacing: 8,
                children: _filtrosActuales.entries.map((entry) {
                  return Chip(
                    label: Text('${entry.key}: ${entry.value}'),
                    backgroundColor: Colors.green[100],
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      // Remover filtro individual
                      setState(() => _filtrosActuales.remove(entry.key));
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultaInput() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.smart_toy, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Consulta Inteligente',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Pregunta sobre tus compras...',
                hintText:
                    'Ej: "Mis pedidos pendientes", "Productos más comprados"',
                border: const OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                      onPressed: _toggleEscuchaVoz,
                      color: _isListening ? Colors.red : Colors.blue,
                      tooltip: 'Voz',
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _enviarConsulta,
                      color: Colors.blue,
                      tooltip: 'Buscar',
                    ),
                  ],
                ),
              ),
            ),
            if (_isListening)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mic, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'Escuchando...',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRespuestaIA() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.smart_toy, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Asistente IA',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                if (_totalResultados > 0)
                  Chip(
                    label: Text('$_totalResultados resultados'),
                    backgroundColor: Colors.blue[100],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(_respuestaIA, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // Widget para reportes tabulares
  Widget _buildReporteTabular() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📊 Reporte: ${_tipoConsulta.toTitleCase()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text('$_totalResultados registros'),
                  backgroundColor: Colors.green[100],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tabla según el tipo de consulta
            if (_tipoConsulta == 'pedidos' ||
                _tipoConsulta == 'pedidos_filtrados')
              _buildTablaPedidos()
            else if (_tipoConsulta == 'ventas')
              _buildTablaProductos()
            else
              _buildTablaGenerica(),

            const SizedBox(height: 12),
            if (_datosConsulta != null && _datosConsulta!.length > 10)
              Text(
                '💡 Mostrando los primeros 10 de $_totalResultados registros',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            Text(
              '💡 Tip: Toca un registro para ver detalles',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTablaPedidos() {
    final datos = _datosConsulta!;

    if (datos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text('No hay datos para mostrar'),
      );
    }

    // Obtener columnas dinámicamente del primer registro
    final primerPedido = datos.first as Map<String, dynamic>;
    final columnas = primerPedido.keys.toList();

    // Columnas importantes para mostrar primero
    final columnasPrioritarias = [
      'fecha',
      'total',
      'estado',
      'forma_pago__nombre',
    ];
    final otrasColumnas = columnas
        .where((col) => !columnasPrioritarias.contains(col))
        .toList();
    final columnasOrdenadas = [...columnasPrioritarias, ...otrasColumnas];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        horizontalMargin: 0,
        headingRowColor: MaterialStateProperty.all(Colors.blue[50]),
        columns: columnasOrdenadas.map((columna) {
          return DataColumn(
            label: Text(
              _formatearNombreColumna(columna),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          );
        }).toList(),
        rows: datos.take(10).map((pedido) {
          final pedidoMap = pedido as Map<String, dynamic>;
          return DataRow(
            onSelectChanged: (_) {
              _mostrarDetallesPedido(pedidoMap);
            },
            cells: columnasOrdenadas.map((columna) {
              final valor = pedidoMap[columna]?.toString() ?? '';
              return DataCell(
                Tooltip(
                  message: valor,
                  child: Text(
                    _formatearValor(columna, valor),
                    style: TextStyle(
                      fontSize: 11,
                      color: _obtenerColorPorColumna(columna, valor),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTablaProductos() {
    final datos = _datosConsulta!;

    if (datos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text('No hay datos para mostrar'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        horizontalMargin: 0,
        headingRowColor: MaterialStateProperty.all(Colors.green[50]),
        columns: const [
          DataColumn(
            label: Text(
              'Producto',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Veces Comprado',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Unidades',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Total Gastado',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: datos.take(10).map((producto) {
          final productoMap = producto as Map<String, dynamic>;
          return DataRow(
            onSelectChanged: (_) {
              _mostrarDetallesProducto(productoMap);
            },
            cells: [
              DataCell(
                Text(
                  productoMap['producto__nombre']?.toString() ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DataCell(
                Text(
                  productoMap['veces_comprado']?.toString() ?? '0',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text(
                  productoMap['total_unidades']?.toString() ?? '0',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DataCell(
                Text(
                  'Bs. ${(double.tryParse(productoMap['total_gastado']?.toString() ?? '0') ?? 0).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTablaGenerica() {
    final datos = _datosConsulta!;

    if (datos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text('No hay datos para mostrar'),
      );
    }

    final primerItem = datos.first as Map<String, dynamic>;
    final columnas = primerItem.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        horizontalMargin: 0,
        columns: columnas.map((columna) {
          return DataColumn(
            label: Text(
              _formatearNombreColumna(columna),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
        rows: datos.take(5).map((item) {
          final itemMap = item as Map<String, dynamic>;
          return DataRow(
            onSelectChanged: (_) {
              _mostrarDetallesGenerico(itemMap);
            },
            cells: columnas.map((columna) {
              return DataCell(
                Text(
                  itemMap[columna]?.toString() ?? '',
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEstadisticas() {
    final stats = _estadisticas!;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Mis Estadísticas Generales',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildItemEstadistica('Total de Pedidos', '${stats.totalPedidos}'),
            _buildItemEstadistica(
              'Total Gastado',
              'Bs. ${stats.totalGastado.toStringAsFixed(2)}',
            ),
            _buildItemEstadistica(
              'Promedio por Pedido',
              'Bs. ${stats.promedioPorPedido.toStringAsFixed(2)}',
            ),
            if (stats.productosFrecuentes.isNotEmpty)
              _buildItemEstadistica(
                'Producto Más Comprado',
                stats.productosFrecuentes.first['producto__nombre']
                        ?.toString() ??
                    'N/A',
              ),
            if (stats.ultimoPedido.isNotEmpty)
              _buildItemEstadistica(
                'Último Pedido',
                '${stats.ultimoPedido['fecha'] ?? 'N/A'} - Bs. ${(stats.ultimoPedido['total'] ?? 0).toStringAsFixed(2)}',
              ),
            // CORREGIDO: Usar el campo correcto
            _buildItemEstadistica('Miembro Desde', stats.miembroDesde),
            // OPCIONAL: También puedes mostrar los meses como cliente
            if (stats.mesesComoCliente > 0)
              _buildItemEstadistica(
                'Tiempo como Cliente',
                '${stats.mesesComoCliente} meses',
              ),
          ],
        ),
      ),
    );
  }

  // Reportes predefinidos
  Widget _buildReportesPredefinidos() {
    final reportes = [
      {
        'titulo': '📦 Mis Pedidos',
        'descripcion': 'Historial completo de pedidos',
        'consulta': 'mostrar todos mis pedidos',
        'color': Colors.blue,
      },
      {
        'titulo': '💰 Gastos por Mes',
        'descripcion': 'Análisis de gastos mensuales',
        'consulta': 'cuánto he gastado por mes este año',
        'color': Colors.green,
      },
      {
        'titulo': '🏆 Productos Frecuentes',
        'descripcion': 'Lo que más compras',
        'consulta': 'mis productos más comprados',
        'color': Colors.orange,
      },
      {
        'titulo': '⏰ Pedidos Recientes',
        'descripcion': 'Últimos 10 pedidos',
        'consulta': 'mis pedidos más recientes',
        'color': Colors.purple,
      },
      {
        'titulo': '⏳ Pedidos Pendientes',
        'descripcion': 'Pedidos en proceso',
        'consulta': 'mis pedidos pendientes',
        'color': Colors.red,
      },
      {
        'titulo': '✅ Pedidos Completados',
        'descripcion': 'Pedidos entregados',
        'consulta': 'mis pedidos completados',
        'color': Colors.teal,
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.rocket_launch, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Reportes Rápidos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Consultas predefinidas para análisis rápido',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: reportes.map((reporte) {
                return InkWell(
                  onTap: () {
                    _textController.text = reporte['consulta'] as String;
                    _enviarConsulta();
                  },
                  child: Container(
                    width: 160,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (reporte['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (reporte['color'] as Color).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reporte['titulo'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: reporte['color'] as Color,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reporte['descripcion'] as String,
                          style: const TextStyle(fontSize: 11),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemEstadistica(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSugerencias() {
    final sugerencias = [
      "¿Cuál fue mi último pedido?",
      "¿Cuánto he gastado en total?",
      "¿Cuál es mi producto más comprado?",
      "¿Cuántos pedidos tengo este mes?",
      "¿Tengo pedidos pendientes?",
      "¿Cuál fue mi pedido más caro?",
      "¿Cuánto gasté el mes pasado?",
      "¿Qué productos compro más?",
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Sugerencias de Búsqueda',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sugerencias.map((sugerencia) {
                return ActionChip(
                  label: Text(sugerencia, style: const TextStyle(fontSize: 12)),
                  onPressed: () {
                    _textController.text = sugerencia;
                    _enviarConsulta();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // NUEVO: Mostrar detalles del pedido
  void _mostrarDetallesPedido(Map<String, dynamic> pedido) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles del Pedido'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: pedido.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        '${_formatearNombreColumna(entry.key)}: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _formatearValor(
                          entry.key,
                          entry.value?.toString() ?? '',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // NUEVO: Mostrar detalles de producto
  void _mostrarDetallesProducto(Map<String, dynamic> producto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles del Producto'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalleItem(
                'Producto',
                producto['producto__nombre']?.toString() ?? 'N/A',
              ),
              _buildDetalleItem(
                'Marca',
                producto['producto__marca__nombre']?.toString() ?? 'N/A',
              ),
              _buildDetalleItem(
                'Veces Comprado',
                producto['veces_comprado']?.toString() ?? '0',
              ),
              _buildDetalleItem(
                'Total Unidades',
                producto['total_unidades']?.toString() ?? '0',
              ),
              _buildDetalleItem(
                'Total Gastado',
                'Bs. ${(double.tryParse(producto['total_gastado']?.toString() ?? '0') ?? 0).toStringAsFixed(2)}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleItem(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$titulo:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }

  void _mostrarDetallesGenerico(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: item.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        '${_formatearNombreColumna(entry.key)}: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(child: Text(entry.value?.toString() ?? '')),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // Funciones auxiliares
  String _formatearNombreColumna(String columna) {
    final map = {
      'fecha': 'Fecha',
      'total': 'Total',
      'estado': 'Estado',
      'usuario__username': 'Cliente',
      'producto__nombre': 'Producto',
      'producto__marca__nombre': 'Marca',
      'cantidad': 'Cantidad',
      'precio_unitario': 'Precio Unitario',
      'subtotal': 'Subtotal',
      'forma_pago__nombre': 'Forma de Pago',
      'veces_comprado': 'Veces Comprado',
      'total_unidades': 'Total Unidades',
      'total_gastado': 'Total Gastado',
    };
    return map[columna] ?? columna.replaceAll('_', ' ').toTitleCase();
  }

  String _formatearValor(String columna, String valor) {
    if (columna == 'total' ||
        columna == 'precio_unitario' ||
        columna == 'subtotal' ||
        columna == 'total_gastado') {
      final numValor = double.tryParse(valor) ?? 0;
      return 'Bs. ${numValor.toStringAsFixed(2)}';
    }
    if (columna == 'fecha' && valor.length > 10) {
      return valor.substring(0, 10); // Mostrar solo la fecha
    }
    return valor.length > 20 ? '${valor.substring(0, 20)}...' : valor;
  }

  Color _obtenerColorPorColumna(String columna, String valor) {
    if (columna == 'estado') {
      switch (valor.toLowerCase()) {
        case 'completado':
        case 'pagado':
        case 'entregado':
          return Colors.green;
        case 'pendiente':
        case 'procesando':
          return Colors.orange;
        case 'cancelado':
        case 'rechazado':
          return Colors.red;
        default:
          return Colors.black;
      }
    }
    return Colors.black;
  }

  void _mostrarModalReporteCompleto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reporte Completo'),
        content: SizedBox(
          width: double.maxFinite,
          child: _buildReporteCompleto(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildReporteCompleto() {
    return SingleChildScrollView(child: _buildTablaPedidos());
  }

  // NUEVO: Seleccionar fecha
  Future<void> _seleccionarFecha(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }
}

// Extensión para formatear texto
extension StringExtension on String {
  String toTitleCase() {
    return split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
