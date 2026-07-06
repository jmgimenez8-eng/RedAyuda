import 'package:dartz/dartz.dart';
import '../entities/paypal_orden.dart';
import '../repositories/pagos_repository.dart';

class CrearOrdenPaypal {
  final PagosRepository repository;

  CrearOrdenPaypal(this.repository);

  Future<Either<String, PaypalOrden>> call({required String pagoId}) {
    return repository.crearOrdenPaypal(pagoId: pagoId);
  }
}
