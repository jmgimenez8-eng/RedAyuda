import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../favores/domain/entities/favor.dart';
import '../providers/subastas_provider.dart';

class EnviarOfertaPage extends ConsumerStatefulWidget {
  final Favor favor;

  const EnviarOfertaPage({super.key, required this.favor});

  @override
  ConsumerState<EnviarOfertaPage> createState() => _EnviarOfertaPageState();
}

class _EnviarOfertaPageState extends ConsumerState<EnviarOfertaPage> {
  final _formKey = GlobalKey<FormState>();
  final _precioController = TextEditingController();
  final _mensajeController = TextEditingController();

  @override
  void dispose() {
    _precioController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  Future<void> _enviarOferta() async {
    if (!_formKey.currentState!.validate()) return;

    final exito = await ref.read(subastasNotifierProvider.notifier).enviarOferta(
      favorId: widget.favor.id,
      precio: double.parse(_precioController.text.trim()),
      mensaje: _mensajeController.text.trim().isEmpty
          ? null
          : _mensajeController.text.trim(),
    );

    if (exito && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oferta enviada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subastasState = ref.watch(subastasNotifierProvider);

    ref.listen(subastasNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.red,
          ),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar oferta'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Favor',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.favor.titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.favor.categoria,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _precioController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Tu oferta (€)',
                  prefixIcon: Icon(Icons.euro),
                  border: OutlineInputBorder(),
                  hintText: 'Ej: 15.00',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduce un precio';
                  }
                  final precio = double.tryParse(value);
                  if (precio == null || precio <= 0) {
                    return 'Introduce un precio válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mensajeController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Mensaje (opcional)',
                  prefixIcon: Icon(Icons.message_outlined),
                  border: OutlineInputBorder(),
                  hintText: 'Explica brevemente por qué eres la mejor opción',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: subastasState.isLoading ? null : _enviarOferta,
                icon: const Icon(Icons.gavel),
                label: subastasState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Enviar oferta',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}