import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';

import '../model/GruppoInterventiModel.dart';
import '../model/InterventoModel.dart';
import '../model/UtenteModel.dart';
import 'DettaglioGruppoPage.dart';

class TableGruppiPage extends StatefulWidget{
  final UtenteModel utente;

  TableGruppiPage({Key? key, required this.utente}) : super(key:key);

  @override
  _TableGruppiPageState createState() => _TableGruppiPageState();
}

class _TableGruppiPageState extends State<TableGruppiPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  late GruppoDataSource _dataSource;
  List<GruppoInterventiModel> allGruppi =[];
  Map<String, double> _columnWidths = {
    'gruppo' : 0,
    'cliente' : 400,
    'descrizione' : 450,
    'importo' : 150,
    'inserimento_importo' : 150,
    'importo_singoli_interventi' : 150,
  };

  @override
  void initState(){
    super.initState();
    getAllGruppi();
    _dataSource = GruppoDataSource(context, widget.utente, allGruppi);
  }

  Future<void> getAllGruppi() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/gruppi');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<GruppoInterventiModel> gruppi =[];
        for(var item in jsonData){
          gruppi.add(GruppoInterventiModel.fromJson(item));
        }
        setState(() {
          allGruppi = gruppi;
          _dataSource = GruppoDataSource(context, widget.utente,allGruppi);
        });
      }
    } catch(e){
      print('Errore: $e');
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "GRUPPI DI INTERVENTO",
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
              getAllGruppi();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(height: 10),
            Expanded(
                child: SfDataGrid(
                  allowTriStateSorting: true,
                  allowMultiColumnSorting: true,
                  allowSorting: true,
                  source: _dataSource,
                  columnWidthMode: ColumnWidthMode.auto,
                  allowColumnsResizing: true,
                  isScrollbarAlwaysShown: true,
                  rowHeight: 40,
                  gridLinesVisibility: GridLinesVisibility.both,
                  headerGridLinesVisibility: GridLinesVisibility.both,
                  columns: [
                    GridColumn(
                      columnName: 'gruppo',
                      label: Container(
                        padding: EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          'GRUPPO',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['gruppo']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'cliente',
                      label: Container(
                        padding: EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          'CLIENTE',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['cliente']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'descrizione',
                      label: Container(
                        padding: EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          'DESCRIZIONE',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['descrizione']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'importo',
                      label: Container(
                        padding: EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          'IMPORTO',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['importo']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'inserimento_importo',
                      label : Container(
                          padding: EdgeInsets.all(8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border(
                                  right : BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  )
                              )
                          ),
                          child: Text(
                            'Inserimento Importo'.toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          )
                      ),
                      width: _columnWidths['inserimento_importo']?? double.nan,
                      minimumWidth: 150,
                    ),
                    GridColumn(
                      columnName: 'importo_singoli_interventi',
                      label: Container(
                        padding: EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          'IMPORTI INTERVENTI',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['importo_singoli_interventi']?? double.nan,
                      minimumWidth: 0,
                    ),
                  ],
                  onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                    setState(() {
                      _columnWidths[details.column.columnName] = details.width;
                    });
                    return true;
                  },
                )
            ),
          ],
        ),
      ),
    );
  }
}

class GruppoDataSource extends DataGridSource{
  UtenteModel utente;
  List<GruppoInterventiModel> _gruppi =[];
  BuildContext context;
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  TextEditingController importoController = TextEditingController();

  GruppoDataSource(this.context, this.utente,List<GruppoInterventiModel> gruppi){
    _gruppi = gruppi;
  }

