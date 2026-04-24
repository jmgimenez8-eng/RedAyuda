import 'package:equatable/equatable.dart';

class Favor extends Equatable {
  final String id;
  final String solicitanteId;
  final String titulo;
  final String descripcion;
  final String categoria;
  final double latitud;
  final double longitud;
  final double radioKm;
  final String ventanaSubasta;
  final String estado;
  final DateTime? expiresAt;
  final DateTime createdAt;

  const Favor({
    required this.id,
    required this.solicitanteId,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.latitud,
    required this.longitud,
    required this.radioKm,
    required this.ventanaSubasta,
    required this.estado,
    this.expiresAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    solicitanteId,
    titulo,
    descripcion,
    categoria,
    latitud,
    longitud,
    radioKm,
    ventanaSubasta,
    estado,
    expiresAt,
    createdAt,
  ];
}