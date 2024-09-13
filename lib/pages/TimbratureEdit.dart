import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart' as ex;
import 'package:fema_crm/pages/TimbraturaPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../model/MarcaTempoModel.dart';
import '../model/UtenteModel.dart';
import 'package:flutter/foundation.dart';
import 'dart:collection';

import 'HomeFormAmministrazioneNewPage.dart';
import 'PDFOggiPage.dart';
import 'TimbratureSettimana.dart';


class TimbratureEdit extends StatefulWidget {
  final UtenteModel utente;
  const TimbratureEdit({Key? key, required this.utente}) : super(key: key);

  @override
  _TimbratureEditState createState() => _TimbratureEditState();
}

class _TimbratureEditState extends State<TimbratureEdit> {

  bool _isSigned = false;
  final _formKey = GlobalKey<FormState>();
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String dataOdierna = DateFormat('dd-MM-yyyy, HH:mm')
      .format(DateTime.now())
      .toString();
  //late String nomeUtente = "${widget.utente.nome} ${widget.utente.cognome}";
  String tipoTimbratura = "";
  late String _gps;
  late String _indirizzo;
  late String idMarcatempo;
  late List<MarcaTempoModel> timbratureOdierne = [];
  List<MarcaTempoModel> allTimbratureEdit = [];
  List<MarcaTempoModel> allTimbratureDU = [];
  final _marcatControllers = <TextEditingController>[];
  final _focusNodes = <FocusNode>[];
  final _isEdited = <bool>[];
  List<MarcaTempoModel> allMarcatemposDU = [];
  List<_RowData> _rowsNew = [];
  int? _editedRowIndex;
  List<UtenteModel> allUtenti = [];
  final FocusManager _focusManager = FocusManager();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _marcatController = TextEditingController();
  DateTime _selectedDate = DateTime.now().subtract(Duration(days: 1));
  String? _selectedUtente = '1';
  List<MarcaTempoModel> allTimbratureMonth = [];


  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 10; i++) {
      _marcatControllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
      _isEdited.add(false);
    }
   // _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
    //_marcatController.text = "";
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
    _marcatController.text = "";

    getAllMarcatempo().then((value) => groupAndSortTimbrature());
    getAllUtenti().whenComplete(() => addNewRow());
    //_getCurrentLocation();
    getAllUtentiSearch();
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
      //'GPS Uscita',
      //'Ora Uscita',
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
          var cellStyleBlu = ex.CellStyle(
            fontColorHex: "#F9A825",//"#1E90FF",//"#00AAFF",
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
              timbratura!.gps == null || timbratura!.gps == '' ? '' : timbratura.edit ? '*'+timbratura!.gps! : timbratura!.gps!,
              timbratura.edit ? '*'+DateFormat('HH:mm').format(timbratura.data!) : DateFormat('HH:mm').format(timbratura.data!),
              //'${timbratura.data!.hour.toString()}:${timbratura.data!.minute.toString()}',
              timbratura!.gpsu == null || timbratura!.gpsu == '' ? '' : timbratura.editu ? '*'+timbratura!.gpsu! : timbratura!.gpsu!,
              timbratura.datau != null ? timbratura.editu ? '*'+DateFormat('HH:mm').format(timbratura.datau!) : DateFormat('HH:mm').format(timbratura.datau!) : '',
              //timbratura.editu ? '*'+DateFormat('HH:mm').format(timbratura.datau!) : DateFormat('HH:mm').format(timbratura.datau!),
              //timbratura.datau != null ? '${timbratura.datau!.hour.toString()}:${timbratura.datau!.minute.toString()}' : '',
            ]);
          }
          // Aggiungi tutte le righe raggruppate alla tabella
          for (var row in groupedRows.values) {
            sheetObject.appendRow(row);
          }
          //evidenzio in rosso i gps non in sede
          bool redRow = false;
          bool bluRow = false;
          for (int rowIndex = 2; rowIndex <= sheetObject.maxRows; rowIndex++) {
            redRow = false;
            bluRow = false;// Resetta il flag ad ogni iterazione di riga
            for (var column in ['D', 'F', 'H', 'J', 'L', 'N']) {
              var cellValue = sheetObject.cell(ex.CellIndex.indexByString("$column$rowIndex")).value;
              print('Gvalue '+cellValue.toString());
              if (cellValue.toString() != 'null' && cellValue.toString() != '' && (!cellValue.toString().contains('73021') || !cellValue.toString().contains('Via Europa'))) {
                if (cellValue.toString() != 'null' && cellValue.toString() != '' && (!cellValue.toString().contains('Puglia') || !cellValue.toString().contains('Puglia'))) {
                  print('red rig $rowIndex, colonn $column $cellValue');
                  // sheetObject.cell(ex.CellIndex.indexByString("C$rowIndex")).cellStyle = cellStyleRed;
                  sheetObject.cell(ex.CellIndex.indexByString("$column$rowIndex")).cellStyle = cellStyleRed;
                  redRow = true; // Imposta il flag a true se almeno una delle celle Ã¨ rossa


                } else {
                  print(' bbluu rig $rowIndex, colonn $column $cellValue');
                  // sheetObject.cell(ex.CellIndex.indexByString("C$rowIndex")).cellStyle = cellStyleBlu;
                  sheetObject.cell(ex.CellIndex.indexByString("$column$rowIndex")).cellStyle = cellStyleBlu;
                  bluRow = true; // Imposta il flag a true se almeno una delle celle Ã¨ rossa
                }


              }
            }
            if (!redRow && !bluRow) {
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
          OpenFilex.open(file?.path);
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

  int getSettimana(DateTime date) {
    int dayOfYear = getDayOfYear(date);
    int week = (dayOfYear - date.weekday + 10) ~/ 7;
    return week;
  }

  int getDayOfYear(DateTime date) {
    return date.difference(DateTime(date.year, 1, 1)).inDays + 1;
  }

  Map<int, List<_RowData>> groupedRows = {};

  void groupAndSortTimbrature() {

    // Raggruppa per utente
    Map<String, List<MarcaTempoModel>> groupedTimbrature = {};

    allTimbratureEdit.forEach((timbratura) {
      String key = '${timbratura.utente!.id}-${DateFormat('yyyy-MM-dd').format(timbratura.data!)}';
      if (!groupedTimbrature.containsKey(key)) {
        groupedTimbrature[key] = [];
      }
      groupedTimbrature[key]!.add(timbratura);
    });
/*
    groupedTimbrature.forEach((utente, timbrature) {
      timbrature.sort((a, b) => b.data!.toIso8601String().compareTo(a.data!.toIso8601String()));
    });
    // Assegna il risultato a allTimbratureEdit
    allTimbratureEdit.clear();
    groupedTimbrature.forEach((utente, timbrature) {
      allTimbratureEdit.addAll(timbrature);
    });*/
    /*allTimbratureEdit.forEach((timbratura) {
      if (!groupedTimbrature.containsKey(timbratura.utente!.id!)) {
        groupedTimbrature[timbratura.utente!.id!] = [];
      }
      groupedTimbrature[timbratura.utente!.id!]!.add(timbratura);
    });*/
    //groupedTimbrature = groupBy(allTimbratureEdit, (timbratura) => timbratura.utente);
    print('vvbcs');
    // Ordina per data
    /*groupedTimbrature.forEach((utente, timbrature) {
      timbrature.sort((a, b) => b.data!.toIso8601String().compareTo(a.data!.toIso8601String()));
    });*/
    print('azaaza');
    // Assegna il risultato a allTimbratureEdit
    /*allTimbratureEdit.clear();
    groupedTimbrature.forEach((utente, timbrature) {
      allTimbratureEdit.addAll(timbrature);
    });*/
    //print(allTimbratureEdit.last.id.toString()+' brbas');

    _rowsNew.clear();//_rows = [];
    groupedTimbrature.forEach((key, timbrature) {
      //timbrature.sort((a, b) => b.data!.toIso8601String().compareTo(a.data!.toIso8601String()));
      /*timbrature.sort((a, b) {
        return b.data!.toIso8601String().compareTo(a.data!.toIso8601String());
      });*/
      if (timbrature.length > 0) {
        MarcaTempoModel firstTimbratura = timbrature[0];
        print('abc '+timbrature[0].id.toString());
        MarcaTempoModel? secondTimbratura = null;
        if (timbrature.length > 1) secondTimbratura = timbrature[1];

        _RowData rowData = _RowData(
          idmt: firstTimbratura.id,
          idmt2: secondTimbratura != null ? secondTimbratura.id : null,
          utente: firstTimbratura.utente,
          dataIngresso: DateFormat('dd/MM/yyyy').format(firstTimbratura.data!),
          oraIngresso: DateFormat('HH:mm').format(firstTimbratura.data!),
          indirizzoIngresso: firstTimbratura.gps!,
          //dataUscita: DateFormat('dd/MM/yyyy').format(secondTimbratura.data!),
          oraUscita: firstTimbratura.datau != null ? DateFormat('HH:mm').format(firstTimbratura.datau!) : '',
          indirizzoUscita: firstTimbratura.gpsu != null ? firstTimbratura.gpsu! : '',
          //dataIngresso2: DateFormat('dd/MM/yyyy').format(secondTimbratura.data!),

          oraIngresso2: secondTimbratura != null ? DateFormat('HH:mm').format(secondTimbratura.data!) : '',
          indirizzoIngresso2: secondTimbratura != null ? secondTimbratura.gps! : '',
          oraUscita2: secondTimbratura != null ? secondTimbratura.datau != null ? DateFormat('HH:mm').format(secondTimbratura.datau!) : '' : '',
          indirizzoUscita2: secondTimbratura != null ? secondTimbratura.gpsu != null ? secondTimbratura.gpsu! : '' : '',
          utenteEdit: firstTimbratura.utenteEdit
        );
        _rowsNew.add(rowData);
      }
    });


    /*_rows = allTimbratureEdit.map((marcaTempo) {
      // Trova la riga esistente con lo stesso utente e data
      _RowData? existingRow;
      try {
        existingRow = _rows.firstWhere((row) => row.utente!.id == marcaTempo.utente!.id && row.dataIngresso == DateFormat('dd/MM/yyyy').format(marcaTempo.data!));
      } catch (e) {
        // Handle the case when the element is not found
      }

      if (existingRow != null) {
        // Aggiungi la timbratura all'elenco esistente
        existingRow.timbrature.add(marcaTempo);
      } else {
        // Crea una nuova riga
      tingRow = _RowData(
          idmt: marcaTempo.id,
          utente: marcaTempo.utente,
          dataIngresso: DateFormat('dd/MM/yyyy').format(marcaTempo.data!),
          oraIngresso: DateFormat('HH:mm').format(marcaTempo.data!),
          indirizzoIngresso: marcaTempo.gps!,
          dataUscita: marcaTempo.datau != null ? DateFormat('dd/MM/yyyy').format(marcaTempo.datau!) : '',
          oraUscita: marcaTempo.datau != null ? DateFormat('HH:mm').format(marcaTempo.datau!) : '',
          indirizzoUscita: marcaTempo.gpsu != null ? marcaTempo.gpsu! : '',
          timbrature: [marcaTempo],
        );
        _rows.add(existingRow);
      }

      return existingRow;
    }).toList();*/

    /*_rows = allTimbratureEdit.map((marcaTempo) {

      return _RowData(
        idmt: marcaTempo.id,
        utente: marcaTempo.utente!,
        dataIngresso: DateFormat('dd/MM/yyyy').format(marcaTempo.data!),
        oraIngresso: DateFormat('HH:mm').format(marcaTempo.data!),//marcaTempo.data!.hour.toString() + ':' + marcaTempo.data!.minute.toString(),
        indirizzoIngresso: marcaTempo.gps!,
        dataUscita: marcaTempo.datau != null ? DateFormat('dd/MM/yyyy').format(marcaTempo.datau!) : '',
        oraUscita: marcaTempo.datau != null ? DateFormat('HH:mm').format(marcaTempo.datau!) : '',
        indirizzoUscita: marcaTempo.gpsu != null ? marcaTempo.gpsu! : '',
        oraIngresso2: ,
        indirizzoIngresso2: ,
        oraUscita2: ,
        indirizzoUscita2: ,
        utenteEdit: marcaTempo.utenteEdit != null ? marcaTempo.utenteEdit! : null,
      );

    }).toList();*/

    groupedRows.clear();
    for (var row in _rowsNew) {
      int settimana = getSettimana(DateFormat('dd/MM/yyyy').parse(row.dataIngresso!));
      if (!groupedRows.containsKey(settimana)) {
        groupedRows[settimana] = [];
      }
      groupedRows[settimana]?.add(row);
    }

    /*_rows.clear();
    groupedRows.forEach((settimana, rows) {

      rows.sort((a, b) {
        return DateFormat('dd/MM/yyyy').parse(b.dataIngresso!).compareTo(DateFormat('dd/MM/yyyy').parse(a.dataIngresso!));
      });
      _rows.addAll(rows);
    });*/
    /*groupedRows.forEach((settimana, rows) {
      rows.sort((a, b) {
        return b.dataIngresso!.compareTo(a.dataIngresso!);
      });
      _rows.addAll(rows);
    });*/
    /*_rows.clear();
    groupedRows.forEach((settimana, rows) {
      _rows.addAll(rows);
    });*/
    /*groupedRows.forEach((settimana, rows) {

      rows.sort((a, b) {
        return DateFormat('dd/MM/yyyy').parse(b.dataIngresso!).compareTo(DateFormat('dd/MM/yyyy').parse(a.dataIngresso!));
      });
    });

    _rows.clear();
    groupedRows.forEach((settimana, rows) {
      _rows.addAll(rows);
    });*/

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

  Future<void> getAllMarcatempo() async {
    try {
      var apiUrl = Uri.parse('${ipaddress}/marcatempo/ordered');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<MarcaTempoModel> allMarcatempos = [];

        DateTime now = DateTime.now();
        DateTime? firstDayOfMonth = null;
        DateTime? lastDayOfMonth = null;

        //if(current == 1) {
          // Ottieni la data di inizio e fine del mese corrente
          firstDayOfMonth = DateTime(now.year, now.month - 1, 1);
          lastDayOfMonth = DateTime(now.year, now.month + 1, 1);

        DateTime threeDaysAgo = DateTime(now.year, now.month, now.day - 7);
        DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
        /*} else if (current ==2){
          // Ottieni la data di inizio e fine del mese precedente
          firstDayOfMonth = DateTime(now.year, now.month - 1, 1);
          lastDayOfMonth = DateTime(now.year, now.month, 1);
        }*/
        for (var item in jsonData) {
          MarcaTempoModel marcatempo = MarcaTempoModel.fromJson(item);
          // Controlla se la data del marcatempo Ã¨ nel mese corrente
          if (marcatempo.data != null &&
              (marcatempo.data!.isAfter(firstDayOfMonth!) || marcatempo.data == firstDayOfMonth) &&
              (marcatempo.data!.isBefore(tomorrow!) || marcatempo.data == tomorrow)) {
            allMarcatempos.add(marcatempo);
          }
        }
        setState(() {
          allTimbratureEdit = allMarcatempos;
          //groupAndSortTimbrature();
          print('timbr '+allMarcatempos.first.id.toString());
        });

      }
    } catch (e) {
      print('Errore durante il recupero dei marcatempo: $e');
    }

  }

  Future<void> edit(_RowData row) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      print(row.idmt!+' FGJ kj '+row.oraUscita.toString());
      if (true){//tipoTimbratura == "INGRESSO") {
        print(DateFormat('dd/MM/yyyy HH:mm').parse('${row.dataIngresso} ${row.oraIngresso}').toIso8601String()+' '+DateTime.now().toIso8601String());

        final response1 = await http.post(
          Uri.parse('${ipaddress}/marcatempo'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id' : row.idmt,
            'gps': row.indirizzoIngresso,
            'data': DateFormat('dd/MM/yyyy HH:mm').parse('${row.dataIngresso} ${row.oraIngresso}').toIso8601String(),//DateTime.now().toIso8601String(),
            'gpsu': row.indirizzoUscita,
            'datau': row.oraUscita != '' ? DateFormat('dd/MM/yyyy HH:mm').parse('${row.dataIngresso} ${row.oraUscita}').toIso8601String() : null,//DateTime.now().toIso8601String(),
            'utente': row.utente!,//widget.utente.toMap(),
            'viaggio': {
              'id': 2,
              'destinazione': 'Calimera',
              'data_arrivo': null,
              'data_partenza': null,
            },
            'edit': row.isEdit,
            'editu': row.isEditu,
            'utenteEdit': widget.utente!//row.utenteEdit != null ? row.utenteEdit!.toMap() : null,
          }),
        );

        var response2;
        var response3;
        if (row.idmt2 != null) {
          response2 = await http.post(
            Uri.parse('${ipaddress}/marcatempo'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id' : row.idmt2,
              'gps': row.indirizzoIngresso2,
              'data': DateFormat('dd/MM/yyyy HH:mm').parse('${row.dataIngresso} ${row.oraIngresso2}').toIso8601String(),//DateTime.now().toIso8601String(),
              'gpsu': row.indirizzoUscita2,
              'datau': row.oraUscita2 != '' ? DateFormat('dd/MM/yyyy HH:mm').parse('${row.dataIngresso} ${row.oraUscita2}').toIso8601String() : null,//DateTime.now().toIso8601String(),
              'utente': row.utente!,//widget.utente.toMap(),
              'viaggio': {
                'id': 2,
                'destinazione': 'Calimera',
                'data_arrivo': null,
                'data_partenza': null,
              },
              'edit': row.isEdit,
              'editu': row.isEditu,
              'utenteEdit': widget.utente!//row.utenteEdit != null ? row.utenteEdit!.toMap() : null,
            }),
          );
        } else if (row.oraIngresso2 != null && row.oraIngresso2 != '') {
          print('3');
          response3 = await http.post(
            Uri.parse('${ipaddress}/marcatempo'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id' : '',
              'gps': row.indirizzoIngresso2,
              'data': DateFormat('dd/MM/yyyy HH:mm').parse('${row.dataIngresso} ${row.oraIngresso2}').toIso8601String(),//DateTime.now().toIso8601String(),
              'gpsu': row.indirizzoUscita2,
              'datau': row.oraUscita2 != '' ? DateFormat('dd/MM/yyyy HH:mm').parse('${row.dataIngresso} ${row.oraUscita2}').toIso8601String() : null,//DateTime.now().toIso8601String(),
              'utente': row.utente!,//widget.utente.toMap(),
              'viaggio': {
                'id': 2,
                'destinazione': 'Calimera',
                'data_arrivo': null,
                'data_partenza': null,
              },
              'edit': row.isEdit,
              'editu': row.isEditu,
              'utenteEdit': widget.utente!//row.utenteEdit != null ? row.utenteEdit!.toMap() : null,
            }),
          );
        }

        //final responses = await Future.wait([response1, response2, response3]);
        //final responses = await Future.wait<http.Response>([response1, if (row.idmt2 != null) response2, if (row.oraIngresso2 != null) response3]);
        //final responses = await Future.wait<http.Response>([response1, if (row.idmt2 != null) response2, if (row.oraIngresso2 != null) response3]);

        final List<Future<http.Response>> responses = [
          if (response1 != null) Future.value(response1),
          if (row.idmt2 != null && response2 != null) Future.value(response2),
          if (row.oraIngresso2 != null && response3 != null) Future.value(response3),
        ];

        //final response = await responses;
        //if ((await Future.wait(responses)).every((response) => response.statusCode == 200)) {
          // Call setState here to update the UI


          for (final response in await Future.wait(responses)) {
            if (response.statusCode == 200) {
              // Aggiorna lo stato della pagina
              Future.delayed(Duration(milliseconds: 100), () {
              setState(() {
                getAllMarcatempo();
                // Aggiorna le variabili di stato qui
              });
              });
            }
          }
          /*Navigator.of(context).pop();

          // Sostituisci la pagina corrente con una nuova pagina
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TimbratureEdit(utente: widget.utente)),
          );*/
          //setState(() {});
          // ...
       // }
      }} catch (e) {
      print('Errore durante il salvataggio del marcatempo: $e');
      }

    }

  Future<void> newTimbratura(_RowData row) async {
    //if (_isSigned == true) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
        print(row.idmt!+' d fdfd'+row.dataIngresso.toString()+' m'+row.oraIngresso.toString()+' k'+row.oraUscita.toString());
        if (true){//tipoTimbratura == "INGRESSO") {
          print(DateFormat('dd/MM/yyyy HH:mm').parse('${row.dataIngresso} ${row.oraIngresso}').toIso8601String()+' '+DateTime.now().toIso8601String());
          var response2 = null;
          var response3 = null;
          final response = await http.post(
            Uri.parse('${ipaddress}/marcatempo'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id' : '',
              'gps': row.indirizzoIngresso,
              'data': DateFormat('dd/MM/yyyy HH:mm').parse('${row.dataIngresso} ${row.oraIngresso}').toIso8601String(),//DateTime.now().toIso8601String(),
              'gpsu': row.indirizzoUscita,
              'datau': row.oraUscita != null && row.oraUscita != '' ? DateFormat('dd/MM/yyyy HH:mm').parse('${row.dataIngresso} ${row.oraUscita}').toIso8601String() : null,//DateTime.now().toIso8601String(),
              'utente': row.utente!,//widget.utente.toMap(),
              'viaggio': {
                'id': 2,
                'destinazione': 'Calimera',
                'data_arrivo': null,
                'data_partenza': null,
              },
              'edit': row.isEdit,
              'editu': row.isEditu,
              'utenteEdit': widget.utente!//row.utenteEdit != null ? row.utenteEdit!.toMap() : null,
            }),
          );
          if (response.statusCode == 200) {
            // Call setState here to update the UI

            Navigator.of(context).pop();

            // Sostituisci la pagina corrente con una nuova pagina
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TimbratureEdit(utente: widget.utente)),
            );
            setState(() {});
            // ...
          }

          //Navigator.pop(context);

          /*ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Timbratura registrata con successo!'),
            ),
          );*/
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
    /*} else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inserisci una firma per validare la timbratura!'),
        ),
      );
    }*/
  }

  DataTable newTable = DataTable(
    columns: [
      DataColumn(label: Text('')),
    ],
    rows: const [],
  );

  Future<List<UtenteModel>?> getAllUtentiNV() async {
    try {
      final response = await http.get(Uri.parse('$ipaddress/api/utente'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<UtenteModel> utenti = [];
        for (var item in jsonData) {
          utenti.add(UtenteModel.fromJson(item));
        }
        print('lopjhg '+utenti.length.toString());
        return utenti;
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata API: $e');
      return null; // Ritorna null in caso di errore
    }
  }

  Future<List<UtenteModel>?> getAllUtentiSearch() async {
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

  Future<void> getAllUtenti() async {
    try {
      final response = await http.get(Uri.parse('$ipaddress/api/utente'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<UtenteModel> utenti = [];
        for (var item in jsonData) {
          allUtenti.add(UtenteModel.fromJson(item));
        }
        //return utenti;
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata API: $e');
      //return null; // Ritorna null in caso di errore
    }
  }

  List<DataTable> _tables = [];
  _RowData newRow = _RowData();
  final _indirizzoIngressoController = TextEditingController();
  final _indirizzoUscitaController = TextEditingController();

  void addNewRow() {
    setState(() {
      if (_rowsNew.any((row) => row.isNewRow)) {
        // Annulla la riga precedente se ne esiste una
        _rowsNew.removeWhere((row) => row.isNewRow);
      }
      print('vbbva');
      /*_rows.insert(0, _RowData(//_rows.add(_RowData(
        idmt: '',
        utente: widget.utente,
        dataIngresso: '',
        oraIngresso: '',
        indirizzoIngresso: '',
        dataUscita: '',
        oraUscita: '',
        indirizzoUscita: '',
        isNewRow: true,
        settimana: null
      ));*/
       newRow = _RowData(
        idmt: '',
        utente: null,//widget.utente,
        dataIngresso: '',
        oraIngresso: '',
        indirizzoIngresso: '',
        //dataUscita: '',
        oraUscita: '',
        indirizzoUscita: '',
        isNewRow: true,
      );

      _editedRowIndex = _rowsNew.indexOf(newRow);
      for (var otherRow in _rowsNew) {
        //if (otherRow != row) {
          otherRow.isModified = false; // impostare isModified a false per le altre righe
          otherRow.isEditu = false;

        //}
      }
      newTable = DataTable(
        headingRowHeight: 30,
        columnSpacing: 10,
        dataRowMinHeight:  30,
        //dataRowMaxHeight: 38,
        border: TableBorder.all(color: Colors.grey),
        columns: [
          DataColumn(label: Text('UTENTE')),
          DataColumn(label: Text('DATA')),
          DataColumn(label: Text('INGRESSO')),
          DataColumn(label: Text('INDIRIZZO INGRESSO')),
          DataColumn(label: Text('USCITA')),
          DataColumn(label: Text('INDIRIZZO USCITA')),
          //DataColumn(label: Text('MODIFICATA DA')),
          DataColumn(label: Text('')),
        ],
        rows: [DataRow(
            selected: _editedRowIndex == _rowsNew.indexOf(newRow)
                ? true : false,
            cells: [
          DataCell(Container(width: 220,
              alignment: Alignment.center,
              child: SizedBox(
                  width: 220, // Imposta una larghezza massima di 200 pixel
                  child:
                  FutureBuilder(
                    future: getAllUtentiNV(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      } else if (snapshot.hasData && snapshot.data != null) {
                        return DropdownButtonFormField<UtenteModel>(
                          value: newRow.utente, // set the value property to the utente property of the _RowData class
                          hint: Text(newRow.utente != null ? newRow.utente!.nome! + ' ' + newRow.utente!.cognome! : ''),
                          onChanged: (newValue) {
                            //print('Before setState: ${newRow.utente!.id}');
                            setState(() {
                              newRow.utente = newValue;
                            });
                            print('After setState: ${newRow.utente!.id}');
                          },
                          items: allUtenti.map((utente) {
                            return DropdownMenuItem(
                              child: Text(utente.nome! + ' ' + utente.cognome!),
                              value: utente, // set the value property of the DropdownMenuItem to the utente object
                            );
                          }).toList(),
                        );
                      } else {
                        return Text("Nessun dato disponibile");
                      }
                    },
                  )))),
                  /*DropdownButton<UtenteModel>(
                    value: newRow.utente,
                    onChanged: (UtenteModel? newValue) {
                      setState(() {
                        newRow.utente = newValue!;//allUtenti.firstWhere((utente) => utente.nome!+' '+utente.cognome! == newValue);
                      });
                    },
                    items: allUtenti.map((UtenteModel? utente) {
                      return DropdownMenuItem<UtenteModel>(
                        child: Text(utente!.nome! + ' ' + utente!.cognome!),
                        value: utente!,
                      );
                    }).toList(),
                  )))),*///Text(newRow.utente!.nome! + ' ' + newRow.utente!.cognome!)),
          DataCell(Container(width: 170,
              alignment: Alignment.center,
              child:
              TextFormField(style: TextStyle(fontSize: 14),
                readOnly: true,
                controller: newRow.dataIngressoController,
                decoration: InputDecoration(border: InputBorder.none),
                //initialValue: row.dataIngresso,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2022),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      newRow.dataIngresso = DateFormat('dd/MM/yyyy').format(pickedDate);
                      newRow.dataIngressoController.text = newRow.dataIngresso!;
                      _editedRowIndex = _rowsNew.indexOf(newRow);
                      newRow.isModified = true;
                      newRow.isEdit = true;
                      for (var otherRow in _rowsNew) {
                        if (otherRow != newRow) {
                          otherRow.isModified = false; // impostare isModified a false per le altre righe
                          otherRow.isEdit = false;
                        }
                      }
                    });
                  }

                },
              )


            //Text(row.dataIngresso!),
            /*TextFormField(
                decoration: InputDecoration(border: InputBorder.none),
                readOnly: true,
                initialValue: row.dataIngresso,

              ),*/
          )),//Text(newRow.dataIngresso!)),
          DataCell(Container(width: 47,
            alignment: Alignment.center,
            child:TextFormField(
              decoration: InputDecoration(border: InputBorder.none),
              controller: newRow.oraIngressoController,
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  initialEntryMode: TimePickerEntryMode.inputOnly,
                  context: context,
                  //initialTime: TimeOfDay.fromDateTime(DateTime.parse('2022-01-01 ${row.oraIngresso}')),
                  initialTime: newRow.oraIngresso != null && newRow.oraIngresso != '' ? TimeOfDay.fromDateTime(DateTime.parse('2022-01-01 ${newRow.oraIngresso}')) :
                  TimeOfDay.fromDateTime(DateTime.parse('${DateTime.now()}')),
                );
                if (pickedTime != null) {
                  setState(() {
                    newRow.oraIngresso = pickedTime.format(context);
                    newRow.oraIngressoController.text = newRow.oraIngresso ?? '';
                    _editedRowIndex = _rowsNew.indexOf(newRow);
                    newRow.isModified = true;
                    newRow.isEdit = true;
                    idMarcatempo = newRow.idmt!;
                    for (var otherRow in _rowsNew) {
                      if (otherRow != newRow) {
                        otherRow.isModified = false; // impostare isModified a false per le altre righe
                        otherRow.isEdit = false;
                      }
                    }
                  });
                }
              },
            ),
          )),//Text(newRow.oraIngresso!)),
          DataCell(Container(width: 210,
              alignment: Alignment.center,
              child:TextFormField(
                minLines: 2,
                maxLines: null,
                style: TextStyle(
                    height: 1, overflow: TextOverflow.visible, fontSize: 13, color: (!newRow.indirizzoIngresso!.contains('73021') || !newRow.indirizzoIngresso!.contains('Via Europa')) ? !newRow.indirizzoIngresso!.contains('Puglia') ? Colors.red : Colors.yellow[800] : Colors.black),
                controller: _indirizzoIngressoController,//TextEditingController(text: newRow.indirizzoIngresso),
                //key: Key(_rows.indexOf(row).toString()),
                //autofocus: false,
                //focusNode: _focusNodes[_rows.indexOf(row)],
                decoration: InputDecoration(border: InputBorder.none,contentPadding: EdgeInsets.only(top: 2.0)),
                //initialValue: newRow.indirizzoIngresso,
                onChanged: (value) {
                  setState(() {
                    newRow.indirizzoIngresso = value;
                    _editedRowIndex = _rowsNew.indexOf(newRow);
                    newRow.isModified = true;
                    newRow.isEdit = true;
                    idMarcatempo = newRow.idmt!;
                    for (var otherRow in _rowsNew) {
                      if (otherRow != newRow) {
                        otherRow.isModified = false; // impostare isModified a false per le altre righe
                        otherRow.isEdit = false;
                      }
                    }
                  });
                },
              ))),//Text(newRow.indirizzoIngresso!)),
          //DataCell(Text(newRow.dataUscita!)),
          DataCell(Container(width: 47,
            alignment: Alignment.center,
            child:TextFormField(
              decoration: InputDecoration(border: InputBorder.none),
              controller: newRow.oraUscitaController,
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  initialEntryMode: TimePickerEntryMode.inputOnly,
                  context: context,
                  initialTime: newRow.oraUscita != null && newRow.oraUscita != '' ? TimeOfDay.fromDateTime(DateTime.parse('2022-01-01 ${newRow.oraUscita}')) :
                  //TimeOfDay.fromDateTime(DateTime.parse('2022-01-01 ${row.oraIngresso}')),
                  TimeOfDay.fromDateTime(DateTime.parse('${DateTime.now()}')),
                );
                if (pickedTime != null) {
                  setState(() {
                    newRow.oraUscita = pickedTime.format(context);
                    newRow.oraUscitaController.text = newRow.oraUscita ?? '';
                    _editedRowIndex = _rowsNew.indexOf(newRow);
                    newRow.isModified = true;
                    newRow.isEditu = true;
                    idMarcatempo = newRow.idmt!;
                    for (var otherRow in _rowsNew) {
                      if (otherRow != newRow) {
                        otherRow.isModified = false; // impostare isModified a false per le altre righe
                        otherRow.isEditu = false;
                      }
                    }
                  });
                }
              },
            ),
          )),//Text(newRow.oraUscita!)),
          DataCell(Container(width: 210,
              alignment: Alignment.center,
              child:TextFormField(
                minLines: 2,
                maxLines: null,
                style: TextStyle(
                    height: 1, overflow: TextOverflow.visible, fontSize: 13, color: (!newRow.indirizzoUscita!.contains('73021') || !newRow.indirizzoUscita!.contains('Via Europa')) ? !newRow.indirizzoUscita!.contains('Puglia') ? Colors.red : Colors.yellow[800] : Colors.black),
                controller: _indirizzoUscitaController,
                //key: Key(_rows.indexOf(row).toString()),
                //autofocus: false,
                //focusNode: _focusNodes[_rows.indexOf(row)],
                decoration: InputDecoration(border: InputBorder.none,contentPadding: EdgeInsets.only(top: 2.0)),
                //initialValue: newRow.indirizzoUscita,
                onChanged: (value) {
                  setState(() {
                    newRow.indirizzoUscita = value;
                    _editedRowIndex = _rowsNew.indexOf(newRow);
                    newRow.isModified = true;
                    newRow.isEdit = true;
                    idMarcatempo = newRow.idmt!;
                    for (var otherRow in _rowsNew) {
                      if (otherRow != newRow) {
                        otherRow.isModified = false; // impostare isModified a false per le altre righe
                        otherRow.isEdit = false;
                      }
                    }
                  });
                },
              ))),//DataCell(Text(newRow.indirizzoUscita!)),
          DataCell(
              _editedRowIndex == _rowsNew.indexOf(newRow)
              ? Container(//width: 320,
              //alignment: Alignment.center,
              child:Row(children: [
                SizedBox(width: 5),
            ElevatedButton(
              onPressed: () {
                if (newRow.dataIngresso != null && newRow.dataIngresso!.isNotEmpty && newRow.dataIngresso != '') {
                  if (newRow.oraIngresso != null && newRow.oraIngresso!.isNotEmpty && newRow.oraIngresso != '') {
                    //print('ghghg '+_rowsNew.elementAt(_rowsNew.indexOf(newRow)));
                    newTimbratura(newRow).whenComplete(() {
                      setState(() {
                        _editedRowIndex = null; // Resetta la riga in modifica
                      });
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            TimbratureEdit(utente: widget.utente)),
                      );
                    });//_rowsNew.elementAt(_rowsNew.indexOf(newRow)));
                    // Salva le modifiche
                    // ...

                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('L\'ORA DI INGRESSO è obbligatoria'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('La DATA è obbligatoria'),
                    ),
                  );
                }
              },
              child: Text('SALVA'),
            ),
            SizedBox(width: 5),
            newRow.isNewRow
                ? ElevatedButton(
              onPressed: ()  {
                 reset(_rowsNew.indexOf(newRow)).whenComplete(() =>
                    setState(() {})
                );
                /*newRow.dataIngresso = null;
                newRow.oraIngresso = null;
                newRow.oraUscita = null;
                newRow.indirizzoIngresso = null;
                newRow.indirizzoUscita = null;*/
                //closeNewRow(_rowsNew.indexOf(newRow));
                // Salva le modifiche
                // ...
                setState(() {
                  _editedRowIndex = null; // Resetta la riga in modifica
                });
                /*Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => TimbratureEdit(utente: widget.utente)),
                    );*/
              },
              child: Text('ANNULLA'),
            ) : Container()
          ],))
              : Container(width: 170,child: Text(''),)),//Text('')),
        ])],
      );
      _tables.insert(0, newTable);
      print('ew43');
    });
  }

  Future<void> reset(int index) async {
    setState(() {
      newRow.utente = null;
      newRow.dataIngresso = null;
      newRow.dataIngressoController.text = '';
      newRow.oraIngresso = null;
      newRow.oraIngressoController.text = '';
      newRow.oraUscita = null;
      newRow.oraUscitaController.text = '';
      newRow.indirizzoIngresso = '';
      newRow.indirizzoUscita = '';
      _indirizzoIngressoController.text = '';
      _indirizzoUscitaController.text = '';
    });
     print('ppp '+newRow.indirizzoIngresso.toString());
  }

  void closeNewRow(int index) {
    setState(() {
      _rowsNew.removeAt(index);
      _editedRowIndex = null;
      for (var otherRow in _rowsNew) {
        //if (otherRow != row) {
        otherRow.isModified = false; // impostare isModified a false per le altre righe
        otherRow.isEditu = false;

        //}
      }
    });
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
                            'SELEZIONA DATA E UTENTE',
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
                            'UTENTE:',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(width: 10),
                          FutureBuilder(
                            future: getAllUtentiSearch(),
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
                SizedBox(height: 12),
                TextFormField(
                  maxLines: 5,
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
    List<int> settimane = groupedRows.keys.toList();
    settimane.sort((a, b) => b.compareTo(a));
    //List<Widget> settimane = [];
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: (){Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeFormAmministrazioneNewPage(userData: widget.utente)//TimbraturaPage(utente: widget.utente),
              ),
            );},
            color: Colors.black, // <-- SEE HERE
          ),
          title: Text(
            'LISTA TIMBRATURE',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.red,
          actions: [
            /*IconButton(
              icon: Icon(
                Icons.assignment_outlined, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TimbratureSettimana(utente: widget.utente)),
                );
                //setState(() {});//getAllMarcatempo();
              },
            ),*/
            //SizedBox(width: 23),
            IconButton(
                color: Colors.white,
                icon: Icon(Icons.assignment_outlined), onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TimbratureSettimana(utente: widget.utente)),
              );
            }),
            SizedBox(width: 23),

            IconButton(
                color: Colors.white,
                icon: Icon(Icons.download), onPressed: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("SCARICA IL RESOCONTO DELLE PRESENZE"),
                    actions: [
                      Center(
                        child:  Column(
                          children: [
                            TextButton(
                              onPressed: () {
                                getAllMarcatempoMonth(2).whenComplete(() => _generateExcel());
                                Navigator.of(context).pop();
                              },
                              child: Text("MESE PRECEDENTE"), //no
                            ),
                            SizedBox(width: 45,),
                            TextButton(
                              onPressed: () {
                                getAllMarcatempoMonth(1).whenComplete(() =>  _generateExcel());
                                Navigator.of(context).pop();
                              },
                              child: Text("MESE CORRENTE"), //si
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
                              child: Text("OGGI"), //si
                            ),
                            /*TextButton(
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
                              child: Text("Modifica"), //si
                            ),*/
                          ],
                        ),
                      )
                    ],
                  );
                },
              );
            }),
            SizedBox(width: 23,),
            IconButton(
                color: Colors.white,
                icon: Icon(Icons.search), onPressed: () async {
              _showDialog();
            }),
            SizedBox(width: 23),
            IconButton(
              icon: Icon(
                Icons.refresh, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TimbratureEdit(utente: widget.utente)),
                );
                //setState(() {});//getAllMarcatempo();
              },
            ),
          ],
        ),
        body: Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
    child: Padding(
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [/*Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [*/
                //SizedBox(height: 10),
                /*Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: addNewRow,
                      child: Text('NUOVA TIMBRATURA'),
                    ),
                ]),*/


                  Column(
                mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          alignment: Alignment.topLeft, // allinea a sinistra
                          child:newTable),
                        SizedBox(width: 540,)
                  ]),

                      /*Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [Container(

                      alignment: Alignment.topLeft,
                      child: Column(
                          children: [newTable])),*/
                        //_tables,
                      /*Flexible(child:
                      Container(
                      alignment: Alignment.centerLeft,
                          child:
                        DataTable(
                          headingRowHeight: 30,
                          columnSpacing: 10,
                          dataRowMinHeight: 30,
                          dataRowMaxHeight: 38,
                          border: TableBorder.all(color: Colors.grey),
                          columns: [
                            DataColumn(label: Text('UTENTE')),
                            DataColumn(label: Text('DATA')),
                            DataColumn(label: Text('INGRESSO')),
                            DataColumn(label: Text('INDIRIZZO INGRESSO')),
                            DataColumn(label: Text('USCITA')),
                            DataColumn(label: Text('INDIRIZZO USCITA')),
                            DataColumn(label: Text('MODIFICATA DA')),
                            DataColumn(label: Text('')),
                          ],
                          rows: [DataRow(
                            cells: List<DataCell>.generate(
                              8,
                                  (index) => DataCell(Container()),
                            ),
                          ),], // Non ci sono righe qui, solo l'header
                        ))),*/
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [Divider(thickness: 20),]),
                        //SizedBox(height: 12),
                        //for (int settimana in groupedRows.keys.toList())
                          for (int settimana in settimane)
            Flexible(child:
            Container(
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                DataTable(

              headingRowHeight: 30,
              columnSpacing: 10,
              dataRowMinHeight:  30,
              //dataRowMaxHeight: 38,
              border: TableBorder.all(color: Colors.grey),
      columns: [
        DataColumn(label: Text('UTENTE'),),
        DataColumn(label: Text(DateFormat('dd/MM/yyyy').format(DateFormat('yyyy-MM-dd').parse(Settimana.getSettimana(settimana, DateTime.now().year)['lunedì']!.toString()),)+' - '+DateFormat('dd/MM/yyyy').format(DateFormat('yyyy-MM-dd').parse(Settimana.getSettimana(settimana, DateTime.now().year)['domenica']!.toString()),))),
        DataColumn(label: Text('ING')),
        DataColumn(label: Text('INDIRIZZO INGRESSO')),
        //DataColumn(label: Text('Data Uscita')),
        DataColumn(label: Text('USC')),
        DataColumn(label: Text('INDIRIZZO USCITA')),
        DataColumn(label: Text('ING')),
        DataColumn(label: Text('INDIRIZZO INGRESSO')),
        DataColumn(label: Text('USC')),
        DataColumn(label: Text('INDIRIZZO USCITA')),
        DataColumn(label: Text('MODIFICATA DA')),
        DataColumn(label: Text('TOT. ORE')),
        DataColumn(label: Text('')),
      ],

      rows: groupedRows[settimana]!.map((row) {
            return DataRow(//selected: int.parse(row.idmt!) % 2 == 0 ? true : false,
          cells: [
            DataCell(
              Container(width: 171,
                  alignment: Alignment.center,
                  child: row.isNewRow ? SizedBox(
                      width: 170, // Imposta una larghezza massima di 200 pixel
                      child: DropdownButton(
                    value: row.utente!.nome!+' '+row.utente!.cognome! ?? '',
                    onChanged: (newValue) {
                      setState(() {
                        row.utente = allUtenti.firstWhere((utente) => utente.nome == newValue);
                      });
                    },
                    items: allUtenti.map((utente) {
                      return DropdownMenuItem(
                        child: Text(utente.nome! + ' ' + utente.cognome!),
                        value: utente.nome!+' '+utente.cognome!,
                      );
                    }).toList(),
                  )) : TextFormField(style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(border: InputBorder.none),
                //textAlignVertical: TextAlignVertical.center,
                textAlign: TextAlign.center, // add this line
                //style: TextStyle(verticalAlign: TextAlignVertical.center),
                readOnly: true,
                initialValue: row.utente!.nome!+' '+row.utente!.cognome!,
                /*onChanged: (value) {
                  setState(() {
                    row.oraIngresso = value;
                  });
                },*/
              )),
            ),
            DataCell(Container(width: 190,
              alignment: Alignment.center,
              child:
              row.isNewRow
                  ? TextFormField(style: TextStyle(fontSize: 14),
                readOnly: true,
                controller: row.dataIngressoController,
                decoration: InputDecoration(border: InputBorder.none),
                //initialValue: row.dataIngresso,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2022),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      row.dataIngresso = DateFormat('dd/MM/yyyy').format(pickedDate);
                      row.dataIngressoController.text = row.dataIngresso!;
                      _editedRowIndex = _rowsNew.indexOf(row);
                      row.isModified = true;
                      row.isEdit = true;
                      //newTable.rows.first.selected = false;
                      for (var otherRow in _rowsNew) {
                        if (otherRow != row) {
                          otherRow.isModified = false; // impostare isModified a false per le altre righe
                          otherRow.isEdit = false;
                        }
                      }
                    });
                  }

                },
              )
                  :
              TextFormField(
                decoration: InputDecoration(border: InputBorder.none),
                //textAlignVertical: TextAlignVertical.center,
                textAlign: TextAlign.center, // add this line
                //style: TextStyle(verticalAlign: TextAlignVertical.center),
                readOnly: true,
                initialValue: row.dataIngresso!,
                /*onChanged: (value) {
                  setState(() {
                    row.oraIngresso = value;
                  });
                },*/
              )
              //Text(row.dataIngresso!),
              /*TextFormField(
                decoration: InputDecoration(border: InputBorder.none),
                readOnly: true,
                initialValue: row.dataIngresso,

              ),*/
            )),
            DataCell(
              //showEditIcon: row.isModified,
                Container(width: 47,
                  alignment: Alignment.center,
                  child:TextFormField(
                decoration: InputDecoration(border: InputBorder.none),
                controller: row.oraIngressoController,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    initialEntryMode: TimePickerEntryMode.inputOnly,
                    context: context,
                    //initialTime: TimeOfDay.fromDateTime(DateTime.parse('2022-01-01 ${row.oraIngresso}')),
                    initialTime: row.oraIngresso != null && row.oraIngresso != '' ? TimeOfDay.fromDateTime(DateTime.parse('2022-01-01 ${row.oraIngresso}')) :
                    TimeOfDay.fromDateTime(DateTime.parse('${DateTime.now()}')),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      row.oraIngresso = pickedTime.format(context);
                      row.oraIngressoController.text = row.oraIngresso ?? '';
                      _editedRowIndex = _rowsNew.indexOf(row);
                      row.isModified = true;
                      row.isEdit = true;
                      idMarcatempo = row.idmt!;
                      for (var otherRow in _rowsNew) {
                        if (otherRow != row) {
                          otherRow.isModified = false; // impostare isModified a false per le altre righe
                          otherRow.isEdit = false;
                        }
                      }
                    });
                  }
                },
              ),
            )),
            DataCell(
              //showEditIcon: row.isModified,
        Container(width: 210,
        alignment: Alignment.center,
        child:TextFormField(
          minLines: 2,
          maxLines: null,
          style: TextStyle(
              height: 1, overflow: TextOverflow.visible, fontSize: 13, color: (!row.indirizzoIngresso!.contains('73021') || !row.indirizzoIngresso!.contains('Via Europa')) ? !row.indirizzoIngresso!.contains('Puglia') ? Colors.red : Colors.yellow[800] : Colors.black),
                //key: Key(_rows.indexOf(row).toString()),
                //autofocus: false,
                //focusNode: _focusNodes[_rows.indexOf(row)],
                decoration: InputDecoration(border: InputBorder.none,contentPadding: EdgeInsets.only(top: 2.0)),
                initialValue: row.indirizzoIngresso,
                onChanged: (value) {
                  setState(() {
                    row.indirizzoIngresso = value;
                    _editedRowIndex = _rowsNew.indexOf(row);
                    row.isModified = true;
                    row.isEdit = true;
                    idMarcatempo = row.idmt!;
                    for (var otherRow in _rowsNew) {
                      if (otherRow != row) {
                        otherRow.isModified = false; // impostare isModified a false per le altre righe
                        otherRow.isEdit = false;
                      }
                    }
                  });
                },
              )),
            ),
            /*DataCell(
              TextFormField(
                readOnly: true,
                initialValue: row.dataUscita,

              ),
            ),*/
            DataCell(
              //showEditIcon: row.isModified,
        Container(width: 47,
        alignment: Alignment.center,
        child:TextFormField(
                decoration: InputDecoration(border: InputBorder.none),
                controller: row.oraUscitaController,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    initialEntryMode: TimePickerEntryMode.inputOnly,
                    context: context,
                    initialTime: row.oraUscita != null && row.oraUscita != '' ? TimeOfDay.fromDateTime(DateTime.parse('2022-01-01 ${row.oraUscita}')) :
                    //TimeOfDay.fromDateTime(DateTime.parse('2022-01-01 ${row.oraIngresso}')),
                      TimeOfDay.fromDateTime(DateTime.parse('${DateTime.now()}')),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      row.oraUscita = pickedTime.format(context);
                      row.oraUscitaController.text = row.oraUscita ?? '';
                      _editedRowIndex = _rowsNew.indexOf(row);
                      row.isModified = true;
                      row.isEditu = true;
                      idMarcatempo = row.idmt!;
                      for (var otherRow in _rowsNew) {
                        if (otherRow != row) {
                          otherRow.isModified = false; // impostare isModified a false per le altre righe
                          otherRow.isEditu = false;
                        }
                      }
                    });
                  }
                },
              ),
            )),
            DataCell(
              //showEditIcon: row.isModified,
        Container(width: 210,
        alignment: Alignment.center,
        child:TextFormField(
          minLines: 2,
          maxLines: null,
          style: TextStyle(
              height: 1, overflow: TextOverflow.visible, fontSize: 13, color: (!row.indirizzoUscita!.contains('73021') || !row.indirizzoUscita!.contains('Via Europa')) ? !row.indirizzoUscita!.contains('Puglia') ? Colors.red : Colors.yellow[800] : Colors.black),
                decoration: InputDecoration(border: InputBorder.none,contentPadding: EdgeInsets.only(top: 2.0)),
                initialValue: row.indirizzoUscita,
                onChanged: (value) {
                  setState(() {
                    row.indirizzoUscita = value;
                    _editedRowIndex = _rowsNew.indexOf(row);
                    row.isModified = true;
                    row.isEditu = true;
                    idMarcatempo = row.idmt!;
                    for (var otherRow in _rowsNew) {
                      if (otherRow != row) {
                        otherRow.isModified = false; // impostare isModified a false per le altre righe
                        otherRow.isEditu = false;
                      }
                    }
                  });
                },
              )),
            ),
            DataCell(
                //showEditIcon: row.isModified,
                Container(width: 47,
                  alignment: Alignment.center,
                  child:TextFormField(
                    decoration: InputDecoration(border: InputBorder.none),
                    controller: row.oraIngresso2Controller,
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        initialEntryMode: TimePickerEntryMode.inputOnly,
                        context: context,
                        //initialTime: TimeOfDay.fromDateTime(DateTime.parse('2022-01-01 ${row.oraIngresso}')),
                        initialTime: row.oraIngresso2 != null && row.oraIngresso2 != '' ? TimeOfDay.fromDateTime(DateTime.parse('2022-01-01 ${row.oraIngresso2}')) :
                        TimeOfDay.fromDateTime(DateTime.parse('${DateTime.now()}')),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          row.oraIngresso2 = pickedTime.format(context);
                          row.oraIngresso2Controller.text = row.oraIngresso2 ?? '';
                          _editedRowIndex = _rowsNew.indexOf(row);
                          row.isModified = true;
                          row.isEdit = true;
                          idMarcatempo = row.idmt!;
                          for (var otherRow in _rowsNew) {
                            if (otherRow != row) {
                              otherRow.isModified = false; // impostare isModified a false per le altre righe
                              otherRow.isEdit = false;
                            }
                          }
                        });
                      }
                    },
                  ),
                )),
            DataCell(
              //showEditIcon: row.isModified,
              Container(width: 210,
                  alignment: Alignment.center,
                  child:TextFormField(
                    minLines: 2,
                    maxLines: null,
                    style: TextStyle(
                        height: 1, overflow: TextOverflow.visible, fontSize: 13, color: (!row.indirizzoIngresso2!.contains('73021') || !row.indirizzoIngresso2!.contains('Via Europa')) ? !row.indirizzoIngresso2!.contains('Puglia') ? Colors.red : Colors.yellow[800] : Colors.black),
                    //key: Key(_rows.indexOf(row).toString()),
                    //autofocus: false,
                    //focusNode: _focusNodes[_rows.indexOf(row)],
                    decoration: InputDecoration(border: InputBorder.none,contentPadding: EdgeInsets.only(top: 2.0)),
                    initialValue: row.indirizzoIngresso2,
                    onChanged: (value) {
                      setState(() {
                        row.indirizzoIngresso2 = value;
                        _editedRowIndex = _rowsNew.indexOf(row);
                        row.isModified = true;
                        row.isEdit = true;
                        idMarcatempo = row.idmt!;
                        for (var otherRow in _rowsNew) {
                          if (otherRow != row) {
                            otherRow.isModified = false; // impostare isModified a false per le altre righe
                            otherRow.isEdit = false;
                          }
                        }
                      });
                    },
                  )),
            ),
            /*DataCell(
              TextFormField(
                readOnly: true,
                initialValue: row.dataUscita,

              ),
            ),*/
            DataCell(
              //showEditIcon: row.isModified,
        Container(width: 47,
        alignment: Alignment.center,
        child:TextFormField(
                decoration: InputDecoration(border: InputBorder.none),
                controller: row.oraUscita2Controller,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    initialEntryMode: TimePickerEntryMode.inputOnly,
                    context: context,
                    initialTime: row.oraUscita2 != null && row.oraUscita2 != '' ? TimeOfDay.fromDateTime(DateTime.parse('2022-01-01 ${row.oraUscita2}')) :
                    //TimeOfDay.fromDateTime(DateTime.parse('2022-01-01 ${row.oraIngresso}')),
                    TimeOfDay.fromDateTime(DateTime.parse('${DateTime.now()}')),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      row.oraUscita2 = pickedTime.format(context);
                      row.oraUscita2Controller.text = row.oraUscita2 ?? '';
                      _editedRowIndex = _rowsNew.indexOf(row);
                      row.isModified = true;
                      row.isEditu = true;
                      idMarcatempo = row.idmt!;
                      for (var otherRow in _rowsNew) {
                        if (otherRow != row) {
                          otherRow.isModified = false; // impostare isModified a false per le altre righe
                          otherRow.isEditu = false;
                        }
                      }
                    });
                  }
                },
              ),
            )),
            DataCell(
              //showEditIcon: row.isModified,
              Container(width: 210,
                  alignment: Alignment.center,
                  child:TextFormField(
                    minLines: 2,
                    maxLines: null,
                    style: TextStyle(
                        height: 1, overflow: TextOverflow.visible, fontSize: 13, color: (!row.indirizzoUscita2!.contains('73021') || !row.indirizzoUscita2!.contains('Via Europa')) ? !row.indirizzoUscita2!.contains('Puglia') ? Colors.red : Colors.yellow[800] : Colors.black),
                    decoration: InputDecoration(border: InputBorder.none,contentPadding: EdgeInsets.only(top: 2.0)),
                    initialValue: row.indirizzoUscita2,
                    onChanged: (value) {
                      setState(() {
                        row.indirizzoUscita2 = value;
                        _editedRowIndex = _rowsNew.indexOf(row);
                        row.isModified = true;
                        row.isEditu = true;
                        idMarcatempo = row.idmt!;
                        for (var otherRow in _rowsNew) {
                          if (otherRow != row) {
                            otherRow.isModified = false; // impostare isModified a false per le altre righe
                            otherRow.isEditu = false;
                          }
                        }
                      });
                    },
                  )),
            ),
            DataCell(
              //showEditIcon: row.isModified,
        Container(width: 120,
        alignment: Alignment.center,
        child:TextFormField(
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(border: InputBorder.none),
                //textAlignVertical: TextAlignVertical.center,
                textAlign: TextAlign.center, // add this line
                //style: TextStyle(verticalAlign: TextAlignVertical.center),
                readOnly: true,
                initialValue: row.utenteEdit != null ? row.utenteEdit!.nome!+' '+row.utenteEdit!.cognome! : '',//widget.utente.nome!+' '+widget.utente.cognome!//
                /*onChanged: (value) {
                  setState(() {
                    row.oraIngresso = value;
                  });
                },*/
              ),
            )),
            DataCell(
              Container(
                width: 50,
                alignment: Alignment.center,
                child: Text(
                  '${row.isNewRow ? '' : row._totalHours.inHours}:${row._totalHours.inMinutes.remainder(60).toString().padLeft(2, '0')}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              ),
              //showEditIcon: row.isModified,
              /*TextFormField(
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(border: InputBorder.none),
                //textAlignVertical: TextAlignVertical.center,
                textAlign: TextAlign.center, // add this line
                //style: TextStyle(verticalAlign: TextAlignVertical.center),
                readOnly: true,
                initialValue: row.utenteEdit != null ? row.utenteEdit!.nome!+' '+row.utenteEdit!.cognome! : '',//widget.utente.nome!+' '+widget.utente.cognome!//
                /*onChanged: (value) {
                  setState(() {
                    row.oraIngresso = value;
                  });
                },*/
              ),*/
            ),
            DataCell(
              _editedRowIndex == _rowsNew.indexOf(row)
                  ? Row(children: [
                    //SizedBox(width: 3),
              ElevatedButton(
                onPressed: () {
                  if (row.dataIngresso != null && row.dataIngresso!.isNotEmpty && row.dataIngresso != '') {
                    if (row.oraIngresso != null && row.oraIngresso!.isNotEmpty && row.oraIngresso != '') {
                      edit(_rowsNew.elementAt(_rowsNew.indexOf(row))).whenComplete(() {
                        setState(() {
                          _editedRowIndex = null; // Resetta la riga in modifica
                        });
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              TimbratureEdit(utente: widget.utente)),
                        );
                      });
                      // Salva le modifiche
                      // ...

                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('L\'ORA DI INGRESSO è obbligatoria'),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('La DATA è obbligatoria'),
                      ),
                    );
                  }
                },
                child: Text('SALVA'),
              ),
                SizedBox(width: 3),
                row.isNewRow
                    ? ElevatedButton(
                  onPressed: () {
                    closeNewRow(_rowsNew.indexOf(row));
                    // Salva le modifiche
                    // ...
                    setState(() {
                      _editedRowIndex = null; // Resetta la riga in modifica
                    });
                    /*Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => TimbratureEdit(utente: widget.utente)),
                    );*/
                  },
                  child: Text('ANNULLA'),
                ) : Container()
              ],)
                  : Container(width: 95),
            ),
          ],
              selected: _editedRowIndex == _rowsNew.indexOf(row)
                  ? true : false,

        );},
      )
          .toList(),
    ),
                  SizedBox(height: 5,)
                  ])
            ))])
                  ]))))));
  }

}

