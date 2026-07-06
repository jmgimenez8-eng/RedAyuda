import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/valoracion_model.dart';

class ValoracionesSupabaseDatasource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<ValoracionModel> crearValoracion({
    required String favorId,
    required String valoradoId,
    required int puntuacion,
    String? comentario,
  }) async {
    final valoradorId = _client.auth.currentUser?.id;
    if (valoradorId == null) throw Exception('No hay sesión activa');

    if (valoradorId == valoradoId) {
      throw Exception('No puedes valorarte a ti mismo');
    }

    // Verificar que el favor está completado
    final favor = await _client
        .from('favores')
        .select()
        .eq('id', favorId)
        .eq('estado', 'completado')
        .maybeSingle();

    if (favor == null) {
      throw Exception('Solo puedes valorar favores completados');
    }

    // Verificar que no ha valorado ya
    final yaValorado = await _client
        .from('valoraciones')
        .select()
        .eq('favor_id', favorId)
        .eq('valorador_id', valoradorId)
        .maybeSingle();

    if (yaValorado != null) {
      throw Exception('Ya has valorado este favor');
    }

    final data = await _client
        .from('valoraciones')
        .insert({
      'favor_id': favorId,
      'valorador_id': valoradorId,
      'valorado_id': valoradoId,
      'puntuacion': puntuacion,
      'comentario': comentario,
    })
        .select()
        .single();

    // Actualizar reputación del usuario valorado
    await _actualizarReputacion(valoradoId);

    return ValoracionModel.fromJson(data);
  }

  Future<void> _actualizarReputacion(String usuarioId) async {
    final valoraciones = await _client
        .from('valoraciones')
        .select('puntuacion')
        .eq('valorado_id', usuarioId);

    if (valoraciones.isEmpty) return;

    final total = (valoraciones as List)
        .map((v) => v['puntuacion'] as int)
        .reduce((a, b) => a + b);

    final promedio = total / valoraciones.length;

    await _client
        .from('usuarios')
        .update({'reputacion': promedio})
        .eq('id', usuarioId);
  }

  Future<List<ValoracionModel>> obtenerValoracionesPorUsuario({
    required String usuarioId,
  }) async {
    final data = await _client
        .from('valoraciones')
        .select()
        .eq('valorado_id', usuarioId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((json) => ValoracionModel.fromJson(json))
        .toList();
  }

  Future<bool> yaValorado({
    required String favorId,
    required String valoradorId,
  }) async {
    final data = await _client
        .from('valoraciones')
        .select()
        .eq('favor_id', favorId)
        .eq('valorador_id', valoradorId)
        .maybeSingle();

    return data != null;
  }

  Future<double> obtenerReputacion({required String usuarioId}) async {
    final data = await _client
        .from('usuarios')
        .select('reputacion')
        .eq('id', usuarioId)
        .single();

    return (data['reputacion'] as num).toDouble();
  }
}