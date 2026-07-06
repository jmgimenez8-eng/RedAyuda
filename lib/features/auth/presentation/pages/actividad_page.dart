import 'package:flutter/material.dart';
import 'package:redayuda/features/favores/presentation/pages/mis_favores_page.dart';
import 'package:redayuda/features/subastas/presentation/pages/mis_ofertas_page.dart';

/// Pantalla "Actividad": unifica los favores publicados por el usuario y las
/// ofertas que ha enviado en una sola sección con pestañas.
class ActividadPage extends StatelessWidget {
  const ActividadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Actividad'),
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            labelStyle: theme.textTheme.titleSmall,
            unselectedLabelStyle: theme.textTheme.titleSmall,
            tabs: const [
              Tab(text: 'Mis favores'),
              Tab(text: 'Mis ofertas'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MisFavoresPage(embedded: true),
            MisOfertasPage(embedded: true),
          ],
        ),
      ),
    );
  }
}
