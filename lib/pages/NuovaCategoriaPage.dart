import 'dart:convert';
import 'package:fema_crm/model/CategoriaInterventoSpecificoModel.dart';
import 'package:fema_crm/model/TipologiaInterventoModel.dart';
import 'package:flutter/material.dart';
import 'package:io/ansi.dart';
import 'package:http/http.dart' as http;

class NuovaCategoriaPage extends StatefulWidget {
  final TipologiaInterventoModel tipologia;

  const NuovaCategoriaPage({Key? key, required this.tipologia})
      : super(key: key);

  @override
  _NuovaCategoriaPageState createState() => _NuovaCategoriaPageState();
}

class _NuovaCategoriaPageState extends State<NuovaCategoriaPage> {
  final _descrizioneController = TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
            'Aggiungi categoria di intervento alla tipologia ${widget.tipologia.descrizione}',
            style: TextStyle(color: Colors.white)),
        centerTitle: false,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _descrizioneController,
                decoration: InputDecoration(labelText: 'Descrizione'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci una descrizione';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  createNewCategoria();
                },
                child: Text('Salva', style: TextStyle(color: Colors.white)),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createNewCategoria() async {
    try {
      final response =
          await http.post(Uri.parse('$ipaddress/api/categorieIntervento'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'descrizione': _descrizioneController.text,
                'tipologiaIntervento': widget.tipologia.toMap(),
              }));
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Categoria salvata!'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
        print('Categoria creata con successo');
      } else {
        throw Exception('Errore durante la creazione del listino');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
    }
  }
}
