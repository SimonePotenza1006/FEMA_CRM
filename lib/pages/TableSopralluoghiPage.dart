import 'dart:convert';
import 'dart:io';
import 'package:fema_crm/pages/DettaglioSopralluogoPage.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../model/ClienteModel.dart';
import '../model/SopralluogoModel.dart';
import '../model/TipologiaInterventoModel.dart';
import '../model/UtenteModel.dart';

class TableSopralluoghiPage extends StatefulWidget{
  TableSopralluoghiPage({Key? key}) : super(key:key);

  @override
  _TableSopralluoghiPageState createState() => _TableSopralluoghiPageState();
}

class _TableSopralluoghiPageState extends State<TableSopralluoghiPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  late SopralluogoDataSource _dataSource;
  List<SopralluogoModel> sopralluoghiList = [];
  List<UtenteModel> utentiList =[];
  List<TipologiaInterventoModel> tipologieList =[];
  List<ClienteModel> clientiList = [];
  List<SopralluogoModel> filteredSopralluoghiList = [];
  Map<String, double> _columnWidths ={
    'sopralluogo' : 0,
    'data' : 300,
    'cliente' : 300,
    'tipologia' : 300,
    'descrizione' : 300,
    'utente' : 300,
  };

  @override
  void initState() {
    super.initState();
    getAllSopralluoghi();
    getAllClienti();
    getAllTipologie();
    getAllUtenti();
    _dataSource = SopralluogoDataSource(context, sopralluoghiList);
  }

  Future<void> getAllClienti() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/cliente');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<ClienteModel> clienti = [];
        for(var item in jsonData){
          clienti.add(ClienteModel.fromJson(item));
        }
        setState(() {
          clientiList = clienti;
        });
      } else {
        throw Exception('Failed to load clienti data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Qualcosa non va Clienti : $e');
    }
  }

  Future<void> getAllTipologie() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/tipologiaIntervento');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<TipologiaInterventoModel> tipologie = [];

        // Converti i dati ricevuti in oggetti TipologiaInterventoModel
        for (var item in jsonData) {
          tipologie.add(TipologiaInterventoModel.fromJson(item));
        }

        // Filtro per escludere le tipologie con id 5, 6 o 7
        tipologie = tipologie.where((tipologia) {
          return !(tipologia.id == '5' || tipologia.id == '6' || tipologia.id == '7');
        }).toList();

        // Aggiorna lo stato con la lista filtrata
        setState(() {
          tipologieList = tipologie;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
    }
  }

  Future<void> getAllUtenti() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/utente');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<UtenteModel> utenti = [];
        for(var item in jsonData){
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          utentiList = utenti;
        });
      } else {
        throw Exception('Failed to load utenti data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Qualcosa non va utenti : $e');
    }
  }

  Future<void> getAllSopralluoghi() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/sopralluogo/ordered');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<SopralluogoModel> sopralluoghi = [];
        for (var item in jsonData) {
          sopralluoghi.add(SopralluogoModel.fromJson(item));
        }
        setState(() {
          sopralluoghiList = sopralluoghi;// Salva la lista originale
          filteredSopralluoghiList = sopralluoghi;
          _dataSource = SopralluogoDataSource(context, sopralluoghiList);
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Report sopralluoghi'.toUpperCase(),
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
                              color: Colors.grey[200],
                            ),
                            SizedBox(width: 3),
                            Text('INFORMATICO'),
                          ],
                        ),
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.yellow[200],
                            ),
                            SizedBox(width: 3),
                            Text('ELETTRICO'),
                          ],
                        ),
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.lightBlue[200],
                            ),
                            SizedBox(width: 3),
                            Text('IDRICO'),
                          ],
                        ),
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.pink[50],
                            ),
                            SizedBox(width: 3),
                            Text('ELETTRONICO'),
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
              color: Colors.white, onPressed: () {  },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(height: 10),
            Expanded(
                child: SfDataGrid(
                  allowTriStateSorting: true,
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
                      columnName: 'sopralluogo',
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
                          'sopralluogo',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['sopralluogo']?? double.nan,
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
                      minimumWidth: 250,
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
                        child: Text(
                          'CLIENTE',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['cliente']?? double.nan,
                      minimumWidth: 250,
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
                        child: Text(
                          'TIPOLOGIA',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['tipologia']?? double.nan,
                      minimumWidth: 250,
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
                      minimumWidth: 250,
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
                      minimumWidth: 250,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          mostraRicercaSopralluoghiDialog(
            context: context,
            utenti: utentiList,
            clienti: clientiList,
            tipologie: tipologieList,
            sopralluoghi: sopralluoghiList,
            onFiltrati: (sopralluoghiFiltrati) {
              _dataSource.updateData(sopralluoghiFiltrati);
            },
            dataSource: _dataSource,
          );
        },
        child: Icon(Icons.filter_list, color: Colors.white,),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class SopralluogoDataSource extends DataGridSource{
  List<SopralluogoModel> _sopralluoghi =[];
  List<SopralluogoModel> _originalSopralluoghi = [];
  BuildContext context;

  SopralluogoDataSource(this.context, List<SopralluogoModel> sopralluoghi){
    _sopralluoghi = sopralluoghi;
    _originalSopralluoghi = List.from(sopralluoghi);
  }

  void resetData(){
    _sopralluoghi = List.from(_originalSopralluoghi);
    notifyListeners();
  }

  void updateData(List<SopralluogoModel> sopralluoghi){
    _sopralluoghi.clear();
    _sopralluoghi.addAll(sopralluoghi);
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows{
    List<DataGridRow> rows = [];
    for(int i = 0; i < _sopralluoghi.length; i++){
      SopralluogoModel sopralluogo = _sopralluoghi[i];
      String? descrizione = sopralluogo.descrizione != null ? sopralluogo.descrizione! : "N/A";
      String? formattedData = sopralluogo.data != null ? DateFormat('dd/MM/yyyy').format(sopralluogo.data!) : "//";
      String? utente = sopralluogo.utente != null ? sopralluogo.utente!.nomeCompleto() : 'N/A';
      String? tipologia = sopralluogo.tipologia != null ? sopralluogo.tipologia?.descrizione! : "N/A";
      String? cliente = sopralluogo.cliente != null ? sopralluogo.cliente?.denominazione! : 'N/A';
      rows.add(DataGridRow(cells: [
        DataGridCell<SopralluogoModel?>(columnName: 'sopralluogo' , value:sopralluogo),
        DataGridCell<String?>(columnName: 'data', value:formattedData),
        DataGridCell<String?>(columnName: 'cliente', value: cliente),
        DataGridCell<String?>(columnName: 'tipologia', value: tipologia),
        DataGridCell<String?>(columnName: 'descrizione', value: descrizione),
        DataGridCell<String?>(columnName: 'utente', value: utente),
      ])
      );
    }
    return rows;
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row){
    final SopralluogoModel sopralluogo = row.getCells().firstWhere((cell) => cell.columnName == 'sopralluogo').value;
    Color? backgroundColor;
    switch (sopralluogo.tipologia?.descrizione) {
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
      default:
        backgroundColor = Colors.white;
    }
    return DataGridRowAdapter(
        color: backgroundColor,
        cells: row.getCells().map<Widget>((dataGridCell){
          final String columnName = dataGridCell.columnName;
          final value = dataGridCell.value;

          Color textColor = Colors.black;
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DettaglioSopralluogoPage(sopralluogo: sopralluogo),
                ),
              );
            },
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(8),
              child: Text(
                value.toString(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: textColor),
              ),
            ),
          );
        }).toList()
    );
  }
}