class _RowData {
  String? idmt;
  String? idmt2;
  UtenteModel? utente;
  UtenteModel? utenteEdit;
  String? dataIngresso;
  String? oraIngresso;
  String? indirizzoIngresso;
  //String? dataUscita;
  String? oraUscita;
  String? indirizzoUscita;


  String? oraIngresso2;
  String? indirizzoIngresso2;

  String? oraUscita2;
  String? indirizzoUscita2;

  bool isModified = false;
  bool isEdit = false;
  bool isEditu = false;
  TextEditingController oraIngressoController = TextEditingController();
  TextEditingController oraUscitaController = TextEditingController();
  TextEditingController oraIngresso2Controller = TextEditingController();
  TextEditingController oraUscita2Controller = TextEditingController();
  bool isNewRow = false;
  TextEditingController dataIngressoController = TextEditingController();
  int? settimana;
  Duration _totalHours = Duration.zero;
  //List<MarcaTempoModel> timbrature;

  _RowData({
    this.idmt,
    this.idmt2,
    this.utente,
    this.utenteEdit,
    this.dataIngresso,
    this.oraIngresso,
    this.indirizzoIngresso,
    //this.dataUscita,
    this.oraUscita,
    this.indirizzoUscita,

    this.oraIngresso2,
    this.indirizzoIngresso2,

    this.oraUscita2,
    this.indirizzoUscita2,

    this.isNewRow = false,
    this.settimana,
    //required this.timbrature
  }) {
    oraIngressoController.text = oraIngresso ?? '';
    oraUscitaController.text = oraUscita ?? '';
    oraIngresso2Controller.text = oraIngresso2 ?? '';
    oraUscita2Controller.text = oraUscita2 ?? '';
    dataIngressoController.text = dataIngresso ?? '';
    calculateTotalHours();
  }

