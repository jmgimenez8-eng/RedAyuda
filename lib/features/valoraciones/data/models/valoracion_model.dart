import '../../domain/entities/valoracion.dart';

class ValoracionModel extends Valoracion {
  const ValoracionModel({
    required super.id,
    required super.favorId,
    required super.valoradorId,
    required super.valoradoId,
    required super.puntuacion,
    super.comentario,
    required super.createdAt,
  });

  factory ValoracionModel.fromJson(Map<String, dynamic> json) {
    return ValoracionModel(
      id: json['id'] as String,
      favorId: json['favor_id'] as String,
      valoradorId: json['valorador_id'] as String,
      valoradoId: json['valorado_id'] as String,
      puntuacion: json['puntuacion'] as int,
      comentario: json['comentario'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'favor_id': favorId,
      'valorador_id': valoradorId,
      'valorado_id': valoradoId,
      'puntuacion': puntuacion,
      'comentario': comentario,
      'created_at': createdAt.toIso8601String(),
    };
  }
}