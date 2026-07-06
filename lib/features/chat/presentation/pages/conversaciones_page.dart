import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:redayuda/features/favores/data/models/favor_model.dart';
import 'chat_page.dart';
import 'package:redayuda/config/app_theme.dart';
import 'package:redayuda/shared/widgets/ui_kit.dart';

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

  Future<void> _abrirChat(BuildContext context, Map<String, dynamic> conv) async {
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
              ayudanteId: conv['ayudante_id'] as String,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _cargarConversaciones,
          ),
        ],
      ),
      body: _cargando
          ? const SkeletonList(itemHeight: 76)
          : _conversaciones.isEmpty
              ? RefreshIndicator(
                  onRefresh: _cargarConversaciones,
                  child: CustomScrollView(
                    slivers: const [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          icon: Icons.forum_outlined,
                          title: 'No tienes conversaciones',
                          message:
                              'Cuando aceptes o envíes una oferta podrás chatear aquí.',
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarConversaciones,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _conversaciones.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final conv = _conversaciones[index];
                      final ultimoMensaje =
                          conv['ultimo_mensaje'] as String? ?? 'Sin mensajes';
                      final ultimoMensajeAt = conv['ultimo_mensaje_at'] != null
                          ? DateTime.parse(conv['ultimo_mensaje_at'] as String)
                          : null;

                      return Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusCard),
                          border: Border.all(color: theme.colorScheme.outline),
                          boxShadow: AppShadows.card,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _abrirChat(context, conv),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: theme.colorScheme.primary
                                        .withValues(alpha: 0.12),
                                    child: Icon(
                                      Icons.forum_rounded,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Conversación',
                                          style: theme.textTheme.titleSmall,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          ultimoMensaje,
                                          style: theme.textTheme.bodySmall,
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
                                      style: theme.textTheme.labelSmall,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(
                              duration: AppDurations.base,
                              delay: (index.clamp(0, 8) * 40).ms)
                          .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
                    },
                  ),
                ),
    );
  }
}
