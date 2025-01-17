import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticke_it/providers/user_provider.dart';
import 'package:ticke_it/screens/login_screen.dart';
import 'package:ticke_it/widgets/header.dart';
import 'package:ticke_it/services/auth_services.dart';
import 'package:ticke_it/components/menu_drawer.dart';

class HomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: Header(
        onMenuPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
        onCartPressed: () {
          print('Carrinho pressionado');
        },
      ),
      drawer: const MenuDrawer(),
      body: Center(
        child: Text('Conteúdo da Tela Home'),
      ),
    );
  }
}
