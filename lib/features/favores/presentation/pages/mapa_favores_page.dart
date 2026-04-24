import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../auth/presentation/providers/favores_provider.dart';
import '../../domain/entities/favor.dart';
import 'publicar_favor_page.dart';
import 'package:redayuda/features/subastas/presentation/pages/detalle_favor_page.dart';

class MapaFavoresPage extends ConsumerStatefulWidget {
  const MapaFavoresPage({super.key});

  @override
  ConsumerState<MapaFavoresPage> createState() => _MapaFavoresPageState();
}

class _MapaFavoresPageState extends ConsumerState<MapaFavoresPage> {
  GoogleMapController? _mapController;
  Position? _posicionActual;
  final Set<Marker> _markers = {};
  bool _cargandoUbicacion = true;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await _obtenerUbicacion();
    if (_posicionActual != null) {
      await _cargarFavores();
    }
  }

  Future<void> _obtenerUbicacion() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _posicionActual = position;
        _cargandoUbicacion = false;
      });
    } catch (e) {
      setState(() => _cargandoUbicacion = false);
    }
  }

  Future<void> _cargarFavores() async {
    if (_posicionActual == null) return;

    await ref.read(favoresNotifierProvider.notifier).cargarFavoresCercanos(
      latitud: _posicionActual!.latitude,
      longitud: _posicionActual!.longitude,
      radioKm: 5.0,
    );

    final favores = ref.read(favoresNotifierProvider).value ?? [];
    _actualizarMarkers(favores);
  }

  void _actualizarMarkers(List<Favor> favores) {
    setState(() {
      _markers.clear();
      for (final favor in favores) {
        _markers.add(
          Marker(
            markerId: MarkerId(favor.id),
            position: LatLng(favor.latitud, favor.longitud),
            infoWindow: InfoWindow(
              title: favor.titulo,
              snippet: '${favor.categoria} — pulsa para ver ofertas',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetalleFavorPage(favor: favor),
                ),
              ),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueViolet,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(favoresNotifierProvider, (previous, next) {
      next.whenOrNull(
        data: (favores) => _actualizarMarkers(favores),
      );
    });

    if (_cargandoUbicacion) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Obteniendo tu ubicación...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favores cercanos'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarFavores,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _posicionActual != null
                  ? LatLng(
                _posicionActual!.latitude,
                _posicionActual!.longitude,
              )
                  : const LatLng(37.9922, -1.1307),
              zoom: 14,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapToolbarEnabled: false,
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ref.watch(favoresNotifierProvider).when(
              data: (favores) => favores.isEmpty
                  ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Text(
                  'No hay favores activos cerca de ti',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  '${favores.length} favor${favores.length == 1 ? '' : 'es'} cerca de ti',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C63FF),
                  ),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PublicarFavorPage(),
          ),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Publicar favor'),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}