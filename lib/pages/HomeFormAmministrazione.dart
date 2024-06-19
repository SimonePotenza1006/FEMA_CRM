import 'dart:async';
import 'dart:convert';
import 'package:fema_crm/databaseHandler/DbHelper.dart';
import 'package:fema_crm/model/OrdinePerInterventoModel.dart';
import 'package:fema_crm/pages/ReportMerceInRiparazionePage.dart';
import 'package:fema_crm/pages/TimbraturaPage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:fema_crm/pages/LogisticaPreventiviHomepage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import '../main.dart';
import '../model/CommissioneModel.dart';
import '../model/InterventoModel.dart';
import '../model/NotaTecnicoModel.dart';
import '../model/RelazioneUtentiInterventiModel.dart';
import '../model/UtenteModel.dart';
import '../model/VeicoloModel.dart';
import 'CalendarioPage.dart';
import 'DettaglioCommissioneAmministrazionePage.dart';
import 'DettaglioInterventoByTecnicoPage.dart';
import 'ImpostazioniPage.dart';
import 'ListaClientiPage.dart';
import 'ListaCredenzialiPage.dart';
import 'ListaInterventiFinalPage.dart';
import 'ListaInterventiNewPage.dart';
import 'ListaInterventiPage.dart';
import 'ListaNoteUtentiPage.dart';
import 'ListiniPage.dart';
import 'MagazzinoPage.dart';
import 'MenuCommissioniPage.dart';
import 'MenuMerceInRiparazionePage.dart';
import 'MenuOrdiniFornitorePage.dart';
import 'MenuSopralluoghiPage.dart';
import 'RegistroCassaPage.dart';
import 'ScannerQrCodeAmministrazionePage.dart';
import 'SpesaSuVeicoloPage.dart';

class HomeFormAmministrazione extends StatefulWidget {
  final UtenteModel userData;

  const HomeFormAmministrazione({Key? key, required this.userData})
      : super(key: key);

  @override
  _HomeFormAmministrazioneState createState() =>
      _HomeFormAmministrazioneState();
}

