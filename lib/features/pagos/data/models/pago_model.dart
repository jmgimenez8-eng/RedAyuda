import '../../domain/entities/pago.dart';

class PagoModel extends Pago {
  const PagoModel({
    required super.id,
    required super.favorId,
    required super.ofertaId,
    required super.solicitanteId,
    required super.ayudanteId,
    required super.importe,
    required super.comisionPlataforma,
    required super.estado,
    super.paypalOrderId,
    super.paypalCaptureId,
    super.codigoVerificacion,
    required super.createdAt,
  });

  factory PagoModel.fromJson(Map<String, dynamic> json) {
    return PagoModel(
      id: json['id'] as String,
      favorId: json['favor_id'] as String,
      ofertaId: json['oferta_id'] as String,
      solicitanteId: json['solicitante_id'] as String,
      ayudanteId: json['ayudante_id'] as String,
      importe: (json['importe'] as num).toDouble(),
      comisionPlataforma:
      (json['comision_plataforma'] as num?)?.toDouble() ?? 0.0,
      estado: json['estado'] as String? ?? 'retenido',
      paypalOrderId: json['paypal_order_id'] as String?,
      paypalCaptureId: json['paypal_capture_id'] as String?,
      codigoVerificacion: json['codigo_verificacion'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'favor_id': favorId,
      'oferta_id': ofertaId,
      'solicitante_id': solicitanteId,
      'ayudante_id': ayudanteId,
      'importe': importe,
      'comision_plataforma': comisionPlataforma,
      'estado': estado,
      'paypal_order_id': paypalOrderId,
      'paypal_capture_id': paypalCaptureId,
      'codigo_verificacion': codigoVerificacion,
      'created_at': createdAt.toIso8601String(),
    };
  }
}