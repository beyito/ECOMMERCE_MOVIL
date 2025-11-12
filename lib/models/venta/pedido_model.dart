// models/venta/pedido_model.dart
import 'dart:ui';

import 'package:flutter/material.dart';

class PedidosResponse {
  final int status;
  final int error;
  final String message;
  final List<Pedido> values;

  PedidosResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.values,
  });

  factory PedidosResponse.fromJson(Map<String, dynamic> json) {
    return PedidosResponse(
      status: json['status'],
      error: json['error'],
      message: json['message'],
      values: (json['values'] as List)
          .map((item) => Pedido.fromJson(item))
          .toList(),
    );
  }
}

class PedidoDetalleResponse {
  final int status;
  final int error;
  final String message;
  final PedidoDetalle values;

  PedidoDetalleResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.values,
  });

  factory PedidoDetalleResponse.fromJson(Map<String, dynamic> json) {
    return PedidoDetalleResponse(
      status: json['status'],
      error: json['error'],
      message: json['message'],
      values: PedidoDetalle.fromJson(json['values']),
    );
  }
}

class Pedido {
  final int pedidoId;
  final String fecha;
  final double total;
  final String estado;
  final String formaPago;
  final List<DetallePedido> detalles;

  Pedido({
    required this.pedidoId,
    required this.fecha,
    required this.total,
    required this.estado,
    required this.formaPago,
    required this.detalles,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      pedidoId: json['pedido_id'],
      fecha: json['fecha'],
      total: double.parse(json['total'].toString()),
      estado: json['estado'],
      formaPago: json['forma_pago'],
      detalles: (json['detalles'] as List)
          .map((item) => DetallePedido.fromJson(item))
          .toList(),
    );
  }

  // Método para obtener el color según el estado
  Color get estadoColor {
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

  // Método para obtener el icono según el estado
  IconData get estadoIcon {
    switch (estado.toLowerCase()) {
      case 'pagado':
        return Icons.check_circle;
      case 'no pagado':
        return Icons.cancel;
      case 'pendiente':
        return Icons.pending;
      case 'en proceso':
        return Icons.hourglass_empty;
      default:
        return Icons.help_outline;
    }
  }
}

class PedidoDetalle {
  final int pedidoId;
  final int usuarioId;
  final String usuarioNombre;
  final String fecha;
  final double total;
  final String estado;
  final String formaPago;
  final List<DetallePedido> detalles;

  PedidoDetalle({
    required this.pedidoId,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.fecha,
    required this.total,
    required this.estado,
    required this.formaPago,
    required this.detalles,
  });

  factory PedidoDetalle.fromJson(Map<String, dynamic> json) {
    return PedidoDetalle(
      pedidoId: json['pedido_id'],
      usuarioId: json['usuario_id'],
      usuarioNombre: json['usuario_nombre'],
      fecha: json['fecha'],
      total: double.parse(json['total'].toString()),
      estado: json['estado'],
      formaPago: json['forma_pago'],
      detalles: (json['detalles'] as List)
          .map((item) => DetallePedido.fromJson(item))
          .toList(),
    );
  }
}

class DetallePedido {
  final int productoId;
  final String nombre;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  DetallePedido({
    required this.productoId,
    required this.nombre,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory DetallePedido.fromJson(Map<String, dynamic> json) {
    return DetallePedido(
      productoId: json['producto_id'],
      nombre: json['nombre'],
      cantidad: json['cantidad'],
      precioUnitario: double.parse(json['precio_unitario'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }
}
