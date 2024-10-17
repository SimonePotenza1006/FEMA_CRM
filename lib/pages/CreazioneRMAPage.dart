import 'dart:convert';
import 'dart:io';
import 'package:fema_crm/model/RestituzioneMerceModel.dart';
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
import '../model/FornitoreModel.dart';
import '../model/TipologiaInterventoModel.dart';
import '../model/UtenteModel.dart';
import 'package:image_picker/image_picker.dart';

import 'CreazioneClientePage.dart';
import 'NuovaDestinazionePage.dart';

class CreazioneRMAPage extends StatefulWidget {
  const CreazioneRMAPage({Key? key}) : super(key: key);

  @override
  _CreazioneRMAPageState createState() =>
      _CreazioneRMAPageState();
}

class _CreazioneRMAPageState
    extends State<CreazioneRMAPage> {
  List<XFile> pickedImages =  [];
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  CategoriaInterventoSpecificoModel? selectedCategoria;
  List<TipologiaInterventoModel> allTipologie = [];
  DateTime _dataOdierna = DateTime.now();
  DateTime? selectedDate = null;
  DateTime? selectedDateRicon = null;
  DateTime? selectedDateRitiro = null;
  String _descrizione = '';
  String _difetto = '';
  String _prodotto = '';
  ClienteModel? selectedCliente;
  FornitoreModel? selectedFornitore;
  UtenteModel? selectedUtenteRiconsegna;
  UtenteModel? selectedUtenteRitiro;
  DestinazioneModel? selectedDestinazione;
  List<ClienteModel> clientiList = [];
  List<ClienteModel> filteredClientiList = [];
  List<FornitoreModel> fornitoriList = [];
  List<FornitoreModel> filteredFornitoriList = [];
  List<DestinazioneModel> allDestinazioniByCliente = [];
  List<CategoriaInterventoSpecificoModel> allCategorieByTipologia = [];
  TextEditingController _descrizioneController = TextEditingController();
  TextEditingController _difettoController = TextEditingController();
  TextEditingController _prodottoController = TextEditingController();
  TipologiaInterventoModel? _selectedTipologia;
  List<UtenteModel> allUtenti = [];
  List<UtenteModel> allCapogruppi = [];
  UtenteModel? _selectedUtente;
  UtenteModel? responsabile;
  UtenteModel? utenteRitiro;
  UtenteModel? _responsabileSelezionato;
  List<UtenteModel?>? _selectedUtenti = [];
  bool _rimborso = false;
  final TextEditingController _rimborsoController = TextEditingController();
  bool _cambio = false;
  final TextEditingController _cambioController = TextEditingController();
  bool _concluso = false;
  final TextEditingController _conclusoController = TextEditingController();

  List<UtenteModel?>? _finalSelectedUtenti = [];
  bool isSelected = false;
  final _formKey = GlobalKey<FormState>();
  final _articoloController = TextEditingController();
  final _accessoriController = TextEditingController();
  //final _difettoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _datiController = TextEditingController();
  bool _preventivoRichiesto = false;
  bool _orarioDisponibile = false;
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    getAllUtentiAttivi();
    //getAllClienti();
    getAllFornitori();
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

  Future<void> _selezionaDataRicon() async {
    final DateTime? dataSelezionata = await showDatePicker(
      locale: const Locale('it', 'IT'),
      context: context,
      initialDate: _dataOdierna,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (dataSelezionata != null && dataSelezionata != _dataOdierna) {
      setState(() {
        selectedDateRicon = dataSelezionata;
      });
    }
  }

  Future<void> _selezionaDataRientro() async {
    final DateTime? dataSelezionata = await showDatePicker(
      locale: const Locale('it', 'IT'),
      context: context,
      initialDate: _dataOdierna,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (dataSelezionata != null && dataSelezionata != _dataOdierna) {
      setState(() {
        selectedDateRitiro = dataSelezionata;
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
          title: const Text('INSERIMENTO MERCE RMA', style: TextStyle(color: Colors.white)),
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
                getAllFornitori();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(17.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(17.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                          child: Container(width: 545, height: 55,
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                                border: Border.all(color: Colors.grey, width: 1)),
                            child: Row(
                              children: [
                                Container(
                                  height: 75,
                                  width: 8,
                                  color: Colors.grey,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child:
                                    RichText(
                                      text: TextSpan(
                                        children: [

                                          WidgetSpan(
                                            child: Icon(Icons.info_outline, size: 18, color: Colors.black54,),
                                          ),
                                          TextSpan(
                                            text: " Inserire nel campo PRODOTTO il nome e il seriale della merce RMA",
                                            style: TextStyle(color: Colors.black54, fontSize: 16),

                                          ),
                                        ],
                                      ),
                                    ),
                                    //Text('Almeno un documento tra carta d\'identità e passaporto è obbligatorio'),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        //const SizedBox(height: 20.0),
                        SizedBox(
                          width: 400,
                          child: TextFormField(
                            controller: _prodottoController,
                            maxLines: null,
                            decoration:  InputDecoration(labelText: 'Prodotto'.toUpperCase()),
                            onChanged: (value) {
                              setState(() {
                                _prodotto = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 30.0),

                        SizedBox(
                          width: 600,
                          child: TextFormField(
                            controller: _difettoController,
                            maxLines: null,
                            decoration:  InputDecoration(labelText: 'Difetto riscontrato'.toUpperCase()),
                            onChanged: (value) {
                              setState(() {
                                _difetto = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: _selezionaData,
                            style: ElevatedButton.styleFrom(primary: Colors.red),
                            child: const Text('DATA ACQUISTO', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        SizedBox(height: 5.0),
                        if(selectedDate != null)
                          Text('${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}', style: TextStyle(fontSize: 17),),
                        const SizedBox(height: 18.0),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              child: Container(padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                              width: 245,
                              child: GestureDetector(
                                onTap: () {
                                  _showFornitoriDialog();
                                },
                                child: SizedBox(
                                  height: 50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        (selectedFornitore?.denominazione != null && selectedFornitore!.denominazione!.length > 18)
                                            ? '${selectedFornitore!.denominazione?.substring(0, 18)}...'  // Troncamento a 15 caratteri e aggiunta di "..."
                                            : (selectedFornitore?.denominazione ?? 'Seleziona Fornitore').toUpperCase(),  // Testo di fallback
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ),
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
                                'utente riconsegna'.toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),

                            //Text("OPPURE"),
                            SizedBox(height: 4),
                            DisplayResponsabileUtentiWidget(
                              responsabile: responsabile,
                              selectedUtenti: _selectedUtenti,
                              onSelectedUtentiChanged: _handleSelectedUtentiChanged,
                            ),

                          ],
                        ),
                        //const SizedBox(height: 40),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: _selezionaDataRicon,
                            style: ElevatedButton.styleFrom(primary: Colors.red),
                            child: const Text('DATA RICONSEGNA', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        SizedBox(height: 5.0),
                        if(selectedDateRicon != null)

                        Text('${selectedDateRicon?.day}/${selectedDateRicon?.month}/${selectedDateRicon?.year}', style: TextStyle(fontSize: 17),),
                        const SizedBox(height: 18.0),
                        SizedBox(
                          width: 200,
                          child: CheckboxListTile(
                            title: Text('Rimborso'),
                            value: _rimborso,
                            onChanged: (value) {
                              setState(() {
                                _rimborso = value!;
                                if (_rimborso) {
                                  _rimborsoController.clear();
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 15,),
                        SizedBox(
                          width: 200,
                          child: CheckboxListTile(
                            title: Text('Cambio'),
                            value: _cambio,
                            onChanged: (value) {
                              setState(() {
                                _cambio = value!;
                                if (_cambio) {
                                  _cambioController.clear();
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 15,),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedUtenti = [];
                                  utenteRitiro = null;
                                  _finalSelectedUtenti = [];
                                  selectedUtenteRitiro = null;
                                });
                                _showRitiroDialog();
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20), // Bordo squadrato
                                ),
                              ),
                              child: Text(
                                'utente ritiro'.toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),

                            //Text("OPPURE"),
                            SizedBox(height: 4),
                            //utenteRitiro != null ? Text(utenteRitiro!.nome!) : Container(),
                            DisplayUtenteRitiroWidget(
                              utenteRitiro: utenteRitiro,
                              selectedUtenti: _selectedUtenti,
                              onSelectedUtentiChanged: _handleSelectedUtentiChanged,
                            ),

                          ],
                        ),
                        //const SizedBox(height: 40),
                        SizedBox(
                          width: 220,
                          child: ElevatedButton(
                            onPressed: _selezionaDataRientro,
                            style: ElevatedButton.styleFrom(primary: Colors.red),
                            child: const Text('DATA RIENTRO UFFICIO', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        SizedBox(height: 5.0),
                        if(selectedDateRitiro != null)

                          Text('${selectedDateRitiro?.day}/${selectedDateRitiro?.month}/${selectedDateRitiro?.year}', style: TextStyle(fontSize: 17),),
                        const SizedBox(height: 18.0),
                        SizedBox(
                          width: 200,
                          child: CheckboxListTile(
                            title: Text('Concluso'),
                            value: _concluso,
                            onChanged: (value) {
                              setState(() {
                                _concluso = value!;
                                if (_concluso) {
                                  _conclusoController.clear();
                                }
                              });
                            },
                          ),
                        ),
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
                        // Aggiungi questo sotto il pulsante per la selezione degli utenti
                        const SizedBox(height: 20),

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
                            onPressed: (_prodotto != '' && _difetto != '' && selectedDate != null && selectedFornitore != null)
                                ? () {
                              /*if (_selectedTipologia?.descrizione == "Riparazione Merce") {
                                savePics();
                              } else if ((responsabile == null)) {
                                _alertDialog();
                              } else {*/
                                savePics();
                                //saveRMA();//saveRelations();
                              //}
                            }
                                : null, // Disabilita il pulsante se le condizioni non sono soddisfatte
                            style: ElevatedButton.styleFrom(primary: Colors.red),
                            child:  Text('Salva Merce RMA'.toUpperCase(), style: TextStyle(color: Colors.white)),
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
                      saveRMA().then((value) => Navigator.pop(context));
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
    final data = await saveRMA();//saveInterventoPlusMerce();
    try{
      if(data == null){
        throw Exception('Dati della merce RMA non disponibili.');
      }
      final rma = RestituzioneMerceModel.fromJson(jsonDecode(data.body));
      try{
        for(var image in pickedImages){
          if(image.path != null && image.path.isNotEmpty){
            print('Percorso del file: ${image.path}');
            var request = http.MultipartRequest(
              'POST',
              Uri.parse('$ipaddress/api/immagine/restituzione/${rma.id}')
            );
            request.files.add(
              await http.MultipartFile.fromPath(
                'restituzione',
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
            'note': null,
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
    final data = await saveRMA();
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
        final intervento = RestituzioneMerceModel.fromJson(jsonDecode(data.body));
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
        print('Errore durante il salvataggio della merce RMA: $e');
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
            'prodotto' : _prodottoController.text,
            'accessori': _accessoriController.text,
            'difetto_riscontrato': _difettoController.text,
            'password' : _passwordController.text,
            'dati' : _datiController.text,
            'presenza_magazzino' : magazzino,
            'preventivo' : _preventivoRichiesto,
            'utente' : responsabile?.toMap()
        }),
      );
      print("Merce RMA salvata! : ${response.body}");
      return response;
    } catch(e){
      print('Errore durante il salvataggio della merce rma: $e');
    }
    return null;
  }

  Future<http.Response?> saveRMA() async {
    late http.Response response;
    var orario_appuntamento = _orarioDisponibile ? _selectedTime : null;
    final orario = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, _selectedTime.hour, _selectedTime.minute);
    bool assigned = responsabile != null ? true : false;
    //if(_orarioDisponibile == true){
      try {
        response = await http.post(
          Uri.parse('$ipaddress/api/restituzioneMerce'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'prodotto':_prodotto,
            'data_acquisto':selectedDate?.toIso8601String(),
            'difetto_riscontrato':_difetto,
            'fornitore':selectedFornitore?.toMap(),
            'data_riconsegna':selectedDateRicon?.toIso8601String(),
            'utenteRiconsegna': selectedUtenteRiconsegna?.toMap(),
            'rimborso':_rimborso,//_rimborsoController.text,
            'cambio':_cambio,//_cambioController.text,
            'data_rientro_ufficio':selectedDateRitiro?.toIso8601String(),
            'utenteRitiro':selectedUtenteRitiro?.toMap(),
            'concluso':_concluso//_conclusoController.text,

            /*'data': selectedDate?.toIso8601String(),
            'data_apertura_intervento' : DateTime.now().toIso8601String(),
            'orario_appuntamento' : orario.toIso8601String(),
            'posizione_gps' : null,
            'orario_inizio': null,
            'orario_fine': null,
            'descrizione': _descrizioneController.text,
            'importo_intervento': null,
            'prezzo_ivato' : null,
            'assegnato': assigned,
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
            'destinazione': selectedDestinazione?.toMap(),*/
          }),
        );
        print("FINE PRIMO METODO: ${response.body}");
        return response;
      } catch (e) {
        print('Errore durante il salvataggio dell\'intervento: $e');
        _showErrorDialog();
      }
      return null;
    /*}
    else{
      try {
        response = await http.post(
          Uri.parse('$ipaddress/api/intervento'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'data': selectedDate?.toIso8601String(),
            'data_apertura_intervento' : DateTime.now().toIso8601String(),
            'orario_appuntamento' : null,
            'posizione_gps' : null,
            'orario_inizio': null,
            'orario_fine': null,
            'descrizione': _descrizioneController.text,
            'importo_intervento': null,
            'prezzo_ivato': null,
            'assegnato': true,
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
    }*/
  }

  void _showFornitoriDialog() {
    TextEditingController searchController = TextEditingController(); // Aggiungi un controller

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) { // Usa StatefulBuilder per aggiornare lo stato del dialogo
            return AlertDialog(
              title: const Text('Seleziona Fornitore', textAlign: TextAlign.center),
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
                          filteredFornitoriList = fornitoriList
                              .where((forn) => forn.denominazione!
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Cerca Fornitore',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: filteredFornitoriList.map((forn) {
                            return ListTile(
                              leading: const Icon(Icons.contact_page_outlined),
                              title: Text(
                                  '${forn.denominazione}, ${forn.indirizzo}'),
                              onTap: () {
                                _aggiornaFornSelezionato(forn);
                                setState(() {
                                  selectedFornitore = forn;
                                  //getAllDestinazioniByCliente(forn.id!);
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

  void _aggiornaFornSelezionato(FornitoreModel cliente) {
    setState(() {
      selectedFornitore = cliente;
    });
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
                          Navigator.of(context).pop();
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

  void _showRitiroDialog() {
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
                            utenteRitiro = utente;
                          });
                          Navigator.of(context).pop();
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

  Future<void> getAllFornitori() async {
    try {
      final response = await http.get(Uri.parse('$ipaddress/api/fornitore'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<FornitoreModel> clienti = [];
        for (var item in jsonData) {
          clienti.add(FornitoreModel.fromJson(item));
        }
        setState(() {
          fornitoriList = clienti;
          filteredFornitoriList = clienti;
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
        /*Text(
          'Utente riconsegna:'.toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),*/
        Text(
          '${widget.responsabile?.nome ?? ''} ${widget.responsabile?.cognome ?? ''}', style: TextStyle(fontSize: 17),
        ),
        SizedBox(height: 30),

      ],
    );
  }
}

class DisplayUtenteRitiroWidget extends StatefulWidget {
  final UtenteModel? utenteRitiro;
  final List<UtenteModel?>? selectedUtenti;
  final Function(List<UtenteModel?>)? onSelectedUtentiChanged;

  const DisplayUtenteRitiroWidget({
    Key? key,
    required this.utenteRitiro,
    required this.selectedUtenti,
    this.onSelectedUtentiChanged,
  }) : super(key: key);

  @override
  _DisplayUtenteRitiroWidgetState createState() =>
      _DisplayUtenteRitiroWidgetState();
}

class _DisplayUtenteRitiroWidgetState
    extends State<DisplayUtenteRitiroWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          '${widget.utenteRitiro?.nome ?? ''} ${widget.utenteRitiro?.cognome ?? ''}', style: TextStyle(fontSize: 17),
        ),
        SizedBox(height: 30),

      ],
    );
  }
}


