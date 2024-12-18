import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuPressed;
  final VoidCallback onCartPressed;

  const Header({
    Key? key,
    required this.onMenuPressed,
    required this.onCartPressed,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60.0); // Altura personalizada do AppBar

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'ticke.it',
        style: TextStyle(
          fontSize: 26, // Fonte maior para destaque
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2, // Espaçamento entre letras
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          iconSize: 28,
          color: Colors.white,
          onPressed: onCartPressed,
        ),
        const SizedBox(width: 8), // Espaço entre ícones
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 4.0,
      shadowColor: Colors.blue.withOpacity(0.5),
    );
  }
}
