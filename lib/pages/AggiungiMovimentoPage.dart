import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import '../model/ClienteModel.dart';
import '../model/InterventoModel.dart';
import '../model/MovimentiModel.dart';
import '../model/UtenteModel.dart';
import 'HomeFormAmministrazione.dart';
import 'PDFPagamentoAccontoPage.dart';
import 'PDFPrelievoCassaPage.dart';

class AggiungiMovimentoPage extends StatefulWidget {
  final UtenteModel userData;

  const AggiungiMovimentoPage({Key? key, required this.userData}) : super(key: key);

  @override
  _AggiungiMovimentoPageState createState() => _AggiungiMovimentoPageState();
}

class _AggiungiMovimentoPageState extends State<AggiungiMovimentoPage> {
  final TextEditingController _descrizioneController = TextEditingController();
  final TextEditingController _importoController = TextEditingController();
  late DateTime selectedDate;
  UtenteModel? selectedUtente;
  TipoMovimentazione? _selectedTipoMovimentazione;
  List<UtenteModel> allUtenti = [];
  Uint8List? signatureBytesIncaricato;
  GlobalKey<SfSignaturePadState> _signaturePadKeyIncaricato = GlobalKey<SfSignaturePadState>();
  Uint8List? signatureBytes;
  GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey<SfSignaturePadState>();
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  ClienteModel? selectedCliente;
  List<ClienteModel> clientiList = [];
  List<ClienteModel> filteredClientiList = [];
  List<InterventoModel> interventi = [];
  InterventoModel? selectedIntervento;

  @override
  void initState() {
    super.initState();
    getAllUtenti();
    getAllClienti();
    _signaturePadKey = GlobalKey<SfSignaturePadState>();
    selectedDate = DateTime.now(); // Inizializza la data selezionata con la data corrente
  }

