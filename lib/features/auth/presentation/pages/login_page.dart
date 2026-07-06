import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'register_page.dart';
import 'package:redayuda/config/app_theme.dart';
import 'package:redayuda/shared/widgets/ui_kit.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).iniciarSesion(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: AppColors.error,
          ),
        ),
      );
    });

    return Scaffold(
      body: Stack(
        children: [
          const AuthBackdrop(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppLogo(size: 76),
                    const SizedBox(height: AppSpacing.md),
                    Text('RedAyuda',
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Conectando personas, resolviendo favores',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    GlassPanel(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.alternate_email_rounded),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Introduce tu email';
                                }
                                if (!value.contains('@')) return 'Email no válido';
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined),
                                  onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Introduce tu contraseña';
                                }
                                if (value.length < 6) return 'Mínimo 6 caracteres';
                                return null;
                              },
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text('¿Olvidaste tu contraseña?'),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            FilledButton(
                              onPressed: authState.isLoading ? null : _login,
                              child: authState.isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.4, color: Colors.white),
                                    )
                                  : const Text('Iniciar sesión'),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _DividerOr(),
                            const SizedBox(height: AppSpacing.md),
                            OutlinedButton.icon(
                              onPressed: authState.isLoading
                                  ? null
                                  : () => ref
                                      .read(authNotifierProvider.notifier)
                                      .iniciarSesionConGoogle(),
                              icon: Image.network(
                                'https://www.google.com/favicon.ico',
                                height: 20,
                                width: 20,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.g_mobiledata_rounded),
                              ),
                              label: const Text('Continuar con Google'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('¿No tienes cuenta?',
                            style: theme.textTheme.bodyMedium),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterPage()),
                          ),
                          child: const Text('Regístrate'),
                        ),
                      ],
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: AppDurations.slow)
                    .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerOr extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('o continúa con',
              style: theme.textTheme.labelMedium),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
