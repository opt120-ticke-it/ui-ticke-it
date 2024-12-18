import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class EventRegistrationScreen extends StatefulWidget {
  @override
  _EventRegistrationScreenState createState() => _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _selectedCategory;
  List<String> _categories=[];
  XFile? _image4x3;
  XFile? _image16x9;
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _tickets = [];

  void _pickImage(bool is4x3) async {
    final XFile? image = await _picker.pickMedia();
    setState(() {
      if (is4x3) {
        _image4x3 = image;
      } else {
        _image16x9 = image;
      }
    });
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Coletar dados e enviar ao backend
      final eventData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'startDate': _startDateController.text,
        'endDate': _endDateController.text,
        'categoriaId': _selectedCategory,
        'location': _locationController.text,
        'image4x3': _image4x3?.path,
        'image16x9': _image16x9?.path,
        'tickets': _tickets.map((ticket) => {
          'name': ticket['name'].text,
          'description': ticket['description'].text,
          'price': ticket['price'].text,
          'quantity': ticket['quantity'].text,
        }).toList(),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final height_box=SizedBox(height: MediaQuery.of(context).size.height*0.05,);
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Evento')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do Evento',border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),height_box,
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição do Evento',border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),height_box,
              TextFormField(
                controller: _startDateController,
                decoration: const InputDecoration(labelText: 'Data de Início',border: OutlineInputBorder()),
                readOnly: true,
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                onTap: () async {
                  DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    _startDateController.text = date.toString().substring(0, 10);
                  }
                },
              ),height_box,
              TextFormField(
                controller: _endDateController,
                decoration: const InputDecoration(labelText: 'Data de Término',border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                onTap: () async {
                  DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    _endDateController.text = date.toString().substring(0, 10);
                  }
                },
              ),height_box,
              DropdownButtonFormField(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Categoria',border: OutlineInputBorder()),
                validator: (value) => value == null ? 'Selecione uma categoria' : null,
              ),height_box,
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Local do Evento',border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),height_box,
              ElevatedButton(
                onPressed: () => _pickImage(true),
                child: const Text('Upload Imagem 4x3'),
              ),height_box,
              ElevatedButton(
                onPressed: () => _pickImage(false),
                child: const Text('Upload Imagem 16x9'),
              ),
              const SizedBox(height: 20),
              const Text('Ingressos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _tickets.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      TextFormField(
                        controller: _tickets[index]['name'],
                        decoration: const InputDecoration(labelText: 'Nome do Ingresso',border:OutlineInputBorder()),
                      ),height_box,
                      TextFormField(
                        controller: _tickets[index]['description'],
                        decoration: const InputDecoration(labelText: 'Descrição do Ingresso',border:OutlineInputBorder() ),
                      ),height_box,
                      TextFormField(
                        controller: _tickets[index]['price'],
                        decoration: const InputDecoration(labelText: 'Preço do Ingresso',border:OutlineInputBorder() ),
                      ),height_box,
                      TextFormField(
                        controller: _tickets[index]['quantity'],
                        decoration: const InputDecoration(labelText: 'Quantidade',border:OutlineInputBorder() ),
                      ),height_box,
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () => _removeTicket(index),
                      )
                    ],
                  );
                },
              ),height_box,
              ElevatedButton(
                onPressed: _addTicket,
                child: const Text('Adicionar Ingresso'),
              ),
              height_box,
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