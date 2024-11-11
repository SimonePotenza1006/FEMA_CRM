import 'package:fema_crm/pages/DettaglioPreventivoAmministrazionePage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/AgenteModel.dart';
import '../model/PreventivoModel.dart';
import 'DettaglioPreventivoPerAgentePage.dart';
import 'PDFRendicontoMensilePreventiviPage.dart';

class ReportPreventiviPerAgentePage extends StatefulWidget {
  const ReportPreventiviPerAgentePage({Key? key}) : super(key: key);

  @override
  _ReportPreventiviPerAgentePageState createState() =>
      _ReportPreventiviPerAgentePageState();
}

class _ReportPreventiviPerAgentePageState
    extends State<ReportPreventiviPerAgentePage> {
  List<AgenteModel> agentiList = [];
  Map<String, List<PreventivoModel>> preventiviPerAgenteMap = {};
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  DateTime? _selectedMonth; // Imposto il tipo come DateTime opzionale

  @override
  void initState() {
    super.initState();
    getAllAgenti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Preventivi per agente',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
              color: Colors.white,
            ),
            onPressed: () {
              // Funzione per ricaricare la pagina
              setState(() {
                getAllAgenti();
              });
            },
          ),
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
                              color: Colors.yellow,
                            ),
                            SizedBox(width: 3),
                            Text('Accettato e in attesa di consegna'),
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
                            Text('Rifiutato'),
                          ],
                        ),
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.green,
                            ),
                            SizedBox(width: 3),
                            Text('Consegnato'),
                          ],
                        ),
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 3),
                            Text('Attesa di accettazione'),
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
              color: Colors.white,
              onPressed: () {
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
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('Giallo: Accettato e in attesa di consegna'),
                          Text('Rosso: Rifiutato'),
                          Text('Verde: Consegnato'),
                          Text('Bianco: Attesa di accettazione'),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            color: Colors.white,
            onPressed: () {
              _showMonthPicker(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildAgentTables(),
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: FloatingActionButton(
          onPressed: () {
            _showDownloadConfirmationDialog();
          },
          backgroundColor: Colors.red,
          child: Icon(Icons.file_download, color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showDownloadConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Scaricare il report delle provvigioni divise per agente?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showMonthSelectionDialog();
              },
              child: Text("Si"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }

  void _showMonthSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Seleziona il mese"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 12,
              itemBuilder: (BuildContext context, int index) {
                final month = DateFormat.MMMM('it_IT').format(DateTime(DateTime.now().year, index + 1));
                return ListTile(
                  title: Text(month),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PDFRendicontoMensilePreventiviPage(mese : month)
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildAgentTables() {
    if (agentiList.isEmpty) {
      return [Text('Nessun agente trovato')];
    }

    List<Widget> tables = [];

    for (var agente in agentiList) {
      final preventivi = preventiviPerAgenteMap[agente.id!] ?? [];

      // Filtra i preventivi solo se è stato selezionato un mese
      final filteredPreventivi = _selectedMonth != null
          ? preventivi.where((preventivo) =>
      preventivo.data_creazione != null &&
          preventivo.data_creazione!.month == _selectedMonth!.month &&
          preventivo.data_creazione!.year == _selectedMonth!.year).toList()
          : preventivi;

      // Calcolo delle provvigioni totali per l'agente corrente
      double totalProvvigioni = filteredPreventivi.fold<double>(
          0.0, (acc, preventivo) => acc + (preventivo.provvigioni ?? 0.0));
      if (filteredPreventivi.length > 0)
      tables.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agente: ${agente.nome} ${agente.cognome}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Totale preventivi emessi: ${filteredPreventivi.length}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Totale delle provvigioni: ${totalProvvigioni.toStringAsFixed(2)} \u20AC',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: 1900,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Cliente')),
                    DataColumn(label: Text('Importo')),
                    DataColumn(label: Text('Accettato')),
                    DataColumn(label: Text('Rifiutato')),
                    DataColumn(label: Text('Consegnato')),
                    DataColumn(label: Text('Data Creazione')),
                    DataColumn(label: Text('Data Accettazione')),
                    DataColumn(label: Text('Data Consegna')),
                  ],
                  rows: _buildRows(filteredPreventivi, agente.id!),
                ),
              ),
            ],
          ),
        ),
      );
      if (agentiList.last != agente) {
        tables.add(SizedBox(height: 20));
      }
    }
    return tables;
  }

  List<DataRow> _buildRows(List<PreventivoModel> preventivi, String agenteId) {
    return preventivi.map((preventivo) {
      Color backgroundColor = Colors.white;
      Color textColor = Colors.black;

      if (preventivo.accettato ?? false) {
        backgroundColor = Colors.yellow;
      } else if (preventivo.rifiutato ?? false) {
        backgroundColor = Colors.red;
        textColor = Colors.white;
      } else if (preventivo.consegnato ?? false) {
        backgroundColor = Colors.green;
        textColor = Colors.white;
      } else if (preventivo.pendente ?? false) {
        backgroundColor = Colors.orangeAccent;
      }

      return DataRow(
        color: MaterialStateColor.resolveWith((states) => backgroundColor),
        cells: [
          DataCell(Text(
            preventivo.cliente?.denominazione ?? 'N/A',
            style: TextStyle(color: textColor),
          )),
          DataCell(Text(
            preventivo.importo != null
                ? '${preventivo.importo!.toStringAsFixed(2)} \u20AC'
                : 'N/A',
            style: TextStyle(color: textColor),
          )),
          DataCell(Text(
            preventivo.accettato ?? false ? 'SI' : 'NO',
            style: TextStyle(color: textColor),
          )),
          DataCell(Text(
            preventivo.rifiutato ?? false ? 'SI' : 'NO',
            style: TextStyle(color: textColor),
          )),
          DataCell(Text(
            preventivo.consegnato ?? false ? 'SI' : 'NO',
            style: TextStyle(color: textColor),
          )),
          DataCell(Text(
            preventivo.data_creazione != null
                ? DateFormat('yyyy-MM-dd').format(preventivo.data_creazione!)
                : 'N/A',
            style: TextStyle(color: textColor),
          )),
          DataCell(Text(
            preventivo.data_accettazione != null
                ? DateFormat('yyyy-MM-dd').format(preventivo.data_accettazione!)
                : 'N/A',
            style: TextStyle(color: textColor),
          )),
          DataCell(Text(
            preventivo.data_consegna != null
                ? DateFormat('yyyy-MM-dd').format(preventivo.data_consegna!)
                : 'N/A',
            style: TextStyle(color: textColor),
          )),
        ].map<DataCell>((cell) {
          return DataCell(
            InkWell(
              onTap: () {
                _handleRowTap(preventivo);
              },
              child: cell.child,
            ),
          );
        }).toList(),
      );
    }).toList();
  }

  void _handleRowTap(PreventivoModel preventivo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DettaglioPreventivoAmministrazionePage(preventivo: preventivo),
      ),
    );
  }

  Future<void> getAllAgenti() async {
    try {
      var apiUrl = Uri.parse('$ipaddressProva/api/agente');
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
        await getAllPreventiviOrderedByAgente();
      } else {
        throw Exception(
            'Failed to load agenti data from API: ${response.statusCode}');
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

  Future<void> getAllPreventiviOrderedByAgente() async {
    for (var agente in agentiList) {
      await getAllPreventiviForAgente(agente.id!);
    }
  }

  Future<void> getAllPreventiviForAgente(String agenteId) async {
    try {
      var apiUrl = Uri.parse('$ipaddressProva/api/preventivo/agente/$agenteId');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<PreventivoModel> preventivi = [];
        for (var item in jsonData) {
          preventivi.add(PreventivoModel.fromJson(item));
        }
        setState(() {
          preventiviPerAgenteMap[agenteId] = preventivi;
        });
      } else {
        throw Exception(
            'Failed to load preventivi data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching preventivi data from API for agente $agenteId: $e');
    }
  }

  Future<void> _showMonthPicker(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedMonth ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedMonth = pickedDate;
      });
    }
  }
}