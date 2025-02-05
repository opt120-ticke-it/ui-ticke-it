import 'package:flutter/material.dart';
import 'package:ticke_it/screens/updateprofile_screen.dart';
import 'package:ticke_it/services/auth_services.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key, required this.name,required this.id});

  String name;

  int id;
  @override
  Widget build(BuildContext context) {
    final myquery = MediaQuery.of(context);
    return Scaffold(
        body: ListView(
      children: [
        Center(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                'Profile',
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
        SizedBox(
          height: myquery.size.height * 0.05,
        ),
        CircleAvatar(
          radius: myquery.size.width * 0.08,
          backgroundColor: Color.fromARGB(255, 0, 0, 0), // Cor do cabeçalho,
          child: Icon(
            Icons.person_outline,
            color: Colors.white,
            size: myquery.size.width * 0.08,
          ),
        ),
        SizedBox(
          height: myquery.size.height * 0.05,
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: TextFormField(
            controller: TextEditingController(text: AuthService.emailuser),
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
            readOnly: true,
          ),
        ),
        SizedBox(
          height: myquery.size.height * 0.01,
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: TextFormField(
            controller: TextEditingController(text: name),
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
            readOnly: true,
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
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>UpdateProfile(name: name,id: id,)));
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
    ));
  }
}
