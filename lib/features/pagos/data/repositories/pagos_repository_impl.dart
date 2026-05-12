import 'package:dartz/dartz.dart';
import '../../domain/entities/pago.dart';
import '../../domain/repositories/pagos_repository.dart';
import '../datasources/pagos_supabase_datasource.dart';

class PagosRepositoryImpl implements PagosRepository {
  final PagosSupabaseDatasource datasource;

  PagosRepositoryImpl(this.datasource);

  @override
  Future<Either<String, Pago>> crearPago({
    required String favorId,
    required String ofertaId,
    required String ayudanteId,
    required double importe,
  }) async {
    try {
      final pago = await datasource.crearPago(
        favorId: favorId,
        ofertaId: ofertaId,
        ayudanteId: ayudanteId,
        importe: importe,
      );
      return Right(pago);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Pago>> confirmarPago({
    required String pagoId,
    required String paypalOrderId,
    required String paypalCaptureId,
  }) async {
    try {
      final pago = await datasource.confirmarPago(
        pagoId: pagoId,
        paypalOrderId: paypalOrderId,
        paypalCaptureId: paypalCaptureId,
      );
      return Right(pago);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Pago>> liberarPago({
    required String pagoId,
    required String codigoVerificacion,
  }) async {
    try {
      final pago = await datasource.liberarPago(
        pagoId: pagoId,
        codigoVerificacion: codigoVerificacion,
      );
      return Right(pago);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Pago>> obtenerPagoPorFavor({
    required String favorId,
  }) async {
    try {
      final pago = await datasource.obtenerPagoPorFavor(favorId: favorId);
      if (pago == null) return const Left('No existe pago para este favor');
      return Right(pago);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String>> generarCodigoVerificacion({
    required String pagoId,
  }) async {
    try {
      final codigo = await datasource.generarCodigoVerificacion(
        pagoId: pagoId,
      );
      return Right(codigo);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Stream<Pago?> escucharPagoPorFavor({required String favorId}) {
    return datasource.escucharPagoPorFavor(favorId: favorId);
  }
}