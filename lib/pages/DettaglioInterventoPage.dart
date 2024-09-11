import 'dart:convert';
import 'dart:typed_data';
import 'package:fema_crm/model/DDTModel.dart';
import 'package:fema_crm/model/NotaTecnicoModel.dart';
import 'package:fema_crm/model/RelazioneDdtProdottiModel.dart';
import 'package:fema_crm/model/RelazioneProdottiInterventoModel.dart';
import 'package:fema_crm/model/RelazioneUtentiInterventiModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../model/InterventoModel.dart';
import '../model/UtenteModel.dart';
import 'AggiuntaManualeProdottiDDTPage.dart';
import 'GalleriaFotoInterventoPage.dart';
import 'PDFInterventoPage.dart';

class DettaglioInterventoPage extends StatefulWidget {
  final InterventoModel intervento;

  DettaglioInterventoPage({required this.intervento});

  @override
  _DettaglioInterventoPageState createState() =>
      _DettaglioInterventoPageState();
}

class _DettaglioInterventoPageState extends State<DettaglioInterventoPage> {
  late Future<List<UtenteModel>> _utentiFuture;
  List<RelazioneUtentiInterventiModel> otherUtenti = [];
  List<NotaTecnicoModel> allNote = [];
  List<UtenteModel> allUtenti = [];
  List<RelazioneDdtProdottoModel> prodottiDdt = [];
  TimeOfDay _selectedTimeAppuntamento = TimeOfDay.now();
  List<RelazioneProdottiInterventoModel> allProdotti = [];
  TimeOfDay _selectedTime = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _selectedTime2 = TimeOfDay(hour: 0, minute: 0);
  UtenteModel? responsabile;
  UtenteModel? _responsabileSelezionato;
  List<UtenteModel?> _selectedUtenti = [];
  List<UtenteModel?> _finalSelectedUtenti = [];
  final TextEditingController rapportinoController = TextEditingController();
  bool modificaDescrizioneVisible = false;
  bool modificaImportoVisibile = false;
  final TextEditingController descrizioneController = TextEditingController();
  final TextEditingController importoController = TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  Future<List<Uint8List>>? _futureImages;

  @override
  void initState() {
    super.initState();
    getProdottiByIntervento();
    getRelazioni();
    getNoteByIntervento();
    getProdottiDdt();
    _fetchUtentiAttivi();
    _futureImages = fetchImages();
    rapportinoController.text = (widget.intervento.relazione_tecnico != null ? widget.intervento.relazione_tecnico : '//')!;
  }

