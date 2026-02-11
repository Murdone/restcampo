import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ComoLlegarScreen extends StatelessWidget {
  const ComoLlegarScreen({super.key});

  // ✅ Cambia esto por tu dirección real:
  static const String direccion = 'Av. Siempre Viva 123, Springfield';

  // Consejo: si tienes coordenadas, es todavía mejor:
  // static const String destinoCoords = '-12.0464,-77.0428'; // ejemplo

  Future<void> _abrirRuta() async {
    // Abre Google Maps con navegación hacia dirección fija.
    final query = Uri.encodeComponent(direccion);

    // “api=1” le dice a Google Maps que es modo direcciones.
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$query&travelmode=driving',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'No se pudo abrir Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cómo llegar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dirección', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(direccion, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _abrirRuta,
                icon: const Icon(Icons.navigation),
                label: const Text('Abrir mejor ruta en Google Maps'),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tip: si usas coordenadas (lat,lng) suele ser más exacto que texto.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
