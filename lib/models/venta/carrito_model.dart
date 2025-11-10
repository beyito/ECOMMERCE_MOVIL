// models/venta/carrito_model.dart

// Modelo para respuesta básica (agregar, actualizar, eliminar)
class CarritoBasicResponse {
  final int status;
  final int error;
  final String message;
  final dynamic values;

  CarritoBasicResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.values,
  });

  factory CarritoBasicResponse.fromJson(Map<String, dynamic> json) {
    return CarritoBasicResponse(
      status: json['status'],
      error: json['error'],
      message: json['message'],
      values: json['values'],
    );
  }
}

// Modelo para obtener el carrito completo
class CarritoResponse {
  final int status;
  final int error;
  final String message;
  final CarritoData values;

  CarritoResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.values,
  });

  factory CarritoResponse.fromJson(Map<String, dynamic> json) {
    return CarritoResponse(
      status: json['status'],
      error: json['error'],
      message: json['message'],
      values: CarritoData.fromJson(json['values']),
    );
  }
}

class CarritoData {
  final int carritoId;
  final double total;
  final List<ItemCarrito> productos;

  CarritoData({
    required this.carritoId,
    required this.total,
    required this.productos,
  });

  factory CarritoData.fromJson(Map<String, dynamic> json) {
    return CarritoData(
      carritoId: json['carrito_id'],
      total: double.parse(json['total'].toString()),
      productos: (json['productos'] as List)
          .map((item) => ItemCarrito.fromJson(item))
          .toList(),
    );
  }
}

class ItemCarrito {
  final int productoId;
  final String nombre;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final int stock;

  ItemCarrito({
    required this.productoId,
    required this.nombre,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    required this.stock,
  });

  factory ItemCarrito.fromJson(Map<String, dynamic> json) {
    return ItemCarrito(
      productoId: json['producto_id'],
      nombre: json['nombre'],
      cantidad: json['cantidad'],
      precioUnitario: double.parse(json['precio_unitario'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
      stock: json['stock'],
    );
  }
}
