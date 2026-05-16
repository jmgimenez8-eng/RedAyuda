import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:redayuda/features/favores/data/models/favor_model.dart';
import 'chat_page.dart';

class ConversacionesPage extends ConsumerStatefulWidget {
  const ConversacionesPage({super.key});

  @override
  ConsumerState<ConversacionesPage> createState() => _ConversacionesPageState();
}

class _ConversacionesPageState extends ConsumerState<ConversacionesPage> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> _conversaciones = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarConversaciones();
  }

  Future<void> _cargarConversaciones() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _client
          .from('conversaciones')
          .select()
          .or('solicitante_id.eq.$userId,ayudante_id.eq.$userId')
          .order('ultimo_mensaje_at', ascending: false);

      setState(() {
        _conversaciones = List<Map<String, dynamic>>.from(data);
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversaciones'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarConversaciones,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _conversaciones.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tienes conversaciones activas',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _cargarConversaciones,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _conversaciones.length,
          itemBuilder: (context, index) {
            final conv = _conversaciones[index];
            final ultimoMensaje =
                conv['ultimo_mensaje'] as String? ?? 'Sin mensajes';
            final ultimoMensajeAt =
            conv['ultimo_mensaje_at'] != null
                ? DateTime.parse(
                conv['ultimo_mensaje_at'] as String)
                : null;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () async {
                  try {
                    final favorData = await _client
                        .from('favores')
                        .select()
                        .eq('id', conv['favor_id'])
                        .single();

                    if (context.mounted) {
                      final favor = FavorModel.fromJson(favorData);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            favor: favor,
                            ayudanteId:
                            conv['ayudante_id'] as String,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                        const Color(0xFF6C63FF).withOpacity(0.1),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Favor: ${conv['favor_id'].toString().substring(0, 8)}...',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ultimoMensaje,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (ultimoMensajeAt != null)
                        Text(
                          timeago.format(ultimoMensajeAt,
                              locale: 'es'),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}