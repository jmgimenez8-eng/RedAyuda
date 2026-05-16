import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/home_page.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Configurar OneSignal primero
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize('6e02c643-52a5-4006-94f6-ec612590c3d6');
  OneSignal.Notifications.requestPermission(true);

  // 2. Inicializar Supabase
  await Supabase.initialize(
    url: 'https://ovoobafrqltnmtdowusn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im92b29iYWZycWx0bm10ZG93dXNuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY1MzY2MDUsImV4cCI6MjA5MjExMjYwNX0.b9Y71a34oJ24ovtL4tkr2yxV3ixB0U723qWFAmcsXIg',
  );

  runApp(const ProviderScope(child: RedAyudaApp()));
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
            return const HomePage();
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