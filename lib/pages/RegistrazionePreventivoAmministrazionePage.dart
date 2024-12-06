import 'dart:convert';

import 'package:fema_crm/model/TipologiaInterventoModel.dart';
import 'package:fema_crm/pages/CreazioneClientePage.dart';
import 'package:fema_crm/pages/DettaglioPreventivoAmministrazionePage.dart';
import 'package:fema_crm/pages/NuovaDestinazionePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fema_crm/model/AziendaModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:fema_crm/model/ClienteModel.dart';
import 'package:fema_crm/model/DestinazioneModel.dart';

import '../model/AgenteModel.dart';
import '../model/PreventivoModel.dart';

class RegistrazionePreventivoAmministrazionePage extends StatefulWidget {
  final UtenteModel userData;

  const RegistrazionePreventivoAmministrazionePage(
      {Key? key, required this.userData})
      : super(key: key);

  @override
  _RegistrazionePreventivoAmministrazionePageState createState() =>
      _RegistrazionePreventivoAmministrazionePageState();
}

class _RegistrazionePreventivoAmministrazionePageState
    extends State<RegistrazionePreventivoAmministrazionePage> {

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
  List<PreventivoModel> allPreventiviByCliente = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';

  @override
  void initState() {
    super.initState();
    getAllAziende().then((_) {
      if (aziendeList.isNotEmpty) {
        setState(() {
          selectedAzienda = aziendeList.firstWhere((azienda) => azienda.id == 3.toString());
        });
      }
    });
    getAllAgenti();
    getAllClienti();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.90;

    return Scaffold(
      appBar: AppBar(
        title: const Text('REGISTRAZIONE PREVENTIVO',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
              color: Colors.white,
            ),
            onPressed: () {
              // Funzione per ricaricare la pagina
              getAllClienti();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: width,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    SizedBox(height: 20),
                    SizedBox(
                      width: 220,
                      child: GestureDetector(
                        onTap: () {
                          _showAgentiDialog();
                        },
                        child: SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedAgente?.nome ?? 'Seleziona Agente'.toString().toUpperCase(),
                                style: TextStyle(fontSize: 16),
                              ),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    SizedBox(
                      width: 220,
                      child: GestureDetector(
                        onTap: () {
                          _showClientiDialog();
                        },
                        child: SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedCliente?.denominazione ??
                                    'Seleziona Cliente'.toString().toUpperCase(),
                                style: TextStyle(fontSize: 16),
                              ),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: 220,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CreazioneClientePage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        ),
                        child: Text('CREA NUOVO CLIENTE'),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(width: 250, child: GestureDetector(
                      onTap: () {
                        _showDestinazioniDialog();
                      },
                      child: SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDestinazione?.denominazione ??
                                  'Seleziona Destinazione'.toString().toUpperCase(),
                              style: TextStyle(fontSize: 16),
                            ),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    ),

                    SizedBox(height: 20),
                    SizedBox(
                      width: 260,
                      child: ElevatedButton(
                        onPressed: () {
                          if(selectedCliente != null){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    NuovaDestinazionePage(cliente: selectedCliente!),
                              ),
                            );
                          } else {
                            return _showNoClienteDialog();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        ),
                        child: Text('CREA NUOVA DESTINAZIONE'),
                      ),
                    ),
                    SizedBox(height: 20),
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
                        hint: Text('CATEGORIA MERCEOLOGICA'),
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
                        hint: Text('LISTINO'),
                      ),
                    ),
                    SizedBox(height: 16),

                    SizedBox(height: 20),
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          redirectTo();
                        },
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                            EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          ),
                        ),
                        child: Text(
                          'SALVA',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    if(selectedCliente != null && allPreventiviByCliente.isEmpty)
                      Text('Nessun preventivo associato a ${selectedCliente?.denominazione!} presente nel database.'.toString().toUpperCase()),
                    if(selectedCliente != null && allPreventiviByCliente.isNotEmpty)
                      Center(
                        child: Container(
                            width: 450,
                            height: 400,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade700),
                            ),
                            child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Padding(
                                  padding: EdgeInsets.all(3),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      for(var preventivo in allPreventiviByCliente)
                                        Text(
                                          '  - Preventivo creato in data ${preventivo.data_creazione?.day}/${preventivo.data_creazione?.month}/${preventivo.data_creazione?.year}, listino:${preventivo.listino}',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                    ],
                                  ),
                                )
                            )
                        ),
                      ),
                  ],
                ),
              )
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getAllAgenti() async {
    try {
      var apiUrl = Uri.parse('$ipaddressProva/api/agente');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<AgenteModel> agenti = [];
        for (var item in jsonData) {
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
      var apiUrl = Uri.parse('$ipaddressProva/api/azienda');
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
      var apiUrl = Uri.parse('$ipaddressProva/api/cliente');
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

  Future<http.Response?> savePrimePreventivo() async {
    late http.Response response;
    try {
      response = await http.post(Uri.parse('$ipaddressProva/api/preventivo'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'azienda': selectedAzienda?.toMap(),
            'agente': selectedAgente?.toMap(),
            'categoria_merceologica': selectedCategoria.toString(),
            'listino': selectedListino.toString(),
            'cliente': selectedCliente?.toMap(),
            'accettato': false,
            'rifiutato': false,
            'attesa': true,
            'pendente': false,
            'consegnato': false,
            'destinazione': selectedDestinazione?.toMap(),
            'descrizione': "Destinazione: " +
                selectedDestinazione!.denominazione.toString(),
            'utente': widget.userData.toMap(),
          }));
        return response;
    } catch (e) {
      print('Errore durante il salvataggio del preventivo');
    }
    return null;
  }

  Future<void> redirectTo() async{
    final data = await savePrimePreventivo();
    try {
      if(data == null){
        throw Exception('Dati del preventivo non disponibili.');
      }
      final preventivo = PreventivoModel.fromJson(jsonDecode(data.body));
      try{
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  DettaglioPreventivoAmministrazionePage(preventivo: preventivo)
          )
        );
      } catch(e){
        print('Qualcosa non va');
      }
    } catch(e){

    }
  }

  Future<void> getAllPreventiviByCliente(String clienteId) async {
    try{
      final response = await http.get(Uri.parse('$ipaddressProva/api/preventivo/cliente/$clienteId'));
      if(response.statusCode == 200){
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          allPreventiviByCliente = responseData
              .map((data) => PreventivoModel.fromJson(data))
              .toList();
        });
      } else {
        throw Exception('Failed to load Preventivi per cliente');
      }
    } catch(e){
      print('Errore durante la richiesta HTTP: $e');
    }
  }

  Future<void> getAllDestinazioniByCliente(String clientId) async {
    try {
      final response = await http
          .get(Uri.parse('$ipaddressProva/api/destinazione/cliente/$clientId'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          allDestinazioniByCliente = responseData
              .map((data) => DestinazioneModel.fromJson(data))
              .toList();
        });
      } else {
        throw Exception('Failed to load Destinazioni per cliente');
      }
    } catch (e) {
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
            child: StatefulBuilder(
                builder: (context, setStateDialog) { // Utilizzo di StatefulBuilder
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        onChanged: (value) {
                          setStateDialog(() { // Usa setState del StatefulBuilder
                            filteredClientiList = clientiList
                                .where((cliente) => cliente.denominazione!
                                .toLowerCase()
                                .contains(value.toLowerCase()))
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
                                title: Text(cliente.denominazione!),
                                onTap: () {
                                  setState(() {
                                    selectedCliente = cliente;
                                    getAllDestinazioniByCliente(cliente.id!);
                                    getAllPreventiviByCliente(cliente.id!);
                                  });
                                  Navigator.of(context).pop();
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  );
                }
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
            child: StatefulBuilder(
                builder: (context, setStateDialog) { // Utilizzo di StatefulBuilder
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        onChanged: (value) {
                          setStateDialog(() { // Usa setState del StatefulBuilder
                            allDestinazioniByCliente = allDestinazioniByCliente
                                .where((destinazione) => destinazione.denominazione!
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Cerca Destinazione',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      SizedBox(height: 16),
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
                  );
                }
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

  void _showNoClienteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Attenzione'),
          content: Text('Seleziona un cliente per poter creare una nuova destinazione.'),
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
