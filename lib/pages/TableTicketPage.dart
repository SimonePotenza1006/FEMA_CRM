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
import 'ListaClientiPage.dart';
import 'DettaglioInterventoPage.dart';

class TableTicketPage extends StatefulWidget{
  TableTicketPage({Key? key}) : super(key : key);

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
    'data_apertura' : 200,
    'priorita' : 60,
    'cliente' : 200,
    'data' : 200,
    'orario' : 150,
    'titolo' : 150,
    'utente' : 230,
    'convertito' : 100,
    'tipologia' : 200,
  };
  bool isLoading = true;

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
          _filteredTickets = tickets;
          _dataSource = TicketDataSource(context, _filteredTickets);
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

  @override
  void initState(){
    super.initState();
    _dataSource = TicketDataSource(context, _filteredTickets);
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
            Expanded(child: isLoading ? Center(child: CircularProgressIndicator()) :
              SfDataGrid(
                  allowPullToRefresh: true,
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
                      columnName: 'priorita',
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
                        child: Text('PR'),
                      ),
                      width: _columnWidths['priorita']?? double.nan,
                      minimumWidth: 45,
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
                      minimumWidth: 100,
                    ),
                    GridColumn(
                      columnName: 'cliente',
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
                        child: Text('CLIENTE'),
                      ),
                      width: _columnWidths['cliente']?? double.nan,
                      minimumWidth: 100,
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
                        child: Text('DATA'),
                      ),
                      width: _columnWidths['data']?? double.nan,
                      minimumWidth: 100,
                    ),
                    GridColumn(
                      columnName: 'orario',
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
                        child: Text('ORARIO'),
                      ),
                      width: _columnWidths['orario']?? double.nan,
                      minimumWidth: 100,
                    ),
                    GridColumn(
                      columnName: 'titolo',
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
                      width: _columnWidths['titolo']?? double.nan,
                      minimumWidth: 100,
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
                    GridColumn(
                      columnName: 'tipologia',
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
                        child: Text('TIPOLOGIA'),
                      ),
                      width: _columnWidths['tipologia']?? double.nan,
                      minimumWidth: 100,
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

class TicketDataSource extends DataGridSource{
  BuildContext context;
  List<TicketModel> _tickets = [];
  List<TicketModel> _filteredTickets = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';

  TicketDataSource(
      this.context,
      List<TicketModel> tickets,
      ){
    _tickets = List.from(tickets);
    _filteredTickets = List.from(tickets);
  }

  @override
  List<DataGridRow> get rows{
    List<DataGridRow> rows = [];
    for (int i = 0; i < _filteredTickets.length; i++) {
      TicketModel ticket = _filteredTickets[i];
      String? stato = ticket.convertito == true ? "SI" : "NO";
      String? cliente = ticket.cliente?.denominazione.toString();
      String? tipologia = ticket.tipologia?.descrizione.toString();
      rows.add(DataGridRow(
        cells: [
          DataGridCell<TicketModel>(columnName: 'ticket', value: ticket),
          DataGridCell<String>(
              columnName: 'data_apertura',
              value: DateFormat('dd/MM/yyyy').format(ticket.data_creazione!)
          ),
          DataGridCell<Priorita>(
            columnName: 'priorita',
            value : ticket.priorita,
          ),
          DataGridCell<String>(
              columnName: 'convertito',
              value: stato
          ),
          DataGridCell<String>(
            columnName: 'cliente',
            value : cliente,
          ),
          DataGridCell<String>(
              columnName: 'data',
              value: ticket.data != null ? DateFormat('dd/MM/yyyy').format(ticket.data!) : "N/A"
          ),
          DataGridCell<String>(
              columnName: 'data_apertura',
              value: ticket.orario_appuntamento != null ? DateFormat('HH:mm').format(ticket.orario_appuntamento!) : "N/A"
          ),
          DataGridCell<String>(
              columnName: 'titolo',
              value: ticket.titolo,
          ),
          DataGridCell<String>(
              columnName: 'utente',
              value: ticket.utente!.nomeCompleto()
          ),
          DataGridCell<String>(
            columnName: 'tipologia',
            value: ticket.tipologia?.descrizione ?? '',//int.parse(intervento.tipologia!.id.toString()),
          ),
        ]
      ));
    }
    return rows;
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row){
    final TicketModel ticket = row.getCells().firstWhere(
            (cell) => cell.columnName == 'ticket').value as TicketModel;
    Color? prioritaColor;
    Color? backgroundColor;
    switch (ticket.tipologia?.descrizione) {
      case 'Informatico':
        backgroundColor = Colors.grey[200]; // grigio chiaro
        break;
      case 'Elettrico':
        backgroundColor = Colors.yellow[200]; // giallo chiaro
        break;
      case 'Idrico':
        backgroundColor = Colors.lightBlue[200]; // azzurro chiaro
        break;
      case 'Elettronico':
        backgroundColor = Colors.pink[50]; // rosa chiarissimo
        break;
      case 'Riparazione Merce':
        backgroundColor = Colors.green[100]; // verde chiarissimo
        break;
      default:
        backgroundColor = Colors.white;
    }

    switch (ticket.priorita) {
      case Priorita.BASSA :
        prioritaColor = Colors.lightGreen;
        break;
      case Priorita.MEDIA :
        prioritaColor = Colors.yellow; // grigio chiaro
        break;
      case Priorita.ALTA:
        prioritaColor = Colors.orange; // giallo chiaro
        break;
      case Priorita.URGENTE:
        prioritaColor = Colors.red; // azzurro chiaro
        break;
      default:
        prioritaColor = Colors.blueGrey[200];
    }

    return DataGridRowAdapter(
        color: backgroundColor,
        cells: row.getCells().map<Widget>((dataGridCell) {
          if (dataGridCell.columnName == 'ticket') {
            return SizedBox.shrink(); // La cella sarà invisibile ma presente
          }
          if( dataGridCell.columnName == 'priorita'){
            return Container(
              color: prioritaColor,
            );
          } else{
            return GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DettaglioTicketPage(ticket: ticket),
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
      }
    ).toList(),
    );
  }
}