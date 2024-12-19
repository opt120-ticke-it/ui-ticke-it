import 'package:flutter/material.dart';
import 'package:ticke_it/screens/event_screen.dart';
import 'package:ticke_it/services/auth_services.dart';
import 'package:ticke_it/screens/home_screen.dart';


class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue, // Cor do cabeçalho
            ),
            child: Text(
              'ticke.it',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () =>Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (ctx) => HomeScreen()))
            ,
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Meus Eventos'),
            onTap: () =>Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (ctx) => EventScreen()))
            ,
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Seus Dados'),
            onTap: () {
              // Ação para "Seus Dados"
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Suporte'),
            onTap: () {
              // Ação para "Suporte"
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () {
              // Ação para "Configurações"
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('FAQ'),
            onTap: () {
              // Ação para "FAQ"
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Termos e Condições'),
            onTap: () {
              // Ação para "Termos e Condições"
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              AuthService.logout(context);
            },
          ),
        ],
      ),
    );
  }
}
