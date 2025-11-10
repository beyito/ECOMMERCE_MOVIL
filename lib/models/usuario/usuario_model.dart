class UsuarioModel {
  final int? id;
  final String? username;
  final String? firstname;
  final String? lastname;
  final String? email;
  final String? ci;
  final String? telefono;
  final int? grupo;
  final String? nombreRol;

  UsuarioModel({
    this.id,
    this.username,
    this.firstname,
    this.lastname,
    this.email,
    this.grupo,
    this.nombreRol,
    this.ci,
    this.telefono,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? "",
      firstname: json['firstname'] ?? "",
      lastname: json['lastname'] ?? "",
      email: json['email'] ?? "",
      grupo: json['grupo'] ?? 0,
      nombreRol: json['nombreRol'] ?? "",
      ci: json['ci'] ?? "",
      telefono: json['telefono'] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'firstname': firstname,
    'lastname': lastname,
    'email': email,
    'grupo': grupo,
    'nombreRol': nombreRol,
    'ci': ci,
    'telefono': telefono,
  };
}
