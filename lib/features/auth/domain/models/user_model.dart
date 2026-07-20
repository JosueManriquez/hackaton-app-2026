class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String rol;
  final String estado;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.rol,
    required this.estado,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      email: data['correo'] ?? '',
      displayName: data['nombre'] ?? '',
      rol: data['rol'] ?? 'ciudadano',
      estado: data['estado'] ?? 'activo',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'correo': email,
      'nombre': displayName,
      'rol': rol,
      'estado': estado,
    };
  }
}
