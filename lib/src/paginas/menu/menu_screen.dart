import 'package:flutter/material.dart';
import 'package:restcampo/src/paginas/homeScreen/home_screen.dart';
import 'package:restcampo/src/paginas/ubicacion/como_llegar.dart';
import 'package:restcampo/src/utils/Menu/menu_header.dart';
import 'package:restcampo/src/utils/Menu/menu_title.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),

            const MenuHeader(),

            const SizedBox(height: 14),
            Divider(color: cs.outlineVariant.withOpacity(0.6), height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                children: [
                  MenuTile(
                    icon: Icons.home_outlined,
                    title: 'Inicio',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                  ),
                  MenuTile(
                    icon: Icons.restaurant_menu_outlined,
                    title: 'Menú / Carta',
                    onTap: () {},
                  ),
                  MenuTile(
                    icon: Icons.maps_home_work_sharp,
                    title: 'Como llegar',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ComoLlegarScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),
                  Divider(color: cs.outlineVariant.withOpacity(0.6), height: 1),
                  MenuTile(
                    icon: Icons.logout,
                    title: 'Salir',
                    isDestructive: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
