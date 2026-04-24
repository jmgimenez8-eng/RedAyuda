import 'package:dartz/dartz.dart';
import '../../../favores/domain/entities/favor.dart';
import '../repositories/favores_repository.dart';

class PublicarFavor {
  final FavoresRepository repository;

  PublicarFavor(this.repository);

  Future<Either<String, Favor>> call({
    required String titulo,
    required String descripcion,
    required String categoria,
    required double latitud,
    required double longitud,
    required double radioKm,
    required String ventanaSubasta,
  }) {
    return repository.publicarFavor(
      titulo: titulo,
      descripcion: descripcion,
      categoria: categoria,
      latitud: latitud,
      longitud: longitud,
      radioKm: radioKm,
      ventanaSubasta: ventanaSubasta,
    );
  }
}