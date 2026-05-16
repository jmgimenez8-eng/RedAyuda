import 'package:dartz/dartz.dart';
import '../repositories/chat_repository.dart';

class CrearConversacion {
  final ChatRepository repository;

  CrearConversacion(this.repository);

  Future<Either<String, void>> call({
    required String favorId,
    required String solicitanteId,
    required String ayudanteId,
  }) {
    return repository.crearConversacion(
      favorId: favorId,
      solicitanteId: solicitanteId,
      ayudanteId: ayudanteId,
    );
  }
}