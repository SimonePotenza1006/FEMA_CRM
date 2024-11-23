import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fema_crm/databaseHandler/DbHelper.dart';
import 'package:fema_crm/pages/CreazioneLicenzaPage.dart';
import 'package:fema_crm/pages/CreazioneRMAPage.dart';
import 'package:fema_crm/pages/MenuInterventiPage.dart';
import 'package:fema_crm/pages/TableAccessiApplicazionePage.dart';
import 'package:fema_crm/pages/TableMagazzinoPage.dart';
import 'package:fema_crm/pages/TableMerceInRiparazionePage.dart';
import 'package:fema_crm/pages/TableTaskPage.dart';
import 'package:fema_crm/pages/TableVeicoliPage.dart';
import 'package:fema_crm/pages/TimbratureEdit.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:fema_crm/pages/CalendarioPage.dart';
import 'package:fema_crm/pages/ListaClientiPage.dart';
import 'package:fema_crm/pages/ListaCredenzialiPage.dart';
import 'package:fema_crm/pages/LogisticaPreventiviHomepage.dart';
import 'package:fema_crm/pages/MenuCommissioniPage.dart';
import 'package:fema_crm/pages/MenuOrdiniFornitorePage.dart';
import 'package:fema_crm/pages/MenuSopralluoghiPage.dart';
import 'package:fema_crm/pages/ScannerQrCodeAmministrazionePage.dart';
import 'package:fema_crm/pages/SpesaSuVeicoloPage.dart';
import 'package:fema_crm/pages/TimbraturaPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../main.dart';
import '../model/CommissioneModel.dart';
import '../model/CustomAppointmentModel.dart';
import '../model/InterventoModel.dart';
import '../model/NotaTecnicoModel.dart';
import '../model/OrdinePerInterventoModel.dart';
import '../model/RelazioneUtentiInterventiModel.dart';
import '../model/TipologiaInterventoModel.dart';
import '../model/UtenteModel.dart';
import '../model/VeicoloModel.dart';
import 'CertificazioniPage.dart';
import 'CreazioneNuovaCartaPage.dart';
import 'CreazioneNuovoUtentePage.dart';
import 'DettaglioCommissioneAmministrazionePage.dart';
import 'DettaglioCommissioneTecnicoPage.dart';
import 'DettaglioInterventoByTecnicoPage.dart';
import 'DettaglioInterventoNewPage.dart';
import 'DettaglioInterventoPage.dart';
import 'DettaglioMerceInRiparazioneByTecnicoPage.dart';
import 'ListaNoteUtentiPage.dart';
import 'ListaUtentiPage.dart';
import 'ParentFolderPage.dart';
import 'RegistroCassaPage.dart';
import 'StoricoMerciUtentiPage.dart';
import 'TableRMAPage.dart';
import 'TableTicketPage.dart';

class HomeFormAmministrazioneNewPage extends StatefulWidget {
  final UtenteModel userData;

  const HomeFormAmministrazioneNewPage({Key? key, required this.userData})
      : super(key: key);

  @override
  _HomeFormAmministrazioneNewPageState createState() =>
      _HomeFormAmministrazioneNewPageState();
}

