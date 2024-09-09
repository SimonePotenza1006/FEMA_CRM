import 'dart:convert';

import 'package:fema_crm/model/InterventoModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class ModificaRelazioneRapportinoPage extends StatefulWidget{
  final InterventoModel intervento;

  ModificaRelazioneRapportinoPage({Key? key, required this.intervento}) : super(key : key);

  @override
  _ModificaRelazioneRapportinoPageState createState() => _ModificaRelazioneRapportinoPageState();
}

class _ModificaRelazioneRapportinoPageState extends State<ModificaRelazioneRapportinoPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  TextEditingController _relazioneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _relazioneController.text = widget.intervento.relazione_tecnico!;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Modifica rapportino intervento ID ${widget.intervento.id}",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: TextFormField(
                    controller: _relazioneController,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: (){
                    saveIntervento();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20), // Set padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Set border radius
                    ),
                  ),
                  child: Text(
                    'Modifica Rapportino',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveIntervento() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.id,
          'data_apertura_intervento' : widget.intervento.data_apertura_intervento?.toIso8601String(),
          'data': widget.intervento.data?.toIso8601String(),
          'orario_appuntamento' : widget.intervento.orario_appuntamento?.toIso8601String(),
          'posizione_gps' : widget.intervento.posizione_gps,
          'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
          'orario_fine': widget.intervento.orario_fine?.toIso8601String(),
          'descrizione': widget.intervento.descrizione,
          'importo_intervento': widget.intervento.importo_intervento,
          'prezzo_ivato' : widget.intervento.prezzo_ivato,
          'assegnato': widget.intervento.assegnato,
          'concluso': widget.intervento.concluso,
          'saldato': widget.intervento.saldato,
          'saldato_da_tecnico' : widget.intervento.saldato_da_tecnico,
          'note': widget.intervento.note,
          'relazione_tecnico' : _relazioneController.text,
          'firma_cliente': widget.intervento.firma_cliente,
          'utente': widget.intervento.utente?.toMap(),
          'cliente': widget.intervento.cliente?.toMap(),
          'veicolo': widget.intervento.veicolo?.toMap(),
          'merce' : widget.intervento.merce?.toMap(),
          'tipologia': widget.intervento.tipologia?.toMap(),
          'categoria': widget.intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
          'destinazione': widget.intervento.destinazione?.toMap(),
          'gruppo' : widget.intervento.gruppo?.toMap(),
        })
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rapportino modificato correttamente!'),
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch(e){
      print('Errore: $e');
    }
  }


}