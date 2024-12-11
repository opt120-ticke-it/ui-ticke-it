import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ticke_it/models/user.dart';

class AuthService {
  // FAZER UM ARQUIVO PARA ARMAZENAR A URL BASE
  static const String _baseUrl = 'http://172.24.176.1:3000';

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required UserType userType,
  }) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}/users/registrar'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'userType': userType.name,
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
}