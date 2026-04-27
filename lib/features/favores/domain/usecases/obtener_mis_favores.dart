import 'package:dartz/dartz.dart';
import '../entities/favor.dart';
import '../../../auth/domain/repositories/favores_repository.dart';

class ObtenerMisFavores {
  final FavoresRepository repository;

  ObtenerMisFavores(this.repository);

  Future<Either<String, List<Favor>>> call() {
    return repository.obtenerMisFavores();
  }
}