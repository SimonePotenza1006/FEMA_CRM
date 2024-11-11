import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class RegistrazioneAziendaPage extends StatefulWidget {
  const RegistrazioneAziendaPage({Key? key}) : super(key: key);

  @override
  _RegistrazioneAziendaPageState createState() =>
      _RegistrazioneAziendaPageState();
}

class _RegistrazioneAziendaPageState extends State<RegistrazioneAziendaPage> {
  final TextEditingController denominazioneController = TextEditingController();
  final TextEditingController luogoLavoroController = TextEditingController();
  final TextEditingController partitaIVAController = TextEditingController();
  final TextEditingController pecController = TextEditingController();
  final TextEditingController recapitoFatturazioneController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController sitoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090';
String ipaddressProva = 'http://gestione.femasistemi.it:8095';

  bool _areFieldsFilled = false;

  @override
  void initState() {
    super.initState();
    _updateAreFieldsFilled();
  }

  void _updateAreFieldsFilled() {
    setState(() {
      _areFieldsFilled = denominazioneController.text.trim().isNotEmpty &&
          luogoLavoroController.text.trim().isNotEmpty &&
          partitaIVAController.text.trim().isNotEmpty &&
          pecController.text.trim().isNotEmpty &&
          recapitoFatturazioneController.text.trim().isNotEmpty &&
          emailController.text.trim().isNotEmpty &&
          sitoController.text.trim().isNotEmpty &&
          telefonoController.text.trim().isNotEmpty;
    });
  }

  Future<void> createAzienda() async {
    final url = Uri.parse('$ipaddressProva/api/azienda');
    final body = jsonEncode({
      'nome': denominazioneController.text.toString(),
      'luogo_di_lavoro': luogoLavoroController.text.toString(),
      'partita_iva': partitaIVAController.text.toString(),
      'pec': pecController.text.toString(),
      'recapito_fatturazione_elettronica':
          recapitoFatturazioneController.text.toString(),
      'email': emailController.text.toString(),
      'telefono': telefonoController.text.toString(),
      'sito': sitoController.text.toString()
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 201) {
        print('Azienda creata con successo!');
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Azienda salvata correttamente!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Errore durante la creazione dell\'azienda');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registrazione Azienda',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Inserisci i dati richiesti per la registrazione di una nuova azienda',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: denominazioneController,
                onChanged: (_) => _updateAreFieldsFilled(),
                decoration: InputDecoration(
                  labelText: 'Denominazione',
                  hintText: 'Inserisci la denominazione',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: luogoLavoroController,
                onChanged: (_) => _updateAreFieldsFilled(),
                decoration: InputDecoration(
                  labelText: 'Luogo di lavoro',
                  hintText: 'Inserisci il luogo di lavoro',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: partitaIVAController,
                onChanged: (_) => _updateAreFieldsFilled(),
                decoration: InputDecoration(
                  labelText: 'Partita IVA',
                  hintText: 'Inserisci la partita IVA',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: pecController,
                onChanged: (_) => _updateAreFieldsFilled(),
                decoration: InputDecoration(
                  labelText: 'PEC',
                  hintText: 'Inserisci l\'indirizzo PEC',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: recapitoFatturazioneController,
                onChanged: (_) => _updateAreFieldsFilled(),
                decoration: InputDecoration(
                  labelText: 'Recapito fatturazione elettronica',
                  hintText: 'Inserisci il recapito di fatturazione elettronica',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                onChanged: (_) => _updateAreFieldsFilled(),
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Inserisci l\'indirizzo email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: telefonoController,
                onChanged: (_) => _updateAreFieldsFilled(),
                decoration: InputDecoration(
                  labelText: 'Telefono',
                  hintText: 'Inserisci il numero di telefono',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: sitoController,
                onChanged: (_) => _updateAreFieldsFilled(),
                decoration: InputDecoration(
                  labelText: 'Sito',
                  hintText: 'Inserisci il sito web',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Azione da eseguire quando viene premuto il pulsante "Reset"
                      setState(() {
                        denominazioneController.clear();
                        luogoLavoroController.clear();
                        partitaIVAController.clear();
                        pecController.clear();
                        recapitoFatturazioneController.clear();
                        emailController.clear();
                        sitoController.clear();
                        _updateAreFieldsFilled();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Reset',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _areFieldsFilled ? () => createAzienda() : null,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Salva azienda',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
