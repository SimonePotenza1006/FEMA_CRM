import 'dart:convert';
import 'package:fema_crm/pages/DettaglioProdottoPage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../model/ProdottoModel.dart';

class TableMagazzinoPage extends StatefulWidget{
  TableMagazzinoPage({Key? key}) : super(key:key);

  @override
  _TableMagazzinoPageState createState() => _TableMagazzinoPageState();
}

class _TableMagazzinoPageState extends State<TableMagazzinoPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  List<ProdottoModel> _allProdotti = [];
  List<ProdottoModel> _filteredProdotti = [];
  late ProdottoDataSource _dataSource;
  Map<String, double> _columnWidths ={
    'prodotto' : 0,
    'codice_danea' : 120,
    'descrizione' : 200,
    'unita_misura' : 120,
    'prezzo_fornitore' : 150,
    'prezzo_medio_vendita' : 150,
    'ultimo_costo' : 150,
    'fornitore' : 200,
    'iva' : 100
  };

  @override
  void initState() {
    super.initState();
    _dataSource = ProdottoDataSource(context, _filteredProdotti);
    getProdotti();
  }

  Future<void> getProdotti() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/prodotto');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<ProdottoModel> prodotti = [];
        for(var item in jsonData){
          prodotti.add(ProdottoModel.fromJson(item));
        }
        setState(() {
          _allProdotti = prodotti;
          _filteredProdotti = prodotti;
          _dataSource = ProdottoDataSource(context, _filteredProdotti);
        });
      }
    }catch(e){
      print('Qualcosa non va prodotti : $e');
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('MAGAZZINO', style: TextStyle(color: Colors.white)),
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
                  allowPullToRefresh: true,
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
                          'prodotto',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['prodotto']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'codice_danea',
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
                          'COD. DANEA',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['codice_danea']?? double.nan,
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
                      columnName: 'unita_misura',
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
                          'unità di misura'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['unita?misura']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'prezzo_fornitore',
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
                          'PREZZO FORNITORE',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['prezzo_fornitore']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'prezzo_medio_vendita',
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
                          'PREZZO MEDIO VENDITA',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['prezzo_medio_vendita']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'ultimo_costo',
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
                          'ULTIMO COSTO',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['ultimo_costo']?? double.nan,
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
                      columnName: 'iva',
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
                          'IVA',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['iva']?? double.nan,
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
            )
          ],
        ),
      ),
    );
  }
}

class ProdottoDataSource extends DataGridSource{
  List<ProdottoModel> _products = [];
  List<ProdottoModel> filteredProducts = [];
  BuildContext context;

  ProdottoDataSource(this.context, List<ProdottoModel> products){
    _products = List.from(products);
    filteredProducts = List.from(products);
  }

  void updateData(List<ProdottoModel> prodotti){
    _products.clear();
    _products.addAll(prodotti);
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows{
    List<DataGridRow> rows = [];
    for(int i = 0; i < filteredProducts.length; i++){
      ProdottoModel prodotto = filteredProducts[i];
      rows.add(DataGridRow(
          cells: [
            DataGridCell<ProdottoModel>(columnName: 'prodotto', value: prodotto),
            DataGridCell<String>(columnName: 'codice_danea', value: prodotto.codice_danea != null ? prodotto.codice_danea! : 'N/A'),
            DataGridCell<String>(columnName: 'descrizione', value: prodotto.descrizione != null ? prodotto.descrizione : "N/A"),
            DataGridCell<String>(columnName: 'unita_misura', value: prodotto.unita_misura != null ? prodotto.unita_misura : "N/A"),
            DataGridCell<String>(columnName: 'prezzo_fornitore', value: prodotto.prezzo_fornitore != null ? prodotto.prezzo_fornitore!.toStringAsFixed(2) : "N/A"),
            DataGridCell<String>(columnName: 'prezzo_medio_vendita', value: prodotto.prezzo_medio_vendita != null ? prodotto.prezzo_medio_vendita!.toStringAsFixed(2) : 'N/A'),
            DataGridCell<String>(columnName: 'ultimo_costo', value: prodotto.ultimo_costo_acquisto != null ? prodotto.ultimo_costo_acquisto!.toStringAsFixed(2) : 'N/A'),
            DataGridCell<String>(columnName: 'fornitore', value: prodotto.fornitore != null ? prodotto.fornitore! : 'N/A'),
            DataGridCell<String>(columnName: 'iva', value: prodotto.iva != null ? '${prodotto.iva}%' : 'N/A')
          ]
      ));
    }
    return rows;
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row){
    final ProdottoModel prodotto = row.getCells().firstWhere(
            (cell) => cell.columnName == 'prodotto',
    ).value as ProdottoModel;
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell){
          final String columnName = dataGridCell.columnName;
          final value = dataGridCell.value;
          return GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DettaglioProdottoPage(prodotto: prodotto),
                ),
              );
            },
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(8),
              child: Text(
                value.toString(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black),
              ),
            ),
          );
        }).toList(),
    );
  }
}