  Future<List<Uint8List>> fetchImages() async {
    final url = '$ipaddress/api/immagine/intervento/${int.parse(widget.intervento.id.toString())}/images';
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
        //print('Risposta del server: ${response.body}');
      }
      throw e; // rethrow the exception
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null) {
      setState(() {
        final now = DateTime.now();
        widget.intervento.orario_inizio = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      });
    }
  }

  Future<void> _selectTimeAppuntamento(BuildContext context) async{
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTimeAppuntamento,
    );
    if (pickedTime != null) {
      setState(() {
        final now = DateTime.now();
        widget.intervento.orario_appuntamento = DateTime(widget.intervento.data!.year, widget.intervento.data!.month, widget.intervento.data!.day, pickedTime.hour, pickedTime.minute);
        _selectedTimeAppuntamento = pickedTime;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        widget.intervento.data = picked;
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime2(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime2,
    );
    if (pickedTime != null) {
      setState(() {
        final now = DateTime.now();
        widget.intervento.orario_fine = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      });
    }
  }

  Future<http.Response?> getDDTByIntervento() async{
    try{
      final response = await http.get(Uri.parse('$ipaddress/api/ddt/intervento/${widget.intervento.id}'));
      if(response.statusCode == 200){
        print('DDT recuperato');
        return response;
      } else {
        print('DDT non presente');
        return null;
      }
    } catch(e){
      print('Errore nel recupero del DDT: $e');
      return null;
    }
  }

  Future<void> getProdottiDdt() async {
    final data = await getDDTByIntervento();
    try{
       if(data == null){
         throw Exception('Dati del DDT non disponibili.');
       } else {
         final ddt = DDTModel.fromJson(jsonDecode(data.body));
         try{
           final response = await http.get(Uri.parse('$ipaddress/api/relazioneDDTProdotto/ddt/${ddt.id}'));
           var responseData = json.decode(response.body);
           if(response.statusCode == 200){
             List<RelazioneDdtProdottoModel> prodotti = [];
             for(var item in responseData){
               prodotti.add(RelazioneDdtProdottoModel.fromJson(item));
             }
             setState(() {
               prodottiDdt = prodotti;
             });
           }
         } catch(e){
           print('Errore 1 nel recupero delle relazioni: $e');
         }
       }
    } catch(e) {
      print('Errore 2 nel recupero delle relazioni: $e');
    }
  }

  Future<void> getProdottiByIntervento() async{
    try{
      final response = await http.get(Uri.parse('$ipaddress/api/relazioneProdottoIntervento/intervento/${widget.intervento.id}'));
      var responseData = json.decode(response.body);
      if(response.statusCode == 200){
        List<RelazioneProdottiInterventoModel> prodotti = [];
        for(var item in responseData){
          prodotti.add(RelazioneProdottiInterventoModel.fromJson(item));
        }
        setState(() {
          allProdotti = prodotti;
        });
      } else {
        throw Exception('Errore durante il recupero dei prodotti');
      }
    } catch(e){
      throw Exception('Errore durante il recupero dei prodotti: $e');
    }
  }

  late double totalePrezzoFornitore = allProdotti.fold(0.0, (sum, relazione) {
    return sum + (relazione.prodotto?.prezzo_fornitore ?? 0.0);
  });

  Future<void> getNoteByIntervento() async{
    try{
      final response = await http.get(Uri.parse('$ipaddress/api/noteTecnico/intervento/${widget.intervento.id}'));
      var responseData = json.decode(response.body);
      if(response.statusCode == 200){
        List<NotaTecnicoModel> note =[];
        for(var item in responseData){
          note.add(NotaTecnicoModel.fromJson(item));
        }
        setState(() {
          allNote = note;
        });
      } else {
        throw Exception('Errore durante il recupero delle note');
      }
    } catch(e){
      throw Exception('Errore durante il recupero delle note: $e');
    }
  }

  Future<void> getRelazioni() async{
    try{
      final response = await http.get(Uri.parse('${ipaddress}/api/relazioneUtentiInterventi/intervento/${widget.intervento.id}'));
      var responseData = json.decode(response.body.toString());
      if(response.statusCode == 200){
        List<RelazioneUtentiInterventiModel> relazioni = [];
        for(var relazione in responseData){
          relazioni.add(RelazioneUtentiInterventiModel.fromJson(relazione));
        }
        setState(() {
          otherUtenti = relazioni;
        });
      } else {
        throw Exception('Errore durante il recupero degli utenti');
      }
    } catch (e) {
      throw Exception('Errore durante il recupero degli utenti: $e');
    }
  }

  Future<void> _fetchUtentiAttivi() async {
    try {
      final response = await http.get(Uri.parse('${ipaddress}/api/utente/attivo'));
      var responseData = json.decode(response.body.toString());
      if (response.statusCode == 200) {
        List<UtenteModel> utenti = [];
        for (var singoloUtente in responseData) {
          utenti.add(UtenteModel.fromJson(singoloUtente));
        }
        setState(() {
          allUtenti = utenti;
        });
      } else {
        throw Exception('Errore durante il recupero degli utenti');
      }
    } catch (e) {
      throw Exception('Errore durante il recupero degli utenti: $e');
    }
  }

  void modificaDescrizione() async{
    try{
      final response = await http.post(
        Uri.parse('${ipaddress}/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.id?.toString(),
          'data_apertura_intervento' : widget.intervento.data_apertura_intervento?.toIso8601String(),
          'data': widget.intervento.data?.toIso8601String(),
          'orario_appuntamento' : widget.intervento.orario_appuntamento?.toIso8601String(),
          'posizione_gps' : widget.intervento.posizione_gps,
          'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
          'orario_fine': widget.intervento.orario_fine?.toIso8601String(),
          'descrizione': descrizioneController.text.toUpperCase(),
          'importo_intervento': widget.intervento.importo_intervento,
          'prezzo_ivato' : widget.intervento.prezzo_ivato,
          'acconto' : widget.intervento.acconto,
          'assegnato': widget.intervento.assegnato,
          'conclusione_parziale' : widget.intervento.conclusione_parziale,
          'concluso': widget.intervento.concluso,
          'saldato': widget.intervento.saldato,
          'saldato_da_tecnico' : widget.intervento.saldato_da_tecnico,
          'note': widget.intervento.note,
          'relazione_tecnico' : widget.intervento.relazione_tecnico,
          'firma_cliente': widget.intervento.firma_cliente,
          'utente': widget.intervento.utente?.toMap(),
          'cliente': widget.intervento.cliente?.toMap(),
          'veicolo': widget.intervento.veicolo?.toMap(),
          'merce' :widget.intervento.merce?.toMap(),
          'tipologia': widget.intervento.tipologia?.toMap(),
          'categoria_intervento_specifico':
          widget.intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
          'destinazione': widget.intervento.destinazione?.toMap(),
          'gruppo' : widget.intervento.gruppo?.toMap()
        }),
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Descrizione cambiata con successo!'),
          ),
        );
        setState(() {
          widget.intervento.descrizione = descrizioneController.text;
        });
      }
    } catch(e){
      print('Qualcosa non va: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String descrizioneInterventoSub = widget.intervento.descrizione!.length < 30
        ? widget.intervento.descrizione!
        : widget.intervento.descrizione!.substring(0, 30);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Dettaglio Intervento',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Wrap(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informazioni di base',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              SizedBox(
                                width: 500,
                                child: buildInfoRow(
                                  title: 'Descrizione',
                                  value: descrizioneInterventoSub,
                                  context: context
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    modificaDescrizioneVisible = !modificaDescrizioneVisible;
                                  });
                                },
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 15),
                          if(modificaDescrizioneVisible)
                            SizedBox(
                              width: 500,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 300,
                                    child: TextFormField(
                                      maxLines: null,
                                      controller: descrizioneController,
                                      decoration: InputDecoration(
                                        labelText: 'Descrizione',
                                        hintText: 'Aggiungi una descrizione',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 170,
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Aggiunge padding attorno al FloatingActionButton
                                    decoration: BoxDecoration(
                                      // Puoi aggiungere altre decorazioni come bordi o ombre qui se necessario
                                    ),
                                    child: FloatingActionButton(
                                      heroTag: "Tag2",
                                      onPressed: () {
                                        if(descrizioneController.text.isNotEmpty){
                                          modificaDescrizione();
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Non è possibile salvare una descrizione nulla!'),
                                            ),
                                          );
                                        }
                                      },
                                      backgroundColor: Colors.red,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Flexible( // Permette al testo di adattarsi alla dimensione del FloatingActionButton
                                            child: Text(
                                              'Modifica Descrizione'.toUpperCase(),
                                              style: TextStyle(color: Colors.white, fontSize: 12),
                                              textAlign: TextAlign.center, // Centra il testo
                                              softWrap: true, // Permette al testo di andare a capo
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              buildInfoRow(
                                title: 'ID intervento',
                                value: widget.intervento.id!,
                                  context: context
                              ),
                              SizedBox(width: 20),
                              buildInfoRow(
                                title: 'Data creazione',
                                value: formatDate(widget.intervento.data_apertura_intervento),
                                  context: context
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              buildInfoRow(
                                title: 'Data accordata',
                                value: formatDate(widget.intervento.data),
                                  context: context
                              ),
                              SizedBox(width: 20),
                              buildInfoRow(
                                title: 'Orario appuntamento',
                                value: formatTime(widget.intervento.orario_appuntamento),
                                  context: context
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 170,
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Aggiunge padding
                                child: FloatingActionButton(
                                  onPressed: () {
                                    _selectDate(context);
                                  },
                                  heroTag: "Tag3",
                                  backgroundColor: Colors.red,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Flexible( // Permette al testo di adattarsi alla dimensione
                                        child: Text(
                                          'Modifica data intervento'.toUpperCase(),
                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                          textAlign: TextAlign.center, // Centra il testo
                                          softWrap: true, // Permette al testo di andare a capo
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Container(
                                width: 170,
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Aggiunge padding attorno al FloatingActionButton
                                decoration: BoxDecoration(
                                  // Puoi aggiungere altre decorazioni come bordi o ombre qui se necessario
                                ),
                                child: FloatingActionButton(
                                  heroTag: "Tag2",
                                  onPressed: () {
                                    _selectTimeAppuntamento(context);
                                  },
                                  backgroundColor: Colors.red,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Flexible( // Permette al testo di adattarsi alla dimensione del FloatingActionButton
                                        child: Text(
                                          'Inserisci orario appuntamento'.toUpperCase(),
                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                          textAlign: TextAlign.center, // Centra il testo
                                          softWrap: true, // Permette al testo di andare a capo
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Prima colonna
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    buildInfoRow(
                                      title: 'Orario Inizio',
                                      value: widget.intervento.orario_inizio != null ? DateFormat("dd/MM/yyyy HH:mm").format(widget.intervento.orario_inizio!) : "N/A",
                                        context: context
                                    ),
                                    if (widget.intervento.orario_inizio == null)
                                      Align(
                                        alignment: Alignment.center,
                                        child: InkWell(
                                          onTap: () => _selectTime(context),
                                          child: Row(
                                            children: [
                                              Icon(Icons.access_time),
                                              SizedBox(width: 8),
                                              Text(
                                                _selectedTime.format(context),
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                // Divisore verticale
                                SizedBox(
                                  width: 20,
                                ),
                                // Seconda colonna
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    buildInfoRow(
                                      title: 'Orario Fine',
                                        value: widget.intervento.orario_fine != null ? DateFormat("dd/MM/yyyy HH:mm").format(widget.intervento.orario_fine!) : "N/A",
                                        context: context
                                    ),
                                    if (widget.intervento.orario_fine == null)
                                      Align(
                                        alignment: Alignment.center,
                                        child: InkWell(
                                          onTap: () => _selectTime2(context),
                                          child: Row(
                                            children: [
                                              Icon(Icons.access_time),
                                              SizedBox(width: 8),
                                              Text(
                                                _selectedTime2.format(context),
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 500,
                            child: buildInfoRow(
                                title: 'Cliente',
                                value: widget.intervento.cliente?.denominazione ?? 'N/A', context: context),
                          ),
                          SizedBox(
                            width: 500,
                            child: buildInfoRow(
                              title: 'Indirizzo destinazione',
                              value: widget.intervento.destinazione?.indirizzo ?? 'N/A',
                                context: context
                            ),
                          ),
                          SizedBox(
                            width: 500,
                            child: buildInfoRow(
                              title: 'Cellulare destinazione',
                              value: widget.intervento.destinazione?.cellulare ?? 'N/A',
                                context: context
                            ),
                          ),
                          SizedBox(
                            width: 500,
                            child: buildInfoRow(
                              title: 'Telefono destinazione',
                              value: widget.intervento.destinazione?.telefono ?? 'N/A',
                                context: context
                            ),
                          ),
                          SizedBox(
                            width: 500,
                            child: buildInfoRow(
                              title: 'Indirizzo cliente',
                              value: widget.intervento.cliente?.indirizzo ?? 'N/A',
                                context: context
                            ),
                          ),
                          SizedBox(
                            width: 500,
                            child: buildInfoRow(
                              title: 'Telefono cliente',
                              value: widget.intervento.cliente?.telefono ?? 'N/A',
                                context: context
                            ),
                          ),
                          SizedBox(
                            width: 500,
                            child: buildInfoRow(
                              title: 'Cellulare cliente',
                              value: widget.intervento.cliente?.cellulare ?? 'N/A',
                                context: context
                            ),
                          ),
                        ],
                      ),
                    ),
                    //FINE PRIMO CONTAINER INFORMAZIONI BASE
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informazioni sull\'intervento',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              SizedBox(
                                width: 500,
                                child: buildInfoRow(
                                  title: 'Importo Intervento',
                                  value: widget.intervento.importo_intervento?.toStringAsFixed(2) ?? 'N/A',
                                    context: context
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    modificaImportoVisibile = !modificaImportoVisibile;
                                  });
                                },
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 10),
                          if(modificaImportoVisibile)
                            SizedBox(
                              width: 500,
                              child: TextFormField(
                                controller: importoController,
                                decoration: InputDecoration(
                                  labelText: 'Importo',
                                  hintText: 'Inserisci l\'importo',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: 500,
                            child: buildInfoRow(
                              title: 'Assegnato',
                              value: booleanToString(widget.intervento.assegnato ?? false),
                                context: context
                            ),
                          ),
                          SizedBox(height: 15),
                          if (widget.intervento.utente == null)
                            FloatingActionButton(
                              heroTag: "Tag",
                              onPressed: () {
                                _showUtentiDialog();
                              },
                              child: Text(
                                '  Assegna  ',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: 500,
                            child: buildInfoRow(
                              title: 'Utente incaricato',
                              value: '${widget.intervento.utente?.nomeCompleto() ?? 'Non assegnato'}',
                                context: context
                            ),
                          ),
                          if (otherUtenti.isNotEmpty)
                            SizedBox(
                              width: 500,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Altri utenti:',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  ...otherUtenti.map((relazione) => buildInfoRow(
                                    title: 'Utente',
                                    value: '${relazione.utente?.nomeCompleto() ?? 'N/A'}',
                                      context: context
                                  )),
                                ],
                              ),
                            ),
                          SizedBox(height: 15),
                          buildRelazioneForm(title: 'Relazione tecnico'),
                          SizedBox(
                            width: 500,
                            child: buildInfoRow(
                              title: 'Concluso',
                              value: booleanToString(widget.intervento.concluso ?? false),
                                context: context
                            ),
                          ),
                          SizedBox(
                            width: 500,
                            child: buildInfoRow(
                              title: 'Saldato',
                              value: booleanToString(widget.intervento.saldato ?? false),
                            ),
                          ),
                          SizedBox(
                            width: 500,
                            child: buildInfoRow(
                              title: "Posizione gps",
                              context: context,
                              value : widget.intervento.posizione_gps ?? "N/A"
                            ),
                          ),
                          SizedBox(
                            width: 500,
                            child: buildInfoRow(
                              title: 'Note',
                              value: widget.intervento.note ?? 'N/A',
                                context: context
                            ),
                          ),
                          SizedBox(
                            width: 500,
                            child: buildInfoRow(
                              title: 'Metodo di pagamento',
                              value: widget.intervento.tipologia_pagamento != null
                                  ? widget.intervento.tipologia_pagamento?.descrizione ?? 'N/A'
                                  : 'N/A',
                                context: context
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        if(widget.intervento.merce != null)
                          Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Informazioni sulla merce in riparazione',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 500,
                                  child: buildInfoRow(
                                    title: 'Presenza magazzino'.toUpperCase(),
                                    value: widget.intervento.merce?.presenza_magazzino == true ? "SI" : "NO",
                                    context: context
                                  ),
                                ),
                                SizedBox(
                                  width: 500,
                                  child : buildInfoRow(
                                    title: 'Articolo',
                                    value: widget.intervento.merce?.articolo ?? 'N/A',
                                      context: context
                                  ),
                                ),
                                SizedBox(
                                  width: 500,
                                  child: buildInfoRow(
                                    title: 'Accessori',
                                    value: widget.intervento.merce?.accessori ?? 'N/A',
                                      context: context
                                  ),
                                ),
                                SizedBox(
                                  width: 500,
                                  child: buildInfoRow(
                                    title: 'Difetto riscontrato',
                                    value: widget.intervento.merce?.difetto_riscontrato ?? 'N/A',
                                      context: context
                                  ),
                                ),
                                SizedBox(
                                  width: 500,
                                  child: buildInfoRow(
                                    title: 'Richiesta di preventivo',
                                    value: booleanToString(widget.intervento.merce?.preventivo ?? false),
                                      context: context
                                  ),
                                ),
                                SizedBox(
                                  width: 500,
                                  child: buildInfoRow(
                                    title: 'Importo preventivato',
                                    value: widget.intervento.merce?.importo_preventivato.toString() ?? 'N/A',
                                      context: context
                                  ),
                                ),
                                SizedBox(
                                  width: 500,
                                  child: buildInfoRow(
                                    title: 'Password',
                                    value: widget.intervento.merce?.password ?? 'N/A',
                                      context: context
                                  ),
                                ),
                                SizedBox(
                                  width: 500,
                                  child: buildInfoRow(
                                    title: 'Dati',
                                    value: widget.intervento.merce?.dati ?? 'N/A',
                                      context: context
                                  ),
                                ),
                                SizedBox(
                                  width: 500,
                                  child: buildInfoRow(
                                      title: 'Diagnosi',
                                      value: widget.intervento.merce?.diagnosi ?? 'N/A',
                                      context: context
                                  ),
                                ),
                                SizedBox(
                                  width: 500,
                                  child: buildInfoRow(
                                      title: 'Risoluzione',
                                      value: widget.intervento.merce?.risoluzione ?? 'N/A',
                                      context: context
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: 20,),
                        Container(
                          width: 600,
                          child: FutureBuilder<List<Uint8List>>(
                            future: _futureImages,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Wrap(
                                  spacing: 16, // aumenta la spaziatura orizzontale tra le foto
                                  runSpacing: 16, // aumenta la spaziatura verticale tra le foto
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
                      ],
                    ),
                    //Inizio container foto
                  ],
                ),
                SizedBox(height: 16.0),
                if(prodottiDdt.isEmpty)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AggiuntaManualeProdottiDDTPage(intervento: widget.intervento)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      textStyle: TextStyle(fontSize: 18),
                      primary: Colors.red,
                    ),
                    child: Text(
                      'Crea DDT',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                SizedBox(height: 16),
                SizedBox(height: 15),
                if(prodottiDdt.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Prodotti inseriti nel DDT:',style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                        ...prodottiDdt.map((relazione){
                          return ListTile(
                            title: Text(
                                'Codice Danea: ${relazione.prodotto?.codice_danea}, ${relazione.prodotto?.descrizione}'
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                SizedBox(height: 16),
                if(allProdotti.isEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nessun prodotto utilizzato', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                    ],
                  ),
                if (allProdotti.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prodotti utilizzati:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ...allProdotti.map((relazione) {
                        bool isInHistoricalUser = relazione.presenza_storico_utente ?? true; // Supponendo che il valore predefinito sia true
                        bool hasDdt = relazione.ddt != null; // Controlla se ddt non è null
                        bool hasSerial = relazione.seriale != null;
                        bool shouldBeRed = !isInHistoricalUser && !hasDdt; // Colore rosso se isInHistoricalUser è false e se hasDdt è false

                        String prezzoFornitore = relazione.prodotto?.prezzo_fornitore != null
                            ? relazione.prodotto!.prezzo_fornitore!.toStringAsFixed(2) + "€"
                            : "Non disponibile"; // Controlla se prezzo_fornitore è null

                        return ListTile(
                          title: Text(
                            '${relazione.prodotto?.descrizione ?? "Descrizione non disponibile"}',
                            style: TextStyle(color: shouldBeRed ? Colors.red : Colors.black),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Codice Danea: ${relazione.prodotto?.codice_danea ?? "Codice non disponibile"} - Prezzo fornitore: $prezzoFornitore',
                                style: TextStyle(color: shouldBeRed ? Colors.red : Colors.black),
                              ),
                              SizedBox(height: 6),
                              Text(
                                '${relazione.seriale ?? ''}', style: TextStyle(color: shouldBeRed ? Colors.red : Colors.black),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 16), // Aggiungere uno spazio tra la lista e il totale
                      Text(
                        'Totale prezzo fornitore: ${totalePrezzoFornitore.toStringAsFixed(2)}€',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                if (allNote.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Note dei tecnici:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ...allNote.map((nota) => ListTile(
                        title: Text('${nota.utente?.nome} ${nota.utente?.cognome}'),
                        subtitle: Text('${nota.nota}'),
                      )),
                    ],
                  ),
                if(allNote.isEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 14,),
                      Text('Nessuna nota relativa all\'intervento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                    ],
                  ),
                SizedBox(height: 20),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20,),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          saveModifiche();
                        },
                        child: Text(
                          'Salva modifiche',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                      SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PDFInterventoPage(
                                    intervento: widget.intervento,
                                    //descrizione: widget.intervento.relazione_tecnico.toString(),
                                ),
                              ),
                            );
                        },
                        icon: Icon(Icons.picture_as_pdf, color: Colors.white),
                        label: Text('Genera PDF', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Imposta il colore di sfondo a rosso
                        ),
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          saldato();
                        },
                        child: Text(
                          'Intervento saldato',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Imposta il colore di sfondo a rosso
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRelazioneForm({required String title}) {
    return SizedBox(
      width: 530,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Allinea il contenuto a sinistra
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16), // Spazio tra il titolo e il campo di testo
          Row(
            children: [
              SizedBox(
                width: 480,
                child: TextFormField(
                  controller: rapportinoController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8), // Spazio tra il campo di testo e l'icona
              IconButton(
                icon: Icon(Icons.content_copy),
                onPressed: () {
                  if (rapportinoController.text.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: rapportinoController.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Rapportino copiato!')),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow({required String title, required String value, BuildContext? context}) {
    // Verifica se il valore supera i 25 caratteri
    bool isValueTooLong = value.length > 25;
    String displayedValue = isValueTooLong ? value.substring(0, 25) + "..." : value;
    return SizedBox(
      width:280,
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
                      width: 4, // Linea di accento colorata
                      height: 24,
                      color: Colors.redAccent, // Colore di accento per un tocco di vivacità
                    ),
                    SizedBox(width: 10),
                    Text(
                      title.toUpperCase() + ": ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87, // Colore contrastante per il testo
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
                          fontWeight: FontWeight.bold, // Un colore secondario per differenziare il valore
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isValueTooLong && context != null)
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
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Divider( // Linea di separazione tra i widget
              color: Colors.grey[400],
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }



  String timeOfDayToIso8601String(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return dateTime.toIso8601String();
  }

  Future<void> saveModifiche() async {
    DateTime? orario = _selectedTimeAppuntamento != null ? convertTimeOfDayToDateTime(_selectedTimeAppuntamento) : widget.intervento.orario_appuntamento;
    double? importo = importoController.text.isNotEmpty ? double.tryParse(importoController.text) : widget.intervento.importo_intervento;
    String? descrizione = descrizioneController.text.isNotEmpty ? descrizioneController.text : widget.intervento.descrizione;
    try {
      final response = await http.post(
        Uri.parse('$ipaddress/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.id,
          'data_apertura_intervento' : widget.intervento.data_apertura_intervento?.toIso8601String(),
          'data': widget.intervento.data?.toIso8601String(),
          'orario_appuntamento': orario?.toIso8601String(),
          'posizione_gps' : widget.intervento.posizione_gps,
          'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
          'orario_fine': widget.intervento.orario_fine?.toIso8601String(),
          'descrizione': descrizione,
          'importo_intervento': importo,
          'prezzo_ivato' : widget.intervento.prezzo_ivato,
          'acconto': widget.intervento.acconto,
          'assegnato': widget.intervento.assegnato,
          'conclusione_parziale': widget.intervento.conclusione_parziale,
          'concluso': widget.intervento.concluso,
          'saldato': widget.intervento.saldato,
          'saldato_da_tecnico' : widget.intervento.saldato_da_tecnico,
          'note': widget.intervento.note,
          'relazione_tecnico': widget.intervento.relazione_tecnico,
          'firma_cliente': widget.intervento.firma_cliente,
          'utente': widget.intervento.utente?.toMap(),
          'cliente': widget.intervento.cliente?.toMap(),
          'veicolo': widget.intervento.veicolo?.toMap(),
          'merce': widget.intervento.merce?.toMap(),
          'tipologia': widget.intervento.tipologia?.toMap(),
          'categoria': widget.intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
          'destinazione': widget.intervento.destinazione?.toMap(),
          'gruppo': widget.intervento.gruppo?.toMap(),
        }),
      );

      if (response.statusCode == 201) {
        print('Modifica effettuata');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Intervento modificato con successo!'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
      }
    } catch (e) {
      print('Errore nell\'aggiornamento dell\'intervento: $e');
    }
  }

  DateTime convertTimeOfDayToDateTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  }

  Future<void> assegna() async {
    print(_selectedUtenti.toString());
    print(_finalSelectedUtenti.toString());
    try {
      final response = await http.post(Uri.parse('${ipaddress}/api/intervento'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': widget.intervento.id,
            'data_apertura_intervento' : widget.intervento.data_apertura_intervento?.toIso8601String(),
            'data': widget.intervento.data?.toIso8601String(),
            'orario_appuntamento' : widget.intervento.orario_appuntamento?.toIso8601String(),
            'posizione_gps' : widget.intervento.posizione_gps,
            'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
            'orario_fine': widget.intervento.orario_fine?.toIso8601String(),
            'descrizione': widget.intervento.descrizione,
            'importo_intervento': widget.intervento.importo_intervento,
            'prezzo_ivato' : widget.intervento.prezzo_ivato,
            'acconto' : widget.intervento.acconto,
            'assegnato': true,
            'conclusione_parziale' : widget.intervento.conclusione_parziale,
            'concluso': widget.intervento.concluso,
            'saldato': widget.intervento.saldato,
            'saldato_da_tecnico' : widget.intervento.saldato_da_tecnico,
            'note': widget.intervento.note,
            'relazione_tecnico' : widget.intervento.relazione_tecnico,
            'firma_cliente': widget.intervento.firma_cliente,
            'utente': _responsabileSelezionato?.toMap(),
            'cliente': widget.intervento.cliente?.toMap(),
            'veicolo': widget.intervento.veicolo?.toMap(),
            'merce' : widget.intervento.merce?.toMap(),
            'tipologia': widget.intervento.tipologia?.toMap(),
            'categoria': widget.intervento.categoria_intervento_specifico?.toMap(),
            'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
            'destinazione': widget.intervento.destinazione?.toMap(),
            'gruppo': widget.intervento.gruppo?.toMap()
          }));
      if (response.statusCode == 201) {
        print('EVVAIIIIIIII');
        if(_selectedUtenti.isNotEmpty){
          for(var utente in _selectedUtenti){
            try{
              print('sono qui');
              final response = await http.post(
                Uri.parse('$ipaddress/api/relazioneUtentiInterventi'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'utente' : utente?.toMap(),
                  'intervento' : widget.intervento.toMap(),
                }),
              );
              print(response.body);
            } catch(e) {
              print('Errore durante il salvataggio della relazione: $e');
            }
          }
        }
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Intervento assegnato!'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
      } else {

      }
    } catch (e) {
      print('Errore durante il salvataggio del preventivo: $e');
    }
  }

  Future<void> saldato() async {
    try {
      final response = await http.post(Uri.parse('${ipaddress}/api/intervento'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': widget.intervento.id,
            'data_apertura_intervento' : widget.intervento.data_apertura_intervento?.toIso8601String(),
            'data': widget.intervento.data?.toIso8601String(),
            'orario_appuntamento' : widget.intervento.orario_appuntamento,
            'posizione_gps' : widget.intervento.posizione_gps,
            'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
            'orario_fine': widget.intervento.orario_fine?.toIso8601String(),
            'descrizione': widget.intervento.descrizione,
            'importo_intervento': widget.intervento.importo_intervento,
            'prezzo_ivato' : widget.intervento.prezzo_ivato,
            'acconto' : widget.intervento.acconto,
            'assegnato': widget.intervento.assegnato,
            'conclusione_parziale' : widget.intervento.conclusione_parziale,
            'concluso': widget.intervento.concluso,
            'saldato': true,
            'saldato_da_tecnico' : widget.intervento.saldato_da_tecnico,
            'note': widget.intervento.note,
            'relazione_tecnico' : widget.intervento.relazione_tecnico,
            'firma_cliente': widget.intervento.firma_cliente,
            'utente': widget.intervento.utente?.toMap(),
            'cliente': widget.intervento.cliente?.toMap(),
            'veicolo': widget.intervento.veicolo?.toMap(),
            'merce' : widget.intervento.merce?.toMap(),
            'tipologia': widget.intervento.tipologia?.toMap(),
            'categoria': widget.intervento.categoria_intervento_specifico?.toMap(),
            'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
            'destinazione': widget.intervento.destinazione?.toMap(),
            'gruppo': widget.intervento.gruppo?.toMap()
          }));
      if (response.statusCode == 201) {
        print('EVVAIIIIIIII');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Intervento saldato!'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
        Navigator.pop(context);
        Navigator.pop(context);
      } else {}
    } catch (e) {
      print('Errore : $e');
    }
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
                                value: _finalSelectedUtenti.contains(utente),
                                onChanged: (value) {
                                  setState(() {
                                    if (value!) {
                                      _selectedUtenti.add(utente);
                                      _finalSelectedUtenti.add(utente);
                                    } else {
                                      _finalSelectedUtenti.remove(utente);
                                      _selectedUtenti.remove(utente);
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
                        Center(
                          child: TextButton(
                            onPressed: () {
                              assegna();
                            },
                            child: Text(
                              'ASSEGNA'
                            ),
                          ),
                        )
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
      setState(() {});
    });
  }

  String formatDate(DateTime? date) {
    return date != null ? dateFormatter.format(date) : 'N/A';
  }

  String formatTime(DateTime? time) {
    return time != null ? timeFormatter.format(time) : 'N/A';
  }

  String booleanToString(bool? value) {
    return value != null ? (value ? 'SI' : 'NO') : 'N/A';
  }

  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
  final DateFormat timeFormatter = DateFormat('HH:mm');
}

