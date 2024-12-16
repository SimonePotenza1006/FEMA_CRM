import 'dart:convert';
import 'dart:io';
import 'package:fema_crm/model/TipologiaInterventoModel.dart';
import 'package:fema_crm/pages/DettaglioInterventoNewPage.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
import '../model/ClienteModel.dart';
import '../model/GruppoInterventiModel.dart';
import '../model/InterventoModel.dart';
import '../model/RelazioneUtentiInterventiModel.dart';
import '../model/TicketModel.dart';
import '../model/UtenteModel.dart';
import 'CreazioneInterventoByAmministrazionePage.dart';
import 'DettaglioTicketPage.dart';
import 'CreazioneTicketTecnicoPage.dart';

class TableTicketPage extends StatefulWidget{
  final UtenteModel utente;

  TableTicketPage({Key? key, required this.utente}) : super(key : key);

  @override
  _TableTicketPageState createState() => _TableTicketPageState();
}

class _TableTicketPageState extends State<TableTicketPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  List<TicketModel> _allTickets =[];
  List<TicketModel> _filteredTickets = [];
  late TicketDataSource _dataSource;
  Map<String, double> _columnWidths = {
    'ticket' : 0,
    'id' : 50,
    'data_apertura' : 200,
    'descrizione' : 370,
    'utente' : 230,
    'convertito' : 140,
    //'tipologia' : 200,
  };
  bool isLoading = true;
  int _currentSheet = 0;

  Future<void> getAllTickets() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/ticket');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<TicketModel> tickets = [];
        for(var item in jsonData){
          tickets.add(TicketModel.fromJson(item));
        }
        setState(() {
          isLoading = false;
          _allTickets = tickets;
          _filteredTickets = _allTickets
              .where((ticket) => ticket.convertito != true).toList();
          _dataSource = TicketDataSource(widget.utente,context, _filteredTickets);
          _dataSource.updateData(_filteredTickets);
        });
      } else {
        isLoading = false;
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

  Future<void> _refreshData() async {
    /*setState(() {
      isLoading = true;
    });*/

    // Simula un caricamento dei dati
    await Future.delayed(Duration(seconds: 2));

    // Qui dovresti aggiornare il tuo DataSource con i nuovi dati
    //_dataSource.updateData();
    getAllTickets();

    /*setState(() {
      isLoading = false;
    });*/
  }

  @override
  void initState(){
    super.initState();
    _dataSource = TicketDataSource(widget.utente, context, _filteredTickets);
    getAllTickets();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('LISTA TICKET', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreazioneTicketTecnicoPage(utente: widget.utente,)));
            },
          ),
          IconButton(
            icon: Icon(
              Icons.refresh, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
              color: Colors.white,
            ),
            onPressed: () {
              getAllTickets();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(height: 10),
            Expanded(child: RefreshIndicator(
                onRefresh: _refreshData,
                child: isLoading ? Center(child: CircularProgressIndicator()) :
              SfDataGrid(
                  //allowPullToRefresh: true,
                  allowSorting: true,
                  allowMultiColumnSorting: true,
                  source: _dataSource,
                  columnWidthMode: ColumnWidthMode.auto,
                  allowColumnsResizing: true,
                  isScrollbarAlwaysShown: true,
                  rowHeight: 40,
                  gridLinesVisibility: GridLinesVisibility.both,
                  headerGridLinesVisibility: GridLinesVisibility.both,
                  columns: [
                    GridColumn(
                      columnName: 'ticket',
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
                          'ticket',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['ticket']?? double.nan,
                      minimumWidth: 0,
                    ),
                    GridColumn(
                      columnName: 'id',
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
                        child: Text('ID'),
                      ),
                      width: _columnWidths['id']?? double.nan,
                      minimumWidth: 100,
                    ),
                    GridColumn(
                      columnName: 'data_apertura',
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
                        child: Text('APERTURA'),
                      ),
                      width: _columnWidths['data_apertura']?? double.nan,
                      minimumWidth: 100,
                    ),
                    GridColumn(
                      columnName: 'convertito',
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
                        child: Text('CONVERTITO'),
                      ),
                      width: _columnWidths['convertito']?? double.nan,
                      minimumWidth: 140,
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
                        child: Text('TITOLO'),
                      ),
                      width: _columnWidths['descrizione']?? double.nan,
                      minimumWidth: 330,
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
                        child: Text('UTENTE'),
                      ),
                      width: _columnWidths['utente']?? double.nan,
                      minimumWidth: 100,
                    ),
                  ],
                onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                  setState(() {
                    _columnWidths[details.column.columnName] = details.width;
                  });
                  return true;
                },
              ))
            ),
            Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                  child: Container(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 5),
                          ElevatedButton(
                            onPressed: () => _changeSheet(0),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black, backgroundColor: _currentSheet == 0 ? Colors.red[300] : Colors.grey[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              elevation: 2.0,
                            ),
                            child: Text('Non convertiti', style: TextStyle(color: Colors.white)),
                          ),
                          SizedBox(width: 5),
                          ElevatedButton(
                            onPressed: () => _changeSheet(1),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black, backgroundColor: _currentSheet == 1 ? Colors.red[300] : Colors.grey[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              elevation: 2.0,
                            ),
                            child: Text('Convertiti', style: TextStyle(color: Colors.white)),
                          ),

                        ],
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _changeSheet(int index) {
    setState(() {
      _currentSheet = index;
      switch (index) {
        case 0:
          _filteredTickets = _allTickets
              .where((ticket) => ticket.convertito != true)
              .toList();
          break;
        case 1:
          _filteredTickets= _allTickets.where((ticket) => ticket.convertito == true).toList();
          break;
      }
      _dataSource.updateData(_filteredTickets);
    });
  }

  List<TicketModel> _getInterventiPerSheet(int sheetIndex) {
    switch (sheetIndex) {
      case 0:
        return _allTickets.where((ticket) => ticket.convertito != true).toList();
      case 1:
        return _allTickets.where((ticket) => ticket.convertito == true).toList();
      default:
        return _allTickets.where((ticket) => ticket.convertito != true).toList();
    }
  }
}

