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

    // Verificar si ya existe un pago para este favor
    final pagoExistente = await _client
        .from('pagos')
        .select()
        .eq('favor_id', favorId)
        .eq('estado', 'retenido')
        .maybeSingle();

    // Si existe un pago retenido sin paypal_order_id reutilizarlo
    if (pagoExistente != null &&
        pagoExistente['paypal_order_id'] == null) {
      return PagoModel.fromJson(pagoExistente);
    }

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

  Future<Map<String, dynamic>> crearOrdenPaypal({required String pagoId}) async {
    final response = await _client.functions.invoke(
      'paypal-create-order',
      body: {'pagoId': pagoId},
    );
    if (response.status != 200) {
      throw Exception('Error creando la orden de PayPal: ${response.data}');
    }
    return response.data as Map<String, dynamic>;
  }

  Future<PagoModel> capturarOrdenPaypal({required String pagoId}) async {
    final response = await _client.functions.invoke(
      'paypal-capture-order',
      body: {'pagoId': pagoId},
    );
    if (response.status != 200) {
      throw Exception('Error capturando el pago de PayPal: ${response.data}');
    }
    final json = (response.data as Map<String, dynamic>)['pago']
        as Map<String, dynamic>;
    return PagoModel.fromJson(json);
  }

  Future<PagoModel> confirmarPagoSimulado({required String pagoId}) async {
    final marca = 'SIMULADO-${DateTime.now().millisecondsSinceEpoch}';

    final data = await _client
        .from('pagos')
        .update({
      'paypal_order_id': marca,
      'paypal_capture_id': marca,
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