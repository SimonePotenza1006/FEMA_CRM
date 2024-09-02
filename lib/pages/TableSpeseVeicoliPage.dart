import 'dart:convert';
import 'package:fema_crm/pages/DettaglioSpesaVeicoloPage.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
import '../model/SpesaVeicoloModel.dart';
import '../model/VeicoloModel.dart';

class TableSpeseVeicoliPage extends StatefulWidget{
  TableSpeseVeicoliPage({Key? key}) : super(key: key);

  @override
  _TableSpeseVeicoliPageState createState() =>_TableSpeseVeicoliPageState();
}

class _TableSpeseVeicoliPageState extends State<TableSpeseVeicoliPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  late SpesaDataSource _dataSource;
  List<SpesaVeicoloModel> allSpese = [];
  Map<String, double> _columnWidths ={
    'spesa' : 0,
    'data' : 200,
    'veicolo' : 200,
    'tipologia_spesa' : 200,
    'note_tipologia' : 200,
    'fornitore' : 200,
    'note_fornitore' : 200,
    'importo' : 200,
    'chilometraggio' : 200,
    'utente' : 200
  };

  @override
  void initState(){
    super.initState();
    getAllSpese();
    _dataSource = SpesaDataSource(context, allSpese);
  }

  Future<void> getAllSpese() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/spesaVeicolo/ordered');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<SpesaVeicoloModel> spese = [];
        for (var item in jsonData) {
          spese.add(SpesaVeicoloModel.fromJson(item));
        }
        setState(() {
          allSpese = spese;
          _dataSource = SpesaDataSource(context, allSpese);
        });
      } else {
        throw Exception(
            'Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Errore di connessione'),
            content: Text(
                'Impossibile caricare i dati dall\'API. Controlla la tua connessione internet e riprova.'),
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
        title: Text("REPORT SPESE SU VEICOLO",
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
                      columnName: 'spesa',
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
                          'SPESA',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['spesa']?? double.nan,
                      minimumWidth: 0,
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
                          'DATA',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['data']?? double.nan,
                      minimumWidth: 0,
                    ),
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
                      columnName: 'tipologia_spesa',
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
                          'TIPOLOGIA SPESA',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['tipologia_spesa']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'note_tipologia',
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
                          'NOTE TIPOLOGIA',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['note_tipologia']?? double.nan,
                      minimumWidth: 0,
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
                          'FORNITORE',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['fornitore']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'note_fornitore',
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
                          'NOTE FORNITORE',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['note_fornitore']?? double.nan,
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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['utente']?? double.nan,
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

class SpesaDataSource extends DataGridSource{
  List<SpesaVeicoloModel> _spese = [];
  BuildContext context;
  String ipaddres = 'http://gestione.femasistemi.it:8090';

  SpesaDataSource(this.context, List<SpesaVeicoloModel> spese){
    _spese = spese;
  }

  @override
  List<DataGridRow> get rows {
    List<DataGridRow> rows = [];
    for(int i = 0; i < _spese.length; i++){
      SpesaVeicoloModel spesa = _spese[i];
      String? formattedData = spesa.data != null ? DateFormat('dd/MM/yyyy').format(spesa.data!) : "//";
      String? veicolo = spesa.veicolo != null ? spesa.veicolo!.descrizione! : '//';
      String? tipologia = spesa.tipologia_spesa != null ? spesa.tipologia_spesa!.descrizione! : '//';
      String? noteTipologia = spesa.note_tipologia_spesa != null ? spesa.note_tipologia_spesa! : '//';
      String? fornitore = spesa.fornitore_carburante != null ? spesa.fornitore_carburante! : "//";
      String? noteFornitore = spesa.note_fornitore != null ? spesa.note_fornitore! : '//';
      String? importo = spesa.importo != null ? spesa.importo.toString() + '€' : '//';
      String? chilometraggio = spesa.km != null ? spesa.km.toString() + ' km' : '//';
      String? utente = spesa.utente != null ? spesa.utente!.nomeCompleto() : '//';

      rows.add(DataGridRow(cells: [
        DataGridCell<SpesaVeicoloModel?>(columnName: 'spesa', value:spesa),
        DataGridCell<String?>(columnName: 'data', value: formattedData),
        DataGridCell<String?>(columnName: 'veicolo', value: veicolo),
        DataGridCell<String?>(columnName: 'tipologia_spesa', value: tipologia),
        DataGridCell<String?>(columnName: 'note_tipologia', value:noteTipologia),
        DataGridCell<String?>(columnName: 'fornitore', value: fornitore),
        DataGridCell<String?>(columnName: 'note_fornitore', value: noteFornitore),
        DataGridCell<String?>(columnName: 'importo', value:importo),
        DataGridCell<String?>(columnName: 'chilometraggio', value:chilometraggio),
        DataGridCell<String?>(columnName: 'utente', value:utente),
      ]));
    }
    return rows;
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row){
    final SpesaVeicoloModel spesa = row.getCells().firstWhere((cell) => cell.columnName == 'spesa').value;

    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell){
          final String columnName = dataGridCell.columnName;
          final value = dataGridCell.value;

          Color textColor = Colors.black;

          return GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DettaglioSpesaVeicoloPage(spesa: spesa),
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