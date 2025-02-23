import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:ticke_it/providers/user_provider.dart';

// ✅ Criar um formatter para CPF
class CPFInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (text.length > 11) {
      text = text.substring(0, 11);
    }

    String formattedText = '';
    if (text.length > 3) {
      formattedText = text.substring(0, 3) + '.';
      if (text.length > 6) {
        formattedText += text.substring(3, 6) + '.';
        if (text.length > 9) {
          formattedText += text.substring(6, 9) + '-';
          formattedText += text.substring(9);
        } else {
          formattedText += text.substring(6);
        }
      } else {
        formattedText += text.substring(3);
      }
    } else {
      formattedText = text;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class TransferTicketScreen extends StatefulWidget {
  final Map ticket;

  TransferTicketScreen({required this.ticket});

  @override
  _TransferTicketScreenState createState() => _TransferTicketScreenState();
}

class _TransferTicketScreenState extends State<TransferTicketScreen> {
  final TextEditingController _receiverCpfController = TextEditingController();
  bool _isTransferring = false;

  Future<void> _showConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.black, width: 2),
          ),
          title: Text(
            'Confirmar Transferência',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: Text(
            'Tem certeza de que deseja transferir este ingresso?',
            style: TextStyle(color: Colors.black87, fontSize: 16),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                transferTicket();
              },
              child: Text(
                'Confirmar',
                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> transferTicket() async {
    final originUserId = Provider.of<UserProvider>(context, listen: false).user.id;
    final destinationUserCpf = _receiverCpfController.text.trim();
    final ticketId = widget.ticket['id'];

    if (destinationUserCpf.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Digite um CPF válido.')),
      );
      return;
    }

    setState(() {
      _isTransferring = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/ticket/transfer'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ticketId': ticketId,
          'originUserId': originUserId,
          'destinationUserCpf': destinationUserCpf,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ingresso transferido com sucesso!')),
        );
        Navigator.pop(context, true);
      } else {
        final errorMessage = json.decode(response.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $errorMessage')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão. Tente novamente.')),
      );
    }

    setState(() {
      _isTransferring = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transferir Ingresso', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.black, width: 2),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ingresso: ${widget.ticket['id']}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _receiverCpfController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CPFInputFormatter()],
                      decoration: InputDecoration(
                        labelText: 'CPF do Usuário Destinatário',
                        labelStyle: TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _isTransferring ? null : _showConfirmationDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isTransferring
                    ? CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.send, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Transferir', style: TextStyle(color: Colors.white)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
