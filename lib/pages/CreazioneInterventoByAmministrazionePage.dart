import 'dart:convert';
import 'dart:io';
import 'package:fema_crm/model/InterventoModel.dart';
import 'package:fema_crm/model/MerceInRiparazioneModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:io/ansi.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../model/CategoriaInterventoSpecificoModel.dart';
import '../model/ClienteModel.dart';
import '../model/DestinazioneModel.dart';
import '../model/TipologiaInterventoModel.dart';
import '../model/UtenteModel.dart';
import 'package:image_picker/image_picker.dart';

import 'CreazioneClientePage.dart';
import 'NuovaDestinazionePage.dart';

class CreazioneInterventoByAmministrazionePage extends StatefulWidget {
  const CreazioneInterventoByAmministrazionePage({Key? key}) : super(key: key);

  @override
  _CreazioneInterventoByAmministrazionePageState createState() =>
      _CreazioneInterventoByAmministrazionePageState();
}

class _CreazioneInterventoByAmministrazionePageState
    extends State<CreazioneInterventoByAmministrazionePage> {
  List<XFile> pickedImages =  [];
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  CategoriaInterventoSpecificoModel? selectedCategoria;
  List<TipologiaInterventoModel> allTipologie = [];
  DateTime _dataOdierna = DateTime.now();
  DateTime? selectedDate = null;
  String _descrizione = '';
  String _nota = '';
  ClienteModel? selectedCliente;
  DestinazioneModel? selectedDestinazione;
  List<ClienteModel> clientiList = [];
  List<ClienteModel> filteredClientiList = [];
  List<DestinazioneModel> allDestinazioniByCliente = [];
  List<CategoriaInterventoSpecificoModel> allCategorieByTipologia = [];
  TextEditingController _descrizioneController = TextEditingController();
  TextEditingController _notaController = TextEditingController();
  TipologiaInterventoModel? _selectedTipologia;
  List<UtenteModel> allUtenti = [];
  List<UtenteModel> allCapogruppi = [];
  UtenteModel? _selectedUtente;
  UtenteModel? responsabile;
  UtenteModel? _responsabileSelezionato;
  List<UtenteModel?>? _selectedUtenti = [];
  List<UtenteModel?>? _finalSelectedUtenti = [];
  bool isSelected = false;
  final _formKey = GlobalKey<FormState>();
  final _articoloController = TextEditingController();
  final _accessoriController = TextEditingController();
  final _difettoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _datiController = TextEditingController();
  bool _preventivoRichiesto = false;
  bool _orarioDisponibile = false;
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    getAllUtentiAttivi();
    getAllClienti();
    getAllTipologie();
  }

  Future<void> _selezionaData() async {
    final DateTime? dataSelezionata = await showDatePicker(
      locale: const Locale('it', 'IT'),
      context: context,
      initialDate: _dataOdierna,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (dataSelezionata != null && dataSelezionata != _dataOdierna) {
      setState(() {
        selectedDate = dataSelezionata;
      });
    }
  }

  void _handleSelectedUtentiChanged(List<UtenteModel?> selectedUtenti) {
    setState(() {
      _selectedUtenti = selectedUtenti;
    });
  }

  Future<void> takePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        pickedImages.add(pickedFile);
      });
    }
  }

  Widget _buildImagePreview() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pickedImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Image.file(File(pickedImages[index].path)),
                IconButton(
                  icon: Icon(Icons.remove_circle),
                  onPressed: () {
                    setState(() {
                      pickedImages.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        SfGlobalLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('it'),
      ],
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('INSERIMENTO INTERVENTO TECNICO', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.red,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: _selezionaData,
                            style: ElevatedButton.styleFrom(primary: Colors.red),
                            child: const Text('SELEZIONA DATA', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        if(selectedDate != null)
                          Text('DATA SELEZIONATA: ${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}'),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _orarioDisponibile,
                              onChanged: (value) {
                                setState(() {
                                  _orarioDisponibile = value ?? false;
                                });
                              },
                            ),
                            Text("è disponibile un orario per l'appuntamento".toUpperCase()),
                          ],
                        ),
                        if (_orarioDisponibile)
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    _selectTime(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.red, // Colore di sfondo rosso
                                    onPrimary: Colors.white, // Colore del testo bianco quando il pulsante è premuto
                                  ),
                                  child: Text('Seleziona Orario'.toUpperCase()),
                                ),
                                SizedBox(height: 12),
                                Text('Orario selezionato : ${(_selectedTime.hour)}.${(_selectedTime.minute)}'.toUpperCase())
                              ],
                            ),
                          ),
                        SizedBox(height: 15),
                        DropdownButton<TipologiaInterventoModel>(
                          value: _selectedTipologia,
                          hint:  Text('Seleziona tipologia di intervento'.toUpperCase()),
                          onChanged: (TipologiaInterventoModel? newValue) {
                            setState(() {
                              _selectedTipologia = newValue;
                            });
                          },
                          items: allTipologie
                              .map<DropdownMenuItem<TipologiaInterventoModel>>(
                                (TipologiaInterventoModel value) => DropdownMenuItem<TipologiaInterventoModel>(
                              value: value,
                              child: Text(value.descrizione!),
                            ),
                          ).toList(),
                        ),
                        const SizedBox(height: 20.0),
                        SizedBox(
                          width: 600,
                          child: TextFormField(
                            controller: _descrizioneController,
                            maxLines: null,
                            decoration:  InputDecoration(labelText: 'Descrizione'.toUpperCase()),
                            onChanged: (value) {
                              setState(() {
                                _descrizione = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 600,
                          child: TextFormField(
                            controller: _notaController,
                            maxLines: null,
                            decoration:  InputDecoration(labelText: 'Nota'.toUpperCase()),
                            onChanged: (value) {
                              setState(() {
                                _nota = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 200,
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
                                        (selectedCliente?.denominazione != null && selectedCliente!.denominazione!.length > 15)
                                            ? '${selectedCliente!.denominazione?.substring(0, 15)}...'  // Troncamento a 15 caratteri e aggiunta di "..."
                                            : (selectedCliente?.denominazione ?? 'Seleziona Cliente').toUpperCase(),  // Testo di fallback
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 200,
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
                                  primary: Colors.red,
                                  onPrimary: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                ),
                                child: Text('Crea nuovo cliente'.toUpperCase()),
                              ),
                            ),
                          ],
                        ),


                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 240,
                              child: GestureDetector(
                                onTap: () {
                                  _showDestinazioniDialog();
                                },
                                child: SizedBox(
                                  height: 50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        (selectedDestinazione?.denominazione != null && selectedDestinazione!.denominazione!.length > 15)
                                            ? '${selectedDestinazione!.denominazione!.substring(0, 15)}...'  // Troncamento a 15 caratteri e aggiunta di "..."
                                            : (selectedDestinazione?.denominazione ?? 'Seleziona Destinazione').toUpperCase(),  // Testo di fallback
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 20),

                            SizedBox(
                              //width: 210,
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
                                  primary: Colors.red,
                                  onPrimary: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                ),
                                child: Text('Crea nuova destinazione'.toUpperCase()),
                              ),
                            ),
                          ],
                        ),


                        const SizedBox(height: 20),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedUtenti = [];
                                  responsabile = null;
                                  _finalSelectedUtenti = [];
                                  _responsabileSelezionato = null;
                                });
                                _showSingleUtenteDialog();
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20), // Bordo squadrato
                                ),
                              ),
                              child: Text(
                                'Seleziona tecnico'.toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(height: 15),
                            Text("OPPURE"),
                            SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedUtenti = [];
                                  responsabile = null;
                                  _finalSelectedUtenti = [];
                                  _responsabileSelezionato = null;
                                });
                                _showUtentiDialog();
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Componi Squadra'.toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        // Aggiungi questo sotto il pulsante per la selezione degli utenti
                        const SizedBox(height: 20),
                        DisplayResponsabileUtentiWidget(
                          responsabile: responsabile,
                          selectedUtenti: _selectedUtenti,
                          onSelectedUtentiChanged: _handleSelectedUtentiChanged,
                        ),
                        if(_selectedTipologia?.descrizione == "Riparazione Merce")
                          Center(
                            child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(height: 15,),
                                            _buildTextFormField(
                                                _articoloController, "Articolo", "Inserisci una descrizione dell'articolo"),
                                            SizedBox(height: 15,),
                                            _buildTextFormField(
                                                _accessoriController, "Accessori", "Inserisci gli accessori se presenti"),
                                            SizedBox(height: 15,),
                                            _buildTextFormField(
                                                _difettoController, "Difetto", "Inserisci il difetto riscontrato"),
                                            SizedBox(height: 15,),
                                            _buildTextFormField(
                                                _passwordController, "Password", "Inserisci le password, se presenti"),
                                            SizedBox(height: 15,),
                                            _buildTextFormField(
                                                _datiController, "Dati", "Inserisci i dati da salvaguardare"),
                                            SizedBox(height: 15,),
                                            Center(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Checkbox(
                                                    value: _preventivoRichiesto,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _preventivoRichiesto = value!;
                                                      });
                                                    },
                                                  ),
                                                  Text("è richiesto un preventivo".toUpperCase()),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(height: 20),
                                            SizedBox(height: 15,),
                                            ElevatedButton(
                                              onPressed: takePicture,
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.red,
                                                onPrimary: Colors.white,
                                              ),
                                              child: Text('Scatta Foto'.toUpperCase(), style: TextStyle(fontSize: 18.0)), // Aumenta la dimensione del testo del pulsante
                                            ),
                                            SizedBox(height: 15,),
                                            _buildImagePreview(),
                                          ]
                                      ),
                                    ),
                                  )
                                ]
                            ),
                          ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: ElevatedButton(
                            onPressed: (selectedCliente != null && selectedDestinazione != null && _descrizioneController.text.isNotEmpty && _selectedTipologia != null)
                                ? () {
                              if (_selectedTipologia?.descrizione == "Riparazione Merce") {
                                savePics();
                              } else if ((responsabile == null)) {
                                _alertDialog();
                              } else {
                                saveRelations();
                              }
                            }
                                : null, // Disabilita il pulsante se le condizioni non sono soddisfatte
                            style: ElevatedButton.styleFrom(primary: Colors.red),
                            child:  Text('Salva Intervento'.toUpperCase(), style: TextStyle(color: Colors.white)),
                          ),
                        ),

                      ],
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

  void _alertDialog(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('ATTENZIONE'),
            content: Text('L\'intervento non è stato assegnato ad alcun tecnico, procedere con la creazione?'.toUpperCase()),
            actions: <Widget>[
              TextButton(
                  onPressed: (){
                    if(_selectedTipologia?.id == 6){
                      saveInterventoPlusMerce();
                    } else{
                      saveIntervento().then((value) => Navigator.pop(context));
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Si'),
              )
            ],
          );
        });
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

  Future<http.Response?> savePics() async{
    final data = await saveInterventoPlusMerce();
    try{
      if(data == null){
        throw Exception('Dati dell\'intervento non disponibili.');
      }
      final intervento = InterventoModel.fromJson(jsonDecode(data.body));
      try{
        for(var image in pickedImages){
          if(image.path != null && image.path.isNotEmpty){
            print('Percorso del file: ${image.path}');
            var request = http.MultipartRequest(
              'POST',
              Uri.parse('$ipaddress/api/immagine/${intervento.id}')
            );
            request.files.add(
              await http.MultipartFile.fromPath(
                'intervento',
                image.path,
                contentType: MediaType('image', 'jpeg'),
              ),
            );
            var response = await request.send();
            if(response.statusCode == 200){
              print('File inviato con successo');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Foto salvata'),
                ),
              );
            }
          }
        }
        pickedImages.clear();
        Navigator.pop(context);
      } catch(e){
        print('Errore durante l\'invio del file: $e');
      }
    } catch(e){
      print('Errore durante l\'invio del file: $e');
    }
    return null;
  }



  Future<http.Response?> saveInterventoPlusMerce() async{
    final data = await saveMerce();
    try{
      if (data == null) {
        // Gestisci il caso in cui il salvataggio dell'intervento non restituisca dati validi
        throw Exception('Dati dell\'intervento non disponibili.');
      }
      final merce = MerceInRiparazioneModel.fromJson(jsonDecode(data.body));
      bool assigned = responsabile != null ? true : false;
      try{
        final response = await http.post(
          Uri.parse('$ipaddress/api/intervento'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'numerazione_danea' : null,
            'data': _dataOdierna.toIso8601String(),
            'data_apertura_intervento' : DateTime.now().toIso8601String(),
            'orario_appuntamento' : null,
            'posizione_gps' : null,
            'orario_inizio': null,
            'orario_fine': null,
            'descrizione': _descrizioneController.text,
            'importo_intervento': null,
            'prezzo_ivato' : null,
            'assegnato': assigned,
            'accettato_da_tecnico' : false,
            'conclusione_parziale' : false,
            'concluso': false,
            'saldato': false,
            'saldato_da_tecnico' : false,
            'note': _notaController.text.isNotEmpty ? _notaController.text : null,
            'relazione_tecnico' : null,
            'firma_cliente': null,
            'utente': responsabile?.toMap(),
            'cliente': selectedCliente?.toMap(),
            'veicolo': null,
            'merce' : merce.toMap(),
            'tipologia': _selectedTipologia?.toMap(),
            'categoria_intervento_specifico': selectedCategoria?.toMap(),
            'tipologia_pagamento': null,
            'destinazione': selectedDestinazione?.toMap(),
          }),
        );
        return response;
      } catch(e){
        print('Errore durante il salvataggio dell\'intervento con merce: $e');
        return null;
      }
    }
    catch(e){
      print('ERRORE: $e');
      return null;
    }
  }

  Future<void> saveRelations() async {
    final data = await saveIntervento();
    if (_selectedUtenti == null || _selectedUtenti!.isEmpty) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Intervento registrato con successo!'),
        ),
      );
    } else {
      try {
        print("Prova1");
        if (data == null) {
          // Gestisci il caso in cui il salvataggio dell'intervento non restituisca dati validi
          throw Exception('Dati dell\'intervento non disponibili.');
        }
        final intervento = InterventoModel.fromJson(jsonDecode(data.body));
        print("PROVA2 ${data.body}");
        // Salvataggio delle relazioni con gli utenti
        for (var tecnico in _selectedUtenti!) {
          print("Prova1");
          try {
            print("PROVA TECNICO ${tecnico?.nome}");
            print("INTERVENTO: ${intervento.id}");
            final response = await http.post(
              Uri.parse('$ipaddress/api/relazioneUtentiInterventi'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'utente': tecnico?.toMap(),
                'intervento': intervento.toMap(),
              }),
            );
            // Controllo se la relazione è stata salvata correttamente
            if (response.statusCode != 200) {
              // Gestisci il caso in cui il salvataggio della relazione non sia andato a buon fine
              throw Exception('Errore durante il salvataggio della relazione.');
            }
          } catch (e) {
            // Gestione degli errori durante il salvataggio delle relazioni
            print('Errore durante il salvataggio della relazione: $e');
            _showErrorDialog();
          }
        }
        // Mostra un messaggio di successo all'utente se tutto è andato a buon fine
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Intervento registrato con successo!'),
            ),
          );
        }
      } catch (e) {
        // Gestione degli errori durante il salvataggio dell'intervento
        print('Errore durante il salvataggio dell\'intervento: $e');
        _showErrorDialog();
      }
    }
    // Effettua il salvataggio dell'intervento e gestisce le relazioni con gli utenti
  }

  Future<http.Response?> saveMerce() async{
    bool? magazzino = _selectedUtente != null ? true : false;
    late http.Response response;
    try{
      response = await http.post(
        Uri.parse('$ipaddress/api/merceInRiparazione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
            'data' : DateTime.now().toIso8601String(),
            'articolo' : _articoloController.text,
            'accessori': _accessoriController.text,
            'difetto_riscontrato': _difettoController.text,
            'password' : _passwordController.text,
            'dati' : _datiController.text,
            'presenza_magazzino' : magazzino,
            'preventivo' : _preventivoRichiesto,
            'utente' : responsabile?.toMap()
        }),
      );
      print("Merce salvata! : ${response.body}");
      return response;
    } catch(e){
      print('Errore durante il salvataggio dell\'intervento: $e');
    }
    return null;
  }

  Future<http.Response?> saveIntervento() async {
    late http.Response response;
    var orario_appuntamento = _orarioDisponibile ? _selectedTime : null;
    bool assigned = responsabile != null ? true : false;
    if(_orarioDisponibile == true){
      try {
        final orario = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, _selectedTime.hour, _selectedTime.minute);
        response = await http.post(
          Uri.parse('$ipaddress/api/intervento'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'numerazione_danea' : null,
            'data': selectedDate != null ? selectedDate?.toIso8601String() : null,
            'data_apertura_intervento' : DateTime.now().toIso8601String(),
            'orario_appuntamento' : orario.toIso8601String(),
            'posizione_gps' : null,
            'orario_inizio': null,
            'orario_fine': null,
            'descrizione': _descrizioneController.text,
            'importo_intervento': null,
            'prezzo_ivato' : null,
            'assegnato': assigned,
            'accettato_da_tecnico' : false,
            'conclusione_parziale' : false,
            'concluso': false,
            'saldato': false,
            'saldato_da_tecnico' : false,
            'note': null,
            'relazione_tecnico' : null,
            'firma_cliente': null,
            'utente': responsabile?.toMap(),
            'cliente': selectedCliente?.toMap(),
            'veicolo': null,
            'tipologia': _selectedTipologia?.toMap(),
            'categoria_intervento_specifico': selectedCategoria?.toMap(),
            'tipologia_pagamento': null,
            'destinazione': selectedDestinazione?.toMap(),
          }),
        );
        print("FINE PRIMO METODO: ${response.body}");
        return response;
      } catch (e) {
        print('Errore durante il salvataggio dell\'intervento: $e');
        _showErrorDialog();
      }
      return null;
    }
    else{
      try {
        response = await http.post(
          Uri.parse('$ipaddress/api/intervento'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'numerazione_danea' : null,
            'data': selectedDate != null ? selectedDate?.toIso8601String() : null,
            'data_apertura_intervento' : DateTime.now().toIso8601String(),
            'orario_appuntamento' : null,
            'posizione_gps' : null,
            'orario_inizio': null,
            'orario_fine': null,
            'descrizione': _descrizioneController.text,
            'importo_intervento': null,
            'prezzo_ivato': null,
            'assegnato': true,
            'accettato_da_tecnico' : false,
            'conclusione_parziale' : false,
            'concluso': false,
            'saldato': false,
            'saldato_da_tecnico' : false,
            'note': null,
            'relazione_tecnico' : null,
            'firma_cliente': null,
            'utente': responsabile?.toMap(),
            'cliente': selectedCliente?.toMap(),
            'veicolo': null,
            'tipologia': _selectedTipologia?.toMap(),
            'categoria_intervento_specifico': selectedCategoria?.toMap(),
            'tipologia_pagamento': null,
            'destinazione': selectedDestinazione?.toMap(),
            'gruppo' : null
          }),
        );
        print("FINE PRIMO METODO: ${response.body}");
        return response;
      } catch (e) {
        print('Errore durante il salvataggio dell\'intervento: $e');
        _showErrorDialog();
      }
      return null;
    }
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
      },
    );
  }

  void _showSingleUtenteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleziona un Utente', textAlign: TextAlign.center),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lista degli utenti recuperati tramite la chiamata API
                  Column(
                    children: allUtenti.map((utente) {
                      return ListTile(
                        title: Text('${utente.nome} ${utente.cognome}'),
                        onTap: () {
                          // Imposta l'utente selezionato come _selectedUtente
                          setState(() {
                            responsabile = utente;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  void _showUtentiDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Seleziona Utenti', textAlign: TextAlign.center),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: allUtenti.map((utente) {
                          return ListTile(
                            leading: Checkbox(
                              value: _finalSelectedUtenti?.contains(utente),
                              onChanged: (value) {
                                setState(() {
                                  if (value!) {
                                    _selectedUtenti?.add(utente);
                                    _finalSelectedUtenti?.add(utente);
                                  } else {
                                    _finalSelectedUtenti?.remove(utente);
                                    _selectedUtenti?.remove(utente);
                                  }
                                });
                              },
                            ),
                            title: Text('${utente.nome} ${utente.cognome}'),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      if (_finalSelectedUtenti!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scegli un responsabile tra gli utenti selezionati:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _finalSelectedUtenti?.length,
                                itemBuilder: (context, index) {
                                  final UtenteModel? utente = _finalSelectedUtenti?[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          responsabile = utente;
                                          _selectedUtenti?.remove(utente);
                                          _responsabileSelezionato = utente;
                                          print('Responsabile: ${responsabile?.cognome}');
                                        });
                                      },
                                      child: Chip(
                                        label: Text('${utente?.nome} ${utente?.cognome}'),
                                        backgroundColor: _responsabileSelezionato == utente ? Colors.yellow : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                )
              ),
            );
          },
        );
      },
    )
    .then((_) {
    setState(() {}); // Chiamiamo setState() dopo la chiusura del dialogo per forzare il ricaricamento della pagina
    });
  }



  void _showDestinazioniDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleziona Destinazione', textAlign: TextAlign.center),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                          leading: const Icon(Icons.home_work_outlined),
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

  Future<void> getAllUtentiAttivi() async {
    try {
      final response = await http.get(Uri.parse('$ipaddress/api/utente/attivo'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<UtenteModel> utenti = [];
        for (var item in jsonData) {
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          allUtenti = utenti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata Api: $e');
      _showErrorDialog();
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
      _showErrorDialog();
    }
  }

  Future<void> getAllTipologie() async {
    try {
      final response = await http.get(Uri.parse('$ipaddress/api/tipologiaIntervento'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<TipologiaInterventoModel> tipologie = [];
        for (var item in jsonData) {
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

  Future<void> getAllDestinazioniByCliente(String clientId) async {
    try {
      final response = await http.get(Uri.parse('$ipaddress/api/destinazione/cliente/$clientId'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          allDestinazioniByCliente = responseData.map((data) => DestinazioneModel.fromJson(data)).toList();
        });
      } else {
        throw Exception('Failed to load Destinazioni per cliente');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
    }
  }

  void _showErrorDialog() {
    if(mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Errore di connessione'),
            content: const Text(
              'Impossibile caricare i dati dall\'API. Controlla la tua connessione internet e riprova.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildTextFormField(
      TextEditingController controller, String label, String hintText) {
    return SizedBox(
      width: 300,
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
      ),
    );
  }
}

class DisplayResponsabileUtentiWidget extends StatefulWidget {
  final UtenteModel? responsabile;
  final List<UtenteModel?>? selectedUtenti;
  final Function(List<UtenteModel?>)? onSelectedUtentiChanged;

  const DisplayResponsabileUtentiWidget({
    Key? key,
    required this.responsabile,
    required this.selectedUtenti,
    this.onSelectedUtentiChanged,
  }) : super(key: key);

  @override
  _DisplayResponsabileUtentiWidgetState createState() =>
      _DisplayResponsabileUtentiWidgetState();
}

class _DisplayResponsabileUtentiWidgetState
    extends State<DisplayResponsabileUtentiWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Responsabile:'.toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          '${widget.responsabile?.nome ?? ''} ${widget.responsabile?.cognome ?? ''}',
        ),
        SizedBox(height: 30),
        Text(
          'Utenti selezionati:'.toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.selectedUtenti!.length,
            itemBuilder: (context, index) {
              final UtenteModel? utente = widget.selectedUtenti![index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Chip(
                  label: Text('${utente?.nome ?? ''} ${utente?.cognome ?? ''}'.toUpperCase()),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}



