import 'dart:convert';

import 'package:fema_crm/model/MerceInRiparazioneModel.dart';
import 'package:flutter/material.dart';
import '../model/InterventoModel.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CompilazionePreventivoMerceInRiparazionePage extends StatefulWidget{
  final MerceInRiparazioneModel merce;

  CompilazionePreventivoMerceInRiparazionePage({Key? key, required this.merce}) : super(key : key);

  @override
  _CompilazionePreventivoMerceInRiparazionePageState createState() => _CompilazionePreventivoMerceInRiparazionePageState();
}

class _CompilazionePreventivoMerceInRiparazionePageState extends State<CompilazionePreventivoMerceInRiparazionePage>{
  final _importoPreventivatoController = TextEditingController();
  final _diagnosiController = TextEditingController();
  String _diagnosi = '';
  String _importoPreventivato = '';
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Inserimento preventivo merce in riparazione: ${widget.merce.articolo}', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDetailRow("Articolo", widget.merce.articolo!),
                      _buildDetailRow("Difetto Riscontrato", widget.merce.difetto_riscontrato!),
                      _buildDetailRow("Accessori", widget.merce.accessori!),
                      if(widget.merce.diagnosi != null)
                        _buildDetailRow("Diagnosi", widget.merce.diagnosi!),
                      if(widget.merce.diagnosi == null)
                        Column(
                          children: [
                            TextFormField(
                              controller: _diagnosiController,
                              decoration: const InputDecoration(labelText: "Inserisci una diagnosi"),
                              onChanged: (value){
                                _diagnosi = value;
                              },
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _importoPreventivatoController,
                              decoration: const InputDecoration(labelText: "Inserisci l'importo del preventivo"),
                              onChanged: (value) {
                                _importoPreventivato = value;
                              },
                              keyboardType: TextInputType.number, // Specifica il tipo di tastiera come numerica
                            ),
                          ],
                        ),
                      SizedBox(height: 50), // Add some spacing between the last widget and the button
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            compilaPreventivo();
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.red, // Set the text color to white
                          ),
                          child: Text('Salva preventivo merce in riparazione'),
                        ),
                      ),
                    ],
                  ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> compilaPreventivo() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddressProva2/api/merceInRiparazione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id,
          'data': widget.merce.data?.toIso8601String(), // Converti data in stringa ISO 8601
          'articolo': widget.merce.articolo,
          'accessori': widget.merce.accessori,
          'difetto_riscontrato': widget.merce.difetto_riscontrato,
          'password': widget.merce.password,
          'dati': widget.merce.dati,
          'presenza_magazzino' : widget.merce.presenza_magazzino,
          'preventivo': widget.merce.preventivo,
          'importo_preventivato': _importoPreventivatoController.text,
          'diagnosi': _diagnosiController.text,
          'risoluzione': widget.merce.risoluzione,
          'data_conclusione': widget.merce.data_conclusione?.toIso8601String(),
          'data_consegna': widget.merce.data_consegna?.toIso8601String(),
        }),
      );
      Navigator.pop(context);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preventivo per merce in riparazione registrato correttamente.'),
        ),
      );
    } catch(e){
      print('Errore $e');
    }
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