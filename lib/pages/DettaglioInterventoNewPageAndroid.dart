import 'dart:convert';
import 'dart:typed_data';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:fema_crm/databaseHandler/DbHelper.dart';
import 'package:fema_crm/model/DDTModel.dart';
import 'package:fema_crm/model/DestinazioneModel.dart';
import 'package:fema_crm/model/NotaTecnicoModel.dart';
import 'package:fema_crm/model/RelazioneDdtProdottiModel.dart';
import 'package:fema_crm/model/RelazioneProdottiInterventoModel.dart';
import 'package:fema_crm/model/RelazioneUtentiInterventiModel.dart';
import 'package:fema_crm/pages/TableInterventiPage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../model/ClienteModel.dart';
import '../model/CommissioneModel.dart';
import '../model/FaseRiparazioneModel.dart';
import '../model/InterventoModel.dart';
import '../model/TipologiaInterventoModel.dart';
import '../model/TipologiaPagamento.dart';
import '../model/UtenteModel.dart';
import '../model/VeicoloModel.dart';
import 'AggiuntaManualeProdottiDDTPage.dart';
import 'CertificazioniPage.dart';
import 'GalleriaFotoInterventoPage.dart';
import 'PDFInterventoPage.dart';

class DettaglioInterventoNewPageAndroid extends StatefulWidget{
  final InterventoModel intervento;
  final UtenteModel utente;

  DettaglioInterventoNewPageAndroid({required this.intervento, required this.utente});

  @override
  _DettaglioInterventoNewPageAndoridState createState() => _DettaglioInterventoNewPageAndoridState();
}

