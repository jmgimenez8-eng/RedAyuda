import 'package:dartz/dartz.dart';
import '../entities/pago.dart';
import '../repositories/pagos_repository.dart';

class ConfirmarPago {
  final PagosRepository repository;

  ConfirmarPago(this.repository);

  Future<Either<String, Pago>> call({
    required String pagoId,
    required String paypalOrderId,
    required String paypalCaptureId,
  }) {
    return repository.confirmarPago(
      pagoId: pagoId,
      paypalOrderId: paypalOrderId,
      paypalCaptureId: paypalCaptureId,
    );
  }
}