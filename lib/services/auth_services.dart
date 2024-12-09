import 'package:flutter/material.dart';
import 'package:ticke_it/models/user.dart';
import 'package:ticke_it/utils/utils.dart';
import 'package:http/http.dart' as http;

class AuthService {
  void signUpUser(
      {required BuildContext context,
      required String email,
      required String password,
      required String name}) async {
    try {
      User user = User(
        id: '',
        name: '',
        email: '',
        password: '',
        userType: UserType.CLIENTE,
      );
    } catch (e) {}
  }
}
