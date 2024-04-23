import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../model/ClienteModel.dart';
import '../model/TipologiaInterventoModel.dart';

class SopralluogoTecnicoForm extends StatefulWidget {
  final UtenteModel utente;

  const SopralluogoTecnicoForm({Key? key, required this.utente});

  @override
  _SopralluogoTecnicoFormState createState() => _SopralluogoTecnicoFormState();
}

class _SopralluogoTecnicoFormState extends State<SopralluogoTecnicoForm> {
  List<ClienteModel> clientiList = [];
  List<TipologiaInterventoModel> tipologieList = [];
  List<ClienteModel> filteredClientiList = [];
  ClienteModel? selectedCliente;
  TipologiaInterventoModel? selectedTipologia;
  final TextEditingController indirizzoController = TextEditingController(); // Aggiunto controller per il campo indirizzo
  final TextEditingController descrizioneController = TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090';

  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      return '${place.street},${place.subThoroughfare} ${place.locality} ${place.postalCode}, ${place.country}';
    } catch (e) {
      print("Errore durante la conversione delle coordinate in indirizzo: $e");
      return "Indirizzo non disponibile";
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      String indirizzo =
      await getAddressFromCoordinates(position.latitude, position.longitude);
      setState(() {
        indirizzoController.text = indirizzo; // Aggiorna il valore del campo indirizzo utilizzando il controller
      });
    } catch (e) {
      print("Errore durante l'ottenimento della posizione: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((value) => print('${indirizzoController.text}')); // Utilizza il valore del controller per ottenere il valore iniziale del campo indirizzo
    getAllClienti();
    getAllTipologie();
  }



  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.90;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrazione sopralluogo',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: width,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  DropdownButton<TipologiaInterventoModel>(
                    value: selectedTipologia,
                    hint: Text('Seleziona tipologia di intervento'),
                    isExpanded: true,
                    onChanged: (TipologiaInterventoModel? newValue) {
                      setState(() {
                        selectedTipologia = newValue;
                      });
                    },
                    items: tipologieList
                        .map<DropdownMenuItem<TipologiaInterventoModel>>(
                            (TipologiaInterventoModel tipologia) {
                          return DropdownMenuItem<TipologiaInterventoModel>(
                            value: tipologia,
                            child: Text(tipologia.descrizione ?? ''),
                          );
                        }).toList(),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      _showClientiDialog();
                    },
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedCliente?.denominazione ??
                                'Seleziona Cliente',
                            style: TextStyle(fontSize: 16),
                          ),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: indirizzoController, // Utilizza il controller per il campo indirizzo
                    onChanged: (value) {
                      // Non è più necessario gestire l'evento onChanged
                    },
                    decoration: InputDecoration(
                      labelText: 'Indirizzo',
                      hintText: 'Indirizzo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: descrizioneController,
                    decoration: InputDecoration(
                      labelText: 'Descrizione',
                      hintText: 'Aggiungi una descrizione',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        saveSopralluogo();
                      },
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        ),
                      ),
                      child: Text(
                        'Salva',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveSopralluogo() async {
    try {
      final response =
      await http.post(Uri.parse('${ipaddress}/api/sopralluogo'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'data': DateTime.now().toIso8601String(),
            'descrizione': descrizioneController.text,
            'utente' : widget.utente.toMap(),
            'posizione' : indirizzoController.text, // Utilizza il valore del controller per il campo indirizzo
            'cliente': selectedCliente?.toMap(),
            'tipologia': selectedTipologia?.toMap()
          }));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sopralluogo registrato!'),
        ),
      );
    } catch (e) {
      print('Errore durante il salvataggio del sopralluogo');
    }
  }

  Future<void> getAllTipologie() async {
    try {
      var apiUrl = Uri.parse('${ipaddress}/api/tipologiaIntervento');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<TipologiaInterventoModel> tipologie = [];
        for (var item in jsonData) {
          tipologie.add(TipologiaInterventoModel.fromJson(item));
        }
        setState(() {
          tipologieList = tipologie;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
      _showErrorDialog();
    }
  }

  Future<void> getAllClienti() async {
    try {
      var apiUrl = Uri.parse('${ipaddress}/api/cliente');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<ClienteModel> clienti = [];
        for (var item in jsonData) {
          clienti.add(ClienteModel.fromJson(item));
        }
        setState(() {
          clientiList = clienti;
          filteredClientiList = clienti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
      _showErrorDialog();
    }
  }

  void _showClientiDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Seleziona Cliente',
            textAlign: TextAlign.center,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      filteredClientiList = clientiList
                          .where((cliente) => cliente.denominazione!
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                          .toList();
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Cerca Cliente',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: filteredClientiList.map((cliente) {
                        return ListTile(
                          leading: Icon(Icons.contact_page_outlined),
                          title: Text(cliente.denominazione! +
                              ", " +
                              cliente.indirizzo!),
                          onTap: () {
                            setState(() {
                              selectedCliente = cliente;
                            });
                            Navigator.of(context).pop();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Errore di connessione'),
          content: Text(
            'Impossibile caricare i dati dall\'API. Controlla la tua connessione internet e riprova.',
          ),
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
