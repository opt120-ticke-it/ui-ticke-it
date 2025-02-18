import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticke_it/models/user.dart';
import 'package:ticke_it/providers/user_provider.dart';
import 'package:ticke_it/screens/login_screen.dart';
import 'package:ticke_it/services/auth_services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _cpfController = MaskedTextController(mask: '000.000.000-00');
  final TextEditingController _birthDateController = TextEditingController();
  String _gender = 'Masculino';

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _register(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await AuthService.register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          cpf: _cpfController.text,
          birthDate: _birthDateController.text,
          gender: _gender,
        );
        Provider.of<UserProvider>(context, listen: false).setUserFromModel(User(
          id: response['id']?.toString() ?? '',
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          cpf: _cpfController.text,
          birthDate: DateTime.parse(_birthDateController.text),
          gender: _gender,
        ));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } catch (e) {
        print('Erro no cadastro: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no cadastro: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale("pt", "BR"), // Define o idioma para português
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // Cor do cabeçalho
              onPrimary: Colors.white, // Texto do cabeçalho
              onSurface: Colors.black, // Cor dos números do calendário
            ),
            dialogBackgroundColor: Colors.white, // Cor de fundo do calendário
          ),
          child: child!,
        );
      },
    );

  if (picked != null) {
    setState(() {
      _birthDateController.text = DateFormat('dd/MM/yyyy', 'pt_BR').format(picked);
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Crie sua Conta',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Preencha os campos para se cadastrar',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nome Completo',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu nome.';
                          }
                          if (value.split(' ').length < 2) {
                            return 'Por favor, insira nome completo.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu email.';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Por favor, insira um email válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cpfController,
                        decoration: InputDecoration(
                          labelText: 'CPF',
                          prefixIcon: const Icon(Icons.credit_card),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu CPF.';
                          }
                          if (!RegExp(r'^\d{3}\.\d{3}\.\d{3}-\d{2}$').hasMatch(value)) {
                            return 'Por favor, insira um CPF válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _birthDateController,
                        decoration: InputDecoration(
                          labelText: 'Data de Nascimento',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context), 
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira sua data de nascimento.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: InputDecoration(
                          labelText: 'Gênero',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        items: ['Masculino', 'Feminino', 'Outro']
                            .map((label) => DropdownMenuItem(
                                  child: Text(label),
                                  value: label,
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _gender = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        obscureText: _obscurePassword,
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirme sua Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, confirme sua senha.';
                          }
                          if (value != _passwordController.text) {
                            return 'As senhas não coincidem.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : () => _register(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'Cadastrar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Já tem uma conta? ',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Faça login',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}