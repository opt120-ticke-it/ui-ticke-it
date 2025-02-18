import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ticke_it/providers/user_provider.dart';
import 'package:intl/intl.dart';

class EventFormScreen extends StatefulWidget {
  final Map? event;

  EventFormScreen({this.event});

  @override
  _EventFormScreenState createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _selectedCategory;
  List categories = [];
  List<Map<String, dynamic>> ticketTypes = [];
  String? _image4x3Base64;
  String? _image16x9Base64;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    if (widget.event != null) {
      _nameController.text = widget.event!['name'];
      _descriptionController.text = widget.event!['description'];
      _startDateController.text = _formatDateTime(widget.event!['startDate']);
      _endDateController.text = _formatDateTime(widget.event!['endDate']);
      _locationController.text = widget.event!['location'];
      _selectedCategory = widget.event!['categoryId'].toString();
      ticketTypes =
          List<Map<String, dynamic>>.from(widget.event!['ticketTypes'] ?? []);
      _image4x3Base64 = widget.event!['image4x3'];
      _image16x9Base64 = widget.event!['image16x9'];
    }
  }

  Future<void> fetchCategories() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/category'));
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> _selectDateTime(
      BuildContext context, TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          controller.text = _formatDateTime(pickedDateTime.toIso8601String());
        });
      }
    }
  }

  String _formatDateTime(String dateTime) {
    final DateTime parsedDateTime = DateTime.parse(dateTime);
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(parsedDateTime);
  }

  DateTime _parseDateTime(String dateTime) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.parse(dateTime);
  }

  Future<void> _pickImage(bool is4x3) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      setState(() {
        if (is4x3) {
          _image4x3Base64 = base64Image;
        } else {
          _image16x9Base64 = base64Image;
        }
      });
    }
  }

  void _addTicketType() {
    setState(() {
      ticketTypes.add({
        'name': '',
        'price': 0.0,
        'totalQuantity': 0,
      });
    });
  }

  void _removeTicketType(int index) {
    setState(() {
      ticketTypes.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final userId = Provider.of<UserProvider>(context, listen: false).user.id;
      final event = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'startDate':
            _parseDateTime(_startDateController.text).toIso8601String(),
        'endDate': _parseDateTime(_endDateController.text).toIso8601String(),
        'location': _locationController.text,
        'categoryId': int.parse(_selectedCategory!),
        'organizerId': userId,
        'ticketTypes': ticketTypes,
        'image4x3': _image4x3Base64,
        'image16x9': _image16x9Base64,
      };
      final response = widget.event == null
          ? await http.post(
              Uri.parse('http://localhost:3000/event'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(event),
            )
          : await http.patch(
              Uri.parse('http://localhost:3000/event/${widget.event!['id']}'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(event),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar o evento')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Criar Evento' : 'Editar Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do evento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descrição'),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a descrição do evento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDateTime(context, _startDateController),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _startDateController,
                    decoration: InputDecoration(
                      labelText: 'Data de Início',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a data de início';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDateTime(context, _endDateController),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _endDateController,
                    decoration: InputDecoration(
                      labelText: 'Data de Término',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a data de término';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Localização'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a localização do evento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                items: categories.map<DropdownMenuItem<String>>((category) {
                  return DropdownMenuItem<String>(
                    value: category['id'].toString(),
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione uma categoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Tipos de Ingressos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...ticketTypes.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> ticketType = entry.value;
                return Column(
                  children: [
                    TextFormField(
                      initialValue: ticketType['name'],
                      decoration:
                          InputDecoration(labelText: 'Nome do Ingresso'),
                      onChanged: (value) {
                        ticketType['name'] = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome do ingresso';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: ticketType['price'].toString(),
                      decoration: InputDecoration(labelText: 'Preço'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        ticketType['price'] = double.parse(value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o preço do ingresso';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: ticketType['totalQuantity'].toString(),
                      decoration:
                          InputDecoration(labelText: 'Quantidade Total'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        ticketType['totalQuantity'] = int.parse(value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a quantidade total de ingressos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _removeTicketType(index),
                      child: Text('Remover Ingresso'),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
              ElevatedButton(
                onPressed: _addTicketType,
                child: Text('Adicionar Tipo de Ingresso'),
              ),
              const SizedBox(height: 16),
              Text(
                'Imagens do Evento',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text('Imagem 4x3'),
                        const SizedBox(height: 8),
                        _image4x3Base64 == null
                            ? Text('Nenhuma imagem selecionada')
                            : Image.memory(base64Decode(_image4x3Base64!)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _pickImage(true),
                          child: Text('Selecionar Imagem'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Text('Imagem 16x9'),
                        const SizedBox(height: 8),
                        _image16x9Base64 == null
                            ? Text('Nenhuma imagem selecionada')
                            : Image.memory(base64Decode(_image16x9Base64!)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _pickImage(false),
                          child: Text('Selecionar Imagem'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.event == null ? 'Criar' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
