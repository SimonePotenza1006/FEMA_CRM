import 'dart:convert';

import 'package:fema_crm/pages/DettaglioCommissioneAmministrazionePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../model/CommissioneModel.dart';
import '../model/InterventoModel.dart';
import 'DettaglioInterventoNewPage.dart';
import 'DettaglioInterventoPage.dart';

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
    'data' : 170,
    'descrizione' : 300,
    'note' : 300,
    'concluso' : 100,
    'utente' : 200,
    'intervento' : 200,
  };
  bool isLoading = true;
  bool _isLoading = true;
  late CommissioneDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    _dataSource = CommissioneDataSource(context, _filteredCommissioni);
    getAllCommissioni();
    _filteredCommissioni = _allCommissioni.toList();
  }

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
                          'Data',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['data']?? double.nan,
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

  CommissioneDataSource(
      this.context,
      List<CommissioneModel> commissioni,
      ){
    _commissioni = List.from(commissioni);
    commissioniFiltrate = List.from(commissioni);
  }

  void updateData(List<CommissioneModel> newCommissioni){
    _commissioni.clear();
    _commissioni.addAll(newCommissioni);
    commissioniFiltrate = List.from(_commissioni);
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows{
    List<DataGridRow> rows =[];
    for(int i = 0; i < commissioniFiltrate.length; i++){
      CommissioneModel commissione = commissioniFiltrate[i];
      String? concluso = commissione.concluso != null ? (commissione.concluso != true ? "NO" : "SI") : "ERRORE";
      String? dataCreazione = DateFormat('dd/MM/yyyy').format(commissione.data_creazione!);
      String? data = commissione.data != null ? (DateFormat('dd/MM/yyyy').format(commissione.data!)) : "NESSUNA DATA";
      rows.add(DataGridRow(
        cells: [
          DataGridCell<CommissioneModel>(columnName: 'commissione', value: commissione),
          DataGridCell<String>(columnName: 'data_creazione', value: dataCreazione),
          DataGridCell<String>(columnName: 'data', value: data),
          DataGridCell<String>(columnName: 'descrizione', value: commissione.descrizione),
          DataGridCell<String>(columnName: 'note', value: commissione.note),
          DataGridCell<String>(columnName: 'concluso', value: concluso),
          DataGridCell<String>(columnName: 'utente', value: commissione.utente?.nomeCompleto()),
          DataGridCell<InterventoModel>(columnName: 'intervento', value: commissione.intervento)
        ]
      ));
    }
    return rows;
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final CommissioneModel commissione = row.getCells().firstWhere(
          (cell) => cell.columnName == "commissione",
    ).value as CommissioneModel;
    final InterventoModel? intervento = row.getCells().firstWhere(
          (cell) => cell.columnName == "intervento",
    ).value as InterventoModel?;

    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.columnName == 'intervento') {
          return Center(
              child:GestureDetector(
                onTap: () {
                  if (intervento != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DettaglioInterventoNewPage(intervento: intervento),
                      ),
                    );
                  }
                },
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 1.0),
                      child: Text(
                        intervento != null ? intervento.titolo! : '///',
                        style: TextStyle(
                          color: intervento != null ? Colors.blue : Colors.black,
                        ),
                      ),
                    ),
                    if (intervento != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 1,
                          color: Colors.blue,
                        ),
                      ),
                  ],
                ),
              ),
          );
        } else if (dataGridCell.columnName == 'commissione') {
          return SizedBox.shrink();
        } else {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DettaglioCommissioneAmministrazionePage(commissione: commissione),
                ),
              );
            },
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.grey[600]!,
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                dataGridCell.value.toString(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }
      }).toList(),
    );
  }
}