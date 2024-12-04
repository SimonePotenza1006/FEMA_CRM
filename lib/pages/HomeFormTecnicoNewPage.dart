import 'dart:async';
import 'dart:convert';
import 'package:fema_crm/databaseHandler/DbHelper.dart';
import 'package:fema_crm/model/TaskModel.dart';
import 'package:fema_crm/pages/CalendarioUtentePage.dart';
import 'package:fema_crm/pages/DettaglioCommissioneTecnicoPage.dart';
import 'package:fema_crm/pages/DettaglioMerceInRiparazioneByTecnicoPage.dart';
import 'package:fema_crm/pages/FormOrdineFornitorePage.dart';
import 'package:fema_crm/pages/ListInterventiTecnicoPage.dart';
import 'package:fema_crm/pages/TableTaskPage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:fema_crm/pages/SpesaSuVeicoloPage.dart';
import 'package:fema_crm/pages/TimbraturaPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../main.dart';
import '../model/CommissioneModel.dart';
import '../model/InterventoModel.dart';
import '../model/RelazioneUtentiInterventiModel.dart';
import '../model/UtenteModel.dart';
import 'CalendarioPage.dart';
import 'CreazioneTicketTecnicoPage.dart';
import 'DettaglioInterventoByTecnicoPage.dart';
import 'InterventoTecnicoForm.dart';
import 'MenuSopralluoghiTecnicoPage.dart';

import 'dart:io';

class HomeFormTecnicoNewPage extends StatefulWidget{
  final UtenteModel? userData;

  const HomeFormTecnicoNewPage({Key? key, required this.userData}) : super(key:key);

  @override
  _HomeFormTecnicoNewPageState createState() => _HomeFormTecnicoNewPageState();
}

