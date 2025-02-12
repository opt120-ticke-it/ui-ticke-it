import 'dart:convert';

class User {
  final dynamic id;
  final String name;
  final String email;
  final String? password; // Tornado opcional
  final String cpf;
  final DateTime birthDate;
  final String gender;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.password, // Tornado opcional
    required this.cpf,
    required this.birthDate,
    required this.gender,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'], // Tornado opcional
      cpf: map['cpf'],
      birthDate: DateTime.parse(map['birthDate']),
      gender: map['gender'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password, // Tornado opcional
      'cpf': cpf,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
    };
  }

  String toJson() => json.encode(toMap());
  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}