  void calculateTotalHours() {
    if (oraIngressoController.text.isNotEmpty && oraUscitaController.text.isNotEmpty && dataIngressoController.text.isNotEmpty) {
      DateTime ingresso = DateFormat('dd/MM/yyyy HH:mm').parse('${dataIngressoController.text} ${oraIngressoController.text}');
      DateTime uscita = DateFormat('dd/MM/yyyy HH:mm').parse('${dataIngressoController.text} ${oraUscitaController.text}');
      _totalHours += uscita.difference(ingresso);
    }
    if (oraIngresso2Controller.text.isNotEmpty && oraUscita2Controller.text.isNotEmpty && dataIngressoController.text.isNotEmpty) {
      DateTime ingresso = DateFormat('dd/MM/yyyy HH:mm').parse('${dataIngressoController.text} ${oraIngresso2Controller.text}');
      DateTime uscita = DateFormat('dd/MM/yyyy HH:mm').parse('${dataIngressoController.text} ${oraUscita2Controller.text}');
      _totalHours += uscita.difference(ingresso);
    }
  }

  void onDataIngressoChanged(String value) {
    dataIngressoController.text = value;
    calculateTotalHours();
  }

  void onOraIngressoChanged(String value) {
    oraIngressoController.text = value;
    calculateTotalHours();
  }

