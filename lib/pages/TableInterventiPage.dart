import 'dart:convert';
import 'package:fema_crm/model/TipologiaInterventoModel.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
import '../model/ClienteModel.dart';
import '../model/GruppoInterventiModel.dart';
import '../model/InterventoModel.dart';
import '../model/RelazioneUtentiInterventiModel.dart';
import '../model/UtenteModel.dart';
import 'CreazioneInterventoByAmministrazionePage.dart';
import 'ListaClientiPage.dart';
import 'DettaglioInterventoPage.dart';

class TableInterventiPage extends StatefulWidget {
  TableInterventiPage({Key? key}) : super(key: key);

  @override
  _TableInterventiPageState createState() => _TableInterventiPageState();
}

class _TableInterventiPageState extends State<TableInterventiPage> {
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  List<InterventoModel> _allInterventi = [];
  List<InterventoModel> _filteredInterventi = [];
  List<ClienteModel> clientiList = [];
  List<TipologiaInterventoModel> tipologieList = [];
  List<UtenteModel> utentiList = [];
  DateTime? _startDate;
  DateTime? _endDate;
  UtenteModel? _selectedUtente;
  ClienteModel? _selecedCliente;
  TipologiaInterventoModel? _selectedTipologia;
  TextEditingController importoController = TextEditingController();
  bool isSearching = false;
  int _currentSheet = 0;
  TextEditingController searchController = TextEditingController();
  List<GruppoInterventiModel> allGruppiNonConclusi = [];
  List<GruppoInterventiModel> filteredGruppi = [];
  List<GruppoInterventiModel> allGruppiConclusi = [];
  late InterventoDataSource _dataSource;
  Map<String, double> _columnWidths = {
    'intervento' : 0,
    'data_apertura_intervento': 120,
    'data': 120,
    'cliente': 200,
    'orario_appuntamento': 120,
    'descrizione': 300,
    'responsabile' : 200,
    'importo_intervento': 100,
    'acconto': 100,
    'inserimento_importo' : 100,
    'importo_restante' : 130,
    'assegna_gruppo' : 100,
  };
  Map<int, List<UtenteModel>> _interventoUtentiMap = {};

  Future<void> getAllUtenti() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/utente');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
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

