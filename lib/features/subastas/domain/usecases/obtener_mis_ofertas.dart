import 'package:dartz/dartz.dart';
import '../entities/oferta.dart';
import '../repositories/subastas_repository.dart';

class ObtenerMisOfertas {
  final SubastasRepository repository;

  ObtenerMisOfertas(this.repository);

  Future<Either<String, List<Oferta>>> call() {
    return repository.obtenerMisOfertas();
  }
}