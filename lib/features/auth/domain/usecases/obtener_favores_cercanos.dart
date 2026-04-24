import 'package:dartz/dartz.dart';
import '../../../favores/domain/entities/favor.dart';
import '../repositories/favores_repository.dart';

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