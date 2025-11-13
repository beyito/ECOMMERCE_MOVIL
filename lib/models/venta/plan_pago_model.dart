// models/venta/plan_pagos_model.dart

class PlanPagosResponse {
  final int status;
  final int error;
  final String message;
  final PlanPagosValues values;

  PlanPagosResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.values,
  });

  factory PlanPagosResponse.fromJson(Map<String, dynamic> json) {
    return PlanPagosResponse(
      status: json['status'],
      error: json['error'],
      message: json['message'],
      values: PlanPagosValues.fromJson(json['values']),
    );
  }
}

class PlanPagosValues {
  final List<CuotaPago> planPagos;

  PlanPagosValues({required this.planPagos});

  factory PlanPagosValues.fromJson(Map<String, dynamic> json) {
    return PlanPagosValues(
      planPagos: (json['plan_pagos'] as List)
          .map((cuota) => CuotaPago.fromJson(cuota))
          .toList(),
    );
  }
}

class CuotaPago {
  final int numeroCuota;
  final double monto;
  final String fechaVencimiento;
  final String estado;

  CuotaPago({
    required this.numeroCuota,
    required this.monto,
    required this.fechaVencimiento,
    required this.estado,
  });

  factory CuotaPago.fromJson(Map<String, dynamic> json) {
    return CuotaPago(
      numeroCuota: json['numero_cuota'],
      monto: double.parse(json['monto'].toString()),
      fechaVencimiento: json['fecha_vencimiento'],
      estado: json['estado'],
    );
  }
}
