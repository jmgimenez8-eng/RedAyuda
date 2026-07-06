import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:redayuda/config/app_theme.dart';

/// ---------------------------------------------------------------------------
/// RedAyuda · UI Kit — widgets reutilizables del sistema de diseño.
/// ---------------------------------------------------------------------------

/// Mapeo centralizado de estados (favor/oferta) a color, icono y etiqueta.
class EstadoUi {
  EstadoUi._();

  static ({Color color, IconData icon, String label}) favor(String estado) {
    switch (estado) {
      case 'activo':
        return (color: AppColors.success, icon: Icons.bolt_rounded, label: 'Activo');
      case 'en_negociacion':
        return (color: AppColors.warning, icon: Icons.handshake_outlined, label: 'En negociación');
      case 'entregado':
        return (color: AppColors.info, icon: Icons.local_shipping_outlined, label: 'Entregado');
      case 'completado':
        return (color: AppColors.info, icon: Icons.verified_outlined, label: 'Completado');
      case 'cancelado':
        return (color: AppColors.error, icon: Icons.cancel_outlined, label: 'Cancelado');
      case 'expirado':
        return (color: AppColors.textSecondary, icon: Icons.timer_off_outlined, label: 'Expirado');
      default:
        return (color: AppColors.textSecondary, icon: Icons.help_outline, label: estado);
    }
  }

  static ({Color color, IconData icon, String label}) oferta(String estado) {
    switch (estado) {
      case 'pendiente':
        return (color: AppColors.warning, icon: Icons.hourglass_bottom_rounded, label: 'Pendiente');
      case 'aceptada':
        return (color: AppColors.success, icon: Icons.check_circle_outline, label: 'Aceptada');
      case 'rechazada':
        return (color: AppColors.error, icon: Icons.cancel_outlined, label: 'Rechazada');
      case 'expirada':
        return (color: AppColors.textSecondary, icon: Icons.timer_off_outlined, label: 'Expirada');
      default:
        return (color: AppColors.textSecondary, icon: Icons.help_outline, label: estado);
    }
  }

  static IconData iconoCategoria(String categoria) {
    switch (categoria) {
      case 'Hogar':      return Icons.home_outlined;
      case 'Transporte': return Icons.directions_car_outlined;
      case 'Compras':    return Icons.shopping_bag_outlined;
      case 'Tecnología': return Icons.devices_outlined;
      case 'Mascotas':   return Icons.pets_outlined;
      case 'Mudanza':    return Icons.local_shipping_outlined;
      case 'Clases':     return Icons.school_outlined;
      default:           return Icons.more_horiz;
    }
  }
}

/// Píldora de categoría con icono y color identificativo.
class CategoryBadge extends StatelessWidget {
  final String categoria;
  final bool small;
  const CategoryBadge(this.categoria, {super.key, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.colorCategoria(categoria);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(EstadoUi.iconoCategoria(categoria), size: small ? 12 : 14, color: color),
          const SizedBox(width: 5),
          Text(
            categoria,
            style: TextStyle(
              color: color,
              fontSize: small ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Píldora de estado genérica (label + color + icono opcional).
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool small;
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = icon;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconData != null) Icon(iconData, size: small ? 12 : 14, color: color),
          if (iconData != null) const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: small ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado vacío consistente con icono, título y mensaje opcional.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        )
            .animate()
            .fadeIn(duration: AppDurations.slow)
            .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
      ),
    );
  }
}

/// Cabecera de sección con título y acción opcional a la derecha.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Caja base para skeletons (placeholder de carga).
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius = AppSpacing.radiusSm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Lista de tarjetas "fantasma" con efecto shimmer para estados de carga.
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  const SkeletonList({super.key, this.itemCount = 5, this.itemHeight = 120});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHigh,
      highlightColor: scheme.surface,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        itemBuilder: (_, _) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: SkeletonBox(height: itemHeight, radius: AppSpacing.radiusCard),
        ),
      ),
    );
  }
}

/// Panel con efecto "glass" (blur + translucidez) para zonas hero/overlays.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final double blur;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  const GlassPanel({
    super.key,
    required this.child,
    this.blur = 18,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.borderRadius = const BorderRadius.all(Radius.circular(AppSpacing.radiusLg)),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (isDark ? Colors.white : Colors.white)
                .withValues(alpha: isDark ? 0.06 : 0.55),
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.6),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Fondo decorativo con destellos de color difuminados (para pantallas hero
/// de autenticación, donde el [GlassPanel] los frostea por detrás).
class AuthBackdrop extends StatelessWidget {
  const AuthBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          left: -60,
          child: _blob(AppColors.primary.withValues(alpha: 0.35), 240),
        ),
        Positioned(
          top: 140,
          right: -70,
          child: _blob(AppColors.accent.withValues(alpha: 0.30), 200),
        ),
        Positioned(
          bottom: -60,
          left: 20,
          child: _blob(AppColors.positive.withValues(alpha: 0.22), 200),
        ),
      ],
    );
  }

  Widget _blob(Color color, double size) => ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      );
}

/// Logotipo de marca: monograma con gradiente + wordmark opcional.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;
  const AppLogo({super.key, this.size = 64, this.showWordmark = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF7048E8)],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(Icons.volunteer_activism_rounded,
          color: Colors.white, size: size * 0.52),
    );

    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: AppSpacing.sm),
        Text('RedAyuda',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800)),
      ],
    );
  }
}
