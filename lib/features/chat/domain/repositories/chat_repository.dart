import 'package:dartz/dartz.dart';
import '../entities/mensaje.dart';

abstract class ChatRepository {
  Future<Either<String, Mensaje>> enviarMensaje({
    required String favorId,
    required String contenido,
  });

  Future<Either<String, List<Mensaje>>> obtenerMensajes({
    required String favorId,
  });

  Future<Either<String, void>> marcarComoLeido({
    required String mensajeId,
  });

  Stream<List<Mensaje>> escucharMensajes({
    required String favorId,
  });

  Future<Either<String, void>> crearConversacion({
    required String favorId,
    required String solicitanteId,
    required String ayudanteId,
  });
}