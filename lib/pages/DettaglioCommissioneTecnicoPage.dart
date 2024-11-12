import 'dart:convert';

import 'package:fema_crm/pages/HomeFormTecnicoNewPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Importo il pacchetto per formattare le date
import 'package:fema_crm/model/CommissioneModel.dart';

class DettaglioCommissioneTecnicoPage extends StatefulWidget {
  final CommissioneModel commissione;

  const DettaglioCommissioneTecnicoPage({Key? key, required this.commissione})
      : super(key: key);

  @override
  _DettaglioCommissioneTecnicoPageState createState() =>
      _DettaglioCommissioneTecnicoPageState();
}

class _DettaglioCommissioneTecnicoPageState
    extends State<DettaglioCommissioneTecnicoPage> {
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';

  @override
  Widget build(BuildContext context) {
    // Formattazione delle date
    String formattedDataCreazione = widget.commissione.data_creazione != null
        ? DateFormat('dd/MM/yyyy HH:mm')
            .format(widget.commissione.data_creazione!)
        : 'N/D';
    String formattedData = widget.commissione.data != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(widget.commissione.data!)
        : 'N/D';

    return Scaffold(
      appBar: AppBar(
        title: Text('Dettaglio commissione',
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
              'Data creazione: $formattedDataCreazione',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Data: $formattedData',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Descrizione: ${widget.commissione.descrizione}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Note: ${widget.commissione.note}',
              style: const TextStyle(fontSize: 20),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            concludiCommissione();
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.red, // Colore di sfondo rosso
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // Bordi arrotondati
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(17.0),
            child: Text(
              'Commissione conclusa',
              style: TextStyle(
                color: Colors.white, // Testo bianco
                fontSize: 18.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> concludiCommissione() async {
    final url = Uri.parse('$ipaddressProva/api/commissione');
    final body = jsonEncode({
      'id': widget.commissione.id,
      'data_creazione': widget.commissione.data_creazione?.toIso8601String(),
      'data': widget.commissione.data?.toIso8601String(),
      'priorita' : widget.commissione.priorita.toString().split('.').last,
      'descrizione': widget.commissione.descrizione,
      'concluso': true,
      'note': widget.commissione.note,
      'utente': widget.commissione.utente,
      'intervento' : widget.commissione.intervento?.toMap(),
      'attivo' : widget.commissione.attivo
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 201) {
        print('Commissione completata!');
        // Torna alla pagina precedente
        Navigator.pop(context);
        // Aggiorna le commissioni chiamando il metodo getAllCommissioniByUtente
        String userId = widget.commissione.utente.toString();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeFormTecnicoNewPage(
              userData: widget.commissione.utente,
            ),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Commissione completata!'),
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        throw Exception('Errore durante la creazione della commissione');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
    }
  }
}
