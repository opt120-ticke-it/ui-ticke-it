import 'package:flutter/material.dart';
import 'package:ticke_it/screens/event_form_screen.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:ticke_it/screens/ticket_validation_screen.dart';
import 'package:provider/provider.dart';
import 'package:ticke_it/providers/user_provider.dart';

class EventDetailsScreen extends StatefulWidget {
  final int eventId;

  EventDetailsScreen({required this.eventId});

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  Map event = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEventDetails();
  }

  Future<void> fetchEventDetails() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/event/${widget.eventId}'),
    );
    if (response.statusCode == 200) {
      setState(() {
        event = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load event details');
    }
  }

  void _navigateToEditEventScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventFormScreen(event: event),
      ),
    );
    if (result == true) {
      fetchEventDetails();
    }
  }

  void _navigateToQrcodeScannerScreen() {
    final userId = Provider.of<UserProvider>(context, listen: false).user.id;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(
          data: {
            'userId': userId,
            'event': event,
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image16x9 = event['images']?.firstWhere(
      (image) => image['type'] == '16x9',
      orElse: () => null,
    );

    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    final String formattedStartDate = event.isNotEmpty
        ? formatter.format(DateTime.parse(event['startDate']))
        : '';
    final String formattedEndDate = event.isNotEmpty
        ? formatter.format(DateTime.parse(event['endDate']))
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Evento'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagem do evento em formato 16x9
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: image16x9 == null
                          ? Center(child: Text('Sem imagem'))
                          : Image.memory(
                              base64Decode(image16x9['base64']),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Dados do evento
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['name'] ?? '',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Divider(height: 20, thickness: 1),
                          _buildDetailRow('Início:', formattedStartDate),
                          _buildDetailRow('Término:', formattedEndDate),
                          _buildDetailRow('Local:', event['location'] ?? ''),
                          SizedBox(height: 8),
                          Text(
                            'Descrição:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            event['description'] ?? '',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Botões de ação
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _navigateToEditEventScreen,
                        child: Text('Editar Evento'),
                      ),
                      ElevatedButton(
                        onPressed: _navigateToQrcodeScannerScreen,
                        child: Text('Validar Ingresso'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
