import '../../domain/entities/oferta.dart';

class OfertaModel extends Oferta {
  const OfertaModel({
    required super.id,
    required super.favorId,
    required super.ayudanteId,
    required super.precio,
    super.mensaje,
    required super.estado,
    required super.createdAt,
  });

  factory OfertaModel.fromJson(Map<String, dynamic> json) {
    return OfertaModel(
      id: json['id'] as String,
      favorId: json['favor_id'] as String,
      ayudanteId: json['ayudante_id'] as String,
      precio: (json['precio'] as num).toDouble(),
      mensaje: json['mensaje'] as String?,
      estado: json['estado'] as String? ?? 'pendiente',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'favor_id': favorId,
      'ayudante_id': ayudanteId,
      'precio': precio,
      'mensaje': mensaje,
      'estado': estado,
      'created_at': createdAt.toIso8601String(),
    };
  }
}