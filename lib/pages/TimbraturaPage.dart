import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart' as ex;
import 'package:fema_crm/model/MarcaTempoModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

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
  String dataOdierna =
      "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}, ${DateTime.now().hour}:${DateTime.now().minute}";
  late String nomeUtente = "${widget.utente.nome} ${widget.utente.cognome}";
  String tipoTimbratura = "";
  late String _gps;
  late String _indirizzo;
  late int idMarcatempo;
  late List<MarcaTempoModel> timbratureOdierne = [];
  List<MarcaTempoModel> allTimbratureMonth = [];

  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      return '${place.street},${place.subThoroughfare} ${place.locality} ${place.postalCode}, ${place.country}';
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
  void initState() {
    super.initState();
    getMarcatempoOggi();
    _getCurrentLocation().then((value) => print('${_indirizzo}'));
    if(widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti") {
      getAllMarcatempoMonth();
    }
  }

  void firmaTrue() {
    _isSigned = true;
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
                    width: 400,
                    height: 200,
                    child: Image(image: AssetImage('assets/images/logo.png')),
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  '${nomeUtente}',
                  style: TextStyle(fontSize: 25),
                ),
                SizedBox(height: 15),
                Text(
                  '${tipoTimbratura}',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                Text(
                  '${dataOdierna}',
                  style: TextStyle(fontSize: 25),
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
      floatingActionButton: widget.utente.cognome == "Mazzei" || widget.utente.cognome == "Chiriatti"
          ? Padding(
        padding: EdgeInsets.only(bottom: 24.0, right: 16.0),
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Scaricare il resoconto Excel delle presenze?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _generateExcel();
                      },
                      child: Text("Si"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("No"),
                    ),
                  ],
                );
              },
            );
          },
          backgroundColor: Colors.red,
          child: Icon(
            Icons.assignment_outlined,
            color: Colors.white,
          ),
        ),
      )
          : null,
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
      'GPS Uscita',
      'Località',
      'Sede'
    ]);

    // Map per tenere traccia delle somme delle differenze per utente e giorno
    Map<String, Map<DateTime, Duration>> userDayDifferences = {};

    // Calcola le differenze e aggiungi i dati al foglio Excel
    for (var timbratura in allTimbratureMonth) {
      // Verifica se l'utente e il giorno corrente sono già stati inseriti nella mappa
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
        MarcaTempoModel? matchingTimbratura = allTimbratureMonth.firstWhere((timbratura) =>
        timbratura.utente?.id == userId &&
            timbratura.data?.year == day.year &&
            timbratura.data?.month == day.month &&
            timbratura.data?.day == day.day);

        if (matchingTimbratura != null) {
          // Determina la località in base al GPS
          String localita = matchingTimbratura.gps != null && matchingTimbratura.gps!.contains('Via Europa') && matchingTimbratura.gps!.contains('Calimera 73021')
              ? 'Calimera'
              : 'NON IN SEDE';

          // Ottieni il nome completo dell'utente
          String userFullName = matchingTimbratura.utente?.nomeCompleto() ?? '';

          sheetObject.appendRow([
            userFullName,
            "${day.day}/${day.month}/${day.year}",
            '${difference.inHours}:${difference.inMinutes.remainder(60).toString().padLeft(2, '0')}',
            matchingTimbratura.gps ?? '', // GPS Entrata
            matchingTimbratura.gpsu ?? '', // GPS Uscita
            localita,
            '', // Sede
          ]);
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
        // Notifica all'utente che il file è stato salvato con successo
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
        }
        ;
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

  Future<void> getAllMarcatempoMonth() async {
    try {
      var apiUrl = Uri.parse('${ipaddress}/marcatempo');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<MarcaTempoModel> allMarcatempos = [];

        // Ottieni la data di inizio e fine del mese corrente
        DateTime now = DateTime.now();
        DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
        DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

        for (var item in jsonData) {
          MarcaTempoModel marcatempo = MarcaTempoModel.fromJson(item);
          // Controlla se la data del marcatempo è nel mese corrente
          if (marcatempo.data != null &&
              marcatempo.data!.isAfter(firstDayOfMonth) &&
              marcatempo.data!.isBefore(lastDayOfMonth)) {
            allMarcatempos.add(marcatempo);
          }
        }

        // Imposta il valore di allTimbratureMonth a allMarcatempos utilizzando setState
        setState(() {
          allTimbratureMonth = allMarcatempos;
        });
      }
    } catch (e) {
      print('Errore durante il recupero dei marcatempo del mese corrente: $e');
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
