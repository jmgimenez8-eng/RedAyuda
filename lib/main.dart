import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class RedAyudaApp extends StatelessWidget {
  const RedAyudaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RedAyuda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
        ),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('RedAyuda — Sprint 1'),
        ),
      ),
    );
  }
}