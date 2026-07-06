import 'package:dartz/dartz.dart';
import '../entities/favor.dart';
import '../../../auth/domain/repositories/favores_repository.dart';

class MarcarFavorEntregado {
  final FavoresRepository repository;

  MarcarFavorEntregado(this.repository);

  Future<Either<String, Favor>> call({required String id}) {
    return repository.marcarFavorEntregado(id: id);
  }
}
