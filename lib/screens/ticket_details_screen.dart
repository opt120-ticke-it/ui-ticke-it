import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketDetailsScreen extends StatelessWidget {
  final Map ticket;

  TicketDetailsScreen({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final event = ticket['event'];
    final ticketType = ticket['ticketType'];

    // Formatar a data
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    final String formattedStartDate = formatter.format(DateTime.parse(event['startDate']));
    final String formattedEndDate = formatter.format(DateTime.parse(event['endDate']));

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Ingresso'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'Descrição: ${event['description']}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 16.0),
            Text(
              'Tipo de Ingresso: ${ticketType['name']}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 16.0),
            Text(
              'Data de Início: $formattedStartDate',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 16.0),
            Text(
              'Data de Término: $formattedEndDate',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 16.0),
            Text(
              'Local: ${event['location']}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 16.0),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                  },
                  child: Text('Abrir QR Code'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Ação para transferir o ingresso
                  },
                  child: Text('Transferir Ingresso'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}