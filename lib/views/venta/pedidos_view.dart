// views/pedidos_view.dart
import 'package:flutter/material.dart';
import 'package:ecommerce_movil/services/venta/pedido_service.dart';
import 'package:ecommerce_movil/models/venta/pedido_model.dart';
import 'package:ecommerce_movil/views/venta/detalle_pedido_view.dart';
import 'package:go_router/go_router.dart';

class PedidosView extends StatefulWidget {
  const PedidosView({Key? key}) : super(key: key);

  @override
  State<PedidosView> createState() => _PedidosViewState();
}

class _PedidosViewState extends State<PedidosView> {
  final PedidoService _pedidoService = PedidoService();
  late Future<PedidosResponse> _futuroPedidos;
  List<Pedido> _pedidos = [];
  String _filtroEstado = 'todos';

  @override
  void initState() {
    super.initState();
    _futuroPedidos = _pedidoService.listarMisPedidos();
  }

  void _recargarPedidos() {
    setState(() {
      _futuroPedidos = _pedidoService.listarMisPedidos();
    });
  }

  List<Pedido> _getPedidosFiltrados() {
    if (_filtroEstado == 'todos') {
      return _pedidos;
    }
    return _pedidos.where((pedido) => pedido.estado == _filtroEstado).toList();
  }

  void _mostrarFiltros(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filtrar por estado',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...['todos', 'pagado', 'no pagado'].map((estado) {
                return ListTile(
                  leading: Icon(
                    _getIconoEstado(estado),
                    color: _getColorEstado(estado),
                  ),
                  title: Text(
                    estado == 'todos'
                        ? 'Todos los pedidos'
                        : estado == 'pagado'
                        ? 'Pagados'
                        : 'No pagados',
                    style: TextStyle(
                      fontWeight: _filtroEstado == estado
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: _filtroEstado == estado
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() {
                      _filtroEstado = estado;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconoEstado(String estado) {
    switch (estado) {
      case 'pagado':
        return Icons.check_circle;
      case 'no pagado':
        return Icons.cancel;
      case 'todos':
        return Icons.list;
      default:
        return Icons.help_outline;
    }
  }

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'pagado':
        return Colors.green;
      case 'no pagado':
        return Colors.red;
      case 'todos':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _mostrarFiltros(context),
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar pedidos',
          ),
          IconButton(
            onPressed: _recargarPedidos,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar pedidos',
          ),
        ],
      ),
      body: FutureBuilder<PedidosResponse>(
        future: _futuroPedidos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return _construirError(snapshot.error.toString());
          } else if (snapshot.hasData) {
            _pedidos = snapshot.data!.values;
            final pedidosFiltrados = _getPedidosFiltrados();

            if (pedidosFiltrados.isEmpty) {
              return _construirSinPedidos();
            }

            return Column(
              children: [
                // Contador de pedidos
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[50],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${pedidosFiltrados.length} pedido${pedidosFiltrados.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_filtroEstado != 'todos')
                        Chip(
                          label: Text(
                            _filtroEstado == 'pagado'
                                ? 'Pagados'
                                : 'No pagados',
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: _getColorEstado(
                            _filtroEstado,
                          ).withOpacity(0.2),
                        ),
                    ],
                  ),
                ),
                // Lista de pedidos
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pedidosFiltrados.length,
                    itemBuilder: (context, index) {
                      return _construirItemPedido(pedidosFiltrados[index]);
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: Text('No se pudieron cargar los pedidos'),
            );
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
            'Error al cargar pedidos',
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
            onPressed: _recargarPedidos,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _construirSinPedidos() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            'No tienes pedidos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Cuando realices un pedido, aparecerá aquí',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navegar a la tienda
              context.go('/home/0');
            },
            child: const Text('Ir a Comprar'),
          ),
        ],
      ),
    );
  }

  Widget _construirItemPedido(Pedido pedido) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navegar al detalle del pedido
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DetallePedidoView(pedidoId: pedido.pedidoId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con ID y fecha
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pedido #${pedido.pedidoId}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    pedido.fecha,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Estado y forma de pago
              Row(
                children: [
                  Icon(pedido.estadoIcon, size: 16, color: pedido.estadoColor),
                  const SizedBox(width: 4),
                  Text(
                    pedido.estado,
                    style: TextStyle(
                      fontSize: 14,
                      color: pedido.estadoColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.payment, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    pedido.formaPago,
                    style: const TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Resumen de productos
              Text(
                '${pedido.detalles.length} producto${pedido.detalles.length != 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'S/. ${pedido.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              // Flecha indicadora
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
