import 'package:dartz/dartz.dart';
import '../entities/pago.dart';
import '../repositories/pagos_repository.dart';

class LiberarPago {
  final PagosRepository repository;

  LiberarPago(this.repository);

  Future<Either<String, Pago>> call({
    required String pagoId,
    required String codigoVerificacion,
  }) {
    return repository.liberarPago(
      pagoId: pagoId,
      codigoVerificacion: codigoVerificacion,
    );
  }
}