import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../auth/presentation/providers/favores_provider.dart';
import 'package:redayuda/config/app_theme.dart';

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
    {'valor': '30min', 'label': '30 min'},
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
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _obtendiendoUbicacion = false);
    }
  }

  Future<void> _publicar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_latitud == null || _longitud == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes obtener tu ubicación primero'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final exito =
        await ref.read(favoresNotifierProvider.notifier).publicarFavor(
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
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favoresState = ref.watch(favoresNotifierProvider);
    final ubicacionOk = _latitud != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Publicar favor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Título del favor',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduce un título';
                  }
                  if (value.length < 5) return 'Mínimo 5 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descripcionController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduce una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _categoriaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categorias
                    .map((cat) =>
                        DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _categoriaSeleccionada = value!),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Tiempo de subasta', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                children: _ventanas.map((v) {
                  final activa = _ventanaSeleccionada == v['valor'];
                  return ChoiceChip(
                    label: Text(v['label']!),
                    selected: activa,
                    showCheckmark: false,
                    onSelected: (_) =>
                        setState(() => _ventanaSeleccionada = v['valor']!),
                    labelStyle: theme.textTheme.labelMedium?.copyWith(
                      color: activa
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: activa ? FontWeight.w700 : FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: activa
                          ? Colors.transparent
                          : theme.colorScheme.outline,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: _obtendiendoUbicacion ? null : _obtenerUbicacion,
                icon: _obtendiendoUbicacion
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : Icon(ubicacionOk
                        ? Icons.check_circle_rounded
                        : Icons.my_location_rounded),
                label: Text(
                  ubicacionOk ? 'Ubicación obtenida' : 'Obtener mi ubicación',
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: ubicacionOk
                        ? AppColors.success
                        : theme.colorScheme.outline,
                  ),
                  foregroundColor:
                      ubicacionOk ? AppColors.success : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: favoresState.isLoading ? null : _publicar,
                icon: favoresState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: Colors.white),
                      )
                    : const Icon(Icons.campaign_rounded),
                label: const Text('Publicar favor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
