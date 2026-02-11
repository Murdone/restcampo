import 'package:flutter/material.dart';
import 'package:restcampo/main.dart';
import 'package:restcampo/src/paginas/menu/menu_screen.dart';
import 'package:restcampo/src/paginas/ubicacion/como_llegar.dart';
import 'package:restcampo/src/utils/card/quick_card.dart';

enum HomeOption { menu, comoLlegar }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeOption? selected;

  void _go(HomeOption option) {
    setState(() => selected = null);

    switch (option) {
      case HomeOption.menu:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MenuScreen()),
        );
        break;

      case HomeOption.comoLlegar:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ComoLlegarScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // quita la flecha automática
        leading: IconButton(
          icon: const Icon(Icons.menu), // icono de rayitas
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MenuScreen()),
            );
          },
        ),
        title: const Text('Campo Restoran'),
        actions: [
          IconButton(
            tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
            onPressed: () => themeController.toggleLightDark(),
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ), // ✅ aquí termina appBar SIN coma extra abajo

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accesos rápidos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                QuickCard(
                  icon: Icons.restaurant_menu_outlined,
                  title: 'Menú',
                  subtitle: 'Ver la carta',
                  onTap: () => _go(HomeOption.menu),
                ),
                QuickCard(
                  icon: Icons.location_on_outlined,
                  title: 'Cómo llegar',
                  subtitle: 'Ubicación y ruta',
                  onTap: () => _go(HomeOption.comoLlegar),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
