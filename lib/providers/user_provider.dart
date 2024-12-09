import 'package:flutter/material.dart';
import 'package:ticke_it/models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
    name: '',
    id: '',
    email: '',
    password: '',
    userType: UserType.CLIENTE,
  );

  User get user => _user;

  void setUser(String user) {
    _user = User.fromJson(user);
    notifyListeners();
  }

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }

  // void updateUser(User newUser) {
  //   user = newUser;
  //   notifyListeners();
  // }
}
