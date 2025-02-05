import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ticke_it/screens/home_screen.dart';
import 'package:ticke_it/services/auth_services.dart';

class UpdateProfile extends StatelessWidget {
  UpdateProfile({super.key, required this.name,required this.id});
  String name;
  int id;
  final _passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final _emailcontroller= TextEditingController(text: AuthService.emailuser);
    final _namecontroller= TextEditingController(text:name);
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  'Update Profile',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'informações pessoais',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
          Padding(
            padding: EdgeInsets.all(16),
            child: TextFormField(
              controller: _namecontroller,
              decoration: InputDecoration(
                labelText: 'Nome Completo',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: TextFormField(
              controller: _emailcontroller,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira sua senha.';
                }
                if (value.length < 6) {
                  return 'A senha deve ter pelo menos 6 caracteres.';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: ()async{
                final response=await AuthService.update(_namecontroller.text,_emailcontroller.text,_passwordController.text,id,context);
                
              },
              child: const Text(
                'Atualizar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
