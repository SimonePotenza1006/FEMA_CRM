import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fema_crm/model/AziendaModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:fema_crm/model/ClienteModel.dart';
import 'package:fema_crm/model/DestinazioneModel.dart';

import '../model/AgenteModel.dart';

class RegistrazionePreventivoAmministrazionePage extends StatefulWidget {
  final UtenteModel userData;

  const RegistrazionePreventivoAmministrazionePage({Key? key, required this.userData}) : super(key: key);

  @override
  _RegistrazionePreventivoAmministrazionePageState createState() => _RegistrazionePreventivoAmministrazionePageState();
}

class _RegistrazionePreventivoAmministrazionePageState extends State<RegistrazionePreventivoAmministrazionePage> {
  TextEditingController clienteController = TextEditingController();

  AziendaModel? selectedAzienda;
  AgenteModel? selectedAgente;
  String? selectedCategoria;
  String? selectedListino;
  ClienteModel? selectedCliente;
  DestinazioneModel? selectedDestinazione;

  List<AziendaModel> aziendeList = [];
  List<ClienteModel> clientiList = [];
  List<AgenteModel> agentiList = [];
  List<ClienteModel> filteredClientiList = [];
  List<DestinazioneModel> allDestinazioniByCliente = [];

  @override
  void initState() {
    super.initState();
    getAllAziende();
    getAllAgenti();
    getAllClienti();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.75;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrazione preventivo', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: width,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: DropdownButton<AziendaModel>(
                      value: selectedAzienda,
                      onChanged: (newValue) {
                        setState(() {
                          selectedAzienda = newValue;
                        });
                      },
                      items: aziendeList.map((azienda) {
                        return DropdownMenuItem<AziendaModel>(
                          value: azienda,
                          child: Text(azienda.nome.toString()),
                        );
                      }).toList(),
                      hint: Text('Seleziona Azienda'),
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      _showAgentiDialog();
                    },
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedAgente?.nome ?? 'Seleziona Agente',
                            style: TextStyle(fontSize: 16),
                          ),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: DropdownButton<String>(
                      value: selectedCategoria,
                      onChanged: (newValue) {
                        setState(() {
                          selectedCategoria = newValue;
                        });
                      },
                      items: [
                        'Elettronico',
                        'Elettrico',
                        'Idraulico',
                        'Informatico',
                        'Toner',
                        'Utensili',
                        'Rangers',
                      ].map((categoria) {
                        return DropdownMenuItem<String>(
                          value: categoria,
                          child: Text(categoria),
                        );
                      }).toList(),
                      hint: Text('Categoria Merceologica'),
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: DropdownButton<String>(
                      value: selectedListino,
                      onChanged: (newValue) {
                        setState(() {
                          selectedListino = newValue;
                        });
                      },
                      items: [
                        '15%',
                        '30%',
                        '35%',
                        '40%',
                        '45%',
                        '50%',
                      ].map((listino) {
                        return DropdownMenuItem<String>(
                          value: listino,
                          child: Text(listino),
                        );
                      }).toList(),
                      hint: Text('Listino'),
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      _showClientiDialog();
                    },
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedCliente?.denominazione ?? 'Seleziona Cliente',
                            style: TextStyle(fontSize: 16),
                          ),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      _showDestinazioniDialog();
                    },
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDestinazione?.denominazione ?? 'Seleziona Destinazione',
                            style: TextStyle(fontSize: 16),
                          ),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        savePrimePreventivo();
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        ),
                      ),
                      child: Text(
                        'Salva',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getAllAgenti() async {
    try {
      var apiUrl = Uri.parse('http://192.168.1.52:8080/api/agente');
      var response = await http.get(apiUrl);

      if(response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<AgenteModel> agenti = [];
        for(var item in jsonData) {
          agenti.add(AgenteModel.fromJson(item));
        }
        setState(() {
          agentiList = agenti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
      _showErrorDialog();
    }
  }

  Future<void> getAllAziende() async {
    try {
      var apiUrl = Uri.parse('http://192.168.1.52:8080/api/azienda');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
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

  Future<void> getAllClienti() async {
    try {
      var apiUrl = Uri.parse('http://192.168.1.52:8080/api/cliente');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<ClienteModel> clienti = [];
        for (var item in jsonData) {
          clienti.add(ClienteModel.fromJson(item));
        }
        setState(() {
          clientiList = clienti;
          filteredClientiList = clienti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
      _showErrorDialog();
    }
  }

  Future<void> savePrimePreventivo() async {
    try {
      final response = await http.post(
          Uri.parse('http://192.168.1.52:8080/api/preventivo'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'azienda' : selectedAzienda?.toMap(),
            'agente': selectedAgente?.toMap(),
            'categoria_merceologica' : selectedCategoria.toString(),
            'listino':selectedListino.toString(),
            'cliente' : selectedCliente?.toMap(),
            'accettato' : false,
            'rifiutato' : false,
            'attesa': true,
            'pendente':false,
            'consegnato' : false,
            'descrizione' : "Destinazione: " + selectedDestinazione!.denominazione.toString(),
            'utente' : widget.userData.toMap(),
          })
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preventivo registrato, attesa di compilazione completa'),
        ),
      );
    } catch (e){
      print('Errore durante il salvataggio del preventivo');
    }
  }

  Future<void> getAllDestinazioniByCliente(String clientId) async{
    try {
      final response = await http.get(Uri.parse('http://192.168.1.52:8080/api/destinazione/cliente/$clientId'));
      if(response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          allDestinazioniByCliente = responseData.map((data) => DestinazioneModel.fromJson(data)).toList();
        });
      } else {
        throw Exception('Failed to load Destinazioni per cliente');
      }
    } catch(e) {
      print('Errore durante la richiesta HTTP: $e');
    }
  }

  void _showClientiDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Seleziona Cliente',
            textAlign: TextAlign.center,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      filteredClientiList = clientiList
                          .where((cliente) => cliente.denominazione!.toLowerCase().contains(value.toLowerCase()))
                          .toList();
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Cerca Cliente',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: filteredClientiList.map((cliente) {
                        return ListTile(
                          leading: Icon(Icons.contact_page_outlined),
                          title: Text(cliente.denominazione! + ", " + cliente.indirizzo!),
                          onTap: () {
                            setState(() {
                              selectedCliente = cliente;
                              getAllDestinazioniByCliente(cliente.id!);
                            });
                            Navigator.of(context).pop();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDestinazioniDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Seleziona Destinazione',
            textAlign: TextAlign.center,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: allDestinazioniByCliente.map((destinazione) {
                        return ListTile(
                          leading: Icon(Icons.home_work_outlined),
                          title: Text(destinazione.denominazione!),
                          onTap: () {
                            setState(() {
                              selectedDestinazione = destinazione;
                            });
                            Navigator.of(context).pop();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAgentiDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Seleziona Agente',
            textAlign: TextAlign.center,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: agentiList.map((agente) {
                        return ListTile(
                          leading: Icon(Icons.person),
                          title: Text(agente.nome! + " " + agente.cognome!),
                          onTap: () {
                            setState(() {
                              selectedAgente = agente;
                            });
                            Navigator.of(context).pop();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
