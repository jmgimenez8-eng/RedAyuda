import 'package:dartz/dartz.dart';
import '../repositories/pagos_repository.dart';

class GenerarCodigoVerificacion {
  final PagosRepository repository;

  GenerarCodigoVerificacion(this.repository);

  Future<Either<String, String>> call({required String pagoId}) {
    return repository.generarCodigoVerificacion(pagoId: pagoId);
  }
}