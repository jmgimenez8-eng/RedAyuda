import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:redayuda/config/app_theme.dart';
import 'package:redayuda/shared/widgets/ui_kit.dart';
import '../../domain/entities/favor.dart';

/// Tarjeta reutilizable para mostrar un [Favor] en listados (explorar, etc.).
class FavorCard extends StatelessWidget {
  final Favor favor;
  final VoidCallback onTap;
  final bool mostrarEstado;
  final Widget? trailing;

  const FavorCard({
    super.key,
    required this.favor,
    required this.onTap,
    this.mostrarEstado = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estado = EstadoUi.favor(favor.estado);

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
                    CategoryBadge(favor.categoria),
                    const Spacer(),
                    if (mostrarEstado)
                      StatusBadge(
                        label: estado.label,
                        color: estado.color,
                        icon: estado.icon,
                        small: true,
                      )
                    else
                      _MetaChip(
                        icon: Icons.schedule_rounded,
                        label: favor.expiresAt != null
                            ? timeago.format(favor.expiresAt!, locale: 'es', allowFromNow: true)
                            : 'Sin caducidad',
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  favor.titulo,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  favor.descripcion,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(Icons.place_outlined,
                        size: 15, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${favor.radioKm.toStringAsFixed(0)} km',
                      style: theme.textTheme.labelMedium,
                    ),
                    const Spacer(),
                    if (trailing != null)
                      trailing!
                    else
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: theme.colorScheme.onSurfaceVariant),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }
}
