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
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';
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
              _buildTextFormField(_notaController, "NOTA", "Inserire la nota"),
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

  Widget _buildTextFormField(
      TextEditingController controller, String label, String hintText,
      {String? Function(String?)? validator}) {
    return SizedBox(
      width: 600, // Larghezza modificata
      child: TextFormField(
        controller: controller,
        maxLines: null, // Permette più righe
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[200], // Sfondo riempito
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none, // Nessun bordo di default
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.redAccent,
              width: 2.0, // Larghezza bordo focale
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1.0, // Larghezza bordo abilitato
            ),
          ),
          contentPadding:
          EdgeInsets.symmetric(vertical: 15, horizontal: 10), // Padding contenuto
        ),
        validator: validator, // Funzione di validazione
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
