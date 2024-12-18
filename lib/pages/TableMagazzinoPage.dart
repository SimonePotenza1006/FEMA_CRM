import 'dart:convert';
import 'package:fema_crm/pages/DettaglioProdottoPage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../model/ProdottoModel.dart';

class TableMagazzinoPage extends StatefulWidget{
  TableMagazzinoPage({Key? key}) : super(key:key);

  @override
  _TableMagazzinoPageState createState() => _TableMagazzinoPageState();
}

class _TableMagazzinoPageState extends State<TableMagazzinoPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';
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
    'iva' : 100,
    'lotto_seriale' : 200
  };
  int _rowsPerPage = 20; // Definisce il numero di righe per pagina
  int _pageCount = 0;
  bool isSearching = false;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    _dataSource = ProdottoDataSource(context, _filteredProdotti,_rowsPerPage);
    getProdotti();
  }

  void startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Cerca prodotti...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white54),
      ),
      style: TextStyle(color: Colors.white),
      onChanged: filterProdotti,
    );
  }

  List<Widget> _buildActions() {
    if (isSearching) {
      return [
        IconButton(
          icon: Icon(Icons.clear, color: Colors.white),
          onPressed: () {
            stopSearch();
          },
        ),
      ];
    } else {
      return [
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: () {
            startSearch();
          },
        ),
      ];
    }
  }

  void filterProdotti(String query) {
    print('Filtering products with query: $query');

    setState(() {
      _dataSource.applyFilter(query);
      _pageCount = (_dataSource.filteredProducts.length / _rowsPerPage).ceil(); // Assicurati che il page count sia corretto
      print('Filtered products count: ${_dataSource.filteredProducts.length}');
      print('Updated page count: $_pageCount');
    });
  }


  void stopSearch() {
    setState(() {
      isSearching = false;
      searchController.clear();
      _dataSource.applyFilter(''); // Ripristina tutti i prodotti rimuovendo il filtro
    });
  }


  Future<void> getProdotti() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/prodotto');
      print('Fetching products from: $apiUrl');

      var response = await http.get(apiUrl);

      if(response.statusCode == 200){
        print('API call successful, status code: ${response.statusCode}');

        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<ProdottoModel> prodotti = [];
        for(var item in jsonData){
          prodotti.add(ProdottoModel.fromJson(item));
        }

        setState(() {
          _allProdotti = prodotti;
          _filteredProdotti = prodotti;
          _dataSource = ProdottoDataSource(context, _filteredProdotti, _rowsPerPage);
          _pageCount = (_allProdotti.length / _rowsPerPage).ceil();
          print('Total products loaded: ${_allProdotti.length}');
          print('Page count set to: $_pageCount');
        });
      } else {
        print('API call failed, status code: ${response.statusCode}');
      }
    }catch(e){
      print('Error fetching products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching ? _buildSearchField() : Text('MAGAZZINO', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions:
          _buildActions(),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(height: 10),
            // Usa Flexible per far sì che la tabella prenda tutto lo spazio disponibile.
            Flexible(
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
                    width: _columnWidths['prodotto'] ?? double.nan,
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
                    width: _columnWidths['codice_danea'] ?? double.nan,
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
                    width: _columnWidths['descrizione'] ?? double.nan,
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
                    width: _columnWidths['unita_misura'] ?? double.nan,
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
                    width: _columnWidths['prezzo_fornitore'] ?? double.nan,
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
                    width: _columnWidths['prezzo_medio_vendita'] ?? double.nan,
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
                    width: _columnWidths['ultimo_costo'] ?? double.nan,
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
                    width: _columnWidths['fornitore'] ?? double.nan,
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
                    width: _columnWidths['iva'] ?? double.nan,
                    minimumWidth: 0,
                  ),
                  GridColumn(
                    columnName: 'lotto_seriale',
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
                        'Lotto/Seriale'.toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['lotto_seriale'] ?? double.nan,
                    minimumWidth: 0,
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
            // Posiziona il SfDataPager in basso sotto la tabella
            if(_pageCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SfDataPagerTheme(
                  data: SfDataPagerThemeData(
                    itemColor: Colors.red,
                    selectedItemColor: Colors.red.shade200,
                    itemTextStyle: TextStyle(color: Colors.white),
                  ),
                  child: SfDataPager(
                    delegate: _dataSource,
                    pageCount: _pageCount.toDouble(),
                    direction: Axis.horizontal,
                  )
                ),
              ),
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
  int rowsPerPage;
  List<ProdottoModel> paginatedProducts = [];

  void applyFilter(String query) {
    print("Filtering products with query: $query");
    if (query.isEmpty) {
      filteredProducts = List.from(_products); // Ripristina tutti i prodotti
    } else {
      filteredProducts = _products.where((prodotto) {
        final descrizione = prodotto.descrizione?.toLowerCase() ?? '';
        final codProdForn = prodotto.cod_prod_forn?.toLowerCase() ?? '';
        final codiceDanea = prodotto.codice_danea?.toLowerCase() ?? '';
        final lottoSeriale = prodotto.lotto_seriale?.toLowerCase() ?? '';
        final categoria = prodotto.categoria?.toUpperCase() ?? '';

        return descrizione.contains(query.toLowerCase()) ||
            codProdForn.contains(query.toLowerCase()) ||
            codiceDanea.contains(query.toLowerCase()) ||
            lottoSeriale.contains(query.toLowerCase()) ||
            categoria.contains(query.toUpperCase());
      }).toList();
    }

    // Aggiorna i prodotti paginati dopo il filtraggio
    paginatedProducts = filteredProducts.take(rowsPerPage).toList();
    print("Filtered products count: ${filteredProducts.length}");

    // Aggiorna il numero di pagine in base ai prodotti filtrati
    final newPageCount = (filteredProducts.length / rowsPerPage).ceil();
    print("Updated page count: $newPageCount");

    // Aggiorna la paginazione
    notifyListeners();
  }





  ProdottoDataSource(this.context, List<ProdottoModel> products, this.rowsPerPage){
    _products = List.from(products);
    filteredProducts = List.from(products);
    paginatedProducts = _products.take(rowsPerPage).toList();
  }

  void updateData(List<ProdottoModel> prodotti){
    _products.clear();
    _products.addAll(prodotti);
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows => paginatedProducts.map<DataGridRow>((prodotto) {
    return DataGridRow(cells: [
      DataGridCell<ProdottoModel>(columnName: 'prodotto', value: prodotto),
      DataGridCell<String>(columnName: 'codice_danea', value: prodotto.codice_danea ?? 'N/A'),
      DataGridCell<String>(columnName: 'descrizione', value: prodotto.descrizione ?? "N/A"),
      DataGridCell<String>(columnName: 'unita_misura', value: prodotto.unita_misura ?? "N/A"),
      DataGridCell<String>(columnName: 'prezzo_fornitore', value: prodotto.prezzo_fornitore?.toStringAsFixed(2) ?? "N/A"),
      DataGridCell<String>(columnName: 'prezzo_medio_vendita', value: prodotto.prezzo_medio_vendita?.toStringAsFixed(2) ?? 'N/A'),
      DataGridCell<String>(columnName: 'ultimo_costo', value: prodotto.ultimo_costo_acquisto?.toStringAsFixed(2) ?? 'N/A'),
      DataGridCell<String>(columnName: 'fornitore', value: prodotto.fornitore ?? 'N/A'),
      DataGridCell<String>(columnName: 'iva', value: prodotto.iva != null ? '${prodotto.iva}%' : 'N/A'),
      DataGridCell<String>(columnName: 'lotto_seriale', value: prodotto.lotto_seriale != null ? prodotto.lotto_seriale! : "N/A")
    ]);
  }).toList();

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final ProdottoModel prodotto = row.getCells().firstWhere(
          (cell) => cell.columnName == 'prodotto',
    ).value as ProdottoModel;
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        final value = dataGridCell.value;
        return GestureDetector(
          onTap: () {
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

  @override
  Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
    final int startIndex = newPageIndex * rowsPerPage;
    final int endIndex = startIndex + rowsPerPage;

    print('Changing page from $oldPageIndex to $newPageIndex');
    print('Paginating filtered products from $startIndex to ${endIndex > filteredProducts.length ? filteredProducts.length : endIndex}');

    if (startIndex < filteredProducts.length) {
      paginatedProducts = filteredProducts.getRange(
          startIndex,
          endIndex > filteredProducts.length ? filteredProducts.length : endIndex
      ).toList();
      notifyListeners();
    } else {
      print('Invalid page change, startIndex out of range.');
    }
    return true;
  }
}