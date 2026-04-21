import 'package:dartz/dartz.dart';
import '../entities/usuario.dart';

abstract class AuthRepository {
  Future<Either<String, Usuario>> registrar({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
  });

  Future<Either<String, Usuario>> iniciarSesion({
    required String email,
    required String password,
  });

  Future<Either<String, void>> cerrarSesion();

  Future<Either<String, void>> recuperarPassword({
    required String email,
  });

  Future<Either<String, Usuario>> obtenerUsuarioActual();

  Stream<Usuario?> onAuthStateChange();
}