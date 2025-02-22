import 'package:flutter/material.dart';
import 'package:ticke_it/components/category_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ticke_it/components/menu_drawer.dart';
import 'package:ticke_it/widgets/header.dart';

class HomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    setState(() {
      isLoading = true;
    });
    final response =
        await http.get(Uri.parse('http://localhost:3000/category/events/list'));
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      appBar: Header(
        onMenuPressed: () {
          widget.scaffoldKey.currentState?.openDrawer();
        },
        onCartPressed: () {
          print('Carrinho pressionado');
        },
        onTitlePressed:
            fetchCategories, // Adicionado para recarregar a página inicial
      ),
      drawer: const MenuDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? Center(child: Text('Não foi encontrado nenhum evento'))
              : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return CategoryWidget(category: categories[index]);
                  },
                ),
    );
  }
}
