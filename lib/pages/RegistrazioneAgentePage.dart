import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../model/AziendaModel.dart';

class RegistrazioneAgentePage extends StatefulWidget {
  const RegistrazioneAgentePage({Key? key}) : super(key: key);

  @override
  _RegistrazioneAgentePageState createState() => _RegistrazioneAgentePageState();
}

class _RegistrazioneAgentePageState extends State<RegistrazioneAgentePage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cognomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController riferimentoAziendaleController = TextEditingController();
  final TextEditingController cellulareController = TextEditingController();
  final TextEditingController luogoLavoroController = TextEditingController();
  final TextEditingController ibanController = TextEditingController();
  String selectedProvvigione = '3%';
  List<AziendaModel> aziendeList = [];
  AziendaModel? selectedAzienda;
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';

  bool _areFieldsFilled = false;

  @override
  void initState() {
    super.initState();

    getAllAziende();
  }

  void _updateAreFieldsFilled() {
    setState(() {
      _areFieldsFilled = nomeController.text.trim().isNotEmpty &&
          cognomeController.text.trim().isNotEmpty &&
          emailController.text.trim().isNotEmpty &&
          cellulareController.text.trim().isNotEmpty &&
          luogoLavoroController.text.trim().isNotEmpty &&
          ibanController.text.trim().isNotEmpty &&
          validateItalianIBAN(ibanController.text);
    });
  }

  int _getProvvigioneValue(String value) {
    return int.parse(value.replaceAll('%', ''));
  }

  Future<void> createAgente() async {
    final url = Uri.parse('$ipaddress/api/agente');
    final body = jsonEncode({
      'nome': nomeController.text.toString(),
      'cognome': cognomeController.text.toString(),
      'email': emailController.text.toString(),
      'riferimento_aziendale': selectedAzienda?.nome.toString(),
      'cellulare': cellulareController.text.toString(),
      'luogo_di_lavoro': luogoLavoroController.text.toString(),
      'iban': ibanController.text.toString(),
      'categoria_provvigione': _getProvvigioneValue(selectedProvvigione),
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 201) {
        print('Agente creato con successo!');
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Agente salvato correttamente!'),
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        throw Exception('Errore durante la creazione dell\'agente');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
    }
  }

  Future<void> getAllAziende() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/azienda');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<AziendaModel> aziende = [];
        for (var item in jsonData) {
          aziende.add(AziendaModel.fromJson(item));
        }
        setState(() {
          aziendeList = aziende;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
      _showErrorDialog();
    }
  }

  bool validateItalianIBAN(String iban) {
    // Italian IBAN format: ITxx xxxxxxx xxxxxxx xxxxx
    const italianIBANPattern = r'^IT\d{2}[0-9A-Z]{23}$';
    if (!RegExp(italianIBANPattern).hasMatch(iban)) {
      return false;
    }

    // Calculate the IBAN checksum
    String ibanWithoutCountryCode = iban.substring(4);
    String countryCode = iban.substring(0, 2);
    String checksum = countryCode + ibanWithoutCountryCode;
    checksum = checksum.toUpperCase();
    checksum = checksum.replaceAllMapped(RegExp(r'[A-Z]'), (match) {
      int charCode = match.group(0)!.codeUnitAt(0) - 55;
      return charCode.toString();
    });
    int checksumValue =int.parse(checksum);
    checksumValue = checksumValue % 97;
    if (checksumValue != 1) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registrazione Agente',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Inserisci i dati richiesti per la registrazione di un nuovo agente',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: nomeController,
                onChanged: (_) => _updateAreFieldsFilled(),
                decoration: InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Inserisci il nome',
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
                controller: cognomeController,
                onChanged: (_) => _updateAreFieldsFilled(),
                decoration: InputDecoration(
                  labelText: 'Cognome',
                  hintText: 'Inserisci il cognome',
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
              DropdownButtonFormField<AziendaModel>(
                value: selectedAzienda,
                onChanged: (azienda) {
                  setState(() {
                    selectedAzienda = azienda;
                    _updateAreFieldsFilled();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Azienda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                items: aziendeList.map((azienda) {
                  return DropdownMenuItem<AziendaModel>(
                    value: azienda,
                    child: Text(azienda.nome!),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: cellulareController,
                onChanged: (_) => _updateAreFieldsFilled(),
                decoration: InputDecoration(
                  labelText: 'Cellulare',
                  hintText: 'Inserisci il numero di cellulare',
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
                controller: ibanController,
                onChanged: (_) => _updateAreFieldsFilled(),
                decoration: InputDecoration(
                  labelText: 'IBAN',
                  hintText: 'Inserisci l\'IBAN',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci l\'IBAN';
                  }
                  if (!validateItalianIBAN(value)) {
                    return 'IBAN non valido per l\'Italia';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedProvvigione,
                onChanged: (value) {
                  setState(() {
                    selectedProvvigione = value!;
                    _updateAreFieldsFilled();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Categoria provvigione',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                items: ['3%', '5%', '10%', '20%', '30%']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:[
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        nomeController.clear();
                        cognomeController.clear();
                        emailController.clear();
                        riferimentoAziendaleController.clear();
                        cellulareController.clear();
                        luogoLavoroController.clear();
                        ibanController.clear();
                        selectedProvvigione = '3%';
                        _updateAreFieldsFilled();
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
                    onPressed: _areFieldsFilled? () => createAgente() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Salva agente',
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