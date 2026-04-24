import 'package:dartz/dartz.dart';
import '../../../favores/domain/entities/favor.dart';

abstract class FavoresRepository {
  Future<Either<String, Favor>> publicarFavor({
    required String titulo,
    required String descripcion,
    required String categoria,
    required double latitud,
    required double longitud,
    required double radioKm,
    required String ventanaSubasta,
  });

  Future<Either<String, List<Favor>>> obtenerFavoresCercanos({
    required double latitud,
    required double longitud,
    required double radioKm,
  });

  Future<Either<String, Favor>> obtenerFavorPorId({
    required String id,
  });

  Future<Either<String, List<Favor>>> obtenerMisFavores();

  Future<Either<String, void>> cancelarFavor({
    required String id,
  });

  Stream<List<Favor>> escucharFavoresCercanos({
    required double latitud,
    required double longitud,
    required double radioKm,
  });
}