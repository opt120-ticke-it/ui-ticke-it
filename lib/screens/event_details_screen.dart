import 'package:flutter/material.dart';
import 'package:ticke_it/screens/event_form_screen.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class EventDetailsScreen extends StatelessWidget {
  final Map event;

  EventDetailsScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    // Extrair as imagens 4x3 e 16x9 da lista de imagens
    final image4x3 = event['images']?.firstWhere(
      (image) => image['type'] == '4x3',
      orElse: () => null,
    );
    final image16x9 = event['images']?.firstWhere(
      (image) => image['type'] == '16x9',
      orElse: () => null,
    );

    // Formatar a data
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    final String formattedStartDate = formatter.format(DateTime.parse(event['startDate']));
    final String formattedEndDate = formatter.format(DateTime.parse(event['endDate']));

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: image4x3 == null
                  ? Center(child: Text('Sem imagem'))
                  : Image.memory(
                      base64Decode(image4x3['base64']),
                      fit: BoxFit.contain,
                    ),
            ),
            SizedBox(height: 16.0),
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: image16x9 == null
                  ? Center(child: Text('Sem imagem'))
                  : Image.memory(
                      base64Decode(image16x9['base64']),
                      fit: BoxFit.contain,
                    ),
            ),
            SizedBox(height: 16.0),
            Text(
              event['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Data de Início: $formattedStartDate',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 8.0),
            Text(
              'Data de Término: $formattedEndDate',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 8.0),
            Text(
              'Local: ${event['location']}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 8.0),
            Text(
              'Descrição:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              event['description'],
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventFormScreen(event: event),
                      ),
                    );
                  },
                  child: Text('Editar Evento'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Função de validar ingresso será implementada mais tarde
                  },
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