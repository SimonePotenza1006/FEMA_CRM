import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

import '../model/VeicoloModel.dart';
import 'CreazioneNuovoVeicoloPage.dart';
import 'ModificaInfoVeicoloPage.dart';

class TableVeicoliPage extends StatefulWidget{
  TableVeicoliPage({Key? key}) : super(key:key);

  @override
  _TableVeicoliPageState createState() => _TableVeicoliPageState();
}

class _TableVeicoliPageState extends State<TableVeicoliPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  late VeicoloDataSource _dataSource;
  List<VeicoloModel> allVeicoli =[];
  Map<String, double> _columnWidths = {
    'veicolo' : 0,
    'descrizione': 200,
    'targa': 120,
    'imei': 120,
    'seriale': 120,
    'proprietario' : 200,
    'chilometraggio' : 200,
    'scadenza_gps':  200,
    'scadenza_bollo' :  200,
    'scadenza_polizza':  200,
    'data_tagliando':  200,
    'data_revisione' :  200,
    'data_inversione_gomme' :  200,
    'data_sostituzione_gomme' :  200,
  };

  @override
  void initState() {
    super.initState();
    getAllVeicoli();
    _dataSource = VeicoloDataSource(context, allVeicoli);
  }

  Future<void> getAllVeicoli() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/veicolo');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<VeicoloModel> veicoli = [];
        for (var item in jsonData) {
          veicoli.add(VeicoloModel.fromJson(item));
        }
        setState(() {
          allVeicoli = veicoli;
          _dataSource = VeicoloDataSource(context, allVeicoli);
        });
      } else {
        throw Exception('Failed to load utenti data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching agenti data from API: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Connection Error'),
            content: Text('Unable to load data from API. Please check your internet connection and try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "LISTA VEICOLI",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CreazioneNuovoVeicoloPage()),
              );
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
                    columnName: 'veicolo',
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
                        'VEICOLO',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['veicolo']?? double.nan,
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
                    minimumWidth: 200,
                  ),
                  GridColumn(
                    columnName: 'targa',
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
                        'TARGA',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['targa']?? double.nan,
                    minimumWidth: 150,
                  ),
                  GridColumn(
                    columnName: 'imei',
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
                        'IMEI',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['imei']?? double.nan,
                    minimumWidth: 150,
                  ),
                  GridColumn(
                    columnName: 'seriale',
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
                        'SERIALE',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['seriale']?? double.nan,
                    minimumWidth: 150,
                  ),
                  GridColumn(
                    columnName: 'proprietario',
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
                        'PROPRIETARIO',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['proprietario']?? double.nan,
                    minimumWidth: 200,
                  ),
                  GridColumn(
                    columnName: 'chilometraggio',
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
                        'CHILOMETRAGGIO',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['chilometraggio']?? double.nan,
                    minimumWidth: 200,
                  ),
                  GridColumn(
                    columnName: 'scadenza_gps',
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
                        'SCADENZA GPS',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['scadenza_gps']?? double.nan,
                    minimumWidth: 200,
                  ),
                  GridColumn(
                    columnName: 'scadenza_bollo',
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
                        'SCADENZA BOLLO',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['scadenza_bollo']?? double.nan,
                    minimumWidth: 200,
                  ),
                  GridColumn(
                    columnName: 'scadenza_polizza',
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
                        'SCADENZA POLIZZA',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['scadenza_polizza']?? double.nan,
                    minimumWidth: 200,
                  ),
                  GridColumn(
                    columnName: 'data_tagliando',
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
                        'DATA TAGLIANDO',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['data_tagliando']?? double.nan,
                    minimumWidth: 200,
                  ),
                  GridColumn(
                    columnName: 'data_revisione',
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
                        'DATA REVISIONE',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['data_revisione']?? double.nan,
                    minimumWidth: 200,
                  ),
                  GridColumn(
                    columnName: 'data_inversione_gomme',
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
                        'DATA INVERSIONE GOMME',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['data_inversione_gomme']?? double.nan,
                    minimumWidth: 200,
                  ),
                  GridColumn(
                    columnName: 'data_sostituzione_gomme',
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
                        'DATA SOSTITUZIONE GOMME',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['data_sostituzione_gomme']?? double.nan,
                    minimumWidth: 200,
                  ),
                ],
                onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                  setState(() {
                    _columnWidths[details.column.columnName] = details.width;
                  });
                  return true;
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class VeicoloDataSource extends DataGridSource {
  List<VeicoloModel> _vehicles = [];
  BuildContext context;
  String ipaddress = 'http://gestione.femasistemi.it:8090';

  VeicoloDataSource(this.context, List<VeicoloModel> vehicles) {
    _vehicles = vehicles;
  }

  @override
  List<DataGridRow> get rows {
    List<DataGridRow> rows = [];
    for (int i = 0; i < _vehicles.length; i++) {
      VeicoloModel veicolo = _vehicles[i];
      String? formattedGps = veicolo.scadenza_gps != null ? DateFormat('dd/MM/yyyy').format(veicolo.scadenza_gps!) : "//";
      String? formattedBollo = veicolo.data_scadenza_bollo != null ? DateFormat('dd/MM/yyyy').format(veicolo.data_scadenza_bollo!) : "//";
      String? formattedPolizza = veicolo.data_scadenza_polizza != null ? DateFormat('dd/MM/yyyy').format(veicolo.data_scadenza_polizza!) : "//";
      String? formattedTagliando = veicolo.data_tagliando != null ? DateFormat('dd/MM/yyyy').format(veicolo.data_tagliando!) : "//";
      String? formattedRevisione = veicolo.data_revisione != null ? DateFormat('dd/MM/yyyy').format(veicolo.data_revisione!) : "//";
      String? formattedSostituzione = veicolo.data_sostituzione_gomme != null ? DateFormat('dd/MM/yyyy').format(veicolo.data_sostituzione_gomme!) : "//";
      String? formattedInversione = veicolo.data_inversione_gomme != null ? DateFormat('dd/MM/yyyy').format(veicolo.data_inversione_gomme!) : "//";
      String? descrizione = veicolo.descrizione != null ? veicolo.descrizione! : "//";
      String? km = veicolo.chilometraggio_attuale != null ? veicolo.chilometraggio_attuale!.toString() : "//";
      String? targa = veicolo.targa != null ? veicolo.targa! : "//";
      String? imei = veicolo.imei != null ? veicolo.imei! : "//";
      String? seriale = veicolo.seriale != null ? veicolo.seriale : "//";
      String? proprietario = veicolo.proprietario != null ? veicolo.proprietario : "//";

      rows.add(DataGridRow(cells: [
        DataGridCell<VeicoloModel>(columnName: 'veicolo', value: veicolo),
        DataGridCell<String>(columnName: 'descrizione', value: descrizione),
        DataGridCell<String>(columnName: 'targa', value: targa),
        DataGridCell<String>(columnName: 'imei', value: imei),
        DataGridCell<String>(columnName: 'seriale', value: seriale),
        DataGridCell<String>(columnName: 'proprietario', value: proprietario),
        DataGridCell<String>(columnName: 'chilometraggio', value: km),
        DataGridCell<String>(columnName: 'scadenza_gps', value: formattedGps),
        DataGridCell<String>(columnName: 'scadenza_bollo', value: formattedBollo),
        DataGridCell<String>(columnName: 'scadenza_polizza', value: formattedPolizza),
        DataGridCell<String>(columnName: 'data_tagliando', value: formattedTagliando),
        DataGridCell<String>(columnName: 'data_revisione', value: formattedRevisione),
        DataGridCell<String>(columnName: 'data_inversione_gomme', value: formattedInversione),
        DataGridCell<String>(columnName: 'data_sostituzione_gomme', value: formattedSostituzione),
      ]));
    }
    return rows;
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final VeicoloModel veicolo = row.getCells().firstWhere((cell) => cell.columnName == 'veicolo').value;

    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        final String columnName = dataGridCell.columnName;
        final value = dataGridCell.value;

        // Controllo del colore delle celle per le date
        Color textColor = Colors.black;
        if (columnName.startsWith('scadenza') || columnName.startsWith('data')) {
          if (value != "//" && value != null) {
            DateTime? cellDate;
            try {
              cellDate = DateFormat('dd/MM/yyyy').parse(value);
            } catch (e) {
              cellDate = null;
            }

            if (cellDate != null) {
              final today = DateTime.now();
              final difference = cellDate.difference(today).inDays;

              if (difference < 0) {
                textColor = Colors.red; // Data superata
              } else if (difference <= 7) {
                textColor = Colors.yellow[700]!; // Data vicina (entro 10 giorni)
              }
            }
          }
        }

        return GestureDetector(
          onTap: () {
            print("Tapped on ${veicolo.targa}");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ModificaInfoVeicoloPage(veicolo: veicolo),
              ),
            );
          },
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
            child: Text(
              value.toString(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: textColor),
            ),
          ),
        );
      }).toList(),
    );
  }
}