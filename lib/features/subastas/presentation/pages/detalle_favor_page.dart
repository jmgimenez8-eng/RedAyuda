import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../favores/domain/entities/favor.dart';
import '../providers/subastas_provider.dart';
import 'enviar_oferta_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:redayuda/features/pagos/presentation/pages/pago_page.dart';
import 'package:redayuda/features/subastas/domain/entities/oferta.dart';

class DetalleFavorPage extends ConsumerStatefulWidget {
  final Favor favor;

  const DetalleFavorPage({super.key, required this.favor});

  @override
  ConsumerState<DetalleFavorPage> createState() => _DetalleFavorPageState();
}

class _DetalleFavorPageState extends ConsumerState<DetalleFavorPage> {
  final String? _currentUserId =
      Supabase.instance.client.auth.currentUser?.id;

  bool get _esSolicitante =>
      _currentUserId == widget.favor.solicitanteId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(subastasNotifierProvider.notifier)
          .cargarOfertasPorFavor(favorId: widget.favor.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ofertasStream = ref.watch(
      ofertasPorFavorStreamProvider((
      widget.favor.id,
      widget.favor.solicitanteId,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del favor'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.favor.categoria,
                            style: const TextStyle(
                              color: Color(0xFF6C63FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.favor.estado,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.favor.titulo,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.favor.descripcion,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          widget.favor.expiresAt != null
                              ? 'Expira ${timeago.format(widget.favor.expiresAt!, locale: 'es')}'
                              : 'Sin expiración',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _esSolicitante
                  ? 'Ofertas recibidas'
                  : 'Tu oferta',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ofertasStream.when(
              data: (ofertas) => ofertas.isEmpty
                  ? Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      _esSolicitante
                          ? 'Aún no hay ofertas para este favor'
                          : 'Aún no has enviado ninguna oferta',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ofertas.length,
                itemBuilder: (context, index) {
                  final oferta = ofertas[index];
                  final esMejorOferta = _esSolicitante && index == 0;
                  return Card(
                    color: esMejorOferta
                        ? const Color(0xFF6C63FF).withOpacity(0.05)
                        : null,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: esMejorOferta
                            ? const Color(0xFF6C63FF)
                            : Colors.grey,
                        child: Text(
                          _esSolicitante
                              ? '${index + 1}'
                              : '€',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        '${oferta.precio.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: esMejorOferta
                              ? const Color(0xFF6C63FF)
                              : null,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: oferta.mensaje != null
                          ? Text(oferta.mensaje!)
                          : null,
                      trailing: _esSolicitante &&
                          oferta.estado == 'pendiente' &&
                          widget.favor.estado == 'activo'
                          ? ElevatedButton(
                        onPressed: () async {
                          final exito = await ref
                              .read(subastasNotifierProvider
                              .notifier)
                              .aceptarOferta(
                            ofertaId: oferta.id,
                            favorId: widget.favor.id,
                          );
                          if (exito && context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PagoPage(
                                  favor: widget.favor,
                                  oferta: oferta,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Aceptar'),
                      )
                          : Chip(
                        label: Text(oferta.estado),
                        backgroundColor:
                        oferta.estado == 'aceptada'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                      ),
                    ),
                  );
                },
              ),
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              error: (error, __) =>
                  Center(child: Text('Error al cargar ofertas: $error')),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.favor.estado == 'activo' && !_esSolicitante
          ? FloatingActionButton.extended(
        onPressed: () {
          final ofertasActuales =
              ref.read(subastasNotifierProvider).value ?? [];

          Oferta? ofertaExistente;
          try {
            ofertaExistente = ofertasActuales.firstWhere(
                  (o) => o.ayudanteId == _currentUserId,
            );
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
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.gavel),
        label: const Text('Enviar oferta'),
      )
          : null,
    );
  }
}