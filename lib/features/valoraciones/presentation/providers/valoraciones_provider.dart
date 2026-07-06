import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/valoraciones_supabase_datasource.dart';
import '../../data/repositories/valoraciones_repository_impl.dart';
import '../../domain/entities/valoracion.dart';
import '../../domain/usecases/crear_valoracion.dart';
import '../../domain/usecases/obtener_reputacion.dart';
import '../../domain/usecases/obtener_valoraciones_por_usuario.dart';

final valoracionesDatasourceProvider =
Provider<ValoracionesSupabaseDatasource>(
      (ref) => ValoracionesSupabaseDatasource(),
);

final valoracionesRepositoryProvider =
Provider<ValoracionesRepositoryImpl>(
      (ref) => ValoracionesRepositoryImpl(
    ref.watch(valoracionesDatasourceProvider),
  ),
);

final crearValoracionProvider = Provider<CrearValoracion>(
      (ref) => CrearValoracion(ref.watch(valoracionesRepositoryProvider)),
);

final obtenerValoracionesPorUsuarioProvider =
Provider<ObtenerValoracionesPorUsuario>(
      (ref) => ObtenerValoracionesPorUsuario(
    ref.watch(valoracionesRepositoryProvider),
  ),
);

final obtenerReputacionProvider = Provider<ObtenerReputacion>(
      (ref) => ObtenerReputacion(ref.watch(valoracionesRepositoryProvider)),
);

class ValoracionesNotifier
    extends StateNotifier<AsyncValue<List<Valoracion>>> {
  final CrearValoracion _crearValoracion;
  final ObtenerValoracionesPorUsuario _obtenerValoraciones;
  final ObtenerReputacion _obtenerReputacion;

  ValoracionesNotifier({
    required CrearValoracion crearValoracion,
    required ObtenerValoracionesPorUsuario obtenerValoraciones,
    required ObtenerReputacion obtenerReputacion,
  })  : _crearValoracion = crearValoracion,
        _obtenerValoraciones = obtenerValoraciones,
        _obtenerReputacion = obtenerReputacion,
        super(const AsyncValue.data([]));

  Future<bool> crearValoracion({
    required String favorId,
    required String valoradoId,
    required int puntuacion,
    String? comentario,
  }) async {
    final result = await _crearValoracion(
      favorId: favorId,
      valoradoId: valoradoId,
      puntuacion: puntuacion,
      comentario: comentario,
    );
    return result.fold(
          (error) {
        state = AsyncValue.error(error, StackTrace.current);
        return false;
      },
          // No se añade a `state`: esa lista representa las valoraciones
          // RECIBIDAS por el usuario del perfil que se esté mostrando. La
          // valoración recién creada la DA el usuario actual a otra persona,
          // así que no debe aparecer en su propio perfil.
          (valoracion) => true,
    );
  }

  Future<void> cargarValoraciones({required String usuarioId}) async {
    state = const AsyncValue.loading();
    final result = await _obtenerValoraciones(usuarioId: usuarioId);
    result.fold(
          (error) => state = AsyncValue.error(error, StackTrace.current),
          (valoraciones) => state = AsyncValue.data(valoraciones),
    );
  }

  Future<double?> obtenerReputacion({required String usuarioId}) async {
    final result = await _obtenerReputacion(usuarioId: usuarioId);
    return result.fold(
          (error) => null,
          (reputacion) => reputacion,
    );
  }
}

final valoracionesNotifierProvider =
StateNotifierProvider<ValoracionesNotifier, AsyncValue<List<Valoracion>>>(
      (ref) => ValoracionesNotifier(
    crearValoracion: ref.watch(crearValoracionProvider),
    obtenerValoraciones: ref.watch(obtenerValoracionesPorUsuarioProvider),
    obtenerReputacion: ref.watch(obtenerReputacionProvider),
  ),
);