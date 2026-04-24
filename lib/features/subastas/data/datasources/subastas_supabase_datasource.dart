import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/oferta_model.dart';

class SubastasSupabaseDatasource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<OfertaModel> enviarOferta({
    required String favorId,
    required double precio,
    String? mensaje,
  }) async {
    final ayudanteId = _client.auth.currentUser?.id;
    if (ayudanteId == null) throw Exception('No hay sesión activa');

    // Verificar que el favor está activo
    final favor = await _client
        .from('favores')
        .select()
        .eq('id', favorId)
        .eq('estado', 'activo')
        .single();

    if (favor == null) throw Exception('El favor no está disponible');

    // Verificar que el ayudante no es el solicitante
    if (favor['solicitante_id'] == ayudanteId) {
      throw Exception('No puedes pujar por tu propio favor');
    }

    // Verificar que no ha enviado ya una oferta
    final ofertaExistente = await _client
        .from('ofertas')
        .select()
        .eq('favor_id', favorId)
        .eq('ayudante_id', ayudanteId)
        .maybeSingle();

    if (ofertaExistente != null) {
      // Actualizar oferta existente
      final data = await _client
          .from('ofertas')
          .update({
        'precio': precio,
        'mensaje': mensaje,
        'estado': 'pendiente',
      })
          .eq('id', ofertaExistente['id'])
          .select()
          .single();
      return OfertaModel.fromJson(data);
    }

    // Crear nueva oferta
    final data = await _client
        .from('ofertas')
        .insert({
      'favor_id': favorId,
      'ayudante_id': ayudanteId,
      'precio': precio,
      'mensaje': mensaje,
      'estado': 'pendiente',
    })
        .select()
        .single();

    return OfertaModel.fromJson(data);
  }

  Future<List<OfertaModel>> obtenerOfertasPorFavor({
    required String favorId,
  }) async {
    final data = await _client
        .from('ofertas')
        .select()
        .eq('favor_id', favorId)
        .order('precio', ascending: true);

    return (data as List)
        .map((json) => OfertaModel.fromJson(json))
        .toList();
  }

  Future<OfertaModel> aceptarOferta({
    required String ofertaId,
    required String favorId,
  }) async {
    // Rechazar todas las demás ofertas
    await _client
        .from('ofertas')
        .update({'estado': 'rechazada'})
        .eq('favor_id', favorId)
        .neq('id', ofertaId);

    // Aceptar la oferta seleccionada
    final data = await _client
        .from('ofertas')
        .update({'estado': 'aceptada'})
        .eq('id', ofertaId)
        .select()
        .single();

    // Actualizar estado del favor
    await _client
        .from('favores')
        .update({'estado': 'en_negociacion'})
        .eq('id', favorId);

    return OfertaModel.fromJson(data);
  }

  Future<void> rechazarOferta({required String ofertaId}) async {
    await _client
        .from('ofertas')
        .update({'estado': 'rechazada'})
        .eq('id', ofertaId);
  }

  Future<List<OfertaModel>> obtenerMisOfertas() async {
    final ayudanteId = _client.auth.currentUser?.id;
    if (ayudanteId == null) throw Exception('No hay sesión activa');

    final data = await _client
        .from('ofertas')
        .select()
        .eq('ayudante_id', ayudanteId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((json) => OfertaModel.fromJson(json))
        .toList();
  }

  Stream<List<OfertaModel>> escucharOfertasPorFavor({
    required String favorId,
  }) {
    return _client
        .from('ofertas')
        .stream(primaryKey: ['id'])
        .eq('favor_id', favorId)
        .order('precio')
        .map((data) => data
        .map((json) => OfertaModel.fromJson(json))
        .toList());
  }
}