import 'package:fema_crm/model/MerceInRiparazioneModel.dart';
import 'package:fema_crm/pages/MenuSopralluoghiTecnicoPage.dart';
import 'package:fema_crm/pages/SpesaSuVeicoloPage.dart';
import 'package:fema_crm/pages/TimbraturaPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import '../main.dart';
import '../model/CommissioneModel.dart';
import '../model/InterventoModel.dart';
import '../model/RelazioneUtentiInterventiModel.dart';
import '../model/UtenteModel.dart';
import 'CalendarioUtentePage.dart';
import 'DettaglioCommissioneTecnicoPage.dart';
import 'DettaglioInterventoByTecnicoPage.dart';
import 'DettaglioMerceInRiparazioneByTecnicoPage.dart';
import 'FormOrdineFornitorePage.dart';
import 'InterventoTecnicoForm.dart';
import 'InizializzazionePreventivoByTecnicoPage.dart';
import 'ListaPreventiviTecnicoPage.dart';
import 'SopralluogoTecnicoForm.dart';
import '../databaseHandler/DbHelper.dart';


class HomeFormTecnico extends StatefulWidget {
  final UtenteModel? userData;

  const HomeFormTecnico({Key? key, required this.userData}) : super(key: key);

  @override
  _HomeFormTecnicoState createState() => _HomeFormTecnicoState();
}

class _HomeFormTecnicoState extends State<HomeFormTecnico> {
  DateTime selectedDate = DateTime.now();
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());





  @override
  void initState() {
    super.initState();
    saveIngresso();
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

  Future<List<MerceInRiparazioneModel>> getMerceInRiparazione(String userId) async{
    try {
      String userId = widget.userData!.id.toString();
      http.Response response = await http
          .get(Uri.parse('${ipaddress}/api/merceInRiparazione/utente/$userId'));
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
          .get(Uri.parse('${ipaddress}/api/relazioneUtentiInterventi/utente/$userId'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<RelazioneUtentiInterventiModel> allRelazioniByUtente = [];
        for(var item in responseData){
          RelazioneUtentiInterventiModel relazione = RelazioneUtentiInterventiModel.fromJson(item);

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
                MaterialPageRoute(builder: (context) => LoginForm()),
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
              padding: const EdgeInsets.all(60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      "Bentornato ${widget.userData!.nome.toString()}!",
                      textAlign: TextAlign.center, // Centra il testo
                      style: TextStyle(
                        fontSize: 24, // Imposta la dimensione del testo
                        fontWeight: FontWeight.bold, // Imposta il grassetto
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TimbraturaPage(
                                  utente: widget.userData!)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      icon: Icon(Icons.more_time, size: 30, color: Colors.white),
                      label: Text(
                        'Timbratura',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 60,
                  //   child: ElevatedButton.icon(
                  //     onPressed: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) => InterventoTecnicoForm(
                  //                 userData: widget.userData!)),
                  //       );
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       primary: Colors.red,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(20.0),
                  //       ),
                  //     ),
                  //     icon: Icon(Icons.build, size: 30, color: Colors.white),
                  //     label: Text(
                  //       'Intervento',
                  //       style: TextStyle(color: Colors.white, fontSize: 20),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CalendarioUtentePage(utente : widget.userData)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: Icon(Icons.calendar_month,
                            size: 30, color: Colors.white),
                      label: Text(
                        'Calendario',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                  SizedBox(
                    height:20
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FormOrdineFornitorePage(utente: widget.userData!)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      icon: Icon(Icons.business_center,
                          size: 30, color: Colors.white),
                      label: Text(
                        'Richiesta d\'ordine',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MenuSopralluoghiTecnicoPage(utente: widget.userData!)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      icon: Icon(Icons.remove_red_eye_outlined,
                          size: 30, color: Colors.white),
                      label: Text(
                        'Sopralluogo',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                            SpesaSuVeicoloPage(utente: widget.userData!)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                        ),
                      ),
                      icon: Icon(Icons.emoji_transportation_outlined,
                              size: 30, color: Colors.white),
                      label: Text(
                        "Spesa su veicolo",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      )
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 60,
                  //   child: ElevatedButton.icon(
                  //     onPressed: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) =>
                  //                 InizializzazionePreventivoByTecnicoPage(
                  //                     utente: widget.userData!)),
                  //       );
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       primary: Colors.red,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(20.0),
                  //       ),
                  //     ),
                  //     icon: Icon(Icons.assignment_outlined,
                  //         size: 30, color: Colors.white),
                  //     label: Text(
                  //       'Registrazione preventivo',
                  //       style: TextStyle(color: Colors.white, fontSize: 20),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 60,
                  //   child: ElevatedButton.icon(
                  //     onPressed: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) => ListaPreventiviTecnicoPage(
                  //                 utente: widget.userData!)),
                  //       );
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       primary: Colors.red,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(20.0),
                  //       ),
                  //     ),
                  //     icon: Icon(Icons.badge_outlined,
                  //         size: 30, color: Colors.white),
                  //     label: Text(
                  //       'I tuoi preventivi',
                  //       style: TextStyle(color: Colors.white, fontSize: 20),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            Center(
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
                  return Center(child: Text('Nessun intervento trovato'));
                }
              },
            ),

            const SizedBox(height: 50.0),
            const Text(
              'Agenda Commissioni',
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
}