class _DettaglioInterventoNewPageAndoridState extends State<DettaglioInterventoNewPageAndroid>{
  late InterventoModel intervento;
  late Future<List<UtenteModel>> _utentiFuture;
  List<TipologiaInterventoModel> tipologieIntervento =[];
  TipologiaInterventoModel? selectedTipologiaIntervento;
  List<TipologiaPagamentoModel> tipologiePagamento = [];
  TipologiaPagamentoModel? selectedTipologia;
  List<RelazioneUtentiInterventiModel> otherUtenti = [];
  List<RelazioneUtentiInterventiModel> relazioniNuove = [];
  List<NotaTecnicoModel> allNote = [];
  List<UtenteModel> allUtenti = [];
  List<CommissioneModel> allCommissioni = [];
  List<VeicoloModel> allVeicoli = [];
  VeicoloModel? selectedVeicolo;
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
  bool modificaImportoMerceVisibile = false;
  bool modificaDescrizioneVisible = false;
  bool modificaImportoVisibile = false;
  bool modificaNotaVisibile = false;
  bool modificaTitoloVisible = false;
  bool modificaSaldoTecnicoVisibile = false;
  bool modificaArticoloVisibile = false;
  bool modificaAccessoriVisibile = false;
  bool modificaDifettoVisibile = false;
  bool modificaPasswordVisibile = false;
  bool modificaDatiVisibile = false;
  bool modificaDiagnosiVisibile = false;
  bool modificaRisoluzioneVisibile = false;
  final TextEditingController importoMerceController = TextEditingController();
  final TextEditingController datiController = TextEditingController();
  final TextEditingController risoluzioneController = TextEditingController();
  final TextEditingController diagnosiController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController difettoController = TextEditingController();
  final TextEditingController accessoriController = TextEditingController();
  final TextEditingController articoloController = TextEditingController();
  final TextEditingController descrizioneController = TextEditingController();
  final TextEditingController _importoController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController titoloController = TextEditingController();
  final TextEditingController saldoController = TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';
  Future<List<Uint8List>>? _futureImages;
  DbHelper? dbHelper;
  List<XFile> pickedImages = [];
  String selectedSection = 'Informazioni Generali';
  String hoveredSection = '';
  File? selectedFile;
  List<String> pdfFiles = [];
  String? errorMessage;
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    intervento = widget.intervento;
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
    if(widget.intervento.merce != null){
      allFasi.then((fasi) {
        // Separiamo le fasi concluse e non concluse
        final fasiNonConcluse = fasi.where((fase) => fase.conclusione != true).toList();
        final fasiConcluse = fasi.where((fase) => fase.conclusione == true).toList();
        // Uniamo le fasi in un'unica lista con quelle concluse per ultime
        setState(() {
          fasiRiparazione = [...fasiNonConcluse, ...fasiConcluse];
          if(intervento.merce != null){
            rapportinoController.text = intervento.relazione_tecnico != null ? intervento.relazione_tecnico! + " " + fasiRiparazione.map((fase) {
              return '${DateFormat('dd/MM/yyyy HH:mm').format(fase.data!)}, ${fase.utente?.nomeCompleto() ?? ''} - ${fase.descrizione ?? ''}';
            }).join('\n') : fasiRiparazione.map((fase) {
              return '${DateFormat('dd/MM/yyyy HH:mm').format(fase.data!)}, ${fase.utente?.nomeCompleto() ?? ''} - ${fase.descrizione ?? ''}';
            }).join('\n');
          }
        });
      });
    }
    getCommissioni();
    getAllTipologieIntervento();
    getProdottiByIntervento();
    getRelazioni();
    getAllVeicoli();
    getNoteByIntervento();
    getProdottiDdt();
    _fetchUtentiAttivi();
    getMetodiPagamento();
    fetchPdfFiles();
    _futureImages = fetchImages();
    rapportinoController.text = (widget.intervento.relazione_tecnico != null ? widget.intervento.relazione_tecnico : '//')!;
    titoloController.text = widget.intervento.titolo != null ? widget.intervento.titolo! : '//';
    descrizioneController.text = widget.intervento.descrizione != null ? widget.intervento.descrizione! : '//';
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void modificaTitolo() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddressProva2/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.id?.toString(),
          'attivo' : widget.intervento.attivo,
          'visualizzato' : widget.intervento.visualizzato,
          'titolo' : titoloController.text.toUpperCase(),
          'numerazione_danea' : widget.intervento.numerazione_danea,
          'priorita' : widget.intervento.priorita.toString().split('.').last,
          'data_apertura_intervento' : widget.intervento.data_apertura_intervento?.toIso8601String(),
          'data': widget.intervento.data?.toIso8601String(),
          'orario_appuntamento' : widget.intervento.orario_appuntamento?.toIso8601String(),
          'posizione_gps' : widget.intervento.posizione_gps,
          'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
          'orario_fine': widget.intervento.orario_fine?.toIso8601String(),
          'descrizione': widget.intervento.descrizione,
          'utente_importo' : widget.intervento.utente_importo,
          'importo_intervento': widget.intervento.importo_intervento,
          'saldo_tecnico' : widget.intervento.saldo_tecnico,
          'prezzo_ivato' : widget.intervento.prezzo_ivato,
          'iva' : widget.intervento.iva,
          'acconto' : widget.intervento.acconto,
          'assegnato': widget.intervento.assegnato,
          'accettato_da_tecnico' : widget.intervento.accettato_da_tecnico,
          'annullato' : widget.intervento.annullato,
          'conclusione_parziale' : widget.intervento.conclusione_parziale,
          'concluso': widget.intervento.concluso,
          'saldato': widget.intervento.saldato,
          'saldato_da_tecnico' : widget.intervento.saldato_da_tecnico,
          'note': widget.intervento.note,
          'relazione_tecnico' : widget.intervento.relazione_tecnico,
          'firma_cliente': widget.intervento.firma_cliente,
          'utente_apertura' : widget.intervento.utente_apertura?.toMap(),
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
            content: Text('Titolo modificato con successo!'),
          ),
        );
        setState(() {
          widget.intervento.titolo = titoloController.text;
        });
      }
    } catch(e){
      print('Qualcosa non va: $e');
    }
  }

  Future<List<String>> fetchPdfFiles() async {
    try {
      print('Inizio richiesta al server per intervento ID: ${widget.intervento.id}'); // Debug

      final response = await http.get(Uri.parse('$ipaddressProva2/pdfu/intervento/${widget.intervento.id.toString()}'));
      print('Risposta ricevuta con status code: ${response.statusCode}'); // Debug

      switch (response.statusCode) {
        case 200:
          final List<dynamic> files = jsonDecode(response.body);
          print('File trovati: $files'); // Debug
          return files.cast<String>();

        case 204:
          print('Nessun file trovato per l\'intervento con ID ${widget.intervento.id}.'); // Debug
          return [];

        case 404:
          throw Exception('Directory non trovata per intervento ID ${widget.intervento.id}.');

        default:
          throw Exception('Errore inatteso: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Errore durante la connessione al server: $e'); // Debug
      throw Exception('Errore durante la connessione al server: $e');
    }
  }

  Future<List<Uint8List>> fetchImages() async {
    final url = '$ipaddressProva2/api/immagine/intervento/${int.parse(widget.intervento.id.toString())}/images';
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

  Future<void> _selectDate3(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        widget.intervento.merce?.data_consegna = picked;
        selectedDate = picked;
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

  Future<http.Response?> getDDTByIntervento() async{
    try{
      final response = await http.get(Uri.parse('$ipaddressProva2/api/ddt/intervento/${widget.intervento.id}'));
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
          final response = await http.get(Uri.parse('$ipaddressProva2/api/relazioneDDTProdotto/ddt/${ddt.id}'));
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

  Future<void> getMetodiPagamento() async{
    try{
      final response = await http.get(Uri.parse('$ipaddressProva2/api/tipologiapagamento'));
      var responseData = json.decode(response.body);
      if(response.statusCode == 200){
        List<TipologiaPagamentoModel> tipologie = [];
        for(var item in responseData){
          tipologie.add(TipologiaPagamentoModel.fromJson(item));
        }
        setState(() {
          tipologiePagamento = tipologie;
        });
      }
    } catch(e){
      print('Errore: $e');
    }
  }

  Future<void> getAllTipologieIntervento() async{
    try{
      final response = await http.get(Uri.parse('$ipaddressProva2/api/tipologiaIntervento'));
      var responseData = json.decode(response.body);
      if(response.statusCode == 200){
        List<TipologiaInterventoModel> tipologie = [];
        for(var item in responseData){
          tipologie.add(TipologiaInterventoModel.fromJson(item));
        }
        setState(() {
          tipologieIntervento = tipologie;
        });
      }
    } catch(e){
      print('Error fetching tipologie: $e');
    }
  }

  Future<void> getAllVeicoli() async{
    try{
      final response = await http.get(Uri.parse('$ipaddressProva2/api/veicolo'));
      var responseData = json.decode(response.body);
      if(response.statusCode == 200){
        List<VeicoloModel> veicoli = [];
        for(var item in responseData){
          veicoli.add(VeicoloModel.fromJson(item));
        }
        setState(() {
          allVeicoli = veicoli;
        });
      }
    } catch(e){
      print('Errore fetching veicoli: $e');
    }
  }

  Future<void> getCommissioni()async{
    try{
      final response = await http.get(Uri.parse('$ipaddressProva2/api/commissione/intervento/${widget.intervento.id}'));
      var responseData = json.decode(response.body);
      if(response.statusCode == 200){
        List<CommissioneModel> commissioni = [];
        for(var item in responseData){
          commissioni.add(CommissioneModel.fromJson(item));
        }
        setState(() {
          allCommissioni = commissioni;
        });
      }
    } catch(e) {
      print('errore fetching commissioni $e');
    }
  }

  Future<void> getProdottiByIntervento() async{
    try{
      final response = await http.get(Uri.parse('$ipaddressProva2/api/relazioneProdottoIntervento/intervento/${widget.intervento.id}'));
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
      final response = await http.get(Uri.parse('$ipaddressProva2/api/noteTecnico/intervento/${widget.intervento.id}'));
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
      final response = await http.get(Uri.parse('$ipaddressProva2/api/relazioneUtentiInterventi/intervento/${widget.intervento.id}'));
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
      final response = await http.get(Uri.parse('$ipaddressProva2/api/utente/attivo'));
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

  Future<void> showTipologiaDialog(BuildContext context, List<TipologiaInterventoModel> allTipologieInt, TipologiaInterventoModel? selectedTipologia) async{
    TipologiaInterventoModel? tempSelectedTipologia = selectedTipologia;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState){
              return AlertDialog(
                title: Text('Selezionare la tipologia di intervento'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: allTipologieInt.map((tipologia){
                      return CheckboxListTile(
                        title: Text(tipologia.descrizione!),
                        value: tempSelectedTipologia == tipologia,
                        onChanged: (bool? value) {
                          setState(() {
                            tempSelectedTipologia = value! ? tipologia : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Annulla'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState((){
                        selectedTipologia = tempSelectedTipologia;
                        intervento.tipologia = selectedTipologia;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text('Conferma'),
                  ),
                ],
              );
            },
          );
        }
    );
  }

  void modificaDescrizione() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddressProva2/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.id?.toString(),
          'attivo' : widget.intervento.attivo,
          'visualizzato' : widget.intervento.visualizzato,
          'titolo' : widget.intervento.titolo,
          'numerazione_danea' : widget.intervento.numerazione_danea,
          'priorita' : widget.intervento.priorita.toString().split('.').last,
          'data_apertura_intervento' : widget.intervento.data_apertura_intervento?.toIso8601String(),
          'data': widget.intervento.data?.toIso8601String(),
          'orario_appuntamento' : widget.intervento.orario_appuntamento?.toIso8601String(),
          'posizione_gps' : widget.intervento.posizione_gps,
          'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
          'orario_fine': widget.intervento.orario_fine?.toIso8601String(),
          'descrizione': descrizioneController.text.toUpperCase(),
          'utente_importo' : intervento.utente_importo,
          'importo_intervento': widget.intervento.importo_intervento,
          'saldo_tecnico' : widget.intervento.saldo_tecnico,
          'prezzo_ivato' : widget.intervento.prezzo_ivato,
          'iva' : widget.intervento.iva,
          'acconto' : widget.intervento.acconto,
          'assegnato': widget.intervento.assegnato,
          'accettato_da_tecnico' : widget.intervento.accettato_da_tecnico,
          'annullato' : widget.intervento.annullato,
          'conclusione_parziale' : widget.intervento.conclusione_parziale,
          'concluso': widget.intervento.concluso,
          'saldato': widget.intervento.saldato,
          'saldato_da_tecnico' : widget.intervento.saldato_da_tecnico,
          'note': widget.intervento.note,
          'relazione_tecnico' : widget.intervento.relazione_tecnico,
          'firma_cliente': widget.intervento.firma_cliente,
          'utente_apertura' : widget.intervento.utente_apertura?.toMap(),
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

  String getPrezzoIvato(InterventoModel intervento) {
    if (intervento.importo_intervento != null && intervento.iva != null) {
      double prezzoIvato = intervento.importo_intervento! * (1 + (intervento.iva! / 100));
      return "${prezzoIvato.toStringAsFixed(2)}€ (${intervento.iva}%)";
    }
    return '';
  }

  void riabilitaIntervento() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddressProva2/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.id?.toString(),
          'attivo' : widget.intervento.attivo,
          'visualizzato' : widget.intervento.visualizzato,
          'titolo' : widget.intervento.titolo,
          'numerazione_danea' : widget.intervento.numerazione_danea,
          'priorita' : widget.intervento.priorita.toString().split('.').last,
          'data_apertura_intervento' : widget.intervento.data_apertura_intervento?.toIso8601String(),
          'data': widget.intervento.data?.toIso8601String(),
          'orario_appuntamento' : widget.intervento.orario_appuntamento?.toIso8601String(),
          'posizione_gps' : widget.intervento.posizione_gps,
          'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
          'orario_fine': widget.intervento.orario_fine?.toIso8601String(),
          'descrizione': widget.intervento.descrizione,
          'utente_importo' : intervento.utente_importo,
          'importo_intervento': widget.intervento.importo_intervento,
          'saldo_tecnico' : widget.intervento.saldo_tecnico,
          'prezzo_ivato' : widget.intervento.prezzo_ivato,
          'iva' : widget.intervento.iva,
          'acconto' : widget.intervento.acconto,
          'assegnato': widget.intervento.assegnato,
          'accettato_da_tecnico' : widget.intervento.accettato_da_tecnico,
          'annullato' : false,
          'conclusione_parziale' : widget.intervento.conclusione_parziale,
          'concluso': widget.intervento.concluso,
          'saldato': widget.intervento.saldato,
          'saldato_da_tecnico' : widget.intervento.saldato_da_tecnico,
          'note': widget.intervento.note,
          'relazione_tecnico' : widget.intervento.relazione_tecnico,
          'firma_cliente': widget.intervento.firma_cliente,
          'utente_apertura' : widget.intervento.utente_apertura?.toMap(),
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
            content: Text('Intervento annullato con successo!'),
          ),
        );
      }
    } catch(e){
      print('Qualcosa non va: $e');
    }
  }

  Widget buildInfoRow({required String title, required String value, BuildContext? context}) {
    bool isValueTooLong = value.length > 8;
    String displayedValue = isValueTooLong ? value.substring(0, 8) + "..." : value;
    return SizedBox(
      width: 310,
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

  void openImportoDialog(BuildContext context, TextEditingController importoController) {
    bool hasIva = false;
    bool ventidue = false;
    bool dieci = false;
    bool quattro = false;
    int selectedIva = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Inserisci un importo'),
              actions: <Widget>[
                TextFormField(
                  controller: importoController,
                  decoration: InputDecoration(
                    labelText: 'Importo',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // consente solo numeri e fino a 2 decimali
                  ],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: !hasIva,
                      onChanged: (bool? value) {
                        setState(() {
                          hasIva = !value!; // Se NO IVA è selezionato, hasIva è false
                          selectedIva = 0; // Nessuna aliquota selezionata per NO IVA
                          ventidue = false;
                          dieci = false;
                          quattro = false;
                        });
                      },
                    ),
                    Text('IVA INCLUSA'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: hasIva,
                      onChanged: (bool? value) {
                        setState(() {
                          hasIva = value!; // Se AGGIUNGI IVA è selezionato, hasIva è true
                          if (!hasIva) {
                            selectedIva = 0; // Reset dell'aliquota IVA se NO IVA è selezionato
                          }
                        });
                      },
                    ),
                    Text('AGGIUNGI IVA'),
                  ],
                ),
                if (hasIva) // Mostra la selezione solo se hasIva è true
                  Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: ventidue,
                              onChanged: (bool? value) {
                                setState(() {
                                  ventidue = value!;
                                  dieci = false;
                                  quattro = false;
                                  selectedIva = 22; // Setta l'IVA a 22%
                                  print('IVA selezionata: $selectedIva');
                                });
                              },
                            ),
                            Text(' 22%'),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: dieci,
                              onChanged: (bool? value) {
                                setState(() {
                                  dieci = value!;
                                  ventidue = false;
                                  quattro = false;
                                  selectedIva = 10; // Setta l'IVA a 10%
                                  print('IVA selezionata: $selectedIva');
                                });
                              },
                            ),
                            Text(' 10%'),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: quattro,
                              onChanged: (bool? value) {
                                setState(() {
                                  quattro = value!;
                                  ventidue = false;
                                  dieci = false;
                                  selectedIva = 4; // Setta l'IVA a 4%
                                  print('IVA selezionata: $selectedIva');
                                });
                              },
                            ),
                            Text(' 4%'),
                          ],
                        ),
                      ],
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    print('IVA passata: $selectedIva'); // Stampa l'IVA prima di chiamare saveImporto
                    saveImporto(hasIva, selectedIva, importoController.text);
                  },
                  child: Text('Salva importo'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> saveImporto(bool prezzoIvato, int iva, String importo) async {
    try {
      print(' IVA : ${iva}');
      final response = await http.post(
        Uri.parse('$ipaddressProva2/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.id,
          'attivo' : widget.intervento.attivo,
          'visualizzato' : widget.intervento.visualizzato,
          'titolo' : widget.intervento.titolo,
          'numerazione_danea' : widget.intervento.numerazione_danea,
          'data_apertura_intervento' : widget.intervento.data_apertura_intervento?.toIso8601String(),
          'data': widget.intervento.data?.toIso8601String(),
          'orario_appuntamento' : widget.intervento.orario_appuntamento?.toIso8601String(),
          'posizione_gps' : widget.intervento.posizione_gps,
          'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
          'orario_fine': widget.intervento.orario_fine?.toIso8601String(),
          'descrizione': widget.intervento.descrizione,
          'utente_importo' : widget.utente.nomeCompleto(),
          'importo_intervento': double.tryParse(importo),
          'saldo_tecnico' : widget.intervento.saldo_tecnico,
          'prezzo_ivato' : prezzoIvato,
          'iva' : iva, // Passa l'IVA selezionata come numero intero
          'assegnato': widget.intervento.assegnato,
          'accettato_da_tecnico' : widget.intervento.accettato_da_tecnico,
          'annullato' : widget.intervento.annullato,
          'conclusione_parziale': widget.intervento.conclusione_parziale,
          'concluso': widget.intervento.concluso,
          'saldato': widget.intervento.saldato,
          'saldato_da_tecnico' : widget.intervento.saldato_da_tecnico,
          'note': widget.intervento.note,
          'relazione_tecnico' : widget.intervento.relazione_tecnico,
          'firma_cliente': widget.intervento.firma_cliente,
          'utente_apertura' : widget.intervento.utente_apertura?.toMap(),
          'utente': widget.intervento.utente?.toMap(),
          'cliente': widget.intervento.cliente?.toMap(),
          'veicolo': widget.intervento.veicolo?.toMap(),
          'merce': widget.intervento.merce?.toMap(),
          'tipologia': widget.intervento.tipologia?.toMap(),
          'categoria': widget.intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': widget.intervento.tipologia_pagamento?.toMap(),
          'destinazione': widget.intervento.destinazione?.toMap(),
          'gruppo' : widget.intervento.gruppo?.toMap()
        }),
      );
      if (response.statusCode == 201) {
        print(response.body.toString());
        print('EVVAIIIIIIII');
        prezzoIvato = false;
        setState(() {
          widget.intervento.importo_intervento = double.tryParse(importo);
          widget.intervento.prezzo_ivato = prezzoIvato;
          widget.intervento.iva = iva;
        });
      }
    } catch (e) {
      print('Errore durante il salvataggio del intervento: $e');
    }
  }

  Widget buildInfoRowUtente({required String title, required String value, required bool visualizzato, BuildContext? context}) {
    bool isValueTooLong = value.length > 13;
    String displayedValue = isValueTooLong ? value.substring(0, 13) + "..." : value;
    return SizedBox(
      width: 200,
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
                          fontWeight: FontWeight.bold,
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
                      value != 'Non assegnato' ? visualizzato ? Tooltip(
                          message: 'L\'UTENTE HA PRESO VISIONE',
                          child: Icon(Icons.check_circle, color: Colors.green, size: 20, ))
                          : Tooltip(
                          message: 'L\'UTENTE NON HA ANCORA PRESO VISIONE',
                          child: Icon(Icons.check_circle_outline, color: Colors.grey, size: 20))
                          : Text('')],
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

  void annullaIntervento() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddressProva2/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.intervento.id?.toString(),
          'attivo' : widget.intervento.attivo,
          'visualizzato' : widget.intervento.visualizzato,
          'titolo' : widget.intervento.titolo,
          'numerazione_danea' : widget.intervento.numerazione_danea,
          'priorita' : widget.intervento.priorita.toString().split('.').last,
          'data_apertura_intervento' : widget.intervento.data_apertura_intervento?.toIso8601String(),
          'data': widget.intervento.data?.toIso8601String(),
          'orario_appuntamento' : widget.intervento.orario_appuntamento?.toIso8601String(),
          'posizione_gps' : widget.intervento.posizione_gps,
          'orario_inizio': widget.intervento.orario_inizio?.toIso8601String(),
          'orario_fine': widget.intervento.orario_fine?.toIso8601String(),
          'descrizione': widget.intervento.descrizione,
          'utente_importo' : intervento.utente_importo,
          'importo_intervento': widget.intervento.importo_intervento,
          'saldo_tecnico' : widget.intervento.saldo_tecnico,
          'prezzo_ivato' : widget.intervento.prezzo_ivato,
          'iva' : widget.intervento.iva,
          'acconto' : widget.intervento.acconto,
          'assegnato': false,
          'accettato_da_tecnico' : widget.intervento.accettato_da_tecnico,
          'annullato' : true,
          'conclusione_parziale' : widget.intervento.conclusione_parziale,
          'concluso': widget.intervento.concluso,
          'saldato': widget.intervento.saldato,
          'saldato_da_tecnico' : widget.intervento.saldato_da_tecnico,
          'note': widget.intervento.note,
          'relazione_tecnico' : widget.intervento.relazione_tecnico,
          'firma_cliente': widget.intervento.firma_cliente,
          'utente_apertura' : widget.intervento.utente_apertura?.toMap(),
          'utente': null,
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
        if (otherUtenti.isNotEmpty) {
          for (var relaz in otherUtenti) {
            try {
              print('Eliminazione vecchie relazioni');
              final response = await http.delete(
                Uri.parse('$ipaddressProva2/api/relazioneUtentiInterventi/' + relaz.id.toString()),
                headers: {'Content-Type': 'application/json'},
              );
              print(response.body.toString());
              print(response.statusCode);
            } catch (e) {
              print('Errore durante l\'eliminazione della relazione: $e');
            }
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Intervento annullato con successo!'),
          ),
        );
      }
    } catch(e){
      print('Qualcosa non va: $e');
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('${intervento.titolo}', style: TextStyle(color: Colors.white)),
      ),
      // drawer: Drawer(
      //   backgroundColor: Colors.grey[700],
      // ),
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: <Widget>[
            //Info generali intervento e cliente
            Container(
              child: Padding(
                padding: EdgeInsets.all(7),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informazioni Generali',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 12.0),
                      Row(
                        children: [
                          buildInfoRow(
                              title: 'Titolo',
                              value: widget.intervento.titolo ?? '//',
                              context: context
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                modificaTitoloVisible = !modificaTitoloVisible;
                              });
                            },
                            child: Icon(
                              Icons.edit,
                              color: Colors.black,
                            ),
                          )
                        ],
                      ),
                      if(modificaTitoloVisible)
                        SizedBox(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 300,
                                  child: TextFormField(
                                    maxLines: null,
                                    controller: titoloController,
                                    decoration: InputDecoration(
                                      labelText: 'Titolo',
                                      hintText: 'Aggiungi un titolo',
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
                                    heroTag: "Tag4",
                                    onPressed: () {
                                      if(titoloController.text.isNotEmpty){
                                        modificaTitolo();
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Non è possibile salvare un titolo vuoto!'),
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
                                            'Modifica Titolo'.toUpperCase(),
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
                        height: 12,
                      ),
                      Row(
                        children: [
                          buildInfoRow(
                              title: 'Descrizione',
                              value: widget.intervento.descrizione!,
                              context: context
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
                      SizedBox(height: 12),
                      if(modificaDescrizioneVisible)
                        SizedBox(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                      SizedBox(height : 12),
                      Row(
                        children: [
                          buildInfoRow(
                              title: 'Note',
                              value: widget.intervento.note ?? 'N/A',
                              context: context
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                      SizedBox(height : 10),
                      Row(
                        children: [
                          buildInfoRow(
                              title: "tipologia",
                              value: intervento.tipologia!.descrizione!
                          ),
                          IconButton(
                            icon : Icon(Icons.edit),
                            onPressed: (){
                              showTipologiaDialog(context, tipologieIntervento, selectedTipologiaIntervento);
                            },
                          )
                        ],
                      ),
                      SizedBox(height : 10),
                      buildInfoRow(
                          title: 'Apertura',
                          value: widget.intervento.utente_apertura?.nomeCompleto() ?? 'N/A',
                          context: context
                      ),
                      SizedBox(height: 20),
                      Text("Informazioni Cliente", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                      buildInfoRow(
                          title: 'Cliente',
                          value: widget.intervento.cliente?.denominazione ?? 'N/A',
                          context: context
                      ),
                      buildInfoRow(
                          title: 'ID Danea cliente',
                          value: widget.intervento.cliente?.cod_danea ?? 'N/A',
                          context: context
                      ),
                      buildInfoRow(
                          title: 'Città destinazione',
                          value: widget.intervento.destinazione?.citta ?? 'N/A',
                          context: context
                      ),
                      buildInfoRow(
                          title: 'Indirizzo',
                          value: widget.intervento.destinazione?.indirizzo ?? 'N/A',
                          context: context
                      ),
                      buildInfoRow(
                          title: 'Cell. destinazione',
                          value: widget.intervento.destinazione?.cellulare ?? 'N/A',
                          context: context
                      ),
                      buildInfoRow(
                          title: 'Tel. destinazione',
                          value: widget.intervento.destinazione?.telefono ?? 'N/A',
                          context: context
                      ),
                      buildInfoRow(
                          title: 'Indirizzo cliente',
                          value: widget.intervento.cliente?.indirizzo ?? 'N/A',
                          context: context
                      ),
                      buildInfoRow(
                          title: 'Tel. cliente',
                          value: widget.intervento.cliente?.telefono ?? 'N/A',
                          context: context
                      ),
                      buildInfoRow(
                          title: 'Cell. cliente',
                          value: widget.intervento.cliente?.cellulare ?? 'N/A',
                          context: context
                      ),
                      SizedBox(height : 20),
                      Row(
                        children: [
                          if(intervento.annullato == false)
                            Container(
                              width: 170,
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8), // Aggiunge padding
                              child: FloatingActionButton(
                                onPressed: widget.utente.cognome == "Mazzei"
                                    ? () {
                                  annullaIntervento();
                                }
                                    : null, // Il pulsante è disabilitato se onPressed è null
                                heroTag: "TagAnnullamento",
                                backgroundColor: widget.utente.cognome == "Mazzei" ? Colors.red : Colors.grey, // Colore condizionale
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible( // Permette al testo di adattarsi alla dimensione
                                      child: Text(
                                        'Annulla intervento'.toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center, // Centra il testo
                                        softWrap: true, // Permette al testo di andare a capo
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          SizedBox(width: 10),
                          if(intervento.annullato == true)
                            Container(
                              width: 170,
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8), // Aggiunge padding
                              child: FloatingActionButton(
                                onPressed: () {
                                  riabilitaIntervento();
                                },
                                heroTag: "TagRiabilita",
                                backgroundColor: Colors.red,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible( // Permette al testo di adattarsi alla dimensione
                                      child: Text(
                                        'Riabilita intervento'.toUpperCase(),
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
                    ],
                  ),
                ),
              ),
            ),
            // Fine info generali, inizio info temporali
            Container(
              child: Padding(
                padding: EdgeInsets.all(7),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dettagli Temporali',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildInfoRow(
                              title: 'Appuntamento',
                              value: formatDate(widget.intervento.data),
                              context: context
                          ),
                          SizedBox(height: 3),
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
                                          'Modifica data appuntamento'.toUpperCase(),
                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                          textAlign: TextAlign.center, // Centra il testo
                                          softWrap: true, // Permette al testo di andare a capo
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
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
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildInfoRow(
                              title: 'Orario',
                              value: formatTime(widget.intervento.orario_appuntamento),
                              context: context
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
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
                              SizedBox(width: 5),
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
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          buildInfoRow(
                              title: 'Orario Inizio',
                              value: widget.intervento.orario_inizio != null ? DateFormat("HH:mm").format(widget.intervento.orario_inizio!) : "N/A",
                              context: context
                          ),
                          SizedBox(width: 10),
                          Align(
                            alignment: Alignment.center,
                            child: InkWell(
                              onTap: () => _selectTime(context),
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          buildInfoRow(
                              title: 'Orario Fine',
                              value: widget.intervento.orario_fine != null ? DateFormat("HH:mm").format(widget.intervento.orario_fine!) : "N/A",
                              context: context
                          ),
                          SizedBox(width : 10),
                          Align(
                            alignment: Alignment.center,
                            child: InkWell(
                              onTap: () => _selectTime2(context),
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            //Fine info temporali, inizio info finanziarie
            Container(
              child: Padding(
                padding: EdgeInsets.all(7),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dettagli Finanziari',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height:10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          buildInfoRow(
                            title: 'Importo',
                            value: getPrezzoIvato(widget.intervento), // Usa la funzione per calcolare il valore del prezzo ivato
                            context: context,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          TextButton(
                            onPressed: () {
                              openImportoDialog(context, _importoController);
                            },
                            child: Icon(
                              Icons.edit,
                              color: Colors.black,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            //Fine info finanziarie, inizio info tecnico
            Container(color: Colors.blue,),
            Container(color: Colors.yellow,),
            //Container(color: Colors.orange,),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        backgroundColor: Colors.red,
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
              title: Text('Info', style: TextStyle(color: Colors.white)),
              icon: Icon(Icons.info_outline, color: Colors.white)
          ),
          BottomNavyBarItem(
              title: Text('Dett. Temporali', style: TextStyle(color: Colors.white)),
              icon: Icon(Icons.schedule, color: Colors.white)
          ),
          BottomNavyBarItem(
              title: Text('Dett. Finanziari', style: TextStyle(color: Colors.white)),
              icon: Icon(Icons.attach_money, color: Colors.white)
          ),
          BottomNavyBarItem(
              title: Text('Tecnico', style: TextStyle(color: Colors.white)),
              icon: Icon(Icons.person, color: Colors.white)
          ),
          BottomNavyBarItem(
              title: Text('Immagini', style: TextStyle(color: Colors.white)),
              icon: Icon(Icons.camera, color: Colors.white)
          ),
        ],
      ),
    );
  }
}