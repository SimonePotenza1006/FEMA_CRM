import 'dart:convert';
import 'dart:typed_data';
import 'package:fema_crm/databaseHandler/DbHelper.dart';
import 'package:fema_crm/model/DDTModel.dart';
import 'package:fema_crm/model/DestinazioneModel.dart';
import 'package:fema_crm/model/NotaTecnicoModel.dart';
import 'package:fema_crm/model/RelazioneDdtProdottiModel.dart';
import 'package:fema_crm/model/RelazioneProdottiInterventoModel.dart';
import 'package:fema_crm/model/RelazioneUtentiInterventiModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../model/ClienteModel.dart';
import '../model/FaseRiparazioneModel.dart';
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
  late Future<List<ClienteModel>> allClienti;
  late Future<List<FaseRiparazioneModel>> allFasi;
  List<ClienteModel> clientiList =[];
  List<ClienteModel> filteredClientiList = [];
  List<DestinazioneModel> allDestinazioniByCliente = [];
  ClienteModel? selectedCliente;
  DestinazioneModel? selectedDestinazione;
  List<RelazioneDdtProdottoModel> prodottiDdt = [];
  TimeOfDay? _selectedTimeAppuntamento = null;
  List<RelazioneProdottiInterventoModel> allProdotti = [];
  TimeOfDay _selectedTime = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _selectedTime2 = TimeOfDay(hour: 0, minute: 0);
  UtenteModel? responsabile;
  UtenteModel? _responsabileSelezionato;
  List<UtenteModel?> _selectedUtenti = [];
  List<UtenteModel?> _finalSelectedUtenti = [];
  List<FaseRiparazioneModel> fasiRiparazione = [];
  TextEditingController rapportinoController = TextEditingController();
  TextEditingController _codiceDaneaController = TextEditingController();
  bool modificaDescrizioneVisible = false;
  bool modificaImportoVisibile = false;
  bool modificaNotaVisibile = false;
  final TextEditingController descrizioneController = TextEditingController();
  final TextEditingController importoController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  Future<List<Uint8List>>? _futureImages;
  DbHelper? dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();
    allClienti = dbHelper!.getAllClienti();
    allClienti.then((clienti) {
      setState(() {
        clientiList = clienti;
        filteredClientiList = List.from(clientiList);
      });
    });
    allFasi = dbHelper!.getFasiByMerce(widget.intervento);
    allFasi.then((fasi){
      setState(() {
       fasiRiparazione = fasi;
      });
    });
    getProdottiByIntervento();
    getRelazioni();
    getNoteByIntervento();
    getProdottiDdt();
    _fetchUtentiAttivi();
    _futureImages = fetchImages();
    rapportinoController.text = (widget.intervento.relazione_tecnico != null ? widget.intervento.relazione_tecnico : '//')!;
  }

  void _showClientiDialog() {
    TextEditingController searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Seleziona Cliente', textAlign: TextAlign.center),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
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
                              title: Text('${cliente.denominazione}, ${cliente.indirizzo}'),
                              onTap: () {
                                setState(() {
                                  selectedCliente = cliente;
                                });
                                Navigator.of(context).pop(); // Chiude il dialog dei clienti
                                _getAndShowDestinazioni(cliente); // Chiama la funzione per aprire il dialog delle destinazioni
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

  void _getAndShowDestinazioni(ClienteModel cliente) async {
    // Mostra un indicatore di caricamento
    showDialog(
      context: context,
      barrierDismissible: false, // Previene la chiusura del dialog toccando al di fuori
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // Ottieni le destinazioni
    List<DestinazioneModel> destinazioni = await dbHelper!.getDestinazioneByCliente(cliente);

    // Chiudi l'indicatore di caricamento
    Navigator.of(context).pop();

    if (destinazioni.isNotEmpty) {
      // Mostra il dialog delle destinazioni
      _showDestinazioniDialog(destinazioni);
    } else {
      // Se non ci sono destinazioni, mostra un messaggio di errore o di avviso
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Nessuna destinazione trovata'),
            content: const Text('Non ci sono destinazioni disponibili per questo cliente.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _showDestinazioniDialog(List<DestinazioneModel> destinazioni) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('SELEZIONA DESTINAZIONE', textAlign: TextAlign.center),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: destinazioni.map((destinazione) {
                        return ListTile(
                          leading: const Icon(Icons.home_work_outlined),
                          title: Text(destinazione.denominazione!),
                          onTap: () {
                            setState(() {
                              selectedDestinazione = destinazione;
                            });
                            Navigator.of(context).pop(); // Chiude il dialog delle destinazioni
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

  Future<void> _selectTimeAppuntamento(BuildContext context) async {
    // Convert DateTime.now() to TimeOfDay
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(), // Use TimeOfDay.now() instead of DateTime.now()
    );

    if (pickedTime != null) {
      setState(() {

        widget.intervento.orario_appuntamento =
              DateTime(widget.intervento.data!.year, widget.intervento.data!.month, widget.intervento.data!.day, pickedTime.hour, pickedTime.minute);
        _selectedTimeAppuntamento = pickedTime;
      });
    }
  }

  Future<void> _selectDate2(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        widget.intervento.data_apertura_intervento = picked;
        selectedDate = picked;
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
    double prezzoFornitore = relazione.prodotto?.prezzo_fornitore ?? 0.0;
    double quantita = relazione.quantita ?? 1.0;

    print('Prezzo Fornitore: $prezzoFornitore, Quantità: ${quantita}'); // Controllo dei valori

    return sum + (prezzoFornitore * quantita);
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
          'numerazione_danea' : widget.intervento.numerazione_danea,
          'priorita' : widget.intervento.priorita.toString().split('.').last,
          'data_apertura_intervento' : widget.intervento.data_apertura_intervento?.toIso8601String(),
          'data': widget.intervento.data?.toIso8601String(),
          'orario_appuntamento' : widget.intervento.orario_appuntamento?.toIso8601String(),
          'posizione_gps' : widget.intervento.posizione_gps,
          'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
          'orario_fine': widget.intervento.orario_fine?.toIso8601String(),
          'descrizione': descrizioneController.text.toUpperCase(),
          'importo_intervento': widget.intervento.importo_intervento,
          'prezzo_ivato' : widget.intervento.prezzo_ivato,
          'iva' : widget.intervento.iva,
          'acconto' : widget.intervento.acconto,
          'assegnato': widget.intervento.assegnato,
          'accettato_da_tecnico' : widget.intervento.accettato_da_tecnico,
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

  void showCodiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Inserisci un codice'.toUpperCase()),
              actions: <Widget>[
                TextFormField(
                  controller: _codiceDaneaController,
                  decoration: InputDecoration(
                    labelText: 'CODICE DANEA',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState((){
                      widget.intervento.numerazione_danea = _codiceDaneaController.text;
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Salva codice'.toUpperCase()),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    Color? prioritaColor;
    switch (widget.intervento.priorita) {
      case Priorita.BASSA :
        prioritaColor = Colors.lightGreen;
        break;
      case Priorita.MEDIA :
        prioritaColor = Colors.yellow; // grigio chiaro
        break;
      case Priorita.ALTA:
        prioritaColor = Colors.orange; // giallo chiaro
        break;
      case Priorita.URGENTE:
        prioritaColor = Colors.red; // azzurro chiaro
        break;
      default:
        prioritaColor = Colors.blueGrey[200];
    }

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
        actions: [
          Tooltip(
            message: 'Salva modifiche',  // The text that will appear in the tooltip
            preferBelow: true,       // This makes the tooltip appear below the icon
            child: IconButton(
              icon: Icon(Icons.save, color: Colors.white, size: 30),
              onPressed: () {
                saveModifiche();
              },
            ),
          ),
          SizedBox(width: 10),
          Tooltip(
            message: 'Genera PDF',  // The text that will appear in the tooltip
            preferBelow: true,       // This makes the tooltip appear below the icon
            child: IconButton(
              icon: Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 30),
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
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Wrap(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
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
                                      value: widget.intervento.descrizione!,
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
                                    value: widget.intervento.id!+'/${widget.intervento.data_apertura_intervento?.year != null ? widget.intervento.data_apertura_intervento?.year : DateTime.now().year }APP',
                                    context: context
                                ),
                                SizedBox(width: 20),
                                buildInfoRow(
                                    title: 'Codice DANEA',
                                    value: widget.intervento.numerazione_danea ?? 'N/A',
                                    context: context
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: (){
                                    showCodiceDialog(context);
                                  }
                                )
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                buildInfoPrioritaRow(
                                    title: 'Priorità',
                                    value: widget.intervento.priorita!,
                                    context: context
                                ),
                                SizedBox(width: 20),
                                buildInfoRow(
                                    title: 'Data creazione',
                                    value: formatDate(widget.intervento.data_apertura_intervento),
                                    context: context
                                ),
                                IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed:(){
                                      _selectDate2(context);
                                    }
                                )
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
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8), // Aggiunge padding
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
                                Container(
                                  width: 70,
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8), // Aggiunge padding
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      //_selectDate(context);

                                        setState(() {
                                          widget.intervento.data = null;

                                        });

                                    },
                                    heroTag: "TagDel",
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.delete, color: Colors.white),
                                    /*Column(
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
                                    ),*/
                                  ),
                                ),
                                SizedBox(width: 30),
                                Container(
                                  width: 170,
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8), // Aggiunge padding attorno al FloatingActionButton
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
                                Container(
                                  width: 70,
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8), // Aggiunge padding
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      setState(() {
                                        widget.intervento.orario_appuntamento = null;
                                        _selectedTimeAppuntamento = null;
                                      });
                                    },
                                    heroTag: "TagDel2",
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.delete, color: Colors.white),
                                    /*Column(
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
                                    ),*/
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 500,
                                  child: buildInfoRow(
                                      title: 'Cliente',
                                      value: widget.intervento.cliente?.denominazione ?? 'N/A', context: context),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _showClientiDialog();
                                  },
                                )
                              ],
                            ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     SizedBox(
                            //       width: 500,
                            //       child: buildInfoRow(
                            //           title: 'Destinazione',
                            //           value: widget.intervento.destinazione?.denominazione ?? 'N/A', context: context),
                            //     ),
                            //     IconButton(
                            //       icon: Icon(Icons.edit),
                            //       onPressed: () {
                            //         _showClientiDialog();
                            //       },
                            //     )
                            //   ],
                            // ),
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
                      SizedBox(width: 35),
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
                            Row(
                              children: [
                                SizedBox(
                                  width: 500,
                                  child: buildInfoRow(
                                      title: 'Utente incaricato',
                                      value: '${widget.intervento.utente?.nomeCompleto() ?? 'Non assegnato'}',
                                      context: context
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: (){
                                    _showUtentiDialog();
                                  },
                                )
                              ],
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
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                  children:[
                                    SizedBox(
                                      width: 500,
                                      child: buildInfoRow(
                                          title: 'Concluso',
                                          value: booleanToString(widget.intervento.concluso ?? false),
                                          context: context
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        // Mostra il dialogo quando l'utente tocca l'icona
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            bool isConcluso = widget.intervento.concluso ?? false;

                                            return AlertDialog(
                                              title: Text(isConcluso
                                                  ? 'L\'intervento non è concluso?'
                                                  : 'L\'intervento è concluso?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      widget.intervento.concluso = !isConcluso;
                                                    });
                                                    Navigator.of(context).pop(); // Chiude il dialogo
                                                  },
                                                  child: Text(isConcluso ? 'Non concluso' : 'Concluso'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop(); // Chiude il dialogo senza fare nulla
                                                  },
                                                  child: Text('Annulla'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ]
                                ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children:[
                                  SizedBox(
                                    width: 500,
                                    child: buildInfoRow(
                                        title: 'Saldato',
                                        value: booleanToString(widget.intervento.saldato ?? false),
                                        context: context
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          bool isSaldato = widget.intervento.saldato ?? false;

                                          return AlertDialog(
                                            title: Text(isSaldato
                                                ? 'L\'intervento non è stato saldato?'
                                                : 'L\'intervento è stato saldato?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    widget.intervento.saldato = !isSaldato;
                                                  });
                                                  Navigator.of(context).pop(); // Chiude il dialogo
                                                },
                                                child: Text(isSaldato ? 'Non saldato' : 'Saldato'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop(); // Chiude il dialogo senza fare nulla
                                                },
                                                child: Text('Annulla'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ]
                            ),
                            SizedBox(
                              width: 500,
                              child: buildInfoRow(
                                  title: "Posizione gps",
                                  context: context,
                                  value : widget.intervento.posizione_gps ?? "N/A"
                              ),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 500,
                                  child: buildInfoRow(
                                      title: 'Note',
                                      value: widget.intervento.note ?? 'N/A',
                                      context: context
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      modificaNotaVisibile = !modificaNotaVisibile;
                                    });
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                            if(modificaNotaVisibile)
                              SizedBox(
                                  width: 500,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 300,
                                        child: TextFormField(
                                          maxLines: null,
                                          controller: noteController,
                                          decoration: InputDecoration(
                                            labelText: 'Nota',
                                            hintText: 'Aggiungi una nota',
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
                                          heroTag: "Tag12",
                                          onPressed: () {
                                            setState(() {
                                              widget.intervento.note = noteController.text;
                                            });
                                          },
                                          backgroundColor: Colors.red,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Flexible( // Permette al testo di adattarsi alla dimensione del FloatingActionButton
                                                child: Text(
                                                  'Modifica Nota'.toUpperCase(),
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
                            SizedBox(
                              height: 162,
                            )
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
                                  if (fasiRiparazione.isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Fasi riparazione:',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        ...fasiRiparazione.map((fase) => SizedBox(
                                            width: 370,
                                            child:ListTile(
                                              title: Text('${DateFormat('dd/MM/yyyy HH:mm').format(fase.data!)},${fase.utente?.nome} ${fase.utente?.cognome}'),
                                              subtitle: Text('${fase.descrizione}'),
                                            )
                                          )
                                            ),
                                      ],
                                    ),
                                  if(fasiRiparazione.isEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 14,),
                                        //Text('Nessuna nota relativa all\'intervento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                                      ],
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
                        ],
                      ),
                      //Inizio container foto
                    ],
                  ),
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
                                'Codice Danea: ${relazione.prodotto?.codice_danea ?? "Codice non disponibile"} - Prezzo fornitore: $prezzoFornitore - Quantità: ${relazione.quantita?.toStringAsFixed(2)}',
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
                  minLines: 3,
                  maxLines: 3,
                  style: TextStyle(fontSize: 13),
                  controller: rapportinoController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),// Spazio tra il campo di testo e l'icona
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
      width: 280,
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
                                  content: Text(value), // Mostra il valore completo qui
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

  void updatePriorita(Priorita newPriorita) {
    setState(() {
      widget.intervento.priorita = newPriorita;
    });
  }

  Widget buildInfoPrioritaRow({required String title, required Priorita value, BuildContext? context}) {
    Color? prioritaColor;
    switch (value) {
      case Priorita.BASSA :
        prioritaColor = Colors.lightGreen;
        break;
      case Priorita.MEDIA :
        prioritaColor = Colors.yellow; // grigio chiaro
        break;
      case Priorita.ALTA:
        prioritaColor = Colors.orange; // giallo chiaro
        break;
      case Priorita.URGENTE:
        prioritaColor = Colors.red; // azzurro chiaro
        break;
      default:
        prioritaColor = Colors.blueGrey[200];
    }
    // Verifica se il valore supera i 25 caratteri
    //bool isValueTooLong = value.length > 25;
    //String displayedValue = isValueTooLong ? value.substring(0, 25) + "..." : value;

    return SizedBox(
      width: 280,
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
                      GestureDetector(
                      onTap: () {
                  // Funzione per aprire il dialog
                  showDialog(
                  context: context!,
                  builder: (BuildContext context) {
                    return
                      AlertDialog(
                        title: Text("Seleziona Priorità"),
                        content: DropdownButton<Priorita>(
                          value: value,
                          onChanged: (Priorita? newValue) {
                            if (newValue != null) {
                              updatePriorita(newValue); // Aggiorna la priorità nel widget genitore
                              Navigator.of(context).pop(); // Chiudi il dialog
                            }
                            setState(() {
                              value = newValue!;
                              widget.intervento.priorita = value; // Aggiorna l'oggetto
                            });
                          },
                          items: Priorita.values.map((Priorita priorita) {
                            return DropdownMenuItem<Priorita>(
                              value: priorita,
                              child: Text(priorita.toString().split('.').last.toUpperCase()),
                            );
                          }).toList(),
                        ),
                        actions: [
                          TextButton(
                            child: Text("Chiudi"),
                            onPressed: () {
                              Navigator.of(context).pop(); // Chiudi il dialog
                            },
                          ),
                        ],
                      );

                  },
                );
      },
        child:
        Container(

                        height: 25,
                        width: 25,
                        color: prioritaColor,
                      )),

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

  Future<void> saveModificheMerce() async{
    
  }

  Future<void> saveModifiche() async {
    // If _selectedTimeAppuntamento is not null, convert TimeOfDay to DateTime, else use widget.intervento.orario_appuntamento
    DateTime? orario;
    if (_selectedTimeAppuntamento != null) {
      final now = DateTime.now();
      orario = DateTime(now.year, now.month, now.day, _selectedTimeAppuntamento!.hour, _selectedTimeAppuntamento!.minute);
    } else {
      orario = widget.intervento.orario_appuntamento;
    }

    // Parse importo from controller, or fallback to existing value
    double? importo = importoController.text.isNotEmpty
        ? double.tryParse(importoController.text)
        : widget.intervento.importo_intervento;

    // Parse descrizione from controller, or fallback to existing value
    String? descrizione = descrizioneController.text.isNotEmpty
        ? descrizioneController.text
        : widget.intervento.descrizione;

    ClienteModel? cliente = selectedCliente != null ? selectedCliente : widget.intervento.cliente;
    DestinazioneModel? destinazione = selectedDestinazione != null ? selectedDestinazione : widget.intervento.destinazione;

    try {
      // Making HTTP request to update the 'intervento
      final response = await http.post(
        Uri.parse('$ipaddress/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.id,
          'numerazione_danea' : widget.intervento.numerazione_danea,
          'priorita' : widget.intervento.priorita.toString().split('.').last,
          'data_apertura_intervento': widget.intervento.data_apertura_intervento?.toIso8601String(),
          'data': widget.intervento.data?.toIso8601String(),
          'orario_appuntamento': orario?.toIso8601String(),  // Ensured correct DateTime
          'posizione_gps': widget.intervento.posizione_gps,
          'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
          'orario_fine': widget.intervento.orario_fine?.toIso8601String(),
          'descrizione': descrizione,  // Using potentially updated descrizione
          'importo_intervento': importo,  // Using potentially updated importo
          'prezzo_ivato': widget.intervento.prezzo_ivato,
          'iva' : widget.intervento.iva,
          'acconto': widget.intervento.acconto,
          'assegnato': widget.intervento.assegnato,
          'accettato_da_tecnico' : widget.intervento.accettato_da_tecnico,
          'conclusione_parziale': widget.intervento.conclusione_parziale,
          'concluso': widget.intervento.concluso,
          'saldato': widget.intervento.saldato,
          'saldato_da_tecnico': widget.intervento.saldato_da_tecnico,
          'note': widget.intervento.note,
          'relazione_tecnico': rapportinoController.text,
          'firma_cliente': widget.intervento.firma_cliente,
          'utente': widget.intervento.utente?.toMap(),
          'cliente': cliente?.toMap(),
          'veicolo': widget.intervento.veicolo?.toMap(),
          'merce': widget.intervento.merce?.toMap(),
          'tipologia': widget.intervento.tipologia?.toMap(),
          'categoria': widget.intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
          'destinazione': destinazione?.toMap(),
          'gruppo': widget.intervento.gruppo?.toMap(),
        }),
      );

      // Handle response success/failure
      if (response.statusCode == 201) {
        print('Modifica effettuata');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Intervento modificato con successo!'),
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DettaglioInterventoPage(intervento: InterventoModel.fromJson(jsonDecode(response.body)))),
        );
      } else {
        print('Errore nella richiesta: ${response.statusCode}');
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
            'numerazione_danea' : widget.intervento.numerazione_danea,
            'priorita' : widget.intervento.priorita.toString().split('.').last,
            'data_apertura_intervento' : widget.intervento.data_apertura_intervento?.toIso8601String(),
            'data': widget.intervento.data?.toIso8601String(),
            'orario_appuntamento' : widget.intervento.orario_appuntamento?.toIso8601String(),
            'posizione_gps' : widget.intervento.posizione_gps,
            'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
            'orario_fine': widget.intervento.orario_fine?.toIso8601String(),
            'descrizione': widget.intervento.descrizione,
            'importo_intervento': widget.intervento.importo_intervento,
            'prezzo_ivato' : widget.intervento.prezzo_ivato,
            'iva' : widget.intervento.iva,
            'acconto' : widget.intervento.acconto,
            'assegnato': true,
            'accettato_da_tecnico' : widget.intervento.accettato_da_tecnico,
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
              print('sono quiiiiii');
              final response = await http.post(
                Uri.parse('$ipaddress/api/relazioneUtentiInterventi'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'utente' : utente?.toMap(),
                  'intervento' : widget.intervento.toMap(),
                }),
              );
              print(response.body.toString());
              print(response.statusCode);
            } catch(e) {
              print('Errore durante il salvataggio della relazione: $e');
            }
          }
        }
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

