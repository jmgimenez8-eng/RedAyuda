import 'package:dartz/dartz.dart';
import '../../domain/entities/mensaje.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_supabase_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatSupabaseDatasource datasource;

  ChatRepositoryImpl(this.datasource);

  @override
  Future<Either<String, Mensaje>> enviarMensaje({
    required String favorId,
    required String contenido,
  }) async {
    try {
      final mensaje = await datasource.enviarMensaje(
        favorId: favorId,
        contenido: contenido,
      );
      return Right(mensaje);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Mensaje>>> obtenerMensajes({
    required String favorId,
  }) async {
    try {
      final mensajes = await datasource.obtenerMensajes(favorId: favorId);
      return Right(mensajes);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> marcarComoLeido({
    required String mensajeId,
  }) async {
    try {
      await datasource.marcarComoLeido(mensajeId: mensajeId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Stream<List<Mensaje>> escucharMensajes({required String favorId}) {
    return datasource.escucharMensajes(favorId: favorId);
  }

  @override
  Future<Either<String, void>> crearConversacion({
    required String favorId,
    required String solicitanteId,
    required String ayudanteId,
  }) async {
    try {
      await datasource.crearConversacion(
        favorId: favorId,
        solicitanteId: solicitanteId,
        ayudanteId: ayudanteId,
      );
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}