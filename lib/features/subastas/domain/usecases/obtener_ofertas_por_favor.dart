import 'package:dartz/dartz.dart';
import '../entities/oferta.dart';
import '../repositories/subastas_repository.dart';

class ObtenerOfertasPorFavor {
  final SubastasRepository repository;

  ObtenerOfertasPorFavor(this.repository);

  Future<Either<String, List<Oferta>>> call({
    required String favorId,
  }) {
    return repository.obtenerOfertasPorFavor(favorId: favorId);
  }
}