class _HomeFormAmministrazioneNewPageState
    extends State<HomeFormAmministrazioneNewPage> {
  int _hoveredIndex = -1;
  List<NotaTecnicoModel> allNote = [];
  List<NotaTecnicoModel> allNoteScadenze = [];
  final CalendarController _calendarController = CalendarController();
  DateTime _selectedDate = DateTime.now();
  List<InterventoModel> allInterventi = [];
  List<CustomAppointmentModel> appointments = [];
  List<CommissioneModel> allCommissioni = [];
  final AppointmentDataSource _appointmentDataSource = AppointmentDataSource([]);
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  List<TipologiaInterventoModel> allTipologie = [];
  List<UtenteModel> allUtenti = [];
  Map<String, bool> _publishedNotes = {};
  DateTime today = DateTime.now();
  bool ingressoSaved = false;
  List<VeicoloModel> allVeicoli = [];
  List<OrdinePerInterventoModel> allOrdini = [];
  DateTime selectedDate = DateTime.now();
  Map<int, int> _menuItemClickCount = {};
  bool scadenze = false;

  @override
  void initState() {
    super.initState();
    if(Platform.isAndroid){
      // _menuItemClickCount.clear();
      // for (int i = 0; i < _menuItems.length; i++) {
      //   _menuItemClickCount[i] = 0;
      // };
    }
    getAllVeicoli().then((_) {
      getNote();
    });
    getAllOrdini();
    _scheduleGetAllOrdini();
    fetchData();
    getAllInterventiBySettore();
  }

  Future<List<InterventoModel>> getAllInterventiBySettore() async {
    try {
      print('getAllInterventiBySettore chiamato');
      var apiUrl = Uri.parse('$ipaddress/api/intervento/categoriaIntervento/'+widget.userData!.tipologia_intervento!.id.toString());
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<InterventoModel> interventi = [];
        for (var item in jsonData) {
          if (InterventoModel.fromJson(item).data != null && InterventoModel.fromJson(item).utente != null && InterventoModel.fromJson(item).utente?.id.toString() != widget.userData?.id.toString() && (InterventoModel.fromJson(item).concluso != true)) //solo gli interventi con data e utente
            interventi.add(InterventoModel.fromJson(item));
        }
        return interventi;
      } else {
        print('getAllInterventiBySettore: fallita con status code ${response.statusCode}');
        return [];
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API getAllInterventi: $e');
      return [];
    }
  }

  // final List<MenuItem> _menuItems = [
  //   MenuItem(icon: Icons.calendar_month_outlined, label: 'CALENDARIO'),
  //   MenuItem(icon: Icons.snippet_folder_outlined, label: 'ORDINI FORNITORE'),
  //   MenuItem(icon: Icons.more_time, label: 'TIMBRATURA'),
  //   MenuItem(icon: Icons.build, label: 'LISTA INTERVENTI'),
  //   MenuItem(icon: Icons.rule_folder_outlined, label: 'RIPARAZIONI'),
  //   MenuItem(icon: Icons.remove_red_eye_outlined, label: 'SOPRALLUOGHI'),
  //   MenuItem(icon: Icons.class_outlined, label: 'COMMISSIONI'),
  //   MenuItem(icon: Icons.emoji_transportation_sharp, label: 'SPESE SU VEICOLO'),
  //   MenuItem(icon: Icons.do_disturb_alt_rounded, label: 'CREDENZIALI'),
  //   MenuItem(icon: Icons.contact_emergency_rounded, label: 'LISTA CLIENTI'),
  //   MenuItem(icon: Icons.warehouse_rounded, label: 'MAGAZZINO'),
  //   MenuItem(icon: Icons.euro_rounded, label: 'REGISTRO CASSA'),
  //   MenuItem(icon: Icons.business_center_outlined, label: 'PREVENTIVI'),
  //   MenuItem(icon: Icons.qr_code_2_outlined, label: 'SCANNER QRCODE'),
  // ];

  Future<void> fetchData() async {
    print('fetchData chiamato');
    await getTipologieIntervento();
    await getAllInterventi();
    await getAllCommissioni();
    await getAllUtenti();
    combineAppointments();
  }

  Future<void> getAllOrdini() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/ordine');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<OrdinePerInterventoModel> ordini = [];
        for(var item in jsonData){
          var ordine = OrdinePerInterventoModel.fromJson(item);
          if(ordine.presa_visione == false && ordine.ordinato == false && ordine.arrivato == false && ordine.consegnato == false){
            ordini.add(ordine);
          }
          setState(() {
            allOrdini = ordini;
          });
        }
      }
    } catch(e){
      print('Errore getAllOrdini: $e');
    }
  }

  void _scheduleGetAllOrdini() {
    Timer.periodic(Duration(minutes: 10), (timer) {
      getAllOrdini();
    });
  }

  bool checkVeicoloScadenze(List<VeicoloModel> allVeicoli) {

    DateTime now = DateTime.now();

    bool hasScadenze = false;

    // Iteriamo su tutti i veicoli
    for (var veicolo in allVeicoli) {
      // Verifica tutte le date e se sono passate o vicine alla scadenza (7 giorni o meno)
      if (veicolo.scadenza_gps != null && veicolo.scadenza_gps!.isBefore(now.add(Duration(days: 7)))) {
        hasScadenze = true;
        break;
      }
      if (veicolo.data_scadenza_bollo != null && veicolo.data_scadenza_bollo!.isBefore(now.add(Duration(days: 7)))) {
        hasScadenze = true;
        break;
      }
      if (veicolo.data_scadenza_polizza != null && veicolo.data_scadenza_polizza!.isBefore(now.add(Duration(days: 7)))) {
        hasScadenze = true;
        break;
      }
      if (veicolo.data_tagliando != null && veicolo.data_tagliando!.isBefore(now.add(Duration(days: 7)))) {
        hasScadenze = true;
        break;
      }
      if (veicolo.data_revisione != null && veicolo.data_revisione!.isBefore(now.add(Duration(days: 7)))) {
        hasScadenze = true;
        break;
      }
      if (veicolo.data_inversione_gomme != null && veicolo.data_inversione_gomme!.isBefore(now.add(Duration(days: 7)))) {
        hasScadenze = true;
        break;
      }
      if (veicolo.data_sostituzione_gomme != null && veicolo.data_sostituzione_gomme!.isBefore(now.add(Duration(days: 7)))) {
        hasScadenze = true;
        break;
      }
    }
    if (hasScadenze) {
      // Aggiorna lo stato e visualizza l'alert
      setState(() {
        scadenze = true;
      });
      // Mostra un AlertDialog per segnalare le nuove scadenze
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ATTENZIONE'),
            content: Text('Scadenze in corso sui veicoli'.toUpperCase()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Chiude l'alert
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return true;
    }

    return false;
  }



  Future<void> getAllVeicoli() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/veicolo');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<VeicoloModel> veicoli = [];
        for (var item in jsonData) {
          VeicoloModel veicolo = VeicoloModel.fromJson(item);
          if(veicolo.flotta == true){
            veicoli.add(veicolo);
          }
        }
        setState(() {
          allVeicoli = veicoli;
        });
      } else {
        throw Exception('Failed to load utenti data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching agenti data from API: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Connection Error'),
            content: Text('Unable to load data from API. Please check your internet connection and try again.'),
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

  Future<List<RelazioneUtentiInterventiModel>> getAllRelazioniByUtente(String userId, DateTime date) async {
    try{
      String userId = widget.userData!.id.toString();
      http.Response response = await http
          .get(Uri.parse('$ipaddress/api/relazioneUtentiInterventi/utente/$userId'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<RelazioneUtentiInterventiModel> allRelazioniByUtente = [];
        for(var item in responseData){
          RelazioneUtentiInterventiModel relazione = RelazioneUtentiInterventiModel.fromJson(item);
          if(relazione.intervento?.concluso != true){
            allRelazioniByUtente.add(relazione);
          }
        }
        return allRelazioniByUtente;
      }else {
        return [];
      }
    } catch (e) {
      print('Error fetching interventi: $e');
      return [];
    }
  }

  Future<List<InterventoModel>> getAllInterventiByUtente(String userId, DateTime date) async {
    try {
      String userId = widget.userData.id.toString();
      http.Response response = await http
          .get(Uri.parse('$ipaddress/api/intervento/utente/$userId'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<InterventoModel> allInterventiByUtente = [];
        for (var interventoJson in responseData) {
          InterventoModel intervento = InterventoModel.fromJson(interventoJson);
          // Aggiungi il filtro per interventi non conclusi
          if(intervento.concluso != true){
            allInterventiByUtente.add(intervento);
          }
        }
        return allInterventiByUtente;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching interventi: $e');
      return [];
    }
  }

  Future<List<InterventoModel>> getMerce(String userId) async{
    try{
      String userId = widget.userData!.id.toString();
      http.Response response = await http.get(Uri.parse('$ipaddress/api/intervento/withMerce/$userId'));
      if(response.statusCode == 200){
        var responseData = json.decode(response.body);
        List<InterventoModel> interventi = [];
        for(var interventoJson in responseData){
          InterventoModel intervento = InterventoModel.fromJson(interventoJson);
          if(intervento.concluso != true){
            interventi.add(intervento);
          }
        }
        return interventi;
      } else {
        return [];
      }
    } catch(e){
      print('Errore fetch merce: $e');
      return[];
    }
  }

  Future<List<CommissioneModel>> getAllCommissioniByUtente(
      String userId) async {
    try {
      String userId = widget.userData.id.toString();
      http.Response response = await http
          .get(Uri.parse('$ipaddress/api/commissione/utente/$userId'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<CommissioneModel> allCommissioniByUtente = [];
        for (var item in responseData) {
          CommissioneModel commissione = CommissioneModel.fromJson(item);
          if (commissione.concluso == false) {
            allCommissioniByUtente.add(commissione);
          }
        }
        return allCommissioniByUtente;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching commissioni: $e');
      return [];
    }
  }

  int _calculateHoveredIndex(Offset position) {
    final center = Offset(500 / 2, 500 / 2); // Use the same size as in CustomPaint
    final angle = (math.atan2(position.dy - center.dy, position.dx - center.dx) + math.pi * 2) % (math.pi * 2);
    final sectorAngle = (2 * math.pi) / 14; // 14 menu items
    final hoveredIndex = (angle ~/ sectorAngle) % 14;
    return hoveredIndex;
  }

  // Future<void> checkScadenzeVeicoli() async {
  //   for (var veicolo in allVeicoli) {
  //     await checkScadenzeDate(veicolo);
  //   }
  // }

  // Future<void> checkScadenzeDate(VeicoloModel veicolo) async {
  //
  //   // Controllo scadenza bollo
  //   if (veicolo.data_scadenza_bollo!= null) {
  //     final differenceBollo = veicolo.data_scadenza_bollo!.difference(today).inDays;
  //     if (differenceBollo <= 30) {
  //       final noteKey = '${veicolo.id}_bollo_${today.toIso8601String()}';
  //       if (_publishedNotes.containsKey(noteKey)) {
  //         return; // Note has already been published today
  //       }
  //
  //       bool trovato = allNoteScadenze.any((nota) => nota.nota == "Il veicolo ${veicolo.descrizione} ha il bollo in scadenza tra ${differenceBollo} giorni!" && nota.data != null && nota.data!.toString().startsWith(today.toString().substring(0, 10)));
  //
  //       if(!trovato)
  //       try {
  //
  //          final response = await http.post(
  //           Uri.parse('$ipaddress/api/noteTecnico'),
  //           headers: {'Content-Type': 'application/json'},
  //           body: jsonEncode({
  //             'utente': widget.userData.toMap(),
  //             'data': DateTime.now().toIso8601String(),
  //             'nota': "Il veicolo ${veicolo.descrizione} ha il bollo in scadenza tra ${differenceBollo} giorni!",
  //           }),
  //         );
  //         print("Nota scadenza bollo creata!");
  //         // Mark note as published today
  //         _publishedNotes[noteKey] = true;
  //       } catch (e) {
  //         print("Errore nota scadenza bollo: $e");
  //       }
  //     }
  //   }
  //   // Controllo scadenza polizza
  //   if (veicolo.data_scadenza_polizza!= null) {
  //     final differencePolizza = veicolo.data_scadenza_polizza!.difference(today).inDays;
  //     if (differencePolizza <= 30) {
  //       bool trovato = allNoteScadenze.any((nota) => nota.nota == "Il veicolo ${veicolo.descrizione} ha la polizza in scadenza tra ${differencePolizza} giorni!" && nota.data != null && nota.data!.toString().startsWith(today.toString().substring(0, 10)));
  //
  //       final noteKey = '${veicolo.id}_polizza_${today.toIso8601String()}';
  //       if (_publishedNotes.containsKey(noteKey)) {
  //         return; // Note has already been published today
  //       }
  //
  //
  //       if(!trovato)
  //         try {
  //
  //           final response = await http.post(
  //           Uri.parse('$ipaddress/api/noteTecnico'),
  //           headers: {'Content-Type': 'application/json'},
  //           body: jsonEncode({
  //             'utente': widget.userData.toMap(),
  //             'data': DateTime.now().toIso8601String(),
  //             'nota': "Il veicolo ${veicolo.descrizione} ha la polizza in scadenza tra ${differencePolizza} giorni!",
  //           }),
  //         );
  //         print("Nota scadenza polizza creata!");
  //         // Mark note as published today
  //         _publishedNotes[noteKey] = true;
  //       } catch (e) {
  //         print("Errore nota scadenza polizza: $e");
  //       }
  //
  //     }
  //   }
  //   // Controllo scadenza tagliando
  //   if (veicolo.data_tagliando!= null) {
  //     final differenceTagliando = today.difference(veicolo.data_tagliando!).inDays;
  //     if (differenceTagliando >= 700) {
  //       final noteKey = '${veicolo.id}_tagliando_${today.toIso8601String()}';
  //       if (_publishedNotes.containsKey(noteKey)) {
  //         return; // Note has already been published today
  //       }
  //
  //       bool trovato = allNoteScadenze.any((nota) => nota.nota == "Il veicolo ${veicolo.descrizione} ha superato i 700 giorni dall'ultimo tagliando!" && nota.data != null && nota.data!.toString().startsWith(today.toString().substring(0, 10)));
  //
  //       try {
  //         if(!trovato) final response = await http.post(
  //           Uri.parse('$ipaddress/api/noteTecnico'),
  //           headers: {'Content-Type': 'application/json'},
  //           body: jsonEncode({
  //             'utente': widget.userData.toMap(),
  //             'data': DateTime.now().toIso8601String(),
  //             'nota': "Il veicolo ${veicolo.descrizione} ha superato i 700 giorni dall'ultimo tagliando!",
  //           }),
  //         );
  //         print("Nota promemoria tagliando creata!");
  //         // Mark note as published today
  //         _publishedNotes[noteKey] = true;
  //       } catch (e) {
  //         print("Errore nota promemoria tagliando: $e");
  //       }
  //     }
  //   }
  // }

  Future<void> getAllUtenti() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/utente');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<UtenteModel> utenti = [];
        for (var item in jsonData) {
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          allUtenti = utenti;
        });
      } else {
        print('getAllUtenti: fallita con status code ${response.statusCode}');
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API getAllUtenti: $e');
    }
  }

  Future<void> getAllCommissioni() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/commissione');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<CommissioneModel> commissioni = [];
        for (var item in jsonData) {
          commissioni.add(CommissioneModel.fromJson(item));
        }
        setState(() {
          allCommissioni = commissioni;
        });
      } else {
        print('getAllCommissioni: fallita con status code ${response.statusCode}');
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API getAllCommissioni: $e');
    }
  }

  Future<void> getTipologieIntervento() async {
    print('getTipologieIntervento chiamato');
    try {
      var apiUrl = Uri.parse('$ipaddress/api/tipologiaIntervento');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        print('getTipologieIntervento: chiamata API riuscita');
        var jsonData = jsonDecode(response.body);
        List<TipologiaInterventoModel> tipologie = [];
        for (var item in jsonData) {
          tipologie.add(TipologiaInterventoModel.fromJson(item));
        }
        setState(() {
          allTipologie = tipologie;
        });
      } else {
        print('getTipologieIntervento: fallita con status code ${response.statusCode}');
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
    }
  }

  Future<void> getAllInterventi() async {
    print('getAllInterventi chiamato');
    try {
      var apiUrl = Uri.parse('$ipaddress/api/intervento');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        print('getAllInterventi: chiamata API riuscita');
        var jsonData = jsonDecode(response.body);
        List<InterventoModel> interventi = [];
        for (var item in jsonData) {
          try {
            var intervento = InterventoModel.fromJson(item);

            interventi.add(intervento);

          } catch (e) {
            print('Errore nella creazione di InterventoModel: $e');
          }
        }
        setState(() {
          allInterventi = interventi;
        });
      } else {
        print('getAllInterventi: fallita con status code ${response.statusCode}');
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
    }
  }

  void combineAppointments() {
    appointments = [];
    // Aggiungi gli interventi
    appointments.addAll(allInterventi.map((intervento) {
      DateTime? startTime;
      if (intervento.orario_appuntamento != null) {
        startTime = intervento.orario_appuntamento!;
      } else if (intervento.data != null) {
        startTime = intervento.data!;
      } else {
        // Gestione se entrambi i campi sono null, qui puoi loggare l'errore o impostare un valore predefinito
        startTime = DateTime.now(); // oppure ritorna null per ignorare l'intervento
      }
      DateTime endTime = startTime.add(Duration(hours: 1));
      String? subject = "${intervento.descrizione}";
      Color color = _getColorForTipologia(int.parse(intervento.tipologia!.id.toString()));
      return CustomAppointmentModel(
        startTime: startTime,
        endTime: endTime,
        subject: subject,
        recurrenceId: intervento,
        color: color,
        concluso: intervento.concluso,
      );
    }).toList());
    // Aggiungi le commissioni
    appointments.addAll(allCommissioni.map((commissione) {
      DateTime startTime = commissione.data != null ? commissione.data! : commissione.data_creazione!; //commissione.data_creazione! è una pezza momentanea
      DateTime endTime = startTime.add(Duration(hours: 2));
      return CustomAppointmentModel(
        startTime: startTime,
        endTime: endTime,
        subject: commissione.descrizione!,
        recurrenceId: commissione,
        color: Colors.yellow[900]!,
        concluso: commissione.concluso,
      );
    }).toList());
    setState(() {
      _appointmentDataSource.updateAppointments(appointments);
    });
  }


  Color _getColorForTipologia(int tipologiaId) {
    switch (tipologiaId) {
      case 1:
        return Colors.blueAccent;
      case 2:
        return Colors.greenAccent;
      case 3:
        return Colors.redAccent;
      case 4:
        return Colors.yellow;
      case 5:
        return Colors.pinkAccent;
      default:
        return Colors.grey;
    }
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    if (backgroundColor == Colors.redAccent ||
        backgroundColor == Colors.blueAccent ||
        backgroundColor == Colors.grey) {
      return Colors.white;
    }
    return Colors.black;
  }

  Future<List<NotaTecnicoModel>> getNote() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$ipaddress/api/noteTecnico/ordered'),
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<NotaTecnicoModel> note = [];
        List<NotaTecnicoModel> noteScadenze = [];

        for (var item in responseData) {
          NotaTecnicoModel nota = NotaTecnicoModel.fromJson(item);

          // Controlla se la stringa "Il veicolo" è presente in nota.nota
          if (nota.nota != null && nota.nota!.contains("Il veicolo")) {
            noteScadenze.add(nota);

          } else {
            note.add(nota);
          }
        }

        setState(() {
          allNote = note;
          allNoteScadenze = noteScadenze;
        });

        return note;
      } else {
        print('Error fetching note: ${response.statusCode}');
        return []; // Restituisci una lista vuota in caso di errore
      }
    } catch (e) {
      print('Error fetching note: $e');
      return []; // Restituisci una lista vuota in caso di eccezione
    }
  }


  int _lastClickedIndex = 0;

  // void _navigateToPage(int index) {
  //   if(Platform.isAndroid){
  //     if (_lastClickedIndex != index) {
  //       _menuItemClickCount.clear(); // azzerare tutti i contatori quando si clicca su un bottone diverso
  //       _lastClickedIndex = index; // aggiornare l'indice dell'ultimo bottone cliccato
  //     }
  //   }
  //
  //   if(Platform.isAndroid){
  //     if (_menuItemClickCount.containsKey(index)) {
  //       _menuItemClickCount[index] = (_menuItemClickCount[index] ?? 0) + 1;
  //     } else {
  //       _menuItemClickCount[index] = 1;
  //     }
  //   }
  //
  //
  //   //if (_menuItemClickCount[index] % 2 == 0 && _hoveredIndex != -1) {
  //   if ((_menuItemClickCount[index] ?? 0) % 2 == 0 && _hoveredIndex != -1) {
  //     switch (index) {
  //       case 0:
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => CalendarioPage()),
  //         );
  //         break;
  //       case 1:
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) =>
  //               MenuOrdiniFornitorePage(utente: widget.userData)),
  //         );
  //         break;
  //       case 2:
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) => (widget.userData.cognome! == "Mazzei" || widget.userData.cognome! == "Chiriatti") ?
  //               TimbratureEdit(utente: widget.userData) : TimbraturaPage(utente: widget.userData)
  //           ),
  //         );
  //         break;
  //       case 3:
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) =>
  //               MenuInterventiPage(utente: widget.userData)), //ListaInterventiFinalPage()),
  //         );
  //         break;
  //       case 4:
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) =>
  //               TableMerceInRiparazionePage()),
  //         );
  //         break;
  //       case 5:
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) =>
  //               MenuSopralluoghiPage(utente: widget.userData)),
  //         );
  //         break;
  //       case 6:
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => MenuCommissioniPage()),
  //         );
  //         break;
  //       case 7:
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) =>
  //               SpesaSuVeicoloPage(utente: widget.userData)),
  //         );
  //         break;
  //       case 8:
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => ListaCredenzialiPage()),
  //         );
  //         break;
  //       case 9:
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => ListaClientiPage()),
  //         );
  //         break;
  //       case 10:
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => TableMagazzinoPage()),
  //         );
  //         break;
  //       case 11:
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) =>
  //               RegistroCassaPage(userData: widget.userData)),
  //         );
  //         break;
  //       case 12:
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) =>
  //               LogisticaPreventiviHomepage(userData: widget.userData)),
  //         );
  //         break;
  //       case 13:
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) => ScannerQrCodeAmministrazionePage()),
  //         );
  //         break;
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'F.E.M.A. AMMINISTRAZIONE',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {

              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginForm()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[700],
        child: Column(
          children: [
            DrawerHeader(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 16),
                        Icon(Icons.settings, color: Colors.white,),
                        SizedBox(width: 4),
                        Text(
                          'IMPOSTAZIONI', style: TextStyle(color: Colors.white, fontSize: 24),
                        )
                      ],
                    )
                  ],
                )
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: Text('Crea nuovo utente', style: TextStyle(color: Colors.white),),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreazioneNuovoUtentePage()),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Gestione licenze', style: TextStyle(color: Colors.white),),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreazioneLicenzaPage()),
                      );
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Management veicoli',
                      style: TextStyle(
                        color: scadenze ? Colors.red : Colors.white,
                        fontWeight: scadenze ? FontWeight.bold : FontWeight.normal,
                        fontSize: scadenze ? 20 : 16, // Cambia la dimensione del testo
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TableVeicoliPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Aggiungi carta', style: TextStyle(color: Colors.white),),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreazioneNuovaCartaPage()),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Certificazioni', style: TextStyle(color: Colors.white),),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CertificazioniPage(utente: widget.userData!)),
                      );
                    },
                  ),
                  if(widget.userData.cognome! == "Mazzei" || widget.userData.cognome! == "Chiriatti")
                    ListTile(
                      title: Text('Controllo accessi applicazione', style: TextStyle(color: Colors.white),),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TableAccessiApplicazionePage()),
                        );
                      },
                    ),
                  if(widget.userData.cognome! == "Mazzei" || widget.userData.cognome! == "Chiriatti" || widget.userData.cognome! == "Zaminga")
                    ListTile(
                      title: Text('Storico merci utenti', style: TextStyle(color: Colors.white),),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StoricoMerciUtentiPage()),
                        );
                      },
                    ),
                  if(widget.userData.cognome! == "Mazzei" || widget.userData.cognome! == "Chiriatti" || widget.userData.cognome! == "Zaminga")
                    ListTile(
                      title: Text('Credenziali utenti', style: TextStyle(color: Colors.white),),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ListaUtentiPage()),
                        );
                      },
                    ),
                  if(widget.userData.cognome! == "Mazzei" || widget.userData.cognome! == "Chiriatti")
                    ListTile(
                      title: Text('Archivio', style: TextStyle(color: Colors.white)),
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ParentFolderPage()),
                        );
                      },
                    ),
                  ListTile(
                    title: Text('Lista RMA', style: TextStyle(color: Colors.white)),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TableRMAPage()),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Aggiungi RMA', style: TextStyle(color: Colors.white)),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreazioneRMAPage(utente:widget.userData)),
                      );
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginForm()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 85, left: 25, right: 25, bottom: 40),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (Platform.isAndroid) {
              // Tablet/Mobile layout
              return SingleChildScrollView(
                  child: Column(
                      children: [
                        Column(
                          children: [
                            //   GestureDetector(
                            //   onTapUp: (details) {
                            // if (_hoveredIndex != -1) {
                            // _navigateToPage(_hoveredIndex);
                            // }
                            // },
                            //   onPanUpdate: (details) {
                            //     RenderBox box = context.findRenderObject() as RenderBox;
                            //     Offset localOffset = box.globalToLocal(details.globalPosition);
                            //     setState(() {
                            //       _hoveredIndex = _calculateHoveredIndex(localOffset);
                            //     });
                            //   },
                            //   child: CustomPaint(
                            //     size: Size(500, 500),
                            //     painter: MenuPainter(
                            //           (index) {
                            //         setState(() {
                            //           _hoveredIndex = index;
                            //         });
                            //       },
                            //           () {
                            //         setState(() {
                            //           _hoveredIndex = -1;
                            //         });
                            //       },
                            //       context,
                            //       size: Size(500, 500),
                            //       hoveredIndex: _hoveredIndex,
                            //     ),
                            //   ),
                            // ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 350,
                                  child: buildMenuButton(icon: Icons.access_time_outlined, text: 'TIMBRATURA',
                                    onPressed: () {
                                      if(widget.userData.id == "2" || widget.userData.id == "13"){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => TimbratureEdit(utente: widget.userData)),
                                        );
                                      } else{
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => TimbraturaPage(utente: widget.userData)),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: 350,
                                  child: buildMenuButton(icon: Icons.build, text: 'INTERVENTI',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => MenuInterventiPage(utente: widget.userData)),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: 350,
                                  child: buildMenuButton(icon: Icons.calendar_month_sharp, text: 'CALENDARIO',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => CalendarioPage()),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: 350,
                                  child: buildMenuButton(icon: Icons.snippet_folder_outlined, text: 'ORDINI FORNITORE',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => MenuOrdiniFornitorePage(utente: widget.userData)),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: 350,
                                  child: buildMenuButton(icon: Icons.euro_rounded, text: 'REGISTRO CASSA',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => RegistroCassaPage(userData: widget.userData)),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: 350,
                                  child: buildMenuButton(icon: Icons.rule_folder_outlined, text: 'RIPARAZIONI',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => TableMerceInRiparazionePage()),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: 350,
                                  child: buildMenuButton(icon: Icons.remove_red_eye_outlined, text: 'SOPRALLUOGHI',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => MenuSopralluoghiPage(utente: widget.userData)),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: 350,
                                  child: buildMenuButton(icon: Icons.class_outlined, text: 'COMMISSIONI',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => MenuCommissioniPage()),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: 350,
                                  child: buildMenuButton(icon: Icons.emoji_transportation_sharp, text: 'SPESE SU VEICOLO',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => SpesaSuVeicoloPage(utente: widget.userData)),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: 350,
                                  child: buildMenuButton(icon: Icons.do_disturb_alt_rounded, text: 'CREDENZIALI',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ListaCredenzialiPage()),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: 350,
                                  child: buildMenuButton(icon: Icons.contact_emergency_rounded, text: 'CLIENTI',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ListaClientiPage()),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: 350,
                                  child: buildMenuButton(icon: Icons.warehouse_outlined, text: 'MAGAZZINO',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => TableMagazzinoPage()),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: 350,
                                  child: buildMenuButton(icon: Icons.business_center_outlined, text: 'PREVENTIVI',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => LogisticaPreventiviHomepage(userData: widget.userData)),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: 350,
                                  child: buildMenuButton(icon: Icons.qr_code_2, text: 'QRCODE',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ScannerQrCodeAmministrazionePage()),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: 350,
                                  child: buildMenuButton(icon: Icons.checklist, text: 'TASK',
                                    onPressed: () {
                                      SystemChrome.setPreferredOrientations([
                                        //DeviceOrientation.landscapeLeft,
                                        DeviceOrientation.landscapeRight,
                                      ]);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => TableTaskPage(utente: widget.userData)),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 350,
                                  child: buildMenuButton(icon: Icons.sticky_note_2_outlined, text: 'TICKET',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => TableTicketPage()),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 80),
                            Column(
                              children: [
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'SCADENZE',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 750,
                                  height: 250,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade700),
                                  ),
                                  child: FutureBuilder<List<NotaTecnicoModel>>(
                                    future: Future.value(allNoteScadenze),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Center(child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(child: Text('Errore: ${snapshot.error}'));
                                      } else if (snapshot.hasData) {
                                        List<NotaTecnicoModel> note = snapshot.data!;
                                        return SingleChildScrollView(
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: note.length,
                                            itemBuilder: (context, index) {
                                              NotaTecnicoModel nota = note[index];
                                              String formattedDate = intl.DateFormat(
                                                  'dd/MM/yyyy HH:mm')
                                                  .format(
                                                  DateTime.parse(nota.data!.toIso8601String()));
                                              return ListTile(
                                                title: Text(
                                                  nota.utente!.nomeCompleto() ?? 'N/A',
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                subtitle: Text(
                                                  '$formattedDate - ${nota.nota}',
                                                  style: TextStyle(fontSize: 16),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      } else {
                                        return Center(child: Text('Nessuna nota trovata'));
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(height: 24),
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ListaNoteUtentiPage()),
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'NOTE DEGLI UTENTI',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 750,
                                  height: 250,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade700),
                                  ),
                                  child: FutureBuilder<List<NotaTecnicoModel>>(
                                    future: Future.value(allNote),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Center(child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(child: Text('Errore: ${snapshot.error}'));
                                      } else if (snapshot.hasData) {
                                        List<NotaTecnicoModel> note = snapshot.data!;
                                        return SingleChildScrollView(
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: note.length,
                                            itemBuilder: (context, index) {
                                              NotaTecnicoModel nota = note[index];
                                              String formattedDate = intl.DateFormat(
                                                  'dd/MM/yyyy HH:mm')
                                                  .format(
                                                  DateTime.parse(nota.data!.toIso8601String()));
                                              return ListTile(
                                                title: Text(
                                                  nota.utente!.nomeCompleto() ?? 'N/A',
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                subtitle: Text(
                                                  '$formattedDate - ${nota.nota}',
                                                  style: TextStyle(fontSize: 16),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      } else {
                                        return Center(child: Text('Nessuna nota trovata'));
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            Column(
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey.shade700),

                                    ),
                                    width: 750,
                                    height: 300,
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: SfCalendar(
                                        view: _calendarController.view?? CalendarView.week,
                                        controller: _calendarController,
                                        dataSource: _appointmentDataSource,
                                        monthViewSettings: MonthViewSettings(
                                          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                                        ),
                                        appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details){
                                          return Container(
                                            constraints: BoxConstraints(minHeight: 70),
                                            child: details.appointments.isNotEmpty
                                                ? ListView.builder(
                                              itemCount: details.appointments.length,
                                              itemBuilder: (context, index){
                                                Appointment appointment = details.appointments.elementAt(index)!;
                                                return GestureDetector(
                                                  onTap: (){
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) {
                                                          if (appointment.recurrenceId is InterventoModel) {
                                                            InterventoModel intervento = appointment.recurrenceId as InterventoModel;
                                                            return DettaglioInterventoNewPage(intervento: intervento);
                                                          } else {
                                                            CommissioneModel commissione = appointment.recurrenceId as CommissioneModel;
                                                            return DettaglioCommissioneAmministrazionePage(commissione: commissione);
                                                          }
                                                        },
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(8),
                                                      color: appointment.color,
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.all(6),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                appointment.subject,
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: _getTextColorForBackground(appointment.color),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        if (appointment.recurrenceId is InterventoModel && (appointment.recurrenceId as InterventoModel).concluso == true)
                                                          Positioned(
                                                            top: 0,
                                                            right: 0,
                                                            child: Icon(
                                                              Icons.check_circle,
                                                              color: Colors.red[500],
                                                              size: 20,
                                                            ),
                                                          ),
                                                        if(appointment.recurrenceId is CommissioneModel && (appointment.recurrenceId as CommissioneModel).concluso == true)
                                                          Positioned(
                                                            top: 0,
                                                            right: 0,
                                                            child: Icon(
                                                              Icons.check_circle,
                                                              color: Colors.white,
                                                              size: 20,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ) : SizedBox.shrink(),
                                          );
                                        },
                                      ),
                                    )
                                )
                              ],
                            ),
                            SizedBox(height: 25),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Interventi',
                                    style: TextStyle(
                                        fontSize: 30.0, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 15),
                                  IconButton(
                                    icon: Icon(Icons.calendar_today),
                                    onPressed: () async {
                                      final DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: selectedDate,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );
                                      if (pickedDate != null && pickedDate != selectedDate) {
                                        setState(() {
                                          selectedDate = pickedDate;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            FutureBuilder<List<InterventoModel>>(
                              future: getAllInterventiByUtente(widget.userData!.id.toString(), selectedDate),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(child: Text('Errore: ${snapshot.error}'));
                                } else if (snapshot.hasData) {
                                  List<InterventoModel> interventi = snapshot.data!;
                                  interventi = interventi.where((intervento) => intervento.merce == null).toList();
                                  interventi = interventi.where((intervento) {
                                    return intervento.data == null || intervento.data!.isSameDay(selectedDate);
                                  }).toList();
                                  if (interventi.isEmpty) {
                                    return Center(child: Text('', style: TextStyle(color: Colors.black,
                                        fontSize: 15.0)));
                                  }

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: interventi.length,
                                    itemBuilder: (context, index) {
                                      InterventoModel intervento = interventi[index];

                                      // Metodo per mappare la priorità al colore corrispondente
                                      Color getPriorityColor(Priorita priorita) {
                                        switch (priorita) {
                                          case Priorita.BASSA:
                                            return Colors.lightGreen;
                                          case Priorita.MEDIA:
                                            return Colors.yellow; // grigio chiaro
                                          case Priorita.ALTA:
                                            return Colors.orange; // giallo chiaro
                                          case Priorita.URGENTE:
                                            return Colors.red; // azzurro chiaro
                                          default:
                                            return Colors.blueGrey[200]!;
                                        }
                                      }

                                      // Determina il colore in base alla priorità
                                      Color backgroundColor =  getPriorityColor(intervento.priorita!);

                                      TextStyle textStyle = intervento.concluso ?? false
                                          ? TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)
                                          : TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);

                                      return Card(
                                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                          title: Text(
                                            '${intervento.cliente!.denominazione!}\n ${intervento.destinazione?.citta}, ${intervento.destinazione?.indirizzo}',
                                            style: textStyle,
                                          ),
                                          subtitle: Text(
                                            '${intervento.titolo}',
                                            style: textStyle,
                                          ),
                                          trailing: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              // Condizione per visualizzare l'icona di check se l'intervento è concluso
                                              if (intervento.concluso ?? false)
                                                Icon(Icons.check, color: Colors.black, size: 18), // Check icon
                                              Text(
                                                intervento.data != null
                                                    ? '${intervento.data!.day.toString().padLeft(2, '0')}/${intervento.data!.month.toString().padLeft(2, '0')}/${intervento.data!.year}'
                                                    : 'Nessun appuntamento stabilito',
                                                style: TextStyle(fontSize: 13, color: Colors.black),
                                              ),
                                              Text(
                                                intervento.orario_appuntamento != null
                                                    ? '${intervento.orario_appuntamento?.hour.toString().padLeft(2, '0')}:${intervento.orario_appuntamento?.minute.toString().padLeft(2, '0')}'
                                                    : 'Nessun orario stabilito',
                                                style: TextStyle(fontSize: 13, color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => DettaglioInterventoByTecnicoPage(
                                                  utente: widget.userData!,
                                                  intervento: intervento,
                                                ),
                                              ),
                                            );
                                          },
                                          tileColor: Colors.white60,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(color: getPriorityColor(intervento!.priorita!), width: 8),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  return Center(child: Text(''));
                                }
                              },
                            ),
                            FutureBuilder<List<RelazioneUtentiInterventiModel>>(
                              future: getAllRelazioniByUtente(widget.userData!.id.toString(), selectedDate),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(child: Text('Errore: ${snapshot.error}'));
                                } else if (snapshot.hasData) {
                                  List<RelazioneUtentiInterventiModel> relazioni = snapshot.data!;
                                  relazioni = relazioni.where((relazione) => relazione.intervento!.concluso != true && relazione.intervento!.merce == null).toList();
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: relazioni.length,
                                    itemBuilder: (context, index) {
                                      RelazioneUtentiInterventiModel relazione = relazioni[index];
                                      Color getPriorityColor(Priorita priorita) {
                                        switch (priorita) {
                                          case Priorita.BASSA:
                                            return Colors.lightGreen;
                                          case Priorita.MEDIA:
                                            return Colors.yellow; // grigio chiaro
                                          case Priorita.ALTA:
                                            return Colors.orange; // giallo chiaro
                                          case Priorita.URGENTE:
                                            return Colors.red; // azzurro chiaro
                                          default:
                                            return Colors.blueGrey[200]!;
                                        }
                                      }

                                      // Determina il colore in base alla priorità
                                      Color backgroundColor =  getPriorityColor(relazione.intervento!.priorita!);

                                      TextStyle textStyle = relazione.intervento?.concluso ?? false
                                          ? TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)
                                          : TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);
                                      /*TextStyle textStyle = relazione.intervento!.concluso ?? false
                                    ? TextStyle(color: Colors.white, fontSize: 15)
                                    : TextStyle(color: Colors.black, fontSize: 15);*/
                                      return Card(
                                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6), // aggiungi padding orizzontale
                                      elevation: 4, // aggiungi ombreggiatura
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      // aggiungi bordi arrotondati
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                        title: Text(
                                          '${relazione.intervento?.cliente!.denominazione!}\n${relazione.intervento?.destinazione?.citta}, ${relazione.intervento?.destinazione?.indirizzo}',
                                          style: textStyle,
                                        ),
                                        subtitle: Text(
                                          '${relazione.intervento?.titolo}',
                                          style: textStyle,
                                        ),
                                        trailing: Column(
                                          children: [
                                            if (relazione.intervento!.concluso ?? false)
                                              Icon(Icons.check, color: Colors.black, size: 18), //
                                            Text(
                                              // Formatta la data secondo il tuo formato desiderato
                                              relazione.intervento?.data!= null
                                                  ? '${relazione.intervento?.data!.day.toString().padLeft(2, '0')}/${relazione.intervento?.data!.month.toString().padLeft(2, '0')}/${relazione.intervento?.data!.year}'
                                                  : 'Nessun appuntamento stabilito',
                                              style: TextStyle(fontSize: 13, color: Colors.black),
                                            ),
                                            Text(
                                              relazione.intervento?.orario_appuntamento!= null
                                                  ? '${relazione.intervento?.orario_appuntamento?.hour.toString().padLeft(2, '0')}:${relazione.intervento?.orario_appuntamento?.minute.toString().padLeft(2, '0')}'
                                                  : 'Nessun orario stabilito',
                                              style: TextStyle(fontSize: 13, color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DettaglioInterventoByTecnicoPage(
                                                    utente: widget.userData!,
                                                    intervento: relazione.intervento!,
                                                  ),
                                            ),
                                          );
                                        },
                                        tileColor: Colors.white60,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(color: getPriorityColor(relazione.intervento!.priorita!), width: 8),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      )
                                      );
                                    },
                                  );
                                } else {
                                  return Center(child: Text(''));
                                }
                              },
                            ),
                            const SizedBox(height: 50.0),
                            Center(
                              child: Text(
                                'Interventi di settore',
                                style: TextStyle(
                                    fontSize: 30.0, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            FutureBuilder<List<InterventoModel>>(
                              future: getAllInterventiBySettore(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(child: Text('Errore: ${snapshot.error}'));
                                } else if (snapshot.hasData) {
                                  List<InterventoModel> interventi = snapshot.data!;
                                  interventi = interventi.where((intervento) => intervento.merce == null).toList();
                                  interventi = interventi.where((intervento) {
                                    return intervento.data == null || intervento.data!.isSameDay(selectedDate);
                                  }).toList();
                                  if (interventi.isEmpty) {
                                    return Center(child: Text('', style: TextStyle(color: Colors.black,
                                        fontSize: 15.0)));
                                  }
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: interventi.length,
                                    itemBuilder: (context, index) {
                                      InterventoModel intervento = interventi[index];
                                      // Metodo per mappare la priorità al colore corrispondente
                                      Color getPriorityColor(Priorita priorita) {
                                        switch (priorita) {
                                          case Priorita.BASSA:
                                            return Colors.lightGreen;
                                          case Priorita.MEDIA:
                                            return Colors.yellow; // grigio chiaro
                                          case Priorita.ALTA:
                                            return Colors.orange; // giallo chiaro
                                          case Priorita.URGENTE:
                                            return Colors.red; // azzurro chiaro
                                          default:
                                            return Colors.blueGrey[200]!;
                                        }
                                      }

                                      // Determina il colore in base alla priorità
                                      Color backgroundColor =  getPriorityColor(intervento.priorita!);

                                      TextStyle textStyle = intervento.concluso ?? false
                                          ? TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)
                                          : TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);

                                      return Card(
                                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                          title: Text(
                                            '${intervento.cliente!.denominazione!}\n${intervento.destinazione?.citta}, ${intervento.destinazione?.indirizzo}',
                                            style: textStyle,
                                          ),
                                          subtitle: Text(
                                            '${intervento.titolo}',
                                            style: textStyle,
                                          ),
                                          trailing: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              // Condizione per visualizzare l'icona di check se l'intervento è concluso
                                              if (intervento.concluso ?? false)
                                                Icon(Icons.check, color: Colors.black, size: 18), //
                                              Text(
                                                intervento.data != null
                                                    ? '${intervento.data!.day.toString().padLeft(2, '0')}/${intervento.data!.month.toString().padLeft(2, '0')}/${intervento.data!.year}'
                                                    : 'Nessun appuntamento stabilito',
                                                style: TextStyle(fontSize: 13, color: Colors.black),
                                              ),
                                              Text(
                                                intervento.orario_appuntamento != null
                                                    ? '${intervento.orario_appuntamento?.hour.toString().padLeft(2, '0')}:${intervento.orario_appuntamento?.minute.toString().padLeft(2, '0')}'
                                                    : 'Nessun orario stabilito',
                                                style: TextStyle(fontSize: 13, color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => DettaglioInterventoByTecnicoPage(
                                                  utente: widget.userData!,
                                                  intervento: intervento,
                                                ),
                                              ),
                                            );
                                          },
                                          tileColor: Colors.white60,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(color: getPriorityColor(intervento!.priorita!), width: 8),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  return Center(child: Text(''));
                                }
                              },
                            ),
                            const SizedBox(height: 50.0),
                            Center(
                              child: Text(
                                'Agenda commissioni',
                                style: TextStyle(
                                    fontSize: 30.0, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            FutureBuilder<List<CommissioneModel>>(
                              future: getAllCommissioniByUtente(
                                  widget.userData!.id.toString()),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(child: Text('Errore: ${snapshot.error}'));
                                } else if (snapshot.hasData) {
                                  List<CommissioneModel> commissioni = snapshot.data!;
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: commissioni.length,
                                    itemBuilder: (context, index) {
                                      CommissioneModel commissione = commissioni[index];
                                      return ListTile(
                                        title: Text(
                                            '${commissione.descrizione.toString()}'),
                                        subtitle: Text(commissione.note?? '', style: TextStyle(color: Colors.black),),
                                        trailing: Text(
                                          commissione.data!= null
                                              ? '${commissione.data!.day.toString().padLeft(2, '0')}/${commissione.data!.month.toString().padLeft(2, '0')}/${commissione.data!.year} ${commissione.data!.hour}:${commissione.data!.minute.toStringAsFixed(1)}'
                                              : 'Data non disponibile',
                                          style: TextStyle(
                                              fontSize: 16, color: Colors.black),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DettaglioCommissioneAmministrazionePage(
                                                      commissione: commissione),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                } else {
                                  return Center(child: Text('Nessun intervento trovato'));
                                }
                              },
                            ),
                          ],
                        ),

                      ]));
            } else {
              // Desktop layout
              return SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'SCADENZE',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 750,
                                height: 250,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade700),
                                ),
                                child: FutureBuilder<List<NotaTecnicoModel>>(
                                  future: Future.value(allNoteScadenze),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(child: Text('Errore: ${snapshot.error}'));
                                    } else if (snapshot.hasData) {
                                      List<NotaTecnicoModel> note = snapshot.data!;
                                      return SingleChildScrollView(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: note.length,
                                          itemBuilder: (context, index) {
                                            NotaTecnicoModel nota = note[index];
                                            String formattedDate = intl.DateFormat(
                                                'dd/MM/yyyy HH:mm')
                                                .format(
                                                DateTime.parse(nota.data!.toIso8601String()));
                                            return ListTile(
                                              title: Text(
                                                nota.utente!.nomeCompleto() ?? 'N/A',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              subtitle: Text(
                                                '$formattedDate - ${nota.nota}',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    } else {
                                      return Center(child: Text('Nessuna nota trovata'));
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: 24),
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ListaNoteUtentiPage()),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'NOTE DEGLI UTENTI',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                width: 750,
                                height: 250,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade700),
                                ),
                                child: FutureBuilder<List<NotaTecnicoModel>>(
                                  future: Future.value(allNote),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(child: Text('Errore: ${snapshot.error}'));
                                    } else if (snapshot.hasData) {
                                      List<NotaTecnicoModel> note = snapshot.data!;
                                      return SingleChildScrollView(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: note.length,
                                          itemBuilder: (context, index) {
                                            NotaTecnicoModel nota = note[index];
                                            String formattedDate = intl.DateFormat(
                                                'dd/MM/yyyy HH:mm')
                                                .format(
                                                DateTime.parse(nota.data!.toIso8601String()));
                                            return ListTile(
                                              title: Text(
                                                nota.utente!.nomeCompleto() ?? 'N/A',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              subtitle: Text(
                                                '$formattedDate - ${nota.nota}',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    } else {
                                      return Center(child: Text('Nessuna nota trovata'));
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: 24),
                              Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade700),
                                  ),
                                  width: 750,
                                  height: 300,
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: SfCalendar(
                                      view: _calendarController.view?? CalendarView.week,
                                      controller: _calendarController,
                                      dataSource: _appointmentDataSource,
                                      monthViewSettings: MonthViewSettings(
                                        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                                      ),
                                      appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details){
                                        return Container(
                                          constraints: BoxConstraints(minHeight: 70),
                                          child: details.appointments.isNotEmpty
                                              ? ListView.builder(
                                            itemCount: details.appointments.length,
                                            itemBuilder: (context, index){
                                              Appointment appointment = details.appointments.elementAt(index)!;
                                              return GestureDetector(
                                                onTap: (){
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) {
                                                        if (appointment.recurrenceId is InterventoModel) {
                                                          InterventoModel intervento = appointment.recurrenceId as InterventoModel;
                                                          return DettaglioInterventoNewPage(intervento: intervento);
                                                        } else {
                                                          CommissioneModel commissione = appointment.recurrenceId as CommissioneModel;
                                                          return DettaglioCommissioneAmministrazionePage(commissione: commissione);
                                                        }
                                                      },
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(8),
                                                    color: appointment.color,
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(6),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              appointment.subject,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: _getTextColorForBackground(appointment.color),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      if (appointment.recurrenceId is InterventoModel && (appointment.recurrenceId as InterventoModel).concluso == true)
                                                        Positioned(
                                                          top: 0,
                                                          right: 0,
                                                          child: Icon(
                                                            Icons.check_circle,
                                                            color: Colors.red[500],
                                                            size: 20,
                                                          ),
                                                        ),
                                                      if(appointment.recurrenceId is CommissioneModel && (appointment.recurrenceId as CommissioneModel).concluso == true)
                                                        Positioned(
                                                          top: 0,
                                                          right: 0,
                                                          child: Icon(
                                                            Icons.check_circle,
                                                            color: Colors.white,
                                                            size: 20,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ) : SizedBox.shrink(),
                                        );
                                      },
                                    ),
                                  )
                              )
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 350,
                                    child: buildMenuButton(icon: Icons.access_time_outlined, text: 'TIMBRATURA',
                                      onPressed: () {
                                        if(widget.userData.cognome == "Mazzei" || widget.userData.cognome == "Chiriatti"){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => TimbratureEdit(utente: widget.userData)),
                                          );
                                        } else{
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => TimbraturaPage(utente: widget.userData)),
                                          );
                                        }

                                      },
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  SizedBox(
                                    width: 350,
                                    child: buildMenuButton(icon: Icons.build, text: 'INTERVENTI',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => MenuInterventiPage(utente: widget.userData)),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 350,
                                    child: buildMenuButton(icon: Icons.calendar_month_sharp, text: 'CALENDARIO',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => CalendarioPage()),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  SizedBox(
                                    width: 350,
                                    child: buildMenuButton(icon: Icons.snippet_folder_outlined, text: 'ORDINI FORNITORE',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => MenuOrdiniFornitorePage(utente: widget.userData)),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 350,
                                    child: buildMenuButton(icon: Icons.euro_rounded, text: 'REGISTRO CASSA',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => RegistroCassaPage(userData: widget.userData)),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  SizedBox(
                                    width: 350,
                                    child: buildMenuButton(icon: Icons.rule_folder_outlined, text: 'RIPARAZIONI',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => TableMerceInRiparazionePage()),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 350,
                                    child: buildMenuButton(icon: Icons.remove_red_eye_outlined, text: 'SOPRALLUOGHI',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => MenuSopralluoghiPage(utente: widget.userData)),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  SizedBox(
                                    width: 350,
                                    child: buildMenuButton(icon: Icons.class_outlined, text: 'COMMISSIONI',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => MenuCommissioniPage()),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 350,
                                    child: buildMenuButton(icon: Icons.emoji_transportation_sharp, text: 'SPESE SU VEICOLO',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => SpesaSuVeicoloPage(utente: widget.userData)),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  SizedBox(
                                    width: 350,
                                    child: buildMenuButton(icon: Icons.do_disturb_alt_rounded, text: 'CREDENZIALI',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ListaCredenzialiPage()),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 350,
                                    child: buildMenuButton(icon: Icons.contact_emergency_rounded, text: 'CLIENTI',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ListaClientiPage()),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  SizedBox(
                                    width: 350,
                                    child: buildMenuButton(icon: Icons.warehouse_outlined, text: 'MAGAZZINO',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => TableMagazzinoPage()),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 350,
                                    child: buildMenuButton(icon: Icons.business_center_outlined, text: 'PREVENTIVI',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => LogisticaPreventiviHomepage(userData: widget.userData)),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  SizedBox(
                                    width: 350,
                                    child: buildMenuButton(icon: Icons.qr_code_2, text: 'QRCODE',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ScannerQrCodeAmministrazionePage()),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 350,
                                    child: buildMenuButton(icon: Icons.edit_note, text: 'TASK',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => TableTaskPage(utente: widget.userData)),//LogisticaPreventiviHomepage(userData: widget.userData)),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  SizedBox(
                                    width: 350,
                                    child: buildMenuButton(icon: Icons.sticky_note_2_outlined, text: 'TICKET',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => TableTicketPage()),//LogisticaPreventiviHomepage(userData: widget.userData)),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                          // GestureDetector(
                          //   onTapUp: (details) {
                          //     if (_hoveredIndex != -1) {
                          //       _navigateToPage(_hoveredIndex);
                          //     }
                          //   },
                          //   onPanUpdate: (details) {
                          //     RenderBox box = context.findRenderObject() as RenderBox;
                          //     Offset localOffset = box.globalToLocal(details.globalPosition);
                          //     setState(() {
                          //       _hoveredIndex = _calculateHoveredIndex(localOffset);
                          //     });
                          //   },
                          //   child: CustomPaint(
                          //     size: Size(600, 600),
                          //     painter: MenuPainter(
                          //           (index) {
                          //         setState(() {
                          //           _hoveredIndex = index;
                          //         });
                          //       },
                          //           () {
                          //         setState(() {
                          //           _hoveredIndex = -1;
                          //         });
                          //       },
                          //       context,
                          //       size: Size(650, 650),
                          //       hoveredIndex: _hoveredIndex,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'INTERVENTI',
                              style: TextStyle(
                                  fontSize: 30.0, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 15),
                            IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () async {
                                final DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (pickedDate != null && pickedDate != selectedDate) {
                                  setState(() {
                                    selectedDate = pickedDate;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      FutureBuilder<List<InterventoModel>>(
                        future: getAllInterventiByUtente(widget.userData!.id.toString(), selectedDate),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Errore: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            List<InterventoModel> interventi = snapshot.data!;
                            interventi = interventi.where((intervento) => intervento.merce == null).toList();
                            interventi = interventi.where((intervento) {
                              return intervento.data == null || intervento.data!.isSameDay(selectedDate);
                            }).toList();
                            if (interventi.isEmpty) {
                              return Center(child: Text('', style: TextStyle(color: Colors.black,
                                  fontSize: 15.0)));
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: interventi.length,
                              itemBuilder: (context, index) {
                                InterventoModel intervento = interventi[index];

                                // Metodo per mappare la priorità al colore corrispondente
                                Color getPriorityColor(Priorita priorita) {
                                  switch (priorita) {
                                    case Priorita.BASSA:
                                      return Colors.lightGreen;
                                    case Priorita.MEDIA:
                                      return Colors.yellow; // grigio chiaro
                                    case Priorita.ALTA:
                                      return Colors.orange; // giallo chiaro
                                    case Priorita.URGENTE:
                                      return Colors.red; // azzurro chiaro
                                    default:
                                      return Colors.blueGrey[200]!;
                                  }
                                }
                                Color backgroundColor =  getPriorityColor(intervento.priorita!);

                                TextStyle textStyle = intervento.concluso ?? false
                                    ? TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)
                                    : TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);

                                return Card(
                                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    title: Text(
                                      '${intervento.cliente!.denominazione!}\n ${intervento.destinazione?.citta}, ${intervento.destinazione?.indirizzo}',
                                      style: textStyle,
                                    ),
                                    subtitle: Text(
                                      '${intervento.titolo}',
                                      style: textStyle,
                                    ),
                                    trailing: Column(
                                      children: [
                                        Text(
                                          // Formatta la data secondo il tuo formato desiderato
                                          intervento.data!= null
                                              ? '${intervento.data!.day}/${intervento.data!.month}/${intervento.data!.year}'
                                              : 'Nessun appuntamento stabilito',
                                          style: TextStyle(fontSize: 10, color: Colors.black),
                                        ),
                                        Text(
                                          intervento.orario_appuntamento!= null
                                              ? '${intervento.orario_appuntamento?.hour}:${intervento.orario_appuntamento?.minute}'
                                              : 'Nessun orario stabilito',
                                          style: TextStyle(fontSize: 10, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DettaglioInterventoByTecnicoPage(
                                            utente: widget.userData!,
                                            intervento: intervento,
                                          ),
                                        ),
                                      );
                                    },
                                    tileColor: backgroundColor,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Colors.grey.shade100, width: 0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return Center(child: Text(''));
                          }
                        },
                      ),
                      FutureBuilder<List<RelazioneUtentiInterventiModel>>(
                        future: getAllRelazioniByUtente(widget.userData!.id.toString(), selectedDate),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Errore: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            List<RelazioneUtentiInterventiModel> relazioni = snapshot.data!;
                            relazioni = relazioni.where((relazione) => relazione.intervento!.concluso != true && relazione.intervento!.merce == null).toList();
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: relazioni.length,
                              itemBuilder: (context, index) {
                                RelazioneUtentiInterventiModel relazione = relazioni[index];
                                Color backgroundColor = relazione.intervento!.concluso ?? false ? Colors.green : Colors.white;
                                TextStyle textStyle = relazione.intervento?.concluso ?? false
                                    ? TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)
                                    : TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);
                                return ListTile(
                                  title: Text(
                                    '${relazione.intervento?.cliente!.denominazione!}\n ${relazione.intervento?.destinazione?.citta}, ${relazione.intervento?.destinazione?.indirizzo}',
                                    style: textStyle,
                                  ),
                                  subtitle: Text(
                                    '${relazione.intervento?.descrizione}',
                                    style: textStyle,
                                  ),
                                  trailing: Column(
                                    children: [
                                      Text(
                                        // Formatta la data secondo il tuo formato desiderato
                                        relazione.intervento?.data!= null
                                            ? '${relazione.intervento?.data!.day}/${relazione.intervento?.data!.month}/${relazione.intervento?.data!.year}'
                                            : 'Nessun appuntamento stabilito',
                                        style: TextStyle(fontSize: 10, color: Colors.black),
                                      ),
                                      Text(
                                        relazione.intervento?.orario_appuntamento!= null
                                            ? '${relazione.intervento?.orario_appuntamento?.hour}:${relazione.intervento?.orario_appuntamento?.minute}'
                                            : 'Nessun orario stabilito',
                                        style: TextStyle(fontSize: 10, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DettaglioInterventoByTecnicoPage(
                                              utente: widget.userData!,
                                              intervento: relazione.intervento!,
                                            ),
                                      ),
                                    );
                                  },
                                  tileColor: backgroundColor,
                                );
                              },
                            );
                          } else {
                            return Center(child: Text(''));
                          }
                        },
                      ),
                      Center(
                        child: Text(
                          'Interventi di settore'.toUpperCase(),
                          style: TextStyle(
                              fontSize: 30.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      FutureBuilder<List<InterventoModel>>(
                        future: getAllInterventiBySettore(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Errore: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            List<InterventoModel> interventi = snapshot.data!;
                            interventi = interventi.where((intervento) => intervento.merce == null).toList();
                            interventi = interventi.where((intervento) {
                              return intervento.data == null || intervento.data!.isSameDay(selectedDate);
                            }).toList();
                            if (interventi.isEmpty) {
                              return Center(child: Text('', style: TextStyle(color: Colors.black,
                                  fontSize: 15.0)));
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: interventi.length,
                              itemBuilder: (context, index) {
                                InterventoModel intervento = interventi[index];
                                // Metodo per mappare la priorità al colore corrispondente
                                Color getPriorityColor(Priorita priorita) {
                                  switch (priorita) {
                                    case Priorita.BASSA:
                                      return Colors.lightGreen;
                                    case Priorita.MEDIA:
                                      return Colors.yellow; // grigio chiaro
                                    case Priorita.ALTA:
                                      return Colors.orange; // giallo chiaro
                                    case Priorita.URGENTE:
                                      return Colors.red; // azzurro chiaro
                                    default:
                                      return Colors.blueGrey[200]!;
                                  }
                                }
                                Color backgroundColor =  getPriorityColor(intervento.priorita!);

                                TextStyle textStyle = intervento.concluso ?? false
                                    ? TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)
                                    : TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);

                                return Card(
                                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    title: Text(
                                      '${intervento.cliente!.denominazione!}\n ${intervento.destinazione?.citta}, ${intervento.destinazione?.indirizzo}',
                                      style: textStyle,
                                    ),
                                    subtitle: Text(
                                      '${intervento.titolo}',
                                      style: textStyle,
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Condizione per visualizzare l'icona di check se l'intervento è concluso
                                        if (intervento.concluso ?? false)
                                          Icon(Icons.check, color: Colors.white, size: 15), // Check icon
                                        Text(
                                          intervento.data != null
                                              ? '${intervento.data!.day}/${intervento.data!.month}/${intervento.data!.year}'
                                              : 'Nessun appuntamento stabilito',
                                          style: TextStyle(fontSize: 10, color: Colors.black),
                                        ),
                                        Text(
                                          intervento.orario_appuntamento != null
                                              ? '${intervento.orario_appuntamento?.hour}:${intervento.orario_appuntamento?.minute}'
                                              : 'Nessun orario stabilito',
                                          style: TextStyle(fontSize: 10, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DettaglioInterventoByTecnicoPage(
                                            utente: widget.userData!,
                                            intervento: intervento,
                                          ),
                                        ),
                                      );
                                    },
                                    tileColor: backgroundColor,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Colors.grey.shade100, width: 0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return Center(child: Text(''));
                          }
                        },
                      ),
                      const SizedBox(height: 50.0),
                      Center(
                        child: Text(
                          'MERCE IN RIPARAZIONE',
                          style: TextStyle(
                              fontSize: 30.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      FutureBuilder<List<InterventoModel>>(
                        future: getMerce(widget.userData!.id.toString()),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Errore: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            List<InterventoModel> merce = snapshot.data!;

                            // Filtra i dati della lista per mostrare solo quelli con merce presente
                            merce = merce.where((item) => item.merce != null).toList();
                            if (merce.isEmpty) {
                              return Center(child: Text('', style: TextStyle(color: Colors.black,
                                  fontSize: 15.0)));
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: merce.length,
                              itemBuilder: (context, index) {
                                InterventoModel singolaMerce = merce[index];

                                // Metodo per mappare la priorità al colore corrispondente
                                Color getPriorityColor(Priorita priorita) {
                                  switch (priorita) {
                                    case Priorita.BASSA:
                                      return Colors.lightGreen;
                                    case Priorita.MEDIA:
                                      return Colors.yellow;
                                    case Priorita.ALTA:
                                      return Colors.orange;
                                    case Priorita.URGENTE:
                                      return Colors.red;
                                    default:
                                      return Colors.blueGrey[200]!;
                                  }
                                }

                                // Determina il colore in base alla priorità della merce
                                Color backgroundColor = getPriorityColor(singolaMerce.priorita ?? Priorita.BASSA);

                                TextStyle textStyle = singolaMerce.concluso ?? false
                                    ? TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)
                                    : TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);

                                return Card(
                                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    title: Text(
                                      '${singolaMerce.merce?.articolo ?? "Articolo non specificato"}',
                                      style: textStyle,
                                    ),
                                    subtitle: Text(
                                      '${singolaMerce.merce?.difetto_riscontrato ?? "Difetto non specificato"}',
                                      style: textStyle,
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Data arrivo merce:', style: TextStyle(fontSize: 10, color: Colors.black)),
                                        SizedBox(height: 3),
                                        Text(
                                          singolaMerce.data_apertura_intervento != null
                                              ? DateFormat("dd/MM/yyyy").format(singolaMerce.data_apertura_intervento!)
                                              : 'Data non disponibile',
                                          style: TextStyle(fontSize: 10, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DettaglioMerceInRiparazioneByTecnicoPage(
                                            intervento: singolaMerce,
                                            merce: singolaMerce.merce!,
                                            utente: widget.userData!,
                                          ),
                                        ),
                                      );
                                    },
                                    tileColor: backgroundColor,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Colors.grey.shade100, width: 0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return Center(child: Text('Nessuna merce trovata'));
                          }
                        },
                      ),
                      FutureBuilder<List<RelazioneUtentiInterventiModel>>(
                        future: getAllRelazioniByUtente(widget.userData!.id.toString(), selectedDate),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Errore: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            List<RelazioneUtentiInterventiModel> relazioni = snapshot.data!;

                            // Filtra la lista per includere solo relazioni con merce associata e non conclusi
                            relazioni = relazioni.where((relazione) => relazione.intervento!.concluso != true && relazione.intervento!.merce != null).toList();

                            if (relazioni.isEmpty) {
                              return Center(child: Text('', style: TextStyle(color: Colors.black,
                                  fontSize: 15.0)));
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: relazioni.length,
                              itemBuilder: (context, index) {
                                RelazioneUtentiInterventiModel relazione = relazioni[index];

                                // Funzione per ottenere il colore basato sulla priorità dell'intervento
                                Color getPriorityColor(Priorita priorita) {
                                  switch (priorita) {
                                    case Priorita.BASSA:
                                      return Colors.lightGreen;
                                    case Priorita.MEDIA:
                                      return Colors.yellow;
                                    case Priorita.ALTA:
                                      return Colors.orange;
                                    case Priorita.URGENTE:
                                      return Colors.red;
                                    default:
                                      return Colors.blueGrey[200]!;
                                  }
                                }

                                // Determina il colore di sfondo in base alla priorità
                                Color backgroundColor = getPriorityColor(relazione.intervento!.priorita ?? Priorita.BASSA);

                                TextStyle textStyle = relazione.intervento?.concluso ?? false
                                    ? TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)
                                    : TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);

                                return Card(
                                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    title: Text(
                                      '${relazione.intervento?.cliente!.denominazione} \n${relazione.intervento?.descrizione}',
                                      style: textStyle,
                                    ),
                                    subtitle: Text(
                                      '${relazione.intervento?.merce?.difetto_riscontrato}',
                                      style: textStyle,
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Data arrivo merce:', style: TextStyle(fontSize: 10, color: Colors.black)),
                                        SizedBox(height: 3),
                                        Text(
                                          relazione.intervento?.data_apertura_intervento != null
                                              ? DateFormat("dd/MM/yyyy").format(relazione.intervento!.data_apertura_intervento!)
                                              : 'Data non disponibile',
                                          style: TextStyle(fontSize: 10, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DettaglioMerceInRiparazioneByTecnicoPage(
                                            utente: widget.userData!,
                                            intervento: relazione.intervento!,
                                            merce: relazione.intervento!.merce!,
                                          ),
                                        ),
                                      );
                                    },
                                    tileColor: backgroundColor,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Colors.grey.shade100, width: 0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return Center(child: Text(''));
                          }
                        },
                      ),
                      const SizedBox(height: 50.0),
                      const Text(
                        'AGENDA COMMISSIONI',
                        style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20.0),
                      FutureBuilder<List<CommissioneModel>>(
                        future: getAllCommissioniByUtente(widget.userData!.id.toString()),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Errore: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            List<CommissioneModel> commissioni = snapshot.data!;
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: commissioni.length,
                              itemBuilder: (context, index) {
                                CommissioneModel commissione = commissioni[index];
                                return ListTile(
                                  title: Text('${commissione.descrizione.toString()}', style: TextStyle(color: Colors.black)),
                                  subtitle: Text(commissione.note ?? '', style: TextStyle(color: Colors.black)),
                                  trailing: Text(
                                    // Formatta la data secondo il tuo formato desiderato
                                    commissione.data != null
                                        ? '${commissione.data!.day}/${commissione.data!.month}/${commissione.data!.year} ${commissione.data!.hour}:${commissione.data!.minute.toStringAsFixed(1)}'
                                        : 'Data non disponibile',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black), // Stile opzionale per la data
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DettaglioCommissioneTecnicoPage(
                                                commissione: commissione),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          } else {
                            return Center(child: Text('Nessuna commissione trovata'));
                          }
                        },
                      ),
                    ],
                  )
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildMenuButton(
      {required IconData icon, required String text, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade400, Colors.red.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
              SizedBox(width: 30),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}


//}// class MenuPainter extends CustomPainter {
//   final Function(int) onHover;
//   final Function() onHoverExit;
//   final Size size;
//   final int hoveredIndex;
//   final BuildContext context; // Add BuildContext
//
//   MenuPainter(this.onHover, this.onHoverExit, this.context, {required this.size, required this.hoveredIndex});
//
//   // List of menu items
//   final List<MenuItem> _menuItems = [
//     MenuItem(icon: Icons.calendar_month_outlined, label: 'CALENDARIO'),
//     MenuItem(icon: Icons.snippet_folder_outlined, label: 'ORDINI FORNITORE'),
//     MenuItem(icon: Icons.more_time, label: 'TIMBRATURA'),
//     MenuItem(icon: Icons.build, label: 'LISTA INTERVENTI'),
//     MenuItem(icon: Icons.rule_folder_outlined, label: 'RIPARAZIONI'),
//     MenuItem(icon: Icons.remove_red_eye_outlined, label: 'SOPRALLUOGHI'),
//     MenuItem(icon: Icons.class_outlined, label: 'COMMISSIONI'),
//     MenuItem(icon: Icons.emoji_transportation_sharp, label: 'SPESE SU VEICOLO'),
//     MenuItem(icon: Icons.do_disturb_alt_rounded, label: 'CREDENZIALI'),
//     MenuItem(icon: Icons.contact_emergency_rounded, label: 'LISTA CLIENTI'),
//     MenuItem(icon: Icons.warehouse_rounded, label: 'MAGAZZINO'),
//     MenuItem(icon: Icons.euro_rounded, label: 'REGISTRO CASSA'),
//     MenuItem(icon: Icons.business_center_outlined, label: 'PREVENTIVI'),
//     MenuItem(icon: Icons.qr_code_2_outlined, label: 'SCANNER QRCODE'),
//   ];
//
//   TextPainter labelPainter = TextPainter(
//     text: TextSpan(
//       text: '',
//       style: TextStyle(
//         fontSize: 18,
//         color: Colors.black,
//       ),
//     ),
//     textAlign: TextAlign.center,
//     textDirection: TextDirection.ltr,
//   );
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..style = PaintingStyle.fill;
//
//     // Radius
//     final outerRadius = size.width / 2;
//     final innerRadius = size.width / 4.5;
//     final center = Offset(size.width / 2, size.height / 2);
//
//     // Draw the menu items
//     final angle = 2 * math.pi / _menuItems.length;
//     for (int i = 0; i < _menuItems.length; i++) {
//       final menuItem = _menuItems[i];
//       final startAngle = i * angle;
//       final sweepAngle = angle - 0.02; // Add a small gap between each arc
//
//       // Determine if this menu item is hovered
//       bool isHovered = hoveredIndex == i;
//
//       // Calculate the scale factor for the hovered section
//       double scaleFactor = isHovered ? 1.2 : 1.0;
//
//       // Draw the sections
//       paint.color = isHovered ? Colors.red[900]!.withOpacity(0.6 ) : Colors.red;
//       Path path = Path();
//       path.arcTo(
//         Rect.fromCircle(center: center, radius: outerRadius * scaleFactor),
//         startAngle,
//         sweepAngle,
//         false,
//       );
//       path.arcTo(
//         Rect.fromCircle(center: center, radius: innerRadius * scaleFactor),
//         startAngle + sweepAngle,
//         -sweepAngle,
//         false,
//       );
//       path.close();
//       canvas.drawPath(path, paint);
//
//       //Draw the icon in white
//       final iconX = center.dx +
//           (outerRadius * scaleFactor + (isHovered ? innerRadius * scaleFactor * 1.2 : innerRadius * scaleFactor)) /
//               2 *
//               math.cos(startAngle + sweepAngle / 2);
//       final iconY = center.dy +
//           (outerRadius * scaleFactor + (isHovered ? innerRadius * scaleFactor * 1.2 : innerRadius * scaleFactor)) /
//               2 *
//               math.sin(startAngle + sweepAngle / 2);
//       TextPainter textPainter = TextPainter(
//         text: TextSpan(
//           text: String.fromCharCode(menuItem.icon.codePoint),
//           style: TextStyle(
//             fontSize: isHovered ? 28 : 24,
//             fontFamily: menuItem.icon.fontFamily,
//             color: Colors.white,
//           ),
//         ),
//         textAlign: TextAlign.center,
//         textDirection: TextDirection.ltr,
//       );
//       textPainter.layout();
//       textPainter.paint(
//           canvas,
//           Offset(iconX - textPainter.width / 2,
//               iconY - textPainter.height / 2));
//
//       // Draw the label if hovered
//       if (isHovered) {
//         final labelX = center.dx;
//         labelPainter.text = TextSpan(
//           text: menuItem.label,
//           style: TextStyle(
//               fontSize: 20,
//               color: Colors.black,
//               fontWeight: FontWeight.bold
//           ),
//         );
//         labelPainter.layout();
//         final labelHeight = labelPainter.height;
//         final labelY = center.dy - innerRadius * scaleFactor * 0.1 + labelHeight / 2;
//         labelPainter.paint(
//             canvas,
//             Offset(labelX - labelPainter.width / 2,
//                 labelY - labelHeight / 2));
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(MenuPainter oldDelegate) => oldDelegate.hoveredIndex != hoveredIndex;
//
//   @override
//   bool hitTest(Offset position) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final distance = math.sqrt(math.pow(position.dx - center.dx, 2) + math.pow(position.dy - center.dy, 2));
//     final radius = size.width / 2;
//
//     if (distance <= radius) {
//       final angle = (math.atan2(position.dy - center.dy, position.dx - center.dx) + math.pi * 2) % (math.pi * 2);
//       final section = (angle / (2 * math.pi / _menuItems.length)).floor();
//
//       final newIndex = section % _menuItems.length;
//       onHover(newIndex); // Call the onHover callback
//       return true;
//     }
//     onHoverExit(); // Call the onHoverExit callback
//     return false;
//   }
// }
//
// class MenuItem {
//   final IconData icon;
//   final String label;
//
//   MenuItem({required this.icon, required this.label});