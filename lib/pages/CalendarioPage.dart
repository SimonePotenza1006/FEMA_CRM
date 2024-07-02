import 'package:fema_crm/model/CommissioneModel.dart';
import 'package:fema_crm/model/CustomAppointmentModel.dart';
import 'package:fema_crm/model/InterventoModel.dart';
import 'package:fema_crm/model/TipologiaInterventoModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:fema_crm/pages/CreazioneInterventoByAmministrazionePage.dart';
import 'package:fema_crm/pages/DettaglioCommissioneAmministrazionePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'DettaglioInterventoPage.dart';

class CalendarioPage extends StatefulWidget {
  @override
  _CalendarioPageState createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  final CalendarController _calendarController = CalendarController();
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  DateTime _selectedDate = DateTime.now();
  List<InterventoModel> allInterventi = [];
  List<CommissioneModel> allCommissioni = [];
  List<CustomAppointmentModel> appointments = [];
  List<TipologiaInterventoModel> allTipologie = [];
  List<UtenteModel> allUtenti = [];
  UtenteModel? _selectedUser;
  final AppointmentDataSource _appointmentDataSource = AppointmentDataSource([]);

  @override
  void initState() {
    super.initState();
    print('initState chiamato');
    fetchData();
  }

  Future<void> fetchData() async {
    print('fetchData chiamato');
    await getTipologieIntervento();
    await getAllInterventi();
    await getAllCommissioni();
    await getAllUtenti();
    combineAppointments();
  }

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
    appointments.addAll(allInterventi.map((intervento) {
      DateTime startTime = intervento.orario_appuntamento!= null? intervento.orario_appuntamento! : intervento.data!;
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
    appointments.addAll(allCommissioni.map((commissione) {
      DateTime startTime = commissione.data!;
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
        return Colors.yellowAccent;
      case 5:
        return Colors.pinkAccent;
      default:
        return Colors.grey;
    }
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    if (backgroundColor == Colors.red ||
        backgroundColor == Colors.blueAccent ||
        backgroundColor == Colors.grey ||
        backgroundColor == Colors.yellow[900]) {
      return Colors.white;
    }
    return Colors.black;
  }

  void showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FilterModal(
          allUtenti: allUtenti,
          onUserSelected: (selectedUser) {
            setState(() {
              _selectedUser = selectedUser;
              filterAppointments();
            });
          },
        );
      },
    );
  }

  void filterAppointments() {
    appointments = [];
    appointments.addAll(allInterventi
        .where((intervento) => intervento.utente!.id == _selectedUser?.id)
        .map((intervento) {
      DateTime startTime = intervento.orario_appuntamento!= null
          ? intervento.orario_appuntamento!
          : intervento.data!;
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
    appointments.addAll(allCommissioni
        .where((commissione) => commissione.utente!.id == _selectedUser?.id)
        .map((commissione) {
      DateTime startTime = commissione.data!;
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale('it', 'IT'),
      localizationsDelegates: [
        SfGlobalLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('it', 'IT'),
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
                lastDate: DateTime(2100),
              );
              if (picked!= null) {
                setState(() {
                  _selectedDate = picked;
                  _calendarController.displayDate = picked;
                  print('Data selezionata: $_selectedDate');
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
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return CreazioneInterventoByAmministrazionePage();
                      },
                    ),
                  );
                },
                icon: Icon(Icons.add, color: Colors.white)
            )
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
                  child: Text('Mensile'),
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
                  child: Text('Settimanale'),
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
                  child: Text('Giornaliera'),
                ),
                SizedBox(width: 15),
              ],
            ),
            Expanded(
              child: SfCalendar(
                view: _calendarController.view?? CalendarView.month,
                controller: _calendarController,
                dataSource: _appointmentDataSource,
                monthViewSettings: MonthViewSettings(
                  appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                ),
                appointmentBuilder: (BuildContext context, CalendarAppointmentDetails details) {
                  print('appointmentBuilder chiamato');
                  return Container(
                    constraints: BoxConstraints(minHeight: 70),
                    child: details.appointments.isNotEmpty
                        ? ListView.builder(
                      itemCount: details.appointments.length,
                      itemBuilder: (context, index) {
                        Appointment appointment = details.appointments.elementAt(index)!;

                        return GestureDetector(
                          onTap: () {
                            // Navigate to DettaglioInterventoPage with the appointment's recurrenceId
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  if (appointment.recurrenceId is InterventoModel) {
                                    InterventoModel intervento = appointment.recurrenceId as InterventoModel;
                                    return DettaglioInterventoPage(intervento: intervento);
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
                    )
                        : SizedBox.shrink(),
                  );
                },

              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,

          onPressed: () {
            showFilterModal(context);
          },
          child: Icon(Icons.filter_list, color: Colors.white,),
        ),
      ),
    );
  }
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<CustomAppointmentModel> source) {
    appointments = source;
  }

  @override
  List<dynamic> get appointments => super.appointments!;

  void updateAppointments(List<CustomAppointmentModel> newAppointments) {
    appointments = newAppointments;
    notifyListeners(CalendarDataSourceAction.reset, newAppointments);
  }
}

class FilterModal extends StatefulWidget {
  final List<UtenteModel> allUtenti;
  final Function(UtenteModel?) onUserSelected;

  FilterModal({required this.allUtenti, required this.onUserSelected});

  @override
  _FilterModalState createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  UtenteModel? _selectedUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<UtenteModel>(
            decoration: InputDecoration(
              labelText: 'Seleziona utente',
              border: OutlineInputBorder(),
            ),
            value: _selectedUser,
            onChanged: (UtenteModel? newValue) {
              setState(() {
                _selectedUser = newValue;
              });
            },
            items: widget.allUtenti.map((utente) {
              return DropdownMenuItem<UtenteModel>(
                value: utente,
                child: Text(utente.nomeCompleto().toString()),
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty.all<Color>(Colors.red),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
            ),
            onPressed: () {
              widget.onUserSelected(_selectedUser);
              Navigator.pop(context);
            },
            child: Text('Filtrare', style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }
}