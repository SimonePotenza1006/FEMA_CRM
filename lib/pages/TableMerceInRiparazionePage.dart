import 'dart:convert';
import 'package:fema_crm/model/MerceInRiparazioneModel.dart';
import 'package:fema_crm/model/TipologiaInterventoModel.dart';
import 'package:fema_crm/pages/DettaglioMerceInRiparazioneAmministrazionePage.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class TableMerceInRiparazionePage extends StatefulWidget{
  TableMerceInRiparazionePage({Key? key}) : super(key : key);

  @override
  _TableMerceInRiparazionePageState createState() => _TableMerceInRiparazionePageState();
}

class _TableMerceInRiparazionePageState extends State<TableMerceInRiparazionePage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  List<MerceInRiparazioneModel> _allMerce = [];
  late MerceDataSource _dataSource;
  Map<String, double> _columnWidths = {
    'merce' : 0,
    'data_arrivo' : 120,
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
    'data_consegna' : 120
  };

  Future<void> getAllMerce() async{
    try{
      var apiUrl = Uri.parse('$ipaddressProva/api/merceInRiparazione/ordered');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<MerceInRiparazioneModel> merce = [];
        for(var item in jsonData){
          merce.add(MerceInRiparazioneModel.fromJson(item));
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
          'Lista merce in riparazione'.toUpperCase(),
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
                            Text('Presenza in magazzino'),
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
                            Text('Presa in carico'),
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
                            Text('Preventivo comunicato, in attesa di accettazione'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
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
                              color: Colors.blue[300],
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
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: IconButton(
              icon: Icon(Icons.info),
              color: Colors.white,
              onPressed: () {},
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
                      columnName: 'data_arrivo',
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
                          'data arrivo'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['data_arrivo']?? double.nan,
                      minimumWidth: 120,
                    ),
                    GridColumn(
                      columnName: 'articolo',
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
                          'articolo'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['articolo']?? double.nan,
                      minimumWidth: 200,
                    ),
                    GridColumn(
                      columnName: 'difetto',
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
                          'difetto'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['difetto']?? double.nan,
                      minimumWidth: 200,
                    ),
                    GridColumn(
                      columnName: 'richiesta_preventivo',
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
                          'richiesta preventivo'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['richiesta_preventivo']?? double.nan,
                      minimumWidth: 80,
                    ),
                    GridColumn(
                      columnName: 'importo_preventivato',
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
                          'importo preventivato'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['importo_preventivato']?? double.nan,
                      minimumWidth: 80,
                    ),
                    GridColumn(
                      columnName: 'data_presa_in_carico',
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
                          'data incarico'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['data_presa_in_carico']?? double.nan,
                      minimumWidth: 120,
                    ),
                    GridColumn(
                      columnName: 'data_comunica_preventivo',
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
                          'data comunicazione preventivo'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['data_comunica_preventivo']?? double.nan,
                      minimumWidth: 120,
                    ),
                    GridColumn(
                      columnName: 'preventivo_accettato',
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
                          'preventivo accettato'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['preventivo_accettato']?? double.nan,
                      minimumWidth: 80,
                    ),
                    GridColumn(
                      columnName: 'data_accettazione_preventivo',
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
                          'data accettazione preventivo'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['data_accettazione_preventivo']?? double.nan,
                      minimumWidth: 120,
                    ),
                    GridColumn(
                      columnName: 'data_conclusione',
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
                          'data conclusione'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['data_conclusione']?? double.nan,
                      minimumWidth: 120,
                    ),
                    GridColumn(
                      columnName: 'prodotti_installati',
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
                          'prodotti installati'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['prodotti_installati']?? double.nan,
                      minimumWidth: 200,
                    ),
                    GridColumn(
                      columnName: 'data_consegna',
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
                          'data consegna'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['data_consegna']?? double.nan,
                      minimumWidth: 120,
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
  List<MerceInRiparazioneModel> _merch = [];
  BuildContext context;

  MerceDataSource(this.context, List<MerceInRiparazioneModel> merce){
    _merch = merce;
  }

  void updateData(List<MerceInRiparazioneModel> newMerce){
    _merch.clear();
    _merch.addAll(newMerce);
  }

  @override
  List<DataGridRow> get rows{
    List<DataGridRow> rows = [];
    for(int i = 0; i < _merch.length; i++){
      MerceInRiparazioneModel merce = _merch[i];
      String? importo = merce.importo_preventivato != null ? merce.importo_preventivato!.toStringAsFixed(2) : "N/A";
      String? preventivo = merce.preventivo != null ? "SI" : "NO";
      String? preventivoAccettato = merce.preventivo != null ? (merce.preventivo != true ? "NO" : "SI") : "N/A";

      rows.add(DataGridRow(
          cells: [
            DataGridCell<MerceInRiparazioneModel>(columnName: 'merce', value: merce),
            DataGridCell<String>(
                columnName: 'data_arrivo',
                value: merce.data != null
                    ? DateFormat('dd/MM/yyyy').format(merce.data!)
                    : ''
            ),
            DataGridCell<String>(
                columnName: 'articolo',
                value: merce.articolo ?? '',
            ),
            DataGridCell<String>(
                columnName: 'difetto',
                value: merce.difetto_riscontrato ?? '',
            ),
            DataGridCell<String>(
                columnName: 'richiesta_preventivo',
                value: preventivo,
            ),
            DataGridCell<String>(
                columnName: 'importo_preventivato',
                value: importo,
            ),
            DataGridCell<String>(
                columnName: 'data_presa_in_carico',
                value: merce.data_presa_in_carico != null
                    ? DateFormat('dd/MM/yyyy').format(merce.data_presa_in_carico!)
                    : 'N/A',
            ),
            DataGridCell<String>(
                columnName: 'data_comunica_preventivo',
                value: merce.data_comunica_preventivo != null
                    ? DateFormat('dd/MM/yyyy').format(merce.data_comunica_preventivo!)
                    : 'N/A',
            ),
            DataGridCell<String>(
                columnName: 'preventivo_accettato',
                value: preventivoAccettato
            ),
            DataGridCell<String>(
                columnName: 'data_accettazione_preventivo',
                value: merce.data_accettazione_preventivo != null
                    ? DateFormat('dd/MM/yyyy').format(merce.data_accettazione_preventivo!)
                    : 'N/A'
            ),
            DataGridCell<String>(
                columnName: 'data_conclusione',
                value: merce.data_conclusione != null
                    ? DateFormat('dd/MM/yyyy').format(merce.data_conclusione!)
                    : 'N/A'
            ),
            DataGridCell<String>(
                columnName: 'prodotti_installati',
                value: merce.prodotti_installati ?? 'N/A'
            ),
            DataGridCell<String>(
                columnName: 'data_consegna',
                value: merce.data_consegna != null
                    ? DateFormat('dd/MM/yyyy').format(merce.data_consegna!)
                    : 'N/A'
            ),
          ]
      ));
    }
    return rows;
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row){
    final MerceInRiparazioneModel merce = row.getCells().firstWhere(
            (cell) => cell.columnName == 'merce',
    ).value as MerceInRiparazioneModel;

    Color backgroundColor;

    if (merce.presenza_magazzino == true) {
      backgroundColor = Colors.white; // Bianco
    } else if (merce.data_presa_in_carico != null) {
      backgroundColor = Colors.grey[300]!; // Grigio chiaro
    } else if (merce.preventivo == true && merce.data_comunica_preventivo != null && merce.preventivo_accettato == null) {
      backgroundColor = Colors.orange[300]!; // Arancione
    } else if (merce.preventivo == true && merce.preventivo_accettato == false) {
      backgroundColor = Colors.red[300]!; // Rosso
    } else if (merce.preventivo == true && merce.preventivo_accettato == true && merce.data_conclusione == null) {
      backgroundColor = Colors.blue[300]!; // Blu
    } else if (merce.data_conclusione != null) {
      backgroundColor = Colors.green[300]!; // Verde
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
                    builder: (context) => DettaglioMerceInRiparazioneAmministrazionePage(merce: merce),
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