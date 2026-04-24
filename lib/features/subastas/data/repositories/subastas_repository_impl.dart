import 'package:dartz/dartz.dart';
import '../../domain/entities/oferta.dart';
import '../../domain/repositories/subastas_repository.dart';
import '../datasources/subastas_supabase_datasource.dart';

class SubastasRepositoryImpl implements SubastasRepository {
  final SubastasSupabaseDatasource datasource;

  SubastasRepositoryImpl(this.datasource);

  @override
  Future<Either<String, Oferta>> enviarOferta({
    required String favorId,
    required double precio,
    String? mensaje,
  }) async {
    try {
      final oferta = await datasource.enviarOferta(
        favorId: favorId,
        precio: precio,
        mensaje: mensaje,
      );
      return Right(oferta);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Oferta>>> obtenerOfertasPorFavor({
    required String favorId,
  }) async {
    try {
      final ofertas = await datasource.obtenerOfertasPorFavor(
        favorId: favorId,
      );
      return Right(ofertas);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Oferta>> aceptarOferta({
    required String ofertaId,
    required String favorId,
  }) async {
    try {
      final oferta = await datasource.aceptarOferta(
        ofertaId: ofertaId,
        favorId: favorId,
      );
      return Right(oferta);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> rechazarOferta({
    required String ofertaId,
  }) async {
    try {
      await datasource.rechazarOferta(ofertaId: ofertaId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Oferta>>> obtenerMisOfertas() async {
    try {
      final ofertas = await datasource.obtenerMisOfertas();
      return Right(ofertas);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Stream<List<Oferta>> escucharOfertasPorFavor({
    required String favorId,
  }) {
    return datasource.escucharOfertasPorFavor(favorId: favorId);
  }
}