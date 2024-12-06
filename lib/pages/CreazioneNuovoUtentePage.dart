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
                  width: 300,
                  child: DropdownButton<TipologiaInterventoModel>(
                    value: selectedTipologia,
                    hint: Text('Seleziona tipologia di intervento'),
                    isExpanded: true,
                    onChanged: (TipologiaInterventoModel? newValue) {
                      setState(() {
                        selectedTipologia = newValue;
                      });
                    },
                    items: tipologieList
                        .map<DropdownMenuItem<TipologiaInterventoModel>>(
                            (TipologiaInterventoModel tipologia) {
                          return DropdownMenuItem<TipologiaInterventoModel>(
                            value: tipologia,
                            child: Text(tipologia.descrizione ?? ''),
                          );
                        }).toList(),
                  ),
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: 300,
                  child: DropdownButton<RuoloUtenteModel>(
                    value: selectedRuolo,
                    hint: Text('Seleziona il ruolo dell\'utente'),
                    isExpanded: true,
                    onChanged: (RuoloUtenteModel? newValue) {
                      setState(() {
                        selectedRuolo = newValue;
                      });
                    },
                    items: ruoliList
                        .map<DropdownMenuItem<RuoloUtenteModel>>(
                            (RuoloUtenteModel ruolo) {
                          return DropdownMenuItem<RuoloUtenteModel>(
                            value: ruolo,
                            child: Text(ruolo.descrizione ?? ''),
                          );
                        }).toList(),
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
          Uri.parse('$ipaddressProva/api/utente'),
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
      var apiUrl = Uri.parse('$ipaddressProva/api/tipologiaIntervento');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
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

    // Controllo sulla lunghezza e sul prefisso
    if (value.length != 27 || !value.startsWith('IT')) {
      return 'Inserisci un IBAN italiano valido';
    }

    // Controllo che gli altri caratteri siano alfanumerici
    final ibanRegex = RegExp(r'^[A-Z0-9]+$');
    if (!ibanRegex.hasMatch(value.substring(2))) {
      return 'Inserisci un IBAN italiano valido';
    }

    return null; // Se tutto è corretto, non c'è errore
  }

  Future<void> getAllRuoli() async {
    try {
      var apiUrl = Uri.parse('$ipaddressProva/api/ruolo');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
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

  Widget _buildTextFormField(
      TextEditingController controller, String label, String hintText, {String? Function(String?)? validator}) {
    return SizedBox(
      width: 320,
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
        validator: validator, // Assegna la funzione di validazione
      ),
    );
  }
}