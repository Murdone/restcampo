import 'dart:async';

import 'package:flutter/material.dart';
import 'package:restcampo/src/paginas/homeScreen/home_screen.dart'; // ✅ cambio

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()), // ✅ cambio
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final logoPath = isDark
        ? 'assets/images/LogoOs.png'
        : 'assets/images/LogoCl.png';

    final bgColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(logoPath, width: 140, height: 140),
              const SizedBox(height: 16),
              Text(
                'Campo Restoran',
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Bienvenido',
                style: TextStyle(
                  color: textColor.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
