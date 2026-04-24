import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/favor_model.dart';

class FavoresSupabaseDatasource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<FavorModel> publicarFavor({
    required String titulo,
    required String descripcion,
    required String categoria,
    required double latitud,
    required double longitud,
    required double radioKm,
    required String ventanaSubasta,
  }) async {
    final solicitanteId = _client.auth.currentUser?.id;
    if (solicitanteId == null) throw Exception('No hay sesión activa');

    final ahora = DateTime.now();
    DateTime expiresAt;
    switch (ventanaSubasta) {
      case '30min':
        expiresAt = ahora.add(const Duration(minutes: 30));
        break;
      case '24h':
        expiresAt = ahora.add(const Duration(hours: 24));
        break;
      default:
        expiresAt = ahora.add(const Duration(hours: 1));
    }

    final data = await _client
        .from('favores')
        .insert({
      'solicitante_id': solicitanteId,
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'latitud': latitud,
      'longitud': longitud,
      'radio_km': radioKm,
      'ventana_subasta': ventanaSubasta,
      'estado': 'activo',
      'expires_at': expiresAt.toIso8601String(),
    })
        .select()
        .single();

    return FavorModel.fromJson(data);
  }

  Future<List<FavorModel>> obtenerFavoresCercanos({
    required double latitud,
    required double longitud,
    required double radioKm,
  }) async {
    final data = await _client
        .from('favores')
        .select()
        .eq('estado', 'activo')
        .gte('expires_at', DateTime.now().toIso8601String());

    final favores = (data as List)
        .map((json) => FavorModel.fromJson(json))
        .where((favor) {
      final distancia = _calcularDistancia(
        latitud,
        longitud,
        favor.latitud,
        favor.longitud,
      );
      return distancia <= radioKm;
    })
        .toList();

    return favores;
  }

  Future<FavorModel> obtenerFavorPorId({required String id}) async {
    final data = await _client
        .from('favores')
        .select()
        .eq('id', id)
        .single();

    return FavorModel.fromJson(data);
  }

  Future<List<FavorModel>> obtenerMisFavores() async {
    final solicitanteId = _client.auth.currentUser?.id;
    if (solicitanteId == null) throw Exception('No hay sesión activa');

    final data = await _client
        .from('favores')
        .select()
        .eq('solicitante_id', solicitanteId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((json) => FavorModel.fromJson(json))
        .toList();
  }

  Future<void> cancelarFavor({required String id}) async {
    await _client
        .from('favores')
        .update({'estado': 'cancelado'})
        .eq('id', id);
  }

  Stream<List<FavorModel>> escucharFavoresCercanos({
    required double latitud,
    required double longitud,
    required double radioKm,
  }) {
    return _client
        .from('favores')
        .stream(primaryKey: ['id'])
        .eq('estado', 'activo')
        .map((data) => data
        .map((json) => FavorModel.fromJson(json))
        .where((favor) {
      final distancia = _calcularDistancia(
        latitud,
        longitud,
        favor.latitud,
        favor.longitud,
      );
      return distancia <= radioKm;
    })
        .toList());
  }

  double _calcularDistancia(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      ) {
    const double radioTierra = 6371;
    final double dLat = _gradosARadianes(lat2 - lat1);
    final double dLon = _gradosARadianes(lon2 - lon1);
    final double a = (dLat / 2) * (dLat / 2) +
        _gradosARadianes(lat1) *
            _gradosARadianes(lat2) *
            (dLon / 2) *
            (dLon / 2);
    final double c = 2 * (a < 1 ? a : 1);
    return radioTierra * c;
  }

  double _gradosARadianes(double grados) {
    return grados * (3.141592653589793 / 180);
  }
}