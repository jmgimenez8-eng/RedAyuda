import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/pagos_supabase_datasource.dart';
import '../../data/repositories/pagos_repository_impl.dart';
import '../../domain/entities/pago.dart';
import '../../domain/usecases/confirmar_pago.dart';
import '../../domain/usecases/crear_pago.dart';
import '../../domain/usecases/generar_codigo_verificacion.dart';
import '../../domain/usecases/liberar_pago.dart';

final pagosDatasourceProvider = Provider<PagosSupabaseDatasource>(
      (ref) => PagosSupabaseDatasource(),
);

final pagosRepositoryProvider = Provider<PagosRepositoryImpl>(
      (ref) => PagosRepositoryImpl(ref.watch(pagosDatasourceProvider)),
);

final crearPagoProvider = Provider<CrearPago>(
      (ref) => CrearPago(ref.watch(pagosRepositoryProvider)),
);

final confirmarPagoProvider = Provider<ConfirmarPago>(
      (ref) => ConfirmarPago(ref.watch(pagosRepositoryProvider)),
);

final liberarPagoProvider = Provider<LiberarPago>(
      (ref) => LiberarPago(ref.watch(pagosRepositoryProvider)),
);

final generarCodigoVerificacionProvider = Provider<GenerarCodigoVerificacion>(
      (ref) => GenerarCodigoVerificacion(ref.watch(pagosRepositoryProvider)),
);

final pagoPorFavorStreamProvider = StreamProvider.family<Pago?, String>(
      (ref, favorId) => ref
      .watch(pagosRepositoryProvider)
      .escucharPagoPorFavor(favorId: favorId),
);

class PagosNotifier extends StateNotifier<AsyncValue<Pago?>> {
  final CrearPago _crearPago;
  final ConfirmarPago _confirmarPago;
  final LiberarPago _liberarPago;
  final GenerarCodigoVerificacion _generarCodigoVerificacion;

  PagosNotifier({
    required CrearPago crearPago,
    required ConfirmarPago confirmarPago,
    required LiberarPago liberarPago,
    required GenerarCodigoVerificacion generarCodigoVerificacion,
  })  : _crearPago = crearPago,
        _confirmarPago = confirmarPago,
        _liberarPago = liberarPago,
        _generarCodigoVerificacion = generarCodigoVerificacion,
        super(const AsyncValue.data(null));

  Future<Pago?> crearPago({
    required String favorId,
    required String ofertaId,
    required String ayudanteId,
    required double importe,
  }) async {
    state = const AsyncValue.loading();
    final result = await _crearPago(
      favorId: favorId,
      ofertaId: ofertaId,
      ayudanteId: ayudanteId,
      importe: importe,
    );
    return result.fold(
          (error) {
        state = AsyncValue.error(error, StackTrace.current);
        return null;
      },
          (pago) {
        state = AsyncValue.data(pago);
        return pago;
      },
    );
  }

  Future<bool> confirmarPago({
    required String pagoId,
    required String paypalOrderId,
    required String paypalCaptureId,
  }) async {
    final result = await _confirmarPago(
      pagoId: pagoId,
      paypalOrderId: paypalOrderId,
      paypalCaptureId: paypalCaptureId,
    );
    return result.fold(
          (error) {
        state = AsyncValue.error(error, StackTrace.current);
        return false;
      },
          (pago) {
        state = AsyncValue.data(pago);
        return true;
      },
    );
  }

  Future<bool> liberarPago({
    required String pagoId,
    required String codigoVerificacion,
  }) async {
    final result = await _liberarPago(
      pagoId: pagoId,
      codigoVerificacion: codigoVerificacion,
    );
    return result.fold(
          (error) {
        state = AsyncValue.error(error, StackTrace.current);
        return false;
      },
          (pago) {
        state = AsyncValue.data(pago);
        return true;
      },
    );
  }

  Future<String?> generarCodigoVerificacion({required String pagoId}) async {
    final result = await _generarCodigoVerificacion(pagoId: pagoId);
    return result.fold(
          (error) => null,
          (codigo) => codigo,
    );
  }
}

final pagosNotifierProvider =
StateNotifierProvider<PagosNotifier, AsyncValue<Pago?>>(
      (ref) => PagosNotifier(
    crearPago: ref.watch(crearPagoProvider),
    confirmarPago: ref.watch(confirmarPagoProvider),
    liberarPago: ref.watch(liberarPagoProvider),
    generarCodigoVerificacion: ref.watch(generarCodigoVerificacionProvider),
  ),
);