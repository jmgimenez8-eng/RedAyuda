import 'package:dartz/dartz.dart';
import '../entities/valoracion.dart';
import '../repositories/valoraciones_repository.dart';

class ObtenerValoracionesPorUsuario {
  final ValoracionesRepository repository;

  ObtenerValoracionesPorUsuario(this.repository);

  Future<Either<String, List<Valoracion>>> call({
    required String usuarioId,
  }) {
    return repository.obtenerValoracionesPorUsuario(
      usuarioId: usuarioId,
    );
  }
}