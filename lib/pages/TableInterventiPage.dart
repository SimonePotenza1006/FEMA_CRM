import 'dart:convert';
import 'dart:io';
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
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  List<InterventoModel> _allInterventi = [];
  List<InterventoModel> _filteredInterventi = [];
  List<ClienteModel> clientiList = [];
  List<TipologiaInterventoModel> tipologieList = [];
  List<UtenteModel> utentiList = [];
  TextEditingController importoController = TextEditingController();
  bool isSearching = false;
  int _currentSheet = 0;
  TextEditingController searchController = TextEditingController();
  List<GruppoInterventiModel> allGruppiNonConclusi = [];
  List<GruppoInterventiModel> filteredGruppi = [];
  List<GruppoInterventiModel> allGruppiConclusi = [];
  late InterventoDataSource _dataSource;
  TextEditingController _descrizioneController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  ClienteModel? selectedCliente;
  List<ClienteModel> filteredClientiList = [];
  Map<String, double> _columnWidths = {
    'intervento' : 0,
    'id_intervento' : 150,
    'codice_danea' : 200,
    'priorita' : 45,
    'data_apertura_intervento': 210,
    'data': 200,
    'cliente': 200,
    'orario_appuntamento': 150,
    'descrizione': 300,
    'responsabile' : 230,
    'importo_intervento': 150,
    'prezzo_ivato' : 130,
    'importo_ivato' : 150,
    'acconto': 150,
    'inserimento_importo' : 100,
    'importo_restante' : 150,
    'assegna_gruppo' : 130,
    'tipologia' : 180,
    'stato' : 100
  };
  Map<int, List<UtenteModel>> _interventoUtentiMap = {};
  bool isLoading = true;
  bool _isLoading = true;

  Future<void> getAllUtenti() async{
    try{
      var apiUrl = Uri.parse('$ipaddressProva/api/utente');
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
      var apiUrl = Uri.parse('$ipaddressProva/api/tipologiaIntervento');
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
      var apiUrl = Uri.parse('$ipaddressProva/api/cliente');
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
      var apiUrl = Uri.parse('$ipaddressProva/api/gruppi/ordered');
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

    setState(() {
      isLoading = true; // Inizio del caricamento
    });
    try {
      var apiUrl = Uri.parse('$ipaddressProva/api/intervento/ordered');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<InterventoModel> interventi = [];
        interventi = (jsonData as List)
            .take(21) // Limita a 20 elementi
            .map((item) => InterventoModel.fromJson(item))
            .toList();
        /*for (var item in jsonData) {
          interventi.add(InterventoModel.fromJson(item));
        }*/
        // Recuperare tutte le relazioni utenti-interventi
        Map<int, List<UtenteModel>> interventoUtentiMap = {};
        for (var intervento in interventi) {
          var relazioni = await getRelazioni(int.parse(intervento.id.toString()));
          interventoUtentiMap[int.parse(intervento.id.toString())] = relazioni.map((relazione) => relazione.utente!).toList();
        }
        setState(() {
          _isLoading = false;
          _allInterventi = interventi;
          _filteredInterventi = interventi.toList();
          _dataSource = InterventoDataSource(context, _filteredInterventi, interventoUtentiMap, filteredGruppi);
        });
      } else {
        _isLoading = false;
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during API call: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // Fine del caricamento
      });
    }
  }

  Future<void> getAllInterventiTot() async {

    setState(() {
      isLoading = true; // Inizio del caricamento
    });
    try {
      var apiUrl = Uri.parse('$ipaddressProva/api/intervento/ordered');
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
          _isLoading = false;
          _allInterventi = interventi;
          _filteredInterventi = interventi.toList();
          _dataSource = InterventoDataSource(context, _filteredInterventi, interventoUtentiMap, filteredGruppi);
        });
      } else {
        _isLoading = false;
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during API call: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // Fine del caricamento
      });
    }
  }

  Future<List<RelazioneUtentiInterventiModel>> getRelazioni(int interventoId) async {
    try {
      final response = await http.get(Uri.parse('$ipaddressProva/api/relazioneUtentiInterventi/intervento/$interventoId'));
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
        case 5:
          _filteredInterventi = _allInterventi.where((intervento) => (intervento.annullato ?? false)).toList();
      }
      _dataSource.updateData(_filteredInterventi, _interventoUtentiMap, filteredGruppi);
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
      _dataSource.updateData(_filteredInterventi, _interventoUtentiMap, filteredGruppi);
    });
  }

  void _showClientiDialog() {
    TextEditingController searchController = TextEditingController(); // Aggiungi un controller
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) { // Usa StatefulBuilder per aggiornare lo stato del dialogo
            return AlertDialog(
              title: const Text('Seleziona Cliente', textAlign: TextAlign.center),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController, // Aggiungi il controller
                      onChanged: (value) {
                        setState(() {
                          filteredClientiList = clientiList
                              .where((cliente) => cliente.denominazione!
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Cerca Cliente',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: filteredClientiList.map((cliente) {
                            return ListTile(
                              leading: const Icon(Icons.contact_page_outlined),
                              title: Text(
                                  '${cliente.denominazione}'),
                              onTap: () {
                                setState(() {
                                  selectedCliente = cliente;
                                });
                                Navigator.of(context).pop();
                                print('${selectedCliente?.denominazione}');
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _dataSource = InterventoDataSource(context, _filteredInterventi, {}, filteredGruppi);
    getAllInterventi();
    getAllGruppi();
    getAllClienti().whenComplete(() => print('Clienti ok'));
    getAllTipologie().whenComplete(() => print('Tipologie ok'));
    getAllUtenti().whenComplete(() => print('Utenti ok'));
    _filteredInterventi = _allInterventi.toList();
    _changeSheet(0);
    getAllInterventiTot();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista Interventi'.toUpperCase(),
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
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.green[100],
                            ),
                            SizedBox(width: 3),
                            Text('RIPARAZIONE MERCE'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.white,
                            ),
                            SizedBox(width: 3),
                            Text('VENDITA FRONT OFFICE'),

                          ],
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Priorità:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 3),
                            Text('PRIORITÁ NULLA'),
                          ],
                        ),
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.lightGreen,
                            ),
                            SizedBox(width: 3),
                            Text('PRIORITÁ BASSA'),
                          ],
                        ),
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.yellow,
                            ),
                            SizedBox(width: 3),
                            Text('PRIORITÁ MEDIA'),
                          ],
                        ),
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 3),
                            Text('PRIORITÁ ALTA'),
                          ],
                        ),
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.red,
                            ),
                            SizedBox(width: 3),
                            Text('URGENTE'),
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
              color: Colors.white, onPressed: () {
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
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.green[100],
                            ),
                            SizedBox(width: 3),
                            Text('RIPARAZIONE MERCE'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.white,
                            ),
                            SizedBox(width: 3),
                            Text('VENDITA FRONT OFFICE'),

                          ],
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Priorità:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 3),
                            Text('PRIORITÁ NULLA'),
                          ],
                        ),
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.lightGreen,
                            ),
                            SizedBox(width: 3),
                            Text('PRIORITÁ BASSA'),
                          ],
                        ),
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.yellow,
                            ),
                            SizedBox(width: 3),
                            Text('PRIORITÁ MEDIA'),
                          ],
                        ),
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 3),
                            Text('PRIORITÁ ALTA'),
                          ],
                        ),
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.red,
                            ),
                            SizedBox(width: 3),
                            Text('URGENTE'),
                          ],
                        ),
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
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TableInterventiPage()));
              //getAllInterventi();
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
              child: isLoading // Controlla lo stato di caricamento
                  ? Center(child: CircularProgressIndicator()) // Mostra l'indicatore di caricamento
                  : SfDataGrid(
                allowPullToRefresh: true,
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
                    columnName: 'id_intervento',
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
                      child: ColumnFilter(
                        columnName: 'ID',
                        onFilterApplied: (filtro) {
                          setState(() {
                            _dataSource.filtraColonna('id_intervento', filtro);
                          });
                        },
                      ),
                    ),
                    width: _columnWidths['id_intervento']?? double.nan,
                    minimumWidth: 150,
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
                      child: ColumnFilter(
                        columnName: 'CODICE DANEA',
                        onFilterApplied: (filtro) {
                          setState(() {
                            _dataSource.filtraColonna('codice_danea', filtro);
                          });
                        },
                      ),
                    ),
                    width: _columnWidths['codice_danea']?? double.nan,
                    minimumWidth: 200,
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
                      child: ColumnFilter(
                        columnName: 'Cliente'.toUpperCase(),
                        onFilterApplied: (filtro) {
                          setState(() {
                            _dataSource.filtraColonna('cliente', filtro);
                          });
                        },
                      ),
                    ),
                    width: _columnWidths['cliente']?? double.nan,
                    minimumWidth: 200, // Imposta la larghezza minima
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
                      child: ColumnFilter(
                        columnName: 'Data apertura'.toUpperCase(),
                        onFilterApplied: (filtro) {
                          setState(() {
                            _dataSource.filtraColonna('data_apertura_intervento', filtro);
                          });
                        },
                      ),
                    ),
                    width: _columnWidths['data_apertura_intervento']?? double.nan,
                    minimumWidth: 210, // Imposta la larghezza minima
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
                      child: ColumnFilter(
                        columnName: 'APPUNTAMENTO'.toUpperCase(),
                        onFilterApplied: (filtro) {
                          setState(() {
                            _dataSource.filtraColonna('data', filtro);
                          });
                        },
                      ),
                    ),
                    width: _columnWidths['data']?? double.nan,
                    minimumWidth: 200,
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
                      child: ColumnFilter(
                        columnName: 'Orario'.toUpperCase(),
                        onFilterApplied: (filtro) {
                          setState(() {
                            _dataSource.filtraColonna('orario_appuntamento', filtro);
                          });
                        },
                      ),
                    ),
                    width: _columnWidths['orario_appuntamento']?? double.nan,
                    minimumWidth: 150, // Imposta la larghezza minima
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
                      child: ColumnFilter(
                        columnName: 'TITOLO'.toUpperCase(),
                        onFilterApplied: (filtro) {
                          setState(() {
                            _dataSource.filtraColonna('descrizione', filtro);
                          });
                        },
                      ),
                    ),
                    width: _columnWidths['descrizione']?? double.nan,
                    minimumWidth: 300, // Imposta la larghezza minima
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
                      child: ColumnFilter(
                        columnName: 'Responsabile'.toUpperCase(),
                        onFilterApplied: (filtro) {
                          setState(() {
                            _dataSource.filtraColonna('responsabile', filtro);
                          });
                        },
                      ),
                    ),
                    width: _columnWidths['responsabile']?? double.nan,
                    minimumWidth: 230,
                  ),
                  GridColumn(
                    allowSorting: true,
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
                        'SETTORE'.toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['tipologia']?? double.nan,
                    minimumWidth: 180, // Imposta la larghezza minima
                  ),
                  GridColumn(
                    columnName: 'stato',
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
                      child: Text('STATO', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    width: _columnWidths['stato']?? double.nan,
                    minimumWidth: 100,
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
                          ''.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        )
                    ),
                    width: _columnWidths['inserimento_importo']?? double.nan,
                    minimumWidth: 100,
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
                      child: ColumnFilter(
                        columnName: 'importo \n netto'.toUpperCase(),
                        onFilterApplied: (filtro) {
                          setState(() {
                            _dataSource.filtraColonna('importo_intervento', filtro);
                          });
                        },
                      ),
                    ),
                    width: _columnWidths['importo_intervento']?? double.nan,
                    minimumWidth: 150, // Imposta la larghezza minima
                  ),
                  GridColumn(
                    columnName: 'importo_ivato',
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
                      child: ColumnFilter(
                        columnName: 'importo \n ivato'.toUpperCase(),
                        onFilterApplied: (filtro) {
                          setState(() {
                            _dataSource.filtraColonna('importo_ivato', filtro);
                          });
                        },
                      ),
                    ),
                    width: _columnWidths['importo_ivato']?? double.nan,
                    minimumWidth: 150, // Imposta la larghezza minima
                  ),
                  GridColumn(
                    columnName: 'acconto'.toUpperCase(),
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
                        'Acconto'.toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['acconto']?? double.nan,
                    minimumWidth: 150, // Imposta la larghezza minima
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
                        'Importo restante'.toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    width: _columnWidths['importo_restante']?? double.nan,
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
                          'Seleziona Gruppo'.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      )
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
            Flex(
              // height: 60,
              direction: Axis.horizontal,
              children: [
                Expanded(
                  child:
                  Container(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
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
                              onPressed: () => _changeSheet(4),
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
                            SizedBox(width: 5),
                            ElevatedButton(
                              onPressed: () => _changeSheet(5),
                              style: ElevatedButton.styleFrom(
                                primary: _currentSheet == 5 ? Colors.red[300] : Colors.grey[700],
                                onPrimary: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                elevation: 2.0,
                              ),
                              child: Text('Annullati', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                  ),
                )
              ]
            )
          ],
        ),
      ),
      floatingActionButton:Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: (){
              showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog(
                      title: Text('Crea un nuovo gruppo', style: TextStyle(fontWeight: FontWeight.bold)),
                      actions: <Widget>[
                        TextFormField(
                          controller: _descrizioneController,
                          decoration: InputDecoration(
                            labelText: 'Nome del nuovo gruppo',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            labelText: 'Inserisci una nota al gruppo',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          child: GestureDetector(
                            onTap: () {
                              _showClientiDialog();
                            },
                            child: SizedBox(
                              height: 50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(selectedCliente?.denominazione ?? 'Seleziona Cliente', style: const TextStyle(fontSize: 16)),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            saveGruppo();
                          },
                          child: Text('Salva gruppo'),
                        ),
                      ],
                    );
                  });
            },
            backgroundColor: Colors.red,
            child: Icon(Icons.create_new_folder, color: Colors.white),
            heroTag: "Tag2",
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              mostraRicercaInterventiDialog(
                context: context,
                utenti: utentiList,
                clienti: clientiList,
                tipologie: tipologieList,
                interventi: _allInterventi,
                onFiltrati: (interventiFiltrati) {
                  _dataSource.updateData(interventiFiltrati, _interventoUtentiMap, filteredGruppi);
                },
              );
            },
            child: Icon(Icons.filter_list, color: Colors.white,),
            backgroundColor: Colors.red,
          ),
        ],
      )
    );
  }

  Future<void> saveGruppo() async{
    try{
      final response = await http.post(
          Uri.parse('$ipaddressProva/api/gruppi'),
          headers: {'Content-Type' : 'application/json'},
          body: jsonEncode({
            'descrizione' : _descrizioneController.text,
            'note' : _noteController.text,
            'importo' : null,
            'concluso' : false,
            'cliente' : selectedCliente?.toMap()
          })
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nuova gruppo registrato con successo!'),
        ),
      );
      getAllGruppi();
      getAllInterventi();
    } catch(e){
      print('Errore: $e');
    }
  }
}

