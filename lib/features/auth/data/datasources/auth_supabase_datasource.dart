import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario_model.dart';

class AuthSupabaseDatasource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<UsuarioModel> registrar({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
  }) async {

    final authResponse = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final user = authResponse.user;
    if (user == null) {
      throw Exception('Error al registrar el usuario en Auth');
    }

    try {
      await _client.from('usuarios').insert({
        'id': user.id, // El UUID de Auth
        'nombre': nombre,
        'email': email,
        'telefono': telefono,
        'rol': 'solicitante',
        'reputacion': 5.0,
        'strikes': 0,
        'estado': 'activo',
      });

      return UsuarioModel(
        id: user.id,
        nombre: nombre,
        email: email,
        telefono: telefono,
        rol: 'solicitante',
        reputacion: 5.0,
        strikes: 0,
        estado: 'activo',
      );

    } catch (e) {
      print("Error en Insert: $e");
      rethrow;
    }
  }

  Future<UsuarioModel> iniciarSesion({
    required String email,
    required String password,
  }) async {
    final authResponse = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (authResponse.user == null) {
      throw Exception('Credenciales incorrectas');
    }

    // Pequeño delay para que Supabase procese la sesión
    await Future.delayed(const Duration(milliseconds: 500));

    final usuarioData = await _client
        .from('usuarios')
        .select()
        .eq('id', authResponse.user!.id)
        .single();

    return UsuarioModel.fromJson(usuarioData);
  }

  Future<void> cerrarSesion() async {
    await _client.auth.signOut();
  }

  Future<void> recuperarPassword({required String email}) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<UsuarioModel?> obtenerUsuarioActual() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final usuarioData = await _client
        .from('usuarios')
        .select()
        .eq('id', user.id)
        .single();

    return UsuarioModel.fromJson(usuarioData);
  }

  Stream<UsuarioModel?> onAuthStateChange() {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      if (event.session == null) return null;
      final usuarioData = await _client
          .from('usuarios')
          .select()
          .eq('id', event.session!.user.id)
          .single();
      return UsuarioModel.fromJson(usuarioData);
    });
  }
}