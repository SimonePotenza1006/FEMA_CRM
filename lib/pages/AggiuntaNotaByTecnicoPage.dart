import 'dart:convert';

import 'package:fema_crm/model/InterventoModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/UtenteModel.dart';


class AggiuntaNotaByTecnicoPage extends StatefulWidget{
  final InterventoModel intervento;
  final UtenteModel utente;

  const AggiuntaNotaByTecnicoPage({Key? key, required this.intervento, required this.utente})
      : super(key : key);

  @override
  _AggiuntaNotaByTecnicoPageState createState() => _AggiuntaNotaByTecnicoPageState();
}

class _AggiuntaNotaByTecnicoPageState extends State<AggiuntaNotaByTecnicoPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  TextEditingController _notaController = TextEditingController();

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Lascia una nota relativa all\'intervento',
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
              TextFormField(
                controller: _notaController,
                maxLines: null, // Allow multiline input
                decoration: InputDecoration(
                  hintText: 'Inserisci qui la nota',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16), // Add some space between TextFormField and ElevatedButton
              ElevatedButton(
                onPressed: () {
                  saveNota();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Set padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Set border radius
                  ),
                ),
                child: Text(
                  'Salva nota',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveNota() async {
    try{
      final now = DateTime.now().toIso8601String();
      final response = await http.post(
        Uri.parse('$ipaddress/api/noteTecnico'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': now,
          'utente': widget.utente.toMap(),
          'nota': _notaController.text,
          'intervento' : widget.intervento.toMap(),
          // 'cliente' : null,
          // 'destinazione' : null,
          // 'sopralluogo' : null,
          // 'merce' : null,
        }),
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nota relativa all\'intervento salvata con successo!'),
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Errore durante il salvataggio dell\'orario $e');
    }
  }
}
