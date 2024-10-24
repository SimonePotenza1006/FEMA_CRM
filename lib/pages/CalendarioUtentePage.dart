import 'package:fema_crm/pages/DettaglioCommissioneTecnicoPage.dart';
import 'package:fema_crm/pages/DettaglioInterventoByTecnicoPage.dart';
import 'package:fema_crm/pages/InterventoTecnicoForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'dart:convert';

import '../model/CommissioneModel.dart';
import '../model/CustomAppointmentModel.dart';
import '../model/InterventoModel.dart';
import '../model/UtenteModel.dart';

class CalendarioUtentePage extends StatefulWidget {
  final UtenteModel? utente;

  const CalendarioUtentePage({Key? key, required this.utente}) : super(key: key);

  @override
  _CalendarioUtentePageState createState() => _CalendarioUtentePageState();
}

class _CalendarioUtentePageState extends State<CalendarioUtentePage> {
  final CalendarController _calendarController = CalendarController();
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  DateTime _selectedDate = DateTime.now();
  List<InterventoModel> allInterventiByUtente = [];
  List<CommissioneModel> allCommissioniByUtente = [];
  List<CustomAppointmentModel> appointments = [];
  final AppointmentDataSource _appointmentDataSource = AppointmentDataSource([]);

  @override
  void initState() {
    super.initState();
    print('initState chiamato');
    fetchData();
  }

  Future<void> fetchData() async {
    print('fetchData chiamato');
    await getAllInterventiBySettore();//getAllInterventiByUtente();
    await getAllCommissioniByUtente();
    combineAppointments();
  }

