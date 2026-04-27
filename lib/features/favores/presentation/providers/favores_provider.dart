import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/favores_supabase_datasource.dart';
import '../../data/repositories/favores_repository_impl.dart';
import '../../domain/entities/favor.dart';
import '../../domain/usecases/cancelar_favor.dart';
import '../../domain/usecases/obtener_favores_cercanos.dart';
import '../../domain/usecases/obtener_mis_favores.dart';
import '../../domain/usecases/publicar_favor.dart';

final favoresDatasourceProvider = Provider<FavoresSupabaseDatasource>(
      (ref) => FavoresSupabaseDatasource(),
);

final favoresRepositoryProvider = Provider<FavoresRepositoryImpl>(
      (ref) => FavoresRepositoryImpl(ref.watch(favoresDatasourceProvider)),
);

final publicarFavorProvider = Provider<PublicarFavor>(
      (ref) => PublicarFavor(ref.watch(favoresRepositoryProvider)),
);

final obtenerFavoresCercanosProvider = Provider<ObtenerFavoresCercanos>(
      (ref) => ObtenerFavoresCercanos(ref.watch(favoresRepositoryProvider)),
);

final obtenerMisFavoresProvider = Provider<ObtenerMisFavores>(
      (ref) => ObtenerMisFavores(ref.watch(favoresRepositoryProvider)),
);

final cancelarFavorProvider = Provider<CancelarFavor>(
      (ref) => CancelarFavor(ref.watch(favoresRepositoryProvider)),
);

final favoresCercanosStreamProvider = StreamProvider.family<List<Favor>, Map<String, double>>(
      (ref, params) => ref
      .watch(favoresRepositoryProvider)
      .escucharFavoresCercanos(
    latitud: params['latitud']!,
    longitud: params['longitud']!,
    radioKm: params['radioKm']!,
  ),
);

class FavoresNotifier extends StateNotifier<AsyncValue<List<Favor>>> {
  final PublicarFavor _publicarFavor;
  final ObtenerFavoresCercanos _obtenerFavoresCercanos;
  final ObtenerMisFavores _obtenerMisFavores;
  final CancelarFavor _cancelarFavor;

  FavoresNotifier({
    required PublicarFavor publicarFavor,
    required ObtenerFavoresCercanos obtenerFavoresCercanos,
    required ObtenerMisFavores obtenerMisFavores,
    required CancelarFavor cancelarFavor,
  })  : _publicarFavor = publicarFavor,
        _obtenerFavoresCercanos = obtenerFavoresCercanos,
        _obtenerMisFavores = obtenerMisFavores,
        _cancelarFavor = cancelarFavor,
        super(const AsyncValue.data([]));

  Future<bool> publicarFavor({
    required String titulo,
    required String descripcion,
    required String categoria,
    required double latitud,
    required double longitud,
    required double radioKm,
    required String ventanaSubasta,
  }) async {
    state = const AsyncValue.loading();
    final result = await _publicarFavor(
      titulo: titulo,
      descripcion: descripcion,
      categoria: categoria,
      latitud: latitud,
      longitud: longitud,
      radioKm: radioKm,
      ventanaSubasta: ventanaSubasta,
    );
    return result.fold(
          (error) {
        state = AsyncValue.error(error, StackTrace.current);
        return false;
      },
          (favor) {
        state = AsyncValue.data([...state.value ?? [], favor]);
        return true;
      },
    );
  }

  Future<void> cargarFavoresCercanos({
    required double latitud,
    required double longitud,
    required double radioKm,
  }) async {
    state = const AsyncValue.loading();
    final result = await _obtenerFavoresCercanos(
      latitud: latitud,
      longitud: longitud,
      radioKm: radioKm,
    );
    result.fold(
          (error) => state = AsyncValue.error(error, StackTrace.current),
          (favores) => state = AsyncValue.data(favores),
    );
  }

  Future<void> cargarMisFavores() async {
    state = const AsyncValue.loading();
    final result = await _obtenerMisFavores();
    result.fold(
          (error) => state = AsyncValue.error(error, StackTrace.current),
          (favores) => state = AsyncValue.data(favores),
    );
  }

  Future<void> cancelarFavor({required String id}) async {
    final result = await _cancelarFavor(id: id);
    result.fold(
          (error) => state = AsyncValue.error(error, StackTrace.current),
          (_) {
        final favoresActuales = state.value ?? [];
        state = AsyncValue.data(
          favoresActuales.where((f) => f.id != id).toList(),
        );
      },
    );
  }
}

final favoresNotifierProvider =
StateNotifierProvider<FavoresNotifier, AsyncValue<List<Favor>>>(
      (ref) => FavoresNotifier(
    publicarFavor: ref.watch(publicarFavorProvider),
    obtenerFavoresCercanos: ref.watch(obtenerFavoresCercanosProvider),
    obtenerMisFavores: ref.watch(obtenerMisFavoresProvider),
    cancelarFavor: ref.watch(cancelarFavorProvider),
  ),
);