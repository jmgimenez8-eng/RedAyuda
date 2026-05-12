import 'package:dartz/dartz.dart';
import '../entities/pago.dart';

abstract class PagosRepository {
  Future<Either<String, Pago>> crearPago({
    required String favorId,
    required String ofertaId,
    required String ayudanteId,
    required double importe,
  });

  Future<Either<String, Pago>> confirmarPago({
    required String pagoId,
    required String paypalOrderId,
    required String paypalCaptureId,
  });

  Future<Either<String, Pago>> liberarPago({
    required String pagoId,
    required String codigoVerificacion,
  });

  Future<Either<String, Pago>> obtenerPagoPorFavor({
    required String favorId,
  });

  Future<Either<String, String>> generarCodigoVerificacion({
    required String pagoId,
  });

  Stream<Pago?> escucharPagoPorFavor({
    required String favorId,
  });
}