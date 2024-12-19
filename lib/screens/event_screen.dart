import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ticke_it/widgets/header.dart';
import 'package:ticke_it/components/menu_drawer.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController(); 
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _selectedCategory;
  List<String> _categories = ['Categoria 1', 'Categoria 2', 'Categoria 3'];
  XFile? _image4x3;
  XFile? _image16x9;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _tickets = [];

  void _pickImage(bool is4x3) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (is4x3) {
          _image4x3 = image;
        } else {
          _image16x9 = image;
        }
      });
    }
  }

  void _addTicket() {
    setState(() {
      _tickets.add({
        'name': TextEditingController(),
        'description': TextEditingController(),
        'price': TextEditingController(),
        'quantity': TextEditingController(),
      });
    });
  }

  void _removeTicket(int index) {
    setState(() {
      _tickets.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _tickets.isNotEmpty) {
      final eventData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'startDate': _startDateController.text,
        'endDate': _endDateController.text,
        'categoriaId': _selectedCategory,
        'location': _locationController.text,
        'image4x3': _image4x3?.path,
        'image16x9': _image16x9?.path,
        'organizerId': 1,
        'ticketType': _tickets.map((ticket) => {
          'name': ticket['name'].text,
          'description': ticket['description'].text,
          'price': double.tryParse(ticket['price'].text) ?? 0,
          'quantity': int.tryParse(ticket['quantity'].text) ?? 0,
        }).toList(),
      };

      try {
        final response = await http.post(
          Uri.parse('http://172.24.176.1:3000/event'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(eventData),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento cadastrado com sucesso!')),
          );
          _formKey.currentState?.reset();
          setState(() {
            _tickets.clear();
            _image4x3 = null;
            _image16x9 = null;
          });
        } else {
          print(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: ${response.body}')),
          );
        }
      } catch (error) {
        print(error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de conexão: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios e adicione pelo menos um ingresso.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final heightBox = SizedBox(height: MediaQuery.of(context).size.height * 0.02);
    return Scaffold(
      key: scaffoldKey,
      appBar: Header(
        onMenuPressed: () {
          scaffoldKey.currentState?.openDrawer(); // Usa a GlobalKey para abrir o drawer
        },
        onCartPressed: () {
          print('Carrinho pressionado');
        },
      ),
      drawer: const MenuDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do Evento', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              heightBox,
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição do Evento', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              heightBox,
              TextFormField(
                controller: _startDateController,
                decoration: const InputDecoration(labelText: 'Data de Início', border: OutlineInputBorder()),
                readOnly: true,
                onTap: () async {
                  DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      DateTime dateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                      _startDateController.text = DateTime.now().toUtc().toIso8601String();
                    }
                  }
                },
              ),
              heightBox,
              TextFormField(
                controller: _endDateController,
                decoration: const InputDecoration(labelText: 'Data de Término', border: OutlineInputBorder()),
                readOnly: true,
                onTap: () async {
                  DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      DateTime dateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                      _endDateController.text = DateTime.now().toUtc().toIso8601String();
                    }
                  }
                },
              ),  
              heightBox,
              DropdownButtonFormField(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
                items: _categories.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value as String?),
                validator: (value) => value == null ? 'Selecione uma categoria' : null,
              ),
              heightBox,
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Local do Evento', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              heightBox,
              ElevatedButton(
                onPressed: () => _pickImage(true),
                child: const Text('Upload Imagem 4x3'),
              ),
              heightBox,
              ElevatedButton(
                onPressed: () => _pickImage(false),
                child: const Text('Upload Imagem 16x9'),
              ),
              const Divider(height: 40),
              const Text('Ingressos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tickets.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      TextFormField(
                        controller: _tickets[index]['name'],
                        decoration: const InputDecoration(labelText: 'Nome do Ingresso', border: OutlineInputBorder()),
                      ),
                      heightBox,
                      TextFormField(
                        controller: _tickets[index]['description'],
                        decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()),
                      ),
                      heightBox,
                      TextFormField(
                        controller: _tickets[index]['price'],
                        decoration: const InputDecoration(labelText: 'Preço', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                      heightBox,
                      TextFormField(
                        controller: _tickets[index]['quantity'],
                        decoration: const InputDecoration(labelText: 'Quantidade', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeTicket(index),
                      ),
                    ],
                  );
                },
              ),
              heightBox,
              ElevatedButton(
                onPressed: _addTicket,
                child: const Text('Adicionar Ingresso'),
              ),
              heightBox,
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Salvar Evento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
