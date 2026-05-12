import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pago_model.dart';

class PagosSupabaseDatasource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<PagoModel> crearPago({
    required String favorId,
    required String ofertaId,
    required String ayudanteId,
    required double importe,
  }) async {
    final solicitanteId = _client.auth.currentUser?.id;
    if (solicitanteId == null) throw Exception('No hay sesión activa');

    final comision = importe * 0.05;

    final data = await _client
        .from('pagos')
        .insert({
      'favor_id': favorId,
      'oferta_id': ofertaId,
      'solicitante_id': solicitanteId,
      'ayudante_id': ayudanteId,
      'importe': importe,
      'comision_plataforma': comision,
      'estado': 'retenido',
    })
        .select()
        .single();

    return PagoModel.fromJson(data);
  }

  Future<PagoModel> confirmarPago({
    required String pagoId,
    required String paypalOrderId,
    required String paypalCaptureId,
  }) async {
    final data = await _client
        .from('pagos')
        .update({
      'paypal_order_id': paypalOrderId,
      'paypal_capture_id': paypalCaptureId,
      'estado': 'retenido',
    })
        .eq('id', pagoId)
        .select()
        .single();

    return PagoModel.fromJson(data);
  }

  Future<PagoModel> liberarPago({
    required String pagoId,
    required String codigoVerificacion,
  }) async {
    final pago = await _client
        .from('pagos')
        .select()
        .eq('id', pagoId)
        .single();

    if (pago['codigo_verificacion'] != codigoVerificacion) {
      throw Exception('Código de verificación incorrecto');
    }

    final data = await _client
        .from('pagos')
        .update({'estado': 'liberado'})
        .eq('id', pagoId)
        .select()
        .single();

    await _client
        .from('favores')
        .update({'estado': 'completado'})
        .eq('id', pago['favor_id']);

    return PagoModel.fromJson(data);
  }

  Future<PagoModel?> obtenerPagoPorFavor({required String favorId}) async {
    final data = await _client
        .from('pagos')
        .select()
        .eq('favor_id', favorId)
        .maybeSingle();

    if (data == null) return null;
    return PagoModel.fromJson(data);
  }

  Future<String> generarCodigoVerificacion({required String pagoId}) async {
    final codigo = (100000 + Random().nextInt(900000)).toString();

    await _client
        .from('pagos')
        .update({'codigo_verificacion': codigo})
        .eq('id', pagoId);

    return codigo;
  }

  Stream<PagoModel?> escucharPagoPorFavor({required String favorId}) {
    return _client
        .from('pagos')
        .stream(primaryKey: ['id'])
        .eq('favor_id', favorId)
        .map((data) => data.isEmpty ? null : PagoModel.fromJson(data.first));
  }
}