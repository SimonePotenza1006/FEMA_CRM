import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../model/MarcaTempoModel.dart';
import '../model/UtenteModel.dart';
import 'package:flutter/foundation.dart';
import 'dart:collection';

import 'PDFSettPage.dart';
import 'TimbraturaPage.dart';
import 'TimbratureEdit.dart';


class TimbratureSettimana extends StatefulWidget {
  final UtenteModel utente;
  const TimbratureSettimana({Key? key, required this.utente}) : super(key: key);

  @override
  _TimbratureSettimanaState createState() => _TimbratureSettimanaState();
}

class _TimbratureSettimanaState extends State<TimbratureSettimana> {

  bool _isSigned = false;
  final _formKey = GlobalKey<FormState>();
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
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
  late List<_RowData> _rows = [];
  int? _editedRowIndex;
  List<UtenteModel> allUtenti = [];
  final FocusManager _focusManager = FocusManager();


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
    getAllMarcatempo().then((value) {
      calcolaOreLavoro(allTimbratureEdit);
      calcolaOreLavoroMese(allTimbratureEdit);
      groupAndSortTimbrature();
    } );
    getAllUtenti();
    //_getCurrentLocation();
  }

  List<Widget> tabelleM = [];

  void calcolaOreLavoroMese(List<MarcaTempoModel> listaMarcaTempo) {
    List<String> nomiMesi = [
      'GENNAIO',
      'FEBBRAIO',
      'MARZO',
      'APRILE',
      'MAGGIO',
      'GIUGNO',
      'LUGLIO',
      'AGOSTO',
      'SETTEMBRE',
      'OTTOBRE',
      'NOVEMBRE',
      'DICEMBRE'
    ];
    // Creo una mappa per memorizzare le ore di lavoro per utente e mese
    Map<String, Map<String, double>> oreLavoroMese = {};

    // Itero sulla lista di marca tempo
    listaMarcaTempo.forEach((marcaTempo) {
      // Controllo se l'utente è presente nella mappa
      if (!oreLavoroMese.containsKey(marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!)) {
        oreLavoroMese[marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!] = {};
      }

      // Calcolo il mese dell'anno
      int mese = marcaTempo.data!.month;
      String nomeMese = nomiMesi[marcaTempo.data!.month - 1]+' '+marcaTempo.data!.year.toString();

      // Controllo se il mese è presente nella mappa dell'utente
      if (!oreLavoroMese[marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!]!.containsKey(nomeMese)) {
        oreLavoroMese[marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!]![nomeMese] = 0;
      }

      // Calcolo le ore e minuti di lavoro
      int minuti = marcaTempo.datau != null
          ? marcaTempo.datau!.difference(marcaTempo.data!).inMinutes
          : 0;

      double ore = minuti / 60.0;

      // Aggiungo le ore di lavoro alla mappa
      oreLavoroMese[marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!]![nomeMese] = oreLavoroMese[marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!]![nomeMese]! + ore;
    });

    // Creo una mappa per memorizzare le tabelle per ogni mese
    Map<String, List<DataRow>> tabelleMese = {};

    // Itero sulla mappa di ore di lavoro
    oreLavoroMese.forEach((utente, mesi) {
      mesi.forEach((mese, ore) {
        int oreInt = ore.toInt();
        int minuti = ((ore - oreInt) * 60).toInt();

        // Controllo se il mese è presente nella mappa delle tabelle
        if (!tabelleMese.containsKey(mese)) {
          tabelleMese[mese] = [];
        }

        // Aggiungo la riga alla tabella del mese corrente
        tabelleMese[mese]!.add(
          DataRow(
            cells: [
              DataCell(
                  Container(//width: 140,
            alignment: Alignment.center,
            child:
                Text(utente),)
              ),
              DataCell(
              Container(width: 120,
              alignment: Alignment.center,
        child:
                  Text('$oreInt ore $minuti minuti'))
              ),
            ],
          ),
        );
      });
    });


    // Itero sulla mappa delle tabelle
    tabelleMese.forEach((mese, righe) {
      // Creo la tabella del mese corrente
      DataTable tabellaMese = DataTable(
        border: TableBorder.all(color: Colors.grey),
        columns: [
          DataColumn(label: Text('UTENTE'), ),
          DataColumn(label: Text('ORE')),
        ],
        rows: righe,
      );

      // Aggiungo la tabella alla lista di tabelle
      tabelleM.add(
        Column(
          children: [
            //SizedBox(height: 15,),
            Text('\n$mese'),
            tabellaMese,
          ],
        ),
      );
    });

    // Ordino la lista di tabelle in ordine decrescente di mese
    tabelleM.sort((a, b) {
      Column columnA = a as Column;
      Column columnB = b as Column;

      //int meseA = int.parse((columnA.children.first as Text).data!.split(' ')[1]);
      Text textWidget = columnA.children.first as Text;
      List<String> parts = textWidget.data!.split(' ');
      int meseA;
      if (parts.length > 1) {
        meseA = int.parse(parts[1]);
      } else {
        // Handle the case where there's no space in the text
        meseA = 0; // or some other default value
      }

      Text textWidget2 = columnB.children.first as Text;
      List<String> parts2 = textWidget2.data!.split(' ');
      int meseB;
      if (parts2.length > 1) {
        meseB = int.parse(parts2[1]);
      } else {
        // Handle the case where there's no space in the text
        meseB = 0; // or some other default value
      }

      //int meseB = int.parse((columnB.children.first as Text).data!.split(' ')[1]);
      return meseB.compareTo(meseA);
    });

    // Mostra le tabelle
    // ...
  }

  static List<DataColumn> _columns = [
    DataColumn(label: Text('UTENTE')),
    DataColumn(label: Text('SETTIMANA')),
    DataColumn(label: Text('ORE')),
  ];
  DataTable tabella = DataTable(
    columns: _columns,
    rows: [], // You can leave the rows empty for now
  );

  List<Widget> tabelle = [];

  void calcolaOreLavoro(List<MarcaTempoModel> listaMarcaTempo) {
    // Creo una mappa per memorizzare le ore di lavoro per utente e settimana
    Map<String, Map<int, double>> oreLavoro = {};

    // Itero sulla lista di marca tempo
    listaMarcaTempo.forEach((marcaTempo) {
      // Controllo se l'utente è presente nella mappa
      if (!oreLavoro.containsKey(marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!)) {
        oreLavoro[marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!] = {};
      }

      // Calcolo la settimana dell'anno
      int settimana = getSettimana(marcaTempo.data!);

      // Controllo se la settimana è presente nella mappa dell'utente
      if (!oreLavoro[marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!]!.containsKey(settimana)) {
        oreLavoro[marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!]![settimana] = 0;
      }

      // Calcolo le ore e minuti di lavoro
      int minuti = marcaTempo.datau != null
          ? marcaTempo.datau!.difference(marcaTempo.data!).inMinutes
          : 0;

      double ore = minuti / 60.0;

      // Aggiungo le ore di lavoro alla mappa
      oreLavoro[marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!]![settimana] = oreLavoro[marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!]![settimana]! + ore;
    });

    // Creo una mappa per memorizzare le tabelle per ogni settimana
    Map<int, List<DataRow>> tabelleSettimana = {};

    // Itero sulla mappa di ore di lavoro
    oreLavoro.forEach((utente, settimane) {
      settimane.forEach((settimana, ore) {
        int oreInt = ore.toInt();
        int minuti = ((ore - oreInt) * 60).toInt();

        // Controllo se la settimana è presente nella mappa delle tabelle
        if (!tabelleSettimana.containsKey(settimana)) {
          tabelleSettimana[settimana] = [];
        }

        // Aggiungo la riga alla tabella della settimana corrente
        tabelleSettimana[settimana]!.add(
          DataRow(
            cells: [
              DataCell(
                  Container(//width: 140,
                    alignment: Alignment.center,
                    child:
                    Text(utente),)
              ),
              DataCell(
              Container(width: 120,
              alignment: Alignment.center,
        child:
                  Text('$oreInt ore $minuti minuti'))
              ),
            ],
          ),
        );
      });
    });

    // Creo la lista di tabelle
    //List<DataTable> tabelle = [];

    // Itero sulla mappa delle tabelle
    tabelleSettimana.forEach((settimana, righe) {
      // Creo la tabella della settimana corrente
      DataTable tabellaSettimana = DataTable(
        border: TableBorder.all(color: Colors.grey),
        columns: [
          DataColumn(label: Text('UTENTE')),
          DataColumn(label: Text('ORE')),
        ],
        rows: righe,
      );

      // Aggiungo la tabella alla lista di tabelle
      tabelle.add(
        Column(
          children: [
            Text('\n'+DateFormat('dd/MM/yyyy').format(DateFormat('yyyy-MM-dd').parse(Settimana.getSettimana(settimana, DateTime.now().year)['lunedì']!.toString()),)+' - '+DateFormat('dd/MM/yyyy').format(DateFormat('yyyy-MM-dd').parse(Settimana.getSettimana(settimana, DateTime.now().year)['domenica']!.toString()),)),
            //Text('\nSettimana $settimana'),
            tabellaSettimana,
          ],
        ),
      );
    });

    // Ordino la lista di tabelle in ordine decrescente di settimana

      /*Column columnA = a as Column;
      Column columnB = b as Column;

      //int meseA = int.parse((columnA.children.first as Text).data!.split(' ')[1]);
      Text textWidget = columnA.children.first as Text;
      List<String> parts = textWidget.data!.split(' ');
      int settimanaA;
      if (parts.length > 1) {
        String valore = parts[1].trim(); // Rimuove gli spazi bianchi
        if (valore.isNotEmpty && RegExp(r'^\d+$').hasMatch(valore)) { // Controlla se il valore è un numero
          settimanaA = int.parse(valore);
        } else {
          // Handle the case where the value is not a number
          settimanaA = 0; // or some other default value
        }
      } else {
        // Handle the case where there's no space in the text
        settimanaA = 0; // or some other default value
      }

      Text textWidget2 = columnB.children.first as Text;
      List<String> parts2 = textWidget2.data!.split(' ');
      int settimanaB;
      if (parts2.length > 1) {
        String valore = parts2[1].trim(); // Rimuove gli spazi bianchi
        if (valore.isNotEmpty && RegExp(r'^\d+$').hasMatch(valore)) { // Controlla se il valore è un numero
          settimanaB = int.parse(valore);
        } else {
          // Handle the case where the value is not a number
          settimanaB = 0; // or some other default value
        }
      } else {
        // Handle the case where there's no space in the text
        settimanaB = 0; // or some other default value
      }*/
    tabelle.sort((a, b) {
      Column columnA = a as Column;
      Column columnB = b as Column;

      Text textWidget = columnA.children.first as Text;
      List<String> parts = textWidget.data!.split(' ');
      //print('ppaart '+parts[0].toString());
      int settimanaA;
      try {
        settimanaA = getSettimana(DateFormat('dd/MM/yyyy').parse(parts[0].trim()));//int.parse(parts[1]);
      } catch (e) {
        // Handle the case where the week number cannot be parsed
        settimanaA = 0; // or some other default value
      }
      //print('ssA '+settimanaA.toString());
      Text textWidget2 = columnB.children.first as Text;
      List<String> parts2 = textWidget2.data!.split(' ');
      int settimanaB;
      try {
        settimanaB = getSettimana(DateFormat('dd/MM/yyyy').parse(parts2[0].trim()));//int.parse(parts2[1]);
      } catch (e) {
        // Handle the case where the week number cannot be parsed
        settimanaB = 0; // or some other default value
      }

      return settimanaA.compareTo(settimanaB);
    });
    // Mostra le tabelle
    // ...
  }

  void calcolaOreLavoroOld(List<MarcaTempoModel> listaMarcaTempo) {
    // Creo una mappa per memorizzare le ore di lavoro per utente e settimana
    Map<String, Map<int, double>> oreLavoro = {};

    // Itero sulla lista di marca tempo
    listaMarcaTempo.forEach((marcaTempo) {
      // Controllo se l'utente è presente nella mappa
      if (!oreLavoro.containsKey(marcaTempo.utente?.id)) {
        oreLavoro[marcaTempo.utente!.id!] = {};
      }

      // Calcolo la settimana dell'anno
      int settimana = getSettimana(marcaTempo.data!);

      // Controllo se la settimana è presente nella mappa dell'utente
      if (!oreLavoro[marcaTempo.utente?.id]!.containsKey(settimana)) {
        oreLavoro[marcaTempo.utente?.id]![settimana] = 0;
      }

      // Calcolo le ore e minuti di lavoro
      int minuti = marcaTempo.datau != null
          ? marcaTempo.datau!.difference(marcaTempo.data!).inMinutes
          : 0;

      double ore = minuti / 60.0;

      // Aggiungo le ore di lavoro alla mappa
      oreLavoro[marcaTempo.utente?.id]![settimana] = oreLavoro[marcaTempo.utente?.id]![settimana]! + ore;
    });

    // Creo una lista di dati per la tabella
    List<DataRow> dati = [];

    // Itero sulla mappa di ore di lavoro
    oreLavoro.forEach((utente, settimane) {
      settimane.forEach((settimana, ore) {
        int oreInt = ore.toInt();
        int minuti = ((ore - oreInt) * 60).toInt();
        dati.add(DataRow(

         cells: [
          DataCell(Text(utente)),
          DataCell(Text(settimana.toString())),
          DataCell(Text('$oreInt ore $minuti minuti')),
        ]));
      });
    });

    // Ordino la lista di dati in ordine decrescente di settimana
    dati.sort((a, b) {
      int settimanaA = int.parse((a.cells[1].child as Text).data!);
      int settimanaB = int.parse((b.cells[1].child as Text).data!);
      return settimanaB.compareTo(settimanaA);
    });


    // Creo la tabella
    tabella = DataTable(
      columns: [
        DataColumn(label: Text('Utente')),
        DataColumn(label: Text('Settimana')),
        DataColumn(label: Text('Ore')),
      ],
      rows: dati,
    );

    // Mostra la tabella
    // ...
  }

  void calcolaOreLavoro2(List<MarcaTempoModel> listaMarcaTempo) {
    // Creo una mappa per memorizzare le ore di lavoro per utente e settimana
    Map<String, Map<int, double>> oreLavoro = {};

    // Itero sulla lista di marca tempo
    listaMarcaTempo.forEach((marcaTempo) {
      // Controllo se l'utente è presente nella mappa
      if (!oreLavoro.containsKey(marcaTempo.utente?.id)) {
        oreLavoro[marcaTempo.utente!.id!] = {};
      }

      // Calcolo la settimana dell'anno
      int settimana = getSettimana(marcaTempo.data!);

      // Controllo se la settimana è presente nella mappa dell'utente
      if (!oreLavoro[marcaTempo.utente?.id]!.containsKey(settimana)) {
        oreLavoro[marcaTempo.utente?.id]![settimana] = 0;
      }

      int minuti = marcaTempo.datau != null
          ? marcaTempo.datau!.difference(marcaTempo.data!).inMinutes
          : 0;

      double ore = minuti / 60.0;

      // Aggiungo le ore di lavoro alla mappa
      oreLavoro[marcaTempo.utente?.id]![settimana] = oreLavoro[marcaTempo.utente?.id]![settimana]! + ore;

    });

    // Stampo le ore di lavoro per utente e settimana
    oreLavoro.forEach((utente, settimane) {
      print('Utente: $utente');
      settimane.forEach((settimana, ore) {
        int oreInt = ore.toInt();
        int minuti = ((ore - oreInt) * 60).toInt();
        print('Settimana: $settimana, Ore: $oreInt, Minuti: $minuti');

      });
    });
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
  Map<String, Duration> _totalHoursPerUser = {};

  void groupAndSortTimbrature() {

    _rows.forEach((row) {
      if (!_totalHoursPerUser.containsKey(row.utente!.id!)) {
        _totalHoursPerUser[row.utente!.id!] = Duration.zero;
      }
    });

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
    //print('vvbcs');
    // Ordina per data
    /*groupedTimbrature.forEach((utente, timbrature) {
      timbrature.sort((a, b) => b.data!.toIso8601String().compareTo(a.data!.toIso8601String()));
    });*/
    //print('azaaza');
    // Assegna il risultato a allTimbratureEdit
    /*allTimbratureEdit.clear();
    groupedTimbrature.forEach((utente, timbrature) {
      allTimbratureEdit.addAll(timbrature);
    });*/
    //print(allTimbratureEdit.last.id.toString()+' brbas');

    _rows.clear();//_rows = [];
    groupedTimbrature.forEach((key, timbrature) {
      //timbrature.sort((a, b) => b.data!.toIso8601String().compareTo(a.data!.toIso8601String()));
      /*timbrature.sort((a, b) {
        return b.data!.toIso8601String().compareTo(a.data!.toIso8601String());
      });*/
      if (timbrature.length > 0) {
        MarcaTempoModel firstTimbratura = timbrature[0];
        //print('abc '+timbrature[0].id.toString());
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
        _rows.add(rowData);
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
        existingRow = _RowData(
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
    for (var row in _rows) {
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

  Future<void> getAllMarcatempo() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/marcatempo/ordered');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Problemi di rete. Riprova più tardi'),
        ),
      );
    }

  }

  Future<void> edit(_RowData row) async {
    //if (_isSigned == true) {
      try {
        print(row.idmt!+' d fdfd');
        if (true){//tipoTimbratura == "INGRESSO") {
          print(DateFormat('dd/MM/yyyy HH:mm').parse('${row.dataIngresso} ${row.oraIngresso}').toIso8601String()+' '+DateTime.now().toIso8601String());
          final response = await http.post(
            Uri.parse('$ipaddress/marcatempo'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id' : row.idmt,
              'gps': row.indirizzoIngresso,
              'data': DateFormat('dd/MM/yyyy HH:mm').parse('${row.dataIngresso} ${row.oraIngresso}').toIso8601String(),//DateTime.now().toIso8601String(),
              'gpsu': row.indirizzoUscita,
              'datau': DateFormat('dd/MM/yyyy HH:mm').parse('${row.dataIngresso} ${row.oraUscita}').toIso8601String(),//DateTime.now().toIso8601String(),
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
          ).then((value) async {
            if (row.idmt2 != null) { final response = await http.post(
              Uri.parse('$ipaddress/marcatempo'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'id' : row.idmt2,
                'gps': row.indirizzoIngresso2,
                'data': DateFormat('dd/MM/yyyy HH:mm').parse('${row.dataIngresso} ${row.oraIngresso2}').toIso8601String(),//DateTime.now().toIso8601String(),
                'gpsu': row.indirizzoUscita2,
                'datau': DateFormat('dd/MM/yyyy HH:mm').parse('${row.dataIngresso} ${row.oraUscita2}').toIso8601String(),//DateTime.now().toIso8601String(),
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
            );} else if (row.oraIngresso2 != null) {
              final response = await http.post(
                Uri.parse('$ipaddress/marcatempo'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'id' : '',
                  'gps': row.indirizzoIngresso2,
                  'data': DateFormat('dd/MM/yyyy HH:mm').parse('${row.dataIngresso} ${row.oraIngresso2}').toIso8601String(),//DateTime.now().toIso8601String(),
                  'gpsu': row.indirizzoUscita2,
                  'datau': DateFormat('dd/MM/yyyy HH:mm').parse('${row.dataIngresso} ${row.oraUscita2}').toIso8601String(),//DateTime.now().toIso8601String(),
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
          });
          if (response.statusCode == 200) {
            // Call setState here to update the UI
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
            Uri.parse('$ipaddress/marcatempo'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Problemi di rete. Riprova più tardi'),
          ),
        );
      }
    /*} else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inserisci una firma per validare la timbratura!'),
        ),
      );
    }*/
  }

  Future<void> getAllUtenti() async {
    try {
      final response = await http.get(Uri.parse('$ipaddress/api/utente'));
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Problemi di rete. Riprova più tardi'),
        ),
      );
      //return null; // Ritorna null in caso di errore
    }
  }

  List<DataTable> _tables = [];
  void addNewRow() {
    setState(() {
      if (_rows.any((row) => row.isNewRow)) {
        // Annulla la riga precedente se ne esiste una
        _rows.removeWhere((row) => row.isNewRow);
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
      _RowData newRow = _RowData(
        idmt: '',
        utente: widget.utente,
        dataIngresso: '',
        oraIngresso: '',
        indirizzoIngresso: '',
        //dataUscita: '',
        oraUscita: '',
        indirizzoUscita: '',
        isNewRow: true,
      );
      _editedRowIndex = null;
      for (var otherRow in _rows) {
        //if (otherRow != row) {
          otherRow.isModified = false; // impostare isModified a false per le altre righe
          otherRow.isEditu = false;

        //}
      }
      DataTable newTable = DataTable(
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
        rows: [DataRow(cells: [
          DataCell(Text(newRow.utente!.nome! + ' ' + newRow.utente!.cognome!)),
          DataCell(Text(newRow.dataIngresso!)),
          DataCell(Text(newRow.oraIngresso!)),
          DataCell(Text(newRow.indirizzoIngresso!)),
          //DataCell(Text(newRow.dataUscita!)),
          DataCell(Text(newRow.oraUscita!)),
          DataCell(Text(newRow.indirizzoUscita!)),
          DataCell(Text('')),
        ])],
      );
      _tables.insert(0, newTable);
      print('ew43');
    });
  }

  void closeNewRow(int index) {
    setState(() {
      _rows.removeAt(index);
      _editedRowIndex = null;
      for (var otherRow in _rows) {
        //if (otherRow != row) {
        otherRow.isModified = false; // impostare isModified a false per le altre righe
        otherRow.isEditu = false;

        //}
      }
    });
  }


  Duration getTotalHours(String userId) {
    _RowData? row;
    try {
      row = _rows.firstWhere((r) => r.utente!.id == userId);
    } on StateError {
      row = null;
    }
    return row != null ? row.getTotalHoursForUser() : Duration.zero;
  }

  @override
  Widget build(BuildContext context) {

    /*Duration getTotalHours(String userId) {
      _RowData? row;
      try {
        row = _rows.firstWhere((r) => r.utente!.id == userId);
      } on StateError {
        row = null;
      }
      return row != null ? row.getTotalHoursForUser() : Duration.zero;
    }*/
    List<Widget> settimane = [];
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: (){Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TimbratureEdit(utente: widget.utente),
              ),
            );},
            color: Colors.black, // <-- SEE HERE
          ),
          title: Text(
            'REPORT TIMBRATURE',
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
            IconButton(
                color: Colors.white,
                icon: Icon(Icons.download), onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PDFSettPage(timbrature: allTimbratureEdit),
                ),
              );
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
                  MaterialPageRoute(builder: (context) => TimbratureSettimana(utente: widget.utente)),
                );
                //setState(() {});//getAllMarcatempo();
              },
            ),
          ],
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,

            child:Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                SizedBox(height: 10),
                /*Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: addNewRow,
                      child: Text('NUOVA TIMBRATURA'),
                    ),
                ]),*/
                  SizedBox(height: 10),
                  Column(
                mainAxisAlignment: MainAxisAlignment.values[0],
                    mainAxisSize: MainAxisSize.min,
                children: [
Row(mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    //children: [Stack(
    //alignment: AlignmentDirectional.topStart,
    children: [Column(
        mainAxisAlignment: MainAxisAlignment.values[0],
        mainAxisSize: MainAxisSize.min,
        children:[ Text('SETTIMANALE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.values[0],
                      mainAxisSize: MainAxisSize.min,
                      children:
                      tabelle.reversed.toList()//.map((table) => table).toList(),
                      )]),
SizedBox(width: 100),
      Column(
          mainAxisAlignment: MainAxisAlignment.values[0],
          mainAxisSize: MainAxisSize.min,
          children:[
            Text('MENSILE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Column(
    mainAxisAlignment: MainAxisAlignment.values[0],
    mainAxisSize: MainAxisSize.min,
    children:
    tabelleM.reversed.toList()//.map((table) => table).toList(),
  )])
    ])
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
                  /*for (int settimana in groupedRows.keys.toList().reversed)
            Flexible(child:
            Container(
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                DataTable(

              headingRowHeight: 30,
              columnSpacing: 10,
              dataRowMinHeight:  30,
              dataRowMaxHeight: 38,
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
            return DataRow(
          cells: [
            DataCell(
              Container(width: 171,
                  alignment: Alignment.center,
                  child: row.isNewRow ? SizedBox(
                      width: 170, // Imposta una larghezza massima di 200 pixel
                      child: DropdownButton(
                    value: row.utente?.nome ?? '',
                    onChanged: (newValue) {
                      setState(() {
                        row.utente = allUtenti.firstWhere((utente) => utente.nome == newValue);
                      });
                    },
                    items: allUtenti.map((utente) {
                      return DropdownMenuItem(
                        child: Text(utente.nome! + ' ' + utente.cognome!),
                        value: utente.nome,
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
            DataCell(Container(width: 170,
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
                      _editedRowIndex = _rows.indexOf(row);
                      row.isModified = true;
                      row.isEdit = true;
                      for (var otherRow in _rows) {
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
                      _editedRowIndex = _rows.indexOf(row);
                      row.isModified = true;
                      row.isEdit = true;
                      idMarcatempo = row.idmt!;
                      for (var otherRow in _rows) {
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
        child:TextFormField(style: TextStyle(fontSize: 14, color: !row.indirizzoIngresso!.contains('73021')  ? Colors.red : Colors.black),
                //key: Key(_rows.indexOf(row).toString()),
                //autofocus: false,
                //focusNode: _focusNodes[_rows.indexOf(row)],
                decoration: InputDecoration(border: InputBorder.none),
                initialValue: row.indirizzoIngresso,
                onChanged: (value) {
                  setState(() {
                    row.indirizzoIngresso = value;
                    _editedRowIndex = _rows.indexOf(row);
                    row.isModified = true;
                    row.isEdit = true;
                    idMarcatempo = row.idmt!;
                    for (var otherRow in _rows) {
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
                      _editedRowIndex = _rows.indexOf(row);
                      row.isModified = true;
                      row.isEditu = true;
                      idMarcatempo = row.idmt!;
                      for (var otherRow in _rows) {
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
          style: TextStyle(fontSize: 14, color: !row.indirizzoUscita!.contains('73021')  ? Colors.red : Colors.black),
                decoration: InputDecoration(border: InputBorder.none),
                initialValue: row.indirizzoUscita,
                onChanged: (value) {
                  setState(() {
                    row.indirizzoUscita = value;
                    _editedRowIndex = _rows.indexOf(row);
                    row.isModified = true;
                    row.isEditu = true;
                    idMarcatempo = row.idmt!;
                    for (var otherRow in _rows) {
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
                          _editedRowIndex = _rows.indexOf(row);
                          row.isModified = true;
                          row.isEdit = true;
                          idMarcatempo = row.idmt!;
                          for (var otherRow in _rows) {
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
                    style: TextStyle(fontSize: 14, color: !row.indirizzoIngresso2!.contains('73021')  ? Colors.red : Colors.black),
                    //key: Key(_rows.indexOf(row).toString()),
                    //autofocus: false,
                    //focusNode: _focusNodes[_rows.indexOf(row)],
                    decoration: InputDecoration(border: InputBorder.none),
                    initialValue: row.indirizzoIngresso2,
                    onChanged: (value) {
                      setState(() {
                        row.indirizzoIngresso2 = value;
                        _editedRowIndex = _rows.indexOf(row);
                        row.isModified = true;
                        row.isEdit = true;
                        idMarcatempo = row.idmt!;
                        for (var otherRow in _rows) {
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
                      _editedRowIndex = _rows.indexOf(row);
                      row.isModified = true;
                      row.isEditu = true;
                      idMarcatempo = row.idmt!;
                      for (var otherRow in _rows) {
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
                    style: TextStyle(fontSize: 14, color: !row.indirizzoUscita2!.contains('73021')  ? Colors.red : Colors.black),
                    decoration: InputDecoration(border: InputBorder.none),
                    initialValue: row.indirizzoUscita2,
                    onChanged: (value) {
                      setState(() {
                        row.indirizzoUscita2 = value;
                        _editedRowIndex = _rows.indexOf(row);
                        row.isModified = true;
                        row.isEditu = true;
                        idMarcatempo = row.idmt!;
                        for (var otherRow in _rows) {
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
                  '${getTotalHours(row.utente!.id!).inHours}:${getTotalHours(row.utente!.id!).inMinutes.remainder(60).toString().padLeft(2, '0')}',

                  //'${row.isNewRow ? '' : row._totalHours.inHours}:${row._totalHours.inMinutes.remainder(60).toString().padLeft(2, '0')}',
                ),
              ),
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

            DataCell(
              _editedRowIndex == _rows.indexOf(row)
                  ? Row(children: [
              ElevatedButton(
                onPressed: () {
                  if (row.dataIngresso != null && row.dataIngresso!.isNotEmpty && row.dataIngresso != '') {
                    if (row.oraIngresso != null && row.oraIngresso!.isNotEmpty && row.oraIngresso != '') {
                      edit(_rows.elementAt(_rows.indexOf(row)));
                      // Salva le modifiche
                      // ...
                      setState(() {
                        _editedRowIndex = null; // Resetta la riga in modifica
                      });
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            TimbratureSettimana(utente: widget.utente)),
                      );
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
                child: Text('SALVA RIGA'),
              ),
                SizedBox(width: 3),
                row.isNewRow
                    ? ElevatedButton(
                  onPressed: () {
                    closeNewRow(_rows.indexOf(row));
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
                  : Container(),
            ),
          ],
              selected: _editedRowIndex == _rows.indexOf(row)
                  ? true : false,

        );},
      )
          .toList(),
    ),
                  SizedBox(height: 5,)
                  ])
            )
    )*/
    //]
    //)
],)
                  ])))));
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

extension RowDataExtension on _RowData {
  Duration getTotalHoursForUser() {
    Duration totalHours = Duration.zero;

    if (oraIngressoController.text.isNotEmpty && oraUscitaController.text.isNotEmpty && dataIngressoController.text.isNotEmpty) {
      DateTime ingresso = DateFormat('dd/MM/yyyy HH:mm').parse('${dataIngressoController.text} ${oraIngressoController.text}');
      DateTime uscita = DateFormat('dd/MM/yyyy HH:mm').parse('${dataIngressoController.text} ${oraUscitaController.text}');
      totalHours += uscita.difference(ingresso);
    }
    if (oraIngresso2Controller.text.isNotEmpty && oraUscita2Controller.text.isNotEmpty && dataIngressoController.text.isNotEmpty) {
      DateTime ingresso = DateFormat('dd/MM/yyyy HH:mm').parse('${dataIngressoController.text} ${oraIngresso2Controller.text}');
      DateTime uscita = DateFormat('dd/MM/yyyy HH:mm').parse('${dataIngressoController.text} ${oraUscita2Controller.text}');
      totalHours += uscita.difference(ingresso);
    }

    return totalHours;
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