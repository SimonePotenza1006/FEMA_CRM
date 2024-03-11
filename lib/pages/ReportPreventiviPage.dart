import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'DettaglioPreventivoAmministrazionePage.dart';
import 'package:fema_crm/model/PreventivoModel.dart';

class ReportPreventiviPage extends StatefulWidget {
  const ReportPreventiviPage({Key? key}) : super(key: key);

  @override
  _ReportPreventiviPageState createState() => _ReportPreventiviPageState();
}

class _ReportPreventiviPageState extends State<ReportPreventiviPage> {
  List<PreventivoModel> preventiviList = [];
  List<PreventivoModel> originalPreventiviList = [];
  TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  String? _filterValue;

  @override
  void initState() {
    super.initState();
    getAllPreventivi();
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
              filterPreventivi(value);
            },
          ),
        )
            : Text(
          'Report preventivi',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: _isSearchActive ? Icon(Icons.clear) : Icon(Icons.search),
            color: Colors.white,
            onPressed: () {
              setState(() {
                _isSearchActive = !_isSearchActive;
                if (!_isSearchActive) {
                  _searchController.clear();
                  filterPreventivi('');
                }
              });
            },
          ),
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 20,
            columns: [
              DataColumn(label: Text('Azienda', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Categoria merceologica', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Agente', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Utente', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Importo', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Accettato', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Rifiutato', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Attesa di accettazione', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Attesa di consegna', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Consegnato', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Data creazione', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Data accettazione', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Data consegna', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: preventiviList.map((preventivo) {
              Color backgroundColor = Colors.white;
              Color textColor = Colors.black;

              if (preventivo.accettato ?? false) {
                backgroundColor = Colors.yellow;
              } else if (preventivo.rifiutato ?? false) {
                backgroundColor = Colors.red;
              } else if (preventivo.attesa ?? false) {
                backgroundColor = Colors.white;
              } else if (preventivo.consegnato ?? false) {
                backgroundColor = Colors.green;
              } else if (preventivo.pendente ?? false) {
                backgroundColor = Colors.orangeAccent;
              }

              if (backgroundColor == Colors.red || backgroundColor == Colors.green) {
                textColor = Colors.white;
              }

              return DataRow(
                color: MaterialStateColor.resolveWith((states) => backgroundColor),
                cells: [
                  DataCell(
                    Center(child: Text(preventivo.azienda?.nome.toString() ?? 'N/A', style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(child: Text(preventivo.categoria_merceologica ?? 'N/A', style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(child: Text(preventivo.cliente?.denominazione ?? 'N/A', style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(child: Text(preventivo.agente?.nome ?? 'N/A', style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(child: Text(preventivo.utente?.cognome ?? 'N/A', style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(child: Text(preventivo.importo?.toStringAsFixed(2) ?? '0.0', style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(child: Text(preventivo.accettato ?? false ? 'SI' : 'NO', style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(child: Text(preventivo.rifiutato ?? false ? 'SI' : 'NO', style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(child: Text(preventivo.attesa ?? false ? 'SI' : 'NO', style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(child: Text(preventivo.pendente ?? false ? 'SI' : 'NO', style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(child: Text(preventivo.consegnato ?? false ? 'SI' : 'NO', style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(child: Text(preventivo.data_creazione != null ? DateFormat('yyyy-MM-dd').format(preventivo.data_creazione!) : 'N/A', style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(child: Text(preventivo.data_accettazione != null ? DateFormat('yyyy-MM-dd').format(preventivo.data_accettazione!) : 'N/A', style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(child: Text(preventivo.data_consegna != null ? DateFormat('yyyy-MM-dd').format(preventivo.data_consegna!) : 'Non consegnato', style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFilterDialog();
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.filter_list, color: Colors.white),
      ),
    );
  }

  Future<void> getAllPreventivi() async {
    try {
      var apiUrl = Uri.parse('http://192.168.1.52:8080/api/preventivo/ordered');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<PreventivoModel> preventivi = [];
        for (var item in jsonData) {
          preventivi.add(PreventivoModel.fromJson(item));
        }
        setState(() {
          preventiviList = preventivi;
          originalPreventiviList = List.from(preventivi); // Salva la lista originale
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

  void filterPreventivi(String query) {
    setState(() {
      if (query.isNotEmpty) {
        preventiviList = originalPreventiviList.where((preventivo) {
          final cliente = preventivo.cliente?.denominazione ?? '';
          final accettato = preventivo.accettato ?? false;
          final rifiutato = preventivo.rifiutato ?? false;
          final attesa = preventivo.attesa ?? false;
          final consegnato = preventivo.consegnato ?? false;
          final pendente = preventivo.pendente ?? false;

          return cliente.toLowerCase().contains(query.toLowerCase()) ||
              accettato.toString().toLowerCase().contains(query.toLowerCase()) ||
              rifiutato.toString().toLowerCase().contains(query.toLowerCase()) ||
              attesa.toString().toLowerCase().contains(query.toLowerCase()) ||
              consegnato.toString().toLowerCase().contains(query.toLowerCase()) ||
              pendente.toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      } else {
        preventiviList = List.from(originalPreventiviList); // Ripristina la lista originale
      }
    });
  }

  void _navigateToDetailsPage(PreventivoModel preventivo) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DettaglioPreventivoAmministrazionePage(preventivo: preventivo, onNavigateBack: getAllPreventivi),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filtra per'),
          content: DropdownButton<String>(
            value: _filterValue,
            items: <String>[
              'Filtra per consegnato',
              'Filtra per accettato',
              'Filtra per rifiutato',
              'Filtra per attesa',
              'Rimuovi tutti i filtri' // Aggiunta voce per rimuovere tutti i filtri
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _filterValue = newValue;
                if (newValue != null) {
                  if (newValue == 'Filtra per consegnato') {
                    preventiviList = originalPreventiviList.where((preventivo) => preventivo.consegnato ?? false).toList();
                  } else if (newValue == 'Filtra per accettato') {
                    preventiviList = originalPreventiviList.where((preventivo) => preventivo.accettato ?? false).toList();
                  } else if (newValue == 'Filtra per rifiutato') {
                    preventiviList = originalPreventiviList.where((preventivo) => preventivo.rifiutato ?? false).toList();
                  } else if (newValue == 'Filtra per attesa') {
                    preventiviList = originalPreventiviList.where((preventivo) => preventivo.attesa ?? false).toList();
                  } else if (newValue == 'Rimuovi tutti i filtri') { // Rimuovi tutti i filtri e ripristina la lista originale
                    preventiviList = List.from(originalPreventiviList);
                    _filterValue = null;
                  }
                } else {
                  preventiviList = List.from(originalPreventiviList); // Ripristina la lista originale
                }
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }
}
