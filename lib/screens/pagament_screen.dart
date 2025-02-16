import 'package:flutter/material.dart';
import 'package:ticke_it/screens/home_screen.dart';

class PagamentScreen extends StatefulWidget {
  const PagamentScreen({super.key, required this.data});
  final Map<String, dynamic> data;
  @override
  State<PagamentScreen> createState() => _PagamentScreenState();
}

class _PagamentScreenState extends State<PagamentScreen> {
  Future<String?> show_alert_dialog(String pagament) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Pagamento $pagament'),
        content: const Text('Deseja Aceitar Esta Opção De Pagamento'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () {
              if (pagament=="PIX") {
                _showQRCodeDialog(context);
              }
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showQRCodeDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('PIX QR Code'),
          content: Image.asset("lib/img/HtHId.png"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (ctx) => HomeScreen())),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
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
                onPressed: () => show_alert_dialog("Cartão"),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                        color: Colors.white,
                        size: query.height * 0.04,
                        Icons.wysiwyg_sharp),
                    SizedBox(
                      width: query.width * 0.025,
                    ),
                    Text(
                      "Cartão",
                      style: TextStyle(fontSize: 20),
                    )
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
                onPressed: () => show_alert_dialog("PIX"),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                        color: Colors.white,
                        size: query.height * 0.04,
                        Icons.pix_sharp),
                    SizedBox(
                      width: query.width * 0.025,
                    ),
                    const Text(
                      "PIX",
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
