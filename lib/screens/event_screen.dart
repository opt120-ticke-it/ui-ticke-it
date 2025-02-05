import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class EventScreen extends StatefulWidget {
  final int eventId;

  EventScreen({required this.eventId});

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  Map event = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEvent();
  }

  Future<void> fetchEvent() async {
    final response = await http.get(Uri.parse('http://localhost:3000/event/${widget.eventId}'));
    if (response.statusCode == 200) {
      setState(() {
        event = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load event');
    }
  }

  String formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(parsedDate);
  }

  void showTicketModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Selecione o tipo de ingresso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...event['ticketTypes'].map<Widget>((ticketType) {
                return ListTile(
                  title: Text(ticketType['name']),
                  subtitle: Text('Preço: ${ticketType['price']}'),
                  onTap: () {
                    Navigator.pop(context);
                    showConfirmationDialog(ticketType['name']);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void showConfirmationDialog(String ticketTypeName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ingresso Adquirido'),
          content: Text('Você adquiriu o ingresso: $ticketTypeName'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Evento'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: event['id'] != null
                          ? Image.network('http://localhost:3000/image16x9/${event['id']}', fit: BoxFit.cover)
                          : Container(), // Box em branco se não encontrar a imagem
                    ),
                    SizedBox(height: 16.0),
                    Text(event['name'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.0),
                    Text('Descrição: ${event['description']}', textAlign: TextAlign.center),
                    SizedBox(height: 8.0),
                    Text('Data de Início: ${formatDate(event['startDate'])}', textAlign: TextAlign.center),
                    SizedBox(height: 8.0),
                    Text('Data de Término: ${formatDate(event['endDate'])}', textAlign: TextAlign.center),
                    SizedBox(height: 8.0),
                    Text('Local: ${event['location']}', textAlign: TextAlign.center),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: showTicketModal,
                      child: Text('Escolher Ingresso'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}