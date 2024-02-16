import 'package:fema_crm/model/CredenzialiClienteModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DettaglioCredenzialiPage extends StatefulWidget {
  final CredenzialiClienteModel credenziale;

  const DettaglioCredenzialiPage({Key? key, required this.credenziale}) : super(key: key);

  @override
  _DettaglioCredenzialiPageState createState() => _DettaglioCredenzialiPageState();
}

class _DettaglioCredenzialiPageState extends State<DettaglioCredenzialiPage>{


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dettaglio credenziali',
        style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cliente: ${widget.credenziale.cliente?.denominazione}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Utente incaricato: ${widget.credenziale.utente?.cognome}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Credenziali: ${widget.credenziale.descrizione}',
              style: const TextStyle(fontSize: 20),
            )
          ],
        )
      ),
    );
  }
}