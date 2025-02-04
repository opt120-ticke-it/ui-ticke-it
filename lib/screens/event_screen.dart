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
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Selecione o tipo de ingresso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...event['ticketTypes'].map<Widget>((ticketType) {
                return ListTile(
                  title: Text(ticketType['name']),
                  subtitle: Text('Preço: ${ticketType['price']}'),
                  onTap: () {
                    // Lógica para selecionar o ingresso
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network('http://localhost:3000/image16x9/${event['id']}'),
                    SizedBox(height: 16.0),
                    Text(event['name'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.0),
                    Text('Descrição: ${event['description']}'),
                    SizedBox(height: 8.0),
                    Text('Data de Início: ${formatDate(event['startDate'])}'),
                    SizedBox(height: 8.0),
                    Text('Data de Término: ${formatDate(event['endDate'])}'),
                    SizedBox(height: 8.0),
                    Text('Local: ${event['location']}'),
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