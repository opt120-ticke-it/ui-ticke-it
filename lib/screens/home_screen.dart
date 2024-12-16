import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticke_it/providers/user_provider.dart';
import 'package:ticke_it/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Função para exibir o menu
  void _openMenu(BuildContext context) async {
    final String selectedItem = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(300, 100, 0, 0), // Controle da posição do menu
      items: [
        const PopupMenuItem<String>(
          value: 'meusEventos',
          child: Text('Meus Eventos'),
        ),
        const PopupMenuItem<String>(
          value: 'seusDados',
          child: Text('Seus Dados'),
        ),
        const PopupMenuItem<String>(
          value: 'suporte',
          child: Text('Suporte'),
        ),
        const PopupMenuItem<String>(
          value: 'configuracoes',
          child: Text('Configurações'),
        ),
        const PopupMenuItem<String>(
          value: 'faq',
          child: Text('FAQ'),
        ),
        const PopupMenuItem<String>(
          value: 'termosCondicoes',
          child: Text('Termos e Condições'),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Text('Logout'),
        ),
      ],
      elevation: 8.0,
    ) ?? '';

    if (selectedItem.isNotEmpty) {
      switch (selectedItem) {
        case 'logout':
          _logout(context);
          break;
        default:
          break;
      }
    }
  }

  // Função de logout
  void _logout(BuildContext context) {
    // Exibir o AlertDialog para confirmação de logout
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: const Text('Você tem certeza que deseja sair?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar o diálogo
                Provider.of<UserProvider>(context, listen: false).logout(); // Logout
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ); // Navegar para login
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logout realizado com sucesso!')),
                );
              },
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.blue, // Cor de fundo do app bar
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo do aplicativo
          Row(
            children: [
              const SizedBox(width: 10),
              const Text(
                'Ticke.it',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white),
              ),
            ],
          ),
          // Ícones alinhados à direita (Carrinho e Menu)
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // Coloque aqui a função do carrinho
                  print('Carrinho de compras pressionado');
                },
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 30,
                ),
              ),
              IconButton(
                onPressed: () => _openMenu(context),
                icon: const Icon(
                  Icons.menu,
                  size: 30,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    body: const Center(child: Text('Tela Principal do App')),
  );
  }
}
