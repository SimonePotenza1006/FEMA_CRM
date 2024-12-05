import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';

import '../model/ClienteModel.dart';
import '../model/DestinazioneModel.dart';
import '../model/InterventoModel.dart';
import '../model/TicketModel.dart';
import 'dart:convert';
import 'package:fema_crm/pages/HomeFormAmministrazioneNewPage.dart';
import 'package:fema_crm/pages/TableCommissioniPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fema_crm/model/CommissioneModel.dart';

import '../model/TipoTaskModel.dart';
import '../model/TipologiaInterventoModel.dart';
import '../model/UtenteModel.dart';
import 'CreazioneClientePage.dart';
import 'GalleriaFotoInterventoPage.dart';
import 'NuovaDestinazionePage.dart';

class DettaglioTicketPage extends StatefulWidget{
  final TicketModel ticket;
  final UtenteModel utente;

  DettaglioTicketPage({Key? key, required this.ticket, required this.utente}) : super(key : key);

  @override
  _DettaglioTicketPageState createState() => _DettaglioTicketPageState();
}

class _DettaglioTicketPageState extends State<DettaglioTicketPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  Future<List<Uint8List>>? _futureImages;
  bool conversioneIntervento = false;
  bool conversioneTask = false;
  List<ClienteModel> clientiList = [];
  List<ClienteModel> filteredClientiList = [];
  ClienteModel? selectedCliente;
  List<DestinazioneModel> allDestinazioniByCliente = [];
  DestinazioneModel? selectedDestinazione;
  TextEditingController _titoloController = TextEditingController();
  TextEditingController _descrizioneController = TextEditingController();
  TextEditingController _notaController = TextEditingController();
  TextEditingController _titoloTaskController = TextEditingController();
  TextEditingController _descrizioneTaskController = TextEditingController();
  Priorita? _selectedPriorita;
  List<TipologiaInterventoModel> tipologieList = [];
  TipologiaInterventoModel? selectedTipologia;
  List<TipoTaskModel> tipiTask = [];
  TipoTaskModel? selectedTipoTask;
  List<UtenteModel> allUtenti = [];
  UtenteModel? selectedUtente;

  Future<void> getAllTipiTask() async{
    try{
      var apiUrl = Uri.parse('$ipaddressProva/api/tipoTask');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<TipoTaskModel> tipologie = [];
        for(var item in jsonData){
          tipologie.add(TipoTaskModel.fromJson(item));
        }
        setState(() {
          tipiTask = tipologie;
        });
      } else {
        throw Exception('Failed to load tipi task data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Qualcosa non va tipologie Task: $e');
    }
  }

  Future<void> getAllUtenti() async{
    try{
      var apiUrl = Uri.parse('$ipaddressProva/api/utente/attivo');
      var response =await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<UtenteModel> utenti = [];
        for(var item in jsonData){
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          allUtenti = utenti;
        });
      } else {
        throw Exception('Failed to load utenti data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Qualcosa non va getAllUtenti: $e');
    }
  }

  Future<void> getAllTipologie() async{
    try{
      var apiUrl = Uri.parse('$ipaddressProva/api/tipologiaIntervento');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<TipologiaInterventoModel> tipologie = [];
        for(var item in jsonData){
          tipologie.add(TipologiaInterventoModel.fromJson(item));
        }
        setState(() {
          tipologieList = tipologie;
        });
      } else {
        throw Exception('Failed to load tipologie data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Qualcosa non va tipologie : $e');
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
    }
  }

  @override
  void initState(){
    super.initState();
    getAllClienti();
    getAllTipologie();
    getAllUtenti();
    getAllTipiTask();
    _futureImages = fetchImages();
    _descrizioneController.text = (widget.ticket.descrizione != null ? widget.ticket.descrizione!.toString() : '');
    _notaController.text = (widget.ticket.note != null ? widget.ticket.note! : '');
    _descrizioneTaskController.text = (widget.ticket.descrizione != null ? widget.ticket.descrizione! : '');
  }

  Future<List<Uint8List>> fetchImages() async {
    final url = '$ipaddressProva/api/immagine/ticket/${int.parse(widget.ticket.id.toString())}/images';
    http.Response? response;
    try {
      response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final images = jsonData.map<Uint8List>((imageData) {
          final base64String = imageData['imageData'];
          final bytes = base64Decode(base64String);
          return bytes.buffer.asUint8List();
        }).toList();
        return images; // no need to wrap with Future
      } else {
        throw Exception('Errore durante la chiamata al server: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata al server: $e');
      if (response!= null) {

      }
      throw e; // rethrow the exception
    }
  }

  Future<void> savePicsTask(List<Uint8List> images, int taskId) async{
    try{
      showDialog(
        context: context,
        barrierDismissible: false, // Impedisce la chiusura del dialog premendo fuori
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Caricamento in corso..."),
              ],
            ),
          );
        },
      );
      for(var imageBytes in images){
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$ipaddressProva/api/immagine/task/$taskId'),
        );
        request.files.add(http.MultipartFile.fromBytes(
          'task', // Nome del campo nel form
          imageBytes,
          filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
        var response = await request.send();
        if (response.statusCode == 200) {
          print('File inviato con successo');
        } else {
          print('Errore durante l\'invio del file: ${response.statusCode}');
        }
      }
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Successo"),
            content: Text("Caricamento completato!"),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pop(context); // Chiudi l'alert di successo
                  Navigator.pop(context); // Torna alla pagina precedente
                },
              ),
            ],
          );
        },
      );
    } catch(e){
      Navigator.pop(context); // Chiudi il dialog di caricamento in caso di errore
      print('Errore durante l\'invio del file: $e');
    }
  }

  Future<void> savePics(List<Uint8List> images, int interventoId) async {
    try {
      // Mostra il caricamento
      showDialog(
        context: context,
        barrierDismissible: false, // Impedisce la chiusura del dialog premendo fuori
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Caricamento in corso..."),
              ],
            ),
          );
        },
      );
      for (var imageBytes in images) {
        // Converte Uint8List in MultipartFile
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$ipaddressProva/api/immagine/$interventoId'),
        );
        request.files.add(http.MultipartFile.fromBytes(
          'intervento', // Nome del campo nel form
          imageBytes,
          filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
        var response = await request.send();
        if (response.statusCode == 200) {
          print('File inviato con successo');
        } else {
          print('Errore durante l\'invio del file: ${response.statusCode}');
        }
      }
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Successo"),
            content: Text("Caricamento completato!"),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pop(context); // Chiudi l'alert di successo
                  Navigator.pop(context); // Torna alla pagina precedente
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      Navigator.pop(context); // Chiudi il dialog di caricamento in caso di errore
      print('Errore durante l\'invio del file: $e');
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dettaglio ticket',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: (){
              getAllClienti();
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildInfoRow(title: "Id", value: widget.ticket.id!),
                //buildInfoRow(title: "Tipologia", value: widget.ticket.tipologia?.descrizione ?? "N/A"),
                buildInfoRow(title: "Utente", value: widget.ticket.utente?.nomeCompleto() ?? "N/A"),
                buildInfoRow(title: "Data creazione", value: DateFormat('dd/MM/yyyy HH:mm').format(widget.ticket.data_creazione!)),
                buildInfoRow(title: "Descrizione", value: widget.ticket.descrizione ?? "N/A", showCopyIcon : true, context: context),
                buildInfoRow(title: "Note", value: widget.ticket.note ?? "N/A", showCopyIcon : true, context: context),
                SizedBox(height: 10),
                Container(
                  width: 500,
                  height: 200,
                  child: FutureBuilder<List<Uint8List>>(
                    future: _futureImages,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: snapshot.data!.asMap().entries.map((entry) {
                            int index = entry.key;
                            Uint8List imageData = entry.value;
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PhotoViewPage(
                                      images: snapshot.data!,
                                      initialIndex: index, // Passa l'indice dell'immagine cliccata
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 150, // aumenta la larghezza del container
                                height: 170, // aumenta l'altezza del container
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1), // aggiungi bordo al container
                                ),
                                child: Image.memory(
                                  imageData,
                                  fit: BoxFit.cover, // aggiungi fit per coprire l'intero spazio
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Nessuna foto presente nel database!');
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                SizedBox(width: 30),
                SizedBox(
                  width: 200, // Larghezza desiderata
                  height: 50, // Altezza desiderata
                  child: FloatingActionButton(
                    heroTag: "iniziaConversione1",
                    onPressed: () {
                      setState(() {
                        conversioneIntervento = !conversioneIntervento;
                        if(conversioneTask == true){
                          conversioneTask = false;
                        }
                      });
                    },
                    backgroundColor: Colors.red, // Colore di sfondo rosso
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Bordi leggermente arrotondati
                    ),
                    child: Text(
                      'CREA INTERVENTO',
                      style: TextStyle(
                        color: Colors.white, // Colore della scritta bianco
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: 200, // Larghezza desiderata
                  height: 50, // Altezza desiderata
                  child: FloatingActionButton(
                    heroTag: "iniziaConversione",
                    onPressed: () {
                      setState(() {
                        conversioneTask = !conversioneTask;
                        if(conversioneIntervento == true){
                          conversioneIntervento = false;
                        }
                      });
                    },
                    backgroundColor: Colors.red, // Colore di sfondo rosso
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Bordi leggermente arrotondati
                    ),
                    child: Text(
                      'CREA TASK',
                      style: TextStyle(
                        color: Colors.white, // Colore della scritta bianco
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: 200, // Larghezza desiderata
                  height: 50, // Altezza desiderata
                  child: FloatingActionButton(
                    heroTag: "Elimina",
                    onPressed: () {
                      showDeleteConfirmationDialog(context);
                    },
                    backgroundColor: Colors.red, // Colore di sfondo rosso
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Bordi leggermente arrotondati
                    ),
                    child: Text(
                      'ELIMINA TICKET',
                      style: TextStyle(
                        color: Colors.white, // Colore della scritta bianco
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(width: 150),
            if(conversioneIntervento)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Compilazione intervento', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  SizedBox(
                    width: 600,
                    child: TextFormField(
                      controller: _titoloController,
                      maxLines: null,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Titolo'.toUpperCase(),
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none, // Rimuove il bordo standard
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.redAccent,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1.0,
                          ),
                        ),
                        hintText: "Inserisci il titolo",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 600,
                    child: TextFormField(
                      controller: _descrizioneController,
                      maxLines: 5,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Descrizione'.toUpperCase(),
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.redAccent,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1.0,
                          ),
                        ),
                        hintText: "Inserisci la descrizione",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 600,
                    child: TextFormField(
                      controller: _notaController,
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Note'.toUpperCase(),
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.redAccent,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1.0,
                          ),
                        ),
                        hintText: "Inserisci le note",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 400,
                    child: DropdownButtonFormField<TipologiaInterventoModel>(
                      value: selectedTipologia,
                      onChanged: (TipologiaInterventoModel? newValue) {
                        setState(() {
                          selectedTipologia = newValue;
                        });
                      },
                      items: tipologieList.map<DropdownMenuItem<TipologiaInterventoModel>>((TipologiaInterventoModel tipologia) {
                        return DropdownMenuItem<TipologiaInterventoModel>(
                          value: tipologia,
                          child: Text(
                            tipologia.descrizione!, // Supponendo che TipologiaInterventoModel abbia una proprietà `label`
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'TIPOLOGIA INTERVENTO',
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.redAccent,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Selezionare una tipologia di intervento';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 400,
                    child: DropdownButtonFormField<Priorita>(
                      value: _selectedPriorita,
                      onChanged: (Priorita? newValue) {
                        setState(() {
                          _selectedPriorita = newValue;
                        });
                      },
                      items: [Priorita.BASSA, Priorita.MEDIA, Priorita.ALTA, Priorita.URGENTE]
                          .map<DropdownMenuItem<Priorita>>((Priorita value) {
                        String label = "";
                        if (value == Priorita.BASSA) {
                          label = 'BASSA';
                        } else if (value == Priorita.MEDIA) {
                          label = 'MEDIA';
                        } else if (value == Priorita.ALTA) {
                          label = 'ALTA';
                        } else if (value == Priorita.URGENTE) {
                          label = 'URGENTE';
                        }
                        return DropdownMenuItem<Priorita>(
                          value: value,
                          child: Text(
                            label,
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'PRIORITÀ',
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.redAccent,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Selezionare la priorità';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 10),
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
                            foregroundColor: Colors.white, backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          ),
                          child: Text('Crea nuovo cliente'.toUpperCase()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 250,
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
                            foregroundColor: Colors.white, backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          ),
                          child: Text('Crea nuova destinazione'.toUpperCase()),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 200, // Larghezza desiderata
                    height: 50, // Altezza desiderata
                    child: FloatingActionButton(
                      heroTag: "Conversione",
                      onPressed: (_titoloController.text.isNotEmpty &&
                          _descrizioneController.text.isNotEmpty &&
                          _notaController.text.isNotEmpty &&
                          _selectedPriorita != null &&
                          selectedTipologia != null &&
                          selectedCliente != null &&
                          selectedDestinazione != null)
                          ? () {
                        creaIntervento();
                      }
                          : null, // Disabilita il pulsante se le condizioni non sono soddisfatte
                      backgroundColor: (_titoloController.text.isNotEmpty &&
                          _descrizioneController.text.isNotEmpty &&
                          _notaController.text.isNotEmpty &&
                          _selectedPriorita != null &&
                          selectedTipologia != null &&
                          selectedCliente != null &&
                          selectedDestinazione != null)
                          ? Colors.red
                          : Colors.grey, // Cambia colore in base alle condizioni
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Bordi leggermente arrotondati
                      ),
                      child: Text(
                        'CREA INTERVENTO',
                        style: TextStyle(
                          color: Colors.white, // Colore della scritta bianco
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if(conversioneTask)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Compilazione Task', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  SizedBox(
                    width: 600,
                    child: TextFormField(
                      controller: _titoloTaskController,
                      maxLines: null,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Titolo'.toUpperCase(),
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none, // Rimuove il bordo standard
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.redAccent,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1.0,
                          ),
                        ),
                        hintText: "Inserisci il titolo",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 600,
                    child: TextFormField(
                      controller: _descrizioneTaskController,
                      maxLines: 5,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Descrizione'.toUpperCase(),
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.redAccent,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1.0,
                          ),
                        ),
                        hintText: "Inserisci la descrizione",
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 400,
                    child: DropdownButtonFormField<TipoTaskModel>(
                      value: selectedTipoTask,
                      onChanged: (TipoTaskModel? newValue) {
                        setState(() {
                          selectedTipoTask = newValue;
                        });
                      },
                      items: tipiTask.map<DropdownMenuItem<TipoTaskModel>>((TipoTaskModel tipologia) {
                        return DropdownMenuItem<TipoTaskModel>(
                          value: tipologia,
                          child: Text(
                            tipologia.descrizione!, // Supponendo che TipologiaInterventoModel abbia una proprietà `label`
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'TIPOLOGIA TASK',
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.redAccent,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Selezionare una tipologia di intervento';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 400,
                    child: DropdownButtonFormField<UtenteModel>(
                      value: selectedUtente,
                      onChanged: (UtenteModel? newValue) {
                        setState(() {
                          selectedUtente = newValue;
                        });
                      },
                      items: allUtenti.map<DropdownMenuItem<UtenteModel>>((UtenteModel utente) {
                        return DropdownMenuItem<UtenteModel>(
                          value: utente,
                          child: Text(
                            utente.nomeCompleto()!,
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'UTENTE',
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.redAccent,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Selezionare un utente';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 200, // Larghezza desiderata
                    height: 50, // Altezza desiderata
                    child: FloatingActionButton(
                      heroTag: "Conversione",
                      onPressed: (_descrizioneTaskController.text.isNotEmpty &&
                          _titoloTaskController.text.isNotEmpty &&
                          selectedTipoTask != null &&
                          selectedUtente != null)
                          ? () {
                        creaTask();
                      }
                          : null, // Disabilita il pulsante se le condizioni non sono soddisfatte
                      backgroundColor: (_descrizioneTaskController.text.isNotEmpty &&
                          _titoloTaskController.text.isNotEmpty &&
                          selectedTipoTask != null &&
                          selectedUtente != null)
                          ? Colors.red
                          : Colors.grey, // Cambia colore in base alle condizioni
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Bordi leggermente arrotondati
                      ),
                      child: Text(
                        'CREA TASK',
                        style: TextStyle(
                          color: Colors.white, // Colore della scritta bianco
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        )
      ),
    );
  }

  void showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Conferma Eliminazione'),
          content: Text('Procedere all\'eliminazione del ticket con ID ${widget.ticket.id}? La procedura sarà irreversibile'
              'e comporterà l\'eliminazione delle foto collegate al ticket.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                deleteTicket(int.parse(widget.ticket.id!));
              },
              child: Text('Sì'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteTicket(int ticketId) async{
    try{
      final response = await http.delete(
        Uri.parse('$ipaddressProva/api/ticket/$ticketId'),
        headers: {'Content-Type': 'application/json'},
      );
      print(response.statusCode);
      if(response.statusCode == 200){
        print('Daje');
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ticket eliminato con successo!')));
      } else {
        print('Errore durante l\'eliminazione del ticket');
      }
    } catch(e){
      print('Errore durante la richiesta HTTP: $e');
    }
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

  Future<void> creaTask() async{
    try{
      showDialog(
        context: context,
        barrierDismissible: false, // Impedisce la chiusura del dialog premendo fuori
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Caricamento in corso..."),
              ],
            ),
          );
        },
      );
      final response = await http.post(
        Uri.parse('$ipaddressProva/api/task'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'utente' : selectedUtente?.toMap(),
          'data_creazione' : DateTime.now().toIso8601String(),
          'tipologia' : selectedTipoTask?.toMap(),
          'titolo' : _titoloTaskController.text,
          'descrizione' : _descrizioneTaskController.text,
          'concluso' : false,
          'condiviso' : true,
          'accettato' : false,
          'data_conclusione' : null,
          'data_accettazione' : null,
        }),
      );
      if (response.statusCode == 201) {
        print('Ticket convertito in intervento con successo');
        final taskId = jsonDecode(response.body)['id'];
        final images = await fetchImages();
        await savePicsTask(images, taskId);
      } else {
        throw Exception(
            'Errore durante la creazione dell\'intervento: ${response.statusCode}');
      }
      final response2 = await http.post(
        Uri.parse('$ipaddressProva/api/ticket'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.ticket.id,
          'data_creazione': widget.ticket.data_creazione?.toIso8601String(),
          'descrizione': widget.ticket.descrizione,
          'note': widget.ticket.note,
          'convertito': true,
          //'tipologia': widget.ticket.tipologia?.toMap(),
          'utente': widget.ticket.utente?.toMap(),
        }),
      );

      if (response2.statusCode == 201) {
        Navigator.pop(context); // Chiudi il dialog del caricamento
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ticket convertito correttamente!')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Chiudi il dialog del caricamento in caso di errore
      print('Qualcosa non va $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e')),
      );
    } finally {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }
  }

  Future<void> creaIntervento() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false, // Impedisce la chiusura del dialog premendo fuori
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Caricamento in corso..."),
              ],
            ),
          );
        },
      );
      final response = await http.post(
        Uri.parse('$ipaddressProva/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'attivo': true,
          'visualizzato': false,
          'titolo': "TICKET ${widget.ticket.id} " + _titoloController.text,
          'priorita': _selectedPriorita.toString().split('.').last,
          'data_apertura_intervento' : DateTime.now().toIso8601String(),
          'descrizione': _descrizioneController.text,
          'note': _notaController.text,
          'utente_apertura': widget.utente.toMap(),
          'cliente': selectedCliente?.toMap(),
          'destinazione': selectedDestinazione?.toMap(),
          'tipologia': selectedTipologia?.toMap()
        }),
      );
      if (response.statusCode == 201) {
        print('Ticket convertito in intervento con successo');
        final interventoId = jsonDecode(response.body)['id'];
        final images = await fetchImages();
        await savePics(images, interventoId);
      } else {
        throw Exception(
            'Errore durante la creazione dell\'intervento: ${response.statusCode}');
      }

      final response2 = await http.post(
        Uri.parse('$ipaddressProva/api/ticket'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.ticket.id,
          'data_creazione': widget.ticket.data_creazione?.toIso8601String(),
          'descrizione': widget.ticket.descrizione,
          'note': widget.ticket.note,
          'convertito': true,
          //'tipologia': widget.ticket.tipologia?.toMap(),
          'utente': widget.ticket.utente?.toMap(),
        }),
      );
      if (response2.statusCode == 201) {
        Navigator.pop(context); // Chiudi il dialog del caricamento
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ticket convertito correttamente!')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Chiudi il dialog del caricamento in caso di errore
      print('Qualcosa non va $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e')),
      );
    } finally {
      // Assicurati che il dialogo venga chiuso in ogni caso
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }
  }

  void _showClientiDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'SELEZIONA CLIENTE',
            textAlign: TextAlign.center,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Attendi, caricamento clienti in corso...'), // Messaggio di caricamento
              SizedBox(height: 16),
              Center(child: CircularProgressIndicator()), // Indicatore di caricamento
            ],
          ),
        );
      },
    );
    await getAllClienti();
    Navigator.of(context).pop();
    _showClientiListDialog();
  }

  void _showClientiListDialog() {
    TextEditingController searchController = TextEditingController();
    List<ClienteModel> filteredClientiList = clientiList; // Inizializzazione della lista filtrata
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) { // Usa StatefulBuilder per gestire lo stato nel dialog
            return AlertDialog(
              title: Text(
                'SELEZIONA CLIENTE',
                textAlign: TextAlign.center,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      onChanged: (value) {
                        // Aggiorna lo stato del dialogo, non del widget genitore
                        setState(() {
                          filteredClientiList = clientiList.where((cliente) {
                            final denominazione = cliente.denominazione?.toLowerCase() ?? '';
                            final codice_fiscale = cliente.codice_fiscale?.toLowerCase() ?? '';
                            final partita_iva = cliente.partita_iva?.toLowerCase() ?? '';
                            final telefono = cliente.telefono?.toLowerCase() ?? '';
                            final cellulare = cliente.cellulare?.toLowerCase() ?? '';
                            final citta = cliente.citta?.toLowerCase() ?? '';
                            final email = cliente.email?.toLowerCase() ?? '';
                            final cap = cliente.cap?.toLowerCase() ?? '';

                            return denominazione.contains(value.toLowerCase()) ||
                                codice_fiscale.contains(value.toLowerCase()) ||
                                partita_iva.contains(value.toLowerCase()) ||
                                telefono.contains(value.toLowerCase()) ||
                                cellulare.contains(value.toLowerCase()) ||
                                citta.contains(value.toLowerCase()) ||
                                email.contains(value.toLowerCase()) ||
                                cap.contains(value.toLowerCase());
                          }).toList();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'CERCA CLIENTE',
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

  Future<void> getAllDestinazioniByCliente(String clientId) async {
    try {
      final response = await http.get(Uri.parse('$ipaddressProva/api/destinazione/cliente/$clientId'));
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

  Widget buildInfoRow({
    required String title,
    required String value,
    BuildContext? context,
    bool showCopyIcon = false, // Parametro opzionale per l'icona di copia
  }) {
    bool isValueTooLong = value.length > 20; // Controllo per valore lungo
    String displayedValue = isValueTooLong ? value.substring(0, 20) + "..." : value;

    return SizedBox(
      width: 500,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      color: Colors.redAccent,
                    ),
                    SizedBox(width: 10),
                    Text(
                      title.toUpperCase() + ": ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        displayedValue.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isValueTooLong && context != null) // Icona per valore lungo
                        IconButton(
                          icon: Icon(Icons.info_outline),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("${title.toUpperCase()}"),
                                  content: Text(value),
                                  actions: [
                                    TextButton(
                                      child: Text("Chiudi"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      if (showCopyIcon) // Icona per copiare negli appunti
                        IconButton(
                          icon: Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: value));
                            if (context != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Testo copiato negli appunti"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Divider(
              color: Colors.grey[400],
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }
}