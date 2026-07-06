import 'package:dartz/dartz.dart';
import '../../domain/entities/favor.dart';
import '../../../auth/domain/repositories/favores_repository.dart';
import '../datasources/favores_supabase_datasource.dart';

class FavoresRepositoryImpl implements FavoresRepository {
  final FavoresSupabaseDatasource datasource;

  FavoresRepositoryImpl(this.datasource);

  @override
  Future<Either<String, Favor>> publicarFavor({
    required String titulo,
    required String descripcion,
    required String categoria,
    required double latitud,
    required double longitud,
    required double radioKm,
    required String ventanaSubasta,
  }) async {
    try {
      final favor = await datasource.publicarFavor(
        titulo: titulo,
        descripcion: descripcion,
        categoria: categoria,
        latitud: latitud,
        longitud: longitud,
        radioKm: radioKm,
        ventanaSubasta: ventanaSubasta,
      );
      return Right(favor);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Favor>>> obtenerFavoresCercanos({
    required double latitud,
    required double longitud,
    required double radioKm,
  }) async {
    try {
      final favores = await datasource.obtenerFavoresCercanos(
        latitud: latitud,
        longitud: longitud,
        radioKm: radioKm,
      );
      return Right(favores);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Favor>> obtenerFavorPorId({
    required String id,
  }) async {
    try {
      final favor = await datasource.obtenerFavorPorId(id: id);
      return Right(favor);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Favor>>> obtenerMisFavores() async {
    try {
      final favores = await datasource.obtenerMisFavores();
      return Right(favores);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> cancelarFavor({required String id}) async {
    try {
      await datasource.cancelarFavor(id: id);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Favor>> marcarFavorEntregado({required String id}) async {
    try {
      final favor = await datasource.marcarFavorEntregado(favorId: id);
      return Right(favor);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Stream<List<Favor>> escucharFavoresCercanos({
    required double latitud,
    required double longitud,
    required double radioKm,
  }) {
    return datasource.escucharFavoresCercanos(
      latitud: latitud,
      longitud: longitud,
      radioKm: radioKm,
    );
  }
}