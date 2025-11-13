// views/detalle_pedido_view.dart
import 'package:flutter/material.dart';
import 'package:ecommerce_movil/services/venta/pedido_service.dart';
import 'package:ecommerce_movil/models/venta/pedido_model.dart';
import 'package:ecommerce_movil/models/venta/plan_pago_model.dart';

class DetallePedidoView extends StatefulWidget {
  final int pedidoId;

  const DetallePedidoView({Key? key, required this.pedidoId}) : super(key: key);

  @override
  State<DetallePedidoView> createState() => _DetallePedidoViewState();
}

class _DetallePedidoViewState extends State<DetallePedidoView> {
  final PedidoService _pedidoService = PedidoService();
  late Future<PedidoDetalleResponse> _futuroPedidoDetalle;
  late Future<PlanPagosResponse> _futuroPlanPagos;

  @override
  void initState() {
    super.initState();
    _futuroPedidoDetalle = _pedidoService.obtenerPedido(widget.pedidoId);
    _futuroPlanPagos = _pedidoService.obtenerPlanPagosPedido(widget.pedidoId);
  }

  void _recargarDetalle() {
    setState(() {
      _futuroPedidoDetalle = _pedidoService.obtenerPedido(widget.pedidoId);
      _futuroPlanPagos = _pedidoService.obtenerPlanPagosPedido(widget.pedidoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #${widget.pedidoId}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _recargarDetalle,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: FutureBuilder<PedidoDetalleResponse>(
        future: _futuroPedidoDetalle,
        builder: (context, snapshotPedido) {
          if (snapshotPedido.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshotPedido.hasError) {
            return _construirError(snapshotPedido.error.toString());
          } else if (snapshotPedido.hasData) {
            final pedido = snapshotPedido.data!.values;
            return _construirDetallePedido(pedido);
          } else {
            return const Center(child: Text('No se pudo cargar el pedido'));
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
            'Error al cargar el pedido',
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
            onPressed: _recargarDetalle,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _construirDetallePedido(PedidoDetalle pedido) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información general del pedido
          _construirInfoPedido(pedido),
          const SizedBox(height: 24),

          // Productos del pedido
          _construirProductosPedido(pedido),
          const SizedBox(height: 24),

          // Resumen total
          _construirResumenTotal(pedido),
          const SizedBox(height: 24),

          // Plan de pagos
          FutureBuilder<PlanPagosResponse>(
            future: _futuroPlanPagos,
            builder: (context, snapshotPlanPagos) {
              if (snapshotPlanPagos.connectionState ==
                  ConnectionState.waiting) {
                return _construirPlanPagosCargando();
              } else if (snapshotPlanPagos.hasError) {
                return _construirPlanPagosError(
                  snapshotPlanPagos.error.toString(),
                );
              } else if (snapshotPlanPagos.hasData) {
                final planPagos = snapshotPlanPagos.data!.values.planPagos;
                return _construirPlanPagos(planPagos);
              } else {
                return Container(); // Ocultar si no hay datos
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _construirInfoPedido(PedidoDetalle pedido) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información del Pedido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _construirItemInfo('Número de pedido', '#${pedido.pedidoId}'),
            _construirItemInfo('Fecha', pedido.fecha),
            _construirItemInfo('Cliente', pedido.usuarioNombre),
            _construirItemInfo(
              'Estado',
              pedido.estado,
              valorColor: _getColorEstado(pedido.estado),
            ),
            _construirItemInfo(
              'Forma de pago',
              pedido.formaPago,
              valorColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirItemInfo(String titulo, String valor, {Color? valorColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valorColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirProductosPedido(PedidoDetalle pedido) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Productos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...pedido.detalles.map((detalle) {
              return _construirItemProducto(detalle);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _construirItemProducto(DetallePedido detalle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Información del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detalle.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Cantidad: ${detalle.cantidad}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  'S/. ${detalle.precioUnitario.toStringAsFixed(2)} c/u',
                  style: const TextStyle(fontSize: 14, color: Colors.green),
                ),
              ],
            ),
          ),
          // Subtotal
          Text(
            'S/. ${detalle.subtotal.toStringAsFixed(2)}',
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

  Widget _construirResumenTotal(PedidoDetalle pedido) {
    return Card(
      elevation: 2,
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total del pedido:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'S/. ${pedido.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NUEVO: Widget para el plan de pagos
  Widget _construirPlanPagos(List<CuotaPago> planPagos) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.payment, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Plan de Pagos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (planPagos.isEmpty)
              const Center(
                child: Text(
                  'No hay plan de pagos disponible',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...planPagos.map((cuota) {
                return _construirItemCuota(cuota);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _construirItemCuota(CuotaPago cuota) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getColorFondoEstado(cuota.estado),
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Información de la cuota
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cuota ${cuota.numeroCuota}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Vence: ${cuota.fechaVencimiento}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),

          // Monto y estado
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'S/. ${cuota.monto.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getColorEstado(cuota.estado),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  cuota.estado.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirPlanPagosCargando() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.payment, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Plan de Pagos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _construirPlanPagosError(String error) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.payment, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Plan de Pagos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Error al cargar plan de pagos',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pagado':
        return Colors.green;
      case 'no pagado':
        return Colors.red;
      case 'pendiente':
        return Colors.orange;
      case 'en proceso':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getColorFondoEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pagado':
        return Colors.green[50]!;
      case 'no pagado':
        return Colors.red[50]!;
      case 'pendiente':
        return Colors.orange[50]!;
      case 'en proceso':
        return Colors.blue[50]!;
      default:
        return Colors.grey[50]!;
    }
  }
}