  void onOraUscitaChanged(String value) {
    oraUscitaController.text = value;
    calculateTotalHours();
  }

}

class Settimana {
  static DateTime getLunedi(int numeroSettimana, int anno) {
  DateTime primoGiornoAnno = DateTime(anno, 1, 1);
  while (primoGiornoAnno.weekday != 1) {
  primoGiornoAnno = primoGiornoAnno.add(Duration(days: 1));
  }
  return primoGiornoAnno.add(Duration(days: (numeroSettimana - 1) * 7));
  }

  static DateTime getDomenica(int numeroSettimana, int anno) {
    return getLunedi(numeroSettimana, anno).add(Duration(days: 6));
  }

  static Map<String, DateTime> getSettimana(int numeroSettimana, int anno) {
    DateTime lunedi = getLunedi(numeroSettimana, anno);
    DateTime domenica = getDomenica(numeroSettimana, anno);
    return {
    'lunedì': lunedi,
    'domenica': domenica,
    };
  }
}
/*class TimePickerWidget extends StatefulWidget {
  final String initialTime;
  final Function(String) onTimeChanged;

  TimePickerWidget({required this.initialTime, required this.onTimeChanged});

  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: widget.initialTime,
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          initialEntryMode: TimePickerEntryMode.inputOnly,
          context: context,
          initialTime: TimeOfDay.fromDateTime(DateTime.parse('2022-01-01 ${widget.initialTime}')),
        );
        if (pickedTime != null) {
          setState(() {
            widget.onTimeChanged(pickedTime.format(context));
          });
        }
      },
    );
  }
}*/