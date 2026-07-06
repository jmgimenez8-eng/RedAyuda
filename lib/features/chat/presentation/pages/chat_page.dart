import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/chat_provider.dart';
import 'package:redayuda/features/favores/domain/entities/favor.dart';
import 'package:redayuda/config/app_theme.dart';
import 'package:redayuda/shared/widgets/ui_kit.dart';

class ChatPage extends ConsumerStatefulWidget {
  final Favor favor;
  final String ayudanteId;

  const ChatPage({
    super.key,
    required this.favor,
    required this.ayudanteId,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _mensajeController = TextEditingController();
  final _scrollController = ScrollController();
  final String? _currentUserId = Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(chatNotifierProvider.notifier).crearConversacion(
            favorId: widget.favor.id,
            solicitanteId: widget.favor.solicitanteId,
            ayudanteId: widget.ayudanteId,
          );
      await ref
          .read(chatNotifierProvider.notifier)
          .cargarMensajes(favorId: widget.favor.id);
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _enviarMensaje() async {
    final contenido = _mensajeController.text.trim();
    if (contenido.isEmpty) return;
    _mensajeController.clear();
    await ref.read(chatNotifierProvider.notifier).enviarMensaje(
          favorId: widget.favor.id,
          contenido: contenido,
        );
    _scrollToBottom();
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mensajesStream = ref.watch(mensajesStreamProvider(widget.favor.id));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.14),
              child: Icon(Icons.person_rounded,
                  color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chat', style: theme.textTheme.titleSmall),
                  Text(
                    widget.favor.titulo,
                    style: theme.textTheme.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: mensajesStream.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (mensajes) {
                if (mensajes.isEmpty) {
                  return const EmptyState(
                    icon: Icons.waving_hand_outlined,
                    title: 'Inicia la conversación',
                    message: 'Envía el primer mensaje para coordinar el favor.',
                  );
                }

                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: mensajes.length,
                  itemBuilder: (context, index) {
                    final mensaje = mensajes[index];
                    final esMio = mensaje.emisorId == _currentUserId;
                    return _Burbuja(
                      texto: mensaje.contenido,
                      hora: timeago.format(mensaje.createdAt, locale: 'es'),
                      esMio: esMio,
                    );
                  },
                );
              },
            ),
          ),
          _BarraEntrada(
            controller: _mensajeController,
            onEnviar: _enviarMensaje,
          ),
        ],
      ),
    );
  }
}

class _Burbuja extends StatelessWidget {
  final String texto;
  final String hora;
  final bool esMio;
  const _Burbuja({required this.texto, required this.hora, required this.esMio});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = Radius.circular(AppSpacing.radiusLg);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment:
            esMio ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!esMio) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: Icon(Icons.person_rounded,
                  size: 15, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  esMio ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 10),
                  decoration: BoxDecoration(
                    color: esMio
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.only(
                      topLeft: radius,
                      topRight: radius,
                      bottomLeft: esMio ? radius : const Radius.circular(4),
                      bottomRight: esMio ? const Radius.circular(4) : radius,
                    ),
                  ),
                  child: Text(
                    texto,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: esMio
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(hora, style: theme.textTheme.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarraEntrada extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onEnviar;
  const _BarraEntrada({required this.controller, required this.onEnviar});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onEnviar(),
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHigh,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Material(
              color: theme.colorScheme.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onEnviar,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.send_rounded,
                      color: theme.colorScheme.onPrimary, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
