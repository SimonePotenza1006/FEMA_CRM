import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../model/InterventoModel.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'ScannerBarCodePage.dart';
import 'ScannerQrCodePage.dart';
import 'CompilazioneRapportinoPage.dart'; // Importa il pacchetto per il formato delle date
import 'package:fema_crm/model/RelazioneDdtProdottiModel.dart';


class DettaglioInterventoByTecnicoPage extends StatefulWidget {
  final InterventoModel intervento;

  DettaglioInterventoByTecnicoPage({Key? key, required this.intervento}) : super(key: key);

  @override
  _DettaglioInterventoByTecnicoPageState createState() => _DettaglioInterventoByTecnicoPageState();
}

class _DettaglioInterventoByTecnicoPageState extends State<DettaglioInterventoByTecnicoPage> {
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy'); // Formato della data
  final DateFormat timeFormat = DateFormat('HH:mm');

  List<RelazioneDdtProdottoModel> prodotti = [];


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
                      MaterialPageRoute(builder: (context) => ScannerQrCodePage(intervento: widget.intervento)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16), // Padding interno
                    textStyle: TextStyle(fontSize: 20), // Dimensione del testo
                    primary: Colors.red, // Colore di sfondo del pulsante
                  ),
                  child: Text(
                    'Scannerizza QrCode',
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
}
