import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticke_it/screens/my_events_screen.dart';
import 'package:ticke_it/screens/profile_screen.dart';
import 'package:ticke_it/screens/login_screen.dart';
import 'package:ticke_it/screens/my_tickets_screen.dart'; // Importar a nova tela
import 'package:ticke_it/providers/user_provider.dart';

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
              color: Color.fromARGB(255, 0, 0, 0), // Cor do cabeçalho
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
            leading: const Icon(Icons.event),
            title: const Text('Meus Eventos'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyEventsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Seus Dados'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.airplane_ticket),
            title: const Text('Meus Ingressos'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyTicketsScreen()), // Navegar para a nova tela
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Provider.of<UserProvider>(context, listen: false).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}