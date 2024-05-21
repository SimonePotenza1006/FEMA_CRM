import 'package:fema_crm/model/VeicoloModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'ModificaInfoVeicoloPage.dart';

class DettaglioVeicoloPage extends StatefulWidget {
  final VeicoloModel veicolo;

  const DettaglioVeicoloPage({Key? key, required this.veicolo}) : super(key: key);

  @override
  _DettaglioVeicoloPageState createState() => _DettaglioVeicoloPageState();
}

class _DettaglioVeicoloPageState extends State<DettaglioVeicoloPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dettaglio ${widget.veicolo.descrizione}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: double.infinity),
          child: SingleChildScrollView(
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: Column(
                    children: [
                      _buildInfoText('Proprietario : ${widget.veicolo.proprietario}'),
                      _buildInfoText('Chilometraggio attuale : ${widget.veicolo.chilometraggio_attuale} km'),
                      _buildInfoText('Data ultima revisione: ${widget.veicolo.data_revisione}'),
                      _buildInfoText('Data scadenza Bollo : ${widget.veicolo.data_scadenza_bollo}'),
                      _buildInfoText('Data scadenza polizza assicurativa : ${widget.veicolo.data_scadenza_polizza}'),
                      SizedBox(height: 20),
                      _buildInfoText('Data ultimo tagliando : ${widget.veicolo.data_tagliando}'),
                      _buildInfoText('Chilometraggio all\'ultimo tagliando : ${widget.veicolo.chilometraggio_ultimo_tagliando} km'),
                      _buildInfoText('Chilometri da effettuare prima del prossimo tagliando : ${widget.veicolo.soglia_tagliando} km'),
                      SizedBox(height: 20),
                      _buildInfoText('Data ultima sostituzione gomme : ${widget.veicolo.data_sostituzione_gomme}'),
                      _buildInfoText('Chilometraggio all\'ultima sostituzione gomme : ${widget.veicolo.chilometraggio_ultima_sostituzione} km'),
                      _buildInfoText('Chilometri da effettuare prima della prossima sostituzione : ${widget.veicolo.soglia_sostituzione} km'),
                      SizedBox(height: 20),
                      _buildInfoText('Data ultima inversione gomme : ${widget.veicolo.data_inversione_gomme}'),
                      _buildInfoText('Chilometraggio all\'ultima inversione gomme : ${widget.veicolo.chilometraggio_ultima_inversione} km'),
                      _buildInfoText('Chilometri da effettuare prima della prossima inversione : ${widget.veicolo.soglia_inversione} km'),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ModificaInfoVeicoloPage(veicolo: widget.veicolo)),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      ),
                    ),
                    child: Text(
                      'Modifica',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildInfoText(String text) {
    // Divide il testo in due parti: etichetta e dato
    final parts = text.split(':');
    final labelText = parts[0];
    var dataText = parts[1];

    // Format the date
    if (labelText.contains('Data')) {
      final dateFormat = DateFormat('dd/MM/yyyy');
      final date = DateTime.parse(dataText.trim());
      dataText = dateFormat.format(date);
    }

    return Column(
      children: [
        Row(
          children: [
            Text(
              '$labelText: ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              dataText, // Rimuove eventuali spazi bianchi aggiunti
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
        Divider(color: Colors.grey[300], thickness: 0.5),
      ],
    );
  }
}