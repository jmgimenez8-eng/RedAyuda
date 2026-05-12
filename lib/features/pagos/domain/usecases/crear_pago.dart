import 'package:dartz/dartz.dart';
import '../entities/pago.dart';
import '../repositories/pagos_repository.dart';

class CrearPago {
  final PagosRepository repository;

  CrearPago(this.repository);

  Future<Either<String, Pago>> call({
    required String favorId,
    required String ofertaId,
    required String ayudanteId,
    required double importe,
  }) {
    return repository.crearPago(
      favorId: favorId,
      ofertaId: ofertaId,
      ayudanteId: ayudanteId,
      importe: importe,
    );
  }
}