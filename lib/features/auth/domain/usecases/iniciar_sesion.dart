import 'package:dartz/dartz.dart';
import '../entities/usuario.dart';
import '../repositories/auth_repository.dart';

class IniciarSesion {
  final AuthRepository repository;

  IniciarSesion(this.repository);

  Future<Either<String, Usuario>> call({
    required String email,
    required String password,
  }) {
    return repository.iniciarSesion(
      email: email,
      password: password,
    );
  }
}