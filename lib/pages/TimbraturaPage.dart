import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart' as ex;
import 'package:fema_crm/model/MarcaTempoModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'PDFOggiPage.dart';

class TimbraturaPage extends StatefulWidget {
  final UtenteModel utente;
  const TimbraturaPage({Key? key, required this.utente}) : super(key: key);

  @override
  _TimbraturaPageState createState() => _TimbraturaPageState();
}

class _TimbraturaPageState extends State<TimbraturaPage> {
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();
  Uint8List? signatureBytes;
  bool _isSigned = false;
  final _formKey = GlobalKey<FormState>();
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String dataOdierna = DateFormat('dd-MM-yyyy, HH:mm').format(DateTime.now()).toString();
  late String nomeUtente = "${widget.utente.nome} ${widget.utente.cognome}";
  String tipoTimbratura = "";
  late String _gps;
  late String _indirizzo;
  late int idMarcatempo;
  late List<MarcaTempoModel> timbratureOdierne = [];
  List<MarcaTempoModel> allTimbratureMonth = [];
  List<MarcaTempoModel> allTimbratureDU = [];

  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      return '${place.street},${place.subThoroughfare} ${place.locality} ${place.postalCode}';//, ${place.country}';
    } catch (e) {
      print("Errore durante la conversione delle coordinate in indirizzo: $e");
      return "Indirizzo non disponibile";
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      String indirizzo =
      await getAddressFromCoordinates(position.latitude, position.longitude);
      setState(() {
        _gps = "${position.latitude}, ${position.longitude}";
        _indirizzo = indirizzo.toString();
      });
    } catch (e) {
      print("Errore durante l'ottenimento della posizione: $e");
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _marcatController.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
    _marcatController.text = "";
    getMarcatempoOggi();
    getAllUtenti();
    _getCurrentLocation().then((value) => print('${_indirizzo}'));
  }

  void firmaTrue() {
    _isSigned = true;
  }

  DateTime _selectedDate = DateTime.now().subtract(Duration(days: 1));
  String? _selectedUtente = '1';
  late var utentidb;

  Future<List<UtenteModel>?> getAllUtenti() async {
    try {
      final response = await http.get(Uri.parse('$ipaddress/api/utente'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<UtenteModel> utenti = [];
        for (var item in jsonData) {
          utenti.add(UtenteModel.fromJson(item));
        }
        return utenti;
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata API: $e');
      return null; // Ritorna null in caso di errore
    }
  }

  TextEditingController _dateController = TextEditingController();
  TextEditingController _marcatController = TextEditingController();

  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(_selectedDate.year, _selectedDate.month - 1, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _marcatController.text = "";
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      });
    }
  }

  Future<void> _showDialog() async {
    setState(() {
      _marcatController.text = '';
    });

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Container(
                  width: 865.0, // Imposta la larghezza desiderata
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Seleziona data e utente',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            width: 230,
                            child: ListTile(
                              //title: Text('Data:'),
                              subtitle: TextField(
                                controller: _dateController,
                                readOnly: true,
                                onTap: _showDatePicker,
                                decoration: InputDecoration(
                                  suffixIcon: Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                ),
                              ),
                              onTap: () async {
                                setState(() {
                                  _marcatController.text = "";
                                });
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(_selectedDate.year, _selectedDate.month - 1, 1),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _marcatController.text = '';
                                    _selectedDate = picked;
                                  });
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 50),
                          Text(
                            'Utente:',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(width: 10),
                          FutureBuilder(
                            future: getAllUtenti(),
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text("${snapshot.error}");
                              } else if (snapshot.hasData && snapshot.data != null) {
                                return DropdownButton<String>(
                                  value: _selectedUtente,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedUtente = newValue;
                                      _marcatController.text = '';
                                    });
                                  },
                                  items: snapshot.data.map<DropdownMenuItem<String>>((value) {
                                    return DropdownMenuItem<String>(
                                      value: value.id,
                                      child: Text(
                                        value.nome! + ' ' + value.cognome!,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    );
                                  }).toList(),
                                );
                              } else {
                                return Text("Nessun dato disponibile");
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  )
              ),
              actions: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          getAllMarcatempoDataUtente(_selectedDate, _selectedUtente!);
                          // Navigator.of(context).pop(); // Chiudi l'AlertDialog
                        },
                        child: Text('CERCA', style: TextStyle(color: Colors.white, fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          padding: EdgeInsets.all(20),
                        ),
                      ),
                    ]),
                SizedBox(height: 10),
                TextFormField(
                  maxLines: 3,
                  controller: _marcatController,
                  readOnly: true,
                  showCursor: false,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    // labelText: 'Testo',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: const Text(
            'Timbratura',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.red,
          actions:  widget.utente.cognome == "Mazzei" || widget.utente.cognome == "Chiriatti" ? <Widget>[
            IconButton(
                color: Colors.white,
                icon: Icon(Icons.search), onPressed: () async {
              _showDialog();
            }),
            SizedBox(width: 23),
            IconButton(
                color: Colors.white,
                icon: Icon(Icons.assignment_outlined), onPressed: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Scarica il resoconto delle presenze"),
                    actions: [
                      Center(
                        child:  Column(
                          children: [
                            TextButton(
                              onPressed: () {
                                getAllMarcatempoMonth(2).whenComplete(() => _generateExcel());
                                Navigator.of(context).pop();
                              },
                              child: Text("Mese precedente"), //no
                            ),
                            SizedBox(width: 45,),
                            TextButton(
                              onPressed: () {
                                getAllMarcatempoMonth(1).whenComplete(() =>  _generateExcel());
                                Navigator.of(context).pop();
                              },
                              child: Text("Mese corrente"), //si
                            ),
                            SizedBox(width: 80,),
                            TextButton(
                              onPressed: () {
                                getAllMarcatempoToday().whenComplete(() {
                                  if (timbratureOdierne.isNotEmpty)
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PDFOggiPage(timbrature: timbratureOdierne),
                                      ),
                                    ); else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Ancora nessuna timbratura in data odierna')));
                                  }
                                });
                              },
                              child: Text("Oggi"), //si
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                },
              );
            }),
            SizedBox(width: 12,)
          ] : null
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: SizedBox(
                    width: 300,
                    height: 150,
                    child: Image(image: AssetImage('assets/images/logo.png')),
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  '${nomeUtente}',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 15),
                Text(
                  '${tipoTimbratura}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                Text(
                  '${dataOdierna}',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 50),
                Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: SfSignaturePad(
                      onDraw: (offset, time) {
                        firmaTrue();
                      },
                      key: signatureGlobalKey,
                      backgroundColor: Colors.white,
                      strokeColor: Colors.black,
                      minimumStrokeWidth: 1.0,
                      maximumStrokeWidth: 4.0),
                ),
                SizedBox(height: 30),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          resetFirma();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          padding: EdgeInsets.all(20),
                        ),
                        child: const Text(
                          'RESET FIRMA',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          timbra();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        ),
                        child: const Text(
                          '  TIMBRA  ',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int lastRow = 1; // Se il foglio Excel ha un'intestazione, partire da 1
  int lastColumn = 3; // Numero di colonne che stai aggiungendo
  void _generateExcel() async {
    var excel = ex.Excel.createExcel();
    ex.Sheet sheetObject = excel['Sheet1'];
    sheetObject.appendRow([
      'Utente',
      'Data',
      'Totale Ore',
      'GPS Entrata',
      'Ora Entrata',
      'GPS Uscita',
      'Ora Uscita',
      'GPS Entrata',
      'Ora Entrata',
      'GPS Uscita',
      'Ora Uscita',
      'GPS Entrata',
      'Ora Entrata',
      'GPS Uscita',
      'Ora Uscita',
    ]);
    // Map per tenere traccia delle somme delle differenze per utente e giorno
    Map<String, Map<DateTime, Duration>> userDayDifferences = {};
    // Calcola le differenze e aggiungi i dati al foglio Excel
    for (var timbratura in allTimbratureMonth) {
      // Verifica se l'utente e il giorno corrente sono giÃ  stati inseriti nella mappa
      String? userId = timbratura.utente?.id;
      DateTime? dayKey = DateTime(timbratura.data!.year, timbratura.data!.month, timbratura.data!.day);
      if (userId != null && dayKey != null) {
        userDayDifferences.putIfAbsent(userId, () => {});
        userDayDifferences[userId]!.update(dayKey, (value) => value + (timbratura.datau?.difference(timbratura.data!) ?? Duration.zero), ifAbsent: () => timbratura.datau?.difference(timbratura.data!) ?? Duration.zero);
      }
    }
    // Aggiungi i dati al foglio Excel utilizzando le somme delle differenze
    for (var entry in userDayDifferences.entries) {
      String userId = entry.key;
      Map<DateTime, Duration> dayMap = entry.value;
      dayMap.forEach((day, difference) {
        // Ottieni le informazioni sulla timbratura corrispondente
        List<MarcaTempoModel?> matchingTimbraturas = allTimbratureMonth.where((timbratura) =>
        timbratura.utente?.id == userId &&
            timbratura.data?.year == day.year &&
            timbratura.data?.month == day.month &&
            timbratura.data?.day == day.day).toList();
        if (matchingTimbraturas != null) {
          // Ottieni il nome completo dell'utente
          String userFullName = matchingTimbraturas.first!.utente?.nomeCompleto() ?? '';
          Map<String, List<dynamic>> groupedRows = {};
          var cellStyleRed = ex.CellStyle(
            fontColorHex: "#FF0000",
          );
          var cellStyleDefault = ex.CellStyle(
            fontColorHex: "#000000",
          );
          for (var timbratura in matchingTimbraturas) {
            String key = '${userFullName}_${day.day}/${day.month}/${day.year}';
            // Se non esiste ancora una lista per questa chiave, creala
            groupedRows.putIfAbsent(key, () => [
              userFullName,
              DateFormat('dd-MM-yyyy').format(day),
              //"${day.day}/${day.month}/${day.year}",
              '${difference.inHours.toString().padLeft(2, '0')}:${difference.inMinutes.remainder(60).toString().padLeft(2, '0')}',
            ]);
            // Aggiungi i dati specifici della timbratura alla lista per questa chiave
            groupedRows[key]!.addAll([
              timbratura!.gps ?? '',
              DateFormat('HH:mm').format(timbratura.data!),
              //'${timbratura.data!.hour.toString()}:${timbratura.data!.minute.toString()}',
              timbratura!.gpsu ?? '',
              timbratura.datau != null ? DateFormat('HH:mm').format(timbratura.datau!) : '',
              //timbratura.datau != null ? '${timbratura.datau!.hour.toString()}:${timbratura.datau!.minute.toString()}' : '',
            ]);
          }
          // Aggiungi tutte le righe raggruppate alla tabella
          for (var row in groupedRows.values) {
            sheetObject.appendRow(row);
          }
          //evidenzio in rosso i gps non in sede
          bool redRow = false;
          for (int rowIndex = 2; rowIndex <= sheetObject.maxRows; rowIndex++) {
            redRow = false; // Resetta il flag ad ogni iterazione di riga
            for (var column in ['D', 'F', 'H', 'J', 'L', 'N']) {
              var cellValue = sheetObject.cell(ex.CellIndex.indexByString("$column$rowIndex")).value;
              print('value '+cellValue.toString());
              if (cellValue.toString() != 'null' && cellValue.toString() != '' && (!cellValue.toString().contains('Via Europa') || !cellValue.toString().contains('73021'))) {
                print('rig $rowIndex, colonn $column $cellValue');
                sheetObject.cell(ex.CellIndex.indexByString("C$rowIndex")).cellStyle = cellStyleRed;
                sheetObject.cell(ex.CellIndex.indexByString("$column$rowIndex")).cellStyle = cellStyleRed;
                redRow = true; // Imposta il flag a true se almeno una delle celle Ã¨ rossa
              }
            }
            if (!redRow) {
              sheetObject.cell(ex.CellIndex.indexByString("C$rowIndex")).cellStyle = cellStyleDefault;
            }
          }
        }
      });
    }
    try {
      // Codifica il file Excel e salvalo
      late String filePath;
      if (Platform.isWindows) {
        String appDocumentsPath = 'C:\\ReportTimbrature';
        filePath = '$appDocumentsPath\\report_timbrature.xlsx';
      } else if (Platform.isAndroid) {
        Directory? externalStorageDir = await getExternalStorageDirectory();
        if (externalStorageDir != null) {
          String appDocumentsPath = externalStorageDir.path;
          filePath = '$appDocumentsPath/report_timbrature.xlsx';
        } else {
          throw Exception('Impossibile ottenere il percorso di salvataggio.');
        }
      }
      var excelBytes = await excel.encode();
      if (excelBytes != null) {
        await File(filePath).create(recursive: true).then((file) {
          file.writeAsBytesSync(excelBytes);
        });
        // Notifica all'utente che il file Ã¨ stato salvato con successo
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Excel salvato in $filePath')));
      } else {
        print('Errore durante la codifica del file Excel');
      }
    } catch (error) {
      print('Errore durante il salvataggio del file Excel: $error');
    }
  }

  Future<void> timbra() async {
    if (_isSigned == true) {
      try {
        if (tipoTimbratura == "INGRESSO") {
          print('${tipoTimbratura}');
          final response = await http.post(
            Uri.parse('${ipaddress}/marcatempo'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'gps': _indirizzo.toString(),
              'data': DateTime.now().toIso8601String(),
              'utente': widget.utente.toMap(),
              'viaggio': {
                'id': 2,
                'destinazione': 'Calimera',
                'data_arrivo': null,
                'data_partenza': null,
              },
            }),
          );
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Timbratura di INGRESSO registrata con successo!'),
            ),
          );
        } else {
          print('${tipoTimbratura}');
          final response = await http.post(
            Uri.parse('${ipaddress}/marcatempo'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id': idMarcatempo,
              'gps': timbratureOdierne.last.gps,
              'gpsu': _indirizzo.toString(),
              'data': timbratureOdierne.last.data!.toIso8601String(),
              'datau': DateTime.now().toIso8601String(),
              'viaggio': {
                'id': 2,
                'destinazione': 'Calimera',
                'data_arrivo': null,
                'data_partenza': null,
              },
              'utente': widget.utente.toMap(),
            }),
          );
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Timbratura di USCITA registrata con successo!'),
            ),
          );
        };
      } catch (e) {
        print('Errore durante il salvataggio del marcatempo: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inserisci una firma per validare la timbratura!'),
        ),
      );
    }
  }

  void resetFirma() {
    signatureGlobalKey.currentState?.clear();
    _isSigned = false;
  }

  Future<void> getAllMarcatempoDataUtente(DateTime data, String utenteid) async {
    try {
      var apiUrl = Uri.parse('${ipaddress}/marcatempo');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<MarcaTempoModel> allMarcatemposDU = [];

        for (var item in jsonData) {
          MarcaTempoModel marcatempo = MarcaTempoModel.fromJson(item);
          print(DateFormat('yyyy-MM-dd').format(marcatempo.data!)+' '+DateFormat('yyyy-MM-dd').format(data)+' '+marcatempo.utente!.id.toString()+' '+int.parse(utenteid).toString());
          if (marcatempo.data != null &&
              DateFormat('yyyy-MM-dd').format(marcatempo.data!) == DateFormat('yyyy-MM-dd').format(data) && marcatempo.utente!.id == utenteid) {
            allMarcatemposDU.add(marcatempo);
          }
        }
        setState(() {
          allTimbratureDU = allMarcatemposDU;
          if (allMarcatemposDU.isNotEmpty) {
            for (var item in allMarcatemposDU) {
              _marcatController.text = allMarcatemposDU.map(
                      (item) =>
                  (DateFormat('HH:mm').format(item.data!) + ' ' + item.gps! +
                      ' - '
                      + (item.datau != null ? DateFormat('HH:mm').format(item.datau!) + ' ' + item.gpsu! : '     /      ')
                  )).join('\n');
            }
          } else _marcatController.text= '- nessun risultato -';
        });
        print('mmmm '+_marcatController.text);
      }
    } catch (e) {
      print('Errore durante il recupero dei marcatempo: $e');
    }
  }

  Future<void> getAllMarcatempoToday() async {
    try {
      var apiUrl = Uri.parse('${ipaddress}/marcatempo/pres/1/2');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<MarcaTempoModel> allMarcatempos = [];

        DateTime now = DateTime.now();
        DateTime? firstDayOfMonth = null;
        DateTime? lastDayOfMonth = null;

        // Ottieni la data di inizio e fine del mese precedente
        firstDayOfMonth = DateTime(now.year, now.month, now.day);
        lastDayOfMonth = now.add(Duration(days: 1));//DateTime(now.year, now.month, 0);

        for (var item in jsonData) {
          MarcaTempoModel marcatempo = MarcaTempoModel.fromJson(item);
          // Controlla se la data del marcatempo Ã¨ nel mese corrente
          if (marcatempo.data != null &&
              (marcatempo.data!.isAfter(firstDayOfMonth!) || marcatempo.data == firstDayOfMonth) &&
              (marcatempo.data!.isBefore(lastDayOfMonth!) || marcatempo.data == lastDayOfMonth)) {
            allMarcatempos.add(marcatempo);
          }
          /*if (marcatempo.data != null &&
              marcatempo.data!.isAfter(firstDayOfMonth!) &&
              marcatempo.data!.isBefore(lastDayOfMonth!)) {
            allMarcatempos.add(marcatempo);
          }*/
        }
        // Imposta il valore di allTimbratureMonth a allMarcatempos utilizzando setState
        setState(() {
          timbratureOdierne = allMarcatempos;
          print('timbr oggi '+allMarcatempos.toString());
        });
      }
    } catch (e) {
      print('Errore durante il recupero dei marcatempo: $e');
    }
  }

  Future<void> getAllMarcatempoMonth(int current) async {
    try {
      var apiUrl = Uri.parse('${ipaddress}/marcatempo');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<MarcaTempoModel> allMarcatempos = [];

        DateTime now = DateTime.now();
        DateTime? firstDayOfMonth = null;
        DateTime? lastDayOfMonth = null;

        if(current == 1) {
          // Ottieni la data di inizio e fine del mese corrente
          firstDayOfMonth = DateTime(now.year, now.month, 1);
          lastDayOfMonth = DateTime(now.year, now.month + 1, 1);
        } else if (current ==2){
          // Ottieni la data di inizio e fine del mese precedente
          firstDayOfMonth = DateTime(now.year, now.month - 1, 1);
          lastDayOfMonth = DateTime(now.year, now.month, 1);
        }
        for (var item in jsonData) {
          MarcaTempoModel marcatempo = MarcaTempoModel.fromJson(item);
          // Controlla se la data del marcatempo Ã¨ nel mese corrente
          if (marcatempo.data != null &&
              (marcatempo.data!.isAfter(firstDayOfMonth!) || marcatempo.data == firstDayOfMonth) &&
              (marcatempo.data!.isBefore(lastDayOfMonth!) || marcatempo.data == lastDayOfMonth)) {
            allMarcatempos.add(marcatempo);
          }
        }
        setState(() {
          allTimbratureMonth = allMarcatempos;
          print('timbr '+allMarcatempos.toString());
        });
      }
    } catch (e) {
      print('Errore durante il recupero dei marcatempo: $e');
    }
  }

  Future<void> getMarcatempoOggi() async {
    try {
      var apiUrl = Uri.parse('${ipaddress}/marcatempo/oggi/${widget.utente.id}/2');
      var response = await http.get(apiUrl);
      var jsonData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<MarcaTempoModel> timbrature = [];
        for (var item in jsonData) {
          timbrature.add(MarcaTempoModel.fromJson(item));
          setState(() {
            timbratureOdierne = timbrature;
          });
        }
        if (timbrature.isNotEmpty) {
          if (timbrature.last.datau == null) {
            print("Uscita");
            setState(() {
              idMarcatempo = int.parse(timbrature.last.id!);
              tipoTimbratura = "USCITA";
            });
          } else {
            print('Entrata');
            setState(() {
              idMarcatempo = int.parse(timbrature.last.id!);
              tipoTimbratura = "INGRESSO";
            });
          }
        } else {
          print("Entrata");
          setState(() {
            tipoTimbratura = "INGRESSO";
          });
        }
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
    }
  }
}