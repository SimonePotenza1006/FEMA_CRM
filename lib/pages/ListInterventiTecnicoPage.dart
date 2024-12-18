import 'dart:async';
import 'dart:convert';
import 'package:fema_crm/databaseHandler/DbHelper.dart';
import 'package:fema_crm/pages/CalendarioUtentePage.dart';
import 'package:fema_crm/pages/DettaglioCommissioneTecnicoPage.dart';
import 'package:fema_crm/pages/DettaglioMerceInRiparazioneByTecnicoPage.dart';
import 'package:fema_crm/pages/FormOrdineFornitorePage.dart';
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
import 'DettaglioInterventoByTecnicoPage.dart';
import 'InterventoTecnicoForm.dart';
import 'MenuSopralluoghiTecnicoPage.dart';

import 'dart:io';

class ListInterventiTecnicoPage extends StatefulWidget{
  final UtenteModel? userData;

  const ListInterventiTecnicoPage({Key? key, required this.userData}) : super(key:key);

  @override
  _ListInterventiTecnicoPageState createState() => _ListInterventiTecnicoPageState();
}

class _ListInterventiTecnicoPageState extends State<ListInterventiTecnicoPage>{
  DateTime selectedDate = DateTime.now();
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';
  String formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
  int _hoveredIndex = -1;
  Map<int, int> _menuItemClickCount = {};
  TextEditingController _rapportinoController = TextEditingController();
  // static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  // Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
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
      http.Response response = await http.get(Uri.parse('$ipaddress/api/intervento/withMerce/$userId'));
      if(response.statusCode == 200){
        var responseData = json.decode(response.body);
        List<InterventoModel> interventi = [];
        for(var interventoJson in responseData){
          InterventoModel intervento = InterventoModel.fromJson(interventoJson);
          if(intervento!.concluso != true){
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
          .get(Uri.parse('$ipaddress/api/intervento/utente/$userId'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<InterventoModel> allInterventiByUtente = [];
        for (var interventoJson in responseData) {
          InterventoModel intervento = InterventoModel.fromJson(interventoJson);
          // Aggiungi il filtro per interventi non conclusi
          if(intervento.merce == null && intervento.concluso != true){
            allInterventiByUtente.add(intervento);
          }
        }

        //getAllRelazioniByUtente(widget.userData!.id.toString(), selectedDate);
        http.Response response2 = await http
            .get(Uri.parse('$ipaddress/api/relazioneUtentiInterventi/utente/$userId'));
        if (response2.statusCode == 200) {
          var responseData2 = json.decode(response2.body);
          //print('rrdd2 '+responseData2.toString());
          //List<RelazioneUtentiInterventiModel> allRelazioniByUtente = [];
          for(var item in responseData2){
            RelazioneUtentiInterventiModel relazione = RelazioneUtentiInterventiModel.fromJson(item);
            if(relazione.intervento!.concluso != true){
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

  Future<List<InterventoModel>> getAllInterventiBySettore() async {
    try {
      print('getAllInterventiBySettore chiamato');
      var apiUrl = Uri.parse('$ipaddress/api/intervento/categoriaIntervento/'+widget.userData!.tipologia_intervento!.id.toString());
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
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
      var apiUrl = Uri.parse('$ipaddress/api/intervento');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LISTA INTERVENTI',//'Home ${widget.userData!.nomeCompleto().toString()}',
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
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 12, bottom: 20),
        child: LayoutBuilder(
            builder: (context, constraints){
              if (constraints.maxWidth <= 800) {
                // Tablet/Mobile layout
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      widget.userData!.id != '19' ? Wrap(children: <Widget>[
                        //joytek 19
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Interventi in corso',
                                style: TextStyle(
                                    fontSize: 30.0, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        FutureBuilder<List<InterventoModel>>(
                          future: getAllInterventiByUtente(widget.userData!.id.toString(), selectedDate),
                          builder: (context, snapshot){
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Errore: ${snapshot.error}'));
                            } else if(snapshot.hasData){
                              List<InterventoModel> interventi = snapshot.data!;
                              interventi = interventi.where((intervento) => intervento.merce == null).toList();
                              interventi = interventi.where((intervento) {
                                return intervento.orario_inizio != null && intervento.orario_fine == null;
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
                            } else{
                              return Center(child: Text(''));
                            }
                          },
                        ),
                        const SizedBox(height: 10.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Interventi personali',
                                style: TextStyle(
                                    fontSize: 30.0, fontWeight: FontWeight.bold),
                              ),
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
                                return Center(child: Text('', style: TextStyle(color: Colors.black,
                                    fontSize: 15.0)));
                              }
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
                                return Center(child: Text('', style: TextStyle(color: Colors.black,
                                    fontSize: 15.0)));
                              }
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
                      ]),
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
                                    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                    title: Text(
                                      '${singolaMerce.cliente!.denominazione!} - ${singolaMerce.merce?.articolo ?? "Articolo non specificato"}',
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
                                        Text('Data arrivo merce:', style: TextStyle(fontSize: 13, color: Colors.black)),
                                        SizedBox(height: 3),
                                        Text(
                                          relazione.intervento?.data_apertura_intervento != null
                                              ? DateFormat("dd/MM/yyyy").format(relazione.intervento!.data_apertura_intervento!)
                                              : 'Data non disponibile',
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
                    ],
                  ),
                );
              } else {
                return Scaffold(
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        widget.userData!.id != '19' ? Wrap(children: <Widget>[
                          //joytek 19
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Interventi in corso',
                                  style: TextStyle(
                                      fontSize: 30.0, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          FutureBuilder<List<InterventoModel>>(
                            future: getAllInterventiByUtente(widget.userData!.id.toString(), selectedDate),
                            builder: (context, snapshot){
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Errore: ${snapshot.error}'));
                              } else if(snapshot.hasData){
                                List<InterventoModel> interventi = snapshot.data!;
                                interventi = interventi.where((intervento) => intervento.merce == null).toList();
                                interventi = interventi.where((intervento) {
                                  return intervento.orario_inizio != null && intervento.orario_fine == null;
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
                              } else{
                                return Center(child: Text(''));
                              }
                            },
                          ),
                          const SizedBox(height: 10.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Interventi personali',
                                  style: TextStyle(
                                      fontSize: 30.0, fontWeight: FontWeight.bold),
                                ),
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
                                  return Center(child: Text('', style: TextStyle(color: Colors.black,
                                      fontSize: 15.0)));
                                }
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
                                  return Center(child: Text('', style: TextStyle(color: Colors.black,
                                      fontSize: 15.0)));
                                }
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
                        ]),
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
                                      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                      title: Text(
                                        '${singolaMerce.cliente!.denominazione!} - ${singolaMerce.merce?.articolo ?? "Articolo non specificato"}',
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
                                          Text('Data arrivo merce:', style: TextStyle(fontSize: 13, color: Colors.black)),
                                          SizedBox(height: 3),
                                          Text(
                                            relazione.intervento?.data_apertura_intervento != null
                                                ? DateFormat("dd/MM/yyyy").format(relazione.intervento!.data_apertura_intervento!)
                                                : 'Data non disponibile',
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
}

