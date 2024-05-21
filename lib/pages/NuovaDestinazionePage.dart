import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fema_crm/databaseHandler/DbHelper.dart';
import 'package:fema_crm/model/ClienteModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NuovaDestinazionePage extends StatefulWidget {
  final ClienteModel cliente;

  const NuovaDestinazionePage({Key? key1, required this.cliente})
      : super(key: key1);

  @override
  _NuovaDestinazionePageState createState() => _NuovaDestinazionePageState();
}

class _NuovaDestinazionePageState extends State<NuovaDestinazionePage> {
  final _formKey = GlobalKey<FormState>();
  final _denominazioneController = TextEditingController();
  final _indirizzoController = TextEditingController();
  final _capController = TextEditingController();
  final _cittaController = TextEditingController();
  final _provinciaController = TextEditingController();
  final _codiceFiscaleController = TextEditingController();
  final _partitaIvaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _cellulareController = TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090';

  DbHelper? dbHelper;
  bool isLoading = true;

  @override
  void initState() {
    dbHelper = DbHelper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
              'Aggiungi destinazione al cliente ${widget.cliente.denominazione}',
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
                    controller: _denominazioneController,
                    decoration: InputDecoration(labelText: 'Denominazione'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci una denominazione';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _indirizzoController,
                    decoration: InputDecoration(labelText: 'Indirizzo'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un indirizzo';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _capController,
                    decoration: InputDecoration(labelText: 'CAP'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un CAP';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _cittaController,
                    decoration: InputDecoration(labelText: 'Città'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci una città';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _provinciaController,
                    decoration: InputDecoration(labelText: 'Provincia(sigla)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci una provincia';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _codiceFiscaleController,
                    decoration: InputDecoration(labelText: 'Codice Fiscale'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un codice fiscale';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _partitaIvaController,
                    decoration: InputDecoration(labelText: 'Partita IVA'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci una Partita IVA';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _telefonoController,
                    decoration: InputDecoration(labelText: 'Telefono'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un numero di telefono';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _cellulareController,
                    decoration: InputDecoration(labelText: 'Cellulare'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un numero di cellulare';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final denominazione = _denominazioneController.text;
                        final indirizzo = _indirizzoController.text;
                        final cap = _capController.text;
                        final citta = _cittaController.text;
                        final provincia = _provinciaController.text;
                        final codice_fiscale = _codiceFiscaleController.text;
                        final partita_iva = _partitaIvaController.text;
                        final telefono = _telefonoController.text;
                        final cellulare = _cellulareController.text;
                        final cliente = widget.cliente;
                        createNewDestinazione(
                            denominazione,
                            indirizzo,
                            cap,
                            citta,
                            provincia,
                            codice_fiscale,
                            partita_iva,
                            telefono,
                            cellulare,
                            cliente);
                      }
                    },
                    child: Text('Salva',
                    style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.red),
                    ),
                  )
                ],
              ),
            )));
  }

  Future<void> createNewDestinazione(
      String denominazione,
      String indirizzo,
      String cap,
      String citta,
      String provincia,
      String codice_fiscale,
      String partita_iva,
      String telefono,
      String cellulare,
      ClienteModel cliente) async {
    print('${widget.cliente}');
    final url = Uri.parse('${ipaddress}/api/destinazione');
    final body = jsonEncode({
      'denominazione': denominazione,
      'indirizzo': indirizzo,
      'cap': cap,
      'citta': citta,
      'provincia': provincia,
      'codice_fiscale': codice_fiscale,
      'partita_iva': partita_iva,
      'telefono': telefono,
      'cellulare': cellulare,
      'cliente': widget.cliente,
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 201) {
        print('Destinazione aggiunta con successo!');
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Destinazione creata!'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
      } else {
        throw Exception('Errore durante la creazione della destinazione');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
    }
  }
}
