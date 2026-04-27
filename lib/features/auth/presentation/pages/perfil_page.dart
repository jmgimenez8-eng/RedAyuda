import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';

class PerfilPage extends ConsumerStatefulWidget {
  const PerfilPage({super.key});

  @override
  ConsumerState<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends ConsumerState<PerfilPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  bool _editando = false;
  bool _cargando = true;
  Map<String, dynamic>? _perfil;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final data = await Supabase.instance.client
          .from('usuarios')
          .select()
          .eq('id', userId)
          .single();

      setState(() {
        _perfil = data;
        _nombreController.text = data['nombre'] ?? '';
        _telefonoController.text = data['telefono'] ?? '';
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      await Supabase.instance.client
          .from('usuarios')
          .update({
        'nombre': _nombreController.text.trim(),
        'telefono': _telefonoController.text.trim(),
      })
          .eq('id', userId);

      setState(() {
        _editando = false;
        _perfil?['nombre'] = _nombreController.text.trim();
        _perfil?['telefono'] = _telefonoController.text.trim();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmarEliminarCuenta() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar tu cuenta? '
              'Esta acción no se puede deshacer y todos tus datos serán eliminados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar cuenta'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) return;

        await Supabase.instance.client
            .from('usuarios')
            .update({'estado': 'eliminado'})
            .eq('id', userId);

        await ref.read(authNotifierProvider.notifier).cerrarSesion();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cuenta eliminada correctamente'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar la cuenta: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_editando ? Icons.close : Icons.edit_outlined),
            onPressed: () => setState(() => _editando = !_editando),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF6C63FF),
                child: Text(
                  (_perfil?['nombre'] as String? ?? 'U')
                      .substring(0, 1)
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _perfil?['email'] as String? ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${(_perfil?['reputacion'] as num?)?.toStringAsFixed(1) ?? '5.0'} de reputación',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nombreController,
                enabled: _editando,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre no puede estar vacío';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoController,
                enabled: _editando,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _perfil?['rol'] as String? ?? 'solicitante',
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              if (_editando) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _guardarCambios,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar cambios'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.orange),
                title: const Text('Cerrar sesión'),
                onTap: () async {
                  await ref
                      .read(authNotifierProvider.notifier)
                      .cerrarSesion();
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Eliminar cuenta',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: _confirmarEliminarCuenta,
              ),
            ],
          ),
        ),
      ),
    );
  }
}