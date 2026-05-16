import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import '../../../favores/domain/entities/favor.dart';
import '../../../subastas/domain/entities/oferta.dart';
import '../providers/pagos_provider.dart';
import 'package:redayuda/features/chat/presentation/pages/chat_page.dart';

class PagoPage extends ConsumerStatefulWidget {
  final Favor favor;
  final Oferta oferta;

  const PagoPage({
    super.key,
    required this.favor,
    required this.oferta,
  });

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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaypalCheckoutView(
          sandboxMode: true,
          clientId: 'tu_paypal_client_id_aqui',
          secretKey: 'tu_paypal_secret_key_aqui',
          transactions: [
            {
              'amount': {
                'total': widget.oferta.precio.toStringAsFixed(2),
                'currency': 'EUR',
                'details': {
                  'subtotal': widget.oferta.precio.toStringAsFixed(2),
                  'shipping': '0',
                  'shipping_discount': 0,
                },
              },
              'description': widget.favor.titulo,
              'item_list': {
                'items': [
                  {
                    'name': widget.favor.titulo,
                    'quantity': 1,
                    'price': widget.oferta.precio.toStringAsFixed(2),
                    'currency': 'EUR',
                  },
                ],
              },
            },
          ],
          note: 'Pago en garantía REDAYUDA',
          onSuccess: (params) async {
            final orderId = params['orderID'] as String? ?? '';
            final captureId = params['paymentId'] as String? ?? '';

            await ref.read(pagosNotifierProvider.notifier).confirmarPago(
              pagoId: pago.id,
              paypalOrderId: orderId,
              paypalCaptureId: captureId,
            );

            final codigo = await ref
                .read(pagosNotifierProvider.notifier)
                .generarCodigoVerificacion(pagoId: pago.id);

            if (mounted) {
              setState(() {
                _pagando = false;
                _pagoCompletado = true;
                _codigoVerificacion = codigo;
              });
              Navigator.pop(context);
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() => _pagando = false);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error en el pago: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          onCancel: () {
            if (mounted) {
              setState(() => _pagando = false);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pago cancelado'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _liberarPago() async {
    final codigoController = TextEditingController();

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
            const SizedBox(height: 16),
            TextField(
              controller: codigoController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Código de 6 dígitos',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar == true && _pagoId != null && mounted) {
      final exito = await ref.read(pagosNotifierProvider.notifier).liberarPago(
        pagoId: _pagoId!,
        codigoVerificacion: codigoController.text.trim(),
      );

      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pago liberado. ¡Favor completado!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pagosState = ref.watch(pagosNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago en garantía'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen del favor',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Favor'),
                        Flexible(
                          child: Text(
                            widget.favor.titulo,
                            textAlign: TextAlign.right,
                            style:
                            const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Importe oferta'),
                        Text(
                          '${widget.oferta.precio.toStringAsFixed(2)} €',
                          style:
                          const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Comisión plataforma (5%)'),
                        Text(
                          '${(widget.oferta.precio * 0.05).toStringAsFixed(2)} €',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total a pagar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${widget.oferta.precio.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!_pagoCompletado) ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.security, color: Color(0xFF6C63FF)),
                          SizedBox(width: 8),
                          Text(
                            'Pago en garantía (Escrow)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tu dinero quedará retenido de forma segura hasta que '
                            'confirmes que el favor se ha completado satisfactoriamente. '
                            'Solo entonces se transferirá al ayudante.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _pagando ? null : _iniciarPago,
                icon: _pagando
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.payment),
                label: Text(
                  _pagando ? 'Procesando...' : 'Pagar con PayPal',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF003087),
                  foregroundColor: Colors.white,
                ),
              ),
            ] else ...[
              Card(
                color: Colors.green.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pago retenido correctamente',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Comparte este código con el ayudante cuando el favor esté completado:',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _codigoVerificacion ?? '------',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                icon: const Icon(Icons.chat_outlined),
                label: const Text(
                  'Chatear con el ayudante',
                  style: TextStyle(fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF6C63FF)),
                  foregroundColor: const Color(0xFF6C63FF),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: pagosState.isLoading ? null : _liberarPago,
                icon: const Icon(Icons.lock_open),
                label: const Text(
                  'Confirmar favor completado',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}