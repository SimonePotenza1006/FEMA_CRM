import 'package:flutter/material.dart';
import 'package:io/ansi.dart';
import 'dart:convert';
import '../databaseHandler/DbHelper.dart';
import 'package:http/http.dart' as http;

class CreazioneClientePage extends StatefulWidget {
  const CreazioneClientePage({super.key, Key? key1});

  @override
  _CreazioneClientePageState createState() => _CreazioneClientePageState();
}

class _CreazioneClientePageState extends State<CreazioneClientePage> {
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
  final _daneaController = TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';

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
        title: const Text(
          'Creazione nuovo cliente',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTextFormField(_daneaController, 'Codice Danea',
                      'Inserisci il codice Danea'),
                  SizedBox(height: 15,),
                  _buildTextFormField(_codiceFiscaleController, 'Codice Fiscale',
                      'Inserisci un codice fiscale'),
                  SizedBox(height: 15,),
                  _buildTextFormField(_partitaIvaController, 'Partita IVA',
                      'Inserisci una Partita IVA'),
                  SizedBox(height: 15,),
                  _buildTextFormField(_denominazioneController, 'Denominazione',
                      'Inserisci una denominazione'),
                  SizedBox(height: 15,),
                  _buildTextFormField(_indirizzoController, 'Indirizzo',
                      'Inserisci un indirizzo'),
                  SizedBox(height: 15,),
                  _buildTextFormField(_capController, 'CAP', 'Inserisci un CAP'),
                  SizedBox(height: 15,),
                  _buildTextFormField(
                      _cittaController, 'Città', 'Inserisci una città'),
                  SizedBox(height: 15,),
                  _buildTextFormField(_provinciaController, 'Provincia (Solo la sigla)',
                      'Inserisci una provincia (Solo la sigla)'),
                  SizedBox(height: 15,),
                  _buildTextFormField(
                      _nazioneController, 'Nazione', 'Inserisci una nazione'),
                  SizedBox(height: 15,),
                  _buildTextFormField(
                      _recapitoFatturazioneElettronicaController,
                      'Recapito Fatturazione Elettronica',
                      'Inserisci un recapito per la fatturazione elettronica'),
                  SizedBox(height: 15,),
                  _buildTextFormField(
                      _riferimentoAmministrativoController,
                      'Riferimento Amministrativo',
                      'Inserisci un riferimento amministrativo'),
                  SizedBox(height: 15,),
                  _buildTextFormField(_referenteController, 'Referente',
                      'Inserisci un referente'),
                  SizedBox(height: 15,),
                  _buildTextFormField(_faxController, 'Fax', 'Inserisci un fax'),
                  SizedBox(height: 15,),
                  _buildTextFormField(_telefonoController, 'Telefono',
                      'Inserisci un numero di telefono'),
                  SizedBox(height: 15,),
                  _buildTextFormField(_cellulareController, 'Cellulare',
                      'Inserisci un numero di cellulare'),
                  SizedBox(height: 15,),
                  _buildTextFormField(
                      _emailController, 'Email', 'Inserisci un indirizzo email'),
                  SizedBox(height: 15,),
                  _buildTextFormField(
                      _pecController, 'PEC', 'Inserisci un indirizzo PEC'),
                  SizedBox(height: 15,),
                  _buildTextFormField(_noteController, 'Note', ''),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        createNewCliente();
                      }
                    },
                    child: Text('Salva', style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.red),
                    ),
                  ),
                ],
              ),
            )
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
      TextEditingController controller, String label, String hintText) {
    return SizedBox(
      width: 500,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(
              color: Colors.red,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Campo obbligatorio';
          }
          return null;
        },
      ),
    );
  }

  Future<void> createNewCliente() async {
    final url = Uri.parse('$ipaddress/api/cliente');
    final body = jsonEncode({
      'codice_fiscale': _codiceFiscaleController.text,
      'cod_danea' : _daneaController.text,
      'partita_iva': _partitaIvaController.text,
      'denominazione': _denominazioneController.text,
      'indirizzo': _indirizzoController.text,
      'cap': _capController.text,
      'citta': _cittaController.text,
      'provincia': _provinciaController.text,
      'nazione': _nazioneController.text,
      'recapito_fatturazione_elettronica':
          _recapitoFatturazioneElettronicaController.text,
      'riferimento_amministrativo': _riferimentoAmministrativoController.text,
      'referente': _referenteController.text,
      'fax': _faxController.text,
      'telefono': _telefonoController.text,
      'cellulare': _cellulareController.text,
      'email': _emailController.text,
      'pec': _pecController.text,
      'note': _noteController.text,
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 201) {
        print('Cliente creato con successo!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cliente creato!'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Qualcosa è andato storto!'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
        throw Exception('Errore durante il salvataggio del cliente');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
    }
  }
}
