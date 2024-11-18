import 'dart:convert';

import 'package:fema_crm/pages/CreazioneTaskPage.dart';
import 'package:fema_crm/pages/DettaglioCommissioneAmministrazionePage.dart';
import 'package:fema_crm/pages/HomeFormAmministrazioneNewPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../model/CommissioneModel.dart';
import '../model/InterventoModel.dart';
import '../model/TaskModel.dart';
import '../model/UtenteModel.dart';
import 'DettaglioInterventoNewPage.dart';
import 'DettaglioInterventoPage.dart';
import 'ModificaTaskPage.dart';

class TableTaskPage extends StatefulWidget{
  final UtenteModel utente;
  const TableTaskPage({Key? key, required this.utente}) : super(key: key);
  //TableTaskPage({Key? key}) : super(key : key);

  @override
  _TableTaskPageState createState() => _TableTaskPageState();
}

class _TableTaskPageState extends State<TableTaskPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  List<TaskModel> _allCommissioni = [];
  List<TaskModel> _filteredCommissioni = [];
  Map<String, double> _columnWidths ={};

  bool isLoading = true;
  bool _isLoading = true;
  late TaskDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    _columnWidths ={
    'task' : 0,
    'data_creazione' : 150,
    'data_conclusione' : 170,
    'titolo' : 300,
    'tipologia' : 200,
    'utente' : (widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti") ? 200 : 0,
    'accettato' : (widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti") ? 170 : 0,
    'accettatoicon' : (widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti") ? 0 : 60,
    'completed' : 60,
    'delete' : 60,
  };
    _dataSource = TaskDataSource(context, _filteredCommissioni, widget.utente);
    getAllTask();
    _filteredCommissioni = _allCommissioni.toList();
  }

  Future<void> getAllTask() async{
    setState(() {
      isLoading = true; // Inizio del caricamento
    });
    try{
      var apiUrl = (widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti") ? Uri.parse('$ipaddressProva/api/task/all')
      : Uri.parse('$ipaddressProva/api/task/utente/'+widget.utente!.id!);
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<TaskModel> commissioni = [];
        for(var item in jsonData){
          commissioni.add(TaskModel.fromJson(item));
        }
        setState(() {
          _isLoading = false;
          _allCommissioni = commissioni;
          _filteredCommissioni = commissioni;
          _dataSource = TaskDataSource(context, _filteredCommissioni, widget.utente);
        });
      } else {
        _isLoading = false;
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
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        /*leading: BackButton(
          onPressed: (){Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>  HomeFormAmministrazioneNewPage(userData: widget.utente),
            ),
          );},
          color: Colors.black, // <-- SEE HERE
        ),*/
        title: Text('LISTA TASK', style: TextStyle(color: Colors.white)),
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
                          'Data Conclusione',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['data_conclusione']?? double.nan,
                      minimumWidth: 150,
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
                        child: Text(
                          'Titolo',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['titolo']?? double.nan,
                      minimumWidth: 300,
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
                          'Tipologia',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      width: _columnWidths['tipologia']?? double.nan,
                      minimumWidth: 300,
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
                  ],
                  onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                    setState(() {
                      _columnWidths[details.column.columnName] = details.width;
                    });
                    return true;
                  },
                ))
          ],
        ),
      ),
    );
  }
}

class TaskDataSource extends DataGridSource{
  List<TaskModel> _commissioni = [];
  List<TaskModel> commissioniFiltrate = [];
  BuildContext context;
  UtenteModel utente;
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';

  TaskDataSource(
      this.context,
      List<TaskModel> commissioni,
      this.utente,
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
          DataGridCell<String>(columnName: 'data_creazione', value: dataCreazione),
          DataGridCell<String>(columnName: 'data_conclusione', value: dataConclusione),
          DataGridCell<String>(columnName: 'titolo', value: task.titolo),
          DataGridCell<String>(columnName: 'tipologia', value: task.tipologia.toString().split('.').last),
          //DataGridCell<String>(columnName: 'concluso', value: concluso),
          DataGridCell<String>(columnName: 'utente', value: task.utente?.nomeCompleto()),
          DataGridCell<String>(columnName: 'accettato', value: accettato),
          DataGridCell<TaskModel>(columnName: 'accettatoicon', value: task),
          DataGridCell<TaskModel>(columnName: 'completed', value: task),
          DataGridCell<TaskModel>(columnName: 'delete', value: task),
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
        Uri.parse('$ipaddressProva/api/task'),
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
          'tipologia': task.tipologia.toString().split('.').last,//_selectedTipo.toString().split('.').last,
          'utente': task.utente!.toMap(),//_condiviso ? selectedUtente?.toMap() : widget.utente,
        }),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TableTaskPage(utente: utente),
        ),
      );
      //Navigator.of(context).pop();//Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stato Task aggiornato con successo!'),
        ),
      );
    } catch (e) {
      print('Errore durante il salvataggio del task $e');
    }
  }

  Future<void> accettaTask(TaskModel task) async {
    final formatter = DateFormat(
        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"); // Crea un formatter per il formato desiderato
    //var data = selectedDate != null ? selectedDate?.toIso8601String() : null;
    //final formattedDate = _dataController.text.isNotEmpty ? _dataController  // Formatta la data in base al formatter creato
    try {
      final response = await http.post(
        Uri.parse('$ipaddressProva/api/task'),
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
          'tipologia': task.tipologia.toString().split('.').last,//_selectedTipo.toString().split('.').last,
          'utente': task.utente!.toMap(),//_condiviso ? selectedUtente?.toMap() : widget.utente,
        }),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TableTaskPage(utente: utente),
        ),
      );

      //Navigator.of(context).pop();//Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stato Task aggiornato con successo!'),
        ),
      );
    } catch (e) {
      print('Errore durante il salvataggio del task $e');
    }
  }

  Future<void> deleteTask(BuildContext context, String? id) async {
    try {
      final response = await http.delete(
        Uri.parse('$ipaddressProva/api/task/$id'),
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

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final TaskModel task = row.getCells().firstWhere(
          (cell) => cell.columnName == "task",
    ).value as TaskModel;
    /*final InterventoModel? intervento = row.getCells().firstWhere(
          (cell) => cell.columnName == "intervento",
    ).value as InterventoModel?;*/

    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        /*if (dataGridCell.columnName == 'intervento') {
          return Center(
              child:GestureDetector(
                onTap: () {
                  //if (intervento != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DettaglioInterventoNewPage(intervento: intervento),
                      ),
                    );
                  //}
                },
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 1.0),
                      child: Text(
                        intervento != null ? (intervento.titolo ?? '//') : '///',
                        style: TextStyle(
                          color: intervento != null ? Colors.blue : Colors.black,
                        ),
                      ),
                    ),
                    if (intervento != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 1,
                          color: Colors.blue,
                        ),
                      ),
                  ],
                ),
              ),
          );
        } else if (dataGridCell.columnName == 'commissione') {
          return SizedBox.shrink();
        } else {*/
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
      } else {
        return GestureDetector(
            onTap: () {
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