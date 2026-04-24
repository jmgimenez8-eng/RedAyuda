import '../../domain/entities/favor.dart';

class FavorModel extends Favor {
  const FavorModel({
    required super.id,
    required super.solicitanteId,
    required super.titulo,
    required super.descripcion,
    required super.categoria,
    required super.latitud,
    required super.longitud,
    required super.radioKm,
    required super.ventanaSubasta,
    required super.estado,
    super.expiresAt,
    required super.createdAt,
  });

  factory FavorModel.fromJson(Map<String, dynamic> json) {
    return FavorModel(
      id: json['id'] as String,
      solicitanteId: json['solicitante_id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      categoria: json['categoria'] as String,
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      radioKm: (json['radio_km'] as num?)?.toDouble() ?? 5.0,
      ventanaSubasta: json['ventana_subasta'] as String? ?? '1h',
      estado: json['estado'] as String? ?? 'activo',
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'solicitante_id': solicitanteId,
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'latitud': latitud,
      'longitud': longitud,
      'radio_km': radioKm,
      'ventana_subasta': ventanaSubasta,
      'estado': estado,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}