import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ticke_it/screens/event_screen.dart';

class EventWidget extends StatelessWidget {
  final Map event;

  EventWidget({required this.event});

  Future<String> fetchImage(int eventId) async {
    final response = await http.get(Uri.parse('http://localhost:3000/image4x3/$eventId'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return ''; // Retorna string vazia se não encontrar a imagem
    }
  }

  String formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchImage(event['id']),
      builder: (context, snapshot) {
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
                  color: Colors.grey.shade200,
                  child: snapshot.connectionState == ConnectionState.waiting
                      ? Center(child: CircularProgressIndicator())
                      : snapshot.hasError || snapshot.data == ''
                          ? Container() // Box em branco se não encontrar a imagem
                          : Image.network(snapshot.data as String, fit: BoxFit.cover),
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
      },
    );
  }
}