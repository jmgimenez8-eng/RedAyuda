import 'package:dartz/dartz.dart';
import '../entities/valoracion.dart';

abstract class ValoracionesRepository {
  Future<Either<String, Valoracion>> crearValoracion({
    required String favorId,
    required String valoradoId,
    required int puntuacion,
    String? comentario,
  });

  Future<Either<String, List<Valoracion>>> obtenerValoracionesPorUsuario({
    required String usuarioId,
  });

  Future<Either<String, bool>> yaValorado({
    required String favorId,
    required String valoradorId,
  });

  Future<Either<String, double>> obtenerReputacion({
    required String usuarioId,
  });
}