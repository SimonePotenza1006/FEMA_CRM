import 'dart:convert';
import 'package:fema_crm/pages/HomeFormAmministrazioneNewPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fema_crm/model/CommissioneModel.dart';

class DettaglioCommissioneAmministrazionePage extends StatefulWidget {
  final CommissioneModel commissione;

  DettaglioCommissioneAmministrazionePage({Key? key, required this.commissione})
      : super(key: key);

  @override
  _DettaglioCommissioneAmministrazionePageState createState() =>
      _DettaglioCommissioneAmministrazionePageState();
}

class _DettaglioCommissioneAmministrazionePageState
    extends State<DettaglioCommissioneAmministrazionePage> {
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';

  @override
  Widget build(BuildContext context) {
    String formattedDataCreazione = DateFormat('dd/MM/yyyy HH:mm')
        .format(widget.commissione.data_creazione ?? DateTime.now());
    String formattedData = DateFormat('dd/MM/yyyy HH:mm')
        .format(widget.commissione.data ?? DateTime.now());
    String? descrizione = widget.commissione.descrizione != null
        ? widget.commissione.descrizione
        : 'NESSUNA DESCRIZIONE DISPONIBILE';
    String? nota = widget.commissione.note != null
        ? widget.commissione.note
        : 'NESSUNA NOTA DISPONIBILE';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dettaglio commissione',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              child: ListTile(
                title: Text(
                  'Data creazione:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  formattedDataCreazione,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: ListTile(
                title: Text(
                  'Data:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  formattedData,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: ListTile(
                title: Text(
                  'Descrizione:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  descrizione.toString(),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: ListTile(
                title: Text(
                  'Note:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  nota.toString(),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: concludiCommissione,
        backgroundColor: Colors.red,
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> concludiCommissione() async {
    final url = Uri.parse('$ipaddress/api/commissione');
    final body = jsonEncode({
      'id': widget.commissione.id,
      'data_creazione': widget.commissione.data_creazione?.toIso8601String(),
      'data': widget.commissione.data?.toIso8601String(),
      'descrizione': widget.commissione.descrizione,
      'concluso': true,
      'note': widget.commissione.note,
      'utente': widget.commissione.utente
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        print('Commissione completata!');
        Navigator.pop(context);
        String userId = widget.commissione.utente.toString();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeFormAmministrazioneNewPage(
              userData: widget.commissione.utente!,
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