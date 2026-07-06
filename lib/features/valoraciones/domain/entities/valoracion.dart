import 'package:equatable/equatable.dart';

class Valoracion extends Equatable {
  final String id;
  final String favorId;
  final String valoradorId;
  final String valoradoId;
  final int puntuacion;
  final String? comentario;
  final DateTime createdAt;

  const Valoracion({
    required this.id,
    required this.favorId,
    required this.valoradorId,
    required this.valoradoId,
    required this.puntuacion,
    this.comentario,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    favorId,
    valoradorId,
    valoradoId,
    puntuacion,
    comentario,
    createdAt,
  ];
}