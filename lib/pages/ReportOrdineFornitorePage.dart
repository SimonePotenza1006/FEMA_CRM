  import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/OrdinePerInterventoModel.dart';
import '../model/UtenteModel.dart';
import 'DettaglioOrdineAmministrazionePage.dart';

class ReportOrdineFornitorePage extends StatefulWidget {
  final UtenteModel? utente;

  const ReportOrdineFornitorePage({Key? key, required this.utente}) : super(key: key);

  @override
  _ReportOrdineFornitorePageState createState() => _ReportOrdineFornitorePageState();
}

class _ReportOrdineFornitorePageState extends State<ReportOrdineFornitorePage> {
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  bool _isSearchActive = false;
  String? _filterValue;
  TextEditingController _searchController = TextEditingController();
  List<OrdinePerInterventoModel> ordiniList = [];
  List<OrdinePerInterventoModel> originalOrdiniList = [];
  ScrollController _scrollController = ScrollController();
  ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getAllOrdini();
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
              filterOrdini(value);
            },
          ),
        )
            : Text(
          'Report Ordini al fornitore',
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
                  filterOrdini('');
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
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Leggenda colori:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Giallo: Presa visione'),
                        Text('Arancione: Ordinato'),
                        Text('Azzurro: Arrivato'),
                        Text('Verde: Consegnato'),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              getAllOrdini();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Scrollbar(
              controller: _horizontalScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: DataTable(
                    columnSpacing: 170,
                    columns: [
                      DataColumn(
                          label: Text('Data creazione', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Utente', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Data richiesta disponibilità', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Entro e non oltre il', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Descrizione', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Fornitore', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: ordiniList.map((ordine) {
                      Color backgroundColor = Colors.white;
                      Color textColor = Colors.black;

                      if (ordine.presa_visione ?? false) {
                        backgroundColor = Colors.yellow;
                      } else if (ordine.ordinato ?? false) {
                        backgroundColor = Colors.orange;
                      } else if (ordine.arrivato ?? false) {
                        backgroundColor = Colors.lightBlueAccent;
                      } else if (ordine.consegnato ?? false) {
                        backgroundColor = Colors.lightGreen;
                      }

                      if (backgroundColor == Colors.lightGreen || backgroundColor == Colors.lightBlueAccent) {
                        textColor = Colors.white;
                      }
                      return DataRow(
                        color: MaterialStateColor.resolveWith((states) => backgroundColor),
                        cells: [
                          DataCell(
                            Center(
                              child: Text(
                                ordine.data_creazione != null
                                    ? DateFormat('yyyy-MM-dd').format(ordine.data_creazione!)
                                    : 'N/A',
                                style: TextStyle(color: textColor),
                              ),
                            ),
                            onTap: () => _navigateToDetailsPage(ordine),
                          ),
                          DataCell(
                            Center(
                              child: Text(
                                ordine.utente?.nomeCompleto() ?? 'N/A',
                                style: TextStyle(color: textColor),
                              ),
                            ),
                            onTap: () => _navigateToDetailsPage(ordine),
                          ),
                          DataCell(
                            Text(
                              ordine.cliente?.denominazione ?? 'N/A',
                              style: TextStyle(color: textColor),
                            ),
                            onTap: () => _navigateToDetailsPage(ordine),
                          ),
                          DataCell(
                            Center(
                              child: Text(
                                ordine.data_disponibilita != null
                                    ? DateFormat('yyyy-MM-dd').format(ordine.data_disponibilita!)
                                    : 'N/A',
                                style: TextStyle(color: textColor),
                              ),
                            ),
                            onTap: () => _navigateToDetailsPage(ordine),
                          ),
                          DataCell(
                            Center(
                              child: Text(
                                ordine.data_ultima != null
                                    ? DateFormat('yyyy-MM-dd').format(ordine.data_ultima!)
                                    : 'N/A',
                                style: TextStyle(color: textColor),
                              ),
                            ),
                            onTap: () => _navigateToDetailsPage(ordine),
                          ),
                          DataCell(
                            Text(
                              ordine.descrizione ?? 'N/A',
                              style: TextStyle(color: textColor),
                            ),
                            onTap: () => _navigateToDetailsPage(ordine),
                          ),
                          DataCell(
                            Center(
                              child: Text(
                                ordine.fornitore?.denominazione ?? 'N/A',
                                style: TextStyle(color: textColor),
                              ),
                            ),
                            onTap: () => _navigateToDetailsPage(ordine),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          _showFilterDialog();
        },
        child: Icon(
          Icons.filter_list_alt,
          color: Colors.white,
        ),
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
              'Filtra per non visionati',
              'Filtra per presa visione',
              'Filtra per ordinato',
              'Filtra per arrivato',
              'Filtra per consegnato',
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
                  if (newValue == 'Filtra per non visionati') {
                    ordiniList = originalOrdiniList.where((ordine) => ordine.presa_visione == false &&
                        ordine.ordinato == false && ordine.arrivato == false && ordine.consegnato == false).toList();
                  } else if (newValue == 'Filtra per presa visione') {
                    ordiniList = originalOrdiniList.where((ordine) => ordine.utente_presa_visione != null && ordine.utente_ordine == null && ordine.utente_consegnato == null && ordine.consegnato == false ).toList();
                  } else if (newValue == 'Filtra per ordinato') {
                    ordiniList = originalOrdiniList.where((ordine) => ordine.ordinato ?? false).toList();
                  } else if (newValue == 'Filtra per arrivato') {
                    ordiniList = originalOrdiniList.where((ordine) => ordine.arrivato ?? false).toList();
                  } else if (newValue == 'Filtra per consegnato') {
                    ordiniList = originalOrdiniList.where((ordine) => ordine.consegnato ?? false).toList();
                  } else if (newValue == 'Rimuovi tutti i filtri') {
                    ordiniList = List.from(originalOrdiniList);
                    _filterValue = null;
                  }
                } else {
                  ordiniList = List.from(originalOrdiniList);
                }
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  Future<void> getAllOrdini() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/ordine/ordered');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<OrdinePerInterventoModel> ordini = [];
        for (var item in jsonData) {
          ordini.add(OrdinePerInterventoModel.fromJson(item));
        }
        setState(() {
          ordiniList = ordini;
          originalOrdiniList = ordini;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore 1 :$e');
    }
  }

  void filterOrdini(String query) {
    setState(() {
      if (query.isNotEmpty) {
        ordiniList = originalOrdiniList.where((ordine) {
          final cliente = ordine.cliente?.denominazione ?? '';
          final utenteC = ordine.utente?.cognome ?? '';
          final utenteN = ordine.utente?.nome ?? '';

          return cliente.toLowerCase().contains(query.toLowerCase()) ||
              utenteC.toLowerCase().contains(query.toLowerCase()) ||
              utenteN.toLowerCase().contains(query.toLowerCase());
        }).toList();
      } else {
        ordiniList = List.from(originalOrdiniList);
      }
    });
  }

  void _navigateToDetailsPage(OrdinePerInterventoModel ordine) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DettaglioOrdineAmministrazionePage(
            ordine: ordine, onNavigateBack: getAllOrdini, utente: widget.utente),
      ),
    );
  }
}
