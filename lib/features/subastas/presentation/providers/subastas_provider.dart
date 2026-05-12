import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/subastas_supabase_datasource.dart';
import '../../data/repositories/subastas_repository_impl.dart';
import '../../domain/entities/oferta.dart';
import '../../domain/usecases/aceptar_oferta.dart';
import '../../domain/usecases/enviar_oferta.dart';
import '../../domain/usecases/obtener_mis_ofertas.dart';
import '../../domain/usecases/obtener_ofertas_por_favor.dart';

final subastasDatasourceProvider = Provider<SubastasSupabaseDatasource>(
      (ref) => SubastasSupabaseDatasource(),
);

final subastasRepositoryProvider = Provider<SubastasRepositoryImpl>(
      (ref) => SubastasRepositoryImpl(ref.watch(subastasDatasourceProvider)),
);

final enviarOfertaProvider = Provider<EnviarOferta>(
      (ref) => EnviarOferta(ref.watch(subastasRepositoryProvider)),
);

final obtenerOfertasPorFavorProvider = Provider<ObtenerOfertasPorFavor>(
      (ref) => ObtenerOfertasPorFavor(ref.watch(subastasRepositoryProvider)),
);

final aceptarOfertaProvider = Provider<AceptarOferta>(
      (ref) => AceptarOferta(ref.watch(subastasRepositoryProvider)),
);

final obtenerMisOfertasProvider = Provider<ObtenerMisOfertas>(
      (ref) => ObtenerMisOfertas(ref.watch(subastasRepositoryProvider)),
);


final ofertasPorFavorStreamProvider =
StreamProvider.family<List<Oferta>, (String, String)>(
      (ref, params) => ref
      .watch(subastasRepositoryProvider)
      .escucharOfertasPorFavor(
    favorId: params.$1,
    solicitanteId: params.$2,
  ),
);

class SubastasNotifier extends StateNotifier<AsyncValue<List<Oferta>>> {
  final EnviarOferta _enviarOferta;
  final ObtenerOfertasPorFavor _obtenerOfertasPorFavor;
  final AceptarOferta _aceptarOferta;
  final ObtenerMisOfertas _obtenerMisOfertas;

  SubastasNotifier({
    required EnviarOferta enviarOferta,
    required ObtenerOfertasPorFavor obtenerOfertasPorFavor,
    required AceptarOferta aceptarOferta,
    required ObtenerMisOfertas obtenerMisOfertas,
  })  : _enviarOferta = enviarOferta,
        _obtenerOfertasPorFavor = obtenerOfertasPorFavor,
        _aceptarOferta = aceptarOferta,
        _obtenerMisOfertas = obtenerMisOfertas,
        super(const AsyncValue.data([]));

  Future<bool> enviarOferta({
    required String favorId,
    required double precio,
    String? mensaje,
  }) async {
    state = const AsyncValue.loading();
    final result = await _enviarOferta(
      favorId: favorId,
      precio: precio,
      mensaje: mensaje,
    );
    return result.fold(
          (error) {
        state = AsyncValue.error(error, StackTrace.current);
        return false;
      },
          (oferta) {
        state = AsyncValue.data([...state.value ?? [], oferta]);
        return true;
      },
    );
  }

  Future<void> cargarOfertasPorFavor({required String favorId}) async {
    state = const AsyncValue.loading();
    final result = await _obtenerOfertasPorFavor(favorId: favorId);
    result.fold(
          (error) => state = AsyncValue.error(error, StackTrace.current),
          (ofertas) => state = AsyncValue.data(ofertas),
    );
  }

  Future<bool> aceptarOferta({
    required String ofertaId,
    required String favorId,
  }) async {
    final result = await _aceptarOferta(
      ofertaId: ofertaId,
      favorId: favorId,
    );
    return result.fold(
          (error) {
        state = AsyncValue.error(error, StackTrace.current);
        return false;
      },
          (oferta) {
        final ofertasActuales = state.value ?? [];
        state = AsyncValue.data(
          ofertasActuales
              .map((o) => o.id == ofertaId ? oferta : o)
              .toList(),
        );
        return true;
      },
    );
  }

  Future<void> cargarMisOfertas() async {
    state = const AsyncValue.loading();
    final result = await _obtenerMisOfertas();
    result.fold(
          (error) => state = AsyncValue.error(error, StackTrace.current),
          (ofertas) => state = AsyncValue.data(ofertas),
    );
  }
}

final subastasNotifierProvider =
StateNotifierProvider<SubastasNotifier, AsyncValue<List<Oferta>>>(
      (ref) => SubastasNotifier(
    enviarOferta: ref.watch(enviarOfertaProvider),
    obtenerOfertasPorFavor: ref.watch(obtenerOfertasPorFavorProvider),
    aceptarOferta: ref.watch(aceptarOfertaProvider),
    obtenerMisOfertas: ref.watch(obtenerMisOfertasProvider),
  ),
);