class _HomeFormTecnicoNewPageState extends State<HomeFormTecnicoNewPage>{
  DateTime selectedDate = DateTime.now();
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
  int _hoveredIndex = -1;
  Map<int, int> _menuItemClickCount = {};
  // static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  // Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    if(Platform.isAndroid){
      _menuItemClickCount.clear();
      for (int i = 0; i < _menuItems.length; i++) {
        _menuItemClickCount[i] = 0;
      };
    }
    saveIngresso();
    getAllTasks();
  }

  final List<MenuItem> _menuItems = [
    MenuItem(icon: Icons.more_time, label: 'TIMBRATURA'),
    MenuItem(icon: Icons.snippet_folder_outlined, label: 'RICHIESTA ORDINE'),
    MenuItem(icon: Icons.remove_red_eye_outlined, label: 'SOPRALLUOGHI'),
    MenuItem(icon: Icons.emoji_transportation_sharp, label: 'SPESE SU VEICOLO'),
    MenuItem(icon: Icons.calendar_month_sharp, label: 'CALENDARIO'),
    MenuItem(icon: Icons.build, label: 'INTERVENTI'),
    MenuItem(icon: Icons.edit_note, label: 'TASK'),
    MenuItem(icon: Icons.sticky_note_2_outlined, label: 'TICKET')
  ];

  int _calculateHoveredIndex(Offset position) {
    final center = Offset(650 / 2, 650 / 2); // Use the same size as in CustomPaint
    final angle = (math.atan2(position.dy - center.dy, position.dx - center.dx) + math.pi * 2) % (math.pi * 2);
    final sectorAngle = (2 * math.pi) / 8; // 14 menu items
    final hoveredIndex = (angle ~/ sectorAngle) % 8;
    return hoveredIndex;
  }

  Future<void> saveIngresso() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddressProva/api/ingresso'),
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

  Future<void> getAllTasks() async {
    try {
      String userId = widget.userData!.id.toString();
      http.Response response = await http.get(Uri.parse('$ipaddressProva/api/task/utente/$userId'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<TaskModel> tasks = [];
        for (var item in responseData) {
          TaskModel task = TaskModel.fromJson(item);
          if (task.accettato == false) {
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


  Future<List<CommissioneModel>> getAllCommissioniByUtente(
      String userId) async {
    try {
      String userId = widget.userData!.id.toString();
      http.Response response = await http
          .get(Uri.parse('$ipaddressProva/api/commissione/utente/$userId'));
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

  Future<List<RelazioneUtentiInterventiModel>> getAllRelazioniByUtente(String userId, DateTime date) async {
    try{
      String userId = widget.userData!.id.toString();
      http.Response response = await http
          .get(Uri.parse('$ipaddressProva/api/relazioneUtentiInterventi/utente/$userId'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<RelazioneUtentiInterventiModel> allRelazioniByUtente = [];
        for(var item in responseData){
          RelazioneUtentiInterventiModel relazione = RelazioneUtentiInterventiModel.fromJson(item);
          if(relazione.intervento!.concluso != true){
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

  Future<List<InterventoModel>> getMerce(String userId) async{
    try{
      String userId = widget.userData!.id.toString();
      http.Response response = await http.get(Uri.parse('$ipaddressProva/api/intervento/withMerce/$userId'));
      if(response.statusCode == 200){
        var responseData = json.decode(response.body);
        List<InterventoModel> interventi = [];
        for(var interventoJson in responseData){
          InterventoModel intervento = InterventoModel.fromJson(interventoJson);
          if(intervento!.merce?.data_consegna == null){//if(intervento!.concluso != true){
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

  Future<List<InterventoModel>> getAllInterventiByUtente(String userId, DateTime date) async {
    try {
      String userId = widget.userData!.id.toString();
      http.Response response = await http
          .get(Uri.parse('$ipaddressProva/api/intervento/utente/$userId'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<InterventoModel> allInterventiByUtente = [];
        for (var interventoJson in responseData) {
          InterventoModel intervento = InterventoModel.fromJson(interventoJson);
          // Aggiungi il filtro per interventi non conclusi
          if(intervento.merce == null && intervento.concluso != true && intervento.visualizzato != true){
            allInterventiByUtente.add(intervento);
          }
        }

        //getAllRelazioniByUtente(widget.userData!.id.toString(), selectedDate);
        http.Response response2 = await http
            .get(Uri.parse('$ipaddressProva/api/relazioneUtentiInterventi/utente/$userId'));
        if (response2.statusCode == 200) {
          var responseData2 = json.decode(response2.body);
          //print('rrdd2 '+responseData2.toString());
          //List<RelazioneUtentiInterventiModel> allRelazioniByUtente = [];
          for(var item in responseData2){
            RelazioneUtentiInterventiModel relazione = RelazioneUtentiInterventiModel.fromJson(item);
            if(relazione.intervento!.concluso != true && relazione.visualizzato != true){
              //print('rrrlint '+relazione.intervento!.toString());
              allInterventiByUtente.add(relazione.intervento!);
            }
          }
          //return allRelazioniByUtente;
        }//else {return [];}

        allInterventiByUtente.sort((a, b) {
          // Gestisci gli orari non null
          if (a.orario_inizio != null && b.orario_inizio == null) {
            return -1; // A ha orario_inizio, viene prima di B
          } else if (a.orario_inizio == null && b.orario_inizio != null) {
            return 1; // B ha orario_inizio, viene prima di A
          }

          // Gestisci i casi di data null
          if (a.data == null && b.data == null) {
            return 0; // Entrambi null, considerali uguali
          } else if (a.data == null) {
            return 1; // A è null, quindi viene dopo B
          } else if (b.data == null) {
            return -1; // B è null, quindi A viene prima
          }

          // Confronta le date
          int dateComparison = a.data!.compareTo(b.data!);
          if (dateComparison != 0) {
            return dateComparison;
          }

          // Se le date sono uguali, gestisci gli orari
          if (a.orario_appuntamento == null && b.orario_appuntamento == null) {
            return 0; // Entrambi null, considerali uguali
          } else if (a.orario_appuntamento == null) {
            return 1; // A è null, quindi viene dopo B
          } else if (b.orario_appuntamento == null) {
            return -1; // B è null, quindi A viene prima
          }

          // Confronta gli orari
          int hourComparison = a.orario_appuntamento!.hour.compareTo(b.orario_appuntamento!.hour);
          if (hourComparison != 0) {
            return hourComparison;
          }

          // Se le ore sono uguali, confronta i minuti
          return a.orario_appuntamento!.minute.compareTo(b.orario_appuntamento!.minute);
        });

        return allInterventiByUtente;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching interventi: $e');
      return [];
    }
  }

  int _lastClickedIndex = 0;

  void _navigateToPage(int index) {
    if(Platform.isAndroid){
      if (_lastClickedIndex != index) {
        _menuItemClickCount.clear(); // azzerare tutti i contatori quando si clicca su un bottone diverso
        _lastClickedIndex = index; // aggiornare l'indice dell'ultimo bottone cliccato
      }
    }

    if(Platform.isAndroid){
      if (_menuItemClickCount.containsKey(index)) {
        _menuItemClickCount[index] = (_menuItemClickCount[index] ?? 0) + 1;
      } else {
        _menuItemClickCount[index] = 1;
      }
    }

    if ((_menuItemClickCount[index] ?? 0) % 2 == 0 && _hoveredIndex != -1) {
      switch (index) {
        case 4:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CalendarioUtentePage(utente: widget.userData!)),
          );
          break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FormOrdineFornitorePage(utente: widget.userData!)),
        );
        break;
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TimbraturaPage(utente: widget.userData!)),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MenuSopralluoghiTecnicoPage(utente: widget.userData!)),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SpesaSuVeicoloPage(utente: widget.userData!)),
        );
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ListInterventiTecnicoPage(userData: widget.userData)),//InterventoTecnicoForm(userData: widget.userData!)),
        );
        break;
        case 6:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TableTaskPage(utente: widget.userData!)),//InterventoTecnicoForm(userData: widget.userData!)),
          );
          break;
        case 7:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreazioneTicketTecnicoPage(utente: widget.userData!)),
          );
      }
    }
  }

  Future<List<InterventoModel>> getAllInterventiBySettore() async {
    try {
      print('getAllInterventiBySettore chiamato');
      var apiUrl = Uri.parse('$ipaddressProva/api/intervento/categoriaIntervento/'+widget.userData!.tipologia_intervento!.id.toString());
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

  Future<List<InterventoModel>> getAllInterventi() async {
    try {
      print('getAllInterventi chiamato');
      var apiUrl = Uri.parse('$ipaddressProva/api/intervento');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<InterventoModel> interventi = [];
        for (var item in jsonData) {
          if (InterventoModel.fromJson(item).utente != null && (InterventoModel.fromJson(item).concluso != true)) //solo gli interventi con data e utente
            interventi.add(InterventoModel.fromJson(item));
        }
        return interventi;
      } else {
        print('getAllInterventi: fallita con status code ${response.statusCode}');
        return [];
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API getAllInterventi: $e');
      return [];
    }
  }

  void interventoVisualizzato(InterventoModel intervento) async{
    try{
      print('iinnt '+intervento.utente.toString()+' '+widget.userData.toString());
      if (intervento.utente != null && intervento.utente!.id == widget.userData!.id) {
        print('è interv ');
      final response = await http.post(
        Uri.parse('$ipaddressProva/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': intervento.id?.toString(),
          'attivo' : intervento.attivo,
          'visualizzato' : true,
          'titolo' : intervento.titolo,
          'numerazione_danea' : intervento.numerazione_danea,
          'priorita' : intervento.priorita.toString().split('.').last,
          'data_apertura_intervento' : intervento.data_apertura_intervento?.toIso8601String(),
          'data': intervento.data?.toIso8601String(),
          'orario_appuntamento' : intervento.orario_appuntamento?.toIso8601String(),
          'posizione_gps' : intervento.posizione_gps,//_indirizzo,
          'orario_inizio': intervento.orario_inizio?.toIso8601String(),//DateTime.now().toIso8601String(),
          'orario_fine': intervento.orario_fine?.toIso8601String(),
          'descrizione': intervento.descrizione,
          'importo_intervento': intervento.importo_intervento,
          'saldo_tecnico' : intervento.saldo_tecnico,
          'prezzo_ivato' : intervento.prezzo_ivato,
          'iva' : intervento.iva,
          'acconto' : intervento.acconto,
          'assegnato': intervento.assegnato,
          'accettato_da_tecnico' : intervento.accettato_da_tecnico,
          'annullato' : intervento.annullato,
          'conclusione_parziale' : intervento.conclusione_parziale,
          'concluso': intervento.concluso,
          'saldato': intervento.saldato,
          'saldato_da_tecnico' : intervento.saldato_da_tecnico,
          'note': intervento.note,
          'relazione_tecnico' : intervento.relazione_tecnico,
          'firma_cliente': intervento.firma_cliente,
          'utente_apertura' : intervento.utente_apertura?.toMap(),
          'utente': intervento.utente?.toMap(),
          'cliente': intervento.cliente?.toMap(),
          'veicolo': intervento.veicolo?.toMap(),
          'merce': intervento.merce?.toMap(),
          'tipologia': intervento.tipologia?.toMap(),
          'categoria_intervento_specifico':
            intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': intervento.tipologia_pagamento?.toMap(),
          'destinazione': intervento.destinazione?.toMap(),
          'gruppo' : intervento.gruppo?.toMap()
        }),
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Intervento visualizzato!'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeFormTecnicoNewPage(userData: widget.userData)),
        );
      } } else
        {
          print('è relaz ');
          RelazioneUtentiInterventiModel? relazioneiu = null;
          http.Response response2 = await http
              .get(Uri.parse('$ipaddressProva/api/relazioneUtentiInterventi/interventoutente/'+intervento.id.toString()+'/'+widget.userData!.id.toString()));
          if (response2.statusCode == 200) {
            print('res st 200 ');
            var responseData2 = json.decode(response2.body);
            //print('rrdd2 '+responseData2.toString());
            //List<RelazioneUtentiInterventiModel> allRelazioniByUtente = [];

              RelazioneUtentiInterventiModel relazione = RelazioneUtentiInterventiModel.fromJson(responseData2);
              if(relazione.intervento!.concluso != true && relazione.visualizzato != true){
                //print('rrrlint '+relazione.intervento!.toString());
                relazioneiu = RelazioneUtentiInterventiModel.fromJson(responseData2);
              }

            //return allRelazioniByUtente;
          }//else {return [];}
          print('res st 200 '+relazioneiu!.id.toString());
          final response = await http.post(
            Uri.parse('$ipaddressProva/api/relazioneUtentiInterventi'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id': relazioneiu!.id,
              'intervento': relazioneiu!.intervento?.toMap(),
              'utente': relazioneiu!.utente?.toMap(),
              'visualizzato': true
            }),
          );
          print(response.statusCode);
          if(response.statusCode == 200){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Intervento visualizzato!'),
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeFormTecnicoNewPage(userData: widget.userData)),
            );
          }
        }
    } catch(e){
      print('Qualcosa non va: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home ${widget.userData!.nomeCompleto().toString()}',
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
      body: Padding(
        padding: EdgeInsets.only(top: 40, bottom: 40),
        child: LayoutBuilder(
            builder: (context, constraints){
              if (constraints.maxWidth <= 800) {
                // Tablet/Mobile layout
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        children: [
                          SizedBox(height: 31),
                          GestureDetector(
                            onTapUp: (details) {
                              if (_hoveredIndex != -1) {
                                _navigateToPage(_hoveredIndex);
                              }
                            },
                            onPanUpdate: (details) {
                              RenderBox box = context.findRenderObject() as RenderBox;
                              Offset localOffset = box.globalToLocal(details.globalPosition);
                              setState(() {
                                _hoveredIndex = _calculateHoveredIndex(localOffset);
                              });
                            },
                            child: CustomPaint(
                                size: Size(300, 300),
                                painter: MenuPainter(
                                      (index) {
                                    setState(() {
                                      _hoveredIndex = index;
                                    });
                                  },
                                      () {
                                    setState(() {
                                      _hoveredIndex = -1;
                                    });
                                  },
                                  context,
                                  size: Size(300, 300),
                                  hoveredIndex: _hoveredIndex,
                                ),

                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25),
                      widget.userData!.id != '19' ? Wrap(children: <Widget>[  //joytek 19
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Nuovi Interventi',
                              style: TextStyle(
                                  fontSize: 30.0, fontWeight: FontWeight.bold),
                            ),
                            /*SizedBox(width: 15),
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
                            ),*/
                          ],
                        ),
                      ),
                        const SizedBox(height: 10.0),
                      FutureBuilder<List<InterventoModel>>(
                        future: getAllInterventiByUtente(widget.userData!.id.toString(), selectedDate),
                        builder: (context, snapshot) {
                          //print('length '+snapshot.data!.length.toString());
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Errore: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            List<InterventoModel> interventi = snapshot.data!;
                            interventi = interventi.where((intervento) => intervento.merce == null).toList();
                            interventi = interventi.where((intervento) {
                              return intervento.data == null || intervento.data!.isBefore(selectedDate.add(Duration(days: 1)));//isSameDay(selectedDate);
                            }).toList();
                            if (interventi.isEmpty) {
                              return Center(child: Text(''));
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
                                              : 'Data N.D.',
                                          style: TextStyle(fontSize: 13, color: Colors.black),
                                        ),
                                        Text(
                                          intervento.orario_appuntamento != null
                                              ? '${intervento.orario_appuntamento?.hour.toString().padLeft(2, '0')}:${intervento.orario_appuntamento?.minute.toString().padLeft(2, '0')}'
                                              : 'Orario N.D.',
                                          style: TextStyle(fontSize: 13, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(//contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                        title: new Text(''+intervento.titolo.toString(), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                        content: new Text('Cliente: '+intervento.cliente!.denominazione!+' - '+intervento!.destinazione!.indirizzo!+'\n'
                                        +'\nData: '+
                                            (intervento.data != null
                                            ? '${intervento.data!.day.toString().padLeft(2, '0')}/${intervento.data!.month.toString().padLeft(2, '0')}/${intervento.data!.year}'
                                            : 'N.D.')+
                                        '\nOrario appuntamento: '+ (intervento.orario_appuntamento != null
                                            ? '${intervento.orario_appuntamento?.hour.toString().padLeft(2, '0')}:${intervento.orario_appuntamento?.minute.toString().padLeft(2, '0')}'
                                            : 'N.D.'), style: TextStyle(fontSize: 14)),
                                        actions: <Widget>[
                                          Form(
                                              //key: _formKeyLice,
                                              //autovalidateMode: AutovalidateMode.onUserInteraction,
                                              child:
                                              Column(
                                                //scrollDirection: Axis.vertical,
                                                //direction: Axis.vertical,
                                                  children: [



                                                    TextButton(
                                                      onPressed: () {
                                                       interventoVisualizzato(intervento);},
                                                      //Navigator.of(context).pop(true), // <-- SEE HERE
                                                      child: new Text('PRESA VISIONE', style: TextStyle(
                                                          fontSize: 22.0,
                                                          fontWeight: FontWeight.w600),),
                                                    ),
                                                  ]))
                                        ],
                                      ),
                                      );
                                      /*Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DettaglioInterventoByTecnicoPage(
                                            utente: widget.userData!,
                                            intervento: intervento,
                                          ),
                                        ),
                                      );*/
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
                      /*FutureBuilder<List<RelazioneUtentiInterventiModel>>(
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
                                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child:
                                ListTile(
                                  contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                  title: Text(
                                    '${relazione.intervento?.cliente!.denominazione!}\n ${relazione.intervento?.destinazione?.citta}, ${relazione.intervento?.destinazione?.indirizzo}',
                                    style: textStyle,
                                  ),
                                  subtitle: Text(
                                    '${relazione.intervento?.titolo}',
                                    style: textStyle,
                                  ),
                                  trailing: Column(
                                    children: [
                                      if (relazione.intervento!.concluso ?? false)
                                        Icon(Icons.check, color: Colors.black, size: 18), // Check icon
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
                      ),*/
                      ]) : Wrap(children: <Widget>[
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        FutureBuilder<List<InterventoModel>>(
                          future: getAllInterventi(),
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
                                return Center(child: Text(''));
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
                                                : 'Data N.D.',
                                            style: TextStyle(fontSize: 13, color: Colors.black),
                                          ),
                                          Text(
                                            intervento.orario_appuntamento != null
                                                ? '${intervento.orario_appuntamento?.hour.toString().padLeft(2, '0')}:${intervento.orario_appuntamento?.minute.toString().padLeft(2, '0')}'
                                                : 'Orario N.D.',
                                            style: TextStyle(fontSize: 13, color: Colors.black),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(//contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                            title: new Text(''+intervento.titolo.toString(), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                            content: new Text('Cliente: '+intervento.cliente!.denominazione!+' - '+intervento!.destinazione!.indirizzo!+'\n'
                                                +'\nData: '+
                                                (intervento.data != null
                                                    ? '${intervento.data!.day.toString().padLeft(2, '0')}/${intervento.data!.month.toString().padLeft(2, '0')}/${intervento.data!.year}'
                                                    : 'N.D.')+
                                                '\nOrario appuntamento: '+ (intervento.orario_appuntamento != null
                                                ? '${intervento.orario_appuntamento?.hour.toString().padLeft(2, '0')}:${intervento.orario_appuntamento?.minute.toString().padLeft(2, '0')}'
                                                : 'N.D.'), style: TextStyle(fontSize: 14)),
                                            actions: <Widget>[
                                              Form(
                                                  child:
                                                  Column(
                                                      children: [
                                                        TextButton(
                                                          onPressed: () {
                                                            interventoVisualizzato(intervento);},
                                                          child: new Text('PRESA VISIONE', style: TextStyle(
                                                              fontSize: 22.0,
                                                              fontWeight: FontWeight.w600),),
                                                        ),
                                                      ]))
                                            ],
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

                      ]),

                      /*const SizedBox(height: 50.0),
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
                              return Center(child: Text(''));
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
                      ),*/
                      const SizedBox(height: 50.0),
                      Center(
                        child: Text(
                          'Merce in riparazione',
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
                              return Center(child: Text(''));
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
                                Color backgroundColor = getPriorityColor(singolaMerce.priorita ?? Priorita.BASSA);
                                TextStyle textStyle = singolaMerce.concluso ?? false
                                    ? TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)
                                    : TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);

                                return Card(
                                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
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
                                        Text('Data arrivo merce:', style: TextStyle(fontSize: 13, color: Colors.black)),
                                        SizedBox(height: 3),
                                        Text(
                                          singolaMerce.data_apertura_intervento != null
                                              ? DateFormat("dd/MM/yyyy").format(singolaMerce.data_apertura_intervento!)
                                              : 'Data non disponibile',
                                          style: TextStyle(fontSize: 13, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      showDialog(
                                        //barrierDismissible: false,
                                        context: context,
                                        builder: (context) => AlertDialog(//contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                          title: new Text(''+singolaMerce.titolo.toString(), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                          content: new Text('Cliente: '+singolaMerce.cliente!.denominazione!+' - '+singolaMerce!.destinazione!.indirizzo!+'\n'
                                              +'\n'+singolaMerce.merce!.articolo!+' - '+singolaMerce.merce!.difetto_riscontrato!+'\n\nData: '+
                                              (singolaMerce.data != null
                                                  ? '${singolaMerce.data!.day.toString().padLeft(2, '0')}/${singolaMerce.data!.month.toString().padLeft(2, '0')}/${singolaMerce.data!.year}'
                                                  : 'N.D.')+
                                              '\nOrario appuntamento: '+ (singolaMerce.orario_appuntamento != null
                                              ? '${singolaMerce.orario_appuntamento?.hour.toString().padLeft(2, '0')}:${singolaMerce.orario_appuntamento?.minute.toString().padLeft(2, '0')}'
                                              : 'N.D.'),
                                              style: TextStyle(fontSize: 14)

                                          ),
                                          actions: <Widget>[
                                            Form(
                                                child:
                                                Column(
                                                    children: [
                                                      TextButton(
                                                        onPressed: () {
                                                          interventoVisualizzato(singolaMerce);},
                                                        //Navigator.of(context).pop(true), // <-- SEE HERE
                                                        child: new Text('PRESA VISIONE', style: TextStyle(
                                                            fontSize: 22.0,
                                                            fontWeight: FontWeight.w600),),
                                                      ),
                                                    ]))
                                          ],
                                        ),
                                      );
                                    },
                                    tileColor: Colors.white60,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(color: getPriorityColor(singolaMerce!.priorita!), width: 8),
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
                              return Center(child: Text(''));
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
                                        Text('Data arrivo merce:', style: TextStyle(fontSize: 13, color: Colors.black)),
                                        SizedBox(height: 3),
                                        Text(
                                          relazione.intervento?.data_apertura_intervento != null
                                              ? DateFormat("dd/MM/yyyy").format(relazione.intervento!.data_apertura_intervento!)
                                              : 'Data N.D.',
                                          style: TextStyle(fontSize: 13, color: Colors.black),
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
                      Center(
                        child: Text(
                          'Agenda commissioni',
                          style: TextStyle(
                              fontSize: 30.0, fontWeight: FontWeight.bold),
                        ),
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
                                Color backgroundColor = getPriorityColor(commissione.priorita ?? Priorita.BASSA);

                                TextStyle textStyle = commissione.concluso ?? false
                                    ? TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)
                                    : TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);
                                return Card(
                                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    title: Text(
                                      '${commissione.descrizione}',
                                      style: textStyle,
                                    ),
                                    subtitle: Text(
                                      '${commissione.note}',
                                      style: textStyle,
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          commissione.data != null
                                              ? DateFormat("dd/MM/yyyy").format(commissione.data!)
                                              : 'Data N.D.',
                                          style: TextStyle(fontSize: 13, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DettaglioCommissioneTecnicoPage(
                                              commissione: commissione
                                          ),
                                        ),
                                      );
                                    },
                                    tileColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(color: getPriorityColor(commissione.priorita!), width: 8),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
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
                );
              } else {
                return Scaffold(
                  body: SingleChildScrollView(
                    child: Column(
                      mainAxisSize:
                      MainAxisSize.min, // Imposta grandezza minima per la colonna
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 7),//EdgeInsets.all(20.0),
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
                                    MaterialPageRoute(builder: (context) => CalendarioUtentePage(utente: widget.userData)),
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
                                    MaterialPageRoute(builder: (context) => FormOrdineFornitorePage(utente: widget.userData!)),
                                  );
                                },
                              ),
                              SizedBox(height: 20),
                              buildMenuButton(
                                icon: Icons.remove_red_eye_outlined,
                                text: 'SOPRALLUOGHI',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => MenuSopralluoghiTecnicoPage(utente: widget.userData!)),
                                  );
                                },
                              ),
                              SizedBox(height: 20),
                              buildMenuButton(
                                icon: Icons.build,
                                text: 'INTERVENTI',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ListInterventiTecnicoPage(userData: widget.userData)),//InterventoTecnicoForm(userData: widget.userData!)),
                                  );
                                },
                              ),
                              SizedBox(height: 20),
                              buildMenuButton(
                                icon: Icons.edit_note,
                                text: 'TASK',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => TableTaskPage(utente: widget.userData!)),//InterventoTecnicoForm(userData: widget.userData!)),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 17,),
                        widget.userData!.id != '19' ? Wrap(children: <Widget>[
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'NUOVI INTERVENTI',
                                style: TextStyle(
                                    fontSize: 30.0, fontWeight: FontWeight.bold),
                              ),
                              /*SizedBox(width: 15),
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
                              ),*/
                            ],
                          ),
                        ),
                        const SizedBox(height: 10.0),
                          FutureBuilder<List<InterventoModel>>(
                            future: getAllInterventiByUtente(widget.userData!.id.toString(), selectedDate),
                            builder: (context, snapshot) {
                              //print('length '+snapshot.data!.length.toString());
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Errore: ${snapshot.error}'));
                              } else if (snapshot.hasData) {
                                List<InterventoModel> interventi = snapshot.data!;
                                interventi = interventi.where((intervento) => intervento.merce == null).toList();
                                interventi = interventi.where((intervento) {
                                  return intervento.data == null || intervento.data!.isBefore(selectedDate.add(Duration(days: 1)));//isSameDay(selectedDate);
                                }).toList();
                                if (interventi.isEmpty) {
                                  return Center(child: Text(''));
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
                                                  : 'Data N.D.',
                                              style: TextStyle(fontSize: 13, color: Colors.black),
                                            ),
                                            Text(
                                              intervento.orario_appuntamento != null
                                                  ? '${intervento.orario_appuntamento?.hour.toString().padLeft(2, '0')}:${intervento.orario_appuntamento?.minute.toString().padLeft(2, '0')}'
                                                  : 'Orario N.D.',
                                              style: TextStyle(fontSize: 13, color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(//contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                              title: new Text(''+intervento.titolo.toString(), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                              content: new Text('Cliente: '+intervento.cliente!.denominazione!+' - '+intervento!.destinazione!.indirizzo!+'\n'
                                                  +'\nData: '+
                                                  (intervento.data != null
                                                      ? '${intervento.data!.day.toString().padLeft(2, '0')}/${intervento.data!.month.toString().padLeft(2, '0')}/${intervento.data!.year}'
                                                      : 'N.D.')+
                                                  '\nOrario appuntamento: '+ (intervento.orario_appuntamento != null
                                                  ? '${intervento.orario_appuntamento?.hour.toString().padLeft(2, '0')}:${intervento.orario_appuntamento?.minute.toString().padLeft(2, '0')}'
                                                  : 'N.D.'), style: TextStyle(fontSize: 14)),
                                              actions: <Widget>[
                                                Form(
                                                  //key: _formKeyLice,
                                                  //autovalidateMode: AutovalidateMode.onUserInteraction,
                                                    child:
                                                    Column(
                                                        children: [
                                                          TextButton(
                                                            onPressed: () {
                                                              interventoVisualizzato(intervento);},
                                                            //Navigator.of(context).pop(true), // <-- SEE HERE
                                                            child: new Text('PRESA VISIONE', style: TextStyle(
                                                                fontSize: 22.0,
                                                                fontWeight: FontWeight.w600),),
                                                          ),
                                                        ]))
                                              ],
                                            ),
                                          );
                                          /*Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DettaglioInterventoByTecnicoPage(
                                            utente: widget.userData!,
                                            intervento: intervento,
                                          ),
                                        ),
                                      );*/
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
                    /*FutureBuilder<List<RelazioneUtentiInterventiModel>>(
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
                                  return
                                    Card(
                                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      child:
                                    ListTile(
                                    title: Text(
                                      '${relazione.intervento?.cliente!.denominazione!}\n ${relazione.intervento?.destinazione?.citta}, ${relazione.intervento?.destinazione?.indirizzo}',
                                      style: textStyle,
                                    ),
                                    subtitle: Text(
                                      '${relazione.intervento?.titolo}',
                                      style: textStyle,
                                    ),
                                    trailing: Column(
                                      children: [
                                        if (relazione.intervento?.concluso ?? false)
                                          Icon(Icons.check, color: Colors.white, size: 15),
                                        Text(
                                          // Formatta la data secondo il tuo formato desiderato
                                          relazione.intervento?.data!= null
                                              ? '${relazione.intervento?.data!.day.toString().padLeft(2, '0')}/${relazione.intervento?.data!.month.toString().padLeft(2, '0')}/${relazione.intervento?.data!.year}'
                                              : 'Nessun appuntamento stabilito',
                                          style: TextStyle(fontSize: 10, color: Colors.black),
                                        ),
                                        Text(
                                          relazione.intervento?.orario_appuntamento!= null
                                              ? '${relazione.intervento?.orario_appuntamento?.hour.toString().padLeft(2, '0')}:${relazione.intervento?.orario_appuntamento?.minute.toString().padLeft(2, '0')}'
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
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(color: Colors.grey.shade100, width: 0.5),
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
                        ),*/
                        ]) : Wrap(children: <Widget>[

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
                            future: getAllInterventi(),
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
                                  return Center(child: Text(''));
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
                                                  ? '${intervento.data!.day.toString().padLeft(2, '0')}/${intervento.data!.month.toString().padLeft(2, '0')}/${intervento.data!.year}'
                                                  : 'Data N.D.',//'Nessun appuntamento stabilito',
                                              style: TextStyle(fontSize: 13, color: Colors.black),
                                            ),
                                            Text(
                                              intervento.orario_appuntamento!= null
                                                  ? '${intervento.orario_appuntamento?.hour.toString().padLeft(2, '0')}:${intervento.orario_appuntamento?.minute.toString().padLeft(2, '0')}'
                                                  : 'Orario N.D.',//'Nessun appuntamento stabilito',
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

                          ]),
                        /*Center(
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
                                return Center(child: Text(''));
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
                                                ? '${intervento.data!.day.toString().padLeft(2, '0')}/${intervento.data!.month.toString().padLeft(2, '0')}/${intervento.data!.year}'
                                                : 'Nessun appuntamento stabilito',
                                            style: TextStyle(fontSize: 10, color: Colors.black),
                                          ),
                                          Text(
                                            intervento.orario_appuntamento != null
                                                ? '${intervento.orario_appuntamento?.hour.toString().padLeft(2, '0')}:${intervento.orario_appuntamento?.minute.toString().padLeft(2, '0')}'
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
                        ),*/
                        const SizedBox(height: 50.0),
                        Center(
                          child: Text(
                            'MERCE IN RIPARAZIONE',
                            style: TextStyle(
                                fontSize: 30.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10.0),
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
                                return Center(child: Text(''));
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
                                  Color backgroundColor = getPriorityColor(singolaMerce.priorita ?? Priorita.BASSA);
                                  TextStyle textStyle = singolaMerce.concluso ?? false
                                      ? TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)
                                      : TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);

                                  return Card(
                                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
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
                                          Text('Data arrivo merce:', style: TextStyle(fontSize: 13, color: Colors.black)),
                                          SizedBox(height: 3),
                                          Text(
                                            singolaMerce.data_apertura_intervento != null
                                                ? DateFormat("dd/MM/yyyy").format(singolaMerce.data_apertura_intervento!)
                                                : 'Data non disponibile',
                                            style: TextStyle(fontSize: 13, color: Colors.black),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        showDialog(
                                          //barrierDismissible: false,
                                          context: context,
                                          builder: (context) => AlertDialog(//contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                            title: new Text(''+singolaMerce.titolo.toString(), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                            content: new Text('Cliente: '+singolaMerce.cliente!.denominazione!+' - '+singolaMerce!.destinazione!.indirizzo!+'\n'
                                                +'\n'+singolaMerce.merce!.articolo!+' - '+singolaMerce.merce!.difetto_riscontrato!+'\n\nData: '+
                                                (singolaMerce.data != null
                                                    ? '${singolaMerce.data!.day.toString().padLeft(2, '0')}/${singolaMerce.data!.month.toString().padLeft(2, '0')}/${singolaMerce.data!.year}'
                                                    : 'N.D.')+
                                                '\nOrario appuntamento: '+ (singolaMerce.orario_appuntamento != null
                                                ? '${singolaMerce.orario_appuntamento?.hour.toString().padLeft(2, '0')}:${singolaMerce.orario_appuntamento?.minute.toString().padLeft(2, '0')}'
                                                : 'N.D.'),
                                                style: TextStyle(fontSize: 14)

                                            ),
                                            actions: <Widget>[
                                              Form(
                                                  child:
                                                  Column(
                                                      children: [
                                                        TextButton(
                                                          onPressed: () {
                                                            interventoVisualizzato(singolaMerce);},
                                                          //Navigator.of(context).pop(true), // <-- SEE HERE
                                                          child: new Text('PRESA VISIONE', style: TextStyle(
                                                              fontSize: 22.0,
                                                              fontWeight: FontWeight.w600),),
                                                        ),
                                                      ]))
                                            ],
                                          ),
                                        );
                                      },
                                      tileColor: Colors.white60,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(color: getPriorityColor(singolaMerce!.priorita!), width: 8),
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
                                return Center(child: Text(''));
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
                                        '${relazione.intervento?.cliente!.denominazione}\n${relazione.intervento?.descrizione}',
                                        style: textStyle,
                                      ),
                                      subtitle: Text(
                                        '${relazione.intervento?.merce?.difetto_riscontrato}',
                                        style: textStyle,
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Data arrivo merce:', style: TextStyle(fontSize: 13, color: Colors.black)),
                                          SizedBox(height: 3),
                                          Text(
                                            relazione.intervento?.data_apertura_intervento != null
                                                ? DateFormat("dd/MM/yyyy").format(relazione.intervento!.data_apertura_intervento!)
                                                : 'Data N.D.',
                                            style: TextStyle(fontSize: 13, color: Colors.black),
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
                                  Color backgroundColor = getPriorityColor(commissione.priorita ?? Priorita.BASSA);

                                  TextStyle textStyle = commissione.concluso ?? false
                                      ? TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)
                                      : TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold);
                                  return Card(
                                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                      title: Text(
                                        '${commissione.descrizione}',
                                        style: textStyle,
                                      ),
                                      subtitle: Text(
                                        '${commissione.note}',
                                        style: textStyle,
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            commissione.data != null
                                                ? DateFormat("dd/MM/yyyy").format(commissione.data!)
                                                : 'Data N.D.',
                                            style: TextStyle(fontSize: 13, color: Colors.black),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DettaglioCommissioneTecnicoPage(
                                              commissione: commissione
                                            ),
                                          ),
                                        );
                                      },
                                      tileColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(color: getPriorityColor(commissione.priorita!), width: 8),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
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
            }
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
            colors: [Colors.red, Colors.red],
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

