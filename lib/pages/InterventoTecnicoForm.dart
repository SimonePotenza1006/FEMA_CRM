import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/CategoriaInterventoSpecificoModel.dart';
import '../model/ClienteModel.dart';
import '../model/DestinazioneModel.dart';
import '../model/TipologiaInterventoModel.dart';
import '../model/UtenteModel.dart';
import '../model/VeicoloModel.dart';


class InterventoTecnicoForm extends StatefulWidget {
  final UtenteModel userData;

  const InterventoTecnicoForm({Key? key, required this.userData});

  @override
  _InterventoTecnicoFormState createState() => _InterventoTecnicoFormState();
}

class _InterventoTecnicoFormState extends State<InterventoTecnicoForm>{
  CategoriaInterventoSpecificoModel? selectedCategoria;
  List<TipologiaInterventoModel> allTipologie = [];
  VeicoloModel? _selectedVeicolo;
  DateTime _dataOdierna = DateTime.now();
  TimeOfDay _orarioInizio = TimeOfDay.now();
  TimeOfDay _orarioFine = TimeOfDay.now();
  VeicoloModel? selectedVeicolo;
  String _descrizione = '';
  bool _interventoConcluso = false;
  ClienteModel? selectedCliente;
  DestinazioneModel? selectedDestinazione;
  List<VeicoloModel> veicoliList = [];
  List<ClienteModel> clientiList = [];
  List<ClienteModel> filteredClientiList = [];
  List<DestinazioneModel> allDestinazioniByCliente = [];
  List<CategoriaInterventoSpecificoModel> allCategorieByTipologia = [];
  TextEditingController _descrizioneController = TextEditingController();
  TipologiaInterventoModel? _selectedTipologia;

  @override
  void initState() {
    super.initState();
    getAllClienti();
    getAllVeicoli();
    getAllTipologie();
  }

  @override
  void dispose() {
    _descrizioneController.dispose();
    super.dispose();
  }

  Future<void> getAllTipologie() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.52:8080/api/tipologiaIntervento'));
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<TipologiaInterventoModel> tipologie = [];
        for(var item in jsonData) {
          tipologie.add(TipologiaInterventoModel.fromJson(item));
        }
        setState(() {
          allTipologie = tipologie;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
      _showErrorDialog();
    }
  }

