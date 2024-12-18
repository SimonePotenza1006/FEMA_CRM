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
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';
  int? activeSaveIndex;
  Map<String, TextEditingController> _noteControllers = {};
  Map<String, ValueNotifier<bool>> _isSaveEnabled = {};
  int? _currentlyEditingId;

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
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CreazioneLicenzaPage()));
              //getAllInterventi();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
              key: _formKey,
              child: Center(
                child:
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        SizedBox(height: 20),
                        FutureBuilder<List<LicenzaModel>>(
                          future: futureLicenze(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else {
                              // Inizializza la lista delle note se è vuota
                              if (_noteControllers.isEmpty) {
                                for (var licenza in snapshot.data!) {
                                  var controller = TextEditingController(text: licenza.note);
                                  _noteControllers[licenza.id!] = controller;
                                  _isSaveEnabled[licenza.id!] = ValueNotifier(false);

                                  controller.addListener(() {
                                    // Aggiorna il ValueNotifier in base al contenuto del campo di testo
                                    _isSaveEnabled[licenza.id!]!.value = controller.text.isNotEmpty;
                                  });
                                }
                              }

                              return DataTable(
                                headingRowHeight: 30,
                                //columnSpacing: 10,
                                dataRowMinHeight:  20,
                                dataRowMaxHeight: 34,

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
                                      width: 210, // Imposta la larghezza se necessario
                                      child: Text(
                                        'NOTE',
                                        textAlign: TextAlign.center, // Centra il testo
                                      ),
                                    ),
                                  ),

                                ],
                                rows: snapshot.data!.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  LicenzaModel model = entry.value;

                                  TextEditingController _controller = TextEditingController(text: model.note);
                                  //bool isModified = false; // Flag per controllare se la nota è stata modificata


                                  return DataRow(cells: [
                                    DataCell(
                                        Container(
                                            width: 140,
                                            alignment: Alignment.center,
                                            child: Text(model.descrizione!))),
                                    DataCell(
                                        Container(//width: 120,
                                            alignment: Alignment.center,
                                            child:
                                            Text(model.utilizzato! ? 'SI' : 'NO'))),
                                    DataCell(
                                        Container(width: 210,
                                            alignment: Alignment.centerLeft,
                                            child: Row(children: [

                                              IconButton(
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return
                                                          StatefulBuilder(
                                                              builder: (context, setState) {
                                                                // Variabile per memorizzare l'aliquota IVA selezionata
                                                                return AlertDialog(
                                                                    title: Text('Modifica note'),
                                                                    actions: <Widget>[
                                                                      TextFormField(
                                                                        controller: _controller,
                                                                        decoration: InputDecoration(
                                                                          labelText: 'Note',
                                                                          border: OutlineInputBorder(),
                                                                        ),

                                                                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed: () {
                                                                          noteLicenza(model, _controller.text).then((_) {
                                                                            Navigator.pushReplacement(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) => CreazioneLicenzaPage()),
                                                                            );
                                                                          });;

                                                                        },
                                                                        child: Text('Salva note'),
                                                                      ),
                                                                    ]);});});


                                                }, icon: Icon(Icons.create, color: Colors.grey),),
                                              Text(model.note ?? ''),
                                            ],)//Text(model.note ?? '')
                                        )
                                    ),
                                  ]);
                                }).toList(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    Column(children: [
                      SizedBox(width: 40),]),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                          child: Text('CREA', style: TextStyle(color: Colors.white)),
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                          ),
                        ),

                      ],)

                  ],),

              )
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _noteControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<List<LicenzaModel>> futureLicenze() async {
    try {
      var apiUrl = Uri.parse('$ipaddress2/api/licenza/all');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<LicenzaModel> licenze = [];
        for (var item in jsonData) {
          licenze.add(LicenzaModel.fromJson(item));
        }
        // Recuperare tutte le relazioni utenti-interventi
        return licenze.reversed.toList();
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
      ),
    );
  }

  Future<void> noteLicenza(LicenzaModel licenza, String note) async {
    print(licenza.note.toString()+' '+note);
    final url = Uri.parse('$ipaddress2/api/licenza/nuova');
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
      if (response.statusCode == 201) {
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
    final url = Uri.parse('$ipaddress2/api/licenza/nuova');
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
