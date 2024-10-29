import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../model/CommissioneModel.dart';

class TableCommissioniPage extends StatefulWidget{
  TableCommissioniPage({Key? key}) : super(key : key);

  @override
  _TableCommissioniPageState createState() => _TableCommissioniPageState();
}

class _TableCommissioniPageState extends State<TableCommissioniPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  List<CommissioneModel> _allCommissioni = [];
  List<CommissioneModel> _filteredCommissioni = [];
  Map<String, double> _columnWidths ={
    'commissione' : 0,
    'data_creazione' : 150,
    'descrizione' : 300,
    'note' : 300,
    'concluso' : 100,
    'utente' : 200,
    'intervento' : 200,
  };
  bool isLoading = true;
  bool _isLoading = true;
  late CommissioneDataSource _dataSource;

  Future<void> getAllCommissioni() async{
    setState(() {
      isLoading = true; // Inizio del caricamento
    });
    try{
      var apiUrl = Uri.parse('$ipaddressProva/api/commissione/ordered');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<CommissioneModel> commissioni = [];
        for(var item in jsonData){
          commissioni.add(CommissioneModel.fromJson(item));
        }
        setState(() {
          _isLoading = false;
          _allCommissioni = commissioni;
          _filteredCommissioni = commissioni;
          _dataSource = CommissioneDataSource(context, _filteredCommissioni);
        });
      } else {
        _isLoading = false;
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during API call: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // Fine del caricamento
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('LISTA COMMISSIONI', style: TextStyle(color: Colors.white)),
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
                  MaterialPageRoute(builder: (context) => TableCommissioniPage()));
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
                child: isLoading ? Center(child: CircularProgressIndicator()) : SfDataGrid(
                  allowPullToRefresh: true,
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
                      columnName: 'commissione',
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
                          'commissione',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['commissione']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'data_creazione',
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
                          'Data creazione',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['data_creazione']?? double.nan,
                      minimumWidth: 150,
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
                          'Descrizione',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['descrizione']?? double.nan,
                      minimumWidth: 300,
                    ),
                    GridColumn(
                      columnName: 'note',
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
                          'Note',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['note']?? double.nan,
                      minimumWidth: 300,
                    ),
                    GridColumn(
                      columnName: 'concluso',
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
                          'Concluso',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['concluso']?? double.nan,
                      minimumWidth: 300,
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
                          'Utente',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['utente']?? double.nan,
                      minimumWidth: 300,
                    ),
                    GridColumn(
                      columnName: 'intervento',
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
                          'Intervento',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['intervento']?? double.nan,
                      minimumWidth: 300,
                    ),
                  ],
                  onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                    setState(() {
                      _columnWidths[details.column.columnName] = details.width;
                    });
                    return true;
                  },
                ))
          ],
        ),
      ),
    );
  }
}

class CommissioneDataSource extends DataGridSource{
  List<CommissioneModel> _commissioni = [];
  List<CommissioneModel> commissioniFiltrate = [];
  BuildContext context;
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
}