  Future<List<InterventoModel>> getInterventiByGruppo(String gruppoId) async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/intervento/gruppo/$gruppoId');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<InterventoModel> interventi = [];
        for (var item in jsonData) {
          interventi.add(InterventoModel.fromJson(item));
        }
        return interventi;
      } else {
        throw Exception('Failed to load interventi');
      }
    } catch (e) {
      print('Errore: $e');
      return [];
    }
  }


  @override
  List<DataGridRow> get rows {
    List<DataGridRow> rows = [];
    for (int i = 0; i < _gruppi.length; i++) {
      GruppoInterventiModel gruppo = _gruppi[i];
      String? cliente = gruppo.cliente?.denominazione;

      // Chiamata API per ottenere gli interventi del gruppo
      Future<List<InterventoModel>> interventi = getInterventiByGruppo(gruppo.id!);

      // Usa FutureBuilder per gestire il risultato della chiamata asincrona
      rows.add(DataGridRow(cells: [
        DataGridCell<GruppoInterventiModel>(columnName: 'gruppo', value: gruppo),
        DataGridCell<String>(columnName: 'cliente', value: cliente),
        DataGridCell<String>(columnName: 'descrizione', value: gruppo.descrizione),
        DataGridCell<String>(columnName: 'importo', value: gruppo.importo != null ? '${gruppo.importo?.toStringAsFixed(2)}€' : 'N/A'),
        DataGridCell<Widget>(
          columnName: 'inserimento_importo',
          value: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return
                    StatefulBuilder(
                        builder: (context, setState){
                          return AlertDialog(
                            title: Text('Inserisci un importo'),
                            actions: <Widget>[
                              TextFormField(
                                controller: importoController,
                                decoration: InputDecoration(
                                  labelText: 'Importo',
                                  border: OutlineInputBorder(),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // consenti solo numeri e fino a 2 decimali
                                ],
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                              ),
                              TextButton(
                                onPressed: () {
                                  saveImporto(gruppo).then((_) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => TableGruppiPage(utente: utente,)),
                                    );
                                  });
                                },
                                child: Text('Salva importo'),
                              ),
                            ],
                          );
                        }
                    );
                },
              );
            },
            icon: Icon(Icons.create, color: Colors.grey),
          ),
        ),
        DataGridCell<Future<List<InterventoModel>>>(columnName: 'importo_singoli_interventi', value: interventi)
      ]));
    }
    return rows;
  }

  Future<void> saveImporto(GruppoInterventiModel gruppo) async {
    try {
      final response = await http.post(
        Uri.parse('$ipaddress/api/gruppi'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': gruppo.id,
          'descrizione': gruppo.descrizione,
          'importo': double.parse(importoController.text),
          'concluso': gruppo.concluso,
          'note': gruppo.note,
          'cliente': gruppo.cliente?.toMap(),
        }),
      );
      if (response.statusCode == 201) {
        print('EVVAIIIIIIII');
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Errore durante il salvataggio del intervento: $e');
    }
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final GruppoInterventiModel gruppo = row
        .getCells()
        .firstWhere((cell) => cell.columnName == "gruppo")
        .value;

    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        final String columnName = dataGridCell.columnName;
        final value = dataGridCell.value;

        if (dataGridCell.value is Widget) {
          return Container(
            alignment: Alignment.center,
            child: dataGridCell.value,
          );
        }

        if (columnName == 'importo_singoli_interventi') {
          // Usa FutureBuilder per ottenere il totale degli interventi
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder<List<InterventoModel>>(
                future: value, // La lista di interventi viene dal DataGridCell
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Mostra un caricamento mentre aspetti la risposta
                    } else if (snapshot.hasError) {
                      return Text("Errore"); // Gestisci gli errori
                    } else if (snapshot.hasData) {
                      double totaleInterventi = 0.0;
                      bool hasNullImporto = false;

                      // Somma gli importi e controlla se esiste un importo nullo
                      for (var intervento in snapshot.data!) {
                        if (intervento.importo_intervento == null) {
                          hasNullImporto = true; // Trovato un importo nullo
                        } else {
                          totaleInterventi += intervento.importo_intervento!;
                        }
                      }

                      // Cambia il colore in rosso se c'è un importo nullo
                      Color textColor = hasNullImporto ? Colors.red : Colors.black;
                      FontWeight weight = hasNullImporto ? FontWeight.bold : FontWeight.normal;

                      return Text(
                        totaleInterventi.toStringAsFixed(2) + "€",
                        style: TextStyle(color: textColor, fontWeight: weight),
                      );
                    } else {
                      return Text(
                        "0.00",
                        style: TextStyle(color: Colors.black),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        } else {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DettaglioGruppoPage(gruppo: gruppo, utente: utente),
                ),
              );
            },
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(8.0),
              child: Text(
                value.toString(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black),
              ),
            ),
          );
        }
      }).toList(),
    );
  }
}