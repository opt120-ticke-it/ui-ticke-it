import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ticke_it/screens/event_screen.dart';
import 'dart:convert';

class EventWidget extends StatelessWidget {
  final Map event;

  EventWidget({required this.event});

  String formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(parsedDate);
  }

  bool isValidBase64(String base64String) {
    try {
      base64Decode(base64String);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extrair a imagem 4x3 da lista de imagens
    final image4x3 = event['images']?.firstWhere(
      (image) => image['type'] == '4x3',
      orElse: () => null,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EventScreen(eventId: event['id'])),
        );
      },
      child: Container(
        width: 150,
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: double.infinity,
              color: Colors.white,
              child: image4x3 == null || !isValidBase64(image4x3['base64'])
                  ? Center(child: Text('Sem imagem'))
                  : Image.memory(
                      base64Decode(image4x3['base64']),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(child: Text('Erro ao carregar imagem'));
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    event['name'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Data: ${formatDate(event['startDate'])}',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Local: ${event['location']}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}