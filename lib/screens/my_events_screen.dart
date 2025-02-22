import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:ticke_it/providers/user_provider.dart';
import 'package:ticke_it/screens/event_form_screen.dart';
import 'package:ticke_it/screens/event_details_screen.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  _MyEventsScreenState createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  List events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user.id;
    final response = await http.get(Uri.parse('http://localhost:3000/user/$userId/events'));
    if (response.statusCode == 200) {
      setState(() {
        events = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load events');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Eventos'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventFormScreen()),
              ).then((_) => fetchEvents());
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchEvents,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : events.isEmpty
              ? Center(child: Text('Não foi encontrado nenhum evento'))
              : ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return EventItem(event: events[index]);
                  },
                ),
    );
  }
}

class EventItem extends StatelessWidget {
  final Map event;

  EventItem({required this.event});

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
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(eventId: event['id']),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: image4x3 == null
                  ? Center(child: Text('Sem imagem'))
                  : Image.memory(
                      base64Decode(image4x3['base64']),
                      fit: BoxFit.cover,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['name'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Data: ${event['startDate']}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Local: ${event['location']}',
                    style: TextStyle(color: Colors.grey[600]),
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