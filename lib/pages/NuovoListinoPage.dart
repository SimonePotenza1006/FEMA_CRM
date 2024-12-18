import 'dart:convert';
import 'package:fema_crm/model/CategoriaPrezzoListinoModel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fema_crm/model/CategoriaInterventoSpecificoModel.dart';

class NuovoListinoPage extends StatefulWidget {
  final CategoriaInterventoSpecificoModel categoria;

  const NuovoListinoPage({Key? key1, required this.categoria})
      : super(key: key1);

  @override
  _NuovoListinoPageState createState() => _NuovoListinoPageState();
}

class _NuovoListinoPageState extends State<NuovoListinoPage> {
  final _formKey = GlobalKey<FormState>();
  final _descrizioneController = TextEditingController();
  final _prezzoController = TextEditingController();
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
            'Aggiungi listino alla categoria ${widget.categoria.descrizione}',
            style: TextStyle(color: Colors.white)),
        centerTitle: false,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
              TextFormField(
                controller: _prezzoController,
                decoration: InputDecoration(labelText: 'Prezzo'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci un prezzo';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Salvataggio nel database o invio al server
                    final descrizione = _descrizioneController.text;
                    final prezzo = double.parse(_prezzoController.text);
                    final categoria = widget.categoria;
                    createNewListino(descrizione, prezzo, categoria);
                  }
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

  Future<void> createNewListino(String descrizione, double prezzo,
      CategoriaInterventoSpecificoModel categoria) async {
    final url = Uri.parse('$ipaddress/api/listino');
    final body = jsonEncode({
      'descrizione': descrizione,
      'prezzo': prezzo,
      'categoriaInterventoSpecifico': {
        'id': widget.categoria.id,
        'descrizione': widget.categoria.descrizione,
        'tipologia': widget.categoria.tipologiaIntervento,
      }
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) {
        print('Listino aggiunto con successo');
      } else {
        throw Exception('Errore durante la creazione del listino');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
    }
  }
}
