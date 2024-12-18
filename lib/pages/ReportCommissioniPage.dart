import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../model/CommissioneModel.dart';

class ReportCommissioniPage extends StatefulWidget {
  const ReportCommissioniPage({Key? key}) : super(key: key);

  @override
  _ReportCommissioniPageState createState() => _ReportCommissioniPageState();
}

class _ReportCommissioniPageState extends State<ReportCommissioniPage> {
  List<CommissioneModel> allCommissioni = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';

  @override
  void initState() {
    super.initState();
    getAllCommissioni();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Report commissioni',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
          actions : [
            IconButton(
              icon: Icon(
                Icons.refresh, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
                color: Colors.white,
              ),
              onPressed: () {
                // Funzione per ricaricare la pagina
                setState(() {});
              },
            ),
          ]
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Data creazione')),
              DataColumn(label: Text('Data')),
              DataColumn(label: Text('Descrizione')),
              DataColumn(label: Text('Concluso')),
              DataColumn(label: Text('Note')),
              DataColumn(label: Text('Utente')),
            ],
            rows: allCommissioni.map((commissione) {
              return DataRow(
                color: MaterialStateColor.resolveWith((states) {
                  return _getRowColor(commissione.concluso!);
                }),
                cells: [
                  DataCell(Text(
                    DateFormat('dd/MM/yyyy')
                        .format(commissione.data_creazione!),
                    style:
                        TextStyle(color: _getTextColor(commissione.concluso!)),
                  )),
                  DataCell(Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(commissione.data!),
                    style:
                        TextStyle(color: _getTextColor(commissione.concluso!)),
                  )),
                  DataCell(Text(
                    commissione.descrizione!,
                    style:
                        TextStyle(color: _getTextColor(commissione.concluso!)),
                  )),
                  DataCell(Text(
                    commissione.concluso! ? 'Si' : 'No',
                    style:
                        TextStyle(color: _getTextColor(commissione.concluso!)),
                  )),
                  DataCell(Text(
                    commissione.note!,
                    style:
                        TextStyle(color: _getTextColor(commissione.concluso!)),
                  )),
                  DataCell(Text(
                    commissione.utente!.nome! +
                        ' ' +
                        commissione.utente!.cognome!,
                    style:
                        TextStyle(color: _getTextColor(commissione.concluso!)),
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Color _getRowColor(bool concluso) {
    if (concluso) {
      return Colors.green; // Riga verde se concluso è true
    } else {
      return Colors.red; // Riga rossa se concluso è false
    }
  }

  Color _getTextColor(bool concluso) {
    if (concluso) {
      return Colors.white; // Testo bianco se concluso è true
    } else {
      return Colors.white; // Testo bianco se concluso è false
    }
  }

  Future<void> getAllCommissioni() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/commissione/ordered');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<CommissioneModel> commissioni = [];
        for (var item in jsonData) {
          commissioni.add(CommissioneModel.fromJson(item));
        }
        setState(() {
          allCommissioni = commissioni;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Errore di connessione'),
            content: Text(
                'Impossibile caricare i dati dall\'API. Controlla la tua connessione internet e riprova.'),
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
}
