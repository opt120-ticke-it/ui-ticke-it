import 'package:flutter/material.dart';
import 'package:ticke_it/models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
    id: '',
    name: '',
    email: '',
    password: '',
    cpf: '',
    birthDate: DateTime.now(),
    gender: '',
  );

  String? _token; // Token opcional, usado para autenticação.

  User get user => _user;
  String? get token => _token; // Getter para o token.

  // Define os dados do usuário e o token.
  void setUser(String userJson, {String? token}) {
    _user = User.fromJson(userJson);
    _token = token;
    notifyListeners();
  }

  // Define o usuário diretamente a partir de um modelo.
  void setUserFromModel(User user, {String? token}) {
    _user = user;
    _token = token;
    notifyListeners();
  }

  // Redefine o estado do usuário e limpa o token ao fazer logout.
  void logout() {
    _user = User(
      id: '',
      name: '',
      email: '',
      password: '',
      cpf: '',
      birthDate: DateTime.now(),
      gender: '',
    );
    _token = null;
    notifyListeners();
  }
}