import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../favores/domain/entities/favor.dart';
import '../../../subastas/domain/entities/oferta.dart';
import '../providers/pagos_provider.dart';
import 'pago_simulado_page.dart';
import 'package:redayuda/features/chat/presentation/pages/chat_page.dart';
import 'package:redayuda/config/app_theme.dart';

class PagoPage extends ConsumerStatefulWidget {
  final Favor favor;
  final Oferta oferta;

  const PagoPage({super.key, required this.favor, required this.oferta});

  @override
  ConsumerState<PagoPage> createState() => _PagoPageState();
}

class _PagoPageState extends ConsumerState<PagoPage> {
  bool _pagando = false;
  bool _pagoCompletado = false;
  String? _pagoId;
  String? _codigoVerificacion;

  Future<void> _iniciarPago() async {
    setState(() => _pagando = true);

    final pago = await ref.read(pagosNotifierProvider.notifier).crearPago(
          favorId: widget.favor.id,
          ofertaId: widget.oferta.id,
          ayudanteId: widget.oferta.ayudanteId,
          importe: widget.oferta.precio,
        );

    if (pago == null || !mounted) {
      setState(() => _pagando = false);
      return;
    }

    setState(() => _pagoId = pago.id);

    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PagoSimuladoPage(favor: widget.favor, oferta: widget.oferta),
      ),
    );

    if (!mounted) return;

    if (resultado != true) {
      setState(() => _pagando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pago cancelado'),
          backgroundColor: AppColors.warning,
          action: SnackBarAction(label: 'Reintentar', onPressed: _iniciarPago),
        ),
      );
      return;
    }

    final exito = await ref
        .read(pagosNotifierProvider.notifier)
        .confirmarPagoSimulado(pagoId: pago.id);

    if (!mounted) return;

    if (!exito) {
      setState(() => _pagando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No se pudo confirmar el pago'),
          backgroundColor: AppColors.error,
          action: SnackBarAction(label: 'Reintentar', onPressed: _iniciarPago),
        ),
      );
      return;
    }

    final codigo = await ref
        .read(pagosNotifierProvider.notifier)
        .generarCodigoVerificacion(pagoId: pago.id);

    if (mounted) {
      setState(() {
        _pagando = false;
        _pagoCompletado = true;
        _codigoVerificacion = codigo;
      });
    }
  }

  Future<void> _liberarPago() async {
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
                'Introduce el código de verificación que te ha proporcionado el ayudante:',
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

      final pagoId = _pagoId ??
          ref.read(pagoPorFavorStreamProvider(widget.favor.id)).valueOrNull?.id;

      if (confirmar == true && pagoId != null && mounted) {
        final exito = await ref.read(pagosNotifierProvider.notifier).liberarPago(
              pagoId: pagoId,
              codigoVerificacion: codigoController.text.trim(),
            );

        if (exito && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pago liberado. ¡Favor completado!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        }
      }
    } finally {
      codigoController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pagosState = ref.watch(pagosNotifierProvider);
    final pagoPersistido =
        ref.watch(pagoPorFavorStreamProvider(widget.favor.id)).valueOrNull;

    // El pago queda 'retenido' desde que se paga hasta que se libera, sin
    // importar si el favor sigue en negociación o ya fue marcado como
    // entregado por el ayudante. Así el código de verificación sigue
    // disponible aunque se cierre y reabra esta pantalla.
    final yaPagado = pagoPersistido != null && pagoPersistido.estado == 'retenido';
    final yaLiberado = pagoPersistido != null && pagoPersistido.estado == 'liberado';
    final mostrarExito = _pagoCompletado || yaPagado || yaLiberado;
    final codigo = _codigoVerificacion ?? pagoPersistido?.codigoVerificacion ?? '------';

    return Scaffold(
      appBar: AppBar(title: const Text('Pago en garantía')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ResumenPago(favor: widget.favor, oferta: widget.oferta),
            const SizedBox(height: AppSpacing.lg),
            if (!mostrarExito) ...[
              const _InfoEscrow(),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: _pagando ? null : _iniciarPago,
                icon: _pagando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.4),
                      )
                    : const Icon(Icons.account_balance_wallet_rounded),
                label: Text(_pagando ? 'Procesando...' : 'Pagar con PayPal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.paypalBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ] else ...[
              _PagoExitoso(codigo: codigo, liberado: yaLiberado),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatPage(
                      favor: widget.favor,
                      ayudanteId: widget.oferta.ayudanteId,
                    ),
                  ),
                ),
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: const Text('Chatear con el ayudante'),
              ),
              if (!yaLiberado) ...[
                const SizedBox(height: AppSpacing.sm),
                FilledButton.icon(
                  onPressed: pagosState.isLoading ? null : _liberarPago,
                  icon: const Icon(Icons.lock_open_rounded),
                  label: const Text('Confirmar favor completado'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.success),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ResumenPago extends StatelessWidget {
  final Favor favor;
  final Oferta oferta;
  const _ResumenPago({required this.favor, required this.oferta});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final comision = oferta.precio * 0.05;
    final total = oferta.precio + comision;

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
          Text('Resumen del favor', style: theme.textTheme.titleMedium),
          const Divider(),
          _fila(theme, 'Favor', favor.titulo, bold: true),
          const SizedBox(height: AppSpacing.xs),
          _fila(theme, 'Importe oferta',
              '${oferta.precio.toStringAsFixed(2)} €'),
          const SizedBox(height: AppSpacing.xs),
          _fila(theme, 'Comisión plataforma (5%)',
              '+ ${comision.toStringAsFixed(2)} €',
              muted: true),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total a pagar', style: theme.textTheme.titleMedium),
              Text(
                '${total.toStringAsFixed(2)} €',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fila(ThemeData theme, String label, String value,
      {bool bold = false, bool muted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: muted ? theme.colorScheme.onSurfaceVariant : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoEscrow extends StatelessWidget {
  const _InfoEscrow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pago en garantía (Escrow)',
                    style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  'Tu dinero quedará retenido de forma segura hasta que confirmes '
                  'que el favor se ha completado. Solo entonces se transferirá al ayudante.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PagoExitoso extends StatelessWidget {
  final String codigo;
  final bool liberado;
  const _PagoExitoso({required this.codigo, this.liberado = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.30)),
      ),
      child: Column(
        children: [
          const Icon(Icons.verified_rounded, color: AppColors.success, size: 48),
          const SizedBox(height: AppSpacing.xs),
          Text(
            liberado ? 'Favor completado y pago liberado' : 'Pago retenido correctamente',
            style: theme.textTheme.titleMedium?.copyWith(color: AppColors.success),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            liberado
                ? 'Código de verificación utilizado:'
                : 'Comparte este código con el ayudante cuando el favor esté completado:',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
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
              style: theme.textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
