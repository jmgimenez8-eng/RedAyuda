import 'package:equatable/equatable.dart';

class Usuario extends Equatable {
  final String id;
  final String nombre;
  final String email;
  final String? telefono;
  final String rol;
  final double reputacion;
  final int strikes;
  final String estado;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.telefono,
    required this.rol,
    required this.reputacion,
    required this.strikes,
    required this.estado,
  });

  @override
  List<Object?> get props => [
    id,
    nombre,
    email,
    telefono,
    rol,
    reputacion,
    strikes,
    estado,
  ];
}