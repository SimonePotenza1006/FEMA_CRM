import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../model/IngressoModel.dart';
import '../model/UtenteModel.dart';

class ControlloAccessiApplicazionePage extends StatefulWidget {
  const ControlloAccessiApplicazionePage({Key? key}) : super(key: key);

  @override
  _ControlloAccessiApplicazionePageState createState() => _ControlloAccessiApplicazionePageState();
}

class _ControlloAccessiApplicazionePageState extends State<ControlloAccessiApplicazionePage> {
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  List<UtenteModel> utentiList = [];
  Map<String, List<IngressoModel>> ingressiPerUtenteMap = {};
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    getAllUtenti();
  }

  Future<void> getAllIngressiForUtente(String utenteId) async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/ingresso/utente/$utenteId');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<IngressoModel> ingressi = [];
        for (var item in jsonData) {
          ingressi.add(IngressoModel.fromJson(item));
        }
        setState(() {
          ingressiPerUtenteMap[utenteId] = ingressi;
        });
      } else {
        throw Exception('Failed to load ingressi data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ingressi data from API for utente $utenteId: $e');
    }
  }

  Future<void> getAllIngressiOrderedByUtente() async {
    for (var utente in utentiList) {
      await getAllIngressiForUtente(utente.id!);
    }
  }

  Future<void> getAllUtenti() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/utente');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<UtenteModel> utenti = [];
        for (var item in jsonData) {
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          utentiList = utenti;
        });
        await getAllIngressiOrderedByUtente();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report ingressi applicazione',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          Hero(
            tag: 'calendar_button', // Assicurati che questo tag sia unico
            child: IconButton(
              icon: Icon(Icons.calendar_today, color: Colors.white),
              onPressed: () {
                _showDatePicker(context);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildUtenteTables(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildUtenteTables() {
    if (utentiList.isEmpty) {
      return [Text('Nessun utente trovato')];
    }

    List<Widget> tables = [];
    for (var utente in utentiList) {
      final ingressi = ingressiPerUtenteMap[utente.id] ?? [];

      tables.add(
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Utente: ${utente.nome} ${utente.cognome}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              DataTable(
                columns: [
                  DataColumn(label: Text('Data e orario di ingresso')),
                ],
                rows: _buildRows(ingressi, utente.id!),
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

  List<DataRow> _buildRows(List<IngressoModel> ingressi, String utenteId) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    List<IngressoModel> filteredIngressi = ingressi;
    if (_selectedDate != null) {
      filteredIngressi = ingressi.where((ingresso) => ingresso.orario != null && ingresso.orario!.toLocal().day == _selectedDate!.toLocal().day).toList();
    }

    return filteredIngressi.map((ingresso) {
      Color backgroundColor = Colors.white;
      Color textColor = Colors.black;
      return DataRow(cells: [
        DataCell(
          Text(
            dateFormat.format(ingresso.orario!) ?? 'N/A',
            style: TextStyle(color: textColor),
          ),
        ),
      ]);
    }).toList();
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }
}
