import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/favores_provider.dart';
import '../../domain/entities/favor.dart';
import '../widgets/favor_card.dart';
import 'package:redayuda/features/subastas/presentation/pages/detalle_favor_page.dart';
import 'package:redayuda/features/valoraciones/presentation/pages/valoracion_page.dart';
import 'package:redayuda/config/app_theme.dart';
import 'package:redayuda/shared/widgets/ui_kit.dart';

class MisFavoresPage extends ConsumerStatefulWidget {
  /// Cuando es `true` se renderiza sin Scaffold/AppBar (para incrustarlo en
  /// la pantalla "Actividad").
  final bool embedded;
  const MisFavoresPage({super.key, this.embedded = false});

  @override
  ConsumerState<MisFavoresPage> createState() => _MisFavoresPageState();
}

class _MisFavoresPageState extends ConsumerState<MisFavoresPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoresNotifierProvider.notifier).cargarMisFavores();
    });
  }

  Future<void> _refrescar() =>
      ref.read(favoresNotifierProvider.notifier).cargarMisFavores();

  Future<void> _confirmarCancelar(BuildContext context, Favor favor) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
        title: const Text('Cancelar favor'),
        content: Text('¿Seguro que quieres cancelar "${favor.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      await ref.read(favoresNotifierProvider.notifier).cancelarFavor(id: favor.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Favor cancelado')),
        );
      }
    }
  }

  Future<void> _navegarAValorar(BuildContext context, Favor favor) async {
    try {
      final oferta = await Supabase.instance.client
          .from('ofertas')
          .select('ayudante_id, usuarios(nombre)')
          .eq('favor_id', favor.id)
          .eq('estado', 'aceptada')
          .maybeSingle();

      if (oferta == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se encontró la oferta aceptada de este favor'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      // Como solicitante valoras al ayudante (nunca a ti mismo).
      final ayudanteId = oferta['ayudante_id'] as String;
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (ayudanteId == currentUserId) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No puedes valorarte a ti mismo'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ValoracionPage(
              favor: favor,
              valoradoId: ayudanteId,
              valoradoNombre:
                  (oferta['usuarios'] as Map?)?['nombre'] as String? ?? 'Ayudante',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody(context);
    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Mis favores')),
      body: body,
    );
  }

  Widget _buildBody(BuildContext context) {
    final favoresState = ref.watch(favoresNotifierProvider);

    return favoresState.when(
      loading: () => const SkeletonList(),
      error: (_, _) => EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'No se pudieron cargar tus favores',
        message: 'Comprueba tu conexión e inténtalo de nuevo.',
        action: FilledButton.icon(
          onPressed: _refrescar,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Reintentar'),
        ),
      ),
      data: (favores) {
        if (favores.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refrescar,
            child: CustomScrollView(
              slivers: const [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'No tienes favores publicados',
                    message: 'Cuando publiques un favor aparecerá aquí.',
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refrescar,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: favores.length,
            itemBuilder: (context, index) {
              final favor = favores[index];
              Widget? trailing;
              if (favor.estado == 'activo') {
                trailing = IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  tooltip: 'Cancelar',
                  onPressed: () => _confirmarCancelar(context, favor),
                );
              } else if (favor.estado == 'completado') {
                trailing = IconButton(
                  icon: const Icon(Icons.star_rounded, color: AppColors.amber),
                  tooltip: 'Valorar',
                  onPressed: () => _navegarAValorar(context, favor),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: FavorCard(
                  favor: favor,
                  mostrarEstado: true,
                  trailing: trailing,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalleFavorPage(favor: favor),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: AppDurations.base, delay: (index.clamp(0, 8) * 40).ms)
                  .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
            },
          ),
        );
      },
    );
  }
}
