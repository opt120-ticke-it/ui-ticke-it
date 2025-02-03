import 'package:flutter/material.dart'; // Necessário para o uso do BuildContext e AlertDialog
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart'; // Importando o Provider
import 'package:ticke_it/models/user.dart';
import 'package:ticke_it/providers/user_provider.dart'; // Importando o UserProvider
import 'package:ticke_it/screens/login_screen.dart'; // Importando a tela de login

class AuthService {
  // FAZER UM ARQUIVO PARA ARMAZENAR A URL BASE
  static const String _baseUrl = 'http://localhost:3000';

  // Função de registro
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}/user/registrar'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      print(errorBody);
      throw Exception(errorBody['message'] ?? 'Erro no registro');
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorBody = jsonDecode(response.body);
      print(errorBody);
      throw Exception(errorBody['message'] ?? 'Erro no login');
    }
  }

  static void logout(BuildContext context) {
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
                // Logout no UserProvider
                Provider.of<UserProvider>(context, listen: false).logout();
                // Navegar para a tela de login
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Logout realizado com sucesso!')),
                );
              },
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }
}
