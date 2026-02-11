import 'package:flutter/material.dart';

class MenuHeader extends StatelessWidget {
  const MenuHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, size: 36, color: cs.onSurfaceVariant),
    );
  }
}
