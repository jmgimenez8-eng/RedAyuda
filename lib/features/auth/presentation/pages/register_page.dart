import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'package:redayuda/config/app_theme.dart';
import 'package:redayuda/shared/widgets/ui_kit.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).registrar(
          nombre: _nombreController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          telefono: _telefonoController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        data: (usuario) {
          if (usuario != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registro exitoso. Verifica tu email.'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          }
        },
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: AppColors.error,
          ),
        ),
      );
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Crear cuenta'),
      ),
      body: Stack(
        children: [
          const AuthBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  const Center(child: AppLogo(size: 64)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Únete a RedAyuda',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Crea tu cuenta en menos de un minuto',
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
                            controller: _nombreController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Nombre completo',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Introduce tu nombre';
                              }
                              if (value.length < 3) return 'Mínimo 3 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
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
                            controller: _telefonoController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Teléfono',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Introduce tu teléfono';
                              }
                              if (value.length < 9) return 'Teléfono no válido';
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
                                return 'Introduce una contraseña';
                              }
                              if (value.length < 6) return 'Mínimo 6 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirmar contraseña',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () => setState(() =>
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirma tu contraseña';
                              }
                              if (value != _passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          FilledButton(
                            onPressed: authState.isLoading ? null : _registrar,
                            child: authState.isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.4, color: Colors.white),
                                  )
                                : const Text('Crear cuenta'),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md),
                                child: Text('o continúa con',
                                    style: theme.textTheme.labelMedium),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
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
                      Text('¿Ya tienes cuenta?',
                          style: theme.textTheme.bodyMedium),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Inicia sesión'),
                      ),
                    ],
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: AppDurations.slow)
                  .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic),
            ),
          ),
        ],
      ),
    );
  }
}
