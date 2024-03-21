import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/CommissioneModel.dart';
import '../model/UtenteModel.dart';

class ReportCommissioniPerAgentePage extends StatefulWidget {
  const ReportCommissioniPerAgentePage({Key? key}) : super(key: key);

  @override
  _ReportCommissioniPerAgentePageState createState() => _ReportCommissioniPerAgentePageState();
}

class _ReportCommissioniPerAgentePageState extends State<ReportCommissioniPerAgentePage>{

  List<UtenteModel> utentiList = [];
  Map<String, List<CommissioneModel>> commissioniPerUtenteMap = {};

  @override
  void initState() {
    super.initState();
    getAllUtenti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Commissioni per utente',
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
                        Text('Rosso: Non concluso'),
                        Text('Verde: Concluso'),
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
            children: _buildUtentiTables(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildUtentiTables() {
    if (utentiList.isEmpty) {
      return [Text('Nessun utente trovato')];
    }
    List<Widget> tables = [];
    for (var utente in utentiList) {
      final commissioni = commissioniPerUtenteMap[utente.id!] ?? [];
      tables.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Utente: ${utente.nome} ${utente.cognome}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Totale commissioni svolte: ${commissioni.length}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              DataTable(
                columns: [
                  DataColumn(label: Text('Data Creazione')),
                  DataColumn(label: Text('Data')),
                  DataColumn(label: Text('Descrizione')),
                  DataColumn(label: Text('Note')),
                ],
                rows: _buildRows(commissioni, utente.id!),
              ),
            ],
          ),
        ),
      );
      if (utentiList.last != utente) {
        tables.add(SizedBox(height: 20));
      }
    }
    return tables;
  }


  List<DataRow> _buildRows(List<CommissioneModel> commissioni, String utenteId) {
    return commissioni.map((commissione) {
      Color backgroundColor = Colors.white;
      Color textColor = Colors.black;

      if (commissione.concluso ?? false) {
        backgroundColor = Colors.green;
      } else {
        backgroundColor = Colors.red;
        textColor = Colors.white;
      }

      return DataRow(
        color: MaterialStateColor.resolveWith((states) => backgroundColor),
        cells: [
          DataCell(Text(
            commissione.data_creazione != null ? DateFormat('yyyy-MM-dd').format(commissione.data_creazione!) : 'N/A',
            style: TextStyle(color: textColor),
          )),
          DataCell(Text(
            commissione.data != null ? DateFormat('yyyy-MM-dd').format(commissione.data!) : 'N/A',
            style: TextStyle(color: textColor),
          )),
          DataCell(Text(
            commissione.descrizione != null ? commissione.descrizione.toString() : 'N/A',
            style: TextStyle(color: textColor),
          )),
          DataCell(Text(
            commissione.note != null ? commissione.note.toString() : 'N/A',
            style: TextStyle(color: textColor),
          )),
        ].map<DataCell>((cell) {
          return DataCell(
            InkWell(
              onTap: () {
                _handleRowTap(commissione);
              },
              child: cell.child,
            ),
          );
        }).toList(),
      );
    }).toList();
  }

  void _handleRowTap(CommissioneModel commissione) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => DettaglioPreventivoPerAgentePage(preventivo: preventivo),
    //   ),
    // );
  }


  Future<void> getAllUtenti() async {
    try {
      var apiUrl = Uri.parse('http://192.168.1.52:8080/api/utente');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<UtenteModel> utenti = [];
        for (var item in jsonData) {
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          utentiList = utenti;
        });
        await getAllCommissioniOrderedByUtente();
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

  Future<void> getAllCommissioniOrderedByUtente() async {
    for (var utente in utentiList) {
      await getAllCommissioniForUtente(utente.id!);
    }
  }


  Future<void> getAllCommissioniForUtente(String utenteId) async {
    try {
      var apiUrl = Uri.parse('http://192.168.1.52:8080/api/commissione/utente/$utenteId');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<CommissioneModel> commissioni = [];
        for (var item in jsonData) {
          commissioni.add(CommissioneModel.fromJson(item));
        }
        setState(() {
          commissioniPerUtenteMap[utenteId] = commissioni;
        });
      } else {
        throw Exception('Failed to load commissioni data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching commissioni data from API for utente $utenteId: $e');
    }
  }

}