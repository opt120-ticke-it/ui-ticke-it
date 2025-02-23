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
  List<Map<String, dynamic>> newTicketTypes = [];
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
      final newTicketType = {
        'name': '',
        'price': 0.0,
        'totalQuantity': 0,
      };
      newTicketTypes.add(newTicketType);
      ticketTypes.add(newTicketType);
    });
  }

  void _removeNewTicketType(Map<String, dynamic> ticketType) {
    setState(() {
      newTicketTypes.remove(ticketType);
      ticketTypes.remove(ticketType);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final userId =
            Provider.of<UserProvider>(context, listen: false).user.id;
        if (_selectedCategory == null) {
          throw Exception('Categoria não selecionada');
        }
        final event = {
          'id': widget.event != null ? widget.event!['id'] : null,
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
                body: jsonEncode(
                    event..removeWhere((key, value) => value == null)),
              );

        if (response.statusCode == 200 || response.statusCode == 201) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar o evento')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco da tela
      appBar: AppBar(
        title: Text(
          widget.event == null ? 'Criar Evento' : 'Editar Evento',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white, // Cor branca para o Card
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Nome
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome do evento';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Descrição
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
                  // Data de Início
                  GestureDetector(
                    onTap: () => _selectDateTime(context, _startDateController),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _startDateController,
                        decoration: InputDecoration(
                          labelText: 'Data de Início',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                  // Data de Término
                  GestureDetector(
                    onTap: () => _selectDateTime(context, _endDateController),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _endDateController,
                        decoration: InputDecoration(
                          labelText: 'Data de Término',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                  // Localização
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Localização',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a localização do evento';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Categoria
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                  // Tipos de Ingressos
                  Text(
                    'Tipos de Ingressos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  ...ticketTypes.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> ticketType = entry.value;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cabeçalho do ingresso
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ingresso ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (newTicketTypes.contains(ticketType))
                                  IconButton(
                                    onPressed: () =>
                                        _removeNewTicketType(ticketType),
                                    icon: Icon(Icons.delete, color: Colors.red),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Campo para nome
                            TextFormField(
                              initialValue: ticketType['name'],
                              decoration: InputDecoration(
                                labelText: 'Nome',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
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
                            // Linha com preço e quantidade
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue:
                                        ticketType['price'].toString(),
                                    decoration: InputDecoration(
                                      labelText: 'Preço',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      ticketType['price'] =
                                          double.tryParse(value) ?? 0.0;
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Insira o preço';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    initialValue:
                                        ticketType['totalQuantity'].toString(),
                                    decoration: InputDecoration(
                                      labelText: 'Quantidade',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      ticketType['totalQuantity'] =
                                          int.tryParse(value) ?? 0;
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Insira a quantidade';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  ElevatedButton(
                    onPressed: _addTicketType,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white, // Texto branco
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Adicionar Tipo de Ingresso'),
                  ),
                  const SizedBox(height: 16),
                  // Imagens do Evento
                  Text(
                    'Imagens do Evento',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text('Imagem 4x3'),
                            const SizedBox(height: 8),
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _image4x3Base64 == null
                                  ? Center(child: Text('Nenhuma imagem'))
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        base64Decode(_image4x3Base64!),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _pickImage(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text('Selecionar'),
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
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _image16x9Base64 == null
                                  ? Center(child: Text('Nenhuma imagem'))
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        base64Decode(_image16x9Base64!),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _pickImage(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text('Selecionar'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      widget.event == null ? 'Criar Evento' : 'Salvar Evento',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
