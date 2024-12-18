import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'dart:convert';

import '../model/IngressoModel.dart';

class TableAccessiApplicazionePage extends StatefulWidget {
  TableAccessiApplicazionePage({Key? key}) : super(key: key);

  @override
  _TableAccessiApplicazionePageState createState() =>
      _TableAccessiApplicazionePageState();
}

class _TableAccessiApplicazionePageState
    extends State<TableAccessiApplicazionePage> {
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';
  late IngressoDataSource _dataSource;
  List<IngressoModel> allIngressi = [];
  Map<String, double> _columnWidths = {
    'data': 400,
    'utente': 400,
  };

  Future<void> getAllIngressi() async {
    try {
      var apiUrl = Uri.parse('$ipaddressProva2/api/ingresso/ordered');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<IngressoModel> ingressi = [];
        for (var item in jsonData) {
          ingressi.add(IngressoModel.fromJson(item));
        }
        setState(() {
          allIngressi = ingressi;
          _dataSource = IngressoDataSource(context, allIngressi);
        });
      } else {
        throw Exception(
            'Failed to load ingressi data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ingressi: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _dataSource = IngressoDataSource(context, allIngressi);
    getAllIngressi();
  }

  // Funzione per filtrare in base alla data selezionata
  void _filterIngressiByDate(DateTime selectedDate) async {
    // Ricarica tutti gli ingressi prima di filtrare
    await getAllIngressi();

    setState(() {
      allIngressi = allIngressi.where((ingresso) {
        return ingresso.orario != null &&
            ingresso.orario!.year == selectedDate.year &&
            ingresso.orario!.month == selectedDate.month &&
            ingresso.orario!.day == selectedDate.day;
      }).toList();

      _dataSource = IngressoDataSource(context, allIngressi);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report ingressi applicazione',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          Hero(
            tag: 'calendar_button',
            child: IconButton(
              icon: Icon(Icons.calendar_today, color: Colors.white),
              onPressed: () async {
                DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  helpText: 'Seleziona una data',
                  locale: Locale('it', 'IT'),
                );

                if (selectedDate != null) {
                  // Filtra i dati della tabella in base alla data selezionata
                  _filterIngressiByDate(selectedDate);
                }
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(13),
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
                    columnName: 'data',
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
                        'DATA',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['data'] ?? double.nan,
                    minimumWidth: 0,
                  ),
                  GridColumn(
                    columnName: 'utente',
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
                        'UTENTE',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['utente'] ?? double.nan,
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
            ),
          ],
        ),
      ),
    );
  }
}

class IngressoDataSource extends DataGridSource {
  List<IngressoModel> _ingressi = [];
  BuildContext context;

  IngressoDataSource(this.context, List<IngressoModel> ingressi) {
    _ingressi = ingressi;
  }

  @override
  List<DataGridRow> get rows {
    List<DataGridRow> rows = [];
    for (int i = 0; i < _ingressi.length; i++) {
      IngressoModel ingresso = _ingressi[i];
      String? formattedData =
      DateFormat('dd/MM/yyyy HH:mm').format(ingresso.orario!);
      String? utente = ingresso.utente!.nomeCompleto();
      rows.add(DataGridRow(cells: [
        DataGridCell<String>(columnName: 'data', value: formattedData),
        DataGridCell<String>(columnName: 'utente', value: utente),
      ]));
    }
    return rows;
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        final value = dataGridCell.value;
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8),
          child: Text(
            value.toString(),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black),
          ),
        );
      }).toList(),
    );
  }
}
