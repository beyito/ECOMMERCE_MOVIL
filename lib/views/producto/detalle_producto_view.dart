// views/pagina_detalle_producto.dart
import 'package:ecommerce_movil/models/producto/producto_model.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_movil/services/producto/producto_service.dart';
import 'package:ecommerce_movil/services/venta/carrito_service.dart';
import 'package:ecommerce_movil/widgets/cantidad_dialog.dart';
import 'package:ecommerce_movil/models/producto/historial_precio_model.dart';
import 'package:ecommerce_movil/services/producto/historial_precio_service.dart';
import 'package:ecommerce_movil/widgets/grafica_historial_precios.dart';

class DetalleProductoView extends StatefulWidget {
  final int idProducto;

  const DetalleProductoView({Key? key, required this.idProducto})
    : super(key: key);

  @override
  State<DetalleProductoView> createState() => _DetalleProductoViewState();
}

class _DetalleProductoViewState extends State<DetalleProductoView> {
  final ProductoService _servicioProductos = ProductoService();
  final CarritoService _servicioCarrito = CarritoService();
  late Future<DetalleProductoResponse> _futuroDetalleProducto;
  bool _agregandoAlCarrito = false;

  @override
  void initState() {
    super.initState();

    _futuroDetalleProducto = _servicioProductos.obtenerDetalleProducto(
      widget.idProducto,
    );
  }

  void _recargarProducto() {
    setState(() {
      _futuroDetalleProducto = _servicioProductos.obtenerDetalleProducto(
        widget.idProducto,
      );
    });
  }

  Future<void> _agregarAlCarrito(int productoId, int cantidad) async {
    setState(() {
      _agregandoAlCarrito = true;
    });

    try {
      final respuesta = await _servicioCarrito.agregarProductoCarrito(
        productoId: productoId,
        cantidad: cantidad,
      );

      if (respuesta.status == 1) {
        _mostrarMensajeExito(context, 'Producto agregado al carrito');
      } else {
        _mostrarMensajeError(context, respuesta.message);
      }
    } catch (e) {
      _mostrarMensajeError(context, 'Error: $e');
    } finally {
      setState(() {
        _agregandoAlCarrito = false;
      });
    }
  }

  Future<void> _mostrarDialogoCantidad(Producto producto) async {
    final cantidad = await showDialog<int>(
      context: context,
      builder: (context) => DialogCantidad(
        stockDisponible: producto.stock,
        nombreProducto: producto.nombre,
      ),
    );

    if (cantidad != null && cantidad > 0) {
      await _agregarAlCarrito(producto.id, cantidad);
    }
  }

