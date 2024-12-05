import 'dart:convert';

import 'package:fema_crm/pages/CreazioneTaskPage.dart';
import 'package:fema_crm/pages/DettaglioCommissioneAmministrazionePage.dart';
import 'package:fema_crm/pages/HomeFormAmministrazioneNewPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../model/CommissioneModel.dart';
import '../model/InterventoModel.dart';
import '../model/TaskModel.dart';
import '../model/TipoTaskModel.dart';
import '../model/UtenteModel.dart';
import 'ModificaTaskPage.dart';

class TableTaskPage extends StatefulWidget{
  final UtenteModel utente;
  const TableTaskPage({Key? key, required this.utente}) : super(key: key);

  @override
  _TableTaskPageState createState() => _TableTaskPageState();
}

class _TableTaskPageState extends State<TableTaskPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  List<TaskModel> _allCommissioni = [];
  List<TaskModel> _filteredCommissioni = [];
  List<TaskModel> _taskFede =[];
  Map<String, double> _columnWidths ={};
  int? _currentSheet;
  bool isLoading = true;
  bool _isLoading = true;
  late TaskDataSource _dataSource;
  List<TipoTaskModel> allTipi = [];
  List<UtenteModel> allUtenti = [];
  UtenteModel? selectedUtente;
  TextEditingController _descrizioneController = TextEditingController();

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  void _setPreferredOrientation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      const double thresholdWidth = 450.0;
      if (size.width < thresholdWidth) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      }
    });
  }

  Future<bool> deleteTasksByTipo(String? selectedTipo) async {
    if (selectedTipo == null) {
      print('Nessuna tipologia selezionata, nessuna operazione effettuata.');
      return false;
    }

    // Filtra i task con tipologia corrispondente
    List<TaskModel> tasksToDelete = _allCommissioni.where((task) => task.tipologia == selectedTipo).toList();
    bool allDeleted = true;

    for (var task in tasksToDelete) {
      final String url = '$ipaddress/api/task/${task.id}';
      try {
        final response = await http.delete(Uri.parse(url));
        if (response.statusCode == 200 || response.statusCode == 204) {
          print('Eliminato task con id ${task.id}');
          // Aggiorna lista locale solo se il task è stato eliminato con successo
          _allCommissioni.remove(task);
          _filteredCommissioni.remove(task);
        } else {
          print('Errore nell\'eliminazione del task con id ${task.id}: ${response.statusCode} - ${response.body}');
          allDeleted = false;
        }
      } catch (e) {
        print('Eccezione durante l\'eliminazione del task con id ${task.id}: $e');
        allDeleted = false;
      }
    }

    if (allDeleted) {
      print('Tutti i task con tipologia "$selectedTipo" sono stati eliminati con successo.');
    } else {
      print('Alcuni task non sono stati eliminati. Operazione incompleta.');
    }

    return allDeleted;
  }


  Future<void> deleteTipologia(TipoTaskModel? selectedTipoToDelete) async {
    if (selectedTipoToDelete == null) {
      print('Nessuna tipologia selezionata. Operazione annullata.');
      return;
    }

    try {
      // Step 1: Elimina tutti i task associati
      print('Inizio eliminazione task associati...');
      bool tasksDeleted = await deleteTasksByTipo(selectedTipoToDelete.id!);

      if (!tasksDeleted) {
        print('Non è stato possibile eliminare tutti i task. Annullo l\'eliminazione della tipologia.');
        return; // Interrompi il processo se i task non sono stati eliminati con successo
      }

      // Step 2: Elimina la tipologia
      print('Task eliminati. Procedo con l\'eliminazione della tipologia.');
      final String url = '$ipaddress/api/tipoTask/${selectedTipoToDelete.id}';
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Tipologia "${selectedTipoToDelete.descrizione}" eliminata con successo.');
        allTipi.remove(selectedTipoToDelete);
        getAllTipi();
        getAllTask();
      } else {
        print('Errore nell\'eliminazione della tipologia "${selectedTipoToDelete.descrizione}": '
            '${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Eccezione durante l\'eliminazione della tipologia "${selectedTipoToDelete.descrizione}": $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _setPreferredOrientation();
    _columnWidths = {
      'task': 0,
      'accettatoicon': (widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti") ? 0 : 60,
      'completed': 60,
      'delete': 60,
      'condividi': (widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti") ? 60 : 0,
      'data_creazione': 150,
      'titolo': 300,
      'utente': (widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti") ? 200 : 0,
      'accettato': (widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti") ? 170 : 0,
      'data_conclusione': 150,
    };
    initializeData();
    setState(() {
      if(widget.utente.cognome == "Mazzei"){
        _currentSheet = 9;
      }
    });
  }

  Future<void> initializeData() async {
    print('Inizio inizializzazione dei dati...');
    await getAllTipi();
    print('Tipologie caricate con successo.');

    await getAllUtenti();
    print('Utenti caricati con successo.');

    await getAllTask();
    print('Task caricati con successo.');

    setState(() {
      print('Inizio filtraggio delle commissioni...');
      if (widget.utente.cognome! == "Mazzei") {
        print('Utente Mazzei rilevato. Applicazione del filtro per tipologia id = 9 e cognome Mazzei...');
        _filteredCommissioni = _allCommissioni.where((task) {
          print(
              'Task: ${task.titolo}, Tipologia ID: ${task.tipologia?.id}, Utente Cognome: ${task.utente?.cognome}');
          return task.tipologia?.id == "9" && task.utente?.cognome == "Mazzei";
        }).toList();
        print('Numero di task filtrati: ${_filteredCommissioni.length}');
      } else {
        _filteredCommissioni = _allCommissioni.toList();
        print('Nessun filtro applicato, tutte le task assegnate a _filteredCommissioni.');
      }

      _dataSource = TaskDataSource(context, _filteredCommissioni, widget.utente, List.from(allUtenti));
      print('Datasource inizializzato con ${_filteredCommissioni.length} task.');
    });
    print('Inizializzazione completata.');
  }

  Future<void> getAllUtenti() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/utente/attivo');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<UtenteModel> utenti = [];
        for (var item in jsonData) {
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          allUtenti = utenti;
        });
      } else {
        throw Exception(
            'Failed to load utenti data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching agenti data from API: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Connection Error'),
            content: Text(
                'Unable to load data from API. Please check your internet connection and try again.'),
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

  Future<void> getAllTipi() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/tipoTask');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<TipoTaskModel> tipi = [];
        for(var item in jsonData){
          tipi.add(TipoTaskModel.fromJson(item));
        }
        setState(() {
          allTipi = tipi;
        });
      } else {
        throw Exception(
            'Failed to load tipi task data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Error fetching tipi task data from API: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Connection Error'),
            content: Text(
                'Unable to load data from API. Please check your internet connection and try again.'),
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

  Future<void> getAllTask() async {
    setState(() {
      isLoading = true;
      print('Caricamento iniziato...');
    });
    try {
      // Decidi l'endpoint in base al cognome dell'utente
      var apiUrl = (widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti")
          ? Uri.parse('$ipaddress/api/task/all')
          : Uri.parse('$ipaddress/api/task/utente/' + widget.utente!.id!);
      print('Chiamata API verso: $apiUrl');
      var response = await http.get(apiUrl);
      print('Risposta ricevuta con status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print('Dati ricevuti: ${jsonData.length} elementi trovati.');
        List<TaskModel> commissioni = [];
        for (var item in jsonData) {
          commissioni.add(TaskModel.fromJson(item));
        }
        print('Numero di task convertiti: ${commissioni.length}');
        setState(() {
          _isLoading = false;
          _allCommissioni = commissioni;
          print('Tutte le commissioni assegnate a _allCommissioni: ${_allCommissioni.length} task.');
          // Applica il filtro iniziale per filteredCommissioni se l'utente è Mazzei
          if (widget.utente.cognome! == "Mazzei") {
            print('Filtraggio per utente Mazzei con tipologia id = 9...');
            _filteredCommissioni = commissioni.where((task) {
              print('Task: ${task.titolo}, Tipologia: ${task.tipologia?.id}, Utente: ${task.utente?.cognome}');
              return task.tipologia?.id == "9" && task.utente?.cognome == "Mazzei";
            }).toList();
            print('Numero di task filtrati: ${_filteredCommissioni.length}');
          } else {
            _filteredCommissioni = commissioni;
            print('Nessun filtro applicato, tutte le task assegnate a _filteredCommissioni.');
          }
          _dataSource = TaskDataSource(context, _filteredCommissioni, widget.utente, allUtenti);
          print('Datasource aggiornato.');
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Errore nella chiamata API, status code: ${response.statusCode}');
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata API: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during API call: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // Fine del caricamento
        print('Caricamento terminato.');
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return WillPopScope(
        onWillPop: () async {
          // Ripristina l'orientamento predefinito quando si lascia la pagina
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('LISTA TASK', style: TextStyle(color: Colors.white)),
            centerTitle: true,
            backgroundColor: Colors.red,
            actions: [
              if(widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti")
                Row(
                  children: [
                    PopupMenuButton<UtenteModel>(
                      icon: Icon(Icons.person, color: Colors.white), // Icona della casa
                      onSelected: (UtenteModel utente) {
                        setState(() {
                          selectedUtente = utente;
                        });
                        filterTasksByUtente(selectedUtente!);
                      },
                      itemBuilder: (BuildContext context) {
                        return allUtenti.map((UtenteModel singleUtente) {
                          return PopupMenuItem<UtenteModel>(
                            value: singleUtente,
                            child: Text(singleUtente.nomeCompleto()!.toUpperCase()),
                          );
                        }).toList();
                      },
                    ),
                    SizedBox(width: 2),
                    Text('${selectedUtente != null ? "${selectedUtente?.nomeCompleto()!.toUpperCase()}" : "TUTTI"}', style: TextStyle(color: Colors.white)),
                    SizedBox(width: 6)
                  ],
                ),
              IconButton(
                icon: Icon(
                  Icons.add, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
                  color: Colors.white,
                ),
                onPressed: () {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.portraitDown,
                  ]);
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreazioneTaskPage(utente: widget.utente,)));
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
                  color: Colors.white,
                ),
                onPressed: () {
                  // Navigator.pushReplacement(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => TableTaskPage(utente: widget.utente,)));
                  getAllTask();
                  getAllTipi();
                  getAllUtenti();
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
                    child: isLoading ? Center(child: CircularProgressIndicator()) : SfDataGrid(
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
                          columnName: 'task',
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
                              'task',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          width: _columnWidths['task']?? double.nan,
                          minimumWidth: 0,
                        ),
                        GridColumn(
                          allowSorting: false,
                          columnName: 'accettatoicon',
                          label: Container(
                            padding: EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 0,
                                ),
                              ),
                            ),
                            child: Text(
                              '',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          width: _columnWidths['accettatoicon']?? double.nan,
                          minimumWidth: (widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti") ? 0 : 60,
                        ),
                        GridColumn(
                          allowSorting: false,
                          columnName: 'completed',
                          label: Container(
                            padding: EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 0,
                                ),
                              ),
                            ),
                            child: Text(
                              '',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          width: 60,//_columnWidths['task']?? double.nan,
                          minimumWidth: 60,
                        ),
                        GridColumn(
                          allowSorting: false,
                          columnName: 'delete',
                          label: Container(
                            padding: EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 0,
                                ),
                              ),
                            ),
                            child: Text(
                              '',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          width: 60,//_columnWidths['task']?? double.nan,
                          minimumWidth: 60,
                        ),
                        GridColumn(
                          allowSorting: false,
                          columnName: 'condividi',
                          label: Container(
                            padding: EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 0,
                                ),
                              ),
                            ),
                            child: Text(
                              '',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          width: _columnWidths['condividi']?? double.nan,
                          minimumWidth: (widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti") ? 60 : 0,
                        ),
                        GridColumn(
                          columnName: 'data_creazione',
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
                              'Data creazione',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          width: _columnWidths['data_creazione']?? double.nan,
                          minimumWidth: 150,
                        ),
                        /*GridColumn(
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
                          'Data Conclusione',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['data_conclusione']?? double.nan,
                      minimumWidth: 150,
                    ),*/
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
                            child: Text(
                              'Titolo',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          width: _columnWidths['titolo']?? double.nan,
                          minimumWidth: 300,
                        ),
                        /*GridColumn(
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
                          'Tipologia',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['tipologia']?? double.nan,
                      minimumWidth: 300,
                    ),*/
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
                              'Utente',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          width: _columnWidths['utente']?? double.nan,
                          minimumWidth: (widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti") ? 300 : 0,
                        ),
                        GridColumn(
                          columnName: 'accettato',
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
                              'Accettato',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          width: _columnWidths['accettato']?? double.nan,
                          minimumWidth: (widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti") ? 170 : 0,
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
                              'Data conclusione',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          width: _columnWidths['data_conclusione']?? double.nan,
                          minimumWidth: 150,
                        ),
                      ],
                      onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                        setState(() {
                          _columnWidths[details.column.columnName] = details.width;
                        });
                        return true;
                      },
                    )),
                if(widget.utente.cognome == "Mazzei" || widget.utente.cognome == "Chiriatti")
                  Flex(
                    direction: Axis.horizontal,
                    children: [
                      Expanded(
                        child: Container(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: allTipi.map((tipo) {
                                final isSelected = _currentSheet == int.parse(tipo.id!);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _changeSheet(int.parse(tipo.id!));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(horizontal: 35, vertical: 25),
                                      backgroundColor: isSelected
                                          ? Colors.red // Colore rosso per il pulsante selezionato
                                          : Colors.grey[300], // Colore grigio chiaro per i non selezionati
                                      foregroundColor: isSelected
                                          ? Colors.white // Testo bianco per il pulsante selezionato
                                          : Colors.black, // Testo nero per i non selezionati
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        side: isSelected
                                            ? BorderSide(color: Colors.red, width: 2.0) // Bordo rosso
                                            : BorderSide.none, // Nessun bordo
                                      ),
                                      elevation: isSelected ? 6.0 : 2.0, // Più elevazione se selezionato
                                    ),
                                    child: Text(
                                      tipo.descrizione!, // Mostra la descrizione
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
            floatingActionButton: widget.utente.cognome == "Mazzei" ||
                widget.utente.cognome == "Chiriatti" ?
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children : [
                FloatingActionButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        TipoTaskModel? selectedTipoToDelete;
                        return StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return AlertDialog(
                              title: Text(
                                'Scegliere una tipologia da eliminare',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: allTipi.map((tipo) {
                                  return RadioListTile<TipoTaskModel>(
                                    title: Text(tipo.descrizione!),
                                    value: tipo,
                                    groupValue: selectedTipoToDelete,
                                    onChanged: (TipoTaskModel? value) {
                                      setState(() {
                                        selectedTipoToDelete = value;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: selectedTipoToDelete == null
                                      ? null
                                      : () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Conferma Eliminazione'),
                                          content: Text(
                                            'Questa operazione cancellerà la tipologia "${selectedTipoToDelete?.descrizione}" '
                                                'e tutte le task con la tipologia scelta. Sei sicuro di voler procedere all\'eliminazione?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                // Conferma eliminazione
                                                deleteTipologia(selectedTipoToDelete);
                                                Navigator.of(context).pop(); // Chiudi il dialog di conferma
                                                Navigator.of(context).pop(); // Chiudi il dialog principale
                                              },
                                              child: Text('Sì'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Chiudi il dialog di conferma
                                              },
                                              child: Text('No'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Text('Elimina'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Chiudi il dialog principale
                                  },
                                  child: Text('Annulla'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                  backgroundColor: Colors.red,
                  child: Icon(Icons.delete, color: Colors.white),
                  heroTag: "Tag3",
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return AlertDialog(
                              title: Text(
                                'Crea una nuova Tipologia',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: _descrizioneController,
                                    onChanged: (value) {
                                      // Aggiorna lo stato del dialogo
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Nome della nuova tipologia',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                ],
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: _descrizioneController.text.isNotEmpty
                                      ? () {
                                    saveTipologia();
                                  }
                                      : null, // Disabilita il pulsante se il testo è vuoto
                                  child: Text('Salva Tipologia'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                  backgroundColor: Colors.red,
                  child: Icon(Icons.create_new_folder, color: Colors.white),
                  heroTag: "Tag2",
                ),
              ]
            ) : Container(),
        )
        );
  }

  Future<void> saveTipologia() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/tipoTask'),
        headers: {'Content-Type' : 'application/json'},
        body: jsonEncode({
          'descrizione' : _descrizioneController.text
        })
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nuova tipologia registrata con successo!'),
        ),
      );
      getAllTipi();
    } catch(e){
      print('Errore: $e');
    }
  }

  void _changeSheet(int? tipoId) {
    print('Selected Sheet ID: $tipoId'); // Debug
    setState(() {
      _currentSheet = tipoId; // Aggiorna il tipo corrente
      print('Updated _currentSheet: $_currentSheet'); // Debug

      // Filtra la lista dei dati
      if (tipoId != null) {
        _filteredCommissioni = _allCommissioni
            .where((task) {
          final taskId = task.tipologia?.id?.toString(); // Converte l'ID del task in stringa
          final tipoIdStr = tipoId.toString(); // Converte il tipo selezionato in stringa
          final matches = taskId == tipoIdStr; // Confronta come stringhe
          print('Filtering task: $taskId matches: $matches'); // Debug
          return matches;
        })
            .toList();
      } else {
        _filteredCommissioni = _allCommissioni; // Mostra tutti i dati se nullo
      }

      print('Filtered _filteredCommissioni count: ${_filteredCommissioni.length}'); // Debug

      // Aggiorna la tabella
      _dataSource.updateData(_filteredCommissioni);
    });
  }

  void filterTasksByUtente(UtenteModel utente) {
    setState(() {
      // Filtra le commissioni in base all'ID dell'utente
      _filteredCommissioni = _allCommissioni.where((commissione) {
        final taskUserId = commissione.utente?.id; // ID dell'utente nella commissione
        final selectedUserId = utente.id; // ID dell'utente selezionato
        final matches = taskUserId == selectedUserId; // Confronta gli ID
        print('Filtering task by user: $taskUserId matches: $matches'); // Debug
        return matches;
      }).toList();
      // Aggiorna i dati nella data source
      _dataSource.updateData(_filteredCommissioni);
      print('Filtered _filteredCommissioni count: ${_filteredCommissioni.length}'); // Debug
    });
  }


}

class TaskDataSource extends DataGridSource{
  List<TaskModel> _commissioni = [];
  List<TaskModel> commissioniFiltrate = [];
  BuildContext context;
  UtenteModel utente;
  List<UtenteModel> _allUtenti;
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  UtenteModel? selectedUtenteCondivisione;

  TaskDataSource(
      this.context,
      List<TaskModel> commissioni,
      this.utente,
      this._allUtenti
      ){
    _commissioni = List.from(commissioni);
    commissioniFiltrate = List.from(commissioni);
  }

  void updateData(List<TaskModel> newCommissioni){
    _commissioni.clear();
    _commissioni.addAll(newCommissioni);
    commissioniFiltrate = List.from(_commissioni);
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows{
    List<DataGridRow> rows =[];
    for(int i = 0; i < commissioniFiltrate.length; i++){
      TaskModel task = commissioniFiltrate[i];
      String? concluso = task.concluso != null ? (task.concluso != true ? "NO" : "SI") : "ERRORE";
      String? dataCreazione = DateFormat('dd/MM/yyyy').format(task.data_creazione!);
      String? dataConclusione = task.data_conclusione != null ? (DateFormat('dd/MM/yyyy').format(task.data_conclusione!)) : "NON CONCLUSO";
      String? accettato = task.accettato! ? 'ACCETTATO' : 'NON ACCETTATO';
      rows.add(DataGridRow(
        cells: [
          DataGridCell<TaskModel>(columnName: 'task', value: task),
          DataGridCell<TaskModel>(columnName: 'accettatoicon', value: task),
          DataGridCell<TaskModel>(columnName: 'completed', value: task),
          DataGridCell<TaskModel>(columnName: 'delete', value: task),
          DataGridCell<TaskModel>(columnName: 'condividi', value: task),
          DataGridCell<String>(columnName: 'data_creazione', value: dataCreazione),
          DataGridCell<String>(columnName: 'titolo', value: task.titolo),
          DataGridCell<String>(columnName: 'utente', value: task.utente?.nomeCompleto()),
          DataGridCell<String>(columnName: 'accettato', value: accettato),
          DataGridCell<String>(columnName: 'data_conclusione', value: dataConclusione),
        ]
      ));
    }
    return rows;
  }

  Future<void> conclusoTask(TaskModel task) async {
    final formatter = DateFormat(
        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"); // Crea un formatter per il formato desiderato
    //var data = selectedDate != null ? selectedDate?.toIso8601String() : null;
    //final formattedDate = _dataController.text.isNotEmpty ? _dataController  // Formatta la data in base al formatter creato
    try {
      final response = await http.post(
        Uri.parse('$ipaddress/api/task'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': task.id,
          'data_creazione': task.data_creazione!.toIso8601String(),//DateTime.now().toIso8601String(),//data, // Utilizza la data formattata
          'data_conclusione': DateTime.now().toIso8601String(),//task.data_conclusione,//null,
          'titolo' : task.titolo,//_titoloController.text,
          'descrizione': task.descrizione,//_descrizioneController.text,
          'concluso': true,
          'condiviso': task.condiviso,//_condiviso,
          'accettato': task.accettato,//false,
          'tipologia': task.tipologia?.toMap(),//_selectedTipo.toString().split('.').last,
          'utente': task.utente!.toMap(),//_condiviso ? selectedUtente?.toMap() : widget.utente,
        }),
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stato Task aggiornato con successo!'),
          ),
        );
      }

    } catch (e) {
      print('Errore durante il salvataggio del task $e');
    }
  }

  Future<void> assegnaTask(TaskModel task, UtenteModel utente) async {
    final formatter = DateFormat(
        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"); // Crea un formatter per il formato desiderato
    try {
      final response = await http.post(
        Uri.parse('$ipaddress/api/task'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': task.id,
          'data_creazione': task.data_creazione!.toIso8601String(),//DateTime.now().toIso8601String(),//data, // Utilizza la data formattata
          'data_conclusione': null,//task.data_conclusione!.toIso8601String(),//task.data_conclusione,//null,
          'titolo' : task.titolo,//_titoloController.text,
          'descrizione': task.descrizione,//_descrizioneController.text,
          'concluso': task.concluso,
          'condiviso': true,//_condiviso,
          'accettato': false,//task.accettato,//false,
          'tipologia': task.tipologia?.toMap(),//_selectedTipo.toString().split('.').last,
          'utente': utente.toMap(),//_condiviso ? selectedUtente?.toMap() : widget.utente,
        }),
      );
      if(response.statusCode == 201){
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stato Task aggiornato con successo!'),
          ),
        );
      }
      //Navigator.of(context).pop();//Navigator.pop(context);
    } catch (e) {
      print('Errore durante il salvataggio del task $e');
    }
  }

  Future<void> accettaTask(TaskModel task) async {
    final formatter = DateFormat(
        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"); // Crea un formatter per il formato desiderato
    try {
      final response = await http.post(
        Uri.parse('$ipaddress/api/task'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': task.id,
          'data_creazione': task.data_creazione!.toIso8601String(),//DateTime.now().toIso8601String(),//data, // Utilizza la data formattata
          'data_conclusione': null,//task.data_conclusione!.toIso8601String(),//task.data_conclusione,//null,
          'titolo' : task.titolo,//_titoloController.text,
          'descrizione': task.descrizione,//_descrizioneController.text,
          'concluso': task.concluso,
          'condiviso': task.condiviso,//_condiviso,
          'accettato': true,//task.accettato,//false,
          'tipologia': task.tipologia?.toMap(),//_selectedTipo.toString().split('.').last,
          'utente': task.utente!.toMap(),//_condiviso ? selectedUtente?.toMap() : widget.utente,
        }),
      );
      if(response.statusCode == 201){
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stato Task assegnata con successo!'),
          ),
        );
      }
    } catch (e) {
      print('Errore durante il salvataggio del task $e');
    }
  }

  Future<void> deleteTask(BuildContext context, String? id) async {
    try {
      final response = await http.delete(
        Uri.parse('$ipaddress/api/task/$id'),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task eliminato con successo')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TableTaskPage(utente: utente),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossibile eliminare il task')),
        );
      }
    } catch (e) {
      print('Errore durante l\'eliminazione del task: $e');
    }
  }

  Future<void> getAllTask() async{
    try{
      var apiUrl = (utente.cognome! == "Mazzei" || utente.cognome! == "Chiriatti") ? Uri.parse('$ipaddress/api/task/all')
          : Uri.parse('$ipaddress/api/task/utente/'+utente.id!);
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<TaskModel> commissioni = [];
        for(var item in jsonData){
          commissioni.add(TaskModel.fromJson(item));
        }
        if(response.statusCode == 200){
          _commissioni = commissioni;
          commissioniFiltrate = commissioni;
        }
      } else {
        //_isLoading = false;
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during API call: $e')),
      );
    } finally{
      updateData(_commissioni);
    }
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final TaskModel task = row.getCells().firstWhere(
          (cell) => cell.columnName == "task",
    ).value as TaskModel;
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
      if (dataGridCell.columnName == 'completed') {
        return IconButton(tooltip: task.concluso! ? 'TASK CONCLUSO' : 'CLICCA QUI PER CONCLUDERE IL TASK',
          icon: Icon(size: 27,
            task.concluso! ? Icons.check_circle : Icons.hourglass_bottom,
            color: task.concluso! ? Colors.green : Colors.grey,
          ), onPressed: () { task.concluso! ? null : showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('CONCLUSIONE TASK'),
                  content: Text(
                      'CONFERMI DI VOLER AGGIORNARE LO STATO DEL TASK COME CONCLUSO?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('NO'),
                    ),
                    TextButton(
                      onPressed: () {
                        conclusoTask(task);
                        //Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );

          },
        );
      } else if (dataGridCell.columnName == 'accettatoicon') {
        return IconButton(tooltip: task.accettato! ? 'TASK GIA\' ACCETTATO' : 'CLICCA QUI PER ACCETTARE IL TASK',
            icon: Icon(size: 27,
            task.accettato! ? Icons.warning : Icons.warning,
            color: task.accettato! ? Colors.grey : Colors.orange,
          ), onPressed: () {  task.accettato! ? null : showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('ACCETTA TASK'),
                content: Text(
                    'L\'AMMINISTRAZIONE HA CREATO UN TASK PER TE, CONFERMI DI AVER PRESO VISIONE?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('NO'),
                  ),
                  TextButton(
                    onPressed: () {
                      accettaTask(task);
                      //Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );},
        );
      } else if (dataGridCell.columnName == 'delete') {
        return IconButton(tooltip: 'CLICCA QUI PER ELIMINARE IL TASK',
          icon: Icon(Icons.delete, color: Colors.red, size: 27,),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('ELIMINAZIONE TASK'),
                  content: Text(
                      'CONFERMI DI VOLER ELIMINARE IL TASK DALLA LISTA?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('NO'),
                    ),
                    TextButton(
                      onPressed: () {
                        deleteTask(context, task.id);
                        //Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
        );
      } else if (dataGridCell.columnName == 'condividi') {
        return IconButton(
          tooltip: 'CONDIVIDI TASK',
          icon: Icon(Icons.send, color: Colors.grey, size: 22),
          onPressed: () {
            // Variabile locale per tracciare l'utente selezionato
            UtenteModel? localSelectedUtente = selectedUtenteCondivisione;

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder( // Consente di aggiornare lo stato nel dialog
                  builder: (BuildContext context, StateSetter setState) {
                    return AlertDialog(
                      title: Text('Condividi Task'),
                      content: SingleChildScrollView(
                        child: Container(
                          width: double.maxFinite,
                          child: Column(
                            //mainAxisSize: MainAxisSize.min,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _allUtenti.length,
                                itemBuilder: (context, index) {
                                  return RadioListTile<UtenteModel>(
                                    value: _allUtenti[index],
                                    groupValue: localSelectedUtente,
                                    onChanged: (UtenteModel? newValue) {
                                      setState(() {
                                        localSelectedUtente = newValue; // Aggiorna lo stato locale
                                      });
                                    },
                                    title: Text(_allUtenti[index].nomeCompleto()!),
                                  );
                                },
                              ),
                            ],
                          ),
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
                            if (localSelectedUtente != null) {
                              // Salva l'utente selezionato
                              assegnaTask(task, localSelectedUtente!);
                              print('Utente selezionato: ${localSelectedUtente!.nomeCompleto()}');
                            }
                          },
                          child: Text('Condividi'),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      } else {
        return GestureDetector(
            onTap: () {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
              ]);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ModificaTaskPage(utente: utente, task: task,)//DettaglioCommissioneAmministrazionePage(commissione: commissione),
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
                style: task.concluso! ? TextStyle(decoration: TextDecoration.lineThrough,) : TextStyle(),
              ),
            ),
          );
        }
      }).toList(),
    );
  }
}