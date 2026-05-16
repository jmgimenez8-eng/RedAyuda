import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/mensaje_model.dart';

class ChatSupabaseDatasource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<MensajeModel> enviarMensaje({
    required String favorId,
    required String contenido,
  }) async {
    final emisorId = _client.auth.currentUser?.id;
    if (emisorId == null) throw Exception('No hay sesión activa');

    final data = await _client
        .from('mensajes')
        .insert({
      'favor_id': favorId,
      'emisor_id': emisorId,
      'contenido': contenido,
      'leido': false,
    })
        .select()
        .single();

    // Actualizar último mensaje en conversación
    await _client
        .from('conversaciones')
        .update({
      'ultimo_mensaje': contenido,
      'ultimo_mensaje_at': DateTime.now().toIso8601String(),
    })
        .eq('favor_id', favorId);

    return MensajeModel.fromJson(data);
  }

  Future<List<MensajeModel>> obtenerMensajes({
    required String favorId,
  }) async {
    final data = await _client
        .from('mensajes')
        .select()
        .eq('favor_id', favorId)
        .order('created_at', ascending: true);

    return (data as List)
        .map((json) => MensajeModel.fromJson(json))
        .toList();
  }

  Future<void> marcarComoLeido({required String mensajeId}) async {
    await _client
        .from('mensajes')
        .update({'leido': true})
        .eq('id', mensajeId);
  }

  Stream<List<MensajeModel>> escucharMensajes({
    required String favorId,
  }) {
    return _client
        .from('mensajes')
        .stream(primaryKey: ['id'])
        .eq('favor_id', favorId)
        .order('created_at')
        .map((data) => data
        .map((json) => MensajeModel.fromJson(json))
        .toList());
  }

  Future<void> crearConversacion({
    required String favorId,
    required String solicitanteId,
    required String ayudanteId,
  }) async {
    final existente = await _client
        .from('conversaciones')
        .select()
        .eq('favor_id', favorId)
        .maybeSingle();

    if (existente == null) {
      await _client.from('conversaciones').insert({
        'favor_id': favorId,
        'solicitante_id': solicitanteId,
        'ayudante_id': ayudanteId,
      });
    }
  }
}