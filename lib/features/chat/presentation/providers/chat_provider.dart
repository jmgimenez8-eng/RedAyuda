import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/chat_supabase_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/mensaje.dart';
import '../../domain/usecases/crear_conversacion.dart';
import '../../domain/usecases/enviar_mensaje.dart';
import '../../domain/usecases/obtener_mensajes.dart';

final chatDatasourceProvider = Provider<ChatSupabaseDatasource>(
      (ref) => ChatSupabaseDatasource(),
);

final chatRepositoryProvider = Provider<ChatRepositoryImpl>(
      (ref) => ChatRepositoryImpl(ref.watch(chatDatasourceProvider)),
);

final enviarMensajeProvider = Provider<EnviarMensaje>(
      (ref) => EnviarMensaje(ref.watch(chatRepositoryProvider)),
);

final obtenerMensajesProvider = Provider<ObtenerMensajes>(
      (ref) => ObtenerMensajes(ref.watch(chatRepositoryProvider)),
);

final crearConversacionProvider = Provider<CrearConversacion>(
      (ref) => CrearConversacion(ref.watch(chatRepositoryProvider)),
);

final mensajesStreamProvider = StreamProvider.family<List<Mensaje>, String>(
      (ref, favorId) => ref
      .watch(chatRepositoryProvider)
      .escucharMensajes(favorId: favorId),
);

class ChatNotifier extends StateNotifier<AsyncValue<List<Mensaje>>> {
  final EnviarMensaje _enviarMensaje;
  final ObtenerMensajes _obtenerMensajes;
  final CrearConversacion _crearConversacion;

  ChatNotifier({
    required EnviarMensaje enviarMensaje,
    required ObtenerMensajes obtenerMensajes,
    required CrearConversacion crearConversacion,
  })  : _enviarMensaje = enviarMensaje,
        _obtenerMensajes = obtenerMensajes,
        _crearConversacion = crearConversacion,
        super(const AsyncValue.data([]));

  Future<bool> enviarMensaje({
    required String favorId,
    required String contenido,
  }) async {
    final result = await _enviarMensaje(
      favorId: favorId,
      contenido: contenido,
    );
    return result.fold(
          (error) {
        state = AsyncValue.error(error, StackTrace.current);
        return false;
      },
          (mensaje) {
        state = AsyncValue.data([...state.value ?? [], mensaje]);
        return true;
      },
    );
  }

  Future<void> cargarMensajes({required String favorId}) async {
    state = const AsyncValue.loading();
    final result = await _obtenerMensajes(favorId: favorId);
    result.fold(
          (error) => state = AsyncValue.error(error, StackTrace.current),
          (mensajes) => state = AsyncValue.data(mensajes),
    );
  }

  Future<void> crearConversacion({
    required String favorId,
    required String solicitanteId,
    required String ayudanteId,
  }) async {
    await _crearConversacion(
      favorId: favorId,
      solicitanteId: solicitanteId,
      ayudanteId: ayudanteId,
    );
  }
}

final chatNotifierProvider =
StateNotifierProvider<ChatNotifier, AsyncValue<List<Mensaje>>>(
      (ref) => ChatNotifier(
    enviarMensaje: ref.watch(enviarMensajeProvider),
    obtenerMensajes: ref.watch(obtenerMensajesProvider),
    crearConversacion: ref.watch(crearConversacionProvider),
  ),
);