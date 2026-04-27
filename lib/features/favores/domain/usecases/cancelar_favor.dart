import 'package:dartz/dartz.dart';
import '../../../auth/domain/repositories/favores_repository.dart';

class CancelarFavor {
  final FavoresRepository repository;

  CancelarFavor(this.repository);

  Future<Either<String, void>> call({required String id}) {
    return repository.cancelarFavor(id: id);
  }
}