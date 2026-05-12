import 'package:equatable/equatable.dart';

class Pago extends Equatable {
  final String id;
  final String favorId;
  final String ofertaId;
  final String solicitanteId;
  final String ayudanteId;
  final double importe;
  final double comisionPlataforma;
  final String estado;
  final String? paypalOrderId;
  final String? paypalCaptureId;
  final String? codigoVerificacion;
  final DateTime createdAt;

  const Pago({
    required this.id,
    required this.favorId,
    required this.ofertaId,
    required this.solicitanteId,
    required this.ayudanteId,
    required this.importe,
    required this.comisionPlataforma,
    required this.estado,
    this.paypalOrderId,
    this.paypalCaptureId,
    this.codigoVerificacion,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    favorId,
    ofertaId,
    solicitanteId,
    ayudanteId,
    importe,
    comisionPlataforma,
    estado,
    paypalOrderId,
    paypalCaptureId,
    codigoVerificacion,
    createdAt,
  ];
}