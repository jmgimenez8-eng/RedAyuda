import 'package:dartz/dartz.dart';
import '../../domain/entities/valoracion.dart';
import '../../domain/repositories/valoraciones_repository.dart';
import '../datasources/valoraciones_supabase_datasource.dart';

class ValoracionesRepositoryImpl implements ValoracionesRepository {
  final ValoracionesSupabaseDatasource datasource;

  ValoracionesRepositoryImpl(this.datasource);

  @override
  Future<Either<String, Valoracion>> crearValoracion({
    required String favorId,
    required String valoradoId,
    required int puntuacion,
    String? comentario,
  }) async {
    try {
      final valoracion = await datasource.crearValoracion(
        favorId: favorId,
        valoradoId: valoradoId,
        puntuacion: puntuacion,
        comentario: comentario,
      );
      return Right(valoracion);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Valoracion>>> obtenerValoracionesPorUsuario({
    required String usuarioId,
  }) async {
    try {
      final valoraciones = await datasource.obtenerValoracionesPorUsuario(
        usuarioId: usuarioId,
      );
      return Right(valoraciones);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> yaValorado({
    required String favorId,
    required String valoradorId,
  }) async {
    try {
      final result = await datasource.yaValorado(
        favorId: favorId,
        valoradorId: valoradorId,
      );
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, double>> obtenerReputacion({
    required String usuarioId,
  }) async {
    try {
      final reputacion = await datasource.obtenerReputacion(
        usuarioId: usuarioId,
      );
      return Right(reputacion);
    } catch (e) {
      return Left(e.toString());
    }
  }
}