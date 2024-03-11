import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/AgenteModel.dart';
import '../model/PreventivoModel.dart';
import 'DettaglioPreventivoAmministrazionePage.dart';
import 'DettaglioPreventivoPerAgentePage.dart'; // Importa la pagina DettaglioPreventivoAmministrazionePage

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
    );
  }

  List<Widget> _buildAgentTables() {
    if (agentiList.isEmpty) {
      return [Text('Nessun agente trovato')];
    }

    List<Widget> tables = [];

    for (var agente in agentiList) {
      final preventivi = preventiviPerAgenteMap[agente.id!] ?? [];
      tables.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agente: ${agente.nome}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              DataTable(
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
                rows: _buildRows(preventivi, agente.id!),
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
            preventivo.importo != null ? '${preventivo.importo!.toStringAsFixed(2)} \u20AC' : 'N/A',
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
            preventivo.data_creazione != null ? DateFormat('yyyy-MM-dd').format(preventivo.data_creazione!) : 'N/A',
            style: TextStyle(color: textColor),
          )),
          DataCell(Text(
            preventivo.data_accettazione != null ? DateFormat('yyyy-MM-dd').format(preventivo.data_accettazione!) : 'N/A',
            style: TextStyle(color: textColor),
          )),
          DataCell(Text(
            preventivo.data_consegna != null ? DateFormat('yyyy-MM-dd').format(preventivo.data_consegna!) : 'N/A',
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
        builder: (context) => DettaglioPreventivoPerAgentePage(preventivo: preventivo),
      ),
    );
  }

  Future<void> getAllAgenti() async {
    try {
      var apiUrl = Uri.parse('http://192.168.1.52:8080/api/agente');
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
        throw Exception('Failed to load agenti data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching agenti data from API: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Connection Error'),
            content: Text('Unable to load data from API. Please check your internet connection and try again.'),
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
      var apiUrl = Uri.parse('http://192.168.1.52:8080/api/preventivo/agente/$agenteId');
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
        throw Exception('Failed to load preventivi data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching preventivi data from API for agente $agenteId: $e');
    }
  }
}
