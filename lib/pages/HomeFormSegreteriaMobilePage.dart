import 'dart:io';
import 'package:fema_crm/model/MerceInRiparazioneModel.dart';
import 'package:fema_crm/pages/MenuCommissioniPage.dart';
import 'package:fema_crm/pages/MenuInterventiPage.dart';
import 'package:fema_crm/pages/MenuSopralluoghiPage.dart';
import 'package:fema_crm/pages/MenuSopralluoghiTecnicoPage.dart';
import 'package:fema_crm/pages/RegistroCassaPage.dart';
import 'package:fema_crm/pages/SpesaSuVeicoloPage.dart';
import 'package:fema_crm/pages/TableTaskPage.dart';
import 'package:fema_crm/pages/TimbraturaPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'dart:convert';
import '../main.dart';
import '../model/CommissioneModel.dart';
import '../model/InterventoModel.dart';
import '../model/RelazioneUtentiInterventiModel.dart';
import '../model/TaskModel.dart';
import '../model/TipoTaskModel.dart';
import '../model/UtenteModel.dart';
import 'CalendarioPage.dart';
import 'CalendarioUtentePage.dart';
import 'DettaglioCommissioneTecnicoPage.dart';
import 'DettaglioInterventoByTecnicoPage.dart';
import 'DettaglioMerceInRiparazioneByTecnicoPage.dart';
import 'FormOrdineFornitorePage.dart';
import 'InterventoTecnicoForm.dart';
import 'InizializzazionePreventivoByTecnicoPage.dart';
import 'ListaPreventiviTecnicoPage.dart';
import 'MenuOrdiniFornitorePage.dart';
import 'SopralluogoTecnicoForm.dart';
import '../databaseHandler/DbHelper.dart';
import 'dart:math' as math;

class HomeFormSegreteriaMobilePage extends StatefulWidget{
  final UtenteModel? userData;

  const HomeFormSegreteriaMobilePage({Key? key, required this.userData}) : super(key:key);

  @override
  _HomeFormSegreteriaMobilePageState createState() => _HomeFormSegreteriaMobilePageState();
}

class _HomeFormSegreteriaMobilePageState extends State<HomeFormSegreteriaMobilePage>{
  DateTime selectedDate = DateTime.now();
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';
  String formattedDate = intl.DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
  int _hoveredIndex = -1;
  int _lastClickedIndex = 0;
  Map<int, int> _menuItemClickCount = {};
  late int tipoIdGlobal;


  @override
  void initState() {
    super.initState();
    saveIngresso();
    getAllTasks();
    getAllTipi();
  }

