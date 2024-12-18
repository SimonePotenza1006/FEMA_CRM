import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:io';

import '../model/SopralluogoModel.dart';
import 'DettaglioSopralluogoPage.dart';

class ReportSopralluoghiPage extends StatefulWidget {
  const ReportSopralluoghiPage({Key? key}) : super(key: key);

  @override
  _ReportSopralluoghiPageState createState() => _ReportSopralluoghiPageState();
}

class _ReportSopralluoghiPageState extends State<ReportSopralluoghiPage> {
  List<SopralluogoModel> sopralluoghiList = [];
  List<SopralluogoModel> originalSopralluoghiList = [];
  TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  String? _filterValue;
  bool _isFilterButtonPressed = false;
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';

  @override
  void initState() {
    super.initState();
    getAllSopralluoghi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchActive
            ? Padding(
                padding: const EdgeInsets.only(right: 50.0),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cerca per cliente',
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    filterSopralluoghi(value);
                  },
                ),
              )
            : Text(
                'Report Sopralluoghi',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
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
          IconButton(
            icon: _isSearchActive ? Icon(Icons.clear) : Icon(Icons.search),
            color: Colors.white,
            onPressed: () {
              setState(() {
                _isSearchActive = !_isSearchActive;
                if (!_isSearchActive) {
                  _searchController.clear();
                  filterSopralluoghi('');
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(
                label: SizedBox(
                  width: MediaQuery.of(context).size.width /
                      3, // Larghezza 1/3 dello schermo
                  child: Center(
                    child: Text(
                      'Data',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  child: Center(
                    child: Text(
                      'Tipologia',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  child: Center(
                    child: Text(
                      'Cliente',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  child: Center(
                    child: Text(
                      'Descrizione',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
            rows: sopralluoghiList.map((sopralluogo) {
              return DataRow(cells: [
                DataCell(
                  Center(
                      child: Text(DateFormat('dd/MM/yyyy').format(sopralluogo.data ?? DateTime.now())),),
                  onTap: () => _navigateToDetailsPage(sopralluogo),
                ),
                DataCell(
                  Center(
                      child: Text(
                          sopralluogo.tipologia?.descrizione.toString() ??
                              'N/A')),
                  onTap: () => _navigateToDetailsPage(sopralluogo),
                ),
                DataCell(
                  Center(
                      child: Text(
                          sopralluogo.cliente?.denominazione.toString() ??
                              'N/A')),
                  onTap: () => _navigateToDetailsPage(sopralluogo),
                ),
                DataCell(
                  Center(
                    child: Text(sopralluogo.descrizione.toString().length >= 30
                        ? sopralluogo.descrizione.toString().substring(0, 30)
                        : sopralluogo.descrizione.toString()),
                  ),
                  onTap: () => _navigateToDetailsPage(sopralluogo),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _navigateToDetailsPage(SopralluogoModel sopralluogo) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DettaglioSopralluogoPage(sopralluogo: sopralluogo),
      ),
    );
  }

  void filterSopralluoghi(String query) {
    setState(() {
      if (query.isNotEmpty) {
        sopralluoghiList = originalSopralluoghiList.where((sopralluogo) {
          final cliente = sopralluogo.cliente?.denominazione ?? '';
          final tipologia = sopralluogo.tipologia?.descrizione ?? '';
          final posizione = sopralluogo.posizione ?? '';
          final descrizione = sopralluogo.descrizione ?? '';

          return cliente.toLowerCase().contains(query.toLowerCase()) ||
                tipologia.toLowerCase().contains(query.toLowerCase()) ||
                posizione.toLowerCase().contains(query.toLowerCase()) ||
                descrizione.toLowerCase().contains(query.toLowerCase());
        }).toList();
      } else {
        sopralluoghiList = List.from(originalSopralluoghiList);
      }
    });
  }

  Future<void> getAllSopralluoghi() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/sopralluogo/ordered');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<SopralluogoModel> sopralluoghi = [];
        for (var item in jsonData) {
          sopralluoghi.add(SopralluogoModel.fromJson(item));
        }
        setState(() {
          sopralluoghiList = sopralluoghi;
          originalSopralluoghiList =
              List.from(sopralluoghi); // Salva la lista originale
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
