import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:redayuda/features/favores/domain/entities/favor.dart';
import '../providers/valoraciones_provider.dart';
import 'package:redayuda/config/app_theme.dart';

class ValoracionPage extends ConsumerStatefulWidget {
  final Favor favor;
  final String valoradoId;
  final String valoradoNombre;

  const ValoracionPage({
    super.key,
    required this.favor,
    required this.valoradoId,
    required this.valoradoNombre,
  });

  @override
  ConsumerState<ValoracionPage> createState() => _ValoracionPageState();
}

class _ValoracionPageState extends ConsumerState<ValoracionPage> {
  int _puntuacion = 5;
  final _comentarioController = TextEditingController();

  static const _etiquetas = {
    1: 'Muy mala experiencia',
    2: 'Mala experiencia',
    3: 'Experiencia normal',
    4: 'Buena experiencia',
    5: 'Excelente experiencia',
  };

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _enviarValoracion() async {
    final exito =
        await ref.read(valoracionesNotifierProvider.notifier).crearValoracion(
              favorId: widget.favor.id,
              valoradoId: widget.valoradoId,
              puntuacion: _puntuacion,
              comentario: _comentarioController.text.trim().isEmpty
                  ? null
                  : _comentarioController.text.trim(),
            );

    if (exito && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Valoración enviada correctamente!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valoracionesState = ref.watch(valoracionesNotifierProvider);

    ref.listen(valoracionesNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: AppColors.error,
          ),
        ),
      );
    });

    final inicial = widget.valoradoNombre.isEmpty
        ? '?'
        : widget.valoradoNombre[0].toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Valorar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: theme.colorScheme.outline),
                boxShadow: AppShadows.card,
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                    child: Text(
                      inicial,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(widget.valoradoNombre, style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    widget.favor.titulo,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('¿Cómo fue la experiencia?',
                style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final estrella = index + 1;
                final activa = estrella <= _puntuacion;
                return GestureDetector(
                  onTap: () => setState(() => _puntuacion = estrella),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    child: Icon(
                      activa ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: AppColors.amber,
                      size: 48,
                    )
                        .animate(target: activa ? 1 : 0)
                        .scaleXY(begin: 0.8, end: 1, duration: AppDurations.fast),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _etiquetas[_puntuacion]!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextFormField(
              controller: _comentarioController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Comentario (opcional)',
                hintText: 'Cuéntanos cómo fue la experiencia con este usuario...',
                prefixIcon: Icon(Icons.comment_outlined),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: valoracionesState.isLoading ? null : _enviarValoracion,
              icon: valoracionesState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.4),
                    )
                  : const Icon(Icons.send_rounded),
              label: const Text('Enviar valoración'),
            ),
          ],
        ),
      ),
    );
  }
}
