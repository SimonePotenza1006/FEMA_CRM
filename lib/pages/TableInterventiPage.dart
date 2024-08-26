import 'dart:convert';
import 'package:fema_crm/model/TipologiaInterventoModel.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
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
  TextEditingController importoController = TextEditingController();
  bool isSearching = false;
  int _currentSheet = 0;
  TextEditingController searchController = TextEditingController();
  List<GruppoInterventiModel> allGruppiNonConclusi = [];
  List<GruppoInterventiModel> filteredGruppi = [];
  List<GruppoInterventiModel> allGruppiConclusi = [];
  late InterventoDataSource _dataSource;
  Map<String, double> _columnWidths = {
    'data_apertura_intervento': 120,
    'data': 120,
    'cliente': 200,
    'orario_appuntamento': 120,
    'descrizione': 300,
    'responsabile' : 200,
    'importo_intervento': 100,
    'acconto': 100,
    'utenti' : 200,
    'inserimento_importo' : 100,
    'assegna_gruppo' : 100,
  };
  Map<int, List<UtenteModel>> _interventoUtentiMap = {};

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
          print('Intervento ${intervento.id} has ${relazioni.length} utenti: ${relazioni.map((relazione) => relazione.utente!.nomeCompleto()).join(', ')}');
        }
        setState(() {
          _allInterventi = interventi;
          _filteredInterventi = interventi.where((intervento) => !(intervento.concluso ?? false)).toList();
          _dataSource = InterventoDataSource(context, _filteredInterventi, interventoUtentiMap);
          print('Updated _interventoUtentiMap: $interventoUtentiMap');
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
          _filteredInterventi = _allInterventi.where((intervento) => !(intervento.concluso ?? false)).toList();
          break;
        case 1:
          _filteredInterventi = _allInterventi.where((intervento) => (intervento.concluso ?? false) && !(intervento.saldato ?? false)).toList();
          break;
        case 2:
          _filteredInterventi = _allInterventi.where((intervento) => (intervento.concluso ?? false) && (intervento.saldato ?? false)).toList();
          break;
      }
      _dataSource.updateData(_filteredInterventi, _interventoUtentiMap);
    });
  }

  void filterInterventi(String query) {
    print('Filtrando per query: $query');
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
      print('Trovati ${_filteredInterventi.length} interventi corrispondenti alla query');
      _dataSource.updateData(_filteredInterventi, _interventoUtentiMap);
    });
  }

  void startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  void stopSearch() {
    setState(() {
      isSearching = false;
      searchController.clear();
      filterInterventi('');
    });
  }

  void _showFilterDialog() {
    String? selectedField;
    TextEditingController queryController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filtra interventi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedField,
                hint: Text('Seleziona campo'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedField = newValue;
                  });
                },
                items: [
                  DropdownMenuItem(value: 'cliente', child: Text('Cliente')),
                  DropdownMenuItem(value: 'descrizione', child: Text('Descrizione')),
                  DropdownMenuItem(value: 'citta', child: Text('Città')),
                  DropdownMenuItem(value: 'tipologia', child: Text('Tipologia')),
                  // Aggiungi altri campi se necessario
                ],
              ),
              TextField(
                controller: queryController,
                decoration: InputDecoration(hintText: 'Inserisci la query'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Annulla'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Filtra'),
              onPressed: () {
                if (selectedField != null && queryController.text.isNotEmpty) {
                  _applyFilter(selectedField!, queryController.text);
                  Navigator.of(context).pop();
                } else {
                  // Mostra un errore se il campo o la query non sono validi
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Seleziona un campo e inserisci una query valida')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _applyFilter(String field, String query) {
    setState(() {
      _filteredInterventi = _allInterventi.where((intervento) {
        switch (field) {
          case 'cliente':
            return intervento.cliente?.denominazione?.toLowerCase().contains(query.toLowerCase()) ?? false;
          case 'descrizione':
            return intervento.descrizione?.toLowerCase().contains(query.toLowerCase()) ?? false;
          case 'citta':
            return (intervento.cliente?.citta?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
                (intervento.destinazione?.citta?.toLowerCase().contains(query.toLowerCase()) ?? false);
          case 'tipologia':
            return intervento.tipologia?.descrizione?.toLowerCase().contains(query.toLowerCase()) ?? false;
          default:
            return false;
        }
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextFormField(
          controller: searchController,
          onChanged: (value) {
            startSearch();
            filterInterventi(value);
          },
          decoration: InputDecoration(
            hintText: 'Cerca...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
        )
            : Text(
          'Lista Interventi',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          isSearching
              ? IconButton(
            icon: Icon(Icons.cancel, color: Colors.white),
            onPressed: stopSearch,
          )
              : IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: startSearch,
          ),
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
                    columnName: 'utenti',
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
                        'Altri tecnici',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['utenti'] ?? double.nan,
                    minimumWidth: 150, // Imposta la larghezza minima
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
                  child: Text('Non Conclusi', style: TextStyle(color: Colors.white)),
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
                  child: Text('Conclusi non Saldati', style: TextStyle(color: Colors.white)),
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
                  child: Text('Conclusi e Saldati', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterDialog,
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
    print('New _interventoUtentiMap: $_interventoUtentiMap');
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

      String utentiNomi = '';
      if (_interventoUtentiMap.containsKey(intervento.id)) {
        List<UtenteModel> utenti = _interventoUtentiMap[intervento.id]!;
        utentiNomi = utenti.map((utente) => utente.nomeCompleto()).join(', ');
      } else {
        utentiNomi = 'NESSUNO'; // or any other default value
      }

      print('Intervento ${intervento.id} utenti: $utentiNomi'); // Debug statement

      rows.add(DataGridRow(
        cells: [
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
            columnName: 'utenti',
            value: utentiNomi,
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
    final int rowIndex = row.getCells().first.columnName == 'data_apertura_intervento'
        ? _interventions.indexWhere((intervento) => intervento.data_apertura_intervento != null
        ? DateFormat('dd/MM/yyyy').format(intervento.data_apertura_intervento!) == row.getCells().first.value
        : intervento.data_apertura_intervento == null && row.getCells().first.value == '')
        : -1;
    if (rowIndex == -1) {
      throw Exception('Row not found');
    }
    InterventoModel intervento = _interventions[rowIndex];

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

    String utentiNomi = '';
    if (_interventoUtentiMap.containsKey(intervento.id)) {
      List<UtenteModel> utenti = _interventoUtentiMap[intervento.id]!;
      utentiNomi = utenti.map((utente) => utente.nomeCompleto()).join(', ');
    } else {
      utentiNomi = 'NESSUNO'; // or any other default value
    }

    return DataGridRowAdapter(
      color: backgroundColor,
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.value is Widget) {
          return Container(
            alignment: Alignment.center,
            //padding: EdgeInsets.all(8.0),
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
              child: Text(dataGridCell.value.toString()),
            ),
          );
        }
      }).toList(),
    );
  }
}
