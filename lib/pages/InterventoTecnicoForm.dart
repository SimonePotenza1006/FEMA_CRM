import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fema_crm/model/InterventoModel.dart';
import 'package:fema_crm/pages/VerificaMaterialeNewPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import '../model/CategoriaInterventoSpecificoModel.dart';
import '../model/ClienteModel.dart';
import '../model/DDTModel.dart';
import '../model/DestinazioneModel.dart';
import '../model/MerceInRiparazioneModel.dart';
import '../model/RelazioneDdtProdottiModel.dart';
import '../model/TipologiaInterventoModel.dart';
import '../model/UtenteModel.dart';
import '../model/VeicoloModel.dart';

class InterventoTecnicoForm extends StatefulWidget {
  final UtenteModel userData;

  const InterventoTecnicoForm({Key? key, required this.userData});

  @override
  _InterventoTecnicoFormState createState() => _InterventoTecnicoFormState();
}

class _InterventoTecnicoFormState extends State<InterventoTecnicoForm> {
  CategoriaInterventoSpecificoModel? selectedCategoria;
  List<TipologiaInterventoModel> allTipologie = [];
  VeicoloModel? _selectedVeicolo;
  DateTime _dataOdierna = DateTime.now();
  TimeOfDay _orarioInizio = TimeOfDay.now();
  TimeOfDay _orarioFine = TimeOfDay.now();
  VeicoloModel? selectedVeicolo;
  String? _relazione = null;
  String? _descrizione = null;
  String? _nota = null;
  TextEditingController _notaController = TextEditingController();
  TextEditingController _relazioneController = TextEditingController();
  bool _interventoConcluso = false;
  bool _interventoAutoassegnato = false;
  ClienteModel? selectedCliente;
  DestinazioneModel? selectedDestinazione;
  List<VeicoloModel> veicoliList = [];
  List<ClienteModel> clientiList = [];
  List<ClienteModel> filteredClientiList = [];
  List<DestinazioneModel> allDestinazioniByCliente = [];
  List<CategoriaInterventoSpecificoModel> allCategorieByTipologia = [];
  TextEditingController _descrizioneController = TextEditingController();
  TipologiaInterventoModel? _selectedTipologia;
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  GlobalKey<SfSignaturePadState> _signaturePadKey =
  GlobalKey<SfSignaturePadState>();
  Uint8List? signatureBytes;
  final _formKey = GlobalKey<FormState>();
  final _articoloController = TextEditingController();
  final _accessoriController = TextEditingController();
  final _difettoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _datiController = TextEditingController();
  bool _preventivoRichiesto = false;
  List<XFile> pickedImages =  [];

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
      final response =
          await http.get(Uri.parse('${ipaddress}/api/tipologiaIntervento'));
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
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

