import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../favores/domain/entities/favor.dart';
import '../providers/subastas_provider.dart';
import 'enviar_oferta_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:redayuda/features/pagos/presentation/pages/pago_page.dart';
import 'package:redayuda/features/pagos/presentation/providers/pagos_provider.dart';
import 'package:redayuda/features/pagos/domain/entities/pago.dart';
import 'package:redayuda/features/favores/presentation/providers/favores_provider.dart';
import 'package:redayuda/features/chat/presentation/providers/chat_provider.dart';
import 'package:redayuda/features/subastas/domain/entities/oferta.dart';
import 'package:redayuda/features/chat/presentation/pages/chat_page.dart';
import 'package:redayuda/config/app_theme.dart';
import 'package:redayuda/shared/widgets/ui_kit.dart';

class DetalleFavorPage extends ConsumerStatefulWidget {
  final Favor favor;

  const DetalleFavorPage({super.key, required this.favor});

  @override
  ConsumerState<DetalleFavorPage> createState() => _DetalleFavorPageState();
}

class _DetalleFavorPageState extends ConsumerState<DetalleFavorPage> {
  final String? _currentUserId = Supabase.instance.client.auth.currentUser?.id;

  bool get _esSolicitante => _currentUserId == widget.favor.solicitanteId;

  bool get _chatDisponible =>
      widget.favor.estado == 'activo' ||
      widget.favor.estado == 'en_negociacion' ||
      widget.favor.estado == 'completado';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(subastasNotifierProvider.notifier)
          .cargarOfertasPorFavor(favorId: widget.favor.id);
    });
  }

  String _obtenerAyudanteId(List<Oferta> ofertas) {
    try {
      final ofertaAceptada = ofertas.firstWhere((o) => o.estado == 'aceptada');
      return ofertaAceptada.ayudanteId;
    } catch (_) {
      return _esSolicitante ? '' : _currentUserId ?? '';
    }
  }

  void _navegarAlChat(BuildContext context, List<Oferta> ofertas) {
    final ayudanteId =
        _esSolicitante ? _obtenerAyudanteId(ofertas) : _currentUserId ?? '';

    if (ayudanteId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró el ayudante'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(favor: widget.favor, ayudanteId: ayudanteId),
      ),
    );
  }

  bool _tieneAccesoChat(List<Oferta> ofertas) {
    if (_esSolicitante) {
      return ofertas.any((o) => o.estado == 'aceptada');
    } else {
      return ofertas.any((o) =>
          o.ayudanteId == _currentUserId &&
          (o.estado == 'aceptada' || o.estado == 'pendiente'));
    }
  }

  Future<void> _aceptarOferta(Oferta oferta) async {
    final exito = await ref.read(subastasNotifierProvider.notifier).aceptarOferta(
          ofertaId: oferta.id,
          favorId: widget.favor.id,
        );
    if (exito && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PagoPage(favor: widget.favor, oferta: oferta),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ofertasStream = ref.watch(
      ofertasPorFavorStreamProvider(
        (widget.favor.id, widget.favor.solicitanteId),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del favor'),
        actions: [
          if (_chatDisponible)
            ofertasStream.when(
              data: (ofertas) {
                if (!_tieneAccesoChat(ofertas)) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  tooltip: 'Chat',
                  onPressed: () => _navegarAlChat(context, ofertas),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderFavor(favor: widget.favor)
                .animate()
                .fadeIn(duration: AppDurations.base)
                .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
            const SizedBox(height: AppSpacing.lg),
            ofertasStream.when(
              data: (ofertas) => SectionHeader(
                _esSolicitante
                    ? 'Ofertas recibidas (${ofertas.length})'
                    : 'Tu oferta',
              ),
              loading: () => SectionHeader(
                  _esSolicitante ? 'Ofertas recibidas' : 'Tu oferta'),
              error: (_, _) => const SectionHeader('Ofertas'),
            ),
            ofertasStream.when(
              loading: () => const SkeletonList(itemCount: 3, itemHeight: 84),
              error: (error, _) => Text('Error al cargar ofertas: $error',
                  style: theme.textTheme.bodyMedium),
              data: (ofertas) {
                if (ofertas.isEmpty) {
                  return _CardVacia(
                    texto: _esSolicitante
                        ? 'Aún no hay ofertas para este favor'
                        : 'Aún no has enviado ninguna oferta',
                  );
                }

                Oferta? ofertaAceptada;
                try {
                  ofertaAceptada =
                      ofertas.firstWhere((o) => o.estado == 'aceptada');
                } catch (_) {
                  ofertaAceptada = null;
                }

                return Column(
                  children: [
                    ...List.generate(ofertas.length, (index) {
                      final oferta = ofertas[index];
                      final esMejorOferta = _esSolicitante && index == 0;
                      final puedeAceptar = _esSolicitante &&
                          oferta.estado == 'pendiente' &&
                          widget.favor.estado == 'activo';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _OfertaTile(
                          oferta: oferta,
                          ranking: index + 1,
                          esMejorOferta: esMejorOferta,
                          esSolicitante: _esSolicitante,
                          onAceptar:
                              puedeAceptar ? () => _aceptarOferta(oferta) : null,
                        ),
                      )
                          .animate()
                          .fadeIn(
                              duration: AppDurations.base,
                              delay: (index.clamp(0, 8) * 50).ms)
                          .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
                    }),
                    if (ofertaAceptada != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _SeccionEscrow(
                        favor: widget.favor,
                        ofertaAceptada: ofertaAceptada,
                        esSolicitante: _esSolicitante,
                        currentUserId: _currentUserId ?? '',
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
      floatingActionButton:
          widget.favor.estado == 'activo' && !_esSolicitante
              ? FloatingActionButton.extended(
                  onPressed: () {
                    final ofertasActuales =
                        ref.read(subastasNotifierProvider).value ?? [];
                    Oferta? ofertaExistente;
                    try {
                      ofertaExistente = ofertasActuales
                          .firstWhere((o) => o.ayudanteId == _currentUserId);
                    } catch (_) {
                      ofertaExistente = null;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EnviarOfertaPage(
                          favor: widget.favor,
                          ofertaExistente: ofertaExistente,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.gavel_rounded),
                  label: const Text('Enviar oferta'),
                )
              : null,
    );
  }
}

class _HeaderFavor extends StatelessWidget {
  final Favor favor;
  const _HeaderFavor({required this.favor});

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
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CategoryBadge(favor.categoria),
              const Spacer(),
              StatusBadge(label: estado.label, color: estado.color, icon: estado.icon),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(favor.titulo, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            favor.descripcion,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.schedule_rounded,
                  size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xxs),
              Flexible(
                child: Text(
                  favor.expiresAt != null
                      ? 'Expira ${timeago.format(favor.expiresAt!, locale: 'es', allowFromNow: true)}'
                      : 'Sin caducidad',
                  style: theme.textTheme.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Icon(Icons.place_outlined,
                  size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xxs),
              Text('${favor.radioKm.toStringAsFixed(0)} km',
                  style: theme.textTheme.labelMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _OfertaTile extends StatelessWidget {
  final Oferta oferta;
  final int ranking;
  final bool esMejorOferta;
  final bool esSolicitante;
  final VoidCallback? onAceptar;

  const _OfertaTile({
    required this.oferta,
    required this.ranking,
    required this.esMejorOferta,
    required this.esSolicitante,
    this.onAceptar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estado = EstadoUi.oferta(oferta.estado);

    return Container(
      decoration: BoxDecoration(
        color: esMejorOferta
            ? theme.colorScheme.primary.withValues(alpha: 0.06)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(
          color: esMejorOferta
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : theme.colorScheme.outline,
          width: esMejorOferta ? 1.5 : 1,
        ),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: esMejorOferta
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            child: Text(
              esSolicitante ? '$ranking' : '€',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: esMejorOferta
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xxs,
                  children: [
                    Text(
                      '${oferta.precio.toStringAsFixed(2)} €',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: esMejorOferta ? theme.colorScheme.primary : null,
                      ),
                    ),
                    // "Mejor oferta" solo aporta mientras la subasta sigue
                    // abierta; una vez aceptada, el badge de estado ya lo indica.
                    if (esMejorOferta && oferta.estado == 'pendiente')
                      const StatusBadge(
                        label: 'Mejor oferta',
                        color: AppColors.primary,
                        icon: Icons.workspace_premium_rounded,
                        small: true,
                      ),
                  ],
                ),
                if (oferta.mensaje != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    oferta.mensaje!,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          if (onAceptar != null)
            FilledButton(onPressed: onAceptar, child: const Text('Aceptar'))
          else
            StatusBadge(label: estado.label, color: estado.color, small: true),
        ],
      ),
    );
  }
}

/// Sección de pago en garantía (escrow) que aparece en el detalle del favor
/// una vez que una oferta ha sido aceptada. Muestra una vista distinta para
/// el solicitante (código + liberar pago) y para el ayudante aceptado
/// (estado del pago + marcar como completado).
class _SeccionEscrow extends ConsumerStatefulWidget {
  final Favor favor;
  final Oferta ofertaAceptada;
  final bool esSolicitante;
  final String currentUserId;

  const _SeccionEscrow({
    required this.favor,
    required this.ofertaAceptada,
    required this.esSolicitante,
    required this.currentUserId,
  });

  @override
  ConsumerState<_SeccionEscrow> createState() => _SeccionEscrowState();
}

class _SeccionEscrowState extends ConsumerState<_SeccionEscrow> {
  Future<void> _liberarPago(String pagoId) async {
    final codigoController = TextEditingController();
    try {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar favor completado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Introduce el código de verificación para liberar el pago al ayudante:',
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: codigoController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(labelText: 'Código de 6 dígitos'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );

      if (confirmar == true && mounted) {
        final exito = await ref.read(pagosNotifierProvider.notifier).liberarPago(
              pagoId: pagoId,
              codigoVerificacion: codigoController.text.trim(),
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(exito
                  ? 'Pago liberado. ¡Favor completado!'
                  : 'Código incorrecto'),
              backgroundColor: exito ? AppColors.success : AppColors.error,
            ),
          );
        }
      }
    } finally {
      codigoController.dispose();
    }
  }

  Future<void> _marcarEntregado() async {
    final resultado =
        await ref.read(marcarFavorEntregadoProvider).call(id: widget.favor.id);
    final exito = resultado.fold((_) => false, (_) => true);

    if (!exito) {
      if (mounted) {
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
          favorId: widget.favor.id,
          contenido:
              '✅ He completado este favor. Confirma la entrega para liberar el pago.',
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favor marcado como entregado. Se avisó al solicitante.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final esAyudanteAceptado =
        widget.currentUserId == widget.ofertaAceptada.ayudanteId;

    // Solo el solicitante o el ayudante de la oferta aceptada ven esta sección.
    if (!widget.esSolicitante && !esAyudanteAceptado) {
      return const SizedBox.shrink();
    }

    final pago =
        ref.watch(pagoPorFavorStreamProvider(widget.favor.id)).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Pago en garantía'),
        _CardEscrow(
          child: widget.esSolicitante
              ? _vistaSolicitante(context, pago)
              : _vistaAyudante(context, pago),
        ),
      ],
    );
  }

  Widget _vistaSolicitante(BuildContext context, Pago? pago) {
    final theme = Theme.of(context);
    final precio = widget.ofertaAceptada.precio;
    final total = precio + precio * 0.05;

    if (pago == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _resumenImporte(theme, precio, total),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Has aceptado esta oferta. Realiza el pago para retener el importe '
            'en garantía y continuar.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PagoPage(
                    favor: widget.favor,
                    oferta: widget.ofertaAceptada,
                  ),
                ),
              ),
              icon: const Icon(Icons.account_balance_wallet_rounded),
              label: const Text('Realizar pago'),
            ),
          ),
        ],
      );
    }

    if (pago.estado == 'liberado') {
      return _bloqueLiberado(theme, precio, total);
    }

    // pago retenido
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _resumenImporte(theme, precio, total),
        const SizedBox(height: AppSpacing.md),
        _EstadoLinea(
          icon: Icons.shield_outlined,
          color: AppColors.success,
          texto: 'Pago retenido en garantía',
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Comparte este código con el ayudante e introdúcelo al confirmar '
          'que el favor está completado:',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.sm),
        _CodigoBox(codigo: pago.codigoVerificacion ?? '------'),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _liberarPago(pago.id),
            icon: const Icon(Icons.lock_open_rounded),
            label: const Text('Confirmar y liberar pago'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
          ),
        ),
      ],
    );
  }

  Widget _vistaAyudante(BuildContext context, Pago? pago) {
    final theme = Theme.of(context);
    final precio = widget.ofertaAceptada.precio;
    final total = precio + precio * 0.05;

    // La vista del ayudante se guía por el estado del favor (que siempre puede
    // leer), no por la visibilidad de la fila de pago, que la RLS podría
    // restringir solo al solicitante.
    if (pago?.estado == 'liberado' || widget.favor.estado == 'completado') {
      return _bloqueLiberado(theme, precio, total);
    }

    final yaEntregado = widget.favor.estado == 'entregado';
    final pagoRetenido = pago?.estado == 'retenido';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _resumenImporte(theme, precio, total),
        const SizedBox(height: AppSpacing.md),
        _EstadoLinea(
          icon: pagoRetenido ? Icons.shield_outlined : Icons.hourglass_bottom_rounded,
          color: pagoRetenido ? AppColors.success : AppColors.warning,
          texto: pagoRetenido
              ? 'El solicitante ya ha pagado. El importe está retenido en garantía.'
              : 'Tu oferta fue aceptada. Coordina con el solicitante y realiza el favor.',
        ),
        const SizedBox(height: AppSpacing.md),
        if (yaEntregado)
          _EstadoLinea(
            icon: Icons.local_shipping_outlined,
            color: AppColors.info,
            texto:
                'Has marcado el favor como entregado. Esperando la confirmación del solicitante.',
          )
        else
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _marcarEntregado,
              icon: const Icon(Icons.task_alt_rounded),
              label: const Text('He completado el favor'),
            ),
          ),
      ],
    );
  }

  Widget _bloqueLiberado(ThemeData theme, double precio, double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _resumenImporte(theme, precio, total),
        const SizedBox(height: AppSpacing.md),
        _EstadoLinea(
          icon: Icons.verified_rounded,
          color: AppColors.success,
          texto: 'Favor completado. El pago se ha liberado al ayudante.',
        ),
      ],
    );
  }

  Widget _resumenImporte(ThemeData theme, double precio, double total) {
    return Column(
      children: [
        _filaImporte(theme, 'Importe de la oferta',
            '${precio.toStringAsFixed(2)} €'),
        const SizedBox(height: AppSpacing.xxs),
        _filaImporte(theme, 'Comisión plataforma (5%)',
            '+ ${(precio * 0.05).toStringAsFixed(2)} €',
            muted: true),
        const Divider(),
        _filaImporte(theme, 'Total', '${total.toStringAsFixed(2)} €', bold: true),
      ],
    );
  }

  Widget _filaImporte(ThemeData theme, String label, String value,
      {bool bold = false, bool muted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(label,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: muted ? theme.colorScheme.onSurfaceVariant : null)),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(value,
            style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                color: bold ? theme.colorScheme.primary : null)),
      ],
    );
  }
}

class _CardEscrow extends StatelessWidget {
  final Widget child;
  const _CardEscrow({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }
}

class _EstadoLinea extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String texto;
  const _EstadoLinea(
      {required this.icon, required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(texto,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600, color: color)),
        ),
      ],
    );
  }
}

class _CodigoBox extends StatelessWidget {
  final String codigo;
  const _CodigoBox({required this.codigo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF7048E8)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Text(
        codigo,
        style: theme.textTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 8,
        ),
      ),
    );
  }
}

class _CardVacia extends StatelessWidget {
  final String texto;
  const _CardVacia({required this.texto});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Icon(Icons.inbox_outlined, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(texto,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}