  Future<void> getCategoriaByTipologia() async {
    try {
      if (_selectedTipologia != null) {
        final response = await http.get(Uri.parse('http://192.168.1.52:8080/api/categorieIntervento/tipologia/${_selectedTipologia!.id}'));
        if (response.statusCode == 200) {
          var jsonData = jsonDecode(response.body);
          List<CategoriaInterventoSpecificoModel> categorie = [];
          for (var item in jsonData) {
            categorie.add(CategoriaInterventoSpecificoModel.fromJson(item));
          }
          setState(() {
            allCategorieByTipologia = categorie;
            selectedCategoria = null; // Resetta la categoria selezionata
          });
        } else {
          throw Exception('Failed to load data from API: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
      _showErrorDialog();
    }
  }

  Future<void> _selezionaData() async {
    final DateTime? dataSelezionata = await showDatePicker(
      context: context,
      initialDate: _dataOdierna,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (dataSelezionata != null && dataSelezionata != _dataOdierna) {
      setState(() {
        _dataOdierna = dataSelezionata;
      });
    }
  }

  Future<void> _selezionaOrarioInizio() async {
    final TimeOfDay? orarioSelezionato = await showTimePicker(
      context: context,
      initialTime: _orarioInizio,
    );
    if (orarioSelezionato != null && orarioSelezionato != _orarioInizio) {
      setState(() {
        _orarioInizio = orarioSelezionato;
      });
    }
  }

  Future<void> _selezionaOrarioFine() async {
    final TimeOfDay? orarioSelezionato = await showTimePicker(
      context: context,
      initialTime: _orarioFine,
    );
    if (orarioSelezionato != null && orarioSelezionato != _orarioFine) {
      setState(() {
        _orarioFine = orarioSelezionato;
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inserimento Intervento Tecnico', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red, // Imposta il colore di sfondo
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Data: ${_dataOdierna.day}/${_dataOdierna.month}/${_dataOdierna.year}'),
            ElevatedButton(
              onPressed: _selezionaData,
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Imposta il colore di sfondo
              ),
              child: const Text('Seleziona Data', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20.0),
            Row(
              children: [
                const Text('Intervento Concluso:', style: TextStyle(color: Colors.black)),
                Checkbox(
                  value: _interventoConcluso,
                  onChanged: (bool? value) {
                    setState(() {
                      _interventoConcluso = value!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            DropdownButton<TipologiaInterventoModel>(
              value: _selectedTipologia,
              hint: Text('Seleziona tipologia di intervento'), // Testo di default
              onChanged: (TipologiaInterventoModel? newValue) {
                setState(() {
                  _selectedTipologia = newValue;
                  getCategoriaByTipologia(); // Carica le categorie di intervento specifiche
                });
              },
              items: allTipologie.map<DropdownMenuItem<TipologiaInterventoModel>>((TipologiaInterventoModel value) {
                return DropdownMenuItem<TipologiaInterventoModel>(
                  value: value,
                  child: Text(value.descrizione!),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Dropdown per selezionare la categoria di intervento
            DropdownButton<CategoriaInterventoSpecificoModel>(
              value: selectedCategoria,
              hint: Text('Seleziona categoria di intervento'), // Testo di default
              onChanged: (CategoriaInterventoSpecificoModel? newValue) {
                setState(() {
                  selectedCategoria = newValue;
                });
              },
              items: allCategorieByTipologia.map<DropdownMenuItem<CategoriaInterventoSpecificoModel>>((CategoriaInterventoSpecificoModel value) {
                return DropdownMenuItem<CategoriaInterventoSpecificoModel>(
                  value: value,
                  child: Text(value.descrizione!),
                );
              }).toList(),
            ),
            if (_interventoConcluso) // Mostra i bottoni solo se l'intervento è concluso
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dropdown per selezionare il veicolo
                  DropdownButton<VeicoloModel>(
                    value: _selectedVeicolo,
                    hint: Text('Seleziona veicolo'), // Testo di default
                    onChanged: (VeicoloModel? newValue) {
                      setState(() {
                        _selectedVeicolo = newValue;
                      });
                    },
                    items: veicoliList.map<DropdownMenuItem<VeicoloModel>>((VeicoloModel value) {
                      return DropdownMenuItem<VeicoloModel>(
                        value: value,
                        child: Text(value.descrizione!),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _selezionaOrarioInizio,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // Imposta il colore di sfondo
                    ),
                    child: Text('Orario Inizio: ${_orarioInizio.format(context)}', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _selezionaOrarioFine,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // Imposta il colore di sfondo
                    ),
                    child: Text('Orario Fine: ${_orarioFine.format(context)}', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _descrizioneController,
              decoration: const InputDecoration(labelText: 'Descrizione'),
              onChanged: (value) {
                setState(() {
                  _descrizione = value;
                });
              },
            ),
            SizedBox(height: 20),
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
            SizedBox(height: 20),
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
            const SizedBox(height: 20.0),
            Expanded(
              child: Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ElevatedButton(
                  onPressed: () {
                    saveIntervento();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // Imposta il colore di sfondo
                  ),
                  child: const Text('Salva Intervento', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  DateTime timeOfDayToDateTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  }

  Future<void> saveIntervento() async {
    try {
      // Inizializziamo le variabili per i valori da inviare
      DateTime? orarioInizioSalvato;
      DateTime? orarioFineSalvato;
      bool assegnatoValue = false;
      bool conclusoValue = false;
      Map<String, dynamic>? veicolo;
      Map<String, dynamic>? utente;

      // Verifichiamo lo stato della checkbox
      if (_interventoConcluso) {
        final now = DateTime.now();
        // Se l'intervento è concluso, convertiamo i valori TimeOfDay in DateTime
        orarioInizioSalvato = DateTime(
          now.year,
          now.month,
          now.day,
          _orarioInizio.hour,
          _orarioInizio.minute,
        );
        orarioFineSalvato = DateTime(
          now.year,
          now.month,
          now.day,
          _orarioFine.hour,
          _orarioFine.minute,
        );
        // Impostiamo i valori delle proprietà assegnato e concluso
        assegnatoValue = true;
        conclusoValue = true;
        veicolo = selectedVeicolo?.toMap();
        utente = widget.userData.toMap();
      }

      // Effettuiamo la richiesta HTTP con i dati appropriati in base allo stato della checkbox
      final response = await http.post(
        Uri.parse('http://192.168.1.52:8080/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': DateTime.now().toIso8601String(),
          'orario_inizio': orarioInizioSalvato?.toIso8601String(),
          'orario_fine': orarioFineSalvato?.toIso8601String(),
          'descrizione': _descrizioneController.text,
          'importo_intervento': null,
          'assegnato': assegnatoValue,
          'concluso': conclusoValue,
          'saldato': false,
          'note': null,
          'firma_cliente': null,
          'utente': utente,
          'cliente': selectedCliente?.toMap(),
          'veicolo': veicolo,
          'tipologia': _selectedTipologia?.toMap(),
          'categoria_intervento_specifico': selectedCategoria?.toMap(),
          'tipologia_pagamento': null,
          'destinazione': selectedDestinazione?.toMap(),
        }),
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Intervento registrato con successo!'),
        ),
      );
    } catch (e) {
      print('Errore durante il salvataggio dell\'intervento: $e');
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

  Future<void> getAllVeicoli() async {
    try {
      http.Response response = await http.get(Uri.parse('http://192.168.1.52:8080/api/veicolo'));
      var responseData = json.decode(response.body.toString());
      if (response.statusCode == 200) {
        List<VeicoloModel> allVeicoli = [];
        for (var veicoloJson in responseData) {
          VeicoloModel veicolo = VeicoloModel.fromJson(veicoloJson);
          allVeicoli.add(veicolo);
        }
        setState(() {
          veicoliList = allVeicoli;
        });
      }
    } catch (e) {
      print('Errore durante il fetch dei veicoli: $e');
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
}
