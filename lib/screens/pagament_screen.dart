import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ticke_it/screens/home_screen.dart';

class PagamentScreen extends StatefulWidget {
  const PagamentScreen({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  State<PagamentScreen> createState() => _PagamentScreenState();
}

class _PagamentScreenState extends State<PagamentScreen> {
  Future<void> showAlertDialog(String paymentMethod) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Pagamento $paymentMethod'),
        content: const Text('Deseja Aceitar Esta Opção De Pagamento'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (paymentMethod == "PIX") {
                _showQRCodeDialog(context);
                _submitPayment();
              } else if (paymentMethod == "Cartão") {
                _showCardPaymentDialog(context);
              }
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }

  Future<void> _showQRCodeDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('PIX QR Code'),
          content: Image.asset("lib/img/HtHId.png"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (ctx) => HomeScreen()),
                );
              },
              child: Text('Concluído'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCardPaymentDialog(BuildContext context) async {
    final TextEditingController cardNumberController = TextEditingController();
    final TextEditingController expiryDateController = TextEditingController();
    final TextEditingController cvvController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Informações do Cartão'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cardNumberController,
                decoration: InputDecoration(labelText: 'Número do Cartão'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: expiryDateController,
                decoration: InputDecoration(labelText: 'Data de Validade'),
                keyboardType: TextInputType.datetime,
              ),
              TextField(
                controller: cvvController,
                decoration: InputDecoration(labelText: 'CVV'),
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitPayment();
              },
              child: Text('Confirmar Cartão'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitPayment() async {
    final userId = widget.data['userId'];
    final eventId = widget.data['event']['id'];
    final ticketTypeId = widget.data['ticketType']['id'];

    final response = await http.post(
      Uri.parse('http://localhost:3000/ticket'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'eventId': eventId,
        'ticketTypeId': ticketTypeId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pagamento realizado com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao realizar o pagamento.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (ctx) => HomeScreen()),
          ),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Pagamento',
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        toolbarHeight: query.height * 0.09,
      ),
      body: ListView(
        children: [
          SizedBox(
            height: query.height * 0.2,
          ),
          Padding(
            padding: const EdgeInsets.all(96.0),
            child: Container(
              height: query.height * 0.06,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => showAlertDialog("Cartão"),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      color: Colors.white,
                      size: query.height * 0.04,
                      Icons.wysiwyg_sharp,
                    ),
                    SizedBox(
                      width: query.width * 0.025,
                    ),
                    Text(
                      "Cartão",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: query.height * 0.0005,
          ),
          Padding(
            padding: const EdgeInsets.all(96.0),
            child: Container(
              height: query.height * 0.06,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => showAlertDialog("PIX"),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      color: Colors.white,
                      size: query.height * 0.04,
                      Icons.pix_sharp,
                    ),
                    SizedBox(
                      width: query.width * 0.025,
                    ),
                    const Text(
                      "PIX",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}