import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/subastas_provider.dart';
import 'package:redayuda/features/subastas/presentation/pages/detalle_favor_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:redayuda/features/favores/data/models/favor_model.dart';
import 'package:redayuda/features/chat/presentation/pages/chat_page.dart';

class MisOfertasPage extends ConsumerStatefulWidget {
  const MisOfertasPage({super.key});

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

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'pendiente': return Colors.orange;
      case 'aceptada': return Colors.green;
      case 'rechazada': return Colors.red;
      case 'expirada': return Colors.grey;
      default: return Colors.grey;
    }
  }

  IconData _iconoEstado(String estado) {
    switch (estado) {
      case 'pendiente': return Icons.hourglass_empty;
      case 'aceptada': return Icons.check_circle_outline;
      case 'rechazada': return Icons.cancel_outlined;
      case 'expirada': return Icons.timer_off_outlined;
      default: return Icons.help_outline;
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
              ayudanteId:
              Supabase.instance.client.auth.currentUser?.id ?? '',
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
    final ofertasState = ref.watch(subastasNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis ofertas'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(subastasNotifierProvider.notifier)
                .cargarMisOfertas(),
          ),
        ],
      ),
      body: ofertasState.when(
        data: (ofertas) {
          if (ofertas.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gavel, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aún no has enviado ninguna oferta',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Explora los favores disponibles y envía tu primera oferta',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref
                .read(subastasNotifierProvider.notifier)
                .cargarMisOfertas(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ofertas.length,
              itemBuilder: (context, index) {
                final oferta = ofertas[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () async {
                      try {
                        final favorData = await Supabase.instance.client
                            .from('favores')
                            .select()
                            .eq('id', oferta.favorId)
                            .single();

                        if (context.mounted) {
                          final favor = FavorModel.fromJson(favorData);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetalleFavorPage(favor: favor),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                Text('Error al cargar el favor: $e')),
                          );
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _iconoEstado(oferta.estado),
                                color: _colorEstado(oferta.estado),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _colorEstado(oferta.estado)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  oferta.estado.toUpperCase(),
                                  style: TextStyle(
                                    color: _colorEstado(oferta.estado),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                timeago.format(oferta.createdAt,
                                    locale: 'es'),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.euro,
                                size: 20,
                                color: Color(0xFF6C63FF),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${oferta.precio.toStringAsFixed(2)} €',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6C63FF),
                                ),
                              ),
                            ],
                          ),
                          if (oferta.mensaje != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              oferta.mensaje!,
                              style: const TextStyle(color: Colors.grey),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 8),

                          // Mensaje de oferta aceptada
                          if (oferta.estado == 'aceptada')
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.celebration,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '¡Tu oferta fue aceptada! Coordina con el solicitante.',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Mensaje de oferta pendiente
                          if (oferta.estado == 'pendiente')
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.hourglass_empty,
                                    color: Colors.orange,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Tu oferta está pendiente de aceptación.',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Botón de chat para ofertas pendientes o aceptadas
                          if (oferta.estado == 'pendiente' ||
                              oferta.estado == 'aceptada') ...[
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _navegarAlChat(context, oferta.favorId),
                              icon: const Icon(Icons.chat_outlined, size: 16),
                              label: const Text('Ir al chat'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Color(0xFF6C63FF)),
                                foregroundColor: const Color(0xFF6C63FF),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('Error al cargar tus ofertas'),
        ),
      ),
    );
  }
}