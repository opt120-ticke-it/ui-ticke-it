import 'package:flutter/material.dart';
import 'package:ticke_it/components/category_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ticke_it/components/menu_drawer.dart';
import 'package:ticke_it/widgets/header.dart';

class HomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  HomeScreen({super.key,required this.user});
  Map<String,dynamic> user;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('http://localhost:3000/category/'));
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body);
      });
    } else {
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
      ),
      drawer: MenuDrawer(responsedata: widget.user,),
      body: categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return CategoryWidget(category: categories[index]);
              },
            ),
    );
  }
}