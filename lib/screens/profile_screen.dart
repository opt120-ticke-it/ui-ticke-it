import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:ticke_it/providers/user_provider.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  bool isLoading = true;
  bool hasError = false;
  String? _cpf;
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user.id;
    final response = await http.get(Uri.parse('http://localhost:3000/user/$userId'));
    if (response.statusCode == 200) {
      final user = json.decode(response.body);
      setState(() {
        _nameController.text = user['name'];
        _emailController.text = user['email'];
        _genderController.text = user['gender'];
        _cpf = user['cpf'];
        _birthDate = DateTime.parse(user['birthDate']);
        isLoading = false;
      });
    } else {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _updateUser({String? password, String? oldPassword}) async {
    if (_formKey.currentState?.validate() ?? false) {
      final userId = Provider.of<UserProvider>(context, listen: false).user.id;
      final user = {
        'id': userId,
        'name': _nameController.text,
        'email': _emailController.text,
        'gender': _genderController.text,
        if (password != null) 'password': password,
        if (oldPassword != null) 'oldPassword': oldPassword,
      };
      final response = await http.patch(
        Uri.parse('http://localhost:3000/user/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil atualizado com sucesso')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar o perfil:')),
        );
      }
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alterar Perfil'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu nome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _genderController.text,
                  decoration: InputDecoration(labelText: 'Gênero'),
                  items: ['Masculino', 'Feminino'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _genderController.text = newValue!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, selecione seu gênero';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => _updateUser(),
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final TextEditingController _currentPasswordController = TextEditingController();
    final TextEditingController _newPasswordController = TextEditingController();
    final TextEditingController _confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alterar Senha'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _currentPasswordController,
                  decoration: InputDecoration(labelText: 'Senha Atual'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua senha atual';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(labelText: 'Nova Senha'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua nova senha';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(labelText: 'Confirmar Nova Senha'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, confirme sua nova senha';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_newPasswordController.text == _confirmPasswordController.text) {
                  _updateUser(password: _newPasswordController.text, oldPassword: _currentPasswordController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('As senhas não coincidem')),
                  );
                }
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(child: Text('Erro ao carregar perfil'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person, size: 100, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text('Nome:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(_nameController.text, style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 16),
                          Text('Email:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(_emailController.text, style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 16),
                          Text('CPF:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(_cpf ?? '', style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 16),
                          Text('Data de Nascimento:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(_birthDate != null ? DateFormat('dd/MM/yyyy').format(_birthDate!) : '', style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 16),
                          Text('Gênero:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(_genderController.text, style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: _showEditProfileDialog,
                                child: Text('Alterar Perfil'),
                              ),
                              ElevatedButton(
                                onPressed: _showChangePasswordDialog,
                                child: Text('Alterar Senha'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}