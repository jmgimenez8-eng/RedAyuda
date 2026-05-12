import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/favores_provider.dart';
import '../../domain/entities/favor.dart';
import 'package:redayuda/features/subastas/presentation/pages/detalle_favor_page.dart';
import 'package:geolocator/geolocator.dart';

class ExplorarFavoresPage extends ConsumerStatefulWidget {
  const ExplorarFavoresPage({super.key});

  @override
  ConsumerState<ExplorarFavoresPage> createState() =>
      _ExplorarFavoresPageState();
}

class _ExplorarFavoresPageState extends ConsumerState<ExplorarFavoresPage> {
  String _categoriaFiltro = 'Todos';

  final List<String> _categorias = [
    'Todos',
    'Hogar',
    'Transporte',
    'Compras',
    'Tecnología',
    'Mascotas',
    'Mudanza',
    'Clases',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarFavores();
    });
  }

  Future<void> _cargarFavores() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      await ref.read(favoresNotifierProvider.notifier).cargarFavoresCercanos(
        latitud: position.latitude,
        longitud: position.longitude,
        radioKm: 50.0,
      );
    } catch (e) {
      await ref.read(favoresNotifierProvider.notifier).cargarFavoresCercanos(
        latitud: 37.9922,
        longitud: -1.1307,
        radioKm: 50.0,
      );
    }
  }

  Color _colorCategoria(String categoria) {
    switch (categoria) {
      case 'Hogar': return Colors.blue;
      case 'Transporte': return Colors.orange;
      case 'Compras': return Colors.green;
      case 'Tecnología': return Colors.purple;
      case 'Mascotas': return Colors.brown;
      case 'Mudanza': return Colors.red;
      case 'Clases': return Colors.teal;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoresState = ref.watch(favoresNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar favores'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarFavores,
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categorias.length,
              itemBuilder: (context, index) {
                final categoria = _categorias[index];
                final seleccionada = _categoriaFiltro == categoria;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(categoria),
                    selected: seleccionada,
                    onSelected: (_) =>
                        setState(() => _categoriaFiltro = categoria),
                    selectedColor: const Color(0xFF6C63FF).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF6C63FF),
                    labelStyle: TextStyle(
                      color: seleccionada
                          ? const Color(0xFF6C63FF)
                          : Colors.grey,
                      fontWeight: seleccionada
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: favoresState.when(
              data: (favores) {
                final filtrados = favores
                    .where((f) =>
                f.estado == 'activo' &&
                    (_categoriaFiltro == 'Todos' ||
                        f.categoria == _categoriaFiltro))
                    .toList();

                if (filtrados.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay favores activos en tu zona',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _cargarFavores,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtrados.length,
                    itemBuilder: (context, index) {
                      final favor = filtrados[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetalleFavorPage(favor: favor),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _colorCategoria(favor.categoria)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        favor.categoria,
                                        style: TextStyle(
                                          color:
                                          _colorCategoria(favor.categoria),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      favor.expiresAt != null
                                          ? timeago.format(favor.expiresAt!,
                                          locale: 'es')
                                          : 'Sin expiración',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  favor.titulo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  favor.descripcion,
                                  style: const TextStyle(color: Colors.grey),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${favor.radioKm.toStringAsFixed(0)} km de radio',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(
                child: Text('Error al cargar favores'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}