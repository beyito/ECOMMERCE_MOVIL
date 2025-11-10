// models/venta/forma_pago_model.dart
class FormaPagoResponse {
  final int status;
  final int error;
  final String message;
  final FormaPagoData values;

  FormaPagoResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.values,
  });

  factory FormaPagoResponse.fromJson(Map<String, dynamic> json) {
    return FormaPagoResponse(
      status: json['status'],
      error: json['error'],
      message: json['message'],
      values: FormaPagoData.fromJson(json['values']),
    );
  }
}

class FormaPagoData {
  final List<FormaPago> formasPago;

  FormaPagoData({required this.formasPago});

  factory FormaPagoData.fromJson(Map<String, dynamic> json) {
    return FormaPagoData(
      formasPago: (json['Formas Pago'] as List)
          .map((item) => FormaPago.fromJson(item))
          .toList(),
    );
  }
}

class FormaPago {
  final int id;
  final String nombre;
  final String descripcion;
  final bool? isActive; // Opcional por si no viene en la respuesta

  FormaPago({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.isActive,
  });

  factory FormaPago.fromJson(Map<String, dynamic> json) {
    return FormaPago(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      isActive: json['is_active'],
    );
  }
}

// Los modelos PedidoRequest y PedidoResponse se mantienen igual
class PedidoRequest {
  final int formaPago;
  final int? mesesCredito;

  PedidoRequest({required this.formaPago, this.mesesCredito});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'forma_pago': formaPago};
    if (mesesCredito != null) {
      data['meses_credito'] = mesesCredito;
    }
    return data;
  }
}

class PedidoResponse {
  final int status;
  final int error;
  final String message;
  final dynamic values;

  PedidoResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.values,
  });

  factory PedidoResponse.fromJson(Map<String, dynamic> json) {
    return PedidoResponse(
      status: json['status'],
      error: json['error'],
      message: json['message'],
      values: json['values'],
    );
  }
}
