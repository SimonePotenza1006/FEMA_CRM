import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/UtenteModel.dart';
import 'package:intl/intl.dart';

class AssegnazioneCommissionePage extends StatefulWidget {
  const AssegnazioneCommissionePage({Key? key}) : super(key: key);

  @override
  _AssegnazioneCommissionePageState createState() =>
      _AssegnazioneCommissionePageState();
}

class _AssegnazioneCommissionePageState
    extends State<AssegnazioneCommissionePage> {
  List<UtenteModel> allUtenti = [];
  // Controller for the text fields
  final TextEditingController _descrizioneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  UtenteModel? selectedUtente;
  DateTime _dataOdierna = DateTime.now();
  DateTime? selectedDate = null;

  @override
  void initState() {
    super.initState();
    getAllUtenti();
  }

  Future<void> _selezionaData() async {
    final DateTime? dataSelezionata = await showDatePicker(
      locale: const Locale('it', 'IT'),
      context: context,
      initialDate: _dataOdierna,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (dataSelezionata != null && dataSelezionata != _dataOdierna) {
      setState(() {
        selectedDate = dataSelezionata;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creazione commissione',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _selezionaData,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('SELEZIONA DATA', style: TextStyle(color: Colors.white)),
                ),
              ),
              if(selectedDate != null)
                Text('DATA SELEZIONATA: ${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}'),
              const SizedBox(height: 20.0),
              SizedBox(height: 20),
              // Description Field
              SizedBox(
                width: 450,
                child: TextFormField(
                  controller: _descrizioneController,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Descrizione',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 450,
                child: TextFormField(
                  controller: _noteController,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Note',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Button
              SizedBox(
                width: 450,
                child: DropdownButtonFormField<UtenteModel>(
                  value: selectedUtente,
                  onChanged: (UtenteModel? newValue){
                    setState(() {
                      selectedUtente = newValue;
                    });
                  },
                  items: allUtenti.map((UtenteModel utente){
                    return DropdownMenuItem<UtenteModel>(
                      value: utente,
                      child: Text(utente.nomeCompleto()!),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                      labelText: 'Seleziona tecnico'.toUpperCase()
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: EdgeInsets.all(22.0),
        child: ElevatedButton(
          onPressed: () {
            createCommissione();
          },
          child: Text('Assegna'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> createCommissione() async {
    final formatter = DateFormat(
        "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"); // Crea un formatter per il formato desiderato
    var data = selectedDate != null ? selectedDate?.toIso8601String() : null;
    //final formattedDate = _dataController.text.isNotEmpty ? _dataController  // Formatta la data in base al formatter creato
    try {
      final response = await http.post(
        Uri.parse('$ipaddress/api/commissione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': data, // Utilizza la data formattata
          'attivo' : true,
          'descrizione': _descrizioneController.text,
          'concluso': false,
          'note': _noteController.text,
          'utente': selectedUtente?.toMap(),
        }),
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Commissione registrata con successo!'),
        ),
      );
    } catch (e) {
      print('Errore durante il salvataggio del preventivo $e');
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
}
