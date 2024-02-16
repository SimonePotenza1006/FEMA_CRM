import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/InterventoModel.dart';
import 'DettaglioInterventoPage.dart';

class ListaInterventiPage extends StatefulWidget {
  const ListaInterventiPage({Key? key}) : super(key: key);

  @override
  _ListaInterventiPageState createState() => _ListaInterventiPageState();
}

class _ListaInterventiPageState extends State<ListaInterventiPage> {
  List<InterventoModel> interventiList = [];

  @override
  void initState() {
    super.initState();
    // Chiamata all'API
    getAllInterventi();
  }

  Future<void> getAllInterventi() async {
    try {
      // Esempio di URL dell'API
      var apiUrl = Uri.parse('http://192.168.1.52:8080/api/intervento/ordered');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        // Parsing dei dati JSON ricevuti
        var jsonData = jsonDecode(response.body);
        debugPrint("Prova: ${jsonData.toString()}", wrapWidth: 1024);
        // Creazione degli oggetti Intervento dalla risposta JSON
        List<InterventoModel> interventi = [];
        for (var item in jsonData) {
          //debugPrint('${item}', wrapWidth: 1024);
          interventi.add(InterventoModel.fromJson(item));
        }

        // Aggiornamento dello stato con i dati ottenuti dall'API
        setState(() {
          interventiList = interventi;
        });
      } else {
        // Se la chiamata all'API non ha avuto successo
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Errore di connessione'),
            content: Text('Impossibile caricare i dati dall\'API. Controlla la tua connessione internet e riprova.'),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista Interventi'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: // Dentro il metodo build, sostituisci la costruzione della DataTable con questo codice:

          DataTable(
            columns: [
              DataColumn(label: Text('Cliente')),
              DataColumn(label: Text('Destinazione')),
              DataColumn(label: Text('Tipologia Intervento')),
              DataColumn(label: Text('Data')),
              DataColumn(label: Text('Assegnato')),
              DataColumn(label: Text('Concluso')),
              DataColumn(label: Text('Note')),
              DataColumn(label: Text('Saldato')),
            ],
            rows: interventiList.map((intervento) {
              return DataRow(
                cells: [
                  DataCell(Text(intervento.cliente?.denominazione ?? 'N/A')),
                  DataCell(Text(intervento.destinazione?.denominazione ?? 'N/A')),
                  DataCell(Text(intervento.tipologia?.descrizione.toString() ?? 'N/A')),
                  DataCell(Text(DateFormat('dd/MM/yyyy').format(intervento.data ?? DateTime.now()))),
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: intervento.assegnato ?? false ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Center(
                          child: Text(
                            intervento.assegnato ?? false ? '     ' : '      ',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: intervento.concluso ?? false ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Center(
                          child: Text(
                            intervento.concluso ?? false ? '      ' : '       ',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(intervento.note ?? "N/A")),
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: intervento.saldato ?? false ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Center(
                          child: Text(
                            intervento.saldato ?? false ? '      ' : '       ',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                // Aggiunta del GestureDetector per la navigazione alla nuova pagina
                onSelectChanged: (isSelected) {
                  if (isSelected != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DettaglioInterventoPage(intervento: intervento),
                      ),
                    );
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}



