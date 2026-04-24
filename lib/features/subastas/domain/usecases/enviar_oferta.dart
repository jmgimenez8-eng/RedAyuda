import 'package:dartz/dartz.dart';
import '../entities/oferta.dart';
import '../repositories/subastas_repository.dart';

class EnviarOferta {
  final SubastasRepository repository;

  EnviarOferta(this.repository);

  Future<Either<String, Oferta>> call({
    required String favorId,
    required double precio,
    String? mensaje,
  }) {
    return repository.enviarOferta(
      favorId: favorId,
      precio: precio,
      mensaje: mensaje,
    );
  }
}