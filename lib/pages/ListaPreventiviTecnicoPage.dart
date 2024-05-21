import 'package:flutter/material.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../model/AgenteModel.dart';
import '../model/PreventivoModel.dart';
import 'DettaglioPreventivoByTecnicoPage.dart';

class ListaPreventiviTecnicoPage extends StatefulWidget {
  final UtenteModel utente;

  const ListaPreventiviTecnicoPage({Key? key, required this.utente})
      : super(key: key);

  @override
  _ListaPreventiviTecnicoPageState createState() =>
      _ListaPreventiviTecnicoPageState();
}

class _ListaPreventiviTecnicoPageState
    extends State<ListaPreventiviTecnicoPage> {
  AgenteModel? agente;
  List<AgenteModel> agentiList = [];
  List<PreventivoModel> preventiviList = [];
  bool isLoading = true;
  double totalCommission = 0.0;
  String ipaddress = 'http://gestione.femasistemi.it:8090';

  @override
  void initState() {
    super.initState();
    getPreventiviByAgente();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista Preventivi',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Totale preventivi emessi: ${preventiviList.length}',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Totale provvigioni: ${totalCommission.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('Data Creazione')),
                          DataColumn(label: Text('Azienda')),
                          DataColumn(label: Text('Cliente')),
                          DataColumn(label: Text('Importo')),
                          DataColumn(label: Text('Accettato')),
                          DataColumn(label: Text('Rifiutato')),
                          DataColumn(label: Text('Attesa')),
                          DataColumn(label: Text('Pendente')),
                          DataColumn(label: Text('Consegnato')),
                        ],
                        rows: preventiviList.map((preventivo) {
                          Color? backgroundColor;
                          Color? textColor;
                          if (preventivo.accettato ?? false) {
                            backgroundColor = Colors.yellow;
                          } else if (preventivo.rifiutato ?? false) {
                            backgroundColor = Colors.red;
                          } else if (preventivo.attesa ?? false) {
                            backgroundColor = Colors.white;
                          } else if (preventivo.consegnato ?? false) {
                            backgroundColor = Colors.green;
                          } else if (preventivo.pendente ?? false) {
                            backgroundColor = Colors.orangeAccent;
                          }
                          if (backgroundColor == Colors.red ||
                              backgroundColor == Colors.green) {
                            textColor = Colors.white;
                          }
                          return DataRow(
                            color: MaterialStateColor.resolveWith((states) =>
                                backgroundColor ?? Colors.transparent),
                            cells: [
                              DataCell(
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DettaglioPreventivoByTecnicoPage(
                                                preventivo: preventivo),
                                      ),
                                    );
                                  },
                                  child: Text(preventivo.data_creazione != null
                                      ? DateFormat('yyyy-MM-dd')
                                          .format(preventivo.data_creazione!)
                                      : ''),
                                ),
                              ),
                              DataCell(
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DettaglioPreventivoByTecnicoPage(
                                                  preventivo: preventivo),
                                        ),
                                      );
                                    },
                                    child:
                                    Text(preventivo.azienda?.nome ?? '')),
                                  ),
                              DataCell(
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DettaglioPreventivoByTecnicoPage(
                                                  preventivo: preventivo),
                                        ),
                                      );
                                    },
                                    child: Text(
                                        preventivo.cliente?.denominazione ?? '')),
                                  ),
                              DataCell(
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DettaglioPreventivoByTecnicoPage(
                                                  preventivo: preventivo),
                                        ),
                                      );
                                    },
                                    child: Text(
                                        preventivo.importo?.toStringAsFixed(2) ??
                                            '')),
                                  ),
                              DataCell(
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DettaglioPreventivoByTecnicoPage(
                                                  preventivo: preventivo),
                                        ),
                                      );
                                    },
                                    child:                                   Text(preventivo.accettato != null
                                        ? (preventivo.accettato! ? 'Si' : 'No')
                                        : '')),
                                  ),
                              DataCell(
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DettaglioPreventivoByTecnicoPage(
                                                  preventivo: preventivo),
                                        ),
                                      );
                                    },
                                    child: Text(preventivo.rifiutato != null
                                        ? (preventivo.rifiutato! ? 'Si' : 'No')
                                        : '')),
                                  ),
                              DataCell(
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DettaglioPreventivoByTecnicoPage(
                                                  preventivo: preventivo),
                                        ),
                                      );
                                    },
                                    child: Text(preventivo.attesa != null
                                        ? (preventivo.attesa! ? 'Si' : 'No')
                                        : '')),
                                  ),
                              DataCell(
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DettaglioPreventivoByTecnicoPage(
                                                  preventivo: preventivo),
                                        ),
                                      );
                                    },
                                    child: Text(preventivo.pendente != null
                                        ? (preventivo.pendente! ? 'Si' : 'No')
                                        : '')),
                                  ),
                              DataCell(
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DettaglioPreventivoByTecnicoPage(
                                                  preventivo: preventivo),
                                        ),
                                      );
                                    },
                                    child: Text(preventivo.consegnato != null
                                        ? (preventivo.consegnato! ? 'Si' : 'No')
                                        : '')),
                                  ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> calculateTotalCommission() async {
    double total = 0.0;
    for (var preventivo in preventiviList) {
      total += preventivo.provvigioni ?? 0.0;
    }
    setState(() {
      totalCommission = total;
    });
  }

  Future<void> getPreventiviByAgente() async {
    try {
      await getAllAgenti();
      await findAgente();
      String? agenteId = agente?.id;
      http.Response response = await http
          .get(Uri.parse('${ipaddress}/api/preventivo/ordered'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<PreventivoModel> allPreventiviByAgente = [];
        for (var preventivoJson in responseData) {
          PreventivoModel preventivo = PreventivoModel.fromJson(preventivoJson);
          if(preventivo.agente?.id == agenteId){
            allPreventiviByAgente.add(preventivo);
          }
        }
        setState(() {
          preventiviList = allPreventiviByAgente;
          isLoading = false;
          calculateTotalCommission();
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
      _showErrorDialog();
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getAllAgenti() async {
    try {
      var apiUrl = Uri.parse('${ipaddress}/api/agente');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<AgenteModel> agenti = [];
        for (var item in jsonData) {
          agenti.add(AgenteModel.fromJson(item));
        }
        setState(() {
          agentiList = agenti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
      _showErrorDialog();
    }
  }

  Future<void> findAgente() async {
    try {
      for (var agente in agentiList) {
        if (agente.nome == widget.utente.nome &&
            agente.cognome == widget.utente.cognome) {
          setState(() {
            this.agente = agente;
          });
          print('Agente: ${agente.nome} ${agente.cognome}');
          break;
        }
      }
    } catch (e) {
      print('Errore durante la ricerca dell\'agente: $e');
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Errore'),
          content: Text(
              'La tua utenza non è riconosciuta come un agente'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
