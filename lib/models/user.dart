// ignore: constant_identifier_names
import 'dart:convert';

enum UserType { CLIENTE, ORGANIZADOR, FUNCIONARIO }

class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserType userType;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      userType: UserType.values.firstWhere((e) => e.name == map['userType']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'userType': userType.name,
    };
  }

  String toJson() => json.encode(toMap());
  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
