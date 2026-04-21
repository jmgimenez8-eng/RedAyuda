import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';

class CerrarSesion {
  final AuthRepository repository;

  CerrarSesion(this.repository);

  Future<Either<String, void>> call() {
    return repository.cerrarSesion();
  }
}