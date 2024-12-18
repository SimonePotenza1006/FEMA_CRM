import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import '../model/SpesaVeicoloModel.dart';
import '../model/TipologiaSpesaVeicoloModel.dart';
import 'DettaglioSpesaVeicoloPage.dart';


class ReportSpeseVeicoloPage extends StatefulWidget {
  const ReportSpeseVeicoloPage({Key? key}) : super(key: key);

  @override
  _ReportSpeseVeicoloPageState createState() => _ReportSpeseVeicoloPageState();
}

class _ReportSpeseVeicoloPageState extends State<ReportSpeseVeicoloPage> {
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';
  List<SpesaVeicoloModel> speseList = [];
  List<SpesaVeicoloModel> originalSpeseList = [];
  List<TipologiaSpesaVeicoloModel> tipologieList = [];
  TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  String? _filterValue;
  bool _isFilterButtonPressed = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getAllSpese();
    getAllTipologieSpesa();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchActive
            ? Padding(
          padding: const EdgeInsets.only(right: 50),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Cerca per veicolo, utente o tipologia di spesa',
              hintStyle: TextStyle(color: Colors.white),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              filterSpese(value);
            },
          ),
        )
            : Text(
          'REPORT SPESE',
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
        ],
      ),
      body: Scrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columnSpacing: 20,
              columns: [
                DataColumn(
                    label: Text('Data', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Veicolo', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Tipologia spesa', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Fornitore carburante', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Importo', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Chilometraggio', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Utente', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: speseList.map((spesa) {
                return DataRow(cells: [
                  DataCell(
                    InkWell(
                      onTap: () => _handleRowTap(spesa),
                      child: Center(
                        child: Text(
                          spesa.data != null
                              ? DateFormat('yyyy-MM-dd').format(spesa.data!)
                              : 'N/A',
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    InkWell(
                      onTap: () => _handleRowTap(spesa),
                      child: Center(
                        child: Text(
                          spesa.veicolo?.descrizione.toString() ?? 'N/A',
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                      InkWell(
                        onTap:  () => _handleRowTap(spesa),
                        child: Center(
                          child: Text(
                            spesa.tipologia_spesa?.descrizione.toString() ?? 'N/A',
                          ),
                        ),
                      )
                  ),
                  DataCell(
                      InkWell(
                        onTap:  () => _handleRowTap(spesa),
                        child: Center(
                          child: Text(
                            spesa.fornitore_carburante.toString() ?? 'N/A',
                          ),
                        ),
                      )
                  ),
                  DataCell(
                      InkWell(
                        onTap:  () => _handleRowTap(spesa),
                        child: Center(
                          child: Text(
                            spesa.importo.toString() + "€" ?? 'N/A',
                          ),
                        ),
                      )
                  ),
                  DataCell(
                      InkWell(
                          onTap:  () => _handleRowTap(spesa),
                          child: Center(
                              child: Text(
                                spesa.km.toString() + " Km"?? 'N/A',
                              )
                          )
                      )
                  ),
                  DataCell(
                      InkWell(
                          onTap:  () => _handleRowTap(spesa),
                          child: Center(
                            child: Text(
                                spesa?.utente?.cognome.toString() ?? 'N/A'
                            ),
                          )
                      )
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _openModal,
        child: Icon(
          Icons.equalizer,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> getAllTipologieSpesa() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/tipologiaSpesaVeicolo');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<TipologiaSpesaVeicoloModel> tipologie = [];
        for (var item in jsonData) {
          tipologie.add(TipologiaSpesaVeicoloModel.fromJson(item));
        }
        setState(() {
          tipologieList = tipologie;
        });
      } else {
        throw Exception(
            'Failed to load data from API: ${response.statusCode}');
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

  Future<void> getAllSpese() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/spesaVeicolo/ordered');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<SpesaVeicoloModel> spese = [];
        for (var item in jsonData) {
          spese.add(SpesaVeicoloModel.fromJson(item));
        }
        setState(() {
          speseList = spese;
          originalSpeseList = List.from(spese);
        });
      } else {
        throw Exception(
            'Failed to load data from API: ${response.statusCode}');
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

  void filterSpese(String query) {
    setState(() {
      if (query.isNotEmpty) {
        speseList = originalSpeseList.where((spesa) {
          final veicolo = spesa?.veicolo?.descrizione ?? '';
          final tipologia_spesa = spesa?.tipologia_spesa?.descrizione ?? '';
          final utente = spesa?.utente?.nome ?? '';

          return veicolo.toLowerCase().contains(query.toLowerCase()) ||
              tipologia_spesa.toLowerCase().contains(query.toLowerCase()) ||
              utente.toLowerCase().contains(query.toLowerCase());
        }).toList();
      } else {
        speseList = List.from(originalSpeseList);
      }
    });
  }

  void _openModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Text(
                'Sommatoria degli importi per tipologia di spesa:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: tipologieList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final tipologia = tipologieList[index];
                    final importoTotale = _calculateTotalAmount(tipologia.id != null ? int.parse(tipologia.id!) : 0); // Ensure id is converted to int and provide a default value if null
                    return ListTile(
                      title: Text(tipologia.descrizione ?? ''),
                      subtitle: Text('Importo totale: $importoTotale €'),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleRowTap(SpesaVeicoloModel spesa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DettaglioSpesaVeicoloPage(spesa: spesa),
      ),
    );
  }

  // Method to calculate total amount for a tipologia
  double _calculateTotalAmount(int tipologiaId) {
    double totalAmount = 0.0;
    for (var spesa in originalSpeseList) {
      if (spesa.tipologia_spesa?.id == tipologiaId.toString()) { // Convertiamo tipologiaId in stringa per confrontare con l'id della tipologia_spesa
        totalAmount += spesa.importo != null ? double.parse(spesa.importo!.toString()) : 0;
      }
    }
    return totalAmount;
  }


}
