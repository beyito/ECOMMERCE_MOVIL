class LoginResponse {
  final int? id;
  final int? status;
  final String? message;
  final String? token;
  final String? usuario;
  final dynamic error; // Puede ser String, Map, List, etc.

  LoginResponse({
    this.id,
    this.status,
    this.message,
    this.token,
    this.usuario,
    this.error,
  });

  factory LoginResponse.success({
    required int id,
    required String token,
    required String usuario,
    String? message,
  }) {
    return LoginResponse(
      status: 1,
      message: message ?? "Se guardó los datos del usuario",
      token: token,
      id: id,
      usuario: usuario,
      error: null,
    );
  }

  factory LoginResponse.failure(dynamic error) {
    return LoginResponse(
      status: 0,
      message: null,
      token: null,
      usuario: null,
      error: error,
    );
  }
}
