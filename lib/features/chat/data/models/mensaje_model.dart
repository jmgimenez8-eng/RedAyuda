import '../../domain/entities/mensaje.dart';

class MensajeModel extends Mensaje {
  const MensajeModel({
    required super.id,
    required super.favorId,
    required super.emisorId,
    required super.contenido,
    required super.leido,
    required super.createdAt,
  });

  factory MensajeModel.fromJson(Map<String, dynamic> json) {
    return MensajeModel(
      id: json['id'] as String,
      favorId: json['favor_id'] as String,
      emisorId: json['emisor_id'] as String,
      contenido: json['contenido'] as String,
      leido: json['leido'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'favor_id': favorId,
      'emisor_id': emisorId,
      'contenido': contenido,
      'leido': leido,
      'created_at': createdAt.toIso8601String(),
    };
  }
}