class MenuPainter extends CustomPainter {
  final Function(int) onHover;
  final Function() onHoverExit;
  final Size size;
  final int hoveredIndex;
  final BuildContext context; // Add BuildContext

  MenuPainter(this.onHover, this.onHoverExit, this.context, {required this.size, required this.hoveredIndex});

  final List<MenuItem> _menuItems = [
    MenuItem(icon: Icons.more_time, label: 'TIMBRATURA'),
    MenuItem(icon: Icons.snippet_folder_outlined, label: 'RICHIESTA ORDINE'),
    MenuItem(icon: Icons.remove_red_eye_outlined, label: 'SOPRALLUOGHI'),
    MenuItem(icon: Icons.emoji_transportation_sharp, label: 'SPESE SU VEICOLO'),
    MenuItem(icon: Icons.calendar_month_sharp, label: 'CALENDARIO'),
    MenuItem(icon: Icons.build, label: 'INTERVENTI'),
    MenuItem(icon: Icons.edit_note, label: 'TASK'),
    MenuItem(icon: Icons.sticky_note_2_outlined, label: 'TICKET')
  ];

  TextPainter labelPainter = TextPainter(
    text: TextSpan(
      text: '',
      style: TextStyle(
        fontSize: 18,
        color: Colors.black,
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: ui.TextDirection.ltr,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Radius
    final outerRadius = size.width / 2;
    final innerRadius = size.width / 4.5;
    final center = Offset(size.width / 2, size.height / 2);

    // Draw the menu items
    final angle = 2 * math.pi / _menuItems.length;
    for (int i = 0; i < _menuItems.length; i++) {
      final menuItem = _menuItems[i];
      final startAngle = i * angle;
      final sweepAngle = angle - 0.02; // Add a small gap between each arc

      // Determine if this menu item is hovered
      bool isHovered = hoveredIndex == i;

      // Calculate the scale factor for the hovered section
      double scaleFactor = isHovered ? 1.2 : 1.0;

      // Draw the sections
      paint.color = isHovered ? Colors.red[900]!.withOpacity(0.6 ) : Colors.red;
      Path path = Path();
      path.arcTo(
        Rect.fromCircle(center: center, radius: outerRadius * scaleFactor),
        startAngle,
        sweepAngle,
        false,
      );
      path.arcTo(
        Rect.fromCircle(center: center, radius: innerRadius * scaleFactor),
        startAngle + sweepAngle,
        -sweepAngle,
        false,
      );
      path.close();
      canvas.drawPath(path, paint);
      final iconX = center.dx +
          (outerRadius * scaleFactor + (isHovered ? innerRadius * scaleFactor * 1.2 : innerRadius * scaleFactor)) /
              2 *
              math.cos(startAngle + sweepAngle / 2);
      final iconY = center.dy +
          (outerRadius * scaleFactor + (isHovered ? innerRadius * scaleFactor * 1.2 : innerRadius * scaleFactor)) /
              2 *
              math.sin(startAngle + sweepAngle / 2);
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(menuItem.icon.codePoint),
          style: TextStyle(
            fontSize: isHovered ? 28 : 24,
            fontFamily: menuItem.icon.fontFamily,
            color: Colors.white,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(iconX - textPainter.width / 2,
              iconY - textPainter.height / 2));
      // Draw the label if hovered
      if (isHovered) {
        final labelX = center.dx;
        labelPainter.text = TextSpan(
          text: menuItem.label,
          style: TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.bold
          ),
        );
        labelPainter.layout();
        final labelHeight = labelPainter.height;
        final labelY = center.dy - innerRadius * scaleFactor * 0.1 + labelHeight / 2;
        labelPainter.paint(
            canvas,
            Offset(labelX - labelPainter.width / 2,
                labelY - labelHeight / 2));
      }
    }
  }

  @override
  bool shouldRepaint(MenuPainter oldDelegate) => oldDelegate.hoveredIndex != hoveredIndex;

  @override
  bool hitTest(Offset position) {
    final center = Offset(size.width / 2, size.height / 2);
    final distance = math.sqrt(math.pow(position.dx - center.dx, 2) + math.pow(position.dy - center.dy, 2));
    final radius = size.width / 2;

    if (distance <= radius) {
      final angle = (math.atan2(position.dy - center.dy, position.dx - center.dx) + math.pi * 2) % (math.pi * 2);
      final section = (angle / (2 * math.pi / _menuItems.length)).floor();

      final newIndex = section % _menuItems.length;
      onHover(newIndex);
      return true;
    }
    onHoverExit();
    return false;
  }
}

class MenuItem {
  final IconData icon;
  final String label;

  MenuItem({required this.icon, required this.label});
}