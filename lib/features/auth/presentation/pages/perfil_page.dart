import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import 'package:redayuda/features/valoraciones/presentation/providers/valoraciones_provider.dart';
import 'package:redayuda/config/app_theme.dart';
import 'package:redayuda/shared/widgets/ui_kit.dart';

class PerfilPage extends ConsumerStatefulWidget {
  const PerfilPage({super.key});

  @override
  ConsumerState<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends ConsumerState<PerfilPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  bool _editando = false;
  bool _cargando = true;
  Map<String, dynamic>? _perfil;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        ref
            .read(valoracionesNotifierProvider.notifier)
            .cargarValoraciones(usuarioId: userId);
      }
    });
  }

  Future<void> _cargarPerfil() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final data = await Supabase.instance.client
          .from('usuarios')
          .select()
          .eq('id', userId)
          .single();

      setState(() {
        _perfil = data;
        _nombreController.text = data['nombre'] ?? '';
        _telefonoController.text = data['telefono'] ?? '';
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      await Supabase.instance.client.from('usuarios').update({
        'nombre': _nombreController.text.trim(),
        'telefono': _telefonoController.text.trim(),
      }).eq('id', userId);

      setState(() {
        _editando = false;
        _perfil?['nombre'] = _nombreController.text.trim();
        _perfil?['telefono'] = _telefonoController.text.trim();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _confirmarEliminarCuenta() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: AppColors.error),
        title: const Text('Eliminar cuenta'),
        content: const Text(
          '¿Seguro que quieres eliminar tu cuenta? Esta acción no se puede '
          'deshacer y todos tus datos serán eliminados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) return;

        await Supabase.instance.client
            .from('usuarios')
            .update({'estado': 'eliminado'}).eq('id', userId);

        await ref.read(authNotifierProvider.notifier).cerrarSesion();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cuenta eliminada correctamente'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar la cuenta: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final nombre = _perfil?['nombre'] as String? ?? '';
    final inicial = nombre.isEmpty ? 'U' : nombre[0].toUpperCase();
    final email = _perfil?['email'] as String? ?? '';
    final reputacion =
        (_perfil?['reputacion'] as num?)?.toStringAsFixed(1) ?? '5.0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        actions: [
          IconButton(
            icon: Icon(_editando ? Icons.close_rounded : Icons.edit_outlined),
            tooltip: _editando ? 'Cancelar' : 'Editar',
            onPressed: () => setState(() => _editando = !_editando),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CabeceraPerfil(
                inicial: inicial,
                nombre: nombre.isEmpty ? 'Usuario' : nombre,
                email: email,
                reputacion: reputacion,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _nombreController,
                enabled: _editando,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _telefonoController,
                enabled: _editando,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 9) {
                    return 'Teléfono no válido (mínimo 9 dígitos)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                initialValue: _perfil?['rol'] as String? ?? 'solicitante',
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              if (_editando) ...[
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: _guardarCambios,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar cambios'),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader('Valoraciones recibidas'),
              const _SeccionValoraciones(),
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.xs),
              ListTile(
                leading:
                    const Icon(Icons.logout_rounded, color: AppColors.warning),
                title: Text('Cerrar sesión', style: theme.textTheme.bodyLarge),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  await ref.read(authNotifierProvider.notifier).cerrarSesion();
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                title: Text(
                  'Eliminar cuenta',
                  style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.error),
                ),
                onTap: _confirmarEliminarCuenta,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _CabeceraPerfil extends StatelessWidget {
  final String inicial;
  final String nombre;
  final String email;
  final String reputacion;

  const _CabeceraPerfil({
    required this.inicial,
    required this.nombre,
    required this.email,
    required this.reputacion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF7048E8)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white.withValues(alpha: 0.22),
            child: Text(
              inicial,
              style: theme.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            nombre,
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              email,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: AppColors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$reputacion de reputación',
                  style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeccionValoraciones extends ConsumerWidget {
  const _SeccionValoraciones();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final valoracionesState = ref.watch(valoracionesNotifierProvider);

    return valoracionesState.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (valoraciones) {
        if (valoraciones.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Row(
              children: [
                Icon(Icons.star_outline_rounded,
                    color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('Aún no tienes valoraciones',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: valoraciones.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final valoracion = valoraciones[index];
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < valoracion.puntuacion
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: AppColors.amber,
                            size: 18,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        valoracion.createdAt.toLocal().toString().substring(0, 10),
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                  if (valoracion.comentario != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(valoracion.comentario!, style: theme.textTheme.bodyMedium),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