class TicketDataSource extends DataGridSource{
  BuildContext context;
  UtenteModel utente;
  List<TicketModel> _tickets = [];
  List<TicketModel> _filteredTickets = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';

  TicketDataSource(
      this.utente,
      this.context,
      List<TicketModel> tickets,
      ){
    _tickets = List.from(tickets);
    _filteredTickets = List.from(tickets);
  }

  void updateData(List<TicketModel> newTickets) {
    _tickets.clear();
    _tickets.addAll(newTickets);
    _filteredTickets = List.from(newTickets);  // Aggiorna anche la lista filtrata
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows{
    List<DataGridRow> rows = [];
    for (int i = 0; i < _filteredTickets.length; i++) {
      TicketModel ticket = _filteredTickets[i];
      String? stato = ticket.convertito == true ? "SI" : "NO";
      //String? tipologia = ticket.tipologia?.descrizione.toString();
      rows.add(DataGridRow(
        cells: [
          DataGridCell<TicketModel>(columnName: 'ticket', value: ticket),
          DataGridCell<String>(
            columnName: 'id',
            value: ticket.id,
          ),
          DataGridCell<String>(
              columnName: 'data_apertura',
              value: DateFormat('dd/MM/yyyy').format(ticket.data_creazione!)
          ),
          DataGridCell<String>(
              columnName: 'convertito',
              value: stato
          ),
          DataGridCell<String>(
              columnName: 'descrizione',
              value: ticket.descrizione,
          ),
          DataGridCell<String>(
              columnName: 'utente',
              value: ticket.utente!.nomeCompleto()
          ),
        ]
      ));
    }
    return rows;
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    // Ottieni il modello del ticket
    final TicketModel ticket = row.getCells().firstWhere(
            (cell) => cell.columnName == 'ticket').value as TicketModel;

    // Colori per righe pari e dispari
    Color backgroundColor = Colors.white;
    Color backgroundColor2 = Colors.grey.shade200;

    // Calcolo del colore
    final rowColor = (int.parse(ticket.id!) % 2 == 0) ? backgroundColor : backgroundColor2;

    // Debug temporaneo
    print('ID del ticket: ${ticket.id}, Colore assegnato: $rowColor');

    // Ritorna il DataGridRowAdapter
    return DataGridRowAdapter(
      color: rowColor,
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.columnName == 'ticket') {
          return SizedBox.shrink(); // La cella è invisibile
        } else {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DettaglioTicketPage(ticket: ticket, utente: utente),
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