  @override
  Widget build(BuildContext context) {
    print('build chiamato');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale('it', 'IT'),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        SfGlobalLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('it'),
      ],
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          centerTitle: true,
          title: GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100));
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                  _calendarController.displayDate = picked;
                });
              }
            },
            child: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: TextStyle(color: Colors.white),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return InterventoTecnicoForm(userData: widget.utente!);
                      },
                    ),
                  );
                },
                icon: Icon(Icons.add, color: Colors.white))
          ],
        ),
        body: Column(
          children: [
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _calendarController.view = CalendarView.month;
                      print('Vista cambiata a Mensile');
                    });
                  },
                  child: Text('MESE'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _calendarController.view = CalendarView.week;
                      print('Vista cambiata a Settimanale');
                    });
                  },
                  child: Text('SETTIMANA'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _calendarController.view = CalendarView.day;
                      print('Vista cambiata a Giornaliera');
                    });
                  },
                  child: Text('GIORNO'),
                ),
                SizedBox(width: 15),
              ],
            ),
            Expanded(
              child: SfCalendar(
                view: _calendarController.view ?? CalendarView.month,
                controller: _calendarController,
                dataSource: _appointmentDataSource,
                monthViewSettings: MonthViewSettings(
                  appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                ),
                timeSlotViewSettings: TimeSlotViewSettings(
                  startHour: 0,
                  endHour: 24,
                  timeIntervalHeight: 50, // Altezza dell'intervallo orario in pixel
                ),
                appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
                  return Container(
                    constraints: BoxConstraints(minHeight: 70),
                    child: details.appointments.isNotEmpty
                        ? ListView.builder(
                        itemCount: details.appointments.length,
                        itemBuilder: (context, index) {
                          Appointment appointment = details.appointments.elementAt(index)!;
                          return GestureDetector(
                            onTap: () {
                              if (appointment.recurrenceId is InterventoModel) {
                                InterventoModel intervento = appointment.recurrenceId as InterventoModel;
                                if ((appointment.recurrenceId as InterventoModel).utente!.id == widget.utente!.id)
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {


                                          return DettaglioInterventoByTecnicoPage(
                                              utente: widget.utente!, intervento: intervento);

                                        }

                                    ),
                                  );
                              else  showDialog(
                                  context: context!,
                                  builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Info Intervento"),
                                  content: Text('Cliente: '+intervento!.cliente!.denominazione!+
                                      '\nDestinazione: '+intervento!.destinazione!.indirizzo!+', '+intervento!.destinazione!.citta!+'\n\n'+intervento!.descrizione!+'\n\nPer utente: '+intervento!.utente!.nome!+' '+intervento!.utente!.cognome!),
                                  actions: [
                                    TextButton(
                                      child: Text("Chiudi"),
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Chiudi il dialog
                                      },
                                    ),
                                  ],
                                );});
                                //null; //alert info intervento
                            } else
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {

                                    CommissioneModel commissione = appointment.recurrenceId as CommissioneModel;
                                    return DettaglioCommissioneTecnicoPage(commissione: commissione);

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
                                            color: appointment.color == Colors.yellowAccent ? Colors.black : Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (appointment.recurrenceId is InterventoModel && (appointment.recurrenceId as InterventoModel).concluso == true ||
                                      appointment.recurrenceId is CommissioneModel && (appointment.recurrenceId as CommissioneModel).concluso == true)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.greenAccent,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        })
                        : SizedBox.shrink(),
                  );
                },
              ),
            )

          ],
        ),
      ),
    );
  }

  Future<void> getAllCommissioniByUtente() async {
    try {
      var apiUrl = Uri.parse('$ipaddressProva/api/commissione/utente/${widget.utente!.id}');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<CommissioneModel> commissioni = [];
        for (var item in jsonData) {
          commissioni.add(CommissioneModel.fromJson(item));
        }
        setState(() {
          allCommissioniByUtente = commissioni;
        });
      } else {
        print('getAllCommissioniByUtente: fallita con status code ${response.statusCode}');
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API getAllCommissioni: $e');
    }
  }

  Future<void> getAllInterventiByUtente() async {
    try {
      print('getAllInterventiByUtente chiamato');
      var apiUrl = Uri.parse('$ipaddressProva/api/intervento/utente/${int.parse(widget.utente!.id.toString())}');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        print('getAllInterventiByUtente: successo, status code: ${response.statusCode}');
        var jsonData = jsonDecode(response.body);
        List<InterventoModel> interventi = [];
        for (var item in jsonData) {
          interventi.add(InterventoModel.fromJson(item));
        }
        setState(() {
          allInterventiByUtente = interventi;
        });
      } else {
        print('getAllInterventiByUtente: fallita con status code ${response.statusCode}');
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API getAllInterventi: $e');
    }
  }

  Future<void> getAllInterventiBySettore() async {
    try {
      print('getAllInterventiBySettore chiamato');
      var apiUrl = Uri.parse('$ipaddressProva/api/intervento/categoriaIntervento/'+widget.utente!.tipologia_intervento!.id.toString());
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        print('getAllInterventiByUtente: successo, status code: ${response.statusCode}');
        var jsonData = jsonDecode(response.body);
        List<InterventoModel> interventi = [];
        for (var item in jsonData) {
          if (InterventoModel.fromJson(item).data != null && InterventoModel.fromJson(item).utente != null) //solo gli interventi con data e utente
          interventi.add(InterventoModel.fromJson(item));
        }
        setState(() {
          allInterventiByUtente = interventi;
        });
      } else {
        print('getAllInterventiBySettore: fallita con status code ${response.statusCode}');
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API getAllInterventi: $e');
    }
  }


  void combineAppointments() {
    appointments = [];
    appointments.addAll(allInterventiByUtente.map((intervento) {
      print('ut: '+intervento.utente!.toString()+' '+widget.utente.toString());
      DateTime startTime = intervento.data!;
      DateTime endTime = startTime.add(Duration(hours: 1));
      String? utente = intervento.utente != null ? intervento.utente?.nomeCompleto() : 'NON ASSEGNATO';
      String? subject = "${intervento.descrizione}";
      return CustomAppointmentModel(
        startTime: startTime,
        endTime: endTime,
        subject: "${intervento.descrizione}",
        recurrenceId: intervento,
        color: intervento.utente!.id == widget.utente!.id ? Colors.red : Colors.grey,
        concluso: intervento.concluso, // Aggiunto per tracciare lo stato 'concluso'
      );
    }).toList());
    appointments.addAll(allCommissioniByUtente.map((commissione) {
      DateTime startTime = commissione.data!;
      DateTime endTime = startTime.add(Duration(hours: 3));
      return CustomAppointmentModel(
        startTime: startTime,
        endTime: endTime,
        subject: commissione.descrizione!,
        recurrenceId: commissione,
        color: Colors.yellow[900]!,
        concluso: commissione.concluso, // Aggiunto per tracciare lo stato 'concluso'
      );
    }).toList());
    setState(() {
      _appointmentDataSource.updateAppointments(appointments);
    });
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<CustomAppointmentModel> source) {
    appointments = source;
  }

  @override
  List<dynamic> get appointments => super.appointments!;

  void updateAppointments(List<CustomAppointmentModel> newAppointments) {
    print('updateAppointments chiamato');
    appointments = newAppointments;
    notifyListeners(CalendarDataSourceAction.reset, newAppointments);
  }
}