  Future<void> getAllTasks() async {
    try {
      String userId = widget.userData!.id.toString();
      http.Response response = await http.get(Uri.parse('$ipaddress/api/task/utente/$userId'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<TaskModel> tasks = [];
        for (var item in responseData) {
          TaskModel task = TaskModel.fromJson(item);
          if (task.accettato == false && task.utentecreate!.id != widget.userData!.id) {
            tasks.add(task);
          }
        }
        if (tasks.isNotEmpty) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Attenzione"),
                content: Text("Ti sono stati assegnati dei nuovi tasks, controlla nell\'apposita sezione e accettali."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Chiude l'alert
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      print('Error fetching commissioni: $e');
    }
  }

  Future<void> getAllTipi() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/tipoTask');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<TipoTaskModel> tipi = [];
        for(var item in jsonData){
          if (widget.userData!.cognome! == "Mazzei" ||
              (TipoTaskModel.fromJson(item).utentecreate!.id == widget.userData!.id)
              || TipoTaskModel.fromJson(item).utente == null
              || (TipoTaskModel.fromJson(item).utente != null && TipoTaskModel.fromJson(item).utente!.id == widget.userData!.id))
            tipi.add(TipoTaskModel.fromJson(item));

        }
        setState(() {
          tipoIdGlobal = int.parse(tipi.first.id!);
          //allTipi = tipi;
        });
      } else {
        throw Exception(
            'Failed to load tipi task data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Error fetching tipi task data from API: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Connection Error'),
            content: Text(
                'Unable to load data from API. Please check your internet connection and try again.'),
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

  Future<void> saveIngresso() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/ingresso'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orario': formattedDate,
          'utente' : widget.userData?.toMap(),
        }),
      );
    } catch (e) {
      print('Errore durante il salvataggio dell\'intervento: $e');
    }
  }



  Future<List<CommissioneModel>> getAllCommissioniByUtente(
      String userId) async {
    try {
      String userId = widget.userData!.id.toString();
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

  Future<List<InterventoModel>> getMerce() async{
    try{

      http.Response response = await http.get(Uri.parse('$ipaddress/api/intervento/withMerce'));
      if(response.statusCode == 200){
        var responseData = json.decode(response.body);
        List<InterventoModel> interventi = [];
        for(var interventoJson in responseData){
          InterventoModel intervento = InterventoModel.fromJson(interventoJson);
          if (intervento.concluso != true)
            interventi.add(intervento);
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

  Future<List<MerceInRiparazioneModel>> getMerceInRiparazione(String userId) async{
    try {
      String userId = widget.userData!.id.toString();
      http.Response response = await http
          .get(Uri.parse('$ipaddress/api/merceInRiparazione/utente/$userId'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<MerceInRiparazioneModel> allMerceByUtente = [];
        for (var item in responseData) {
          MerceInRiparazioneModel merce = MerceInRiparazioneModel.fromJson(item);
          if (merce.data_conclusione == null) {
            allMerceByUtente.add(merce);
          }
        }
        return allMerceByUtente;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching interventi: $e');
      return [];
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
          if (relazione.intervento!.concluso != true)
          allRelazioniByUtente.add(relazione);

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
      String userId = widget.userData!.id.toString();
      http.Response response = await http
          .get(Uri.parse('$ipaddress/api/intervento/utente/$userId'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<InterventoModel> allInterventiByUtente = [];
        for (var interventoJson in responseData) {
          InterventoModel intervento = InterventoModel.fromJson(interventoJson);
          // Aggiungi il filtro per interventi non conclusi
          if (intervento.concluso != true)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'F.E.M.A.',
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
              setState(() {});
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
                MaterialPageRoute(builder: (context) => SplashScreen()),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          mainAxisSize:
          MainAxisSize.min, // Imposta grandezza minima per la colonna
          children: [
            Padding(
              padding: const EdgeInsets.all(35.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      "CIAO ${widget.userData!.nome!.toUpperCase().toString()}!",
                      textAlign: TextAlign.center, // Centra il testo
                      style: TextStyle(
                        fontSize: 24, // Imposta la dimensione del testo
                        fontWeight: FontWeight.bold, // Imposta il grassetto
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  buildMenuButton(
                    icon: Icons.lock_clock,
                    text: 'TIMBRATURA',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TimbraturaPage(utente: widget.userData!)),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  buildMenuButton(
                    icon: Icons.calendar_month_outlined,
                    text: 'CALENDARIO',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CalendarioPage(utente: widget.userData!)),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  buildMenuButton(
                    icon: Icons.car_rental_outlined,
                    text: 'SPESA SU VEICOLO',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SpesaSuVeicoloPage(utente: widget.userData!)),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  buildMenuButton(
                    icon: Icons.snippet_folder_outlined,
                    text: 'ORDINI AL FORNITORE',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MenuOrdiniFornitorePage(utente: widget.userData!)),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  buildMenuButton(
                    icon: Icons.euro_rounded,
                    text: 'REGISTRO CASSA',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegistroCassaPage(userData: widget.userData!)),
                      );
                    },
                  ),
                  /*SizedBox(height: 20),
                  buildMenuButton(
                    icon: Icons.build,
                    text: 'INTERVENTI',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MenuInterventiPage(utente: widget.userData!)),
                      );
                    },
                  ),*/
                  SizedBox(height: 20),
                  buildMenuButton(
                    icon: Icons.remove_red_eye_outlined,
                    text: 'SOPRALLUOGHI',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MenuSopralluoghiPage(utente: widget.userData!)),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  buildMenuButton(
                    icon: Icons.class_outlined,
                    text: 'COMMISSIONI',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MenuCommissioniPage(utente : widget.userData!)),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  buildMenuButton(
                    icon: Icons.class_outlined,
                    text: 'TASK',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TableTaskPage(
                          utente: widget.userData!, selectedUtente: widget.userData!, tipoIdGlobal: tipoIdGlobal,)),
                      );
                    },
                  ),
                ],
              ),
            ),
            Center(
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
                  //interventi = interventi.where((intervento) => intervento.data!.isSameDay(selectedDate)).toList();
                  interventi = interventi.where((intervento) {
                    return intervento.data == null || intervento.data!.isSameDay(selectedDate);
                  }).toList();
                 return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: interventi.length,
                    itemBuilder: (context, index) {
                      InterventoModel intervento = interventi[index];
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
                      //Color backgroundColor = intervento.concluso ?? false ? Colors.green : Colors.white;
                      //TextStyle textStyle = intervento.concluso ?? false ? TextStyle(color: Colors.white, fontSize: 15) : TextStyle(color: Colors.black, fontSize: 15);

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6), // aggiungi padding orizzontale
                        elevation: 4, // aggiungi ombreggiatura
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        // aggiungi bordi arrotondati
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
                            children: [
                              if (intervento.concluso ?? false)
                                Icon(Icons.check, color: Colors.black, size: 18), //
                              Text(
                                // Formatta la data secondo il tuo formato desiderato
                                intervento.data!= null
                                    ? '${intervento.data!.day.toString().padLeft(2, '0')}/${intervento.data!.month.toString().padLeft(2, '0')}/${intervento.data!.year}'
                                    : 'Data N.D.',
                                style: TextStyle(
                                  fontSize: 13, // Stile opzionale per la data
                                  color: Colors.black,//intervento.concluso ?? false ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                intervento.orario_appuntamento!= null
                                    ? '${intervento.orario_appuntamento?.hour.toString().padLeft(2, '0')}:${intervento.orario_appuntamento?.minute.toString().padLeft(2, '0')}'
                                    : 'Orario appuntamento N.D.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,//intervento.concluso ?? false ? Colors.white : Colors.black,
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
                  relazioni = relazioni.where((relazione) => relazione.intervento!.concluso != true && relazione.intervento!.merce == null).toList();//relazione.intervento!.data!.isSameDay(selectedDate)).toList();
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
                      //TextStyle textStyle = relazione.intervento!.concluso ?? false ? TextStyle(color: Colors.white, fontSize: 15) : TextStyle(color: Colors.black, fontSize: 15);
                      TextStyle textStyle = relazione.intervento?.concluso ?? false
                          ? TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)
                          : TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);

                      return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child:
                        ListTile(contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        title: Text(
                          '${relazione.intervento?.cliente!.denominazione!}\n${relazione.intervento?.destinazione?.citta}, ${relazione.intervento?.destinazione?.indirizzo}',
                          style: textStyle,
                        ),
                        subtitle: Text(
                          '${relazione.intervento?.titolo}',
                          style: textStyle,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (relazione.intervento!.concluso ?? false)
                              Icon(Icons.check, color: Colors.black, size: 18), // Check icon
                            Text(
                              // Formatta la data secondo il tuo formato desiderato
                              relazione.intervento?.data!= null
                                  ? '${relazione.intervento?.data!.day.toString().padLeft(2, '0')}/${relazione.intervento?.data!.month.toString().padLeft(2, '0')}/${relazione.intervento?.data!.year}'
                                  : 'Data non disponibile',
                              style: TextStyle(
                                fontSize: 13, // Stile opzionale per la data
                                color: Colors.black,//relazione.intervento!.concluso ?? false ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              relazione.intervento?.orario_appuntamento!= null
                                  ? '${relazione.intervento?.orario_appuntamento?.hour.toString().padLeft(2, '0')}:${relazione.intervento?.orario_appuntamento?.minute.toString().padLeft(2, '0')}'
                                  : 'Nessun orario di appuntamento',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,//relazione.intervento!.concluso ?? false ? Colors.white : Colors.black,
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
                  return Center(child: Text('Nessun intervento trovato'));
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
                future: getMerce(),
                builder:(context, snapshot){
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Errore: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    List<InterventoModel> merce = snapshot.data!;
                    if(merce.isEmpty){
                      return Center(child: Text(''));
                    }
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: merce.length,
                        itemBuilder:(context, index){
                          InterventoModel singolaMerce = merce[index];

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
                          Color backgroundColor =  getPriorityColor(singolaMerce.priorita!);

                          TextStyle textStyle = singolaMerce.concluso ?? false
                              ? TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)
                              : TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);

                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                              title: Text(
                                '${singolaMerce.cliente!.denominazione}',
                                style: textStyle,
                              ),
                              subtitle: Text(
                                '${singolaMerce.merce?.articolo}',
                                style: textStyle,
                              ),
                              trailing: Column(
                                children: [
                                  Text('Data arrivo merce:',
                                    style: TextStyle(fontSize: 13, color: Colors.black)),
                                  SizedBox(height: 3),
                                  Text('${singolaMerce.data_apertura_intervento != null ? intl.DateFormat("dd/MM/yyyy").format(singolaMerce.data_apertura_intervento!) : "Non disponibile"}',
                                      style: TextStyle(fontSize: 13, color: Colors.black))
                                ],
                              ),
                              onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DettaglioMerceInRiparazioneByTecnicoPage(
                                          intervento: singolaMerce,
                                          merce : singolaMerce.merce!,
                                          utente : widget.userData!
                                      ),
                                    )
                                );
                              },
                              tileColor: Colors.white60,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: getPriorityColor(singolaMerce!.priorita!), width: 8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                    );
                  } else{
                    return Center(child: Text('Nessuna merce trovata'));
                  }
                }
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
                        title: Text('${commissione.descrizione.toString()}'),
                        subtitle: Text(commissione.note ?? ''),
                        trailing: Text(
                          // Formatta la data secondo il tuo formato desiderato
                          commissione.data != null
                              ? '${commissione.data!.day}/${commissione.data!.month}/${commissione.data!.year} ${commissione.data!.hour}:${commissione.data!.minute.toStringAsFixed(1)}'
                              : 'Data non disponibile',
                          style: TextStyle(
                              fontSize: 16), // Stile opzionale per la data
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 10),
              Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }


}