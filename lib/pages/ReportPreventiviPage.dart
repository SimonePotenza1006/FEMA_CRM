import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
  bool _isFilterButtonPressed =
      false; // New variable to manage filter and download button state
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';

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
          MouseRegion(
            onEnter: (event) {
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.yellow,
                            ),
                            SizedBox(width: 3),
                            Text('Accettato e in attesa di consegna'),
                          ],
                        ),
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.red,
                            ),
                            SizedBox(width: 3),
                            Text('Rifiutato'),
                          ],
                        ),
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.green,
                            ),
                            SizedBox(width: 3),
                            Text('Consegnato'),
                          ],
                        ),
                        SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 3),
                            Text('Attesa di accettazione'),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: IconButton(
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
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
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
          ),
          IconButton(
              onPressed: (){
                _showDateFilterDialog();
              },
              icon: Icon(
                Icons.filter_alt_outlined,
                color: Colors.white,
              ),
          ),
          IconButton(
            icon: Icon(
              Icons.refresh, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
              color: Colors.white,
            ),
            onPressed: () {
              // Funzione per ricaricare la pagina
              getAllPreventivi();
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
              DataColumn(
                  label: Text('Azienda',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Categoria merceologica',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Cliente',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Agente',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Utente',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Importo',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Accettato',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Rifiutato',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Attesa di accettazione',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Attesa di consegna',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Consegnato',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Data creazione',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Data accettazione',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Data consegna',
                      style: TextStyle(fontWeight: FontWeight.bold))),
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

              if (backgroundColor == Colors.red ||
                  backgroundColor == Colors.green) {
                textColor = Colors.white;
              }

              return DataRow(
                color:
                    MaterialStateColor.resolveWith((states) => backgroundColor),
                cells: [
                  DataCell(
                    Center(
                        child: Text(
                            preventivo.azienda?.nome.toString() ?? 'N/A',
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(
                        child: Text(preventivo.categoria_merceologica ?? 'N/A',
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(
                        child: Text(preventivo.cliente?.denominazione ?? 'N/A',
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(
                        child: Text(preventivo.agente?.nome ?? 'N/A',
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(
                        child: Text(preventivo.utente?.cognome ?? 'N/A',
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(
                        child: Text(
                            preventivo.importo?.toStringAsFixed(2) ?? '0.0',
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(
                        child: Text(preventivo.accettato ?? false ? 'SI' : 'NO',
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(
                        child: Text(preventivo.rifiutato ?? false ? 'SI' : 'NO',
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(
                        child: Text(preventivo.attesa ?? false ? 'SI' : 'NO',
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(
                        child: Text(preventivo.pendente ?? false ? 'SI' : 'NO',
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(
                        child: Text(
                            preventivo.consegnato ?? false ? 'SI' : 'NO',
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(
                        child: Text(
                            preventivo.data_creazione != null
                                ? DateFormat('yyyy-MM-dd')
                                    .format(preventivo.data_creazione!)
                                : 'N/A',
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(
                        child: Text(
                            preventivo.data_accettazione != null
                                ? DateFormat('yyyy-MM-dd')
                                    .format(preventivo.data_accettazione!)
                                : 'N/A',
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                  DataCell(
                    Center(
                        child: Text(
                            preventivo.data_consegna != null
                                ? DateFormat('yyyy-MM-dd')
                                    .format(preventivo.data_consegna!)
                                : 'Non consegnato',
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(preventivo),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          if (_isFilterButtonPressed) {
            _showFilterDialog();
          } else {
            _showConfirmationDialog();
          }
        },
        child: Icon(
          _isFilterButtonPressed ? Icons.filter_list : Icons.arrow_downward,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> getAllPreventivi() async {
    try {
      var apiUrl = Uri.parse('$ipaddressProva/api/preventivo/ordered');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<PreventivoModel> preventivi = [];
        for (var item in jsonData) {
          preventivi.add(PreventivoModel.fromJson(item));
        }
        setState(() {
          preventiviList = preventivi;
          originalPreventiviList =
              List.from(preventivi); // Salva la lista originale
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
              accettato
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              rifiutato
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              attesa.toString().toLowerCase().contains(query.toLowerCase()) ||
              consegnato
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              pendente.toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      } else {
        preventiviList =
            List.from(originalPreventiviList); // Ripristina la lista originale
      }
    });
  }

  void _navigateToDetailsPage(PreventivoModel preventivo) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DettaglioPreventivoAmministrazionePage(
            preventivo: preventivo, onNavigateBack: getAllPreventivi),
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
                    preventiviList = originalPreventiviList
                        .where((preventivo) => preventivo.consegnato ?? false)
                        .toList();
                  } else if (newValue == 'Filtra per accettato') {
                    preventiviList = originalPreventiviList
                        .where((preventivo) => preventivo.accettato ?? false)
                        .toList();
                  } else if (newValue == 'Filtra per rifiutato') {
                    preventiviList = originalPreventiviList
                        .where((preventivo) => preventivo.rifiutato ?? false)
                        .toList();
                  } else if (newValue == 'Filtra per attesa') {
                    preventiviList = originalPreventiviList
                        .where((preventivo) => preventivo.attesa ?? false)
                        .toList();
                  } else if (newValue == 'Rimuovi tutti i filtri') {
                    // Rimuovi tutti i filtri e ripristina la lista originale
                    preventiviList = List.from(originalPreventiviList);
                    _filterValue = null;
                  }
                } else {
                  preventiviList = List.from(
                      originalPreventiviList); // Ripristina la lista originale
                }
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Scaricare excel del report?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _generateExcel();
                Navigator.of(context).pop();
              },
              child: Text('Conferma', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _generateExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Aggiungi intestazioni
    sheetObject.appendRow([
      'Azienda',
      'Categoria merceologica',
      'Cliente',
      'Agente',
      'Utente',
      'Importo',
      'Accettato',
      'Rifiutato',
      'Attesa di accettazione',
      'Attesa di consegna',
      'Consegnato',
      'Data creazione',
      'Data accettazione',
      'Data consegna',
    ]);

    // Aggiungi righe di dati
    for (var preventivo in preventiviList) {
      sheetObject.appendRow([
        preventivo.azienda?.nome ?? 'N/A',
        preventivo.categoria_merceologica ?? 'N/A',
        preventivo.cliente?.denominazione ?? 'N/A',
        preventivo.agente?.nome ?? 'N/A',
        preventivo.utente?.cognome ?? 'N/A',
        preventivo.importo?.toStringAsFixed(2) ?? '0.0',
        preventivo.accettato ?? false ? 'SI' : 'NO',
        preventivo.rifiutato ?? false ? 'SI' : 'NO',
        preventivo.attesa ?? false ? 'SI' : 'NO',
        preventivo.pendente ?? false ? 'SI' : 'NO',
        preventivo.consegnato ?? false ? 'SI' : 'NO',
        preventivo.data_creazione != null
            ? DateFormat('yyyy-MM-dd').format(preventivo.data_creazione!)
            : 'N/A',
        preventivo.data_accettazione != null
            ? DateFormat('yyyy-MM-dd').format(preventivo.data_accettazione!)
            : 'N/A',
        preventivo.data_consegna != null
            ? DateFormat('yyyy-MM-dd').format(preventivo.data_consegna!)
            : 'Non consegnato',
      ]);
    }

    // Salvataggio del file
    try {
      late String filePath;
      if (Platform.isWindows) {
        // Percorso di salvataggio su Windows
        String appDocumentsPath = 'C:\\ReportPreventivi';
        filePath = '$appDocumentsPath\\report_preventivi.xlsx';
      } else if (Platform.isAndroid) {
        // Percorso di salvataggio su Android
        Directory? externalStorageDir = await getExternalStorageDirectory();
        if (externalStorageDir != null) {
          String appDocumentsPath = externalStorageDir.path;
          filePath = '$appDocumentsPath/report_preventivi.xlsx';
        } else {
          throw Exception('Impossibile ottenere il percorso di salvataggio.');
        }
      }

      var excelBytes = await excel.encode();
      if (excelBytes != null) {
        await File(filePath).create(recursive: true).then((file) {
          file.writeAsBytesSync(excelBytes);
        });
        // Notifica all'utente che il file è stato salvato con successo
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Excel salvato in $filePath')));
      } else {
        // Gestisci il caso in cui excel.encode() restituisce null
        print('Errore durante la codifica del file Excel');
      }
    } catch (error) {
      // Gestisci eventuali errori durante il salvataggio del file
      print('Errore durante il salvataggio del file Excel: $error');
    }
  }

  void filterByCurrentMonth() {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    setState(() {
      preventiviList = originalPreventiviList.where((preventivo) {
        return preventivo.data_creazione != null &&
            preventivo.data_creazione!.isAfter(firstDayOfMonth) &&
            preventivo.data_creazione!.isBefore(lastDayOfMonth);
      }).toList();
    });
  }

  void filterByCurrentYear() {
    DateTime now = DateTime.now();
    DateTime firstDayOfYear = DateTime(now.year, 1, 1);
    DateTime lastDayOfYear = DateTime(now.year, 12, 31);

    setState(() {
      preventiviList = originalPreventiviList.where((preventivo) {
        return preventivo.data_creazione != null &&
            preventivo.data_creazione!.isAfter(firstDayOfYear) &&
            preventivo.data_creazione!.isBefore(lastDayOfYear);
      }).toList();
    });
  }

  void filterByLastYear() {
    DateTime now = DateTime.now();
    DateTime firstDayOfLastYear = DateTime(now.year - 1, 1, 1);
    DateTime lastDayOfLastYear = DateTime(now.year - 1, 12, 31);

    setState(() {
      preventiviList = originalPreventiviList.where((preventivo) {
        return preventivo.data_creazione != null &&
            preventivo.data_creazione!.isAfter(firstDayOfLastYear) &&
            preventivo.data_creazione!.isBefore(lastDayOfLastYear);
      }).toList();
    });
  }

  void filterBySpecificDate(DateTime selectedDate) {
    setState(() {
      preventiviList = originalPreventiviList.where((preventivo) {
        return preventivo.data_creazione != null &&
            DateFormat('yyyy-MM-dd').format(preventivo.data_creazione!) ==
                DateFormat('yyyy-MM-dd').format(selectedDate);
      }).toList();
      if (preventiviList.isEmpty) {
        _showNoResultsDialog();
      }
    });
  }

  void _showDateFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        DateTime? selectedDate;

        return AlertDialog(
          title: Text('Filtra per Data Creazione'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Mese Corrente'),
                onTap: () {
                  Navigator.pop(context);
                  filterByCurrentMonth();
                },
              ),
              ListTile(
                title: Text('Anno Corrente'),
                onTap: () {
                  Navigator.pop(context);
                  filterByCurrentYear();
                },
              ),
              ListTile(
                title: Text('Anno Precedente'),
                onTap: () {
                  Navigator.pop(context);
                  filterByLastYear();
                },
              ),
              ListTile(
                title: Text('Seleziona Data Specifica'),
                onTap: () async {
                  selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );

                  if (selectedDate != null) {
                    Navigator.pop(context);
                    filterBySpecificDate(selectedDate!);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNoResultsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nessun preventivo trovato'),
          content: Text(
              'Non è presente alcun preventivo creato in questa data.'),
          actions: [
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

