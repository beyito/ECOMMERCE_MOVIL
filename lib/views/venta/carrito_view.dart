// views/carrito_view.dart (actualizado)
import 'package:flutter/material.dart';
import 'package:ecommerce_movil/services/venta/carrito_service.dart';
import 'package:ecommerce_movil/models/venta/carrito_model.dart';
import 'package:ecommerce_movil/widgets/cantidad_dialog.dart';
import 'package:go_router/go_router.dart';

class CarritoView extends StatefulWidget {
  const CarritoView({Key? key}) : super(key: key);

  @override
  State<CarritoView> createState() => _CarritoViewState();
}

class _CarritoViewState extends State<CarritoView> {
  final CarritoService _servicioCarrito = CarritoService();
  late Future<CarritoResponse> _futuroCarrito;
  final Map<int, bool> _eliminandoProductos = {};
  final Map<int, bool> _actualizandoProductos = {};

  @override
  void initState() {
    super.initState();
    _futuroCarrito = _servicioCarrito.obtenerCarrito();
  }

  @override
  void dispose() {
    // Limpiar cualquier operación pendiente
    super.dispose();
  }

  void _recargarCarrito() {
    if (!mounted) return;
    setState(() {
      _futuroCarrito = _servicioCarrito.obtenerCarrito();
    });
  }

