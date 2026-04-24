import 'package:dartz/dartz.dart';
import '../../../favores/domain/entities/favor.dart';
import '../repositories/favores_repository.dart';

class ObtenerMisFavores {
  final FavoresRepository repository;

  ObtenerMisFavores(this.repository);

  Future<Either<String, List<Favor>>> call() {
    return repository.obtenerMisFavores();
  }
}