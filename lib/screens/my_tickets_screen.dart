import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:ticke_it/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:ticke_it/screens/ticket_details_screen.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  _MyTicketsScreenState createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  List tickets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user.id;
    final response = await http.get(Uri.parse('http://localhost:3000/user/$userId/tickets'));
    if (response.statusCode == 200) {
      setState(() {
        tickets = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load tickets');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Ingressos'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchTickets,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tickets.isEmpty
              ? Center(child: Text('Não foi encontrado nenhum ingresso'))
              : ListView.builder(
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    return TicketItem(ticket: tickets[index]);
                  },
                ),
    );
  }
}

class TicketItem extends StatelessWidget {
  final Map ticket;

  TicketItem({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final event = ticket['event'];
    final ticketType = ticket['ticketType'];

    // Formatar a data
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    final String formattedStartDate = formatter.format(DateTime.parse(event['startDate']));

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetailsScreen(ticket: ticket),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
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
                'Tipo de Ingresso: ${ticketType['name']}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 4.0),
              Text(
                'Data: $formattedStartDate',
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
      ),
    );
  }
}