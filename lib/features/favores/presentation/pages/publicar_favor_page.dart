import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../auth/presentation/providers/favores_provider.dart';

class PublicarFavorPage extends ConsumerStatefulWidget {
  const PublicarFavorPage({super.key});

  @override
  ConsumerState<PublicarFavorPage> createState() => _PublicarFavorPageState();
}

class _PublicarFavorPageState extends ConsumerState<PublicarFavorPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  String _categoriaSeleccionada = 'Hogar';
  String _ventanaSeleccionada = '1h';
  double? _latitud;
  double? _longitud;
  bool _obtendiendoUbicacion = false;

  final List<String> _categorias = [
    'Hogar',
    'Transporte',
    'Compras',
    'Tecnología',
    'Mascotas',
    'Mudanza',
    'Clases',
    'Otros',
  ];

  final List<Map<String, String>> _ventanas = [
    {'valor': '30min', 'label': '30 minutos'},
    {'valor': '1h', 'label': '1 hora'},
    {'valor': '24h', 'label': '24 horas'},
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _obtenerUbicacion() async {
    setState(() => _obtendiendoUbicacion = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('El servicio de ubicación está desactivado');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permiso de ubicación denegado');
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitud = position.latitude;
        _longitud = position.longitude;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _obtendiendoUbicacion = false);
    }
  }

  Future<void> _publicar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_latitud == null || _longitud == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes obtener tu ubicación primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final exito = await ref.read(favoresNotifierProvider.notifier).publicarFavor(
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      categoria: _categoriaSeleccionada,
      latitud: _latitud!,
      longitud: _longitud!,
      radioKm: 5.0,
      ventanaSubasta: _ventanaSeleccionada,
    );

    if (exito && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favor publicado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoresState = ref.watch(favoresNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar favor'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título del favor',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduce un título';
                  }
                  if (value.length < 5) {
                    return 'Mínimo 5 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduce una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _categorias
                    .map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _categoriaSeleccionada = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _ventanaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Tiempo de subasta',
                  prefixIcon: Icon(Icons.timer),
                  border: OutlineInputBorder(),
                ),
                items: _ventanas
                    .map((v) => DropdownMenuItem(
                  value: v['valor'],
                  child: Text(v['label']!),
                ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _ventanaSeleccionada = value!),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _obtendiendoUbicacion ? null : _obtenerUbicacion,
                icon: _obtendiendoUbicacion
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.location_on),
                label: Text(
                  _latitud != null
                      ? 'Ubicación obtenida ✓'
                      : 'Obtener mi ubicación',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: _latitud != null ? Colors.green : Colors.grey,
                  ),
                  foregroundColor:
                  _latitud != null ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: favoresState.isLoading ? null : _publicar,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                ),
                child: favoresState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Publicar favor',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}