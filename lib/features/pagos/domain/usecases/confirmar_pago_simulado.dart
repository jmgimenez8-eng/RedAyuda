import 'package:dartz/dartz.dart';
import '../entities/pago.dart';
import '../repositories/pagos_repository.dart';

class ConfirmarPagoSimulado {
  final PagosRepository repository;

  ConfirmarPagoSimulado(this.repository);

  Future<Either<String, Pago>> call({required String pagoId}) {
    return repository.confirmarPagoSimulado(pagoId: pagoId);
  }
}