  Future<void> _actualizarCantidad(int productoId, int nuevaCantidad) async {
    if (nuevaCantidad <= 0) {
      await _eliminarProducto(productoId);
      return;
    }

    if (!mounted) return;
    setState(() {
      _actualizandoProductos[productoId] = true;
    });

    try {
      final respuesta = await _servicioCarrito.actualizarCantidadProducto(
        productoId: productoId,
        nuevaCantidad: nuevaCantidad,
      );

      if (!mounted) return;

      if (respuesta.status == 1) {
        _recargarCarrito();
        _mostrarMensajeExito('Cantidad actualizada');
      } else {
        _mostrarMensajeError(respuesta.message);
      }
    } catch (e) {
      if (!mounted) return;
      _mostrarMensajeError('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _actualizandoProductos.remove(productoId);
        });
      }
    }
  }

  Future<void> _eliminarProducto(int productoId) async {
    if (!mounted) return;
    setState(() {
      _eliminandoProductos[productoId] = true;
    });

    try {
      final respuesta = await _servicioCarrito.eliminarProductoCarrito(
        productoId,
      );

      if (!mounted) return;

      if (respuesta.status == 1) {
        _recargarCarrito();
        _mostrarMensajeExito('Producto eliminado del carrito');
      } else {
        _mostrarMensajeError(respuesta.message);
      }
    } catch (e) {
      if (!mounted) return;
      _mostrarMensajeError('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _eliminandoProductos.remove(productoId);
        });
      }
    }
  }

  Future<void> _vaciarCarrito() async {
    final shouldVaciar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaciar Carrito'),
        content: const Text(
          '¿Estás seguro de que quieres vaciar todo el carrito?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Vaciar Carrito'),
          ),
        ],
      ),
    );

    if (shouldVaciar == true) {
      await _ejecutarVaciarCarrito();
    }
  }

  Future<void> _ejecutarVaciarCarrito() async {
    try {
      final respuesta = await _servicioCarrito.vaciarCarrito();

      if (!mounted) return;

      if (respuesta.status == 1) {
        _recargarCarrito();
        _mostrarMensajeExito('Carrito vaciado');
      } else {
        _mostrarMensajeError(respuesta.message);
      }
    } catch (e) {
      if (!mounted) return;
      _mostrarMensajeError('Error: $e');
    }
  }

  void _mostrarDialogoActualizarCantidad(ItemCarrito item) {
    showDialog(
      context: context,
      builder: (context) => DialogCantidad(
        stockDisponible: item.stock,
        nombreProducto: item.nombre,
        cantidadInicial: item.cantidad,
      ),
    ).then((cantidad) {
      if (!mounted) return;

      if (cantidad != null && cantidad > 0 && cantidad != item.cantidad) {
        _actualizarCantidad(item.productoId, cantidad);
      }
    });
  }

  void _mostrarDialogoEliminar(ItemCarrito item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${item.nombre}" del carrito?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ).then((confirmado) {
      if (confirmado == true) {
        _eliminarProducto(item.productoId);
      }
    });
  }

  void _mostrarMensajeExito(String mensaje) {
    if (!mounted) return;

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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _mostrarMensajeError(String mensaje) {
    if (!mounted) return;

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
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _recargarCarrito,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar carrito',
          ),
        ],
      ),
      body: FutureBuilder<CarritoResponse>(
        future: _futuroCarrito,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return _construirErrorCarrito(snapshot.error.toString());
          } else if (snapshot.hasData) {
            final carrito = snapshot.data!;
            final productos = carrito.values.productos;

            if (productos.isEmpty) {
              return _construirCarritoVacio();
            }

            return Column(
              children: [
                // Lista de productos
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      return _construirItemCarrito(productos[index]);
                    },
                  ),
                ),

                // Resumen y botones
                _construirResumenCarrito(carrito.values),
              ],
            );
          } else {
            return const Center(child: Text('No se pudo cargar el carrito'));
          }
        },
      ),
    );
  }

  Widget _construirErrorCarrito(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar el carrito',
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
            onPressed: _recargarCarrito,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _construirCarritoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            'Tu carrito está vacío',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Agrega algunos productos para continuar',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (mounted) {
                context.go(
                  '/home/0',
                ); // 👈 Esto te lleva al Inicio (primer tab)
              }
            },
            child: const Text('Seguir Comprando'),
          ),
        ],
      ),
    );
  }

  Widget _construirItemCarrito(ItemCarrito item) {
    final estaEliminando = _eliminandoProductos[item.productoId] ?? false;
    final estaActualizando = _actualizandoProductos[item.productoId] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del producto
            Text(
              item.nombre,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Precio unitario
            Text(
              'S/. ${item.precioUnitario.toStringAsFixed(2)} c/u',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // Controles de cantidad y subtotal - Reorganizado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selector de cantidad - Mejorado
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cantidad:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[50],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: estaActualizando || item.cantidad <= 1
                                ? null
                                : () => _actualizarCantidad(
                                    item.productoId,
                                    item.cantidad - 1,
                                  ),
                            icon: const Icon(Icons.remove, size: 18),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            color: Colors.grey[700],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: estaActualizando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    '${item.cantidad}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                          IconButton(
                            onPressed:
                                estaActualizando || item.cantidad >= item.stock
                                ? null
                                : () => _actualizarCantidad(
                                    item.productoId,
                                    item.cantidad + 1,
                                  ),
                            icon: const Icon(Icons.add, size: 18),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            color: Colors.grey[700],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Subtotal - Mejor alineado
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Subtotal:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'S/. ${item.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Stock y botones de acción - Mejor distribuido
            Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Stock disponible
                  Flexible(
                    child: Text(
                      'Stock: ${item.stock} disponibles',
                      style: TextStyle(
                        fontSize: 12,
                        color: item.stock > 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Botones de acción - Con mejor espaciado
                  Row(
                    children: [
                      // Botón editar cantidad
                      IconButton(
                        onPressed: estaActualizando
                            ? null
                            : () => _mostrarDialogoActualizarCantidad(item),
                        icon: Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.blue[600],
                        ),
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        tooltip: 'Editar cantidad',
                      ),

                      const SizedBox(width: 4),

                      // Botón eliminar
                      estaEliminando
                          ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : IconButton(
                              onPressed: () => _mostrarDialogoEliminar(item),
                              icon: Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.red[600],
                              ),
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              tooltip: 'Eliminar producto',
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirResumenCarrito(CarritoData carrito) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Total con mejor diseño
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total a pagar:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'S/. ${carrito.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Botones de acción - Mejor distribuidos
            Column(
              children: [
                // Botones superiores
                Row(
                  children: [
                    // Botón vaciar carrito
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _vaciarCarrito(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.red.shade300),
                        ),
                        icon: const Icon(Icons.delete_outline, size: 20),
                        label: const Text('Vaciar Carrito'),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Botón seguir comprando
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/home/0'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.blue.shade300),
                        ),
                        icon: const Icon(Icons.arrow_back, size: 20),
                        label: const Text('Seguir Comprando'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Botón principal de pago
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navegar al checkout
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutView()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.payment, size: 20),
                    label: const Text(
                      'Proceder al Pago',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Los métodos _construirItemCarrito y _construirResumenCarrito se mantienen igual
  // ... (copia los mismos métodos que tenías antes)
}
