import 'dart:convert';
import 'dart:io';
import 'package:fema_crm/pages/CreazioneTaskPage.dart';
import 'package:fema_crm/pages/DettaglioCommissioneAmministrazionePage.dart';
import 'package:fema_crm/pages/HomeFormAmministrazioneNewPage.dart';
import 'package:flutter/cupertino.dart';
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
import 'CestinoTaskPage.dart';
import 'ModificaTaskPage.dart';
import 'PDFTaskPage.dart';

class TableTaskPage extends StatefulWidget{
  final UtenteModel utente;
  final UtenteModel selectedUtente;
  final int tipoIdGlobal;
  const TableTaskPage({Key? key, required this.utente, required this.selectedUtente, required this.tipoIdGlobal}) : super(key: key);

  @override
  _TableTaskPageState createState() => _TableTaskPageState();
}

class _TableTaskPageState extends State<TableTaskPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';
  List<TaskModel> _allCommissioni = [];
  List<TaskModel> _filteredCommissioni = [];
  List<TaskModel> _taskFede =[];
  Map<String, double> _columnWidths ={};
  int? _currentSheet;
  bool isLoading = true;
  bool _isLoading = true;
  late TaskDataSource _dataSource;
  List<TipoTaskModel> allTipi = [];
  List<TipoTaskModel> allTipiElim = [];
  List<UtenteModel> allUtenti = [];
  UtenteModel? selectedUtente;
  UtenteModel? selectedUtenteTipo;
  TextEditingController _descrizioneController = TextEditingController();
  bool _condivisoTipo = false;
  int? tipoIdGlobal;
  List<String>? tipotaskdaacc = [];
  List<String>? tipotaskpiene = [];
  TextEditingController _titoloControllerTip = TextEditingController();

  @override
  void dispose() {
    /*SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);*/
    super.dispose();
  }

  Future<void> _refreshData() async {
    /*setState(() {
      isLoading = true;
    });*/

    // Simula un caricamento dei dati
    await Future.delayed(Duration(seconds: 2));

    // Qui dovresti aggiornare il tuo DataSource con i nuovi dati
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TableTaskPage(
          utente: widget.utente, selectedUtente: selectedUtente!, tipoIdGlobal: tipoIdGlobal!)));
    /*getAllTask();
    getAllTipi();
    getAllUtenti();*/

    /*setState(() {
      isLoading = false;
    });*/
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

  Future<void> rinominaTipoTask(TipoTaskModel tipotask) async {
    final formatter = DateFormat(
        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"); // Crea un formatter per il formato desiderato
    var titolotip = _titoloControllerTip.text.isNotEmpty ? _titoloControllerTip.text : "TIPO TASK DEL ${DateTime.now().day}/${DateTime.now().month} ORE ${DateTime.now().hour}:${DateTime.now().minute}";

    try {
      final response = await http.post(
        Uri.parse('$ipaddress/api/tipoTask'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id' : tipotask.id,
          'descrizione' : titolotip,//_titoloControllerTip.text,
          'utente' : tipotask.utente != null ? tipotask.utente?.toMap() : null,
          'utentecreate' : tipotask.utentecreate?.toMap()
        }),
      );
      if(response.statusCode == 201){
        //Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tipologia Task rinominato con successo!'.toUpperCase()),
          ),
        );
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TableTaskPage(
              utente: widget.utente, selectedUtente: selectedUtente!, tipoIdGlobal: tipoIdGlobal!,)));
        /*Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => TableTaskPage(
              utente: utente, selectedUtente: selectedUtente, tipoIdGlobal: tipoIdGlobal)),
              (Route<dynamic> route) => false, // Rimuove tutte le pagine precedenti
        );*/
        /*Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TableTaskPage(
                utente: utente, selectedUtente: selectedUtente, tipoIdGlobal: tipoIdGlobal)));*/
      }
    } catch (e) {
      print('Errore durante la modifica del task $e');
    }
  }

  @override
  void initState() {
    super.initState();
    //_setPreferredOrientation();
    _columnWidths = {
      'task': 0,
      'accettatoicon': 60,//(widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti") ? 0 : 60,
      'completed': 60,
      'delete': 60,
      'condividi': (tipoIdGlobal.toString() == '9' || tipoIdGlobal.toString() == '10') ? 60 : 0,//(widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti") ? 60 : 0,
      'data_creazione': 150,
      'titolo': 300,
      'riferimento': 300,
      'utente': (widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti") ? 200 : 0,
      'accettato': (widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti") ? 170 : 0,
      'data_conclusione': 150,
    };

    setState(() {

      selectedUtente = widget.selectedUtente;//allUtenti.firstWhere((element) => element.id == widget.utente.id);
      //if(widget.utente.cognome == "Mazzei"){
      tipoIdGlobal = widget.tipoIdGlobal;//9;
      //}
    });
    print(tipoIdGlobal.toString()+''+widget.tipoIdGlobal.toString());
    initializeData();
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

        selectedUtente = widget.selectedUtente;//allUtenti.firstWhere((element) => element.id == widget.utente.id);
        //if(widget.utente.cognome == "Mazzei"){
        tipoIdGlobal = widget.tipoIdGlobal;//9;


      if (_allCommissioni.any((element) => element.attivo == true && (element.utente!.id == selectedUtente!.id || element.utentecreate?.id != selectedUtente!.id))) {

        tipotaskpiene = _allCommissioni
            .where((element) => element.attivo == true && (element.utente!.id == selectedUtente!.id || element.utentecreate?.id == selectedUtente!.id))
            .map((element) => element.tipologia?.id).cast<String>()
            .toList();
      }
      print(tipotaskpiene.toString()+' '+tipoIdGlobal!.toString());
      if (tipotaskpiene != null && tipotaskpiene!.isNotEmpty && !tipotaskpiene!.contains(tipoIdGlobal.toString())) tipoIdGlobal = int.parse(tipotaskpiene!.first);
      print(tipotaskpiene.toString()+' '+tipoIdGlobal!.toString());
      print('Inizio filtraggio delle commissioni...');
      //if (widget.utente.cognome! == "Mazzei") {
        print('Utente Mazzei rilevato. Applicazione del filtro per tipologia id = 9 e cognome Mazzei...');
        _filteredCommissioni = _allCommissioni.where((task) {
          print(
              'Task: ${task.titolo}, Tipologia ID: ${widget.tipoIdGlobal}, Utente : ${selectedUtente!.id}');

          return task.attivo == true && task.tipologia?.id! == tipoIdGlobal.toString() &&
              (task.utente?.id! == selectedUtente!.id! || task.utentecreate?.id! == selectedUtente!.id!);
          //return task.tipologia?.id == "9" && task.utente?.cognome == "Mazzei";
        }).toList();
        print('Numero di task filtrati: ${_filteredCommissioni.length}');
      /*} else {
        _filteredCommissioni = _allCommissioni.toList();
        print('Nessun filtro applicato, tutte le task assegnate a _filteredCommissioni.');
      }*/
      //List<String> ids = [];

      // Verifica se almeno un elemento soddisfa la condizione e aggiungi gli id
      if (_allCommissioni.any((element) => element.utente!.id == widget.utente.id && element.attivo == true && element.accettato == false &&
          element.utentecreate?.id != widget.utente.id)) {

        tipotaskdaacc = _allCommissioni
            .where((element) => element.utente!.id == widget.utente.id && element.attivo == true && element.accettato == false &&
            element.utentecreate?.id != widget.utente.id)
            .map((element) => element.tipologia?.id).cast<String>()
            .toList();
      }

      _filteredCommissioni.sort((a, b) {
        if (a.concluso! == b.concluso!) {
          return b.data_conclusione != null && a.data_conclusione != null ? b.data_conclusione!.compareTo(a.data_conclusione!) : -1;
        } else {
          return a.concluso! ? 1 : -1;
        }
      });
      /*_filteredCommissioni.sort((a, b) {
        if (a.concluso! && !b.concluso!) return 1;
        if (!a.concluso! && b.concluso!) return -1;
        return (a.concluso! && b.concluso! && b.data_conclusione != null && a.data_conclusione != null) ? b.data_conclusione!.compareTo(a.data_conclusione!) : 1;
      });*/
      //_filteredCommissioni.sort((a, b) => a!.concluso! ? 1 : 0);
      /*sort((a, b) {
        if (a!.concluso! && !b.concluso) return 1;
        if (!a.concluso && b.concluso) return -1;
        return 0;
      });*/
      //_filteredCommissioni.any((element) => !element.accettato! && element.utentecreate!.id != widget.utente.id ? element.tipologia.id));
      _dataSource = TaskDataSource(context, _filteredCommissioni, widget.utente, List.from(allUtenti), selectedUtente!, tipoIdGlobal!);

      //print(tipotaskdaacc!.first.toString()+' Datasource inizializzato con ${_filteredCommissioni.last.id} task.'+widget.utente.id.toString());
    });
    print('Inizializzazione completata. '+tipotaskpiene.toString());
  }

  Future<void> getAllUtenti() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/utente/attivo');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<UtenteModel> utenti = [];
        for (var item in jsonData) {
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          allUtenti = utenti;

          //if (widget.utente.cognome! == "Mazzei")
            //selectedUtente = widget.selectedUtente;//utenti.firstWhere((element) => element.id == widget.utente.id);
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

  Future<List<TipoTaskModel>> getTaskByTipo(String tipologiatask) async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/task/tipologia/$tipologiatask');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<TipoTaskModel> utenti = [];
        for (var item in jsonData) {
          utenti.add(TipoTaskModel.fromJson(item));
        }
        print(tipologiatask+' taskbytip '+utenti.length.toString());
        return utenti;
      } else {
        throw Exception(
            'Failed to load utenti data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching agenti data from API: $e');
      throw Exception(
          'Failed to load utenti data from API: $e');
      /*showDialog(
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
      );*/
    }
  }

  Future<void> getAllTipi() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/tipoTask');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<TipoTaskModel> tipi = [];
        List<TipoTaskModel> tipielim = [];
        for(var item in jsonData){
          if (widget.utente.cognome! == "Mazzei" ||
              (TipoTaskModel.fromJson(item).utentecreate!.id == widget.utente.id)
              || (TipoTaskModel.fromJson(item).utente == null && (TipoTaskModel.fromJson(item).id == '9' || TipoTaskModel.fromJson(item).id == '10'))
          || (TipoTaskModel.fromJson(item).utente != null && TipoTaskModel.fromJson(item).utente!.id == widget.utente.id))
          tipi.add(TipoTaskModel.fromJson(item));
          if (//widget.utente.cognome! == "Mazzei" ||
              (TipoTaskModel.fromJson(item).utentecreate!.id == widget.utente.id)
              //|| (TipoTaskModel.fromJson(item).utente == null && (TipoTaskModel.fromJson(item).id == '9' || TipoTaskModel.fromJson(item).id == '10'))
              //|| (TipoTaskModel.fromJson(item).utente != null && TipoTaskModel.fromJson(item).utente!.id == widget.utente.id)
          )
            tipielim.add(TipoTaskModel.fromJson(item));
        }
        setState(() {
          //tipoIdGlobal = int.parse(tipi.first.id!);
          allTipi = tipi;
          allTipiElim = tipielim;
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
          ? Uri.parse('$ipaddress/api/task/allattivi')
          : Uri.parse('$ipaddress/api/task/utente/' + widget.utente!.id!);
      print('Chiamata API verso: $apiUrl');
      final response = await http.get(apiUrl);
      print('Risposta ricevuta con status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        var jsonData = json.decode(utf8.decode(response.bodyBytes));
        print(response.body.toString()+' Dati ricevuti: ${jsonData.length} elementi trovati. '+jsonData.toString());
        List<TaskModel> commissioni = [];
        for (var item in jsonData) {

          commissioni.add(TaskModel.fromJson(item));
        }
        print('Numero di task convertiti: ${commissioni.length}');
        setState(() {
          _isLoading = false;
          _allCommissioni = commissioni;
          if (_allCommissioni.any((element) => element.attivo == true && (element.utente!.id == selectedUtente!.id || element.utentecreate?.id != selectedUtente!.id))) {

            tipotaskpiene = _allCommissioni
                .where((element) => element.attivo == true && (element.utente!.id == selectedUtente!.id || element.utentecreate?.id == selectedUtente!.id))
                .map((element) => element.tipologia?.id).cast<String>()
                .toList();
          }
          if (tipotaskpiene != null && tipotaskpiene!.isNotEmpty && !tipotaskpiene!.contains(tipoIdGlobal.toString())) tipoIdGlobal = int.parse(tipotaskpiene!.first);
          print('Tutte le commissioni assegnate a _allCommissioni: ${_allCommissioni.length} task.');
          // Applica il filtro iniziale per filteredCommissioni se l'utente è Mazzei
          //if (widget.utente.cognome! == "Mazzei") {
            print('Filtraggio per utente Mazzei con tipologia id = 9...');
            _filteredCommissioni = commissioni.where((task) {
              print('Task: ${task.titolo}, Tipologia: ${task.tipologia?.id}, Utente: ${task.utente?.cognome}');
              return task.attivo == true && task.tipologia?.id! == tipoIdGlobal.toString() && (task.utente?.id! == selectedUtente!.id! ||
                  task.utentecreate?.id! == selectedUtente!.id!);
              //return task.tipologia?.id == "9" && task.utente?.cognome == "Mazzei";
            }).toList();
            print('Numero di task filtrati: ${_filteredCommissioni.length}');
          /*} else {
            _filteredCommissioni = commissioni;
            print('Nessun filtro applicato, tutte le task assegnate a _filteredCommissioni.');
          }*/
          if (_allCommissioni.any((element) => element.utente!.id == widget.utente.id && element.attivo == true &&
              !element.accettato! && element.utentecreate!.id != widget.utente.id)) {
            tipotaskdaacc = _allCommissioni
                .where((element) => element.utente!.id == widget.utente.id && element.attivo == true && !element.accettato! && element.utentecreate!.id != widget.utente.id)
                .map((element) => element.tipologia!.id).cast<String>()
                .toList();
          }
          _filteredCommissioni.sort((a, b) {
            if (a.concluso! == b.concluso!) {
              return b.data_conclusione != null && a.data_conclusione != null ? b.data_conclusione!.compareTo(a.data_conclusione!) : -1;
            } else {
              return a.concluso! ? 1 : -1;
            }
          });
          /*_filteredCommissioni.sort((a, b) {
            if (a.concluso! && !b.concluso!) return 1;
            if (!a.concluso! && b.concluso!) return -1;
            return a.concluso! && b.concluso! && b.data_conclusione != null && a.data_conclusione != null ? b.data_conclusione!.compareTo(a.data_conclusione!) : 1;
          });*/
          //_filteredCommissioni.sort((a, b) => a!.concluso! ? 1 : 0);
          _dataSource = TaskDataSource(context, _filteredCommissioni, widget.utente, allUtenti, selectedUtente!, tipoIdGlobal!);
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
          /*SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);*/
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('LISTA TASK', style: TextStyle(color: Colors.white)),
            centerTitle: Platform.isAndroid ? false : true,
            backgroundColor: Colors.red,
            actions: [
              if(widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti")
                Row(
                  children: [
                    PopupMenuButton<UtenteModel>(
                      icon: //Icon(Icons.person, color: Colors.white), // Icona della casa
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.white), // Icona dell'utente
                          SizedBox(width: 3), // Spazio tra l'icona e il nome
                          Text(
                            selectedUtente != null ? selectedUtente!.nome!.toUpperCase()+' '+selectedUtente!.cognome!.substring(0,1)+'.' : 'Seleziona Utente',
                            style: TextStyle(color: Colors.white), // Colore del testo
                          ),
                        ],
                      ),
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
                    //SizedBox(width: 2),
                    //Text('${selectedUtente != null ? selectedUtente!.nome!.toUpperCase()+' '+selectedUtente!.cognome!.substring(0,1)+'.' : "UTENTE"}', style: TextStyle(color: Colors.white)),
                    //SizedBox(width: 6)
                  ],
                ),
              IconButton(
                icon: Icon(
                  Icons.add, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
                  color: Colors.white,
                ),
                onPressed: () {
                  /*SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.portraitDown,
                  ]);*/
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreazioneTaskPage(utente: widget.utente,))).then((value) {
                    if (value == 'aggiorna') {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => TableTaskPage(
                            utente: widget.utente, selectedUtente: selectedUtente!, tipoIdGlobal: tipoIdGlobal!,)));
                      //setState(() {}); // Aggiorna la pagina
                    }
                  });
                },
              ),
              IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.download), onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PDFTaskPage(timbrature: _filteredCommissioni),
                  ),
                );
              }),
              //widget.utente.cognome! == "Mazzei" ?
              IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.delete_forever), onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CestinoTaskPage(utente: widget.utente, selectedUtente: selectedUtente!, tipoIdGlobal: tipoIdGlobal!,),
                  ),
                );
              }),// : Container(),
              (widget.utente.id == "2" && Platform.isAndroid) ? Container() : IconButton(
                icon: Icon(
                  Icons.refresh, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
                  color: Colors.white,
                ),
                onPressed: () {
                  print(selectedUtente!.id.toString()+' bbb '+tipoIdGlobal.toString());
                   Navigator.pushReplacement(
                       context,
                       MaterialPageRoute(builder: (context) => TableTaskPage(
                         utente: widget.utente, selectedUtente: selectedUtente!, tipoIdGlobal: tipoIdGlobal!,)));
                  /*getAllTask();
                  getAllTipi();
                  getAllUtenti();*/
                },
              ),
            ],
          ),
          body: LayoutBuilder(
              builder: (context, constraints) { return Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                SizedBox(height: 10),
                Expanded(
                    child: RefreshIndicator(
                        onRefresh: _refreshData,
                        child: isLoading ? Center(child: CircularProgressIndicator()) : SfDataGrid(
                          headerRowHeight: 53,
                      //allowPullToRefresh: true,
                      allowSorting: true,
                      source: _dataSource,
                      columnWidthMode: ColumnWidthMode.auto,
                      /*footer: _dataSource.rows.isEmpty
                          ?  Text('Nessun risultato')
                          : null,*/
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
                          width: (constraints.maxWidth < 460) ? 45 : 60,//_columnWidths['accettatoicon']?? double.nan,
                          minimumWidth: 60//(widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti") ? 0 : 60,
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
                          width: (constraints.maxWidth < 460) ? 45 : 60,//_columnWidths['task']?? double.nan,
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
                          width: (constraints.maxWidth < 460) ? 45 : 60,//_columnWidths['task']?? double.nan,
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
                          width: (tipoIdGlobal.toString() == '9' || tipoIdGlobal.toString() == '10') ? (constraints.maxWidth < 460) ? 45 : 60 : 0,//_columnWidths['condividi']?? double.nan,
                          minimumWidth: (tipoIdGlobal.toString() == '9' || tipoIdGlobal.toString() == '10') ? 60 : 0,
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
                              'DATA\nCREAZIONE',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          width: (constraints.maxWidth < 460) ? 100 : 150,//_columnWidths['data_creazione']?? double.nan,
                          minimumWidth: (constraints.maxWidth < 460) ? 100 : 150,
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
                              'TITOLO',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          width: (constraints.maxWidth < 460) ? 170 : 300,//_columnWidths['titolo']?? double.nan,
                          minimumWidth: (constraints.maxWidth < 460) ? 170 : 300,
                        ),
                        GridColumn(
                          columnName: 'riferimento',
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
                              'RIFERIMENTO',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          width: (constraints.maxWidth < 460) ? 170 : 300,//_columnWidths['titolo']?? double.nan,
                          minimumWidth: (constraints.maxWidth < 460) ? 170 : 300,
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
                              'UTENTE',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          width: (constraints.maxWidth < 460) ? 140 : 300,//_columnWidths['utente']?? double.nan,
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
                              'ACCETTATO',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          width: (constraints.maxWidth < 460) ? 110 : 170,//_columnWidths['accettato']?? double.nan,
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
                              'DATA\nCONCLUSIONE',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          width: (constraints.maxWidth < 460) ? 125 : 150,//_columnWidths['data_conclusione']?? double.nan,
                          minimumWidth: (constraints.maxWidth < 460) ? 125 : 150,
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
                ),

                //if(widget.utente.cognome == "Mazzei" || widget.utente.cognome == "Chiriatti" || widget.utente.ruolo!.id == '3')
                //SizedBox(height: 5,),
                Flex(
                    crossAxisAlignment : CrossAxisAlignment.end,
                    direction: Axis.horizontal,
                    children: [
                      SizedBox(height:5),
                      Expanded(
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: tipotaskpiene != null && tipotaskpiene!.isNotEmpty ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: allTipi.map((tipo) {
                                    print(tipoIdGlobal.toString()+' mmm '+tipo.id!);
                                    final isSelected = tipoIdGlobal == int.parse(tipo.id!);
                                    return (tipotaskpiene!.isNotEmpty && tipotaskpiene!.contains(tipo.id)) ?
                                      GestureDetector(
                                        onLongPress: () {

                                        _titoloControllerTip = TextEditingController(text: tipo.descrizione!.toUpperCase());
                                        //utente.id == task.utentecreate!.id ?
                                        tipo.utentecreate!.id == widget.utente.id ? showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return StatefulBuilder( // Consente di aggiornare lo stato nel dialog
                                              builder: (BuildContext context, StateSetter setState) {
                                                return AlertDialog(
                                                  title: Text('RINOMINA TIPOLOGIA TASK \n\"'.toUpperCase()+tipo.descrizione!.toUpperCase()+'\"',
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                  ),),
                                                  //content: Text('RINOMINA TASK\n\"'.toUpperCase()+task.titolo!.toUpperCase()+'\"'),
                                                  actions: [
                                                    SizedBox(
                                                      width: 600,
                                                      child: TextFormField(
                                                        controller: _titoloControllerTip,
                                                        maxLines: null,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black87,
                                                        ),
                                                        decoration: InputDecoration(
                                                          labelText: 'Titolo'.toUpperCase(),
                                                          labelStyle: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.grey[600],
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                          filled: true,
                                                          fillColor: Colors.grey[200],
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                            borderSide: BorderSide.none, // Rimuove il bordo standard
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                            borderSide: BorderSide(
                                                              color: Colors.redAccent,
                                                              width: 2.0,
                                                            ),
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                            borderSide: BorderSide(
                                                              color: Colors.grey[300]!,
                                                              width: 1.0,
                                                            ),
                                                          ),
                                                          hintText: "Inserisci il titolo",
                                                          hintStyle: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.grey[500],
                                                          ),
                                                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                                        ),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text('Annulla'.toUpperCase()),
                                                    ),
                                                    ElevatedButton(

                                                      onPressed: () {
                                                        rinominaTipoTask(tipo);
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text('SALVA'.toUpperCase(), style: TextStyle(fontSize: 18)),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ) : null;// : null;
                                      },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                      child: Container(
                                        //width: 120, // Larghezza del pulsante
                                        //height: 50, // Altezza del pulsante
                                          child: Container(
                                            clipBehavior: Clip.none, // Permette all'icona di uscire dal contorno
                                            child: Stack(
                                              clipBehavior: Clip.none, // Permette agli elementi di uscire dai bordi
                                              alignment: Alignment.center, // Centra gli elementi all'interno del pulsante
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    _changeSheet(int.parse(tipo.id!));
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                    backgroundColor: isSelected ? Colors.red : Colors.grey[300],
                                                    foregroundColor: isSelected ? Colors.white : Colors.black,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8.0),
                                                    ),
                                                    elevation: isSelected ? 6.0 : 2.0,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        tipo.descrizione!.toUpperCase(),
                                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                      ),
                                                      if (tipo.utente != null && tipo.utente != tipo.utentecreate)
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.send,
                                                              color: Colors.teal,
                                                              size: 18,
                                                            ),
                                                            Text(
                                                              ' ' +
                                                                  ((widget.utente.id != tipo.utente!.id)
                                                                      ? tipo.utente!.nome! +
                                                                      " " +
                                                                      tipo.utente!.cognome!.substring(0, 1) +
                                                                      "."
                                                                      : tipo.utentecreate!.nome! +
                                                                      " " +
                                                                      tipo.utentecreate!.cognome!.substring(0, 1) +
                                                                      "."),
                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                if (selectedUtente!.id == widget.utente.id && tipotaskdaacc!.isNotEmpty && tipotaskdaacc!.contains(tipo.id))
                                                  Positioned(
                                                    right: -5, // Posizione migliore senza taglio
                                                    top: -1, // Posizione migliore senza taglio
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.amber,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black26,
                                                            blurRadius: 4,
                                                            offset: Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(3.0),
                                                        child: Icon(
                                                          Icons.warning_outlined,
                                                          color: Colors.black,
                                                          size: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          )),
                                    )
                                      ) : Container();
                                  }).toList(),
                                ) : SizedBox(
                                  child: Text(' - NESSUN TASK DISPONIBILE -'),
                                height: 49,) ,
                              ),
                            ],
                          )
                        ),
                      ),
                    ],
                  )
              ],
            ),
          );}),
            //floatingActionButton: (widget.utente.cognome == "Mazzei" ||
            //    widget.utente.cognome == "Chiriatti" || widget.utente.ruolo!.id == '3') ?
          floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children : [
                allTipiElim.isNotEmpty ? FloatingActionButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        TipoTaskModel? selectedTipoToDelete;
                        return StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            bool eliminabile = false;
                            return AlertDialog(
                              title: Text(
                                'Scegliere una tipologia da eliminare'.toUpperCase(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              content: SingleChildScrollView( // Aggiungi SingleChildScrollView qui
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: allTipiElim.map((tipo) {
                                  return RadioListTile<TipoTaskModel>(
                                    title: Text(tipo.descrizione!.toUpperCase(),
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                    ),
                                    value: tipo,
                                    groupValue: selectedTipoToDelete,
                                    onChanged: (TipoTaskModel? value) {
                                      setState(() {
                                        selectedTipoToDelete = value;


                                      });
                                    },
                                  );
                                }).toList(),
                              )),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: selectedTipoToDelete == null
                                      ? null
                                      : () {
                                    getTaskByTipo(selectedTipoToDelete!.id!).then((valuee) => valuee.isEmpty ?
                                      showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Conferma Eliminazione'.toUpperCase()),
                                          content: Text(
                                            'La tipologia "${selectedTipoToDelete?.descrizione!.toUpperCase()}" non ha dei task associati ad essa, è pertanto '
                                                'consentita la sua eliminazione. Vuoi procedere?'.toUpperCase(),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                // Conferma eliminazione
                                                deleteTipologia(selectedTipoToDelete);
                                                Navigator.of(context).pop(); // Chiudi il dialog di conferma
                                                Navigator.of(context).pop(); // Chiudi il dialog principale
                                              },
                                              child: Text('SI'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Chiudi il dialog di conferma
                                              },
                                              child: Text('NO'),
                                            ),
                                          ],
                                        );/* : AlertDialog(
                                          title: Text('ELIMINAZIONE NON CONSENTITA'.toUpperCase()),
                                          content: Text(
                                            'ESISTONO ANCORA DEI TASK ASSOCIATI ALLA TIPOLOGIA "${selectedTipoToDelete?.descrizione!.toUpperCase()}" '
                                                'PERTANTO NON è POSSIBILE ELIMINARLA. '.toUpperCase(),
                                          ),
                                          actions: [

                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Chiudi il dialog di conferma
                                              },
                                              child: Text('OK'),
                                            ),
                                          ],
                                        );*/
                                      },
                                    ) : showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('ELIMINAZIONE NON CONSENTITA'.toUpperCase()),
                                          content: Text(
                                            'ESISTONO ANCORA DEI TASK ASSOCIATI ALLA TIPOLOGIA "${selectedTipoToDelete?.descrizione!.toUpperCase()}", '
                                                'PERTANTO NON è POSSIBILE ELIMINARLA. '.toUpperCase(),
                                          ),
                                          actions: [

                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Chiudi il dialog di conferma
                                              },
                                              child: Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    ));
                                  },
                                  child: Text('ELIMINA'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Chiudi il dialog principale
                                  },
                                  child: Text('ANNULLA'),
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
                ) : Container(),
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
                                'CREA NUOVA TIPOLOGIA',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: 10),
                                  TextFormField(
                                    controller: _descrizioneController,
                                    onChanged: (value) {
                                      // Aggiorna lo stato del dialogo
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'NOME NUOVA TIPOLOGIA',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  SizedBox(
                                    width: 200,
                                    child: CheckboxListTile(
                                      title: Text('CONDIVIDI'),
                                      value: _condivisoTipo,
                                      onChanged: (value) {
                                        setState(() {
                                          _condivisoTipo = value!;
                                          /*if (_condiviso) {
                                            _condivisoController.clear();
                                          }*/
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 15),// But
                                  if (_condivisoTipo) SizedBox(
                                    //width: 400,
                                    child: DropdownButtonFormField<UtenteModel>(
                                      value: selectedUtenteTipo,
                                      onChanged: (UtenteModel? newValue) {
                                        setState(() {
                                          selectedUtenteTipo = newValue;
                                        });
                                      },
                                      items: allUtenti.map<DropdownMenuItem<UtenteModel>>((UtenteModel utente) {
                                        return DropdownMenuItem<UtenteModel>(
                                          value: utente,
                                          child: Text(
                                            utente.nomeCompleto()!.toUpperCase(),
                                            style: TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                        );
                                      }).toList(),
                                      decoration: InputDecoration(
                                        labelText: 'SELEZIONA UTENTE',
                                        labelStyle: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[200],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: Colors.redAccent,
                                            width: 2.0,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                            width: 1.0,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                      ),
                                      validator: (value) {
                                        if (value == null) {
                                          return 'SELEZIONA UN UTENTE';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),


                                ],
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: _descrizioneController.text.isNotEmpty
                                      ? () {
                                    saveTipologia();
                                  }
                                      : null, // Disabilita il pulsante se il testo è vuoto
                                  child: Text('SALVA TIPOLOGIA'),
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
                SizedBox(height: 50),
              ]
            ),// : Container(),
        )
        );
  }

  Future<void> saveTipologia() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/tipoTask'),
        headers: {'Content-Type' : 'application/json'},
        body: jsonEncode({
          'descrizione' : _descrizioneController.text,
          'utente' : _condivisoTipo ? selectedUtenteTipo : null,
          'utentecreate' : widget.utente
        })
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nuova tipologia registrata con successo!'.toUpperCase()),
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
      tipoIdGlobal = tipoId; // Aggiorna il tipo corrente
      print('Updated _currentSheet: $tipoIdGlobal'); // Debug

      // Filtra la lista dei dati
      if (tipoId != null) {
        print('utente selez? '+selectedUtente!.id.toString());
        _filteredCommissioni = _allCommissioni
            .where((task) {
          final taskId = task.tipologia?.id?.toString(); // Converte l'ID del task in stringa
          final tipoIdStr = tipoId.toString(); // Converte il tipo selezionato in stringa

          final taskUserId = task.utente?.id; // ID dell'utente nella commissione
          final taskUsercreateId = task.utentecreate?.id; // ID dell'utentecreate
          final selectedUserId = selectedUtente!.id; // ID dell'utente selezionato
          //final matches = taskUserId == selectedUserId; // Confronta gli ID

          final matches = (task.attivo == true && taskId == tipoIdStr && (taskUserId == selectedUserId || taskUsercreateId == selectedUserId));
              //|| (task.tipologia!.utente != null && task.tipologia!.utente!.id == selectedUserId); // Confronta come stringhe
          print('Filtering task: $taskId matches: $matches'); // Debug
          return matches;
        })
            .toList();
      } else {
        _filteredCommissioni = _allCommissioni; // Mostra tutti i dati se nullo
      }

      print('Filtered _filteredCommissioni count: ${_filteredCommissioni.length}'); // Debug
      if (_allCommissioni.any((element) => element.utente!.id == widget.utente.id && element.attivo == true && !element.accettato! &&
          element.utentecreate!.id != widget.utente.id)) {
        tipotaskdaacc = _allCommissioni
            .where((element) => element.utente!.id == widget.utente.id && element.attivo == true && !element.accettato! && element.utentecreate!.id != widget.utente.id)
            .map((element) => element.tipologia!.id).cast<String>()
            .toList();
      }
      if (_allCommissioni.any((element) => element.attivo == true && (element.utente!.id == selectedUtente!.id || element.utentecreate?.id != selectedUtente!.id))) {

        tipotaskpiene = _allCommissioni
            .where((element) => element.attivo == true && (element.utente!.id == selectedUtente!.id || element.utentecreate?.id == selectedUtente!.id))
            .map((element) => element.tipologia?.id).cast<String>()
            .toList();
      }
      // Aggiorna la tabella
      _filteredCommissioni.sort((a, b) {
        if (a.concluso! == b.concluso!) {
          return b.data_conclusione != null && a.data_conclusione != null ? b.data_conclusione!.compareTo(a.data_conclusione!) : -1;
        } else {
          return a.concluso! ? 1 : -1;
        }
      });
      /*_filteredCommissioni.sort((a, b) {
        if (a.concluso! && !b.concluso!) return 1;
        if (!a.concluso! && b.concluso!) return -1;
        return a.concluso! && b.concluso! && b.data_conclusione != null && a.data_conclusione != null ? b.data_conclusione!.compareTo(a.data_conclusione!) : 1;
      });*/
      //_filteredCommissioni.sort((a, b) => a!.concluso! ? 1 : 0);
      _dataSource.updateData(_filteredCommissioni, selectedUtente!, tipoIdGlobal!);
    });
  }

  void filterTasksByUtente(UtenteModel utente) {
    setState(() {
      if (_allCommissioni.any((element) => element.attivo == true && (element.utente!.id == selectedUtente!.id || element.utentecreate?.id != selectedUtente!.id))) {

        tipotaskpiene = _allCommissioni
            .where((element) => element.attivo == true && (element.utente!.id == selectedUtente!.id || element.utentecreate?.id == selectedUtente!.id))
            .map((element) => element.tipologia?.id).cast<String>()
            .toList();
      }
      if (tipotaskpiene != null && tipotaskpiene!.isNotEmpty && !tipotaskpiene!.contains(tipoIdGlobal.toString())) tipoIdGlobal = int.parse(tipotaskpiene!.first);
      // Filtra le commissioni in base all'ID dell'utente
      _filteredCommissioni = _allCommissioni.where((commissione) {
        final taskId = commissione.tipologia?.id?.toString(); // Converte l'ID del task in stringa
        final tipoIdStr = commissione.toString(); // Converte il tipo selezionato in stringa
        final taskUserId = commissione.utente?.id; // ID dell'utente nella commissione
        final taskUsercreateId = commissione.utentecreate?.id; // ID dell'utentecreate
        final selectedUserId = utente.id; // ID dell'utente selezionato
        final matches = commissione.attivo == true && (taskUserId == selectedUserId || taskUsercreateId == selectedUserId) &&
            taskId == tipoIdGlobal.toString();
            //|| (commissione.tipologia!.utente != null && commissione.tipologia!.utente!.id == selectedUserId); // Confronta gli ID
        print('Filtering task by user: $taskUserId matches: $matches'); // Debug
        return matches;
      }).toList();
      if (_allCommissioni.any((element) => element.utente!.id == widget.utente.id && element.attivo == true && !element.accettato! && element.utentecreate!.id != widget.utente.id)) {
        tipotaskdaacc = _allCommissioni
            .where((element) => element.utente!.id == widget.utente.id && element.attivo == true && !element.accettato! && element.utentecreate!.id != widget.utente.id)
            .map((element) => element.tipologia!.id).cast<String>()
            .toList();
      }

      // Aggiorna i dati nella data source
      _filteredCommissioni.sort((a, b) {
        if (a.concluso! == b.concluso!) {
          return b.data_conclusione != null && a.data_conclusione != null ? b.data_conclusione!.compareTo(a.data_conclusione!) : -1;
        } else {
          return a.concluso! ? 1 : -1;
      }
      });
      /*_filteredCommissioni.sort((a, b) {
        if (a.concluso! && !b.concluso!) return 1;
        if (!a.concluso! && b.concluso!) return -1;
        return a.concluso! && b.concluso! && b.data_conclusione != null && a.data_conclusione != null ? b.data_conclusione!.compareTo(a.data_conclusione!) : 1;
      });*/
      //_filteredCommissioni.sort((a, b) => a!.concluso! ? 1 : 0);
      _dataSource.updateData(_filteredCommissioni, utente, tipoIdGlobal!);
      print(tipotaskdaacc!.length.toString()+'Filtered _filteredCommissioni count: ${_filteredCommissioni.length}'); // Debug
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
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';
  UtenteModel? selectedUtenteCondivisione;
  UtenteModel selectedUtente;
  int tipoIdGlobal;
  TextEditingController _titoloController = TextEditingController();
  TextEditingController _riferimentoController = TextEditingController();
  TextEditingController _descrizioneController = TextEditingController();


  TaskDataSource(
      this.context,
      List<TaskModel> commissioni,
      this.utente,
      this._allUtenti,
      this.selectedUtente,
      this.tipoIdGlobal,
      ){
    _commissioni = List.from(commissioni);
    commissioniFiltrate = List.from(commissioni);
  }

  void updateData(List<TaskModel> newCommissioni, UtenteModel selectedUtent, int tipoIdGloba){
    this.selectedUtente = selectedUtent;
    this.tipoIdGlobal = tipoIdGloba;
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
      print('tiiiiiiiiiiiii '+task.titolo.toString());
      String? concluso = task.concluso != null ? (task.concluso != true ? "NO" : "SI") : "ERRORE";
      String? dataCreazione = DateFormat('dd/MM/yyyy').format(task.data_creazione!);
      String? dataConclusione = task.data_conclusione != null ? (DateFormat('dd/MM/yyyy HH:mm').format(task.data_conclusione!)) : "NON CONCLUSO";
      String? accettato = task.accettato! ? 'ACCETTATO' : 'NON ACCETTATO';
      rows.add(DataGridRow(
        cells: [
          DataGridCell<TaskModel>(columnName: 'task', value: task),
          DataGridCell<TaskModel>(columnName: 'accettatoicon', value: task),
          DataGridCell<TaskModel>(columnName: 'completed', value: task),
          DataGridCell<TaskModel>(columnName: 'delete', value: task),
          DataGridCell<TaskModel>(columnName: 'condividi', value: task),
          DataGridCell<String>(columnName: 'data_creazione', value: dataCreazione),
          DataGridCell<String>(columnName: 'titolo', value: task.titolo!.toUpperCase()),
          DataGridCell<String>(columnName: 'riferimento', value: task.riferimento != null && task.riferimento != '' ? task.riferimento!.toUpperCase() : '//'),
          //DataGridCell<String>(columnName: 'utente', value: task.utente?.nomeCompleto()),
          DataGridCell<String>(columnName: 'utente', value: task.condiviso == true ?
            "${task.utentecreate?.nome!} ${task.utentecreate?.cognome?.substring(0,1)}.${String.fromCharCode(10132)}${task.utente?.nome!} ${task.utente?.cognome?.substring(0,1)}." :
            "${selectedUtente.nomeCompleto()}"),
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
          'riferimento': task.riferimento,
          'descrizione': task.descrizione,//_descrizioneController.text,
          'concluso': true,
          'condiviso': task.condiviso,//_condiviso,
          'accettato': task.accettato,//false,
          'tipologia': task.tipologia?.toMap(),//_selectedTipo.toString().split('.').last,
          'utente': task.utente!.toMap(),//_condiviso ? selectedUtente?.toMap() : widget.utente,
          'utentecreate': task.utentecreate!.toMap(),//_condiviso ? selectedUtente?.toMap() : widget.utente,
          'attivo': task.attivo,
        }),
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stato Task aggiornato con successo! '.toUpperCase()),
          ),
        );
        //await Future.delayed(Duration(seconds: 2));
        // Qui dovresti aggiornare il tuo DataSource con i nuovi dati
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TableTaskPage(
                utente: utente, selectedUtente: selectedUtente, tipoIdGlobal: tipoIdGlobal)));
      }
    } catch (e) {
      print('Errore durante il salvataggio del task $e');
    }
  }

  Future<void> assegnaTask(TaskModel task, UtenteModel utentea) async {
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
          'riferimento': task.riferimento,
          'descrizione': task.descrizione,//_descrizioneController.text,
          'concluso': task.concluso,
          'condiviso': true,//_condiviso,
          'accettato': false,//task.accettato,//false,
          'tipologia': task.tipologia?.toMap(),//_selectedTipo.toString().split('.').last,
          'utente': utentea.toMap(),//_condiviso ? selectedUtente?.toMap() : widget.utente,
          'utentecreate': task.utentecreate!.toMap(),
          'attivo': task.attivo
        }),
      );
      if(response.statusCode == 201){
        //Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stato Task aggiornato con successo!'.toUpperCase()),
          ),
        );
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TableTaskPage(
                utente: utente, selectedUtente: selectedUtente, tipoIdGlobal: tipoIdGlobal)));
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
          'riferimento': task.riferimento,
          'descrizione': task.descrizione,//_descrizioneController.text,
          'concluso': task.concluso,
          'condiviso': task.condiviso,//_condiviso,
          'accettato': true,//task.accettato,//false,
          'tipologia': task.tipologia?.toMap(),//_selectedTipo.toString().split('.').last,
          'utente': task.utente!.toMap(),//_condiviso ? selectedUtente?.toMap() : widget.utente,
          'utentecreate': task.utentecreate!.toMap(),
          'attivo': task.attivo
        }),
      );
      if(response.statusCode == 201){
        //Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stato Task aggiornato con successo!'.toUpperCase()),
          ),
        );
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TableTaskPage(
                utente: utente, selectedUtente: selectedUtente, tipoIdGlobal: tipoIdGlobal)));
      }
    } catch (e) {
      print('Errore durante il salvataggio del task $e');
    }
  }

  Future<void> deleteTask(TaskModel task) async {
    final formatter = DateFormat(
        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"); // Crea un formatter per il formato desiderato
    try {
      final response = await http.post(
        Uri.parse('$ipaddress/api/task'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': task.id,
          'data_creazione': task.data_creazione!.toIso8601String(),//DateTime.now().toIso8601String(),//data, // Utilizza la data formattata
          'data_conclusione': task.data_conclusione != null ? task.data_conclusione!.toIso8601String() : null,//task.data_conclusione!.toIso8601String(),//task.data_conclusione,//null,
          'titolo' : task.titolo,//_titoloController.text,
          'riferimento': task.riferimento,
          'descrizione': task.descrizione,//_descrizioneController.text,
          'concluso': task.concluso,
          'condiviso': task.condiviso,//_condiviso,
          'accettato': task.accettato,//false,
          'tipologia': task.tipologia?.toMap(),//_selectedTipo.toString().split('.').last,
          'utente': task.utente!.toMap(),//_condiviso ? selectedUtente?.toMap() : widget.utente,
          'utentecreate': task.utentecreate!.toMap(),
          'attivo': false//task.attivo
        }),
      );
      if(response.statusCode == 201){
        //Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task spostato in archivio!'.toUpperCase()),
          ),
        );
        /*Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => TableTaskPage(
              utente: utente, selectedUtente: selectedUtente, tipoIdGlobal: tipoIdGlobal)),
              (Route<dynamic> route) => false, // Rimuove tutte le pagine precedenti
        );*/
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TableTaskPage(
                utente: utente, selectedUtente: selectedUtente, tipoIdGlobal: tipoIdGlobal)));
      }
    } catch (e) {
      print('Errore durante la modifica del task $e');
    }
  }

  Future<void> rinominaTask(TaskModel task) async {
    final formatter = DateFormat(
        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"); // Crea un formatter per il formato desiderato
    var titolo = _titoloController.text.isNotEmpty ? _titoloController.text : "TASK DEL ${DateTime.now().day}/${DateTime.now().month} ORE ${DateTime.now().hour}:${DateTime.now().minute}";

    try {
      final response = await http.post(
        Uri.parse('$ipaddress/api/task'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': task.id,
          'data_creazione': task.data_creazione!.toIso8601String(),//DateTime.now().toIso8601String(),//data, // Utilizza la data formattata
          'data_conclusione': task.data_conclusione != null ? task.data_conclusione!.toIso8601String() : null,//task.data_conclusione!.toIso8601String(),//task.data_conclusione,//null,
          'titolo' : titolo,//_titoloController.text,//task.titolo,//_titoloController.text,
          'riferimento': task.riferimento,
          'descrizione': task.descrizione,//_descrizioneController.text,
          'concluso': task.concluso,
          'condiviso': task.condiviso,//_condiviso,
          'accettato': task.accettato,//false,
          'tipologia': task.tipologia?.toMap(),//_selectedTipo.toString().split('.').last,
          'utente': task.utente!.toMap(),//_condiviso ? selectedUtente?.toMap() : widget.utente,
          'utentecreate': task.utentecreate!.toMap(),
          'attivo': task.attivo
        }),
      );
      if(response.statusCode == 201){
        //Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task rinominato con successo!'.toUpperCase()),
          ),
        );
        /*Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => TableTaskPage(
              utente: utente, selectedUtente: selectedUtente, tipoIdGlobal: tipoIdGlobal)),
              (Route<dynamic> route) => false, // Rimuove tutte le pagine precedenti
        );*/
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TableTaskPage(
                utente: utente, selectedUtente: selectedUtente, tipoIdGlobal: tipoIdGlobal)));
      }
    } catch (e) {
      print('Errore durante la modifica del task $e');
    }
  }

  Future<void> getAllTaskNO() async{
    try{
      var apiUrl = (utente.cognome! == "Mazzei" || utente.cognome! == "Chiriatti") ? Uri.parse('$ipaddress/api/task/allattivi')
          : Uri.parse('$ipaddress/api/task/utente/'+utente.id!);
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
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
      updateData(_commissioni, selectedUtente, tipoIdGlobal);
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
                  content:
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'CONFERMI DI VOLER AGGIORNARE LO STATO DEL TASK "',
                          style: TextStyle(color: Colors.black), // Colore del testo normale
                        ),
                        TextSpan(
                          text: task.titolo!.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // Testo in grassetto
                        ),
                        TextSpan(
                          text: '" COME CONCLUSO?',
                          style: TextStyle(color: Colors.black), // Colore del testo normale
                        ),
                      ],
                    ),
                  ),
                  /*Text(
                      'CONFERMI DI VOLER AGGIORNARE LO STATO DEL TASK \"'+task.titolo!.toUpperCase()+'\" COME CONCLUSO?'),*/
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
                        Navigator.of(context).pop();
                      },
                      child: Text('OK', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                );
              },
            );

          },
        );
      } else if (dataGridCell.columnName == 'accettatoicon') {
        print('nnn cccc '+utente.nomeCompleto()!);
        return IconButton(tooltip: !task.accettato! && task.utentecreate!.id != utente.id && task.utente!.id == utente.id ? 'CLICCA QUI PER ACCETTARE IL TASK' : '',//'TASK GIA\' ACCETTATO' : ,
            icon: Icon(size: 27,
            !task.accettato! && task.utentecreate!.id != utente.id && task.utente!.id == utente.id ? Icons.warning : null,//Icons.warning,
            color: task.accettato! ? Colors.grey : Colors.orange,
          ), onPressed: () { !task.accettato! && task.utentecreate!.id != utente.id && task.utente!.id == utente.id ? showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('ACCETTA TASK'),
                content:
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: task.utentecreate!.nomeCompleto()!.toUpperCase()+' HA CREATO IL TASK "',
                        style: TextStyle(color: Colors.black), // Colore del testo normale
                      ),
                      TextSpan(
                        text: task.titolo!.toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // Testo in grassetto
                      ),
                      TextSpan(
                        text: '"  PER TE, CONFERMI DI AVER PRESO VISIONE?',
                        style: TextStyle(color: Colors.black), // Colore del testo normale
                      ),
                    ],
                  ),
                ),
                /*Text(
                    task.utentecreate!.nomeCompleto()!.toUpperCase()+' HA CREATO IL TASK \"${task.titolo!.toUpperCase()}\" PER TE, '
                        'CONFERMI DI AVER PRESO VISIONE?'),*/
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
                      Navigator.of(context).pop();
                    },
                    child: Text('OK', style: TextStyle(fontSize: 18)),
                  ),
                ],
              );
            },
          ) : null;},
        );
      } else if (dataGridCell.columnName == 'delete') {
        return IconButton(tooltip: 'CLICCA QUI PER CESTINARE IL TASK',
          icon: Icon(Icons.delete, color: Colors.red, size: 27,),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('ARCHIVIAZIONE TASK'),
                  content: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'CONFERMI DI VOLER SPOSTARE IL TASK "',
                          style: TextStyle(color: Colors.black), // Colore del testo normale
                        ),
                        TextSpan(
                          text: task.titolo!.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // Testo in grassetto
                        ),
                        TextSpan(
                          text: '" NEL CESTINO? POTRAI SUCCESSIVAMENTE '
                              'RECUPERARE IL TASK DAL CESTINO CLICCANDO SU RIPRISTINA',
                          style: TextStyle(color: Colors.black), // Colore del testo normale
                        ),
                      ],
                    ),
                  ),
                  /*Text(
                      'CONFERMI DI VOLER SPOSTARE IL TASK \"'+task.titolo!.toUpperCase()+'\" NEL CESTINO? POTRAI SUCCESSIVAMENTE '
                          'RECUPERARE IL TASK DAL CESTINO CLICCANDO SU RIPRISTINA '),*/
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('NO'),
                    ),
                    TextButton(
                      onPressed: () {
                        deleteTask(task);
                        Navigator.of(context).pop();
                      },
                      child: Text('OK', style: TextStyle(fontSize: 18)),
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
          icon: Icon(Icons.send, color: Colors.grey, size: 24),
          onPressed: () {
            // Variabile locale per tracciare l'utente selezionato
            UtenteModel? localSelectedUtente = selectedUtenteCondivisione;

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder( // Consente di aggiornare lo stato nel dialog
                  builder: (BuildContext context, StateSetter setState) {
                    return AlertDialog(
                      title: Text('Condividi Task\n\"'.toUpperCase()+task.titolo!.toUpperCase()+'\"', style: TextStyle(fontSize: 18)),
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
                                  return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 0.0), // Modifica il valore per avvicinare gli elementi
                                      child: RadioListTile<UtenteModel>(
                                    value: _allUtenti[index],
                                    groupValue: localSelectedUtente,
                                    onChanged: (UtenteModel? newValue) {
                                      setState(() {
                                        localSelectedUtente = newValue; // Aggiorna lo stato locale
                                      });
                                    },
                                    title: Text(_allUtenti[index].nomeCompleto()!.toUpperCase()),
                                  ));
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
                          child: Text('Annulla'.toUpperCase()),
                        ),
                        TextButton(
                          onPressed: () {
                            if (localSelectedUtente != null) {
                              // Salva l'utente selezionato
                              assegnaTask(task, localSelectedUtente!);
                              Navigator.of(context).pop();
                              print('Utente selezionato: ${localSelectedUtente!.nomeCompleto()}'.toUpperCase());
                            }
                          },
                          child: Text('Condividi'.toUpperCase(), style: TextStyle(fontSize: 18)),
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

          onLongPress: () {

            _titoloController = TextEditingController(text: task.titolo!.toUpperCase());
            _riferimentoController = TextEditingController(text: task.riferimento != '' ? task.riferimento!.toUpperCase() : '//');
            _descrizioneController = TextEditingController(text: task.descrizione != '' ? task.descrizione!.toUpperCase() : '//');
            //utente.id == task.utentecreate!.id ?
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder( // Consente di aggiornare lo stato nel dialog
                  builder: (BuildContext context, StateSetter setState) {
                    return AlertDialog(
                      contentPadding: EdgeInsets.all(4),
                      //title: Text('DETTAGLIO TASK \"'.toUpperCase()+task.titolo!.toUpperCase()+'\"', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      //content: Text('RINOMINA TASK\n\"'.toUpperCase()+task.titolo!.toUpperCase()+'\"'),
                      content: Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 15,),
                          Text(
                            'DETTAGLIO TASK',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10,),
                        SizedBox(
                          width: 600,
                          child: TextFormField(enabled: false,
                            controller: _titoloController,
                            maxLines: null,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Titolo'.toUpperCase(),
                              labelStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none, // Rimuove il bordo standard
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.redAccent,
                                  width: 2.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1.0,
                                ),
                              ),
                              hintText: "Inserisci il titolo",
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                            ),
                          ),
                        ),
                        SizedBox(height: 7,),
                        SizedBox(
                          width: 600,
                          child: TextFormField(enabled: false,
                            controller: _riferimentoController,
                            maxLines: null,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: 'RIFERIMENTO'.toUpperCase(),
                              labelStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none, // Rimuove il bordo standard
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.redAccent,
                                  width: 2.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1.0,
                                ),
                              ),
                              hintText: "Inserisci il riferimento",
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                            ),
                          ),
                        ),
                        SizedBox(height: 7,),
                        SizedBox(
                          width: 600,
                          child: TextFormField(enabled: false,
                            controller: _descrizioneController,
                            maxLines: null,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: 'DESCRIZIONE'.toUpperCase(),
                              labelStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none, // Rimuove il bordo standard
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.redAccent,
                                  width: 2.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1.0,
                                ),
                              ),
                              hintText: "Inserisci il titolo",
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                            ),
                          ),
                        ),
                          SizedBox(height: 7,),
                          SizedBox(
                            width: 600,
                            child: TextFormField(enabled: false,
                              initialValue: task.tipologia!.descrizione?.toUpperCase(),
                              //controller: task.tipologia.descrizione,//_descrizioneController,
                              maxLines: null,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                labelText: 'TIPOLOGIA'.toUpperCase(),
                                labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none, // Rimuove il bordo standard
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.redAccent,
                                    width: 2.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1.0,
                                  ),
                                ),
                                hintText: "Inserisci il titolo",
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                              ),
                            ),
                          ),
                          SizedBox(height: 7,),
                          SizedBox(
                            width: 600,
                            child: TextFormField(enabled: false,
                              initialValue: task.condiviso == true ?
                              "${task.utentecreate?.nome!} ${task.utentecreate?.cognome?.substring(0,1)}.${String.fromCharCode(10132)}${task.utente?.nome!} ${task.utente?.cognome?.substring(0,1)}." :
                              "${selectedUtente.nomeCompleto()}",//task.tipologia!.descrizione?.toUpperCase(),
                              //controller: task.tipologia.descrizione,//_descrizioneController,
                              maxLines: null,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                labelText: 'UTENTE'.toUpperCase(),
                                labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none, // Rimuove il bordo standard
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.redAccent,
                                    width: 2.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1.0,
                                  ),
                                ),
                                hintText: "Inserisci il titolo",
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                              ),
                            ),
                          ),
                          task.accettato! ? Row(children: [
                            Text('   ACCETTATO '), Icon(Icons.check_circle, color: Colors.green)
                          ],) : Row(children: [
                            Text('   NON ACCETTATO '), Icon(Icons.warning, color: Colors.orange)
                          ],),
                          task.concluso! ? Row(children: [
                            Text('   CONCLUSO '), Icon(Icons.check_circle, color: Colors.green)
                          ],) : Row(children: [
                            Text('   NON CONCLUSO '), Icon(Icons.hourglass_bottom, color: Colors.grey)
                          ],),
                          //color: task.concluso! ? Colors.green : Colors.grey,
                          //task.concluso! ? Icons.check_circle : Icons.hourglass_bottom,
                          SizedBox(height: 18,),
                          /*TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('CHIUDI'.toUpperCase()),
                          ),*/
                        ]
                      )
                    ),

                      Positioned(
                        right: 8,
                        top: -6,
                        child: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop(); // Chiude il dialog
                          },
                        ),
                      ),

                      ])

                    );
                  },
                );
              },
            );// : null;
          },
            onTap: () {
              /*/SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
              ]);*/
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ModificaTaskPage(utente: utente, task: task,)
                ),
              ).then((value) {
                if (value == 'aggiorna') {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => TableTaskPage(
                        utente: utente, selectedUtente: selectedUtente, tipoIdGlobal: tipoIdGlobal,)));
                   // Aggiorna la pagina
                }
              });
            },//color: task.concluso! ? Colors.white54 : Colors.white,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.grey[600]!,
                    width: 1,
                  ),
                ),
                color: task.concluso! ? Colors.grey[200] : Colors.white,
              ),
              child: Text(
                dataGridCell.value.toString(),
                overflow: TextOverflow.ellipsis,
                style: task.concluso! && dataGridCell.columnName != 'data_conclusione' ? TextStyle(decoration: TextDecoration.lineThrough,) : TextStyle(),
              ),
            ),
          );
        }
      }).toList(),
    );
  }
}