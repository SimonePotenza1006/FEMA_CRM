import 'package:fema_crm/model/LicenzaModel.dart';
import 'package:flutter/material.dart';
import 'package:io/ansi.dart';
import 'dart:convert';
import '../databaseHandler/DbHelper.dart';
import 'package:http/http.dart' as http;

class CreazioneLicenzaPage extends StatefulWidget {
  const CreazioneLicenzaPage({super.key, Key? key1});

  @override
  _CreazioneLicenzaPageState createState() => _CreazioneLicenzaPageState();
}

class _CreazioneLicenzaPageState extends State<CreazioneLicenzaPage> {
  DbHelper? dbHelper;
  final _formKey = GlobalKey<FormState>();
  final _licenzaController = TextEditingController();
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
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';

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
          'GESTIONE LICENZE',
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
                    SizedBox(height: 20),
                    _buildTextFormField(_licenzaController, 'Licenza',
                        'Inserisci una licenza'),

                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          createNewLicenza();
                        }
                      },
                      child: Text('SALVA', style: TextStyle(color: Colors.white)),
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                      ),
                    ),
                    SizedBox(height: 30),
                    FutureBuilder<List<LicenzaModel>>(
                      future: futureLicenze(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else {
                          return DataTable(
                            headingRowHeight: 30,
                            //columnSpacing: 10,
                            dataRowMinHeight:  30,
                            border: TableBorder.all(color: Colors.grey),
                            columns: [
                              DataColumn(
                                label: Container(
                                  width: 140, // Imposta la larghezza se necessario
                                  child: Text(
                                    'LICENZA',
                                    textAlign: TextAlign.center, // Centra il testo
                                  ),
                                ),
                              ),
                              DataColumn(label: Text('UTILIZZATA')),
                              DataColumn(
                                label: Container(
                                  width: 140, // Imposta la larghezza se necessario
                                  child: Text(
                                    'NOTE',
                                    textAlign: TextAlign.center, // Centra il testo
                                  ),
                                ),
                              ),
                              DataColumn(label: Text('')),
                            ],
                            rows: snapshot.data!.map((model) {
                              TextEditingController _controller = TextEditingController(text: model.note);
                              return DataRow(cells: [
                                DataCell(
                                    Container(width: 140,
                                      alignment: Alignment.center,
                                      child: Text(model.descrizione!))),
                                DataCell(
                                    Container(//width: 120,
                                    alignment: Alignment.center,
                                    child:
                                    Text(model.utilizzato! ? 'SI' : 'NO'))),
                                DataCell(
                                  Container(width: 140,
                                  alignment: Alignment.centerLeft,
                                  child:
                                    TextField(
                                    controller: TextEditingController(
                                        text: _controller.text),
                                        onChanged: (value) {
                                          _controller.text = value;
                                    },
                                  ),
                                )),
                                DataCell(
                                    Container(
                                        alignment: Alignment.center,
                                        child:
                                        ElevatedButton(
                                          onPressed:  (_controller.value.text != model.note) ? () {
                                            noteLicenza(model, _controller.value.text).whenComplete(() {
                                                  setState(() {
                                                    //_editedRowIndex = null; // Resetta la riga in modifica
                                                  });
                                                });
                                            } : null,
                                          child: Text('SALVA'),
                                        ),)),
                              ]);
                            }).toList(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              )
          ),
        ),
      ),
    );
  }

  Future<List<LicenzaModel>> futureLicenze() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/licenza');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<LicenzaModel> licenze = [];
        for (var item in jsonData) {
          licenze.add(LicenzaModel.fromJson(item));
        }
        // Recuperare tutte le relazioni utenti-interventi
      return licenze;
      } else {

        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during API call: $e')),
      );
      return [];
    }
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

  Future<void> noteLicenza(LicenzaModel licenza, String note) async {
    print(licenza.note.toString()+' '+note);
    final url = Uri.parse('$ipaddress/api/licenza/nuova');
    final body = jsonEncode({
      'id': licenza.id!,
      'descrizione': licenza.descrizione,
      'utilizzato': true,
      'note': note
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) {
        print('Licenza modificata con successo!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Note modificate!'),
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
        throw Exception('Errore durante il salvataggio della licenza');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
    }
  }

  Future<void> createNewLicenza() async {
    final url = Uri.parse('$ipaddress/api/licenza/nuova');
    final body = jsonEncode({
      'descrizione': _licenzaController.text,
      'utilizzato': false
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 201) {
        print('Licenza creata con successo!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Licenza creata!'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
        _licenzaController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Qualcosa è andato storto!'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
        throw Exception('Errore durante il salvataggio della licenza');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
    }
  }
}
