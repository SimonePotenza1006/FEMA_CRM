import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../model/MarcaTempoModel.dart';
import '../model/UtenteModel.dart';
import 'package:flutter/foundation.dart';
import 'dart:collection';


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
    getAllMarcatempo().then((value) => groupAndSortTimbrature());
    getAllUtenti();
    //_getCurrentLocation();
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
      if (!groupedTimbrature.containsKey(timbratura.utente!.id!)) {
        groupedTimbrature[timbratura.utente!.id!] = [];
      }
      groupedTimbrature[timbratura.utente!.id!]!.add(timbratura);
    });
    //groupedTimbrature = groupBy(allTimbratureEdit, (timbratura) => timbratura.utente);
    print('vvbcs');
    // Ordina per data
    groupedTimbrature.forEach((utente, timbrature) {
      timbrature.sort((a, b) => b.data!.toIso8601String().compareTo(a.data!.toIso8601String()));
    });
    print('azaaza');
    // Assegna il risultato a allTimbratureEdit
    allTimbratureEdit.clear();
    groupedTimbrature.forEach((utente, timbrature) {
      allTimbratureEdit.addAll(timbrature);
    });
    print(allTimbratureEdit.last.id.toString()+' brbas');



    _rows = allTimbratureEdit.map((marcaTempo) {
      return _RowData(
        idmt: marcaTempo.id,
        utente: marcaTempo.utente!,
        dataIngresso: DateFormat('dd/MM/yyyy').format(marcaTempo.data!),
        oraIngresso: DateFormat('HH:mm').format(marcaTempo.data!),//marcaTempo.data!.hour.toString() + ':' + marcaTempo.data!.minute.toString(),
        indirizzoIngresso: marcaTempo.gps!,
        dataUscita: marcaTempo.datau != null ? DateFormat('dd/MM/yyyy').format(marcaTempo.datau!) : '',
        oraUscita: marcaTempo.datau != null ? DateFormat('HH:mm').format(marcaTempo.datau!) : '',
        indirizzoUscita: marcaTempo.gpsu != null ? marcaTempo.gpsu! : '',
        utenteEdit: marcaTempo.utenteEdit != null ? marcaTempo.utenteEdit! : null,
      );
    }).toList();


    for (var row in _rows) {
      int settimana = getSettimana(DateFormat('dd/MM/yyyy').parse(row.dataIngresso!));
      if (!groupedRows.containsKey(settimana)) {
        groupedRows[settimana] = [];
      }
      groupedRows[settimana]?.add(row);
    }
    _rows.clear();
    groupedRows.forEach((settimana, rows) {
      _rows.addAll(rows);
    });
  }

  Future<void> getAllMarcatempo() async {
    try {
      var apiUrl = Uri.parse('${ipaddress}/marcatempo');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<MarcaTempoModel> allMarcatempos = [];

        DateTime now = DateTime.now();
        DateTime? firstDayOfMonth = null;
        DateTime? lastDayOfMonth = null;

        //if(current == 1) {
          // Ottieni la data di inizio e fine del mese corrente
          firstDayOfMonth = DateTime(now.year, now.month, 1);
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
    //if (_isSigned == true) {
      try {
        print(row.idmt!+' d fdfd');
        if (true){//tipoTimbratura == "INGRESSO") {
          print(DateFormat('dd/MM/yyyy HH:mm').parse('${row.dataIngresso} ${row.oraIngresso}').toIso8601String()+' '+DateTime.now().toIso8601String());
          final response = await http.post(
            Uri.parse('${ipaddress}/marcatempo'),
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
          );
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
        dataUscita: '',
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
          DataCell(Text(newRow.dataUscita!)),
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

  @override
  Widget build(BuildContext context) {

    List<Widget> settimane = [];
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'LISTA TIMBRATURE',
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TimbratureEdit(utente: widget.utente)),
                );
                //setState(() {});//getAllMarcatempo();
              },
            ),
          ],
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
            child:Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: addNewRow,
                      child: Text('NUOVA TIMBRATURA'),
                    ),
                ]),
                  SizedBox(height: 10),
                  Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                  for (int settimana in groupedRows.keys)
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
        DataColumn(label: Text('INGRESSO')),
        DataColumn(label: Text('INDIRIZZO INGRESSO')),
        //DataColumn(label: Text('Data Uscita')),
        DataColumn(label: Text('USCITA')),
        DataColumn(label: Text('INDIRIZZO USCITA')),
        DataColumn(label: Text('MODIFICATA DA')),
        DataColumn(label: Text('')),
      ],

      rows: groupedRows[settimana]!.map((row) {
            return DataRow(
          cells: [
            DataCell(
              Container(width: 200,
                  alignment: Alignment.center,
                  child: row.isNewRow ? SizedBox(
                      width: 178, // Imposta una larghezza massima di 200 pixel
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
                  )) : TextFormField(
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
            DataCell(Container(width: 90,
              alignment: Alignment.center,
              child:
              row.isNewRow
                  ? TextFormField(
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
              showEditIcon: row.isModified,
                Container(width: 50,
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
              showEditIcon: row.isModified,
        Container(width: 300,
        alignment: Alignment.center,
        child:TextFormField(
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
              showEditIcon: row.isModified,
              TextFormField(
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
            ),
            DataCell(
              showEditIcon: row.isModified,
        Container(width: 300,
        alignment: Alignment.center,
        child:TextFormField(
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
              showEditIcon: row.isModified,
              TextFormField(
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
            ),
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
                            TimbratureEdit(utente: widget.utente)),
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
            ))])
                  ])]))));
  }

}

class _RowData {
  String? idmt;
  UtenteModel? utente;
  UtenteModel? utenteEdit;
  String? dataIngresso;
  String? oraIngresso;
  String? indirizzoIngresso;
  String? dataUscita;
  String? oraUscita;
  String? indirizzoUscita;
  bool isModified = false;
  bool isEdit = false;
  bool isEditu = false;
  TextEditingController oraIngressoController = TextEditingController();
  TextEditingController oraUscitaController = TextEditingController();
  bool isNewRow = false;
  TextEditingController dataIngressoController = TextEditingController();
  int? settimana;



  _RowData({
    this.idmt,
    this.utente,
    this.utenteEdit,
    this.dataIngresso,
    this.oraIngresso,
    this.indirizzoIngresso,
    this.dataUscita,
    this.oraUscita,
    this.indirizzoUscita,
    this.isNewRow = false,
    this.settimana
  }) {
    oraIngressoController.text = oraIngresso ?? '';
    oraUscitaController.text = oraUscita ?? '';
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