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
  final TextEditingController _dataController = TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090';

  // Selected user
  UtenteModel? selectedUser;

  @override
  void initState() {
    super.initState();
    getAllUtenti();
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
        child: Column(
          children: [
            // Date and Time Picker
            TextFormField(
              controller: _dataController,
              readOnly: true,
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    final DateTime combinedDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                    _dataController.text = combinedDateTime.toString();
                  }
                }
              },
              decoration: InputDecoration(
                labelText: 'Data e Orario',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Description Field
            TextFormField(
              controller: _descrizioneController,
              decoration: InputDecoration(
                labelText: 'Descrizione',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Notes Field
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Button
            ElevatedButton(
              onPressed: () {
                // Show modal with users
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: 200,
                      child: ListView.builder(
                        itemCount: allUtenti.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                                '${allUtenti[index].nome} ${allUtenti[index].cognome}'),
                            onTap: () {
                              setState(() {
                                selectedUser = allUtenti[index];
                              });
                              Navigator.pop(context); // Close modal
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
              child: Text('Scegli Utente'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Selected User
            if (selectedUser != null)
              Text(
                'Utente selezionato: ${selectedUser!.nome} ${selectedUser!.cognome}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            createCommissione();
          },
          child: Text('Assegna'),
          style: ElevatedButton.styleFrom(
            primary: Colors.red,
            onPrimary: Colors.white,
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
    final formattedDate = formatter.format(DateTime.parse(
        _dataController.text)); // Formatta la data in base al formatter creato
    try {
      final response = await http.post(
        Uri.parse('${ipaddress}/api/commissione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': formattedDate, // Utilizza la data formattata
          'descrizione': _descrizioneController.text,
          'concluso': false,
          'note': _noteController.text,
          'utente': selectedUser?.toMap(),
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
      var apiUrl = Uri.parse('${ipaddress}/api/utente');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
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
