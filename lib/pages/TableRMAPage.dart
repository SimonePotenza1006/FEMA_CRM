import 'dart:convert';
import 'dart:io';
//import 'package:fema_crm/model/MerceInRiparazioneModel.dart';
import 'package:fema_crm/model/RestituzioneMerceModel.dart';
import 'package:fema_crm/model/TipologiaInterventoModel.dart';
import 'package:fema_crm/pages/HomeFormAmministrazioneNewPage.dart';
//import 'package:fema_crm/pages/DettaglioMerceInRiparazioneAmministrazionePage.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

import 'DettaglioRMAAmministrazionePage.dart';

class TableRMAPage extends StatefulWidget{
  TableRMAPage({Key? key}) : super(key : key);

  @override
  _TableRMAPageState createState() => _TableRMAPageState();
}

class _TableRMAPageState extends State<TableRMAPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  List<RestituzioneMerceModel> _allMerce = [];
  late MerceDataSource _dataSource;
  Map<String, double> _columnWidths = {
    'merce' : 0,
    'prodotto' : 200,
    'data_acquisto' : 130,
    'difetto_riscontrato' : 200,
    'fornitore' : 200,
    'data_riconsegna' : 200,
    'utenteRiconsegna' : 200,
    'rimborso' : 160,
    'cambio' : 160,
    'data_rientro_ufficio' : 120,
    'utenteRitiro' : 200,
    'concluso' : 160

   /* 'data_arrivo' : 120,
    'articolo' : 300,
    'difetto' : 300,
    'richiesta_preventivo' : 80,
    'importo_preventivato' : 120,
    'data_presa_in_carico' : 120,
    'data_comunica_preventivo' : 120,
    'preventivo_accettato' : 80,
    'data_accettazione_preventivo' : 120,
    'data_conclusione' : 120,
    'prodotti_installati' : 300,
    'data_consegna' : 120*/
  };

  Future<void> getAllMerce() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/restituzioneMerce');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<RestituzioneMerceModel> merce = [];
        for(var item in jsonData){
          merce.add(RestituzioneMerceModel.fromJson(item));
        }
        setState(() {
          _allMerce = merce;
          _dataSource = MerceDataSource(context, _allMerce);
        });
      } else {
        throw Exception('Failed to load merce data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Qualcosa non va nel tirare giù la merce : $e');
    }
  }

  @override
  void initState(){
    super.initState();
    _dataSource = MerceDataSource(context, _allMerce);
    getAllMerce();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista merce RMA'.toUpperCase(),
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          MouseRegion(
            onEnter: (event) {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Legenda colori:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text('RMA Registrata'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.grey[300],
                            ),
                            SizedBox(width: 8),
                            Text('Riconsegnata al fornitore'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.blue[300],
                            ),
                            SizedBox(width: 8),
                            Text('Rientrata in ufficio'),
                          ],
                        ),
                        SizedBox(height: 8),
                        /*Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.red[300],
                            ),
                            SizedBox(width: 8),
                            Text('Preventivo rifiutato'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.orange[300],
                            ),
                            SizedBox(width: 8),
                            Text('Preventivo accettato, riparazione in corso'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.green[300],
                            ),
                            SizedBox(width: 8),
                            Text('Riparazione conclusa'),
                          ],
                        ),*/
                      ],
                    ),
                  );
                },
              );
            },
            child: IconButton(
              icon: Icon(Icons.info),
              color: Colors.white,
              onPressed: () {
                if(Platform.isAndroid)
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Legenda colori:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text('RMA Registrata'),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  color: Colors.grey[300],
                                ),
                                SizedBox(width: 8),
                                Text('Riconsegnata al fornitore'),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  color: Colors.blue[300],
                                ),
                                SizedBox(width: 8),
                                Text('Rientrata in ufficio'),
                              ],
                            ),
                            SizedBox(height: 8),
                            /*Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  color: Colors.red[300],
                                ),
                                SizedBox(width: 8),
                                Text('Preventivo rifiutato'),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  color: Colors.orange[300],
                                ),
                                SizedBox(width: 8),
                                Text('Preventivo accettato, riparazione in corso'),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  color: Colors.green[300],
                                ),
                                SizedBox(width: 8),
                                Text('Riparazione conclusa'),
                              ],
                            ),*/
                          ],
                        ),
                      );
                    },
                  );
              },
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.refresh, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
              color: Colors.white,
            ),
            onPressed: () {
              getAllMerce();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
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
                      columnName: 'merce',
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
                          'merce',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['merce']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'prodotto',
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
                          'prodotto'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['prodotto']?? double.nan,
                      minimumWidth: 200,
                    ),
                    GridColumn(
                      columnName: 'data_acquisto',
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
                          'data acquisto'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['data_acquisto']?? double.nan,
                      minimumWidth: 130,
                    ),
                    GridColumn(
                      columnName: 'difetto_riscontrato',
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
                          'difetto riscontrato'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['difetto_riscontrato']?? double.nan,
                      minimumWidth: 200,
                    ),
                    GridColumn(
                      columnName: 'fornitore',
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
                          'fornitore'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['fornitore']?? double.nan,
                      minimumWidth: 200,
                    ),
                    GridColumn(
                      columnName: 'data_riconsegna',
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
                          'data riconsegna'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['data_riconsegna']?? double.nan,
                      minimumWidth: 120,
                    ),
                    GridColumn(
                      columnName: 'utenteRiconsegna',
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
                          'utente Riconsegna'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['utenteRiconsegna']?? double.nan,
                      minimumWidth: 200,
                    ),
                    GridColumn(
                      columnName: 'rimborso',
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
                          'rimborso'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['rimborso']?? double.nan,
                      minimumWidth: 160,
                    ),
                    GridColumn(
                      columnName: 'cambio',
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
                          'cambio'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['cambio']?? double.nan,
                      minimumWidth: 160,
                    ),
                    GridColumn(
                      columnName: 'data_rientro_ufficio',
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
                          'data rientro'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['data_rientro_ufficio']?? double.nan,
                      minimumWidth: 200,
                    ),
                    GridColumn(
                      columnName: 'utenteRitiro',
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
                          'utente Ritiro'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['utenteRitiro']?? double.nan,
                      minimumWidth: 200,
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
                          'concluso'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['concluso']?? double.nan,
                      minimumWidth: 160,
                    ),

                  ],
                  onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                    setState(() {
                      _columnWidths[details.column.columnName] = details.width;
                    });
                    return true;
                  },
                )
            )
          ],
        ),
      ),
    );
  }
}

