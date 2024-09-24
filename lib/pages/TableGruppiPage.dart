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

class TableGruppiPage extends StatefulWidget{
  TableGruppiPage({Key? key}) : super(key:key);

  @override
  _TableGruppiPageState createState() => _TableGruppiPageState();
}

class _TableGruppiPageState extends State<TableGruppiPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  late GruppoDataSource _dataSource;
  List<GruppoInterventiModel> allGruppi =[];
  Map<String, double> _columnWidths = {
    'gruppo' : 0,
    'cliente' : 400,
    'descrizione' : 450,
    'importo' : 150,
    'importo_singoli_interventi' : 150,
  };

  @override
  void initState(){
    super.initState();
    getAllGruppi();
    _dataSource = GruppoDataSource(context, allGruppi);
  }

  Future<void> getAllGruppi() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/gruppi');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<GruppoInterventiModel> gruppi =[];
        for(var item in jsonData){
          gruppi.add(GruppoInterventiModel.fromJson(item));
        }
        setState(() {
          allGruppi = gruppi;
          _dataSource = GruppoDataSource(context, allGruppi);
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
  List<GruppoInterventiModel> _gruppi =[];
  BuildContext context;
  String ipaddress = 'http://gestione.femasistemi.it:8090';

  GruppoDataSource(this.context, List<GruppoInterventiModel> gruppi){
    _gruppi = gruppi;
  }

  Future<List<InterventoModel>> getInterventiByGruppo(String gruppoId) async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/intervento/gruppo/$gruppoId');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
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
        DataGridCell<String>(columnName: 'importo', value: gruppo.importo?.toStringAsFixed(2)),
        DataGridCell<Future<List<InterventoModel>>>(columnName: 'importo_singoli_interventi', value: interventi)
      ]));
    }
    return rows;
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

        if (columnName == 'importo_singoli_interventi') {
          // Usa FutureBuilder per ottenere il totale degli interventi
          return FutureBuilder<List<InterventoModel>>(
            future: value, // La lista di interventi viene dal DataGridCell
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Mostra un caricamento mentre aspetti la risposta
              } else if (snapshot.hasError) {
                return Text("Errore"); // Gestisci gli errori
              } else if (snapshot.hasData) {
                double totaleInterventi = 0.0;
                for (var intervento in snapshot.data!) {
                  totaleInterventi += intervento.importo_intervento ?? 0;
                }
                return Text(totaleInterventi.toStringAsFixed(2));
              } else {
                return Text("0.00");
              }
            },
          );
        } else {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
            child: Text(
              value.toString(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black),
            ),
          );
        }
      }).toList(),
    );
  }
}