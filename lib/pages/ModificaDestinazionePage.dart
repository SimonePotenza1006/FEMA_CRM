import 'dart:convert';

import 'package:fema_crm/model/ClienteModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/DestinazioneModel.dart';

class ModificaDestinazionePage extends StatefulWidget {
  final DestinazioneModel destinazione;

  const ModificaDestinazionePage({Key? key, required this.destinazione})
      : super(key: key);

  @override
  _ModificaDestinazionePageState createState() =>
      _ModificaDestinazionePageState();
}

class _ModificaDestinazionePageState extends State<ModificaDestinazionePage> {
  late TextEditingController _denominazioneController;
  late TextEditingController _indirizzoController;
  late TextEditingController _capController;
  late TextEditingController _cittaController;
  late TextEditingController _provinciaController;
  late TextEditingController _codiceFiscaleController;
  late TextEditingController _partitaIvaController;
  late TextEditingController _telefonoController;
  late TextEditingController _cellulareController;
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';

  @override
  void initState() {
    super.initState();
    _denominazioneController =
        TextEditingController(text: widget.destinazione.denominazione);
    _indirizzoController =
        TextEditingController(text: widget.destinazione.indirizzo);
    _capController = TextEditingController(text: widget.destinazione.cap);
    _cittaController = TextEditingController(text: widget.destinazione.citta);
    _provinciaController =
        TextEditingController(text: widget.destinazione.provincia);
    _codiceFiscaleController =
        TextEditingController(text: widget.destinazione.codice_fiscale);
    _partitaIvaController =
        TextEditingController(text: widget.destinazione.partita_iva);
    _telefonoController =
        TextEditingController(text: widget.destinazione.telefono);
    _cellulareController =
        TextEditingController(text: widget.destinazione.cellulare);
  }

  @override
  void dispose() {
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
        title:Text('Modifica destinazione'.toUpperCase(), style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTextField('denominazione', _denominazioneController),
              _buildTextField('indirizzo', _indirizzoController),
              _buildTextField('cap', _capController),
              _buildTextField('città', _cittaController),
              _buildTextField('provincia', _provinciaController),
              _buildTextField('codice fiscale', _codiceFiscaleController),
              _buildTextField('partita iva', _partitaIvaController),
              _buildTextField('telefono', _telefonoController),
              _buildTextField('cellulare', _cellulareController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateDestinazione,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.red, // Colore del testo bianco
                ),
                child: const Text('Salva Modifiche'),
              )
            ],
          ),
        )
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: SizedBox(
          width: 400,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label.toUpperCase(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        )
    );
  }

  Future<http.Response> updateDestinazione() async {
    late http.Response response;
    try {
      print('${widget.destinazione.toJson()}');
      response = await http.post(Uri.parse('$ipaddress/api/destinazione'),
          headers: {
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
            'telefono': _telefonoController.text.toString(),
            'cellulare': _cellulareController.text.toString(),
            'cliente': widget.destinazione.cliente?.toJson(),
          }));
      if (response.statusCode == 201) {
        print("Destinazione modificata correttamente!");
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Destinazione modificata correttamente!')));
      } else {
        print("Hai toppato!!");
        print("${widget.destinazione.cliente?.toJson()}");
        print(response.toString());
      }
    } catch (e) {
      print(e.toString());
    }
    return response;
  }
}
