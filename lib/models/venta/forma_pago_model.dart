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
      status: json['status'] ?? 0,
      error: json['error'] ?? 0,
      message: json['message'] ?? '',
      values: FormaPagoData.fromJson(json['values'] ?? {}),
    );
  }
}

class FormaPagoData {
  final List<FormaPago> formasPago;

  FormaPagoData({required this.formasPago});

  factory FormaPagoData.fromJson(Map<String, dynamic> json) {
    // MANEJO SEGURO: Verificar que existe y es una lista
    final formasPagoJson = json['Formas_Pago'];
    if (formasPagoJson is List) {
      return FormaPagoData(
        formasPago: formasPagoJson
            .map((item) => FormaPago.fromJson(item))
            .toList(),
      );
    } else {
      // Si no es una lista válida, retornar lista vacía
      return FormaPagoData(formasPago: []);
    }
  }
}

class FormaPago {
  final int id;
  final String nombre;
  final String descripcion;
  final bool? isActive;

  FormaPago({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.isActive,
  });

  factory FormaPago.fromJson(Map<String, dynamic> json) {
    return FormaPago(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      isActive: json['is_active'] ?? json['isActive'] ?? true,
    );
  }

  // Método útil para mostrar en UI
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'isActive': isActive,
    };
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
      status: json['status'] ?? 0,
      error: json['error'] ?? 0,
      message: json['message'] ?? '',
      values: json['values'],
    );
  }
}
