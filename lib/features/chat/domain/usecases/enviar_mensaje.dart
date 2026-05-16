import 'package:dartz/dartz.dart';
import '../entities/mensaje.dart';
import '../repositories/chat_repository.dart';

class EnviarMensaje {
  final ChatRepository repository;

  EnviarMensaje(this.repository);

  Future<Either<String, Mensaje>> call({
    required String favorId,
    required String contenido,
  }) {
    return repository.enviarMensaje(
      favorId: favorId,
      contenido: contenido,
    );
  }
}