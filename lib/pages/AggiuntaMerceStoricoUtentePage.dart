import 'package:fema_crm/pages/AggiungiMovimentoPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

import '../model/UtenteModel.dart';

class AggiuntaMerceStoricoUtentePage extends StatefulWidget {
  final UtenteModel utente;

  const AggiuntaMerceStoricoUtentePage({Key? key, required this.utente}) : super(key:key);

  @override
  _AggiuntaMerceStoricoUtentePageState createState() => _AggiuntaMerceStoricoUtentePageState();
}

class _AggiuntaMerceStoricoUtentePageState extends State<AggiuntaMerceStoricoUtentePage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  final TextEditingController _materialeController = TextEditingController();
  final TextEditingController _quantitaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aggiunta allo storico di ${widget.utente.nomeCompleto()}', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextFormField(
              controller: _materialeController,
              decoration: InputDecoration(
                labelText: 'Materiale',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _quantitaController,
              decoration: InputDecoration(
                labelText: 'Quantità',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // allow only digits
              ],
              keyboardType: TextInputType.number, // show number keyboard
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: (){
                addMerce();
              },
              style: ElevatedButton.styleFrom(primary: Colors.red),
              child: Text('Aggiungi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addMerce() async {
    Map<String, dynamic> body = {
      'materiale' : _materialeController.text,
      'quantita' : _quantitaController.text,
      'utente' : widget.utente.toMap(),
    };
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/relazioneUtentiProdotti'),
        body: jsonEncode(body),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Materiale aggiunto all\'utente ${widget.utente.nomeCompleto()}'),
          ),
        );
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch(e){
      print('Errore durante il salvataggio della movimentazione: $e');
    }
  }
}


