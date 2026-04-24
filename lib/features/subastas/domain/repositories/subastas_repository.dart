import 'package:dartz/dartz.dart';
import '../entities/oferta.dart';

abstract class SubastasRepository {
  Future<Either<String, Oferta>> enviarOferta({
    required String favorId,
    required double precio,
    required String? mensaje,
  });

  Future<Either<String, List<Oferta>>> obtenerOfertasPorFavor({
    required String favorId,
  });

  Future<Either<String, Oferta>> aceptarOferta({
    required String ofertaId,
    required String favorId,
  });

  Future<Either<String, void>> rechazarOferta({
    required String ofertaId,
  });

  Future<Either<String, List<Oferta>>> obtenerMisOfertas();

  Stream<List<Oferta>> escucharOfertasPorFavor({
    required String favorId,
  });
}