class MerceDataSource extends DataGridSource{
  List<RestituzioneMerceModel> _merch = [];
  BuildContext context;

  MerceDataSource(this.context, List<RestituzioneMerceModel> merce){
    _merch = merce;
  }

  void updateData(List<RestituzioneMerceModel> newMerce){
    _merch.clear();
    _merch.addAll(newMerce);
  }

  @override
  List<DataGridRow> get rows{
    List<DataGridRow> rows = [];
    for(int i = 0; i < _merch.length; i++){
      RestituzioneMerceModel merce = _merch[i];
      //String? importo = merce.importo_preventivato != null ? merce.importo_preventivato!.toStringAsFixed(2) : "N/A";
      //String? preventivo = merce.preventivo != null ? "SI" : "NO";
      //String? preventivoAccettato = merce.preventivo != null ? (merce.preventivo != true ? "NO" : "SI") : "N/A";
      String? rimborso = merce.rimborso != null ? (merce.rimborso != true ? "NO" : "SI") : "N/A";
      String? cambio = merce.cambio != null ? (merce.cambio != true ? "NO" : "SI") : "N/A";
      String? concluso = merce.concluso != null ? (merce.concluso != true ? "NO" : "SI") : "N/A";

      rows.add(DataGridRow(
          cells: [
            DataGridCell<RestituzioneMerceModel>(columnName: 'merce', value: merce),
            DataGridCell<String>(
                columnName: 'prodotto',
                value: merce.prodotto,
            ),
            DataGridCell<String>(
                columnName: 'data_acquisto',
                value: merce.data_acquisto != null
                    ? DateFormat('dd/MM/yyyy').format(merce.data_acquisto!)
                    : 'N/A',
            ),
            DataGridCell<String>(
                columnName: 'difetto_riscontrato',
                value: merce.difetto_riscontrato ?? '',
            ),
            DataGridCell<String>(
                columnName: 'fornitore',
                value: merce.fornitore!.denominazione,
            ),
            DataGridCell<String>(
                columnName: 'data_riconsegna',
                value: merce.data_riconsegna != null
                    ? DateFormat('dd/MM/yyyy').format(merce.data_riconsegna!)
                    : 'N/A',
            ),
            DataGridCell<String>(
                columnName: 'utenteRiconsegna',
                value: merce.utenteRiconsegna != null ? merce.utenteRiconsegna!.nome!+' '+merce.utenteRiconsegna!.cognome! : 'N/A',
            ),
            DataGridCell<String>(
                columnName: 'rimborso',
                value: rimborso,//merce.data_comunica_preventivo != null ? DateFormat('dd/MM/yyyy').format(merce.data_comunica_preventivo!) : 'N/A',
            ),
            DataGridCell<String>(
                columnName: 'cambio',
                value: cambio,//preventivoAccettato
            ),
            DataGridCell<String>(
                columnName: 'data_rientro_ufficio',
                value: merce.data_rientro_ufficio != null
                    ? DateFormat('dd/MM/yyyy').format(merce.data_rientro_ufficio!)
                    : 'N/A'
            ),
            DataGridCell<String>(
                columnName: 'utenteRitiro',
                value: merce.utenteRitiro != null ? merce.utenteRitiro!.nome!+' '+merce.utenteRitiro!.cognome! : 'N/A'
            ),
            DataGridCell<String>(
                columnName: 'concluso',
                value: concluso
            ),

          ]
      ));
    }
    return rows;
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row){
    final RestituzioneMerceModel merce = row.getCells().firstWhere(
            (cell) => cell.columnName == 'merce',
    ).value as RestituzioneMerceModel;

    Color backgroundColor = Colors.white;

    if (merce.data_riconsegna != null && merce.data_rientro_ufficio == null) {
      backgroundColor = Colors.grey[300]!; // Grigio chiaro
    } else if (merce.data_rientro_ufficio != null) {
      backgroundColor = Colors.blue[300]!; // Arancione
    /*} else if (merce.preventivo == true && merce.preventivo_accettato == false) {
      backgroundColor = Colors.red[300]!; // Rosso
    } else if (merce.preventivo == true && merce.preventivo_accettato == true && merce.data_conclusione == null) {
      backgroundColor = Colors.orange[300]!; // Blu
    } else if (merce.data_conclusione != null) {
      backgroundColor = Colors.green[300]!; // Verde*/
    } else {
      backgroundColor = Colors.white; // Default to white if none of the conditions are met
    }

    return DataGridRowAdapter(
      color: backgroundColor,
        cells: row.getCells().map<Widget>((dataGridCell){
          if (dataGridCell.columnName == 'merce') {
            // Cella invisibile per l'oggetto InterventoModel
            return SizedBox.shrink(); // La cella sarà invisibile ma presente
          }
          if(dataGridCell.value is Widget){
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.grey[600]!,
                    width: 1,
                  ),
                ),
              ),
              child: dataGridCell.value,
            );
          } else {
            return GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DettaglioRMAAmministrazionePage(merce: merce),
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