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

  String? _token;

  User get user => _user;
  String? get token => _token; 

  void setUser(String userJson, {String? token}) {
    _user = User.fromJson(userJson);
    _token = token;
    notifyListeners();
  }

  void setUserFromModel(User user, {String? token}) {
    _user = user;
    _token = token;
    notifyListeners();
  }

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