// widgets/dialog_cantidad.dart
import 'package:flutter/material.dart';

class DialogCantidad extends StatefulWidget {
  final int stockDisponible;
  final String nombreProducto;
  final int cantidadInicial;

  const DialogCantidad({
    Key? key,
    required this.stockDisponible,
    required this.nombreProducto,
    this.cantidadInicial = 1,
  }) : super(key: key);

  @override
  State<DialogCantidad> createState() => _DialogCantidadState();
}

class _DialogCantidadState extends State<DialogCantidad> {
  late int _cantidad;

  @override
  void initState() {
    super.initState();
    _cantidad = widget.cantidadInicial;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar Cantidad'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.nombreProducto,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Stock disponible: ${widget.stockDisponible}',
            style: TextStyle(
              color: widget.stockDisponible > 0 ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _cantidad > 1 ? _decrementarCantidad : null,
                icon: const Icon(Icons.remove),
                style: IconButton.styleFrom(backgroundColor: Colors.grey[200]),
              ),
              const SizedBox(width: 16),
              Text(
                '$_cantidad',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _cantidad < widget.stockDisponible
                    ? _incrementarCantidad
                    : null,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(backgroundColor: Colors.grey[200]),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_cantidad),
          child: const Text('Agregar al Carrito'),
        ),
      ],
    );
  }

  void _incrementarCantidad() {
    setState(() {
      if (_cantidad < widget.stockDisponible) {
        _cantidad++;
      }
    });
  }

  void _decrementarCantidad() {
    setState(() {
      if (_cantidad > 1) {
        _cantidad--;
      }
    });
  }
}
