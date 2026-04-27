import 'package:dartz/dartz.dart';
import '../entities/favor.dart';
import '../../../auth/domain/repositories/favores_repository.dart';

class ObtenerFavoresCercanos {
  final FavoresRepository repository;

  ObtenerFavoresCercanos(this.repository);

  Future<Either<String, List<Favor>>> call({
    required double latitud,
    required double longitud,
    required double radioKm,
  }) {
    return repository.obtenerFavoresCercanos(
      latitud: latitud,
      longitud: longitud,
      radioKm: radioKm,
    );
  }
}