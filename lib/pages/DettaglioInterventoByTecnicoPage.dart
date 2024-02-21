import 'package:flutter/material.dart';
import '../model/InterventoModel.dart';
import 'package:intl/intl.dart';

import 'CompilazioneRapportinoPage.dart'; // Importa il pacchetto per il formato delle date

class DettaglioInterventoByTecnicoPage extends StatelessWidget {
  final InterventoModel intervento;
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy'); // Formato della data

  DettaglioInterventoByTecnicoPage({Key? key, required this.intervento}) : super(key: key);

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
              _buildDetailRow('Data', dateFormat.format(intervento.data ?? DateTime.now())),
              _buildDetailRow('Orario Inizio', intervento.orario_inizio != null ? intervento.orario_inizio!.toString() : 'N/A'),
              _buildDetailRow('Orario Fine', intervento.orario_fine != null ? intervento.orario_fine!.toString() : 'N/A'),
              _buildDetailRow('Descrizione', intervento.descrizione ?? 'N/A'),
              _buildDetailRow('Cliente', intervento.cliente?.denominazione ?? 'N/A'),
              _buildDetailRow('Veicolo', intervento.veicolo?.descrizione ?? 'N/A'),
              _buildDetailRow('Tipologia Intervento', intervento.tipologia?.descrizione ?? 'N/A'),
              _buildDetailRow('Categoria Intervento Specifico', intervento.categoria_intervento_specifico?.descrizione ?? 'N/A'),
              _buildDetailRow('Destinazione', intervento.destinazione?.indirizzo ?? 'N/A'),
              SizedBox(height: 20), // Spazio tra gli ultimi dettagli e il pulsante
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CompilazioneRapportinoPage(intervento: intervento))
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
