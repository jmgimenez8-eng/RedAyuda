import 'package:equatable/equatable.dart';

class Oferta extends Equatable {
  final String id;
  final String favorId;
  final String ayudanteId;
  final double precio;
  final String? mensaje;
  final String estado;
  final DateTime createdAt;

  const Oferta({
    required this.id,
    required this.favorId,
    required this.ayudanteId,
    required this.precio,
    this.mensaje,
    required this.estado,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    favorId,
    ayudanteId,
    precio,
    mensaje,
    estado,
    createdAt,
  ];
}