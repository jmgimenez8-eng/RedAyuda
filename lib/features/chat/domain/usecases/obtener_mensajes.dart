import 'package:dartz/dartz.dart';
import '../entities/mensaje.dart';
import '../repositories/chat_repository.dart';

class ObtenerMensajes {
  final ChatRepository repository;

  ObtenerMensajes(this.repository);

  Future<Either<String, List<Mensaje>>> call({
    required String favorId,
  }) {
    return repository.obtenerMensajes(favorId: favorId);
  }
}