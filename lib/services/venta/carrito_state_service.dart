// services/venta/carrito_state_service.dart
import 'package:flutter/material.dart';
import 'carrito_service.dart';
import '../../models/venta/carrito_model.dart';

class CarritoStateService with ChangeNotifier {
  final CarritoService _carritoService = CarritoService();
  CarritoResponse? _carritoActual;
  int _contadorCarrito = 0;

  CarritoResponse? get carritoActual => _carritoActual;
  int get contadorCarrito => _contadorCarrito;

  // Cargar carrito y notificar a los listeners
  Future<void> cargarCarrito() async {
    try {
      _carritoActual = await _carritoService.obtenerCarrito();
      _actualizarContador();
      notifyListeners();
    } catch (e) {
      print('Error cargando carrito: $e');
    }
  }

  // Agregar producto y actualizar estado
  Future<bool> agregarProducto({
    required int productoId,
    required int cantidad,
  }) async {
    try {
      final respuesta = await _carritoService.agregarProductoCarrito(
        productoId: productoId,
        cantidad: cantidad,
      );

      if (respuesta.status == 1) {
        await cargarCarrito(); // Recargar el carrito completo
        return true;
      }
      return false;
    } catch (e) {
      print('Error agregando producto: $e');
      return false;
    }
  }

  // Actualizar cantidad y actualizar estado
  Future<bool> actualizarCantidad({
    required int productoId,
    required int nuevaCantidad,
  }) async {
    try {
      final respuesta = await _carritoService.actualizarCantidadProducto(
        productoId: productoId,
        nuevaCantidad: nuevaCantidad,
      );

      if (respuesta.status == 1) {
        await cargarCarrito();
        return true;
      }
      return false;
    } catch (e) {
      print('Error actualizando cantidad: $e');
      return false;
    }
  }

  // Eliminar producto y actualizar estado
  Future<bool> eliminarProducto(int productoId) async {
    try {
      final respuesta = await _carritoService.eliminarProductoCarrito(
        productoId,
      );

      if (respuesta.status == 1) {
        await cargarCarrito();
        return true;
      }
      return false;
    } catch (e) {
      print('Error eliminando producto: $e');
      return false;
    }
  }

  // Vaciar carrito y actualizar estado
  Future<bool> vaciarCarrito() async {
    try {
      final respuesta = await _carritoService.vaciarCarrito();

      if (respuesta.status == 1) {
        await cargarCarrito();
        return true;
      }
      return false;
    } catch (e) {
      print('Error vaciando carrito: $e');
      return false;
    }
  }

  // Actualizar contador de items en el carrito
  void _actualizarContador() {
    if (_carritoActual != null && _carritoActual!.values.productos.isNotEmpty) {
      _contadorCarrito = _carritoActual!.values.productos.fold(
        0,
        (total, item) => total + item.cantidad,
      );
    } else {
      _contadorCarrito = 0;
    }
  }

  // Forzar actualización
  void notificarCambios() {
    notifyListeners();
  }
}
