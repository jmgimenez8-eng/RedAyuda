import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../favores/domain/entities/favor.dart';
import '../providers/subastas_provider.dart';
import 'package:redayuda/features/subastas/domain/entities/oferta.dart';
import 'package:redayuda/config/app_theme.dart';
import 'package:redayuda/shared/widgets/ui_kit.dart';

class EnviarOfertaPage extends ConsumerStatefulWidget {
  final Favor favor;
  final Oferta? ofertaExistente;

  const EnviarOfertaPage({
    super.key,
    required this.favor,
    this.ofertaExistente,
  });

  @override
  ConsumerState<EnviarOfertaPage> createState() => _EnviarOfertaPageState();
}

class _EnviarOfertaPageState extends ConsumerState<EnviarOfertaPage> {
  final _formKey = GlobalKey<FormState>();
  final _precioController = TextEditingController();
  final _mensajeController = TextEditingController();

  bool get _esMejora => widget.ofertaExistente != null;

  @override
  void initState() {
    super.initState();
    if (widget.ofertaExistente != null) {
      _precioController.text = widget.ofertaExistente!.precio.toStringAsFixed(2);
      _mensajeController.text = widget.ofertaExistente!.mensaje ?? '';
    }
  }

  @override
  void dispose() {
    _precioController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  Future<void> _enviarOferta() async {
    if (!_formKey.currentState!.validate()) return;

    final exito = await ref.read(subastasNotifierProvider.notifier).enviarOferta(
          favorId: widget.favor.id,
          precio: double.parse(_precioController.text.trim()),
          mensaje: _mensajeController.text.trim().isEmpty
              ? null
              : _mensajeController.text.trim(),
        );

    if (exito && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oferta enviada correctamente'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subastasState = ref.watch(subastasNotifierProvider);

    ref.listen(subastasNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: AppColors.error,
          ),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(title: Text(_esMejora ? 'Mejorar oferta' : 'Enviar oferta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
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
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CategoryBadge(widget.favor.categoria),
                        const Spacer(),
                        Text('El favor', style: theme.textTheme.labelMedium),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(widget.favor.titulo, style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Tu propuesta', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _precioController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Tu oferta (€)',
                  prefixIcon: Icon(Icons.euro_rounded),
                  hintText: 'Ej: 15.00',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduce un precio';
                  }
                  final precio = double.tryParse(value);
                  if (precio == null || precio <= 0) {
                    return 'Introduce un precio válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _mensajeController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Mensaje (opcional)',
                  prefixIcon: Icon(Icons.message_outlined),
                  hintText: 'Explica brevemente por qué eres la mejor opción',
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded,
                      size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: AppSpacing.xxs),
                  Expanded(
                    child: Text(
                      'En la subasta inversa, la oferta más baja suele ganar.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: subastasState.isLoading ? null : _enviarOferta,
                icon: subastasState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: Colors.white),
                      )
                    : const Icon(Icons.gavel_rounded),
                label: Text(_esMejora ? 'Mejorar oferta' : 'Enviar oferta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
