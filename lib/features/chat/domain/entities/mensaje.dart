import 'package:equatable/equatable.dart';

class Mensaje extends Equatable {
  final String id;
  final String favorId;
  final String emisorId;
  final String contenido;
  final bool leido;
  final DateTime createdAt;

  const Mensaje({
    required this.id,
    required this.favorId,
    required this.emisorId,
    required this.contenido,
    required this.leido,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    favorId,
    emisorId,
    contenido,
    leido,
    createdAt,
  ];
}