  void _showInterventiDialog() {
    var importo = selectedIntervento?.importo_intervento?.toStringAsFixed(2) ?? 'Importo non inserito';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleziona l\'intervento', textAlign: TextAlign.center),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: interventi.map((intervento) {
                        return ListTile(
                          leading: const Icon(Icons.settings),
                          title: Text('${intervento.descrizione!}, importo: ${importo}'),
                          subtitle: Text(intervento.saldato! ? 'Saldato' : 'Non saldato'),
                          onTap: () {
                            setState(() {
                              selectedIntervento = intervento;
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

  void _showClientiDialog() {
    TextEditingController searchController = TextEditingController(); // Aggiungi un controller
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) { // Usa StatefulBuilder per aggiornare lo stato del dialogo
            return AlertDialog(
              title: const Text('Seleziona Cliente', textAlign: TextAlign.center),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController, // Aggiungi il controller
                      onChanged: (value) {
                        setState(() {
                          filteredClientiList = clientiList
                              .where((cliente) => cliente.denominazione!
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Cerca Cliente',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: filteredClientiList.map((cliente) {
                            return ListTile(
                              leading: const Icon(Icons.contact_page_outlined),
                              title: Text(
                                  '${cliente.denominazione}, ${cliente.indirizzo}'),
                              onTap: () {
                                setState(() {
                                  selectedCliente = cliente;
                                  getAllInterventiByCliente(cliente.id!);
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
      },
    );
  }

  Future<void> getAllInterventiByCliente(String clientId) async {
    try {
      final response = await http.get(Uri.parse('$ipaddress/api/intervento/cliente/$clientId'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          interventi = responseData.map((data) => InterventoModel.fromJson(data)).toList();
        });
      } else {
        throw Exception('Failed to load Destinazioni per cliente');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
    }
  }

  Future<void> getAllClienti() async {
    try {
      final response = await http.get(Uri.parse('$ipaddress/api/cliente'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aggiungi Movimento', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _descrizioneController,
                  decoration: InputDecoration(
                    labelText: 'Descrizione',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci una descrizione';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _importoController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Importo',
                  ),
                  validator: (value) {
                    if (value == null || double.tryParse(value) == null) {
                      return 'Inserisci un importo valido';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<TipoMovimentazione>(
                  value: _selectedTipoMovimentazione,
                  onChanged: (TipoMovimentazione? newValue) {
                    setState(() {
                      _selectedTipoMovimentazione = newValue;
                      if (_selectedTipoMovimentazione == TipoMovimentazione.Entrata || _selectedTipoMovimentazione == TipoMovimentazione.Uscita || _selectedTipoMovimentazione == TipoMovimentazione.Acconto || _selectedTipoMovimentazione == TipoMovimentazione.Pagamento) {
                        _selectUtente();
                      } else {
                        selectedUtente = null;
                      }
                    });
                  },
                  items: TipoMovimentazione.values.map<DropdownMenuItem<TipoMovimentazione>>((TipoMovimentazione value) {
                    String label;
                    if (value == TipoMovimentazione.Entrata) {
                      label = 'Entrata';
                    } else if (value == TipoMovimentazione.Uscita) {
                      label = 'Uscita';
                    } else if(value == TipoMovimentazione.Acconto){
                      label = 'Acconto';
                    } else {
                      label = 'Pagamento';
                    }
                    return DropdownMenuItem<TipoMovimentazione>(
                      value: value,
                      child: Text(label),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Tipo Movimentazione',
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Seleziona il tipo di movimentazione';
                    }
                    return null;
                  },
                ),
                if ((_selectedTipoMovimentazione == TipoMovimentazione.Entrata || _selectedTipoMovimentazione == TipoMovimentazione.Uscita || _selectedTipoMovimentazione == TipoMovimentazione.Acconto || _selectedTipoMovimentazione == TipoMovimentazione.Pagamento) && selectedUtente != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Utente selezionato: ${selectedUtente!.nome}',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 40),
                if (_selectedTipoMovimentazione == TipoMovimentazione.Entrata || _selectedTipoMovimentazione == TipoMovimentazione.Uscita || _selectedTipoMovimentazione == TipoMovimentazione.Acconto || _selectedTipoMovimentazione == TipoMovimentazione.Pagamento)
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Container(
                              width: 700,
                              height: 250,
                              child: SfSignaturePad(
                                key: _signaturePadKey,
                                backgroundColor: Colors.white,
                                strokeColor: Colors.black,
                                minimumStrokeWidth: 2.0,
                                maximumStrokeWidth: 4.0,
                              ),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Chiudi'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final signatureImage = await _signaturePadKey
                                      .currentState!
                                      .toImage(pixelRatio: 3.0);
                                  final data = await signatureImage.toByteData(
                                      format: ui.ImageByteFormat.png);
                                  setState(() {
                                    signatureBytes = data!.buffer.asUint8List();
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: Text('Salva'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Center(
                        child: signatureBytes != null
                            ? Image.memory(signatureBytes!)
                            : Text(
                          'Firma utente alla cassa',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                if (_selectedTipoMovimentazione == TipoMovimentazione.Entrata || _selectedTipoMovimentazione == TipoMovimentazione.Uscita || _selectedTipoMovimentazione == TipoMovimentazione.Acconto || _selectedTipoMovimentazione == TipoMovimentazione.Pagamento)
                  SizedBox(height: 20),
                if (_selectedTipoMovimentazione == TipoMovimentazione.Entrata || _selectedTipoMovimentazione == TipoMovimentazione.Uscita || _selectedTipoMovimentazione == TipoMovimentazione.Acconto || _selectedTipoMovimentazione == TipoMovimentazione.Pagamento)
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Container(
                              width: 700,
                              height: 250,
                              child: SfSignaturePad(
                                key: _signaturePadKeyIncaricato,
                                backgroundColor: Colors.white,
                                strokeColor: Colors.black,
                                minimumStrokeWidth: 2.0,
                                maximumStrokeWidth: 4.0,
                              ),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Chiudi'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final signatureImage = await _signaturePadKeyIncaricato
                                      .currentState!
                                      .toImage(pixelRatio: 3.0);
                                  final data = await signatureImage.toByteData(
                                      format: ui.ImageByteFormat.png);
                                  setState(() {
                                    signatureBytesIncaricato = data!.buffer.asUint8List();
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: Text('Salva'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Center(
                        child: signatureBytesIncaricato != null
                            ? Image.memory(signatureBytesIncaricato!)
                            : Text(
                          'Firma utente incaricato',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                if(_selectedTipoMovimentazione == TipoMovimentazione.Acconto || _selectedTipoMovimentazione == TipoMovimentazione.Pagamento)
                  Container(
                    child: GestureDetector(
                      onTap: () {
                        _showClientiDialog();
                      },
                      child: SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(selectedCliente?.denominazione ?? 'Seleziona Cliente', style: const TextStyle(fontSize: 16)),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                if(_selectedTipoMovimentazione == TipoMovimentazione.Acconto || _selectedTipoMovimentazione == TipoMovimentazione.Pagamento)
                  Container(
                    child: GestureDetector(
                      onTap: () {
                        _showInterventiDialog();
                      },
                      child: SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(selectedIntervento?.descrizione ?? 'Seleziona l\'intervento', style: const TextStyle(fontSize: 16)),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _selectDate(context);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                    ),
                    child: Text(
                      'Seleziona Data',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    'Data selezionata: ${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year.toString().substring(2)}',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_validateInputs()) {
                        if(_selectedTipoMovimentazione == TipoMovimentazione.Entrata || _selectedTipoMovimentazione == TipoMovimentazione.Uscita){
                          addMovimento();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => PDFPrelievoCassaPage(utente: widget.userData, data: selectedDate, incaricato:selectedUtente, descrizione : _descrizioneController.text, importo : _importoController.text, firmaCassa : signatureBytes, firmaIncaricato: signatureBytesIncaricato, tipoMovimentazione: _selectedTipoMovimentazione!)),
                          );
                        } else if(_selectedTipoMovimentazione == TipoMovimentazione.Pagamento){
                          saveStatusInterventoPagamento();
                          addMovimento();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => PDFPagamentoAccontoPage(utente : selectedUtente, data: selectedDate, descrizione : _descrizioneController.text, importo: _importoController.text, tipoMovimentazione: _selectedTipoMovimentazione!, cliente : selectedCliente, intervento : selectedIntervento, firmaCassa: signatureBytes, firmaIncaricato: signatureBytesIncaricato))
                          );
                        } else {
                          saveStatusInterventoAcconto();
                          saveNotaAcconto();
                          addMovimento();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => PDFPagamentoAccontoPage(utente : selectedUtente, data: selectedDate, descrizione : _descrizioneController.text, importo: _importoController.text, tipoMovimentazione: _selectedTipoMovimentazione!, cliente : selectedCliente, intervento : selectedIntervento, firmaCassa: signatureBytes, firmaIncaricato: signatureBytesIncaricato))
                          );
                        }
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                    ),
                    child: Text(
                      'Conferma Inserimento',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  bool _validateInputs() {
    if (_selectedTipoMovimentazione == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seleziona il tipo di movimentazione'),
        ),
      );
      return false;
    }
    if (_descrizioneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inserisci una descrizione'),
        ),
      );
      return false;
    }
    if (_importoController.text.isEmpty || double.tryParse(_importoController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inserisci un importo valido'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> getAllUtenti() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/utente');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<UtenteModel> utenti = [];
        for(var item in jsonData){
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          allUtenti = utenti;
        });
      } else {
        throw Exception(
            'Failed to load agenti data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching agenti data from API: $e');
    }
  }

  Future<void> saveNotaAcconto() async{
    try{
      final now = DateTime.now().toIso8601String();
      final response = await http.post(
        Uri.parse('$ipaddress/api/noteTecnico'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': now,
          'utente': widget.userData.toMap(),
          'nota': "Ricevuto un acconto di ${_importoController.text} ",
          'cliente' : selectedCliente?.toMap(),
          'intervento' : selectedIntervento?.toMap()
        }),
      );
      if (response.statusCode == 201) {
        print('EVVAIIIIIIII2');
      }
    } catch(e){
      print('Errore: $e');
    }
  }

  Future<void> saveStatusInterventoAcconto() async{
    try{
      final response = await http.post(Uri.parse('$ipaddress/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': selectedIntervento?.id,
          'data': selectedIntervento?.data?.toIso8601String(),
          'orario_appuntamento' : selectedIntervento?.orario_appuntamento?.toIso8601String(),
          'orario_inizio': selectedIntervento?.orario_inizio?.toIso8601String(),
          'orario_fine': selectedIntervento?.orario_fine?.toIso8601String(),
          'descrizione': selectedIntervento?.descrizione,
          'importo_intervento': selectedIntervento?.importo_intervento,
          'acconto' : _importoController.text,
          'assegnato': selectedIntervento?.assegnato,
          'conclusione_parziale' : selectedIntervento?.conclusione_parziale,
          'concluso': selectedIntervento?.concluso,
          'saldato': false,
          'note': selectedIntervento?.note,
          'relazione_tecnico' : selectedIntervento?.relazione_tecnico,
          'firma_cliente': selectedIntervento?.firma_cliente,
          'utente': selectedIntervento?.utente?.toMap(),
          'cliente': selectedIntervento?.cliente?.toMap(),
          'veicolo': selectedIntervento?.veicolo?.toMap(),
          'merce': selectedIntervento?.merce?.toMap(),
          'tipologia': selectedIntervento?.tipologia?.toMap(),
          'categoria': selectedIntervento?.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': selectedIntervento?.tipologia_pagamento?.toMap(),
          'destinazione': selectedIntervento?.destinazione?.toMap(),
          'gruppo': selectedIntervento?.gruppo?.toMap()
        }),
      );
      if (response.statusCode == 201) {
        print('EVVAIIIIIIII');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lo stato dell\'intervento è stato salvato correttamente!'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch(e){
      print('Errore: $e');
    }
  }

  Future<void> saveStatusInterventoPagamento() async{
    try{
      final response = await http.post(Uri.parse('$ipaddress/api/intervento'),
          headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': selectedIntervento?.id,
          'data': selectedIntervento?.data?.toIso8601String(),
          'orario_appuntamento' : selectedIntervento?.orario_appuntamento?.toIso8601String(),
          'orario_inizio': selectedIntervento?.orario_inizio?.toIso8601String(),
          'orario_fine': selectedIntervento?.orario_fine?.toIso8601String(),
          'descrizione': selectedIntervento?.descrizione,
          'importo_intervento': selectedIntervento?.importo_intervento,
          'acconto' : double.parse(_importoController.text.toString()),
          'assegnato': selectedIntervento?.assegnato,
          'conclusione_parziale' : selectedIntervento?.conclusione_parziale,
          'concluso': selectedIntervento?.concluso,
          'saldato': true,
          'note': selectedIntervento?.note,
          'relazione_tecnico' : selectedIntervento?.relazione_tecnico,
          'firma_cliente': selectedIntervento?.firma_cliente,
          'utente': selectedIntervento?.utente?.toMap(),
          'cliente': selectedIntervento?.cliente?.toMap(),
          'veicolo': selectedIntervento?.veicolo?.toMap(),
          'merce': selectedIntervento?.merce?.toMap(),
          'tipologia': selectedIntervento?.tipologia?.toMap(),
          'categoria': selectedIntervento?.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': selectedIntervento?.tipologia_pagamento?.toMap(),
          'destinazione': selectedIntervento?.destinazione?.toMap(),
          'gruppo': selectedIntervento?.gruppo?.toMap()
        }),
      );
      if (response.statusCode == 201) {
        print('EVVAIIIIIIII');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lo stato dell\'intervento è stato salvato correttamente!'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch(e){
      print('Errore: $e');
    }
  }

  Future<void> addMovimento() async {
    String formattedDate = DateFormat("yyyy-MM-ddTHH:mm:ss").format(selectedDate.toUtc());
    String tipoMovimentazioneString = _selectedTipoMovimentazione.toString().split('.').last; // Otteniamo solo il nome dell'opzione
    Map<String, dynamic> body = {
      'id': null,
      'data': selectedDate.toIso8601String(),
      'descrizione': _descrizioneController.text,
      'tipo_movimentazione': tipoMovimentazioneString,
      'importo': double.parse(_importoController.text.toString()),
      'utente': widget.userData.toMap(),
    };
    try {
      debugPrint("Body della richiesta: ${body.toString()}");
      final response = await http.post(
        Uri.parse('$ipaddress/api/movimenti'),
        body: jsonEncode(body),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 201) {
        print('Movimentazione salvata con successo');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Movimentazione salvata con successo'),
            ),
          );
        }
      } else {
        print('Errore durante il salvataggio della movimentazione: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore durante il salvataggio della movimentazione'),
            ),
          );
        }
      }
    } catch (e) {
      print('Errore durante la chiamata HTTP: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante la chiamata HTTP'),
          ),
        );
      }
    }
  }

  Future<void> _selectUtente() async {
    selectedUtente = await showDialog<UtenteModel>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleziona Utente'),
          content: SingleChildScrollView(
            child: ListBody(
              children: allUtenti.map((UtenteModel utente) {
                return ListTile(
                  title: Text(utente.nome! + " " + utente.cognome!),
                  onTap: () {
                    Navigator.of(context).pop(utente);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
    setState(() {});
  }
}