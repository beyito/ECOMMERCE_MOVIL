// views/checkout_view.dart
import 'package:flutter/material.dart';
import 'package:ecommerce_movil/services/venta/pedido_service.dart';
import 'package:ecommerce_movil/models/venta/forma_pago_model.dart';

class CheckoutView extends StatefulWidget {
  final double total;
  final int carritoId;

  const CheckoutView({Key? key, required this.total, required this.carritoId})
    : super(key: key);

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final PedidoService _pedidoService = PedidoService();

  late Future<FormaPagoResponse> _futuroFormasPago;
  List<FormaPago> _formasPago = [];
  FormaPago? _formaPagoSeleccionada;
  int? _mesesCreditoSeleccionado;
  bool _procesandoPedido = false;
  bool _cargandoFormasPago = true;

  // Opciones de meses para crédito
  final List<int> _opcionesMeses = [6, 12];

  @override
  void initState() {
    super.initState();
    _futuroFormasPago = _cargarFormasPago();
  }

  Future<FormaPagoResponse> _cargarFormasPago() async {
    try {
      print('🔍 Cargando formas de pago...');
      final response = await _pedidoService.listarFormasPagoActivos();
      print('✅ Formas de pago cargadas: ${response.values.formasPago.length}');

      if (response.values.formasPago.isNotEmpty) {
        print('📋 Formas de pago disponibles:');
        for (var formaPago in response.values.formasPago) {
          print('   - ${formaPago.nombre} (ID: ${formaPago.id})');
        }
      } else {
        print('⚠️ No se encontraron formas de pago');
      }

      setState(() {
        _formasPago = response.values.formasPago;
        _cargandoFormasPago = false;
      });
      return response;
    } catch (e) {
      print('❌ Error cargando formas de pago: $e');
      setState(() {
        _cargandoFormasPago = false;
      });
      throw e;
    }
  }

  void _recargarFormasPago() {
    setState(() {
      _cargandoFormasPago = true;
      _futuroFormasPago = _cargarFormasPago();
    });
  }

  Future<void> _procesarPedido() async {
    if (_formaPagoSeleccionada == null) {
      _mostrarMensajeError('Por favor selecciona una forma de pago');
      return;
    }

    // Validar que si es crédito, tenga meses seleccionados
    if (_formaPagoSeleccionada!.nombre.toLowerCase().contains('credito') &&
        _mesesCreditoSeleccionado == null) {
      _mostrarMensajeError('Por favor selecciona los meses de crédito');
      return;
    }

    setState(() {
      _procesandoPedido = true;
    });

    try {
      final pedidoRequest = PedidoRequest(
        formaPago: _formaPagoSeleccionada!.id,
        mesesCredito: _mesesCreditoSeleccionado,
      );

      final respuesta = await _pedidoService.generarPedido(pedidoRequest);

      if (respuesta.status == 1) {
        _mostrarMensajeExito('Pedido generado exitosamente');

        // Navegar a confirmación o limpiar carrito
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        _mostrarMensajeError(respuesta.message);
      }
    } catch (e) {
      _mostrarMensajeError('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _procesandoPedido = false;
        });
      }
    }
  }

  void _mostrarMensajeExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarMensajeError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proceso de Pago'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<FormaPagoResponse>(
        future: _futuroFormasPago,
        builder: (context, snapshot) {
          if (_cargandoFormasPago) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return _construirError(snapshot.error.toString());
          } else if (snapshot.hasData || _formasPago.isNotEmpty) {
            return _construirContenido();
          } else {
            return _construirSinFormasPago();
          }
        },
      ),
    );
  }

  Widget _construirError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar formas de pago',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _recargarFormasPago,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _construirSinFormasPago() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.payment, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No hay formas de pago disponibles',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Por favor, intenta más tarde',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _recargarFormasPago,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _construirContenido() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen del pedido
          _construirResumenPedido(),
          const SizedBox(height: 24),

          // Formas de pago
          _construirFormasPago(),
          const SizedBox(height: 24),

          // Opciones de crédito (si aplica)
          if (_formaPagoSeleccionada != null &&
              _formaPagoSeleccionada!.nombre.toLowerCase().contains('credito'))
            _construirOpcionesCredito(),

          const SizedBox(height: 32),

          // Botón de confirmar pedido
          _construirBotonConfirmar(),
        ],
      ),
    );
  }

  Widget _construirResumenPedido() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del Pedido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total a pagar:', style: TextStyle(fontSize: 16)),
                Text(
                  'S/. ${widget.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Carrito ID: ${widget.carritoId}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirFormasPago() {
    if (_formasPago.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.payment, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              const Text(
                'No hay formas de pago disponibles',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona forma de pago',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._formasPago.map((formaPago) {
              return _construirOpcionFormaPago(formaPago);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _construirOpcionFormaPago(FormaPago formaPago) {
    final bool isSelected = _formaPagoSeleccionada?.id == formaPago.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? Colors.blue[50] : null,
      elevation: isSelected ? 2 : 1,
      child: ListTile(
        leading: Icon(
          _obtenerIconoFormaPago(formaPago.nombre),
          color: isSelected ? Colors.blue : Colors.grey,
        ),
        title: Text(
          formaPago.nombre,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          formaPago.descripcion,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.blue)
            : null,
        onTap: () {
          setState(() {
            _formaPagoSeleccionada = formaPago;
            // Resetear meses si no es crédito
            if (!formaPago.nombre.toLowerCase().contains('credito')) {
              _mesesCreditoSeleccionado = null;
            }
          });
        },
      ),
    );
  }

  IconData _obtenerIconoFormaPago(String nombre) {
    if (nombre.toLowerCase().contains('credito')) {
      return Icons.credit_card;
    } else if (nombre.toLowerCase().contains('contado')) {
      return Icons.money;
    } else {
      return Icons.payment;
    }
  }

  Widget _construirOpcionesCredito() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona meses de crédito',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _opcionesMeses.map((meses) {
                final bool isSelected = _mesesCreditoSeleccionado == meses;
                return ChoiceChip(
                  label: Text('$meses meses'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _mesesCreditoSeleccionado = selected ? meses : null;
                    });
                  },
                  selectedColor: Colors.blue,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            if (_mesesCreditoSeleccionado != null)
              Text(
                'Pago mensual aproximado: S/. ${(widget.total / _mesesCreditoSeleccionado!).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _construirBotonConfirmar() {
    return SizedBox(
      width: double.infinity,
      child: _procesandoPedido
          ? const ElevatedButton(
              onPressed: null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Procesando pedido...'),
                ],
              ),
            )
          : ElevatedButton(
              onPressed: _procesarPedido,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirmar Pedido',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}
