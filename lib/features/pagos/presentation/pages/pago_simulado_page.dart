import 'package:flutter/material.dart';
import '../../../favores/domain/entities/favor.dart';
import '../../../subastas/domain/entities/oferta.dart';
import 'package:redayuda/config/app_theme.dart';

/// Pantalla que sustituye temporalmente al checkout real de PayPal
/// (sandbox de PayPal bloqueado por COMPLIANCE_VIOLATION, ajeno a esta app).
/// Simula la aprobación del pago para poder seguir probando el flujo de
/// garantía (escrow) de extremo a extremo.
class PagoSimuladoPage extends StatelessWidget {
  final Favor favor;
  final Oferta oferta;

  const PagoSimuladoPage({super.key, required this.favor, required this.oferta});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = oferta.precio + oferta.precio * 0.05;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar pago')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.30)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.science_outlined, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Modo de prueba: la pasarela de PayPal no está disponible. '
                        'Esta pantalla simula la aprobación del pago.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Icon(Icons.account_balance_wallet_rounded,
                  size: 72, color: AppColors.paypalBlue),
              const SizedBox(height: AppSpacing.lg),
              Text(
                favor.titulo,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${total.toStringAsFixed(2)} €',
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall
                    ?.copyWith(fontWeight: FontWeight.w800, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 4),
              Text(
                'Incluye 5% de comisión de la plataforma',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Confirmar pago'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.paypalBlue,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