  Future<void> getAllTipologie() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/tipologiaIntervento');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<TipologiaInterventoModel> tipologie = [];
        for(var item in jsonData){
          tipologie.add(TipologiaInterventoModel.fromJson(item));
        }
        setState(() {
          tipologieList = tipologie;
        });
      } else {
        throw Exception('Failed to load tipologie data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Qualcosa non va tipologie : $e');
    }
  }

  Future<void> getAllClienti() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/cliente');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
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

  Future<void> getAllGruppi() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/gruppi/ordered');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<GruppoInterventiModel> gruppiNonConclusi = [];
        List<GruppoInterventiModel> gruppiConclusi = [];
        for(var item in jsonData) {
          GruppoInterventiModel gruppo = GruppoInterventiModel.fromJson(item);
          if(gruppo.concluso == true) {
            gruppiConclusi.add(gruppo);
          } else {
            gruppiNonConclusi.add(gruppo);
          }
        }
        setState(() {
          allGruppiConclusi = gruppiConclusi;
          allGruppiNonConclusi = gruppiNonConclusi;
          filteredGruppi = gruppiNonConclusi;
        });
      } else {
        throw Exception('Failed to load gruppi data from API: ${response.statusCode}');
      }
    } catch(e) {
      print('Hai toppato chicco : $e');
    }
  }

  Future<void> getAllInterventi() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/intervento/ordered');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<InterventoModel> interventi = [];
        for (var item in jsonData) {
          interventi.add(InterventoModel.fromJson(item));
        }
        // Recuperare tutte le relazioni utenti-interventi
        Map<int, List<UtenteModel>> interventoUtentiMap = {};
        for (var intervento in interventi) {
          var relazioni = await getRelazioni(int.parse(intervento.id.toString()));
          interventoUtentiMap[int.parse(intervento.id.toString())] = relazioni.map((relazione) => relazione.utente!).toList();
        }
        setState(() {
          _allInterventi = interventi;
          _filteredInterventi = interventi.toList();
          _dataSource = InterventoDataSource(context, _filteredInterventi, interventoUtentiMap);
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during API call: $e')),
      );
    }
  }

  Future<List<RelazioneUtentiInterventiModel>> getRelazioni(int interventoId) async {
    try {
      final response = await http.get(Uri.parse('$ipaddress/api/relazioneUtentiInterventi/intervento/$interventoId'));
      var responseData = json.decode(response.body.toString());
      if (response.statusCode == 200) {
        List<RelazioneUtentiInterventiModel> relazioni = [];
        for (var relazione in responseData) {
          relazioni.add(RelazioneUtentiInterventiModel.fromJson(relazione));
        }
        return relazioni;
      } else {
        throw Exception('Errore durante il recupero degli utenti');
      }
    } catch (e) {
      throw Exception('Errore durante il recupero degli utenti: $e');
    }
  }

  void _changeSheet(int index) {
    setState(() {
      _currentSheet = index;
      switch (index) {
        case 0:
          _filteredInterventi = _allInterventi.toList();
          break;
        case 1:
          _filteredInterventi = _allInterventi.where((intervento) => !(intervento.concluso ?? false)).toList();
          break;
        case 2:
          _filteredInterventi = _allInterventi.where((intervento) => (intervento.concluso ?? false) && !(intervento.saldato ?? false)).toList();
          break;
        case 3:
          _filteredInterventi = _allInterventi.where((intervento) => (intervento.concluso ?? false) && (intervento.saldato ?? false)).toList();
          break;
        case 4:
          _filteredInterventi = _allInterventi.where((intervento) => !(intervento.concluso ?? false) && (intervento.saldato ?? false)).toList();
          break;
      }
      _dataSource.updateData(_filteredInterventi, _interventoUtentiMap);
    });
  }

  void filterInterventi(String query) {
    final lowerCaseQuery = query.toLowerCase();

    setState(() {
      _filteredInterventi = _allInterventi.where((intervento) {
        final cliente = intervento.cliente?.denominazione?.toLowerCase() ?? '';
        final indirizzo = intervento.cliente?.indirizzo?.toLowerCase() ?? '';
        final indirizzoD = intervento.destinazione?.indirizzo?.toLowerCase() ?? '';
        final citta = intervento.cliente?.citta?.toLowerCase() ?? '';
        final cittaD = intervento.destinazione?.citta?.toLowerCase() ?? '';
        final codiceFiscale = intervento.cliente?.codice_fiscale?.toLowerCase() ?? '';
        final codiceFiscaleD = intervento.destinazione?.codice_fiscale?.toLowerCase() ?? '';
        final partitaIva = intervento.cliente?.partita_iva?.toLowerCase() ?? '';
        final partitaIvaD = intervento.destinazione?.partita_iva?.toLowerCase() ?? '';
        final telefono = intervento.cliente?.telefono?.toLowerCase() ?? '';
        final telefonoD = intervento.destinazione?.telefono?.toLowerCase() ?? '';
        final cellulare = intervento.cliente?.cellulare?.toLowerCase() ?? '';
        final cellulareD = intervento.destinazione?.cellulare?.toLowerCase() ?? '';
        final tipologia = intervento.tipologia?.descrizione?.toLowerCase() ?? '';
        final descrizione = intervento.descrizione?.toLowerCase() ?? '';

        return cliente.contains(lowerCaseQuery) ||
            indirizzo.contains(lowerCaseQuery) ||
            indirizzoD.contains(lowerCaseQuery) ||
            citta.contains(lowerCaseQuery) ||
            cittaD.contains(lowerCaseQuery) ||
            codiceFiscale.contains(lowerCaseQuery) ||
            codiceFiscaleD.contains(lowerCaseQuery) ||
            partitaIva.contains(lowerCaseQuery) ||
            partitaIvaD.contains(lowerCaseQuery) ||
            telefono.contains(lowerCaseQuery) ||
            telefonoD.contains(lowerCaseQuery) ||
            cellulare.contains(lowerCaseQuery) ||
            cellulareD.contains(lowerCaseQuery) ||
            tipologia.contains(lowerCaseQuery) ||
            descrizione.contains(lowerCaseQuery);
      }).toList();
      _dataSource.updateData(_filteredInterventi, _interventoUtentiMap);
    });
  }

  @override
  void initState() {
    super.initState();
    _dataSource = InterventoDataSource(context, _filteredInterventi, {});
    getAllInterventi();
    getAllGruppi();
    getAllClienti().whenComplete(() => print('Clienti ok'));
    getAllTipologie().whenComplete(() => print('Tipologie ok'));
    getAllUtenti().whenComplete(() => print('Utenti ok'));
    _filteredInterventi = _allInterventi.toList();

    _changeSheet(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista Interventi',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt_1, size: 40, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListaClientiPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add, size: 40, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreazioneInterventoByAmministrazionePage(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.refresh, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
              color: Colors.white,
            ),
            onPressed: () {
              getAllInterventi();
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
                          'intervento',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    width: _columnWidths['intervento']?? double.nan,
                    minimumWidth: 0,
                  ),
                  GridColumn(
                    columnName: 'data_apertura_intervento',
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
                        'Data Apertura',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['data_apertura_intervento']?? double.nan,
                    minimumWidth: 100, // Imposta la larghezza minima
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
                    minimumWidth: 100, // Imposta la larghezza minima
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
                        'Cliente',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['cliente']?? double.nan,
                    minimumWidth: 150, // Imposta la larghezza minima
                  ),
                  GridColumn(
                    columnName: 'orario_appuntamento',
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
                        'Orario Appuntamento',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['orario_appuntamento']?? double.nan,
                    minimumWidth: 100, // Imposta la larghezza minima
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
                    minimumWidth: 200, // Imposta la larghezza minima
                  ),
                  GridColumn(
                    columnName: 'responsabile',
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
                        'Responsabile',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['responsabile']?? double.nan,
                    minimumWidth: 150,
                  ),
                  GridColumn(
                    columnName: 'importo_intervento',
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
                        'Importo',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['importo_intervento']?? double.nan,
                    minimumWidth: 80, // Imposta la larghezza minima
                  ),
                  GridColumn(
                    columnName: 'inserimento_importo',
                    label : Container(
                        padding: EdgeInsets.all(8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border(
                                right : BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                )
                            )
                        ),
                        child: Text(
                          'Inserimento Importo',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        )
                    ),
                    width: _columnWidths['inserimento_importo']?? double.nan,
                    minimumWidth: 80,
                  ),
                  GridColumn(
                    columnName: 'acconto',
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
                        'Acconto',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['acconto']?? double.nan,
                    minimumWidth: 80, // Imposta la larghezza minima
                  ),
                  GridColumn(
                    columnName: 'importo_restante',
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
                        'Importo restante',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['importo_restante']?? double.nan,
                    minimumWidth: 130, // Imposta la larghezza minima
                  ),
                  GridColumn(
                      columnName: 'assegna_gruppo',
                      label: Container(
                        padding: EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border(
                                right: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                )
                            )
                        ),
                        child: Text(
                          'Seleziona Gruppo',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      )
                  )
                ],
                onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                  setState(() {
                    _columnWidths[details.column.columnName] = details.width;
                  });
                  return true;
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _changeSheet(0),
                  style: ElevatedButton.styleFrom(
                    primary: _currentSheet == 0 ? Colors.red[300] : Colors.grey[700], // Cambia colore di sfondo se _currentSheet è 0
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 2.0,
                  ),
                  child: Text('Tutti', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 5),
                ElevatedButton(
                  onPressed: () => _changeSheet(1),
                  style: ElevatedButton.styleFrom(
                    primary: _currentSheet == 1 ? Colors.red[300] : Colors.grey[700], // Cambia colore di sfondo se _currentSheet è 1
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 2.0,
                  ),
                  child: Text('Non conclusi', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 5),
                ElevatedButton(
                  onPressed: () => _changeSheet(2),
                  style: ElevatedButton.styleFrom(
                    primary: _currentSheet == 2 ? Colors.red[300] : Colors.grey[700], // Cambia colore di sfondo se _currentSheet è 2
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 2.0,
                  ),
                  child: Text('Conclusi non saldati', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 5),
                ElevatedButton(
                  onPressed: () => _changeSheet(3),
                  style: ElevatedButton.styleFrom(
                    primary: _currentSheet == 3 ? Colors.red[300] : Colors.grey[700],
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 2.0,
                  ),
                  child: Text('Conclusi e Saldati', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 5),
                ElevatedButton(
                  onPressed: () => _changeSheet(3),
                  style: ElevatedButton.styleFrom(
                    primary: _currentSheet == 4 ? Colors.red[300] : Colors.grey[700],
                    onPrimary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 2.0,
                  ),
                  child: Text('Non conclusi e Saldati', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          mostraRicercaInterventiDialog(
            context: context,
            utenti: utentiList,
            clienti: clientiList,
            tipologie: tipologieList,
            interventi: _allInterventi,
            onFiltrati: (interventiFiltrati) {
              _dataSource.updateData(interventiFiltrati, _interventoUtentiMap);
            },
          );
        },
        child: Icon(Icons.filter_list, color: Colors.white,),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class InterventoDataSource extends DataGridSource {
  List<InterventoModel> _interventions = [];
  Map<int, List<UtenteModel>> _interventoUtentiMap = {};
  BuildContext context;
  TextEditingController importoController = TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  GruppoInterventiModel? _selectedGruppo;
  List<GruppoInterventiModel> filteredGruppi = [];
  List<GruppoInterventiModel> allGruppiConclusi = [];
  List<GruppoInterventiModel> allGruppiNonConclusi = [];
  InterventoModel? _selectedIntervento;


  InterventoDataSource(this.context, List<InterventoModel> interventions, Map<int, List<UtenteModel>> interventoUtentiMap) {
    _interventions = interventions;
    _interventoUtentiMap = interventoUtentiMap;
  }

  void updateData(List<InterventoModel> newInterventions, Map<int, List<UtenteModel>> newInterventoUtentiMap) {
    _interventions.clear();
    _interventions.addAll(newInterventions);
    _interventoUtentiMap = newInterventoUtentiMap;
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows {
    List<DataGridRow> rows = [];
    for (int i = 0; i < _interventions.length; i++) {
      InterventoModel intervento = _interventions[i];
      Color? backgroundColor;
      switch (intervento.tipologia?.descrizione) {
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

      double? importo = intervento.importo_intervento != null ? intervento.importo_intervento : 0;
      double? acconto = intervento.acconto != null ? intervento.acconto : 0;
      double? restante_da_pagare = importo! - acconto!;

      List<UtenteModel> utenti = _interventoUtentiMap[intervento.id] ?? [];
      String utentiString = utenti.isNotEmpty ? utenti.map((utente) => utente.nomeCompleto()).join(', ') : 'NESSUNO';
      String utentiNomi = '';
      if (_interventoUtentiMap.containsKey(intervento.id)) {
        List<UtenteModel> utenti = _interventoUtentiMap[intervento.id]!;
        utentiNomi = utenti.map((utente) => utente.nomeCompleto()).join(', ');
      } else {
        utentiNomi = 'NESSUNO'; // or any other default value
      }

      rows.add(DataGridRow(
        cells: [
          DataGridCell<InterventoModel>(columnName: 'intervento', value: intervento),
          DataGridCell<String>(
            columnName: 'data_apertura_intervento',
            value: intervento.data_apertura_intervento != null
                ? DateFormat('dd/MM/yyyy').format(intervento.data_apertura_intervento!)
                : '',
          ),
          DataGridCell<String>(
            columnName: 'data',
            value: intervento.data != null
                ? DateFormat('dd/MM/yyyy').format(intervento.data!)
                : '',
          ),
          DataGridCell<String>(
            columnName: 'cliente',
            value: intervento.cliente?.denominazione ?? '',
          ),
          DataGridCell<String>(
            columnName: 'orario_appuntamento',
            value: intervento.orario_appuntamento != null
                ? DateFormat('HH:mm').format(intervento.orario_appuntamento!)
                : '',
          ),
          DataGridCell<String>(
            columnName: 'descrizione',
            value: intervento.descrizione ?? '',
          ),
          DataGridCell<String>(
            columnName: 'responsabile',
            value: intervento.utente?.nomeCompleto() ?? 'NON ASSEGNATO',
          ),
          DataGridCell<String>(
            columnName: 'importo_intervento',
            value: intervento.importo_intervento != null
                ? intervento.importo_intervento!.toStringAsFixed(2) + "€"
                : '',
          ),
          DataGridCell<Widget>(
            columnName: 'inserimento_importo',
            value: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Inserisci un importo'),
                      actions: <Widget>[
                        TextFormField(
                          controller: importoController,
                          decoration: InputDecoration(
                            labelText: 'Importo',
                            border: OutlineInputBorder(),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // consenti solo numeri e fino a 2 decimali
                          ],
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                        ),
                        TextButton(
                          onPressed: () {
                            saveImporto(intervento); // <--- Pass the intervento object here
                          },
                          child: Text('Salva importo'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.create, color: Colors.grey),
            ),
          ),
          DataGridCell<String>(
            columnName: 'acconto',
            value: intervento.acconto != null
                ? intervento.acconto!.toStringAsFixed(2) + "€"
                : '',
          ),
          DataGridCell<String>(
            columnName: 'importo_restante',
            value: restante_da_pagare.toStringAsFixed(2) + "€"
          ),
          DataGridCell<Widget>(
              columnName: 'assegna_gruppo',
              value : IconButton(
                onPressed: (){
                  TextEditingController searchController = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            title: const Text(
                              'Seleziona un gruppo di interventi',
                              textAlign: TextAlign.center,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            content: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: MediaQuery.of(context).size.height * 0.6, // Imposta un'altezza massima arbitraria
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,// Utilizza SingleChildScrollView per consentire lo scrolling
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: searchController,
                                      onChanged: (value) {
                                        setState(() {
                                          filteredGruppi = allGruppiNonConclusi
                                              .where((gruppo) =>
                                              gruppo.cliente!.denominazione!
                                                  .toLowerCase()
                                                  .contains(value.toLowerCase()))
                                              .toList();
                                        });
                                      },
                                      decoration: const InputDecoration(
                                        labelText:
                                        'Cerca gruppo tramite la denominazione del cliente',
                                        prefixIcon: Icon(Icons.search),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ListView.builder(
                                      shrinkWrap: true, // Imposta shrinkWrap a true
                                      itemCount: filteredGruppi.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          leading: Icon(Icons.folder_copy_outlined),
                                          title: Text(
                                            '${filteredGruppi[index].cliente!.denominazione!}, ${filteredGruppi[index].descrizione}',
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _selectedGruppo = filteredGruppi[index];
                                            });
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    'Confermi di aggiungere l\'intervento al gruppo: ${_selectedGruppo?.descrizione!} ?',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  content: Container(
                                                    height: 100, // Imposta un'altezza arbitraria per il contenuto
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        SizedBox(), // Spazio vuoto per spingere il testo verso l'alto
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            TextButton(
                                                              onPressed: () {
                                                                addToGruppo(_selectedIntervento!);
                                                                Navigator.of(context).pop();
                                                                Navigator.of(context).pop();
                                                              },
                                                              child: Text('Conferma'),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                icon: Icon(Icons.folder, color:Colors.grey),
              )
          )
        ],
      ));
    }
    return rows;
  }

  Future<void> addToGruppo(InterventoModel intervento) async {
    try{
      final response = await http.post(
        Uri.parse('${ipaddress}/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': intervento.id,
          'data_apertura_intervento' : DateTime.now().toIso8601String(),
          'data': intervento.data?.toIso8601String(),
          'orario_appuntamento' : intervento.orario_appuntamento?.toIso8601String(),
          'orario_inizio': intervento.orario_inizio?.toIso8601String(),
          'orario_fine': intervento.orario_fine?.toIso8601String(),
          'descrizione': intervento.descrizione,
          'importo_intervento': intervento.importo_intervento,
          'assegnato': intervento.assegnato,
          'conclusione_parziale': intervento.conclusione_parziale,
          'concluso': intervento.concluso,
          'saldato': intervento.saldato,
          'note': intervento.note,
          'relazione_tecnico' : intervento.relazione_tecnico,
          'firma_cliente': intervento.firma_cliente,
          'utente': intervento.utente?.toMap(),
          'cliente': intervento.cliente?.toMap(),
          'veicolo': intervento.veicolo?.toMap(),
          'merce': intervento.merce?.toMap(),
          'tipologia': intervento.tipologia?.toMap(),
          'categoria': intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': intervento.tipologia_pagamento?.toMap(),
          'destinazione': intervento.destinazione?.toMap(),
          'gruppo' : _selectedGruppo?.toMap(),
        }),
      );
      if (response.statusCode == 201) {
        print('EVVAIIIIIIII');
        //getAllInterventi();
        //getAllGruppi();
      }
    } catch(e){
      print('Errore durante il salvataggio del intervento: $e');
    }
  }

  Future<void> saveImporto(InterventoModel intervento) async {
    try {
      final response = await http.post(
        Uri.parse('${ipaddress}/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': intervento.id,
          'data_apertura_intervento' : intervento.data_apertura_intervento?.toIso8601String(),
          'data': intervento.data?.toIso8601String(),
          'orario_appuntamento' : intervento.orario_appuntamento?.toIso8601String(),
          'orario_inizio': intervento.orario_inizio?.toIso8601String(),
          'orario_fine': intervento.orario_fine?.toIso8601String(),
          'descrizione': intervento.descrizione,
          'importo_intervento': double.parse(importoController.text),
          'assegnato': intervento.assegnato,
          'conclusione_parziale': intervento.conclusione_parziale,
          'concluso': intervento.concluso,
          'saldato': intervento.saldato,
          'note': intervento.note,
          'relazione_tecnico' : intervento.relazione_tecnico,
          'firma_cliente': intervento.firma_cliente,
          'utente': intervento.utente?.toMap(),
          'cliente': intervento.cliente?.toMap(),
          'veicolo': intervento.veicolo?.toMap(),
          'merce': intervento.merce?.toMap(),
          'tipologia': intervento.tipologia?.toMap(),
          'categoria': intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': intervento.tipologia_pagamento?.toMap(),
          'destinazione': intervento.destinazione?.toMap(),
          'gruppo' : intervento.gruppo?.toMap()
        }),
      );
      if (response.statusCode == 201) {
        print('EVVAIIIIIIII');
        Navigator.pop(context);
      }
    } catch (e) {
      print('Errore durante il salvataggio del intervento: $e');
    }
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    // Recupera l'intervento direttamente dalla cella 'intervento'
    final InterventoModel intervento = row.getCells().firstWhere(
          (cell) => cell.columnName == 'intervento',
    ).value as InterventoModel;
    final List<UtenteModel> utenti = _interventoUtentiMap[intervento.id] ?? [];
    utenti.forEach((utente) {
    });
    // Gestione del colore di sfondo in base alla tipologia
    Color? backgroundColor;
    switch (intervento.tipologia?.descrizione) {
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

    // Get the list of users associated with the intervention

    return DataGridRowAdapter(
      color: backgroundColor,
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.columnName == 'intervento') {
          // Cella invisibile per l'oggetto InterventoModel
          return SizedBox.shrink(); // La cella sarà invisibile ma presente
        }
        if (dataGridCell.value is Widget) {
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
          if (dataGridCell.columnName == 'utenti') {
            // Cella per la colonna "Altri tecnici"
            return Container(
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
                utenti.isNotEmpty ? utenti.map((utente) => utente.nomeCompleto()).join(', ') : 'NESSUNO',
                overflow: TextOverflow.ellipsis,
              ),
            );
          } else {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DettaglioInterventoPage(intervento: intervento),
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
      }).toList(),
    );
  }
}

void mostraRicercaInterventiDialog({
  required BuildContext context,
  required List<UtenteModel> utenti,
  required List<ClienteModel> clienti,
  required List<TipologiaInterventoModel> tipologie,
  required List<InterventoModel> interventi,
  required Function(List<InterventoModel>) onFiltrati,
}) {
  DateTime? startDate;
  DateTime? endDate;
  UtenteModel? selectedUtente;
  ClienteModel? selectedCliente;
  TipologiaInterventoModel? selectedTipologia;
  List<ClienteModel> clientiFiltrati = [];
  TextEditingController _clienteController = TextEditingController();

  List<InterventoModel> filtraPerUtente(List<InterventoModel> interventi, UtenteModel utente) {
    return interventi.where((intervento) => intervento.utente?.id == utente.id).toList();
  }

  List<InterventoModel> filtraPerCliente(List<InterventoModel> interventi, ClienteModel cliente) {
    return interventi.where((intervento) => intervento.cliente?.id == cliente.id).toList();
  }

  List<InterventoModel> filtraPerTipologia(List<InterventoModel> interventi, TipologiaInterventoModel tipologia) {
    return interventi.where((intervento) => intervento.tipologia?.id == tipologia.id).toList();
  }

  List<InterventoModel> filtraPerData(List<InterventoModel> interventi, DateTime data) {
    return interventi.where((intervento) => intervento.data?.isAtSameMomentAs(data) ?? false).toList();
  }

  List<InterventoModel> filtraPerUtenteEIntervalloDate(List<InterventoModel> interventi, UtenteModel utente, DateTime startDate, DateTime endDate) {
    return interventi.where((intervento) {
      return intervento.utente?.id == utente.id &&
          intervento.data != null &&
          intervento.data!.isAfter(startDate) &&
          intervento.data!.isBefore(endDate);
    }).toList();
  }

  List<InterventoModel> filtraConclusiPerUtenteEIntervalloDate(List<InterventoModel> interventi, UtenteModel utente, DateTime startDate, DateTime endDate) {
    return interventi.where((intervento) {
      return intervento.utente?.id == utente.id &&
          intervento.data != null &&
          intervento.concluso == true &&
          intervento.data!.isAfter(startDate) &&
          intervento.data!.isBefore(endDate);
    }).toList();
  }

  List<InterventoModel> filtraPerUtenteClienteEIntervalloDate(List<InterventoModel> interventi, UtenteModel utente, ClienteModel cliente, DateTime startDate, DateTime endDate) {
    return interventi.where((intervento) {
      return intervento.utente?.id == utente.id &&
          intervento.cliente?.id == cliente.id &&
          intervento.data != null &&
          intervento.data!.isAfter(startDate) &&
          intervento.data!.isBefore(endDate);
    }).toList();
  }

  List<InterventoModel> filtraPerUtenteClienteTipologiaEIntervalloDate(
      List<InterventoModel> interventi,
      UtenteModel utente,
      ClienteModel cliente,
      TipologiaInterventoModel tipologia,
      DateTime startDate,
      DateTime endDate
      ) {
    return interventi.where((intervento) {
      return intervento.utente?.id == utente.id &&
          intervento.cliente?.id == cliente.id &&
          intervento.tipologia?.id == tipologia.id &&
          intervento.data != null &&
          intervento.data!.isAfter(startDate) &&
          intervento.data!.isBefore(endDate);
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
                            .where((cliente) => cliente.denominazione!
                            .toLowerCase()
                            .contains(query.toLowerCase()))
                            .toList();
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // background color
                  onPrimary: Colors.white, // text color
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // padding
                ),
                onPressed: () {
                  List<InterventoModel> interventiFiltrati = interventi;
                  if (selectedUtente != null) {
                    interventiFiltrati = filtraPerUtente(interventiFiltrati, selectedUtente!);
                  }
                  if (selectedCliente != null) {
                    interventiFiltrati = filtraPerCliente(interventiFiltrati, selectedCliente!);
                  }
                  if (selectedTipologia != null) {
                    interventiFiltrati = filtraPerTipologia(interventiFiltrati, selectedTipologia!);
                  }
                  if (startDate != null && endDate != null) {
                    interventiFiltrati = interventiFiltrati.where((intervento) {
                      return intervento.data != null &&
                          intervento.data!.isAfter(startDate!) &&
                          intervento.data!.isBefore(endDate!);
                    }).toList();
                  } else if (startDate != null) {
                    interventiFiltrati = filtraPerData(interventiFiltrati, startDate!);
                  }
                  onFiltrati(interventiFiltrati);
                  Navigator.of(context).pop();
                },
                child: Text('Cerca'),
              ),
            ],
          );
        },
      );
    },
  );
}