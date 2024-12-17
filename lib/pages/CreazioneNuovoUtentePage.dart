import 'package:fema_crm/model/RuoloUtenteModel.dart';
import 'package:fema_crm/model/TipologiaInterventoModel.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CreazioneNuovoUtentePage extends StatefulWidget {
  const CreazioneNuovoUtentePage ({Key? key}) : super(key : key);

  @override
  _CreazioneNuovoUtentePageState createState() => _CreazioneNuovoUtentePageState();
}

class _CreazioneNuovoUtentePageState extends State<CreazioneNuovoUtentePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cellulareController = TextEditingController();
  final _codiceFiscaleController = TextEditingController();
  final _ibanController = TextEditingController();
  RuoloUtenteModel? selectedRuolo;
  TipologiaInterventoModel? selectedTipologia;
  List<TipologiaInterventoModel> tipologieList = [];
  List<RuoloUtenteModel> ruoliList = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090';
String ipaddressProva = 'http://gestione.femasistemi.it:8095';

  @override
  void initState(){
    super.initState();
    getAllTipologie();
    getAllRuoli();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Creazione nuovo utente',
        style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTextFormField(_nomeController, 'Nome', 'Inserisci il nome dell\'utente'),
                SizedBox(height: 15),
                _buildTextFormField(_cognomeController, 'Cognome', 'Inserisci il cognome dell\'utente'),
                SizedBox(height: 15),
                _buildTextFormField(_cellulareController, 'Cellulare', 'Inserisci il numero di cellulare dell\'utente'),
                SizedBox(height: 15),
                _buildTextFormField(_codiceFiscaleController, 'Codice Fiscale', 'Inserisci il codice fiscale dell\'utente'),
                SizedBox(height: 15),
                _buildTextFormField(_ibanController, 'Iban', 'Inserisci l\'IBAN dell\'utente', validator: _validateIBAN),
                SizedBox(height: 15),
                _buildTextFormField(_usernameController, 'Username', 'Inserisci l\'username dell\'utente'),
                SizedBox(height: 15),
                _buildTextFormField(_passwordController, 'Password', 'Inserisci la password che dovrà usare l\'utente'),
                SizedBox(height: 15),
                SizedBox(
                  width: 600,
                  child: DropdownButtonFormField<TipologiaInterventoModel>(
                    value: selectedTipologia,
                    hint: Text(
                      'SELEZIONA TIPOLOGIA DI INTERVENTO',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onChanged: (TipologiaInterventoModel? newValue) {
                      setState(() {
                        selectedTipologia = newValue;
                      });
                    },
                    items: tipologieList
                        .map<DropdownMenuItem<TipologiaInterventoModel>>(
                          (TipologiaInterventoModel value) => DropdownMenuItem<TipologiaInterventoModel>(
                        value: value,
                        child: Text(
                          value.descrizione!,
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    )
                        .toList(),
                    decoration: InputDecoration(
                      labelText: 'TIPOLOGIA INTERVENTO',
                      labelStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.redAccent,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1.0,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Selezionare una tipologia di intervento';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: 600,
                  child: DropdownButtonFormField<RuoloUtenteModel>(
                    value: selectedRuolo,
                    hint: Text(
                      'SELEZIONA IL RUOLO DELL\'UTENTE',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onChanged: (RuoloUtenteModel? newValue) {
                      setState(() {
                        selectedRuolo = newValue;
                      });
                    },
                    items: ruoliList
                        .map<DropdownMenuItem<RuoloUtenteModel>>(
                          (RuoloUtenteModel value) => DropdownMenuItem<RuoloUtenteModel>(
                        value: value,
                        child: Text(
                          value.descrizione!,
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    )
                        .toList(),
                    decoration: InputDecoration(
                      labelText: 'RUOLO',
                      labelStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.redAccent,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1.0,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    ),
                    validator: (value) {
                      if (value == null) {
                      return 'Selezionare un ruolo!';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 50),
                Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        saveUtente();
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.red),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      ),
                    ),
                    child: Text(
                      'Salva utente',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          ),
        ),
      ),
    );
  }

  Future<void> saveUtente() async {
    try{
      final response = await http.post(
          Uri.parse('$ipaddress/api/utente'),
          headers: {'Content-Type' : 'application/json'},
          body: jsonEncode({
            'attivo' : true,
            'nome' : _nomeController.text,
            'cognome' : _cognomeController.text,
            'email' : _usernameController.text,
            'password' : _passwordController.text,
            'cellulare' : _cellulareController.text,
            'codice_fiscale' : _codiceFiscaleController.text,
            'iban' : _ibanController.text,
            'ruolo' : selectedRuolo?.toMap(),
            'tipologia_intervento' : selectedTipologia?.toMap(),
          })
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nuovo utente registrato con successo!'),
        ),
      );
    } catch (e) {
      print('Errore durante il salvataggio del sopralluogo');
    }
  }

  Future<void> getAllTipologie() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/tipologiaIntervento');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<TipologiaInterventoModel> tipologie = [];
        for (var item in jsonData) {
          tipologie.add(TipologiaInterventoModel.fromJson(item));
        }
        setState(() {
          tipologieList = tipologie;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
      _showErrorDialog();
    }
  }

  String? _validateIBAN(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obbligatorio';
    }
    if (value.length != 27 || !value.startsWith('IT')) {
      return 'Inserisci un IBAN italiano valido';
    }
    final ibanRegex = RegExp(r'^[A-Z0-9]+$');
    if (!ibanRegex.hasMatch(value.substring(2))) {
      return 'Inserisci un IBAN italiano valido';
    }
    return null;
  }

  Future<void> getAllRuoli() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/ruolo');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<RuoloUtenteModel> ruoli = [];
        for (var item in jsonData) {
          ruoli.add(RuoloUtenteModel.fromJson(item));
        }
        setState(() {
          ruoliList = ruoli;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
      _showErrorDialog();
    }
  }

  Widget _buildTextFormField(
      TextEditingController controller, String label, String hintText,
      {String? Function(String?)? validator}) {
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
        ),
        validator: validator, // Funzione di validazione
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Errore di connessione'),
          content: Text(
            'Impossibile caricare i dati dall\'API. Controlla la tua connessione internet e riprova.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }




}