import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ticke_it/screens/transfer_ticket_screen.dart';

class TicketDetailsScreen extends StatefulWidget {
  final Map ticket;

  TicketDetailsScreen({required this.ticket});

  @override
  _TicketDetailsScreenState createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  late Map ticket;

  @override
  void initState() {
    super.initState();
    // Clona o ticket para evitar mutação direta
    ticket = {...widget.ticket};
  }

  @override
  Widget build(BuildContext context) {
    final event = ticket['event'];
    final ticketType = ticket['ticketType'];

    // Formatar a data
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    final String formattedStartDate =
        formatter.format(DateTime.parse(event['startDate']));
    final String formattedEndDate =
        formatter.format(DateTime.parse(event['endDate']));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalhes do Ingresso',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Color.fromARGB(255, 255, 255, 255), // Fundo geral um pouco mais escuro
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildEventDetails(
              event,
              ticketType,
              formattedStartDate,
              formattedEndDate,
            ),
            const SizedBox(height: 16.0),
            _buildTicketStatus(),
            const Spacer(),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEventDetails(
    Map event,
    Map ticketType,
    String startDate,
    String endDate,
  ) {
    return Card(
      color: Colors.white, // Card claro para o texto preto ficar visível
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        // Aqui estão os "detalhes", então texto em preto
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['name'] ?? '',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Nome do evento em preto (faz parte dos detalhes)
              ),
            ),
            SizedBox(height: 10),
            _buildDetailRow(
              Icons.description,
              'Descrição:',
              event['description'] ?? '',
            ),
            _buildDetailRow(
              Icons.confirmation_number,
              'Tipo de Ingresso:',
              ticketType['name'] ?? '',
            ),
            _buildDetailRow(Icons.date_range, 'Início:', startDate),
            _buildDetailRow(Icons.event, 'Término:', endDate),
            _buildDetailRow(
              Icons.location_on,
              'Local:',
              event['location'] ?? '',
            ),
          ],
        ),
      ),
    );
  }

  /// Cada linha de detalhe fica em preto
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Se o ingresso já foi transferido, exibe essa mensagem
  Widget _buildTicketStatus() {
    if (ticket['transferred'] == true) {
      return Card(
        color: Colors.red[400],
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Ingresso Transferido!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // texto branco aqui
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  /// Botões pretos com texto branco
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.qr_code, color: Colors.white),
          label: Text('Ver QR Code', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => _showQRCodeDialog(context),
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.send, color: Colors.white),
          label: Text('Transferir', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransferTicketScreen(ticket: ticket),
              ),
            );

            if (result == true) {
              setState(() {
                ticket = {...ticket, 'transferred': true}; // Atualiza o estado
              });
            }
          },
        ),
      ],
    );
  }

  void _showQRCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black, // Fundo preto
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'QR Code',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Texto branco
                  ),
                ),
                SizedBox(height: 16),
                // Mantemos o QR code normal
                QrImageView(
                  data: ticket['qrCode'],
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white, // Para destacar o QR do fundo preto
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Fechar',
                    style: TextStyle(color: Colors.white),
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
