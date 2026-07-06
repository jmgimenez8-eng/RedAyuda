import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/pagos_supabase_datasource.dart';
import '../../data/repositories/pagos_repository_impl.dart';
import '../../domain/entities/pago.dart';
import '../../domain/entities/paypal_orden.dart';
import '../../domain/usecases/capturar_orden_paypal.dart';
import '../../domain/usecases/confirmar_pago_simulado.dart';
import '../../domain/usecases/crear_orden_paypal.dart';
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

final crearOrdenPaypalProvider = Provider<CrearOrdenPaypal>(
      (ref) => CrearOrdenPaypal(ref.watch(pagosRepositoryProvider)),
);

final capturarOrdenPaypalProvider = Provider<CapturarOrdenPaypal>(
      (ref) => CapturarOrdenPaypal(ref.watch(pagosRepositoryProvider)),
);

final confirmarPagoSimuladoProvider = Provider<ConfirmarPagoSimulado>(
      (ref) => ConfirmarPagoSimulado(ref.watch(pagosRepositoryProvider)),
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
  final CrearOrdenPaypal _crearOrdenPaypal;
  final CapturarOrdenPaypal _capturarOrdenPaypal;
  final ConfirmarPagoSimulado _confirmarPagoSimulado;
  final LiberarPago _liberarPago;
  final GenerarCodigoVerificacion _generarCodigoVerificacion;

  PagosNotifier({
    required CrearPago crearPago,
    required CrearOrdenPaypal crearOrdenPaypal,
    required CapturarOrdenPaypal capturarOrdenPaypal,
    required ConfirmarPagoSimulado confirmarPagoSimulado,
    required LiberarPago liberarPago,
    required GenerarCodigoVerificacion generarCodigoVerificacion,
  })  : _crearPago = crearPago,
        _crearOrdenPaypal = crearOrdenPaypal,
        _capturarOrdenPaypal = capturarOrdenPaypal,
        _confirmarPagoSimulado = confirmarPagoSimulado,
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

  Future<PaypalOrden?> crearOrdenPaypal({required String pagoId}) async {
    final result = await _crearOrdenPaypal(pagoId: pagoId);
    return result.fold(
          (error) {
        state = AsyncValue.error(error, StackTrace.current);
        return null;
      },
          (orden) => orden,
    );
  }

  Future<bool> capturarOrdenPaypal({required String pagoId}) async {
    final result = await _capturarOrdenPaypal(pagoId: pagoId);
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

  Future<bool> confirmarPagoSimulado({required String pagoId}) async {
    final result = await _confirmarPagoSimulado(pagoId: pagoId);
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
    crearOrdenPaypal: ref.watch(crearOrdenPaypalProvider),
    capturarOrdenPaypal: ref.watch(capturarOrdenPaypalProvider),
    confirmarPagoSimulado: ref.watch(confirmarPagoSimuladoProvider),
    liberarPago: ref.watch(liberarPagoProvider),
    generarCodigoVerificacion: ref.watch(generarCodigoVerificacionProvider),
  ),
);