  Future<void> getCategoriaByTipologia() async {
    try {
      if (_selectedTipologia != null) {
        final response = await http.get(Uri.parse(
            '${ipaddress}/api/categorieIntervento/tipologia/${_selectedTipologia!.id}'));
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
          throw Exception(
              'Failed to load data from API: ${response.statusCode}');
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NUOVO INTERVENTO TECNICO', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(  // Aggiunto SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('DATA: ${_dataOdierna.day}/${_dataOdierna.month}/${_dataOdierna.year}'),
              ElevatedButton(
                onPressed: _selezionaData,
                style: ElevatedButton.styleFrom(primary: Colors.red),
                child: const Text('SELEZIONA DATA', style: TextStyle(color: Colors.white)),
              ),
              TextFormField(
                controller: _descrizioneController,
                decoration: const InputDecoration(labelText: 'DESCRIZIONE'),
                onChanged: (value) {
                  setState(() {
                    _descrizione = value;
                  });
                },
              ),
              SizedBox(height: 15),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  const Text('AUTO-ASSEGNAZIONE', style: TextStyle(color: Colors.black)),
                  Checkbox(
                    value: _interventoAutoassegnato,
                    onChanged: (bool? value) {
                      setState(() {
                        _interventoAutoassegnato = value!;
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('INTERVENTO CONCLUSO:', style: TextStyle(color: Colors.black)),
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
                hint: Text('TIPOLOGIA DI INTERVENTO'),
                onChanged: (TipologiaInterventoModel? newValue) {
                  setState(() {
                    _selectedTipologia = newValue;
                    getCategoriaByTipologia();
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
              if (_interventoConcluso)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButton<VeicoloModel>(
                      value: _selectedVeicolo,
                      hint: Text('SELEZIONA VEICOLO'),
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
                      style: ElevatedButton.styleFrom(primary: Colors.red),
                      child: Text('ORARIO INIZIO: ${_orarioInizio.format(context)}', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _selezionaOrarioFine,
                      style: ElevatedButton.styleFrom(primary: Colors.red),
                      child: Text('ORARIO FINE: ${_orarioFine.format(context)}', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _relazioneController,
                      maxLines: null, // aggiungi questo parametro
                      decoration: const InputDecoration(labelText: 'RAPPORTINO'),
                      onChanged: (value) {
                        setState(() {
                          _relazione = value;
                        });
                      },
                    ),
                    SizedBox(height: 30),
                    Text(
                      'INSERISCI FIRMA CLIENTE:',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
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
                                  child: Text('CHIUDI'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final signatureImage = await _signaturePadKey.currentState!.toImage(pixelRatio: 3.0);
                                    final data = await signatureImage.toByteData(format: ui.ImageByteFormat.png);
                                    setState(() {
                                      signatureBytes = data!.buffer.asUint8List();
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('SALVA'),
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
                            'TOCCA PER AGGIUNGERE LA FIRMA',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _notaController,
                decoration: const InputDecoration(labelText: 'NOTA'),
                onChanged: (value) {
                  setState(() {
                    _nota = value;
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
                        selectedCliente?.denominazione ?? 'SELEZIONA CLIENTE',
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
                        selectedDestinazione?.denominazione ?? 'SELEZIONA DESTINAZIONE',
                        style: TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
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
              const SizedBox(height: 20.0),
              Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ElevatedButton(
                  onPressed: //(selectedCliente != null && selectedDestinazione != null && _descrizioneController.text.isNotEmpty && _selectedTipologia != null)
                  ((selectedCliente != null && selectedDestinazione != null && _descrizioneController.text.isNotEmpty &&
                      _selectedTipologia != null && _selectedTipologia?.id != '6') ||
                      (_selectedTipologia?.id == '6' && _articoloController.text.isNotEmpty && _accessoriController.text.isNotEmpty &&
                          _difettoController.text.isNotEmpty && _passwordController.text.isNotEmpty && _datiController.text.isNotEmpty &&
                          pickedImages.length>0))
                      ? () {

                    if(_selectedTipologia?.id == '6'){
                      savePics().then((value) => Navigator.pop(context));
                      //Navigator.pop(context);
                      //saveInterventoPlusMerce();
                    } else{
                      if(_interventoConcluso == true){
                        saveAndRedirect().then((value) => Navigator.pop(context));
                      } else {
                        saveIntervento().then((value) => Navigator.pop(context));
                      }
                      //saveIntervento().then((value) => Navigator.pop(context));
                      //Navigator.pop(context);
                    }

                          /*if ((_interventoAutoassegnato == false)) { //no tecnico
                             _alertDialog();
                          } else {
                              saveRelations();*/
                    /*if(_interventoConcluso == true){
                      saveAndRedirect();
                    } else {
                      saveIntervento();
                    }*/
                          
                  } : null,
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  child: const Text('SALVA INTERVENTO', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<http.Response?> saveMerce() async{
    bool? magazzino = _interventoAutoassegnato == true ? true : false;
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
          'presenza_magazzino' : !_interventoAutoassegnato,
          'preventivo' : _preventivoRichiesto,
          'utente' : _interventoAutoassegnato == true ? widget.userData.toMap() : null,
        }),
      );
      print("Merce salvata! : ${response.body}");
      return response;
    } catch(e){
      print('Errore durante il salvataggio dell\'intervento: $e');
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
      //bool assigned = _interventoAutoassegnato == null ? true : false;
      try{
        if(_interventoConcluso == true){
          saveAndRedirect().then((value) => Navigator.pop(context));
          //final response = await
          try {
            // Inizializziamo le variabili per i valori da inviare
            DateTime? orarioInizioSalvato;
            DateTime? orarioFineSalvato;
            bool conclusioneParzialeValue = false;
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
              conclusioneParzialeValue = true;
              assegnatoValue = true;
              conclusoValue = true;
              veicolo = selectedVeicolo?.toMap();
              utente = widget.userData.toMap();
            }

            // Effettuiamo la richiesta HTTP con i dati appropriati in base allo stato della checkbox
            final response = await http.post(
              Uri.parse('${ipaddress}/api/intervento'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'numerazione_danea' : null,
                'data_apertura_intervento' : DateTime.now().toIso8601String(),
                'data': _dataOdierna.toIso8601String(),
                'orario_appuntamento' : null,
                'posizione_gps' : null,
                'orario_inizio': orarioInizioSalvato?.toIso8601String(),
                'orario_fine': orarioFineSalvato?.toIso8601String(),
                'descrizione': _descrizione,
                'importo_intervento': null,
                'prezzo_ivato' : null,
                'iva' : null,
                'assegnato': assegnatoValue,
                'accettato_da_tecnico' : false,
                'conclusione_parziale': conclusioneParzialeValue,
                'concluso': conclusoValue,
                'saldato': false,
                'saldato_da_tecnico' : false,
                'note': _nota,
                'relazione_tecnico': _relazione,
                'firma_cliente': signatureBytes,
                'utente': utente,
                'cliente': selectedCliente?.toMap(),
                'veicolo': veicolo,
                'merce' : null,
                'tipologia': _selectedTipologia?.toMap(),
                'categoria_intervento_specifico': null,
                'tipologia_pagamento': null,
                'destinazione': selectedDestinazione?.toMap(),
                'gruppo' : null,
              }),
            );

            // Restituiamo la risposta HTTP
            //return response;
            final intervento = InterventoModel.fromJson(jsonDecode(response.body));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => VerificaMaterialeNewPage(intervento: intervento, utente: widget.userData)),
            );
          } catch (e) {
            print('Errore durante il salvataggio dell\'intervento: $e');
            _showErrorDialog();
            return null; // Restituiamo null in caso di errore
          };
          /*if (response != null) {
            final intervento = InterventoModel.fromJson(jsonDecode(response.body));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => VerificaMaterialeNewPage(intervento: intervento, utente: widget.userData)),
            );
          } else {
            print('Errore durante il recupero del ddt');
          }*/
        } else {
          //saveIntervento().then((value) => Navigator.pop(context));
          try {
            final response = await http.post(Uri.parse('$ipaddress/api/intervento'),
                headers: {'Content-Type' : 'application/json'},
                body: jsonEncode({
                  'numerazione_danea' : null,
                  'data_apertura_intervento' : DateTime.now().toIso8601String(),
                  'data' : _dataOdierna.toIso8601String(),
                  'orario_appuntamento' : null,
                  'posizione_gps' : null,
                  'orario_inizio': null,
                  'orario_fine': null,
                  'descrizione' : _descrizioneController.text,
                  'importo_intervento': null,
                  'prezzo_ivato' : null,
                  'iva' : null,
                  'acconto' : null,
                  'assegnato': _interventoAutoassegnato != false ? true : false,
                  'accettato_da_tecnico' : false,
                  'conclusione_parziale' : false,
                  'concluso' : false,
                  'saldato' : false,
                  'saldato_da_tecnico' : false,
                  'note' : _notaController.text,
                  'relazione_tecnico' : null,
                  'firma_cliente' : null,
                  'utente' : _interventoAutoassegnato != false ? widget.userData.toMap() : null,
                  'cliente' : selectedCliente?.toMap(),
                  'veicolo' : null,
                  'merce' : merce.toMap(),//null,
                  'tipologia' : _selectedTipologia?.toMap(),
                  'categoria' : null,
                  'tipologia_pagamento' : null,
                  'destinazione' : selectedDestinazione?.toMap(),
                  'gruppo' : null,
                })
            );
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Intervento registrato con successo!'),
              ),
            );

          } catch(e){
            print('Errore durante il salvataggio dell\'intervento: $e');
            _showErrorDialog();
          }
        }
        /*final response = await http.post(
          Uri.parse('$ipaddress/api/intervento'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'numerazione_danea' : null,
            'data': _dataOdierna.toIso8601String(),//selectedDate != null ? selectedDate?.toIso8601String() : null,//_dataOdierna.toIso8601String(),
            'data_apertura_intervento' : DateTime.now().toIso8601String(),
            'orario_appuntamento' : null,
            'posizione_gps' : null,
            'orario_inizio': null,
            'orario_fine': null,
            'descrizione': _descrizioneController.text,
            'importo_intervento': null,
            'prezzo_ivato' : null,
            'iva' : null,
            'assegnato': _interventoAutoassegnato,//assigned,
            'accettato_da_tecnico' : false,
            'conclusione_parziale' : false,
            'concluso': false,
            'saldato': false,
            'saldato_da_tecnico' : false,
            'note': _notaController.text.isNotEmpty ? _notaController.text : null,
            'relazione_tecnico' : null,
            'firma_cliente': null,
            'utente': _interventoAutoassegnato == true ? widget.userData.toMap() : null,
            'cliente': selectedCliente?.toMap(),
            'veicolo': null,
            'merce' : merce.toMap(),
            'tipologia': _selectedTipologia?.toMap(),
            'categoria_intervento_specifico': selectedCategoria?.toMap(),
            'tipologia_pagamento': null,
            'destinazione': selectedDestinazione?.toMap(),
          }),
        );
        return response;*/
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
        print('fine salv');
        Navigator.pop(context);
      } catch(e){
        print('Errore durante l\'invio del file: $e');
      }
    } catch(e){
      print('Errore durante l\'invio del file: $e');
    }
    return null;
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

  Future<void> getAllDestinazioniByCliente(String clientId) async {
    try {
      final response = await http
          .get(Uri.parse('${ipaddress}/api/destinazione/cliente/$clientId'));
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

  // void _showClientiDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(
  //           'SELEZIONA CLIENTE',
  //           textAlign: TextAlign.center,
  //         ),
  //         contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  //         content: SizedBox(
  //           width: MediaQuery.of(context).size.width * 0.8,
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               TextField(
  //                 onChanged: (value) {
  //                   setState(() {
  //                     filteredClientiList = clientiList
  //                         .where((cliente) => cliente.denominazione!
  //                             .toLowerCase()
  //                             .contains(value.toLowerCase()))
  //                         .toList();
  //                   });
  //                 },
  //                 decoration: InputDecoration(
  //                   labelText: 'CERCA CLIENTE',
  //                   prefixIcon: Icon(Icons.search),
  //                 ),
  //               ),
  //               SizedBox(height: 16),
  //               Expanded(
  //                 child: SingleChildScrollView(
  //                   child: Column(
  //                     children: filteredClientiList.map((cliente) {
  //                       return ListTile(
  //                         leading: Icon(Icons.contact_page_outlined),
  //                         title: Text(cliente.denominazione!),
  //                         onTap: () {
  //                           setState(() {
  //                             selectedCliente = cliente;
  //                             getAllDestinazioniByCliente(cliente.id!);
  //                           });
  //                           Navigator.of(context).pop();
  //                         },
  //                       );
  //                     }).toList(),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  void _showDestinazioniDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'SELEZIONA DESTINAZIONE',
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
    return DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  }

  Future<http.Response?> saveInterventoConcluso() async {
    try {
      // Inizializziamo le variabili per i valori da inviare
      DateTime? orarioInizioSalvato;
      DateTime? orarioFineSalvato;
      bool conclusioneParzialeValue = false;
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
        conclusioneParzialeValue = true;
        assegnatoValue = true;
        conclusoValue = true;
        veicolo = selectedVeicolo?.toMap();
        utente = widget.userData.toMap();
      }

      // Effettuiamo la richiesta HTTP con i dati appropriati in base allo stato della checkbox
      final response = await http.post(
        Uri.parse('${ipaddress}/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'numerazione_danea' : null,
          'data_apertura_intervento' : DateTime.now().toIso8601String(),
          'data': _dataOdierna.toIso8601String(),
          'orario_appuntamento' : null,
          'posizione_gps' : null,
          'orario_inizio': orarioInizioSalvato?.toIso8601String(),
          'orario_fine': orarioFineSalvato?.toIso8601String(),
          'descrizione': _descrizione,
          'importo_intervento': null,
          'prezzo_ivato' : null,
          'iva' : null,
          'assegnato': assegnatoValue,
          'accettato_da_tecnico' : false,
          'conclusione_parziale': conclusioneParzialeValue,
          'concluso': conclusoValue,
          'saldato': false,
          'saldato_da_tecnico' : false,
          'note': _nota,
          'relazione_tecnico': _relazione,
          'firma_cliente': signatureBytes,
          'utente': utente,
          'cliente': selectedCliente?.toMap(),
          'veicolo': veicolo,
          'merce' : null,
          'tipologia': _selectedTipologia?.toMap(),
          'categoria_intervento_specifico': null,
          'tipologia_pagamento': null,
          'destinazione': selectedDestinazione?.toMap(),
          'gruppo' : null,
        }),
      );

      // Restituiamo la risposta HTTP
      return response;
    } catch (e) {
      print('Errore durante il salvataggio dell\'intervento: $e');
      _showErrorDialog();
      return null; // Restituiamo null in caso di errore
    }
  }


  Future<void> saveAndRedirect() async {
    final response = await saveInterventoConcluso();
    if (response != null) {
        final intervento = InterventoModel.fromJson(jsonDecode(response.body));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VerificaMaterialeNewPage(intervento: intervento, utente: widget.userData)),
        );
      } else {
        print('Errore durante il recupero del ddt');
      }
  }

  Future<void> saveIntervento() async {
    try {
      final response = await http.post(Uri.parse('$ipaddress/api/intervento'),
        headers: {'Content-Type' : 'application/json'},
        body: jsonEncode({
          'numerazione_danea' : null,
          'data_apertura_intervento' : DateTime.now().toIso8601String(),
          'data' : _dataOdierna.toIso8601String(),
          'orario_appuntamento' : null,
          'posizione_gps' : null,
          'orario_inizio': null,
          'orario_fine': null,
          'descrizione' : _descrizioneController.text,
          'importo_intervento': null,
          'prezzo_ivato' : null,
          'iva' : null,
          'acconto' : null,
          'assegnato': _interventoAutoassegnato != false ? true : false,
          'accettato_da_tecnico' : false,
          'conclusione_parziale' : false,
          'concluso' : false,
          'saldato' : false,
          'saldato_da_tecnico' : false,
          'note' : _notaController.text,
          'relazione_tecnico' : null,
          'firma_cliente' : null,
          'utente' : _interventoAutoassegnato != false ? widget.userData.toMap() : null,
          'cliente' : selectedCliente?.toMap(),
          'veicolo' : null,
          'merce' : null,
          'tipologia' : _selectedTipologia?.toMap(),
          'categoria' : null,
          'tipologia_pagamento' : null,
          'destinazione' : selectedDestinazione?.toMap(),
          'gruppo' : null,
        })
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Intervento registrato con successo!'),
        ),
      );
    } catch(e){
      print('Errore durante il salvataggio dell\'intervento: $e');
      _showErrorDialog();
    }
  }

  Future<void> getAllClienti() async {
    try {
      var apiUrl = Uri.parse('${ipaddress}/api/cliente');
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
      http.Response response =
          await http.get(Uri.parse('${ipaddress}/api/veicolo'));
      var responseData = json.decode(response.body.toString());
      if (response.statusCode == 200) {
        List<VeicoloModel> allVeicoli = [];
        for (var item in responseData) {
          VeicoloModel veicolo = VeicoloModel.fromJson(item);
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