class _HomeFormAmministrazioneState extends State<HomeFormAmministrazione> {
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ss').format(
      DateTime.now());
  List<NotaTecnicoModel> allNote = [];
  List<VeicoloModel> allVeicoli = [];
  bool ingressoSaved = false;
  DateTime selectedDate = DateTime.now();
  DateTime today = DateTime.now();
  Map<String, bool> _publishedNotes = {};
  List<OrdinePerInterventoModel> allOrdini = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ScreenUtil.init(context);
  }

  @override
  void initState() {
    super.initState();
    getAllVeicoli().then((_) {
      checkScadenzeVeicoli().then((_) {
        getNote();
      });
    });
    getAllOrdini();
    _scheduleGetAllOrdini();
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

  Future<void> getAllVeicoli() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/veicolo');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<VeicoloModel> veicoli = [];
        for (var item in jsonData) {
          veicoli.add(VeicoloModel.fromJson(item));
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

  Future<void> checkScadenzeVeicoli() async {
    for (var veicolo in allVeicoli) {
      await checkScadenzeDate(veicolo);
    }
  }

  Future<void> checkScadenzeDate(VeicoloModel veicolo) async {
    // Controllo scadenza bollo
    if (veicolo.data_scadenza_bollo!= null) {
      final differenceBollo = veicolo.data_scadenza_bollo!.difference(today).inDays;
      if (differenceBollo <= 30) {
        final noteKey = '${veicolo.id}_bollo_${today.toIso8601String()}';
        if (_publishedNotes.containsKey(noteKey)) {
          return; // Note has already been published today
        }
        try {
          final response = await http.post(
            Uri.parse('$ipaddress/api/noteTecnico'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'utente': widget.userData.toMap(),
              'data': DateTime.now().toIso8601String(),
              'nota': "Il veicolo ${veicolo.descrizione} ha il bollo in scadenza tra ${differenceBollo} giorni!",
            }),
          );
          print("Nota scadenza bollo creata!");
          // Mark note as published today
          _publishedNotes[noteKey] = true;
        } catch (e) {
          print("Errore nota scadenza bollo: $e");
        }
      }
    }
    // Controllo scadenza polizza
    if (veicolo.data_scadenza_polizza!= null) {
      final differencePolizza = veicolo.data_scadenza_polizza!.difference(today).inDays;
      if (differencePolizza <= 30) {
        final noteKey = '${veicolo.id}_polizza_${today.toIso8601String()}';
        if (_publishedNotes.containsKey(noteKey)) {
          return; // Note has already been published today
        }
        try {
          final response = await http.post(
            Uri.parse('$ipaddress/api/noteTecnico'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'utente': widget.userData.toMap(),
              'data': DateTime.now().toIso8601String(),
              'nota': "Il veicolo ${veicolo.descrizione} ha la polizza in scadenza tra ${differencePolizza} giorni!",
            }),
          );
          print("Nota scadenza polizza creata!");
          // Mark note as published today
          _publishedNotes[noteKey] = true;
        } catch (e) {
          print("Errore nota scadenza polizza: $e");
        }
      }
    }
    // Controllo scadenza tagliando
    if (veicolo.data_tagliando!= null) {
      final differenceTagliando = today.difference(veicolo.data_tagliando!).inDays;
      if (differenceTagliando >= 700) {
        final noteKey = '${veicolo.id}_tagliando_${today.toIso8601String()}';
        if (_publishedNotes.containsKey(noteKey)) {
          return; // Note has already been published today
        }
        try {
          final response = await http.post(
            Uri.parse('$ipaddress/api/noteTecnico'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'utente': widget.userData.toMap(),
              'data': DateTime.now().toIso8601String(),
              'nota': "Il veicolo ${veicolo.descrizione} ha superato i 700 giorni dall'ultimo tagliando!",
            }),
          );
          print("Nota promemoria tagliando creata!");
          // Mark note as published today
          _publishedNotes[noteKey] = true;
        } catch (e) {
          print("Errore nota promemoria tagliando: $e");
        }
      }
    }
  }

  Future<List<CommissioneModel>> getAllCommissioniByUtente(
      String userId) async {
    try {
      String userId = widget.userData.id.toString();
      http.Response response = await http
          .get(Uri.parse('${ipaddress}/api/commissione/utente/$userId'));
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

  Future<List<NotaTecnicoModel>> getNote() async {
    try {
      http.Response response = await http.get(
          Uri.parse('${ipaddress}/api/noteTecnico/ordered'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<NotaTecnicoModel> note = [];
        for (var item in responseData) {
          NotaTecnicoModel nota = NotaTecnicoModel.fromJson(item);
          note.add(nota);
        }
        setState(() {
          allNote = note;
        });
        return note;
      } else {
        print('Error fetching note: ${response.statusCode}');
        return []; // Return an empty list on error
      }
    } catch (e) {
      print('Error fetching note: $e');
      return []; // Return an empty list on error
    }
  }

  Future<List<RelazioneUtentiInterventiModel>> getAllRelazioniByUtente(String userId, DateTime date) async {
    try{
      String userId = widget.userData!.id.toString();
      http.Response response = await http
          .get(Uri.parse('${ipaddress}/api/relazioneUtentiInterventi/utente/$userId'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<RelazioneUtentiInterventiModel> allRelazioniByUtente = [];
        for(var item in responseData){
          RelazioneUtentiInterventiModel relazione = RelazioneUtentiInterventiModel.fromJson(item);
          if(relazione.intervento?.concluso == false){
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
          .get(Uri.parse('${ipaddress}/api/intervento/utente/$userId'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<InterventoModel> allInterventiByUtente = [];
        for (var interventoJson in responseData) {
          InterventoModel intervento = InterventoModel.fromJson(interventoJson);
          // Aggiungi il filtro per interventi non conclusi
            allInterventiByUtente.add(intervento);
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


  Future<void> saveIngresso() async {
    try {
      final response = await http.post(
        Uri.parse('$ipaddress/api/ingresso'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orario': formattedDate,
          'utente': widget.userData.toMap(),
        }),
      );
    } catch (e) {
      print('Errore durante il salvataggio dell\'intervento: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'F.E.M.A. Amministrazione',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              // Icona di ricarica, puoi scegliere un'altra icona se preferisci
              color: Colors.white,
            ),
            onPressed: () {
              // Funzione per ricaricare la pagina
              setState(() {});
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>
                    ImpostazioniPage(userData: widget.userData,)),
              );
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
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Bentornato ${widget.userData.nome.toString()}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 40),
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
                        Expanded(
                          child: Text(
                            'Note degli utenti',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey, // Colore dell'icona
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade700),
                  ),
                  height: 250, // Imposta l'altezza fissa desiderata
                  child: FutureBuilder<List<NotaTecnicoModel>>(
                    future: Future.value(allNote),
                    // Utilizza i dati già recuperati
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Errore: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        List<NotaTecnicoModel> note = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: note.length,
                          itemBuilder: (context, index) {
                            NotaTecnicoModel nota = note[index];
                            String formattedDate = DateFormat(
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
                        );
                      } else {
                        return Center(child: Text('Nessuna nota trovata'));
                      }
                    },
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildButton(
                      icon: Icons.calendar_month_outlined,
                      text: 'Calendario',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CalendarioPage()),
                        );
                      },
                    ),
                    SizedBox(width: 20),
                    buildButton(
                      icon: Icons.snippet_folder_outlined,
                      text: 'Ordini fornitore',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuOrdiniFornitorePage(utente: widget.userData),
                          ),
                        );
                      },
                      showBadge: true, // Add this parameter
                    )
                  ],
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton(
                      icon: Icons.more_time,
                      text: 'Timbratura',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TimbraturaPage(utente: widget.userData)),
                        );
                      },
                    ),
                    SizedBox(width: 20),
                    buildButton(
                      icon: Icons.build,
                      text: 'Lista Interventi',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (
                                  context) => const ListaInterventiFinalPage()),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton(
                      icon: Icons.rule_folder_outlined,
                      text: 'Riparazioni',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ReportMerceInRiparazionePage()),
                        );
                      },
                    ),
                    SizedBox(width: 20),
                    buildButton(
                      icon: Icons.remove_red_eye_outlined,
                      text: 'Sopralluoghi',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MenuSopralluoghiPage(
                                      utente: widget.userData)),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton(
                      icon: Icons.class_outlined,
                      text: 'Commissioni',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MenuCommissioniPage()),
                        );
                      },
                    ),
                    SizedBox(width: 20),
                    buildButton(
                      icon: Icons.emoji_transportation_sharp,
                      text: 'Spese su veicolo',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SpesaSuVeicoloPage(utente: widget.userData)),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton(
                      icon: Icons.do_disturb_rounded,
                      text: 'Credenziali',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (
                                  context) => const ListaCredenzialiPage()),
                        );
                      },
                    ),
                    SizedBox(width: 20),
                    buildButton(
                      icon: Icons.contact_emergency_rounded,
                      text: 'Lista Clienti',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ListaClientiPage()),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton(
                      icon: Icons.warehouse_sharp,
                      text: 'Magazzino',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MagazzinoPage()),
                        );
                      },
                    ),
                    SizedBox(width: 20),
                    buildButton(
                      icon: Icons.euro_sharp,
                      text: 'Registro Cassa',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  RegistroCassaPage(userData: widget.userData)),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton(
                      icon: Icons.assignment_outlined,
                      text: 'Listini',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ListiniPage()),
                        );
                      },
                    ),
                    SizedBox(width: 20),
                    buildButton(
                      icon: Icons.business_center_outlined,
                      text: 'Preventivi',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  LogisticaPreventiviHomepage(
                                      userData: widget.userData)),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildButton(
                      icon: Icons.qr_code_2_outlined,
                      text: 'Scanner QrCode',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const ScannerQrCodeAmministrazionePage()),
                        );
                      },
                    ),
                    SizedBox(width: 20),
                    //
                    //
                    //
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
                      interventi = interventi.where((intervento) => intervento.data!.isSameDay(selectedDate)).toList();
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: interventi.length,
                        itemBuilder: (context, index) {
                          InterventoModel intervento = interventi[index];
                          Color backgroundColor = intervento.concluso ?? false ? Colors.green : Colors.white;
                          TextStyle textStyle = intervento.concluso ?? false ? TextStyle(color: Colors.white, fontSize: 15) : TextStyle(color: Colors.black, fontSize: 15);

                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // aggiungi padding orizzontale
                            elevation: 4, // aggiungi ombreggiatura
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            // aggiungi bordi arrotondati
                            child: ListTile(
                              title: Text(
                                '${intervento.descrizione}',
                                style: textStyle,
                              ),
                              subtitle: Text(
                                intervento.cliente?.denominazione.toString()?? '',
                                style: textStyle,
                              ),
                              trailing: Column(
                                children: [
                                  Text(
                                    // Formatta la data secondo il tuo formato desiderato
                                    intervento.data!= null
                                        ? '${intervento.data!.day}/${intervento.data!.month}/${intervento.data!.year}'
                                        : 'Data non disponibile',
                                    style: TextStyle(
                                      fontSize: 16, // Stile opzionale per la data
                                      color: intervento.concluso ?? false ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    intervento.orario_appuntamento!= null
                                        ? '${intervento.orario_appuntamento?.hour}:${intervento.orario_appuntamento?.minute}'
                                        : 'Nessun orario di appuntamento',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: intervento.concluso ?? false ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DettaglioInterventoByTecnicoPage(
                                          utente: widget.userData,
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
                      return Center(child: Text('Nessun intervento trovato'));
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
                      relazioni = relazioni.where((relazione) => relazione.intervento!.data!.isSameDay(selectedDate)).toList();
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: relazioni.length,
                        itemBuilder: (context, index) {
                          RelazioneUtentiInterventiModel relazione = relazioni[index];
                          Color backgroundColor = relazione.intervento!.concluso ?? false ? Colors.green : Colors.white;
                          TextStyle textStyle = relazione.intervento!.concluso ?? false ? TextStyle(color: Colors.white, fontSize: 15) : TextStyle(color: Colors.black, fontSize: 15);
                          return ListTile(
                            title: Text(
                              '${relazione.intervento?.descrizione}',
                              style: textStyle,
                            ),
                            subtitle: Text(
                              relazione.intervento?.cliente?.denominazione.toString()?? '',
                              style: textStyle,
                            ),
                            trailing: Column(
                              children: [
                                Text(
                                  // Formatta la data secondo il tuo formato desiderato
                                  relazione.intervento?.data!= null
                                      ? '${relazione.intervento?.data!.day}/${relazione.intervento?.data!.month}/${relazione.intervento?.data!.year}'
                                      : 'Data non disponibile',
                                  style: TextStyle(
                                    fontSize: 16, // Stile opzionale per la data
                                    color: relazione.intervento!.concluso ?? false ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  relazione.intervento?.orario_appuntamento!= null
                                      ? '${relazione.intervento?.orario_appuntamento?.hour}:${relazione.intervento?.orario_appuntamento?.minute}'
                                      : 'Nessun orario di appuntamento',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: relazione.intervento!.concluso ?? false ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DettaglioInterventoByTecnicoPage(
                                        utente: widget.userData,
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
                      return Center(child: Text('Nessun intervento trovato'));
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
                            subtitle: Text(commissione.note ?? ''),
                            trailing: Text(
                              // Formatta la data secondo il tuo formato desiderato
                              commissione.data != null
                                  ? '${commissione.data!.day}/${commissione
                                  .data!.month}/${commissione.data!
                                  .year} ${commissione.data!.hour}:${commissione
                                  .data!.minute.toStringAsFixed(1)}'
                                  : 'Data non disponibile',
                              style: TextStyle(
                                  fontSize: 16), // Stile opzionale per la data
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
          )),
    );
  }



  Widget buildButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    bool showBadge = false,
  }) {
    double textSize = 20; // Fissa dimensione del testo

    return Expanded(
      child: Card(
        color: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 10, // aggiungi ombreggiatura
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.all(8.0), // Aumenta il padding per evitare tagli
            child: Column(
              children: [
                SizedBox(height: 25.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: textSize,
                    ),
                    SizedBox(width: 10.0), // Aumenta la distanza tra icona e testo
                    Text(
                      text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: textSize,
                      ),
                    ),
                    // Add the badge only if showBadge is true
                    if (showBadge && allOrdini.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(left: 15.0),
                        padding: EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: Colors.red[900],
                          shape: BoxShape.circle,

                        ),
                        child: Text(
                          allOrdini.length.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 25.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}