class InterventoDataSource extends DataGridSource {
  List<InterventoModel> _interventions = [];
  List<InterventoModel> interventiFiltrati = [];
  Map<int, List<UtenteModel>> _interventoUtentiMap = {};
  BuildContext context;
  TextEditingController importoController = TextEditingController();
  TextEditingController codiceDaneaController = TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  GruppoInterventiModel? _selectedGruppo;
  List<GruppoInterventiModel> filteredGruppi = [];
  List<GruppoInterventiModel> allGruppiConclusi = [];
  List<GruppoInterventiModel> allGruppiNonConclusi = [];
  InterventoModel? _selectedIntervento;
  bool prezzoIvato = false;
  bool ventidue = false;
  bool dieci = false;
  bool quattro = false;
  int selectedIva = 0;

  InterventoDataSource(
      this.context,
      List<InterventoModel> interventions,
      Map<int, List<UtenteModel>> interventoUtentiMap,
      List<GruppoInterventiModel> gruppi
      ) {
    _interventions = List.from(interventions);
    interventiFiltrati = List.from(interventions);
    _interventoUtentiMap = interventoUtentiMap;
    filteredGruppi = gruppi;
  }

  void updateData(List<InterventoModel> newInterventions, Map<int, List<UtenteModel>> newInterventoUtentiMap, List<GruppoInterventiModel> gruppi) {
    _interventions.clear();
    _interventions.addAll(newInterventions);
    interventiFiltrati = List.from(newInterventions);  // Aggiorna anche la lista filtrata
    _interventoUtentiMap = newInterventoUtentiMap;
    filteredGruppi = gruppi;
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows {
    List<DataGridRow> rows = [];
    for (int i = 0; i < interventiFiltrati.length; i++) {
      InterventoModel intervento = interventiFiltrati[i];
      Color? backgroundColor;
      switch (intervento.tipologia?.id) {
        case '7' :
          backgroundColor = Colors.blueGrey[200];
          break;
        case '1':
          backgroundColor = Colors.grey[200]; // grigio chiaro
          break;
        case '2':
          backgroundColor = Colors.yellow[200]; // giallo chiaro
          break;
        case '3':
          backgroundColor = Colors.lightBlue[200]; // azzurro chiaro
          break;
        case '4':
          backgroundColor = Colors.pink[50]; // rosa chiarissimo
          break;
        case '6':
          backgroundColor = Colors.green[100]; // verde chiarissimo
          break;
        default:
          backgroundColor = Colors.blueGrey[200];
      }

      Color? prioritaColor;
      switch (intervento.priorita) {
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
          backgroundColor = Colors.red; // azzurro chiaro
          break;
        default:
          backgroundColor = Colors.blueGrey[200];
      }

      double? importo = intervento.importo_intervento != null ? intervento.importo_intervento : 0;
      double? acconto = intervento.acconto != null ? intervento.acconto : 0;
      double? restante_da_pagare = importo! - acconto!;
      String? stato = (intervento.orario_inizio == null && intervento.orario_fine == null)
          ? "Assegnato".toUpperCase()
          : (intervento.orario_inizio != null && intervento.orario_fine == null)
          ? "In lavorazione".toUpperCase()
          : (intervento.orario_inizio != null && intervento.orario_fine != null)
          ? "Concluso".toUpperCase()
          : "///";



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
            columnName: 'id_intervento',
            value: "${intervento.id}/${intervento.data_apertura_intervento?.year != null ? intervento.data_apertura_intervento?.year : DateTime.now().year }APP",
          ),
          DataGridCell<Priorita>(
            columnName: 'priorita',
            value : intervento.priorita,
          ),
          DataGridCell<Widget>(
            columnName: 'codice_danea',
            value: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return
                      StatefulBuilder(
                          builder: (context, setState){
                            return AlertDialog(
                              title: Text('Inserisci un codice'.toUpperCase()),
                              actions: <Widget>[
                                TextFormField(
                                  controller: codiceDaneaController,
                                  decoration: InputDecoration(
                                    labelText: 'CODICE DANEA',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    saveCodice(intervento).then((_) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => TableInterventiPage()),
                                      );
                                    });
                                  },
                                  child: Text('Salva codice'.toUpperCase()),
                                ),
                              ],
                            );
                          }
                      );
                  },
                );
              },
               child: Text(
                   '${intervento.numerazione_danea != null ? intervento.numerazione_danea : 'N/A'}'
               ),
            ),
          ),
          DataGridCell<String>(
            columnName: 'cliente',
            value: intervento.cliente?.denominazione ?? '',
          ),
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
            columnName: 'orario_appuntamento',
            value: intervento.orario_appuntamento != null
                ? DateFormat('HH:mm').format(intervento.orario_appuntamento!)
                : '',
          ),
          DataGridCell<String>(
            columnName: 'descrizione',
            value: intervento.titolo ?? '',
          ),
          DataGridCell<String>(
            columnName: 'responsabile',
            value: intervento.utente?.nomeCompleto() ?? 'NON ASSEGNATO',
          ),
          DataGridCell<String>(
            columnName: 'tipologia',
            value: intervento.tipologia?.descrizione ?? '',//int.parse(intervento.tipologia!.id.toString()),
          ),
          DataGridCell<String>(
            columnName: 'stato',
            value: stato,
          ),
          DataGridCell<Widget>(
            columnName: 'inserimento_importo',
            value: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return
                      StatefulBuilder(
                        builder: (context, setState) {
                          // Variabile per memorizzare l'aliquota IVA selezionata
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
                              Row(
                                children: [
                                  Checkbox(
                                    value: intervento.prezzo_ivato,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        intervento.prezzo_ivato = value;
                                        prezzoIvato = value!;
                                      });
                                    },
                                  ),
                                  Text('IVA INCLUSA'),
                                ],
                              ),
                              if (prezzoIvato == true)
                                Container(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: ventidue,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                ventidue = value!;
                                                dieci = false;
                                                quattro = false;
                                                selectedIva = 22; // Setta l'IVA a 22%
                                                print('IVA selezionata: $selectedIva');
                                              });
                                            },
                                          ),
                                          Text(' 22%'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: dieci,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                dieci = value!;
                                                ventidue = false;
                                                quattro = false;
                                                selectedIva = 10; // Setta l'IVA a 10%
                                                print('IVA selezionata: $selectedIva');
                                              });
                                            },
                                          ),
                                          Text(' 10%'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: quattro,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                quattro = value!;
                                                ventidue = false;
                                                dieci = false;
                                                selectedIva = 4; // Setta l'IVA a 4%
                                                print('IVA selezionata: $selectedIva');
                                              });
                                            },
                                          ),
                                          Text(' 4%'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              TextButton(
                                onPressed: () {
                                  print('IVA passata: $selectedIva'); // Stampa l'IVA prima di chiamare saveImporto
                                  saveImporto(intervento, prezzoIvato, selectedIva).then((_) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => TableInterventiPage()),
                                    );
                                  });
                                },
                                child: Text('Salva importo'),
                              ),
                            ],
                          );
                        },
                      );
                  },
                );
              },
              icon: Icon(Icons.create, color: Colors.grey),
            ),
          ),
          DataGridCell<String>(
            columnName: 'importo_intervento',
            value: intervento.importo_intervento != null
                ? intervento.importo_intervento!.toStringAsFixed(2) + "€"
                : '',
          ),
          DataGridCell<String>(
            columnName: 'importo_ivato',
            value: (intervento.importo_intervento != null && intervento.iva != null)
                ? ((intervento.importo_intervento! * (1 + (intervento.iva! / 100)))
                .toStringAsFixed(2) + "€ (${intervento.iva}%)")
                : '',
          ),
          DataGridCell<String>(
            columnName: 'acconto',
            value: intervento.acconto != null
                ? intervento.acconto!.toStringAsFixed(2) + "€"
                : '',
          ),
          DataGridCell<String>(
            columnName: 'importo_restante',
            value: (intervento.importo_intervento != null && intervento.iva != null)
                ? ((intervento.importo_intervento! * (1 + (intervento.iva! / 100)) -
                (intervento.acconto ?? 0)) // Trattiamo acconto come 0 se è null
                .toStringAsFixed(2) + "€")
                : '',
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
          ),
        ],
      ));
    }
    return rows;
  }

  void filtraColonna(String columnName, String filtro) {
    if (filtro.isEmpty) {
      interventiFiltrati = List.from(_interventions);
    } else {
      interventiFiltrati = _interventions.where((intervento) {
        switch (columnName) {
          case 'descrizione':
            bool result = intervento.titolo?.toLowerCase().contains(filtro.toLowerCase()) ?? false;
            return result;
          case 'id_intervento':
            bool result = intervento.id?.toLowerCase().contains(filtro.toLowerCase()) ?? false;
            return result;
          case 'data_apertura_intervento':
            bool result = intervento.data_apertura_intervento?.toString().toLowerCase().contains(filtro.toLowerCase()) ?? false;
            return result;
          case 'data':
            bool result = intervento.data?.toString().toLowerCase().contains(filtro.toLowerCase()) ?? false;
            return result;
          case 'orario_appuntamento':
            bool result = intervento.orario_appuntamento?.toString().toLowerCase().contains(filtro.toLowerCase()) ?? false;
            return result;
          case 'cliente':
            bool result = intervento.cliente?.denominazione!.toLowerCase().contains(filtro.toLowerCase()) ?? false;
            return result;
          case 'importo_intervento' :
            bool result = intervento.importo_intervento?.toString().toLowerCase().contains(filtro.toLowerCase()) ?? false;
            return result;
          case 'responsabile':
            return (intervento.utente?.nome?.toLowerCase().contains(filtro.toLowerCase()) ?? false) ||
                (intervento.utente?.cognome?.toLowerCase().contains(filtro.toLowerCase()) ?? false);
          default:
            return true;
        }
      }).toList();
    }
    notifyListeners();
  }

  Future<void> addToGruppo(InterventoModel intervento) async {
    try{
      final response = await http.post(
        Uri.parse('$ipaddressProva/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': intervento.id,
          'titolo' : intervento.titolo,
          'attivo' : intervento.attivo,
          'numerazione_danea' : intervento.numerazione_danea,
          'data_apertura_intervento' : DateTime.now().toIso8601String(),
          'data': intervento.data?.toIso8601String(),
          'orario_appuntamento' : intervento.orario_appuntamento?.toIso8601String(),
          'posizione_gps' : intervento.posizione_gps,
          'orario_inizio': intervento.orario_inizio?.toIso8601String(),
          'orario_fine': intervento.orario_fine?.toIso8601String(),
          'descrizione': intervento.descrizione,
          'importo_intervento': intervento.importo_intervento,
          'saldo_tecnico' : intervento.saldo_tecnico,
          'prezzo_ivato' : intervento.prezzo_ivato,
          'iva' : intervento.iva,
          'assegnato': intervento.assegnato,
          'accettato_da_tecnico' : intervento.accettato_da_tecnico,
          'annullato' : intervento.annullato,
          'conclusione_parziale': intervento.conclusione_parziale,
          'concluso': intervento.concluso,
          'saldato': intervento.saldato,
          'saldato_da_tecnico' : intervento.saldato_da_tecnico,
          'note': intervento.note,
          'relazione_tecnico' : intervento.relazione_tecnico,
          'firma_cliente': intervento.firma_cliente,
          'utente_apertura' : intervento.utente_apertura?.toMap(),
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
      }
    } catch(e){
      print('Errore durante il salvataggio del intervento: $e');
    }
  }

  Future<void> saveImporto(InterventoModel intervento, bool prezzoIvato, int iva) async {
    try {
      print(' IVA : ${iva}');
      final response = await http.post(
        Uri.parse('$ipaddressProva/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': intervento.id,
          'attivo' : intervento.attivo,
          'titolo' : intervento.titolo,
          'numerazione_danea' : intervento.numerazione_danea,
          'data_apertura_intervento' : intervento.data_apertura_intervento?.toIso8601String(),
          'data': intervento.data?.toIso8601String(),
          'orario_appuntamento' : intervento.orario_appuntamento?.toIso8601String(),
          'posizione_gps' : intervento.posizione_gps,
          'orario_inizio': intervento.orario_inizio?.toIso8601String(),
          'orario_fine': intervento.orario_fine?.toIso8601String(),
          'descrizione': intervento.descrizione,
          'importo_intervento': double.parse(importoController.text),
          'saldo_tecnico' : intervento.saldo_tecnico,
          'prezzo_ivato' : prezzoIvato,
          'iva' : iva, // Passa l'IVA selezionata come numero intero
          'assegnato': intervento.assegnato,
          'accettato_da_tecnico' : intervento.accettato_da_tecnico,
          'annullato' : intervento.annullato,
          'conclusione_parziale': intervento.conclusione_parziale,
          'concluso': intervento.concluso,
          'saldato': intervento.saldato,
          'saldato_da_tecnico' : intervento.saldato_da_tecnico,
          'note': intervento.note,
          'relazione_tecnico' : intervento.relazione_tecnico,
          'firma_cliente': intervento.firma_cliente,
          'utente_apertura' : intervento.utente_apertura?.toMap(),
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
        print(response.body.toString());
        print('EVVAIIIIIIII');
        Navigator.of(context).pop();
        prezzoIvato = false;
      }
    } catch (e) {
      print('Errore durante il salvataggio del intervento: $e');
    }
  }

  Future<void> saveCodice(InterventoModel intervento) async {
    try {
      final response = await http.post(
        Uri.parse('$ipaddressProva/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': intervento.id,
          'attivo' : intervento.attivo,
          'titolo' : intervento.titolo,
          'numerazione_danea' : codiceDaneaController.text.isNotEmpty ? codiceDaneaController.text : "N/A",
          'data_apertura_intervento' : intervento.data_apertura_intervento?.toIso8601String(),
          'data': intervento.data?.toIso8601String(),
          'orario_appuntamento' : intervento.orario_appuntamento?.toIso8601String(),
          'posizione_gps' : intervento.posizione_gps,
          'orario_inizio': intervento.orario_inizio?.toIso8601String(),
          'orario_fine': intervento.orario_fine?.toIso8601String(),
          'descrizione': intervento.descrizione,
          'importo_intervento': intervento.importo_intervento,
          'saldo_tecnico' : intervento.saldo_tecnico,
          'prezzo_ivato' : prezzoIvato,
          'iva' : intervento.iva,
          'assegnato': intervento.assegnato,
          'accettato_da_tecnico' : intervento.accettato_da_tecnico,
          'annullato' : intervento.annullato,
          'conclusione_parziale': intervento.conclusione_parziale,
          'concluso': intervento.concluso,
          'saldato': intervento.saldato,
          'saldato_da_tecnico' : intervento.saldato_da_tecnico,
          'note': intervento.note,
          'relazione_tecnico' : intervento.relazione_tecnico,
          'firma_cliente': intervento.firma_cliente,
          'utente_apertura' : intervento.utente_apertura?.toMap(),
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
        codiceDaneaController.clear();
        print('EVVAIIIIIIII');
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Errore durante il salvataggio del intervento: $e');
    }
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final InterventoModel intervento = row.getCells().firstWhere(
          (cell) => cell.columnName == 'intervento',
    ).value as InterventoModel;
    final List<UtenteModel> utenti = _interventoUtentiMap[intervento.id] ?? [];
    utenti.forEach((utente) {
    });
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

    Color? prioritaColor;
    switch (intervento.priorita) {
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
        if (dataGridCell.columnName == 'intervento') {
          // Cella invisibile per l'oggetto InterventoModel
          return SizedBox.shrink(); // La cella sarà invisibile ma presente
        }
        if( dataGridCell.columnName == 'priorita'){
          return Container(
              color: prioritaColor,
            );
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
                utenti.isNotEmpty ? utenti.map((utente) =>
                    utente.nomeCompleto()).join(', ') : 'NESSUNO',
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
              ElevatedButton(
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
                    if (selectedUtente != null && selectedCliente != null && selectedTipologia != null) {
                      interventiFiltrati = filtraPerUtenteClienteTipologiaEIntervalloDate(
                          interventiFiltrati,
                          selectedUtente!,
                          selectedCliente!,
                          selectedTipologia!,
                          startDate!,
                          endDate!
                      );
                    } else if (selectedUtente != null && selectedCliente != null) {
                      interventiFiltrati = filtraPerUtenteClienteEIntervalloDate(
                          interventiFiltrati,
                          selectedUtente!,
                          selectedCliente!,
                          startDate!,
                          endDate!
                      );
                    } else if (selectedUtente != null) {
                      interventiFiltrati = filtraPerUtenteEIntervalloDate(
                          interventiFiltrati,
                          selectedUtente!,
                          startDate!,
                          endDate!
                      );
                    } else {
                      interventiFiltrati = interventiFiltrati.where((intervento) {
                        return intervento.data != null &&
                            intervento.data!.isAfter(startDate!) &&
                            intervento.data!.isBefore(endDate!);
                      }).toList();
                    }
                  } else if (startDate != null) {
                    interventiFiltrati = filtraPerData(interventiFiltrati, startDate!);
                  } else if (endDate != null) {
                    interventiFiltrati = filtraPerData(interventiFiltrati, endDate!);
                  }
                  onFiltrati(interventiFiltrati);
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

class ColumnFilter extends StatelessWidget {
  final String columnName;
  final Function(String filtro) onFilterApplied;

  ColumnFilter({required this.columnName, required this.onFilterApplied});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          columnName,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ColumnFilterDialog(
                  columnName: columnName,
                  onFilterApplied: onFilterApplied,
                );
              },
            );
          },
          child: Icon(
            Icons.search,
            size: 20,
          ),
        ),
      ],
    );
  }
}

class ColumnFilterDialog extends StatefulWidget {
  final String columnName;
  final Function(String filtro) onFilterApplied;

  ColumnFilterDialog({required this.columnName, required this.onFilterApplied});

  @override
  _ColumnFilterDialogState createState() => _ColumnFilterDialogState();
}

class _ColumnFilterDialogState extends State<ColumnFilterDialog> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filtra ${widget.columnName}'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: 'Inserisci un valore con cui filtrare'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Chiudi il dialog senza filtrare
          },
          child: Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onFilterApplied(_controller.text);  // Applica il filtro
            Navigator.of(context).pop();  // Chiudi il dialog
          },
          child: Text('Filtra'),
        ),
      ],
    );
  }
}


