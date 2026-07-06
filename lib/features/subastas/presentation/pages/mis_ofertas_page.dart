import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/subastas_provider.dart';
import 'package:redayuda/features/subastas/domain/entities/oferta.dart';
import 'package:redayuda/features/subastas/presentation/pages/detalle_favor_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:redayuda/features/favores/data/models/favor_model.dart';
import 'package:redayuda/features/chat/presentation/pages/chat_page.dart';
import 'package:redayuda/features/chat/presentation/providers/chat_provider.dart';
import 'package:redayuda/features/favores/presentation/providers/favores_provider.dart';
import 'package:redayuda/features/valoraciones/presentation/pages/valoracion_page.dart';
import 'package:redayuda/config/app_theme.dart';
import 'package:redayuda/shared/widgets/ui_kit.dart';

class MisOfertasPage extends ConsumerStatefulWidget {
  /// Cuando es `true` se renderiza sin Scaffold/AppBar (incrustado en "Actividad").
  final bool embedded;
  const MisOfertasPage({super.key, this.embedded = false});

  @override
  ConsumerState<MisOfertasPage> createState() => _MisOfertasPageState();
}

class _MisOfertasPageState extends ConsumerState<MisOfertasPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subastasNotifierProvider.notifier).cargarMisOfertas();
    });
  }

  Future<void> _refrescar() =>
      ref.read(subastasNotifierProvider.notifier).cargarMisOfertas();

  Future<void> _abrirFavor(BuildContext context, String favorId) async {
    try {
      final favorData = await Supabase.instance.client
          .from('favores')
          .select()
          .eq('id', favorId)
          .single();
      if (context.mounted) {
        final favor = FavorModel.fromJson(favorData);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetalleFavorPage(favor: favor)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar el favor: $e')),
        );
      }
    }
  }

  Future<void> _navegarAlChat(BuildContext context, String favorId) async {
    try {
      final favorData = await Supabase.instance.client
          .from('favores')
          .select()
          .eq('id', favorId)
          .single();
      if (context.mounted) {
        final favor = FavorModel.fromJson(favorData);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              favor: favor,
              ayudanteId: Supabase.instance.client.auth.currentUser?.id ?? '',
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

  Future<void> _navegarAValorar(BuildContext context, String favorId) async {
    try {
      final favorData = await Supabase.instance.client
          .from('favores')
          .select()
          .eq('id', favorId)
          .eq('estado', 'completado')
          .maybeSingle();

      if (favorData == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Solo puedes valorar cuando el favor esté completado'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      // Como ayudante valoras al solicitante (nunca a ti mismo).
      final solicitanteId = favorData['solicitante_id'] as String;
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (solicitanteId == currentUserId) {
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

      final solicitanteData = await Supabase.instance.client
          .from('usuarios')
          .select('nombre')
          .eq('id', solicitanteId)
          .maybeSingle();

      if (context.mounted) {
        final favor = FavorModel.fromJson(favorData);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ValoracionPage(
              favor: favor,
              valoradoId: solicitanteId,
              valoradoNombre: solicitanteData?['nombre'] as String? ?? 'Solicitante',
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

  Future<void> _marcarEntregado(BuildContext context, Oferta oferta) async {
    try {
      final favorData = await Supabase.instance.client
          .from('favores')
          .select()
          .eq('id', oferta.favorId)
          .eq('estado', 'en_negociacion')
          .maybeSingle();

      if (favorData == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Este favor ya no está en negociación'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      final resultado = await ref
          .read(marcarFavorEntregadoProvider)
          .call(id: oferta.favorId);

      final exito = resultado.fold((_) => false, (_) => true);
      if (!exito) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo marcar el favor como entregado'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      await ref.read(enviarMensajeProvider).call(
            favorId: oferta.favorId,
            contenido:
                '✅ He completado este favor. Confirma la entrega para liberar el pago.',
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favor marcado como entregado. Se avisó al solicitante.'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() {});
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
      appBar: AppBar(
        title: const Text('Mis ofertas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refrescar,
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildBody(BuildContext context) {
    final ofertasState = ref.watch(subastasNotifierProvider);

    return ofertasState.when(
      loading: () => const SkeletonList(itemHeight: 150),
      error: (_, _) => EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'No se pudieron cargar tus ofertas',
        message: 'Comprueba tu conexión e inténtalo de nuevo.',
        action: FilledButton.icon(
          onPressed: _refrescar,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Reintentar'),
        ),
      ),
      data: (ofertas) {
        if (ofertas.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refrescar,
            child: CustomScrollView(
              slivers: const [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.gavel_rounded,
                    title: 'Aún no has enviado ofertas',
                    message: 'Explora los favores disponibles y envía tu primera oferta.',
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
            itemCount: ofertas.length,
            itemBuilder: (context, index) {
              final oferta = ofertas[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _TarjetaOferta(
                  oferta: oferta,
                  onTap: () => _abrirFavor(context, oferta.favorId),
                  onChatTap: (oferta.estado == 'pendiente' || oferta.estado == 'aceptada')
                      ? () => _navegarAlChat(context, oferta.favorId)
                      : null,
                  onEntregarTap: oferta.estado == 'aceptada'
                      ? () => _marcarEntregado(context, oferta)
                      : null,
                  onValorarTap: oferta.estado == 'aceptada'
                      ? () => _navegarAValorar(context, oferta.favorId)
                      : null,
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

class _TarjetaOferta extends StatelessWidget {
  final Oferta oferta;
  final VoidCallback onTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onEntregarTap;
  final VoidCallback? onValorarTap;

  const _TarjetaOferta({
    required this.oferta,
    required this.onTap,
    this.onChatTap,
    this.onEntregarTap,
    this.onValorarTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estado = EstadoUi.oferta(oferta.estado);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatusBadge(label: estado.label, color: estado.color, icon: estado.icon),
                    const Spacer(),
                    Text(
                      timeago.format(oferta.createdAt, locale: 'es'),
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${oferta.precio.toStringAsFixed(2)} €',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text('tu oferta', style: theme.textTheme.labelMedium),
                  ],
                ),
                if (oferta.mensaje != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    oferta.mensaje!,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (oferta.estado == 'aceptada' || oferta.estado == 'pendiente') ...[
                  const SizedBox(height: AppSpacing.sm),
                  _Banner(
                    color: estado.color,
                    icon: oferta.estado == 'aceptada'
                        ? Icons.celebration_rounded
                        : Icons.hourglass_bottom_rounded,
                    text: oferta.estado == 'aceptada'
                        ? '¡Tu oferta fue aceptada! Coordina con el solicitante.'
                        : 'Tu oferta está pendiente de aceptación.',
                  ),
                ],
                if (onChatTap != null || onEntregarTap != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      if (onChatTap != null)
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: onChatTap,
                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                            label: const Text('Ir al chat'),
                          ),
                        ),
                      if (onChatTap != null && onEntregarTap != null)
                        const SizedBox(width: AppSpacing.xs),
                      if (onEntregarTap != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onEntregarTap,
                            icon: const Icon(Icons.task_alt_rounded, size: 18),
                            label: const Text('Completado'),
                          ),
                        ),
                    ],
                  ),
                ],
                if (onValorarTap != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onValorarTap,
                      icon: const Icon(Icons.star_outline_rounded, size: 18),
                      label: const Text('Valorar'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  const _Banner({required this.color, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
