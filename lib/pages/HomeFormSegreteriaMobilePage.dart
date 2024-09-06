import 'dart:io';
import 'package:fema_crm/model/MerceInRiparazioneModel.dart';
import 'package:fema_crm/pages/MenuSopralluoghiTecnicoPage.dart';
import 'package:fema_crm/pages/SpesaSuVeicoloPage.dart';
import 'package:fema_crm/pages/TimbraturaPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
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
  String formattedDate = intl.DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
  int _hoveredIndex = -1;
  int _lastClickedIndex = 0;
  Map<int, int> _menuItemClickCount = {};


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
  }

  final List<MenuItem> _menuItems = [
    MenuItem(icon: Icons.more_time, label: 'TIMBRATURA'),
    MenuItem(icon: Icons.calendar_month_outlined, label: 'CALENDARIO'),
    MenuItem(icon: Icons.business_center, label: 'RICHIESTA D\'ORDINE'),
    MenuItem(icon: Icons.remove_red_eye_outlined, label: 'SOPRALLUOGO'),
    MenuItem(icon: Icons.emoji_transportation_sharp, label: 'SPESA SU\nVEICOLO'),
  ];

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


    //if (_menuItemClickCount[index] % 2 == 0 && _hoveredIndex != -1) {
    if ((_menuItemClickCount[index] ?? 0) % 2 == 0 && _hoveredIndex != -1) {
      switch (index) {
        case 0:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TimbraturaPage(
                utente: widget.userData!)),
          );
          break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
                CalendarioUtentePage(utente : widget.userData)),
          );
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FormOrdineFornitorePage(utente: widget.userData!)),
          );
          break;
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
                MenuSopralluoghiTecnicoPage(utente: widget.userData!)), //ListaInterventiFinalPage()),
          );
          break;
        case 4:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
                SpesaSuVeicoloPage(utente: widget.userData!)),
          );
          break;
      }
    }
  }

  int _calculateHoveredIndex(Offset position) {
    final center = Offset(500 / 2, 500 / 2); // Use the same size as in CustomPaint
    final angle = (math.atan2(position.dy - center.dy, position.dx - center.dx) + math.pi * 2) % (math.pi * 2);
    final sectorAngle = (2 * math.pi) / 14; // 14 menu items
    final hoveredIndex = (angle ~/ sectorAngle) % 14;
    return hoveredIndex;
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
                  /*SizedBox(
                    height: 7,
                  ),*/
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
                      size: Size(400, 400),
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
                        size: Size(400, 400),
                        hoveredIndex: _hoveredIndex,
                      ),
                    ),
                  ),


                  /*SizedBox(
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
                  ),*/

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
            /*SizedBox(
              height: 180,
            ),*/
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
}

class MenuPainter extends CustomPainter {
  final Function(int) onHover;
  final Function() onHoverExit;
  final Size size;
  final int hoveredIndex;
  final BuildContext context; // Add BuildContext

  MenuPainter(this.onHover, this.onHoverExit, this.context, {required this.size, required this.hoveredIndex});

  // List of menu items
  final List<MenuItem> _menuItems = [
    MenuItem(icon: Icons.more_time, label: 'TIMBRATURA'),
    MenuItem(icon: Icons.calendar_month_outlined, label: 'CALENDARIO'),
    MenuItem(icon: Icons.business_center, label: 'RICHIESTA\nD\'ORDINE'),
    MenuItem(icon: Icons.remove_red_eye_outlined, label: 'SOPRALLUOGO'),
    MenuItem(icon: Icons.emoji_transportation_sharp, label: 'SPESA SU\nVEICOLO'),
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
    textDirection: TextDirection.ltr,
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

      //Draw the icon in white
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
        textDirection: TextDirection.ltr,
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
              fontSize: 18,
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
      onHover(newIndex); // Call the onHover callback
      return true;
    }
    onHoverExit(); // Call the onHoverExit callback
    return false;
  }
}

class MenuItem {
  final IconData icon;
  final String label;

  MenuItem({required this.icon, required this.label});
}