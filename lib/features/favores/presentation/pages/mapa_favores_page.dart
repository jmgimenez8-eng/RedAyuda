import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:redayuda/features/favores/presentation/providers/favores_provider.dart';
import '../../domain/entities/favor.dart';
import 'publicar_favor_page.dart';
import 'package:redayuda/features/subastas/presentation/pages/detalle_favor_page.dart';
import 'package:redayuda/config/app_theme.dart';
import 'package:redayuda/shared/widgets/ui_kit.dart';

class MapaFavoresPage extends ConsumerStatefulWidget {
  const MapaFavoresPage({super.key});

  @override
  ConsumerState<MapaFavoresPage> createState() => _MapaFavoresPageState();
}

class _MapaFavoresPageState extends ConsumerState<MapaFavoresPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
    super.build(context);
    final theme = Theme.of(context);

    ref.listen(favoresNotifierProvider, (previous, next) {
      next.whenOrNull(data: (favores) => _actualizarMarkers(favores));
    });

    if (_cargandoUbicacion) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.md),
              Text('Obteniendo tu ubicación...',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favores cercanos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
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
                      _posicionActual!.latitude, _posicionActual!.longitude)
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
            top: AppSpacing.md,
            left: AppSpacing.md,
            right: AppSpacing.md,
            child: ref.watch(favoresNotifierProvider).when(
                  data: (favores) {
                    final activos =
                        favores.where((f) => f.estado == 'activo').toList();
                    return GlassPanel(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusPill),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.place_rounded,
                              size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              activos.isEmpty
                                  ? 'No hay favores activos cerca'
                                  : '${activos.length} favor${activos.length == 1 ? '' : 'es'} cerca de ti',
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PublicarFavorPage()),
        ),
        icon: const Icon(Icons.add_rounded),
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
