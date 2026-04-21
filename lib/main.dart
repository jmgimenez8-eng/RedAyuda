import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ovoobafrqltnmtdowusn.supabase.co',
    anonKey: 'sb_publishable_Lvykt6dj1Bix-sfCl-gvGg_NRG3OEIz',
  );

  runApp(
    const ProviderScope(
      child: RedAyudaApp(),
    ),
  );
}

class RedAyudaApp extends ConsumerWidget {
  const RedAyudaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'RedAyuda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
        ),
        useMaterial3: true,
      ),
      home: authState.when(
        data: (usuario) {
          if (usuario != null) {
            return const Scaffold(
              body: Center(
                child: Text('¡Bienvenido a REDAYUDA!'),
              ),
            );
          }
          return const LoginPage();
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (_, __) => const LoginPage(),
      ),
    );
  }
}