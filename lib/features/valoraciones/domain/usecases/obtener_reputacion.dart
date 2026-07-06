import 'package:dartz/dartz.dart';
import '../repositories/valoraciones_repository.dart';

class ObtenerReputacion {
  final ValoracionesRepository repository;

  ObtenerReputacion(this.repository);

  Future<Either<String, double>> call({required String usuarioId}) {
    return repository.obtenerReputacion(usuarioId: usuarioId);
  }
}