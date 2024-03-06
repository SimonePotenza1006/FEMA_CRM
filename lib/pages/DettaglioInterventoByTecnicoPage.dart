import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../model/InterventoModel.dart';
import 'package:intl/intl.dart';
import 'CompilazioneDDTByTecnicoPage.dart';
import 'package:http/http.dart' as http;
import 'ScannerBarCodePage.dart';
import 'ScannerQrCodePage.dart';
import 'CompilazioneRapportinoPage.dart'; // Importa il pacchetto per il formato delle date

class DettaglioInterventoByTecnicoPage extends StatefulWidget {
  final InterventoModel intervento;

  DettaglioInterventoByTecnicoPage({Key? key, required this.intervento}) : super(key: key);

  @override
  _DettaglioInterventoByTecnicoPageState createState() => _DettaglioInterventoByTecnicoPageState();
}

class _DettaglioInterventoByTecnicoPageState extends State<DettaglioInterventoByTecnicoPage> {
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy'); // Formato della data
  final DateFormat timeFormat = DateFormat('HH:mm');


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dettaglio Intervento',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              _buildDetailRow('Data', dateFormat.format(widget.intervento.data ?? DateTime.now())),
              _buildDetailRow('Orario Inizio', widget.intervento.orario_inizio != null ? timeFormat.format(widget.intervento.orario_inizio!) : 'N/A'),
              _buildDetailRow('Orario Fine', widget.intervento.orario_fine != null ? timeFormat.format(widget.intervento.orario_fine!) : 'N/A'),
              _buildDetailRow('Descrizione', widget.intervento.descrizione ?? 'N/A'),
              _buildDetailRow('Cliente', widget.intervento.cliente?.denominazione ?? 'N/A'),
              _buildDetailRow('Veicolo', widget.intervento.veicolo?.descrizione ?? 'N/A'),
              _buildDetailRow('Tipologia Intervento', widget.intervento.tipologia?.descrizione ?? 'N/A'),
              _buildDetailRow('Categoria Intervento Specifico', widget.intervento.categoria_intervento_specifico?.descrizione ?? 'N/A'),
              _buildDetailRow('Destinazione', widget.intervento.destinazione?.indirizzo ?? 'N/A'),
              SizedBox(height: 20), // Spazio tra gli ultimi dettagli e il pulsante
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CompilazioneDDTByTecnicoPage(intervento: widget.intervento)),
                    );
                    savePrimeDDT();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16), // Padding interno
                    textStyle: TextStyle(fontSize: 20), // Dimensione del testo
                    primary: Colors.red, // Colore di sfondo del pulsante
                  ),
                  child: Text(
                    'Allega DDT',
                    style: TextStyle(color: Colors.white), // Colore del testo
                  ),
                ),
              ),

              SizedBox(height: 20), // Spazio tra gli ultimi dettagli e il pulsante
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CompilazioneRapportinoPage(intervento: widget.intervento)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16), // Padding interno
                    textStyle: TextStyle(fontSize: 20), // Dimensione del testo
                    primary: Colors.red, // Colore di sfondo del pulsante
                  ),
                  child: Text(
                    'Compila rapportino',
                    style: TextStyle(color: Colors.white), // Colore del testo
                  ),
                ),
              ),
              SizedBox(height: 20), // Spazio tra gli ultimi dettagli e il pulsante
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ScannerBarCodePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16), // Padding interno
                    textStyle: TextStyle(fontSize: 20), // Dimensione del testo
                    primary: Colors.red, // Colore di sfondo del pulsante
                  ),
                  child: Text(
                    'Scanner Barcode',
                    style: TextStyle(color: Colors.white), // Colore del testo
                  ),
                ),
              ),
            ],

          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Future<void> savePrimeDDT() async {
    try {
      Map<String, dynamic> body = {
        'data': widget.intervento.data?.toIso8601String(),
        'orario': DateTime.now().toIso8601String(),
        'concluso': false,
        'firmaUser': null,
        'imageData': null,
        'cliente': widget.intervento.cliente?.toMap(),
        'destinazione': widget.intervento.destinazione?.toMap(),
        'categoriaDdt': {
          'id': 1,
          'descrizione': "DDT Intervento"
        },
        'utente': widget.intervento.utente?.toMap(),
        'intervento': widget.intervento.toMap(),
        'relazioni_prodotti': null,
      };

      debugPrint('Body della richiesta: $body', wrapWidth: 1024);

      final response = await http.post(
        Uri.parse('http://192.168.1.52:8080/api/ddt'),
        body: jsonEncode(body),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('Risposta: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        print('DDT inizializzato, daje');
      } else {
        print('Qualcosa non va');
      }
    } catch (e) {
      print('Errore: $e');
    }
  }

}
