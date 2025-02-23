import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:ticke_it/providers/user_provider.dart';
import 'package:ticke_it/screens/login_screen.dart';
import 'package:ticke_it/screens/pagament_screen.dart';

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
      title: 'ticke.it',
      theme: ThemeData(
        useMaterial3: false, // 🔹 Desativa o Material 3 para evitar cores automáticas
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white, // 🔹 Fundo branco da tela
        colorScheme: ColorScheme.light(
          primary: Colors.black,  // 🔹 Cor principal (afeta botões, seleções, etc.)
          secondary: Colors.black, // 🔹 Cor de destaque
          background: Colors.white,
          surface: Colors.white,
          onPrimary: Colors.white, // 🔹 Texto e ícones sobre preto
          onSecondary: Colors.white,
          onSurface: Colors.black, // 🔹 Texto sobre fundo claro
          onBackground: Colors.black,
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),

      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      
      // 🌍 Adicionando suporte a Português-BR
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
