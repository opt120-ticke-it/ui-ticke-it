import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // Para verificar se é Web

import 'package:ticke_it/screens/event_details_screen.dart';

class QRScannerScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const QRScannerScreen({super.key, required this.data});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? lastCodeResult;
  bool isProcessing = false; // Flag para evitar múltiplas requisições

  @override
  void reassemble() {
    super.reassemble();
    if (!kIsWeb) {
      // Só pausa a câmera em dispositivos móveis
      if (Platform.isAndroid) {
        controller?.pauseCamera();
      } else if (Platform.isIOS) {
        controller?.resumeCamera();
      }
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      print("📸 Código escaneado: ${scanData.code}");

      if (scanData.code == null || isProcessing) {
        print("⚠️ Ignorando código: isProcessing=$isProcessing");
        return;
      }

      // Se o código for o mesmo do último, ignoramos para evitar reprocessamento
      if (scanData.code == lastCodeResult) {
        print("🔁 Código já escaneado anteriormente: ${scanData.code}");
        return;
      }

      // Atualiza flag de processamento
      setState(() {
        isProcessing = true;
        lastCodeResult = scanData.code;
      });

      // Tenta pausar a câmera somente em dispositivos móveis
      if (!kIsWeb) {
        await controller.pauseCamera();
      }

      bool isValid = await _validateTicket(scanData.code!);

      // Aguarda 1,5s antes de liberar a câmera novamente
      Future.delayed(Duration(milliseconds: 1500), () async {
        print("▶️ Retomando scanner...");
        setState(() {
          isProcessing = false;
        });

        if (!kIsWeb) {
          await controller.resumeCamera();
        }
      });

      // Se o ticket for válido, navega para a tela de detalhes do evento
      if (isValid) {
        print("✅ Ticket válido, navegando para detalhes do evento...");
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EventDetailsScreen(eventId: widget.data['event']['id']),
            ),
          );
        }
      } else {
        print("❌ Ticket inválido, exibindo mensagem...");
      }
    });
  }

  Future<bool> _validateTicket(String code) async {
    final userId = widget.data['userId'];
    final eventId = widget.data['event']['id'];

    try {
      print("📡 Enviando requisição para validar ticket...");
      final response = await http.post(
        Uri.parse('http://localhost:3000/ticket/validate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {"ticketCode": code, "eventId": eventId, "validatorId": userId}),
      );

      if (response.statusCode == 200) {
        print("✅ Ticket validado com sucesso!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Ticket válido!')),
        );
        return true;
      } else {
        print("❌ Ticket inválido: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ ${response.body}')),
        );
        return false;
      }
    } catch (e) {
      print("❌ Erro ao validar ticket: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro na validação do ticket')),
      );
      return false;
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Escanear QR Code')),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 250,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
