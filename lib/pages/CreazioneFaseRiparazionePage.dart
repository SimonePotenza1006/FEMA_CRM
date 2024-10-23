import 'dart:convert';

import 'package:fema_crm/model/MerceInRiparazioneModel.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../model/UtenteModel.dart';

class CreazioneFaseRiparazionePage extends StatefulWidget{
  final MerceInRiparazioneModel merce;
  final UtenteModel utente;

  CreazioneFaseRiparazionePage({Key? key, required this.utente, required this.merce}) : super(key:key);

  @override
  _CreazioneFaseRiparazionePageState createState() =>
      _CreazioneFaseRiparazionePageState();
}

class _CreazioneFaseRiparazionePageState extends State<CreazioneFaseRiparazionePage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  TextEditingController _descrizioneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Creazione nuova fase per riparazione merce',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 30),
              TextFormField(
                controller: _descrizioneController,
                maxLines: null, // Allow multiline input
                decoration: InputDecoration(
                  hintText: 'Inserisci qui la descrizione',
                  border: OutlineInputBorder(),
                ),
                onChanged: (text) {
                  setState(() {}); // Aggiorna lo stato per riflettere il cambiamento
                },
              ),
              SizedBox(height: 16), // Add some space between TextFormField and ElevatedButton
              ElevatedButton(
                onPressed: _descrizioneController.text.isNotEmpty
                    ? () {
                  saveFase();
                }
                    : null, // Se il testo è vuoto, disabilita il pulsante
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Set padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Set border radius
                  ),
                ),
                child: Text(
                  'Salva fase',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> saveFase() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await http.post(
        Uri.parse('$ipaddressProva/api/fasi'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': now,
          'descrizione': _descrizioneController.text,
          'utente': widget.utente.toMap(),
          'merce': widget.merce.toMap(),
        }),
      );

      if (response.statusCode == 201) {
        // Mostra un AlertDialog se lo status code è 201
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Operazione completata'),
              content: Text('Fase registrata correttamente'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    // Chiude il dialog e poi chiude la pagina attuale con doppio pop
                    Navigator.pop(context); // Chiude l'AlertDialog
                    Navigator.pop(context); // Chiude la pagina
                  },
                  child: Text('Chiudi'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Errore durante il salvataggio della fase: $e');
    }
  }
}