  void _mostrarMensajeExito(BuildContext context, String mensaje) {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _mostrarMensajeError(BuildContext context, String mensaje) {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Icono del carrito en AppBar
          FutureBuilder<DetalleProductoResponse>(
            future: _futuroDetalleProducto,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return IconButton(
                  onPressed: () {
                    // Navegar a la página del carrito
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => CarritoView()));
                  },
                  icon: const Icon(Icons.shopping_cart),
                  tooltip: 'Ver carrito',
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: FutureBuilder<DetalleProductoResponse>(
        future: _futuroDetalleProducto,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _recargarProducto,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final producto = snapshot.data!.valores.producto;
            return _construirDetalleProducto(producto);
          } else {
            return const Center(child: Text('No se pudo cargar el producto'));
          }
        },
      ),
      bottomNavigationBar: _construirBarraInferior(),
    );
  }

  Widget _construirDetalleProducto(Producto producto) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imágenes del producto
          _construirImagenesProducto(producto),
          const SizedBox(height: 20),

          // Información básica
          _construirInformacionBasica(producto),
          const SizedBox(height: 20),

          // Precios
          _construirInformacionPrecios(producto),
          const SizedBox(height: 20),

          // Especificaciones técnicas
          _construirEspecificaciones(producto),
          const SizedBox(height: 20),

          // Descripción
          _construirDescripcion(producto),
          // ✅ AQUÍ PEGA LA NUEVA SECCIÓN DEL HISTORIAL DE PRECIOS
          _construirSeccionHistorialPrecios(producto),
        ],
      ),
    );
  }

  Widget _construirImagenesProducto(Producto producto) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: producto.imagenesData.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              // child: Image.network(producto.imagenesData[0]['url'], fit: BoxFit.cover),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.image, size: 80, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  'Imagen no disponible',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
    );
  }

  Widget _construirInformacionBasica(Producto producto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          producto.nombre,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _construirChipInfo(producto.marcaNombre, Icons.branding_watermark),
            const SizedBox(width: 8),
            _construirChipInfo(producto.subcategoriaNombre, Icons.category),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Modelo: ${producto.modelo}',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _construirChipInfo(String texto, IconData icono) {
    return Chip(
      label: Text(texto),
      avatar: Icon(icono, size: 16),
      backgroundColor: Colors.blue[50],
    );
  }

  Widget _construirInformacionPrecios(Producto producto) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Precio contado:', style: TextStyle(fontSize: 16)),
                Text(
                  'S/. ${producto.precioContado.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Precio en cuotas:', style: TextStyle(fontSize: 16)),
                Text(
                  'S/. ${producto.precioCuota.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _construirInfoStock(producto.stock),
          ],
        ),
      ),
    );
  }

  Widget _construirInfoStock(int stock) {
    return Row(
      children: [
        Icon(
          stock > 0 ? Icons.check_circle : Icons.cancel,
          color: stock > 0 ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          stock > 0 ? 'En stock ($stock unidades)' : 'Sin stock',
          style: TextStyle(
            color: stock > 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _construirEspecificaciones(Producto producto) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Especificaciones Técnicas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _construirItemEspecificacion(
              'Garantía',
              '${producto.garantiaMeses} meses',
            ),
            _construirItemEspecificacion('Categoría', producto.categoriaNombre),
            _construirItemEspecificacion(
              'Subcategoría',
              producto.subcategoriaNombre,
            ),
            _construirItemEspecificacion('Marca', producto.marcaNombre),
            _construirItemEspecificacion('Modelo', producto.modelo),
            _construirItemEspecificacion(
              'Estado',
              producto.isActive ? 'Activo' : 'Inactivo',
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirItemEspecificacion(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(valor, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _construirDescripcion(Producto producto) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Descripción del Producto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              producto.descripcion,
              style: const TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  // En tu DetalleProductoView, agrega esto después de la descripción:
  Widget _construirSeccionHistorialPrecios(Producto producto) {
    return FutureBuilder<HistorialPrecioResponse>(
      future: HistorialPrecioService().obtenerHistorialPrecios(
        productoId: producto.id,
        meses: 12,
        tipo: 'ambos',
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'No se pudo cargar el historial de precios',
              style: TextStyle(color: Colors.grey),
            ),
          );
        } else if (snapshot.hasData) {
          // ✅ CORRECCIÓN: Acceder a snapshot.data!.values (no snapshot.data!.values)
          final response = snapshot.data!;
          if (response.values.datosGrafica.labels.isNotEmpty) {
            return GraficaHistorialPrecios(historialData: response.values);
          } else {
            return const SizedBox(); // No mostrar si no hay datos
          }
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _construirBarraInferior() {
    return FutureBuilder<DetalleProductoResponse>(
      future: _futuroDetalleProducto,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final producto = snapshot.data!.valores.producto;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Botón de favoritos
              IconButton(
                onPressed: () {
                  // Agregar a favoritos
                },
                icon: const Icon(Icons.favorite_border, size: 28),
                color: Colors.grey,
              ),
              const SizedBox(width: 8),

              // Botón principal de compra
              Expanded(
                child: _agregandoAlCarrito
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
                            Text('Agregando...'),
                          ],
                        ),
                      )
                    : ElevatedButton(
                        onPressed: producto.stock > 0
                            ? () => _mostrarDialogoCantidad(producto)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: producto.stock > 0
                              ? Colors.blue
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          producto.stock > 0
                              ? 'Agregar al Carrito'
                              : 'Sin Stock',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
