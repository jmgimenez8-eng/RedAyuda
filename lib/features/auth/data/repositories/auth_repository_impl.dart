import 'package:dartz/dartz.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_supabase_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthSupabaseDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<Either<String, Usuario>> registrar({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
  }) async {
    try {
      final usuario = await datasource.registrar(
        nombre: nombre,
        email: email,
        password: password,
        telefono: telefono,
      );
      return Right(usuario);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Usuario>> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      final usuario = await datasource.iniciarSesion(
        email: email,
        password: password,
      );
      return Right(usuario);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Usuario>> iniciarSesionConGoogle() async {
    try {
      final usuario = await datasource.iniciarSesionConGoogle();
      return Right(usuario);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> cerrarSesion() async {
    try {
      await datasource.cerrarSesion();
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> recuperarPassword({
    required String email,
  }) async {
    try {
      await datasource.recuperarPassword(email: email);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Usuario>> obtenerUsuarioActual() async {
    try {
      final usuario = await datasource.obtenerUsuarioActual();
      if (usuario == null) return const Left('No hay sesión activa');
      return Right(usuario);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Stream<Usuario?> onAuthStateChange() {
    return datasource.onAuthStateChange();
  }
}