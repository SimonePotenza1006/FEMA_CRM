import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fema_crm/model/AziendaModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:fema_crm/model/ClienteModel.dart';
import 'package:fema_crm/model/DestinazioneModel.dart';

import '../model/AgenteModel.dart';

class InizializzazionePreventivoByTecnicoPage extends StatefulWidget {
  final UtenteModel utente;

  const InizializzazionePreventivoByTecnicoPage(
      {Key? key, required this.utente})
      : super(key: key);

  @override
  _InizializzazionePreventivoByTecnicoPageState createState() =>
      _InizializzazionePreventivoByTecnicoPageState();
}

class _InizializzazionePreventivoByTecnicoPageState
    extends State<InizializzazionePreventivoByTecnicoPage> {
  String? selectedCategoria;
  String? selectedListino;
  ClienteModel? selectedCliente;
  DestinazioneModel? selectedDestinazione;
  AgenteModel? agente;
  AziendaModel? selectedAzienda;

  List<AziendaModel> aziendeList = [];
  List<ClienteModel> clientiList = [];
  List<AgenteModel> agentiList = [];
  List<ClienteModel> filteredClientiList = [];
  List<DestinazioneModel> allDestinazioniByCliente = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';

  @override
  void initState() {
    super.initState();
    checkAgentExistence();
    initializeData();
  }

  Future<void> checkAgentExistence() async {
    await getAllAgenti();
    bool agentExists = false;
    for (var agente in agentiList) {
      if (agente.nome == widget.utente.nome &&
          agente.cognome == widget.utente.cognome) {
        agentExists = true;
        break;
      }
    }
    if (!agentExists) {
      // Mostra un dialog di errore e torna alla pagina precedente
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Errore'),
            content: Text(
              'La tua utenza non è stata riconosciuta come agente!',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Torna alla pagina precedente
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> initializeData() async {
    await getAllAziende();
    await getAllAgenti();
    await getAllClienti();
    await findAgente();
    await findAndSetAzienda();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.90;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrazione preventivo',
            style: TextStyle(color: Colors.white)),
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
                        'Listino 0',
                        'Listino 1',
                        'Listino 2',
                        'Listino 3',
                        'Listino 4',
                        'Listino 5',
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
                            selectedCliente?.denominazione ??
                                'Seleziona Cliente',
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
                            selectedDestinazione?.denominazione ??
                                'Seleziona Destinazione',
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
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
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

  Future<void> savePrimePreventivo() async {
    String? selectedListinoValue;

    // Assegna il valore corretto a selectedListinoValue in base all'opzione selezionata
    switch (selectedListino) {
      case 'Listino 0':
        selectedListinoValue = '15%';
        break;
      case 'Listino 1':
        selectedListinoValue = '30%';
        break;
      case 'Listino 2':
        selectedListinoValue = '35%';
        break;
      case 'Listino 3':
        selectedListinoValue = '40%';
        break;
      case 'Listino 4':
        selectedListinoValue = '45%';
        break;
      case 'Listino 5':
        selectedListinoValue = '50%';
        break;
      default:
        // Se nessun valore corrisponde, mantieni il valore attuale di selectedListino
        selectedListinoValue = selectedListino;
    }

    try {
      final response = await http.post(Uri.parse('$ipaddress/api/preventivo'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'azienda': selectedAzienda?.toMap(),
            'agente': agente?.toMap(),
            'categoria_merceologica': selectedCategoria.toString(),
            'listino':
                selectedListinoValue, // Utilizza selectedListinoValue invece di selectedListino
            'cliente': selectedCliente?.toMap(),
            'destinazione': selectedDestinazione?.toMap(),
            'accettato': false,
            'rifiutato': false,
            'attesa': true,
            'pendente': false,
            'consegnato': false,
            'descrizione': "Destinazione: " +
                selectedDestinazione!.denominazione.toString(),
            'utente': widget.utente.toMap(),
          }));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Preventivo registrato, attesa di compilazione completa'),
        ),
      );
    } catch (e) {
      print('Errore durante il salvataggio del preventivo');
    }
  }

  Future<void> getAllClienti() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/cliente');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
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

  Future<void> getAllDestinazioniByCliente(String clientId) async {
    try {
      final response = await http
          .get(Uri.parse('$ipaddress/api/destinazione/cliente/$clientId'));
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
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
                          onTap: () async {
                            setState(() {
                              selectedCliente = cliente;
                            });
                            await getAllDestinazioniByCliente(cliente.id!);
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

  Future<void> getAllAgenti() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/agente');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
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

  Future<void> findAgente() async {
    await getAllAgenti();
    for (var agente in agentiList) {
      if (agente.nome == widget.utente.nome &&
          agente.cognome == widget.utente.cognome) {
        setState(() {
          this.agente = agente;
        });
        print('Agente: ${agente.nome} ${agente.cognome}');
        break;
      }
    }
  }

  Future<void> findAndSetAzienda() async {
    await findAgente();
    if (agente != null) {
      String? aziendaName = agente!.riferimento_aziendale;
      AziendaModel? foundAzienda;
      for (var azienda in aziendeList) {
        if (azienda.nome == aziendaName) {
          foundAzienda = azienda;
          break;
        }
      }
      setState(() {
        selectedAzienda = foundAzienda;
      });
      print('Azienda: ${selectedAzienda?.nome}');
    }
  }
}
