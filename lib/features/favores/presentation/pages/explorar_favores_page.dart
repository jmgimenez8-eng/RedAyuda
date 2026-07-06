import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/favores_provider.dart';
import '../widgets/favor_card.dart';
import 'package:redayuda/features/subastas/presentation/pages/detalle_favor_page.dart';
import 'package:redayuda/config/app_theme.dart';
import 'package:redayuda/shared/widgets/ui_kit.dart';

class ExplorarFavoresPage extends ConsumerStatefulWidget {
  const ExplorarFavoresPage({super.key});

  @override
  ConsumerState<ExplorarFavoresPage> createState() =>
      _ExplorarFavoresPageState();
}

class _ExplorarFavoresPageState extends ConsumerState<ExplorarFavoresPage> {
  String _categoriaFiltro = 'Todos';

  final List<String> _categorias = [
    'Todos',
    'Hogar',
    'Transporte',
    'Compras',
    'Tecnología',
    'Mascotas',
    'Mudanza',
    'Clases',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarFavores());
  }

  Future<void> _cargarFavores() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      await ref.read(favoresNotifierProvider.notifier).cargarFavoresCercanos(
            latitud: position.latitude,
            longitud: position.longitude,
            radioKm: 50.0,
          );
    } catch (e) {
      await ref.read(favoresNotifierProvider.notifier).cargarFavoresCercanos(
            latitud: 37.9922,
            longitud: -1.1307,
            radioKm: 50.0,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoresState = ref.watch(favoresNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar favores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _cargarFavores,
          ),
        ],
      ),
      body: Column(
        children: [
          _FiltroCategorias(
            categorias: _categorias,
            seleccionada: _categoriaFiltro,
            onSelected: (c) => setState(() => _categoriaFiltro = c),
          ),
          Expanded(
            child: favoresState.when(
              loading: () => const SkeletonList(),
              error: (_, _) => EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Error al cargar favores',
                message: 'Comprueba tu conexión e inténtalo de nuevo.',
                action: FilledButton.icon(
                  onPressed: _cargarFavores,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                ),
              ),
              data: (favores) {
                final filtrados = favores
                    .where((f) =>
                        f.estado == 'activo' &&
                        (_categoriaFiltro == 'Todos' ||
                            f.categoria == _categoriaFiltro))
                    .toList();

                if (filtrados.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _cargarFavores,
                    child: CustomScrollView(
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: EmptyState(
                            icon: Icons.travel_explore_rounded,
                            title: 'No hay favores en tu zona',
                            message: _categoriaFiltro == 'Todos'
                                ? 'Prueba a ampliar el radio o vuelve más tarde.'
                                : 'No hay favores de "$_categoriaFiltro" cerca.',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _cargarFavores,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.md),
                    itemCount: filtrados.length,
                    itemBuilder: (context, index) {
                      final favor = filtrados[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: FavorCard(
                          favor: favor,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetalleFavorPage(favor: favor),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltroCategorias extends StatelessWidget {
  final List<String> categorias;
  final String seleccionada;
  final ValueChanged<String> onSelected;

  const _FiltroCategorias({
    required this.categorias,
    required this.seleccionada,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        itemCount: categorias.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          final activa = seleccionada == categoria;
          return ChoiceChip(
            label: Text(categoria),
            selected: activa,
            showCheckmark: false,
            onSelected: (_) => onSelected(categoria),
            labelStyle: theme.textTheme.labelMedium?.copyWith(
              color: activa ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              fontWeight: activa ? FontWeight.w700 : FontWeight.w600,
            ),
            side: BorderSide(
              color: activa ? Colors.transparent : theme.colorScheme.outline,
            ),
          );
        },
      ),
    );
  }
}
