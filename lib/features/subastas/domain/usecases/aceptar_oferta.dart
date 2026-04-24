import 'package:dartz/dartz.dart';
import '../entities/oferta.dart';
import '../repositories/subastas_repository.dart';

class AceptarOferta {
  final SubastasRepository repository;

  AceptarOferta(this.repository);

  Future<Either<String, Oferta>> call({
    required String ofertaId,
    required String favorId,
  }) {
    return repository.aceptarOferta(
      ofertaId: ofertaId,
      favorId: favorId,
    );
  }
}