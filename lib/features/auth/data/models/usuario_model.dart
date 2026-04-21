import '../../domain/entities/usuario.dart';

class UsuarioModel extends Usuario {
  const UsuarioModel({
    required super.id,
    required super.nombre,
    required super.email,
    super.telefono,
    required super.rol,
    required super.reputacion,
    required super.strikes,
    required super.estado,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      telefono: json['telefono'] as String?,
      rol: json['rol'] as String? ?? 'solicitante',
      reputacion: (json['reputacion'] as num?)?.toDouble() ?? 5.0,
      strikes: json['strikes'] as int? ?? 0,
      estado: json['estado'] as String? ?? 'activo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'rol': rol,
      'reputacion': reputacion,
      'strikes': strikes,
      'estado': estado,
    };
  }

  factory UsuarioModel.fromUsuario(Usuario usuario) {
    return UsuarioModel(
      id: usuario.id,
      nombre: usuario.nombre,
      email: usuario.email,
      telefono: usuario.telefono,
      rol: usuario.rol,
      reputacion: usuario.reputacion,
      strikes: usuario.strikes,
      estado: usuario.estado,
    );
  }
}