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
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';



  @override
  void initState() {
    super.initState();

    // Aggiungi listener ai controller per rilevare i cambiamenti nei campi
    denominazioneController.addListener(_checkForm);
    luogoLavoroController.addListener(_checkForm);
    partitaIVAController.addListener(_checkForm);
    pecController.addListener(_checkForm);
    recapitoFatturazioneController.addListener(_checkForm);
    emailController.addListener(_checkForm);
    telefonoController.addListener(_checkForm);
    sitoController.addListener(_checkForm);
  }

  void _checkForm() {
    setState(() {});
  }

  @override
  void dispose() {
    denominazioneController.removeListener(_checkForm);
    luogoLavoroController.removeListener(_checkForm);
    partitaIVAController.removeListener(_checkForm);
    pecController.removeListener(_checkForm);
    recapitoFatturazioneController.removeListener(_checkForm);
    emailController.removeListener(_checkForm);
    telefonoController.removeListener(_checkForm);
    sitoController.removeListener(_checkForm);
    super.dispose();
  }

  Future<void> createAzienda() async {
    final url = Uri.parse('$ipaddress/api/azienda');
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
              _buildTextFormField(denominazioneController, "Denominazione", "Inserisci il nome dell\'azienda"),
              SizedBox(height: 20),
              _buildTextFormField(luogoLavoroController, "Luogo di lavoro", "Inserisci il luogo di lavoro dell\'azienda"),
              SizedBox(height: 20),
              _buildTextFormField(partitaIVAController, "Partita IVA", "Inserisci la P.IVA dell\'azienda"),
              SizedBox(height: 20),
              _buildTextFormField(pecController, "PEC", "Inserisci la PEC dell\'azienda"),
              SizedBox(height: 20),
              _buildTextFormField(recapitoFatturazioneController, "Recapito fatturazione elettronica", "Inserisci il recapito di fatturazione elettronica dell\'azienda"),
              SizedBox(height: 20),
              _buildTextFormField(emailController, "Email", "Inserisci l\'indirizzo email dell\'azienda"),
              SizedBox(height: 20),
              _buildTextFormField(telefonoController, "Telefono", "Inserisci il numero di telefono dell\'azienda"),
              SizedBox(height: 20),
              _buildTextFormField(sitoController, "Sito web", "Inserisci il sito web dell\'azienda"),
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
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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
                    onPressed: denominazioneController.text.isNotEmpty &&
                        luogoLavoroController.text.isNotEmpty &&
                        partitaIVAController.text.isNotEmpty &&
                        pecController.text.isNotEmpty &&
                        recapitoFatturazioneController.text.isNotEmpty &&
                        emailController.text.isNotEmpty &&
                        sitoController.text.isNotEmpty &&
                        telefonoController.text.isNotEmpty
                        ? createAzienda
                        : null, // Disabilita il pulsante se uno dei campi è vuoto
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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

  Widget _buildTextFormField(
      TextEditingController controller, String label, String hintText) {
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
        ), // Funzione di validazione
      ),
    );
  }


}
