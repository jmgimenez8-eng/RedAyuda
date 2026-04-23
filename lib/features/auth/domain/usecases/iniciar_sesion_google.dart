import 'package:dartz/dartz.dart';
import '../entities/usuario.dart';
import '../repositories/auth_repository.dart';

class IniciarSesionConGoogle {
  final AuthRepository repository;

  IniciarSesionConGoogle(this.repository);

  Future<Either<String, Usuario>> call() {
    return repository.iniciarSesionConGoogle();
  }
}