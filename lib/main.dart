import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticke_it/providers/user_provider.dart';
import 'package:ticke_it/screens/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false, // Remove o banner "DEBUG"
      home: const LoginScreen(),
    );
  }
}
