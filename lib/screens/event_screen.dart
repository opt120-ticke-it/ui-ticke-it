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
  List ticketTypes = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchEventAndTickets();
  }

  Future<void> fetchEventAndTickets() async {
    try {
      final eventResponse = await http.get(Uri.parse('http://localhost:3000/event/${widget.eventId}'));
      final ticketResponse = await http.get(Uri.parse('http://localhost:3000/event/${widget.eventId}/ticketTypes'));

      if (eventResponse.statusCode == 200 && ticketResponse.statusCode == 200) {
        setState(() {
          event = json.decode(eventResponse.body);
          ticketTypes = json.decode(ticketResponse.body);
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  String formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(parsedDate);
  }

  void showTicketModal() {
    if (ticketTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nenhum ingresso disponível para este evento.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecione o tipo de ingresso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ticketTypes.map<Widget>((ticketType) {
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(ticketType['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Preço: R\$ ${ticketType['price']}'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    showConfirmationDialog(ticketType);
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void showConfirmationDialog(Map ticketType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmação de Ingresso'),
          content: Text('Você selecionou o ingresso "${ticketType['name']}" pelo valor de R\$ ${ticketType['price']}. Deseja continuar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Lógica para finalizar a compra
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Extrair a imagem 16x9 da lista de imagens
    final image16x9 = event['images']?.firstWhere(
      (image) => image['type'] == '16x9',
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Evento', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 48),
                        SizedBox(height: 10),
                        Text(
                          'Erro ao carregar os detalhes do evento.',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: fetchEventAndTickets,
                          child: Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: image16x9 == null
                            ? Container(
                                height: 220,
                                width: double.infinity,
                                color: Colors.grey.shade200,
                                child: Center(child: Text('Sem imagem')),
                              )
                            : Image.memory(
                                base64Decode(image16x9['base64']),
                                width: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 220,
                                    width: double.infinity,
                                    color: Colors.grey.shade200,
                                    child: Center(child: Text('Erro ao carregar imagem')),
                                  );
                                },
                              ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        event['name'],
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        color: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Text(
                            event['description'],
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📅 Data de Início: ${formatDate(event['startDate'])}', style: TextStyle(fontSize: 16)),
                              SizedBox(height: 8),
                              Text('🏁 Data de Término: ${formatDate(event['endDate'])}', style: TextStyle(fontSize: 16)),
                              SizedBox(height: 8),
                              Text('📍 Local: ${event['location']}', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: showTicketModal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 5,
                          ),
                          child: Text('Escolher Ingresso', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}