void mostraRicercaSopralluoghiDialog({
  required BuildContext context,
  required List<UtenteModel> utenti,
  required List<ClienteModel> clienti,
  required List<TipologiaInterventoModel> tipologie,
  required List<SopralluogoModel> sopralluoghi,
  required Function(List<SopralluogoModel>) onFiltrati,
  required SopralluogoDataSource dataSource,
}) {
  DateTime? startDate;
  DateTime? endDate;
  UtenteModel? selectedUtente;
  ClienteModel? selectedCliente;
  TipologiaInterventoModel? selectedTipologia;
  List<ClienteModel> clientiFiltrati = [];
  TextEditingController _clienteController = TextEditingController();

  List<SopralluogoModel> filtraPerUtente(List<SopralluogoModel> sopralluoghi, UtenteModel utente) {
    return sopralluoghi.where((sopralluoghi) => sopralluoghi.utente?.id == utente.id).toList();
  }

  List<SopralluogoModel> filtraPerCliente(List<SopralluogoModel> sopralluoghi, ClienteModel cliente) {
    return sopralluoghi.where((sopralluoghi) => sopralluoghi.cliente?.id == cliente.id).toList();
  }

  List<SopralluogoModel> filtraPerTipologia(List<SopralluogoModel> sopralluoghi, TipologiaInterventoModel tipologia) {
    return sopralluoghi.where((sopralluoghi) => sopralluoghi.tipologia?.id == tipologia.id).toList();
  }

  List<SopralluogoModel> filtraPerData(List<SopralluogoModel> sopralluoghi, DateTime data) {
    return sopralluoghi.where((sopralluoghi) => sopralluoghi.data?.isAtSameMomentAs(data) ?? false).toList();
  }

  List<SopralluogoModel> filtraPerUtenteEIntervalloDate(List<SopralluogoModel> sopralluoghi, UtenteModel utente, DateTime startDate, DateTime endDate) {
    return sopralluoghi.where((sopralluoghi) {
      return sopralluoghi.utente?.id == utente.id &&
          sopralluoghi.data != null &&
          sopralluoghi.data!.isAfter(startDate) &&
          sopralluoghi.data!.isBefore(endDate);
    }).toList();
  }
  List<SopralluogoModel> filtraConclusiPerUtenteEIntervalloDate(List<SopralluogoModel> sopralluoghi, UtenteModel utente, DateTime startDate, DateTime endDate) {
    return sopralluoghi.where((sopralluoghi) {
      return sopralluoghi.utente?.id == utente.id &&
          sopralluoghi.data != null &&
          sopralluoghi.data!.isAfter(startDate) &&
          sopralluoghi.data!.isBefore(endDate);
    }).toList();
  }
  List<SopralluogoModel> filtraPerUtenteClienteEIntervalloDate(List<SopralluogoModel> sopralluoghi, UtenteModel utente, ClienteModel cliente, DateTime startDate, DateTime endDate) {
    return sopralluoghi.where((intervento) {
      return intervento.utente?.id == utente.id &&
          intervento.cliente?.id == cliente.id &&
          intervento.data != null &&
          intervento.data!.isAfter(startDate) &&
          intervento.data!.isBefore(endDate);
    }).toList();
  }

  List<SopralluogoModel> filtraPerUtenteClienteTipologiaEIntervalloDate(
      List<SopralluogoModel> sopralluoghi,
      UtenteModel utente,
      ClienteModel cliente,
      TipologiaInterventoModel tipologia,
      DateTime startDate,
      DateTime endDate
      ) {
    return sopralluoghi.where((sopralluoghi) {
      return sopralluoghi.utente?.id == utente.id &&
          sopralluoghi.cliente?.id == cliente.id &&
          sopralluoghi.tipologia?.id == tipologia.id &&
          sopralluoghi.data != null &&
          sopralluoghi.data!.isAfter(startDate) &&
          sopralluoghi.data!.isBefore(endDate);
    }).toList();
  }

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Cerca Interventi'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                startDate = pickedDate;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(labelText: 'Data Inizio'),
                            child: Text(startDate == null
                                ? 'Seleziona'
                                : DateFormat('dd/MM/yyyy').format(startDate!)),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                endDate = pickedDate;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(labelText: 'Data Fine'),
                            child: Text(endDate == null
                                ? 'Seleziona'
                                : DateFormat('dd/MM/yyyy').format(endDate!)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<UtenteModel>(
                    decoration: InputDecoration(labelText: 'Seleziona Utente'),
                    value: selectedUtente,
                    items: utenti.map((utente) {
                      return DropdownMenuItem(
                        value: utente,
                        child: Text(utente.nomeCompleto()!),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedUtente = val;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _clienteController,
                    decoration: InputDecoration(labelText: 'Cerca Cliente per denominazione, indirizzo, numero di telefono, etc.'),
                    onChanged: (query) {
                      setState(() {
                        clientiFiltrati = clienti
                            .where((cliente) {
                          return (cliente.denominazione != null && cliente.denominazione!.toLowerCase().contains(query.toLowerCase())) ||
                              (cliente.cellulare != null && cliente.cellulare!.toLowerCase().contains(query.toLowerCase())) ||
                              (cliente.telefono != null && cliente.telefono!.toLowerCase().contains(query.toLowerCase())) ||
                              (cliente.citta != null && cliente.citta!.toLowerCase().contains(query.toLowerCase())) ||
                              (cliente.codice_fiscale != null && cliente.codice_fiscale!.toLowerCase().contains(query.toLowerCase())) ||
                              (cliente.partita_iva != null && cliente.partita_iva!.toLowerCase().contains(query.toLowerCase())) ||
                              (cliente.fax != null && cliente.fax!.toLowerCase().contains(query.toLowerCase())) ||
                              (cliente.email != null && cliente.email!.toLowerCase().contains(query.toLowerCase()));
                        }).toList();
                      });
                    },
                  ),
                  if (clientiFiltrati.isNotEmpty)
                    Container(
                      constraints: BoxConstraints(maxHeight: 200), // Adjust as needed
                      child: ListView.builder(
                        itemCount: clientiFiltrati.length > 5 ? 5 : clientiFiltrati.length,
                        itemBuilder: (context, index) {
                          ClienteModel cliente = clientiFiltrati[index];
                          return ListTile(
                            title: Text(cliente.denominazione!),
                            onTap: () {
                              setState(() {
                                selectedCliente = cliente;
                                _clienteController.text = cliente.denominazione!; // Update the text of the controller
                                clientiFiltrati = [];
                              });
                            },
                          );
                        },
                      ),
                    ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<TipologiaInterventoModel>(
                    decoration: InputDecoration(labelText: 'Seleziona Tipologia'),
                    value: selectedTipologia,
                    items: tipologie.map((tipologia) {
                      return DropdownMenuItem(
                        value: tipologia,
                        child: Text(tipologia.descrizione!),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedTipologia = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Annulla'),
              ),
              TextButton(
                onPressed: () {
                  dataSource.resetData();  // Reset della lista delle spese
                  dataSource.updateData(dataSource._originalSopralluoghi);
                  // Passa le spese originali alla funzione di callback
                  Navigator.of(context).pop();  // Chiudi il dialog
                },
                child: Text('Reset Filtri'),
              ),
              ElevatedButton(
                onPressed: () {
                  List<SopralluogoModel> sopralluoghiFiltrati = sopralluoghi;
                  if (selectedUtente != null) {
                    sopralluoghiFiltrati = filtraPerUtente(sopralluoghiFiltrati, selectedUtente!);
                  }
                  if (selectedCliente != null) {
                    sopralluoghiFiltrati = filtraPerCliente(sopralluoghiFiltrati, selectedCliente!);
                  }
                  if (selectedTipologia != null) {
                    sopralluoghiFiltrati = filtraPerTipologia(sopralluoghiFiltrati, selectedTipologia!);
                  }
                  if (startDate != null && endDate != null) {
                    if (selectedUtente != null && selectedCliente != null && selectedTipologia != null) {
                      sopralluoghiFiltrati = filtraPerUtenteClienteTipologiaEIntervalloDate(
                          sopralluoghiFiltrati,
                          selectedUtente!,
                          selectedCliente!,
                          selectedTipologia!,
                          startDate!,
                          endDate!
                      );
                    } else if (selectedUtente != null && selectedCliente != null) {
                      sopralluoghiFiltrati = filtraPerUtenteClienteEIntervalloDate(
                          sopralluoghiFiltrati,
                          selectedUtente!,
                          selectedCliente!,
                          startDate!,
                          endDate!
                      );
                    } else if (selectedUtente != null) {
                      sopralluoghiFiltrati = filtraPerUtenteEIntervalloDate(
                          sopralluoghiFiltrati,
                          selectedUtente!,
                          startDate!,
                          endDate!
                      );
                    } else {
                      sopralluoghiFiltrati = sopralluoghiFiltrati.where((sopralluogo) {
                        return sopralluogo.data != null &&
                            sopralluogo.data!.isAfter(startDate!) &&
                            sopralluogo.data!.isBefore(endDate!);
                      }).toList();
                    }
                  } else if (startDate != null) {
                    sopralluoghiFiltrati = filtraPerData(sopralluoghiFiltrati, startDate!);
                  } else if (endDate != null) {
                    sopralluoghiFiltrati = filtraPerData(sopralluoghiFiltrati, endDate!);
                  }
                  onFiltrati(sopralluoghiFiltrati);
                  Navigator.of(context).pop();
                },
                child: Text('Cerca'),
              )
            ],
          );
        },
      );
    },
  );


}