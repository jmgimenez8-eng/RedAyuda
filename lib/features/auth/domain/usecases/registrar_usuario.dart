import 'package:dartz/dartz.dart';
import '../entities/usuario.dart';
import '../repositories/auth_repository.dart';

class RegistrarUsuario {
  final AuthRepository repository;

  RegistrarUsuario(this.repository);

  Future<Either<String, Usuario>> call({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
  }) {
    return repository.registrar(
      nombre: nombre,
      email: email,
      password: password,
      telefono: telefono,
    );
  }
}