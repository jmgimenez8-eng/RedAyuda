import 'package:dartz/dartz.dart';
import '../entities/pago.dart';
import '../repositories/pagos_repository.dart';

class CapturarOrdenPaypal {
  final PagosRepository repository;

  CapturarOrdenPaypal(this.repository);

  Future<Either<String, Pago>> call({required String pagoId}) {
    return repository.capturarOrdenPaypal(pagoId: pagoId);
  }
}
