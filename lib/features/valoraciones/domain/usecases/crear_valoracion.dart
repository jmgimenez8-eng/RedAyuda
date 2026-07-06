import 'package:dartz/dartz.dart';
import '../entities/valoracion.dart';
import '../repositories/valoraciones_repository.dart';

class CrearValoracion {
  final ValoracionesRepository repository;

  CrearValoracion(this.repository);

  Future<Either<String, Valoracion>> call({
    required String favorId,
    required String valoradoId,
    required int puntuacion,
    String? comentario,
  }) {
    return repository.crearValoracion(
      favorId: favorId,
      valoradoId: valoradoId,
      puntuacion: puntuacion,
      comentario: comentario,
    );
  }
}