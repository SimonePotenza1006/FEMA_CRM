import 'package:flutter/material.dart';
import 'dart:convert';
import '../databaseHandler/DbHelper.dart';
import 'package:http/http.dart' as http;


class CreazioneClientePage extends StatefulWidget {
  const CreazioneClientePage({super.key, Key? key1});

  @override
  _CreazioneClientePageState createState() => _CreazioneClientePageState();
}

class _CreazioneClientePageState extends State<CreazioneClientePage>{
  DbHelper? dbHelper;
  final _formKey = GlobalKey<FormState>();
  final _codiceFiscaleController = TextEditingController();
  final _partitaIvaController = TextEditingController();
  final _denominazioneController = TextEditingController();
  final _indirizzoController = TextEditingController();
  final _capController = TextEditingController();
  final _cittaController = TextEditingController();
  final _provinciaController = TextEditingController();
  final _nazioneController = TextEditingController();
  final _recapitoFatturazioneElettronicaController = TextEditingController();
  final _riferimentoAmministrativoController = TextEditingController();
  final _referenteController = TextEditingController();
  final _faxController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _cellulareController = TextEditingController();
  final _emailController = TextEditingController();
  final _pecController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState(){
    dbHelper = DbHelper();
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Creazione nuovo cliente',
        style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),

      body : SingleChildScrollView(
        child:Padding(
          padding : const EdgeInsets.all(16.0),
          child : Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                    controller: _codiceFiscaleController,
                    decoration: InputDecoration(labelText : 'Codice Fiscale'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un codice fiscale';
                      }
                      return null;
                    }
                ),
                TextFormField(
                    controller: _partitaIvaController,
                    decoration: InputDecoration(labelText : 'Partita IVA'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci una Partita IVA';
                      }
                      return null;
                    }
                ),
                TextFormField(
                    controller: _denominazioneController,
                    decoration: InputDecoration(labelText : 'Denominazione'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci una denominazione';
                      }
                      return null;
                    }
                ),
                TextFormField(
                    controller: _indirizzoController,
                    decoration: InputDecoration(labelText : 'Indirizzo'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un indirizzo';
                      }
                      return null;
                    }
                ),
                TextFormField(
                    controller: _capController,
                    decoration: InputDecoration(labelText : 'CAP'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un CAP';
                      }
                      return null;
                    }
                ),
                TextFormField(
                    controller: _cittaController,
                    decoration: InputDecoration(labelText : 'Città'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci una città';
                      }
                      return null;
                    }
                ),
                TextFormField(
                    controller: _provinciaController,
                    decoration: InputDecoration(labelText : 'Provincia'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci una provincia';
                      }
                      return null;
                    }
                ),
                TextFormField(
                    controller: _nazioneController,
                    decoration: InputDecoration(labelText : 'Nazione'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci una nazione';
                      }
                      return null;
                    }
                ),
                TextFormField(
                    controller: _recapitoFatturazioneElettronicaController,
                    decoration: InputDecoration(labelText : 'Recapito Fatturazione Elettronica'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un recapito per la fatturazione elettronica';
                      }
                      return null;
                    }
                ),
                TextFormField(
                    controller: _riferimentoAmministrativoController,
                    decoration: InputDecoration(labelText : 'Riferimento Amministrativo'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un riferimento amministrativo';
                      }
                      return null;
                    }
                ),
                TextFormField(
                    controller: _referenteController,
                    decoration: InputDecoration(labelText : 'Referente'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un referente';
                      }
                      return null;
                    }
                ),
                TextFormField(
                    controller: _faxController,
                    decoration: InputDecoration(labelText : 'Fax'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un fax';
                      }
                      return null;
                    }
                ),
                TextFormField(
                    controller: _telefonoController,
                    decoration: InputDecoration(labelText : 'Telefono'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un numero di telefono';
                      }
                      return null;
                    }
                ),
                TextFormField(
                    controller: _cellulareController,
                    decoration: InputDecoration(labelText : 'Cellulare'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un numero di cellulare';
                      }
                      return null;
                    }
                ),
                TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText : 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un indirizzo email';
                      }
                      return null;
                    }
                ),
                TextFormField(
                    controller: _pecController,
                    decoration: InputDecoration(labelText : 'Pec'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un indirizzo PEC';
                      }
                      return null;
                    }
                ),
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(labelText : 'Note'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed:() {
                    if (_formKey.currentState!.validate()) {
                      final codiceFiscale = _codiceFiscaleController.text;
                      final partitaIva = _partitaIvaController.text;
                      final denominazione = _denominazioneController.text;
                      final indirizzo = _indirizzoController.text;
                      final cap = _capController.text;
                      final citta = _cittaController.text;
                      final provincia = _provinciaController.text;
                      final nazione = _nazioneController.text;
                      final recapitoFatturazioneElettronica = _recapitoFatturazioneElettronicaController
                          .text;
                      final riferimentoAmministrativo = _riferimentoAmministrativoController
                          .text;
                      final referente = _referenteController.text;
                      final fax = _faxController.text;
                      final telefono = _telefonoController.text;
                      final cellulare = _cellulareController.text;
                      final email = _emailController.text;
                      final pec = _pecController.text;
                      final note = _noteController.text;
                      createNewCliente(codiceFiscale, partitaIva, denominazione, indirizzo, cap, citta, provincia, nazione, recapitoFatturazioneElettronica, riferimentoAmministrativo, referente, fax, telefono, cellulare, email, pec, note);
                    }
                  },
                  child: Text('Salva'),
                ),
              ],
            ),
          ),
        ),
      )

    );
  }

  Future<void> createNewCliente(String codiceFiscale, String partitaIva, String denominazione, String indirizzo, String cap, String citta, String provincia, String nazione, String recapitoFatturazioneElettronica, String riferimentoAmministrativo, String referente, String fax, String telefono, String cellulare, String email, String pec, String note) async{
    final url = Uri.parse('http://192.168.1.52:8080/api/cliente');
    final body = jsonEncode({
      'codice_fiscale' : codiceFiscale,
      'partita_iva': partitaIva,
      'denominazione': denominazione,
      'indirizzo': indirizzo,
      'cap': cap,
      'citta': citta,
      'provincia': provincia,
      'nazione' : nazione,
      'recapito_fatturazione_elettronica': recapitoFatturazioneElettronica,
      'riferimento_amministrativo': riferimentoAmministrativo,
      'referente' : referente,
      'fax': fax,
      'telefono' : telefono,
      'cellulare' : cellulare,
      'email' : email,
      'pec': pec,
      'note': note,
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if(response.statusCode == 200){
        print('Cliente creato con successo!');
      } else {
        throw Exception('Errore durante il salvataggio del cliente');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
    }
  }
}