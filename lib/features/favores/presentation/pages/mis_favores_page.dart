import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/favores_provider.dart';
import '../../domain/entities/favor.dart';
import 'package:redayuda/features/subastas/presentation/pages/detalle_favor_page.dart';

class MisFavoresPage extends ConsumerStatefulWidget {
  const MisFavoresPage({super.key});

  @override
  ConsumerState<MisFavoresPage> createState() => _MisFavoresPageState();
}

class _MisFavoresPageState extends ConsumerState<MisFavoresPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoresNotifierProvider.notifier).cargarMisFavores();
    });
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'activo':
        return Colors.green;
      case 'en_negociacion':
        return Colors.orange;
      case 'completado':
        return Colors.blue;
      case 'cancelado':
        return Colors.red;
      case 'expirado':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Future<void> _confirmarCancelar(BuildContext context, Favor favor) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar favor'),
        content: Text(
            '¿Estás seguro de que quieres cancelar "${favor.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      await ref
          .read(favoresNotifierProvider.notifier)
          .cancelarFavor(id: favor.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favor cancelado'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoresState = ref.watch(favoresNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis favores'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: favoresState.when(
        data: (favores) => favores.isEmpty
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No tienes favores publicados',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        )
            : RefreshIndicator(
          onRefresh: () => ref
              .read(favoresNotifierProvider.notifier)
              .cargarMisFavores(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favores.length,
            itemBuilder: (context, index) {
              final favor = favores[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    favor.titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(favor.descripcion),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C63FF)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              favor.categoria,
                              style: const TextStyle(
                                color: Color(0xFF6C63FF),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _colorEstado(favor.estado)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              favor.estado,
                              style: TextStyle(
                                color: _colorEstado(favor.estado),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Publicado ${timeago.format(favor.createdAt, locale: 'es')}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalleFavorPage(favor: favor),
                    ),
                  ),
                  trailing: favor.estado == 'activo'
                      ? IconButton(
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: Colors.red,
                    ),
                    onPressed: () =>
                        _confirmarCancelar(context, favor),
                  )
                      : null,
                ),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('Error al cargar tus favores'),
        ),
      ),
    );
  }
}