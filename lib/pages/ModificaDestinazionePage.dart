import 'dart:convert';

import 'package:fema_crm/model/ClienteModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/DestinazioneModel.dart';

class ModificaDestinazionePage extends StatefulWidget {
  final DestinazioneModel destinazione;

  const ModificaDestinazionePage({Key? key, required this.destinazione}) : super(key:key);

  @override
  _ModificaDestinazionePageState createState() => _ModificaDestinazionePageState();
}

class _ModificaDestinazionePageState extends State<ModificaDestinazionePage>{
  late TextEditingController _denominazioneController;
  late TextEditingController _indirizzoController;
  late TextEditingController _capController;
  late TextEditingController _cittaController;
  late TextEditingController _provinciaController;
  late TextEditingController _codiceFiscaleController;
  late TextEditingController _partitaIvaController;
  late TextEditingController _telefonoController;
  late TextEditingController _cellulareController;

  @override
  void initState() {
    super.initState();
    _denominazioneController = TextEditingController(text: widget.destinazione.denominazione);
    _indirizzoController = TextEditingController(text: widget.destinazione.indirizzo);
    _capController = TextEditingController(text: widget.destinazione.cap);
    _cittaController = TextEditingController(text: widget.destinazione.citta);
    _provinciaController = TextEditingController(text: widget.destinazione.provincia);
    _codiceFiscaleController = TextEditingController(text: widget.destinazione.codice_fiscale);
    _partitaIvaController = TextEditingController(text: widget.destinazione.partita_iva);
    _telefonoController = TextEditingController(text: widget.destinazione.telefono);
    _cellulareController = TextEditingController(text: widget.destinazione.cellulare);
  }

  @override
  void dispose(){
    _denominazioneController.dispose();
    _indirizzoController.dispose();
    _capController.dispose();
    _cittaController.dispose();
    _provinciaController.dispose();
    _codiceFiscaleController.dispose();
    _partitaIvaController.dispose();
    _telefonoController.dispose();
    _cellulareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifica destinazione'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _denominazioneController,
              decoration: const InputDecoration(labelText: 'Denominazione'),
            ),
            TextField(
              controller: _indirizzoController,
              decoration: const InputDecoration(labelText: 'Indirizzo'),
            ),
            TextField(
              controller: _capController,
              decoration: const InputDecoration(labelText: 'CAP'),
            ),
            TextField(
              controller: _cittaController,
              decoration: const InputDecoration(labelText: 'Città'),
            ),
            TextField(
              controller: _provinciaController,
              decoration: const InputDecoration(labelText: 'Provincia'),
            ),
            TextField(
              controller: _codiceFiscaleController,
              decoration: const InputDecoration(labelText: 'Codice Fiscale'),
            ),
            TextField(
              controller: _partitaIvaController,
              decoration: const InputDecoration(labelText: 'Partita IVA'),
            ),
            TextField(
              controller: _telefonoController,
              decoration: const InputDecoration(labelText: 'Telefono'),
            ),
            TextField(
              controller: _cellulareController,
              decoration: const InputDecoration(labelText: 'Cellulare'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateDestinazione,
              child: const Text('Salva Modifiche'),
            ),
          ],
        ),
      ),
    );
  }

  Future<http.Response> updateDestinazione() async {
    late http.Response response;
    try{
      print('${widget.destinazione.toJson()}');
      response = await http.put(
        Uri.parse('http://192.168.1.52:8080/api/destinazione'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
        body: json.encode({
          'id': widget.destinazione.id,
          'denominazione': _denominazioneController.text.toString(),
          'indirizzo': _indirizzoController.text.toString(),
          'cap': _capController.text.toString(),
          'citta': _cittaController.text.toString(),
          'provincia': _provinciaController.text.toString(),
          'codice_fiscale': _codiceFiscaleController.text.toString(),
          'partita_iva': _partitaIvaController.text.toString(),
          'telefono' : _telefonoController.text.toString(),
          'cellulare': _cellulareController.text.toString(),
          'cliente': widget.destinazione.cliente?.toJson(),
        })
      );
      if(response.statusCode == 200){
        print("Destinazione modificata correttamente!");
      } else {
        print("Hai toppato!!");
        print("${widget.destinazione.cliente?.toJson()}");
        print(response.toString());
      }
    }
    catch(e) {
      print(e.toString());
    }
    return response;
  }
}