import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_supabase_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/usecases/cerrar_sesion.dart';
import '../../domain/usecases/iniciar_sesion.dart';
import '../../domain/usecases/recuperar_password.dart';
import '../../domain/usecases/registrar_usuario.dart';

final authDatasourceProvider = Provider<AuthSupabaseDatasource>(
      (ref) => AuthSupabaseDatasource(),
);

final authRepositoryProvider = Provider<AuthRepositoryImpl>(
      (ref) => AuthRepositoryImpl(ref.watch(authDatasourceProvider)),
);

final registrarUsuarioProvider = Provider<RegistrarUsuario>(
      (ref) => RegistrarUsuario(ref.watch(authRepositoryProvider)),
);

final iniciarSesionProvider = Provider<IniciarSesion>(
      (ref) => IniciarSesion(ref.watch(authRepositoryProvider)),
);

final cerrarSesionProvider = Provider<CerrarSesion>(
      (ref) => CerrarSesion(ref.watch(authRepositoryProvider)),
);

final recuperarPasswordProvider = Provider<RecuperarPassword>(
      (ref) => RecuperarPassword(ref.watch(authRepositoryProvider)),
);

final authStateProvider = StreamProvider<Usuario?>(
      (ref) => ref.watch(authRepositoryProvider).onAuthStateChange(),
);

class AuthNotifier extends StateNotifier<AsyncValue<Usuario?>> {
  final RegistrarUsuario _registrarUsuario;
  final IniciarSesion _iniciarSesion;
  final CerrarSesion _cerrarSesion;
  final RecuperarPassword _recuperarPassword;

  AuthNotifier({
    required RegistrarUsuario registrarUsuario,
    required IniciarSesion iniciarSesion,
    required CerrarSesion cerrarSesion,
    required RecuperarPassword recuperarPassword,
  })  : _registrarUsuario = registrarUsuario,
        _iniciarSesion = iniciarSesion,
        _cerrarSesion = cerrarSesion,
        _recuperarPassword = recuperarPassword,
        super(const AsyncValue.data(null));

  Future<void> registrar({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
  }) async {
    state = const AsyncValue.loading();
    final result = await _registrarUsuario(
      nombre: nombre,
      email: email,
      password: password,
      telefono: telefono,
    );
    result.fold(
          (error) => state = AsyncValue.error(error, StackTrace.current),
          (usuario) => state = AsyncValue.data(usuario),
    );
  }

  Future<void> iniciarSesion({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final result = await _iniciarSesion(
      email: email,
      password: password,
    );
    result.fold(
          (error) => state = AsyncValue.error(error, StackTrace.current),
          (usuario) => state = AsyncValue.data(usuario),
    );
  }

  Future<void> cerrarSesion() async {
    state = const AsyncValue.loading();
    final result = await _cerrarSesion();
    result.fold(
          (error) => state = AsyncValue.error(error, StackTrace.current),
          (_) => state = const AsyncValue.data(null),
    );
  }

  Future<void> recuperarPassword({required String email}) async {
    state = const AsyncValue.loading();
    final result = await _recuperarPassword(email: email);
    result.fold(
          (error) => state = AsyncValue.error(error, StackTrace.current),
          (_) => state = const AsyncValue.data(null),
    );
  }
}

final authNotifierProvider =
StateNotifierProvider<AuthNotifier, AsyncValue<Usuario?>>(
      (ref) => AuthNotifier(
    registrarUsuario: ref.watch(registrarUsuarioProvider),
    iniciarSesion: ref.watch(iniciarSesionProvider),
    cerrarSesion: ref.watch(cerrarSesionProvider),
    recuperarPassword: ref.watch(recuperarPasswordProvider),
  ),
);