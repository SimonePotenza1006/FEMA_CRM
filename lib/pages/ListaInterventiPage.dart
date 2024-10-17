import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/GruppoInterventiModel.dart';
import '../model/InterventoModel.dart';
import 'DettaglioInterventoPage.dart';
import 'ListaClientiPage.dart';
import 'PDFRendicontoInterventiPage.dart';
import 'CreazioneInterventoByAmministrazionePage.dart';

class ListaInterventiPage extends StatefulWidget {
  const ListaInterventiPage({Key? key}) : super(key: key);

  @override
  _ListaInterventiPageState createState() => _ListaInterventiPageState();
}

class _ListaInterventiPageState extends State<ListaInterventiPage> {
  late Future<List<InterventoModel>> _interventiFuture;
  List<InterventoModel> filteredInterventi = [];
  List<InterventoModel> allInterventi = [];

  List<GruppoInterventiModel> allGruppi = [];

  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  TextEditingController importoController = TextEditingController();
  bool isSearching = false;
  String ipaddress = 'http://gestione.femasistemi.it:8090';

  Future<void> getAllGruppi() async {
    try{
      var apiUrl = Uri.parse('$ipaddress/api/gruppi/ordered');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<GruppoInterventiModel> gruppi = [];
        for(var item in jsonData) {
          gruppi.add(GruppoInterventiModel.fromJson(item));
        } setState(() {
          allGruppi = gruppi;
        });
      } else {
        throw Exception(
            'Failed to load gruppi data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Hai toppato chicco : $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getAllInterventi();
  }

  Future<void> getAllInterventi() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/intervento/ordered');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<InterventoModel> interventi = [];
        for (var item in jsonData) {
          interventi.add(InterventoModel.fromJson(item));
        } setState(() {
          allInterventi = interventi;
          filteredInterventi = interventi;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
    }
  }

  void filterInterventi(String query) {
    print('Query di ricerca: $query'); // Stampa la query di ricerca per debug
    setState(() {
      filteredInterventi = allInterventi.where((intervento) {
        final cliente = intervento.cliente?.denominazione?.toLowerCase() ?? '';
        final indirizzo = intervento.cliente?.indirizzo?.toLowerCase() ?? '';
        final indirizzoD = intervento.destinazione?.indirizzo?.toLowerCase() ?? '';
        final citta = intervento.cliente?.citta?.toLowerCase() ?? '';
        final cittaD = intervento.destinazione?.citta?.toLowerCase() ?? '';
        final codiceFiscale = intervento.cliente?.codice_fiscale?.toLowerCase() ?? '';
        final codiceFiscaleD = intervento.destinazione?.codice_fiscale?.toLowerCase() ?? '';
        final partitaIva = intervento.cliente?.partita_iva?.toLowerCase() ?? '';
        final partitaIvaD = intervento.destinazione?.partita_iva?.toLowerCase() ?? '';
        final telefono = intervento.cliente?.telefono?.toLowerCase() ?? '';
        final telefonoD = intervento.destinazione?.telefono?.toLowerCase() ?? '';
        final cellulare = intervento.cliente?.cellulare?.toLowerCase() ?? '';
        final cellulareD = intervento.destinazione?.cellulare?.toLowerCase() ?? '';
        final tipologia = intervento.tipologia?.descrizione?.toLowerCase() ?? '';

        final containsQuery = cliente.contains(query.toLowerCase()) ||
            indirizzo.contains(query.toLowerCase()) ||
            indirizzoD.contains(query.toLowerCase()) ||
            citta.contains(query.toLowerCase()) ||
            cittaD.contains(query.toLowerCase()) ||
            codiceFiscale.contains(query.toLowerCase()) ||
            codiceFiscaleD.contains(query.toLowerCase()) ||
            partitaIva.contains(query.toLowerCase()) ||
            partitaIvaD.contains(query.toLowerCase()) ||
            telefono.contains(query.toLowerCase()) ||
            telefonoD.contains(query.toLowerCase()) ||
            cellulare.contains(query.toLowerCase()) ||
            cellulareD.contains(query.toLowerCase()) ||
            tipologia.contains(query.toLowerCase());

        return containsQuery;
      }).toList();
    });
  }

  void startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  void stopSearch() {
    setState(() {
      isSearching = false;
      searchController.clear();
      filterInterventi('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextFormField(
          controller: searchController,
          onChanged: (value) {
            startSearch(); // Attiva il filtro quando si inizia a digitare
            filterInterventi(value); // Applica il filtro
          },
          decoration: InputDecoration(
            hintText: 'Cerca...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
        )
            : Text(
          'Lista Interventi',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          isSearching
              ? IconButton(
            icon: Icon(Icons.cancel, color: Colors.white),
            onPressed: stopSearch,
          )
              : IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: startSearch,
          ),
          IconButton(
            icon: Icon(Icons.person_add_alt_1, size: 40, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListaClientiPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add, size: 40, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreazioneInterventoByAmministrazionePage(),
                ),
              );
            },
          ),
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
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              DataTable(
                columns: [
                  DataColumn(
                    label: Text('Data creazione', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Data accordata', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Responsabile', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Descrizione', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Assegnato', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Concluso', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Conclusione Parziale', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Tipologia Intervento', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Note', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Saldato', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Importo', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Inserisci importo', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label : Text('Acconto', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                      label: Text('Totale', style : TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
                rows: filteredInterventi.map((intervento) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(DateFormat('dd/MM/yyyy').format(intervento.data_apertura_intervento ?? DateTime.now())),
                      ),
                      DataCell(
                        Text(DateFormat('dd/MM/yyyy').format(intervento.data ?? DateTime.now())),
                      ),
                      DataCell(
                        Text(intervento.cliente?.denominazione ?? 'N/A'),
                      ),
                      DataCell(
                        Text(intervento.utente?.cognome ?? 'N/A'),
                      ),
                      DataCell(
                        Text(intervento.descrizione ?? 'N/A'),
                      ),
                      DataCell(
                        Container(
                          decoration: BoxDecoration(
                            color: intervento.assegnato ?? false ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Text(
                            intervento.assegnato ?? false ? 'Assegnato' : 'Non assegnato',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          decoration: BoxDecoration(
                            color: intervento.concluso ?? false ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Text(
                            intervento.concluso ?? false ? 'Concluso' : 'Non concluso',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          decoration: BoxDecoration(
                            color: intervento.conclusione_parziale ?? false ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Text(
                            intervento.conclusione_parziale ?? false ? 'Terminato' : 'Conclusione Parziale',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ),
                      DataCell(
                        Text(intervento.tipologia?.descrizione?.toString() ?? 'N/A'),
                      ),
                      DataCell(
                        Text(
                          intervento.note != null
                              ? (intervento.note!.length > 30 ? intervento.note!.substring(0, 30) : intervento.note!)
                              : 'N/A',
                        ),
                      ),
                      DataCell(
                        Container(
                          decoration: BoxDecoration(
                            color: intervento.saldato ?? false ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          padding: EdgeInsets.all(10),
                          child: Text(
                            intervento.saldato ?? false ? 'Saldato' : 'Non saldato',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(intervento.importo_intervento?.toStringAsFixed(2) ?? 'N/A'),
                      ),
                      DataCell(
                        Center(
                          child: IconButton(
                            onPressed: () {
                              // Show dialog when button is pressed
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Inserisci un importo'),
                                    actions: <Widget>[
                                      TextFormField(
                                        controller: importoController,
                                        decoration: InputDecoration(
                                          labelText: 'Importo',
                                          border: OutlineInputBorder(),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly, // allow only digits
                                        ],
                                        keyboardType: TextInputType.number, // show number keyboard
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Save the importo for the current intervento
                                          saveImporto(intervento); // <--- Pass the intervento object here
                                        },
                                        child: Text('Save'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: Icon(Icons.create, color: Colors.grey),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(intervento.acconto?.toStringAsFixed(2) ?? 'N/A'),
                      ),
                      DataCell(
                        Text(intervento.acconto!= null && intervento.importo_intervento != null
                            ? (intervento.importo_intervento! - intervento.acconto!).toStringAsFixed(2)
                            : intervento.importo_intervento?.toStringAsFixed(2)?? 'N/A'),
                      )
                    ],
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
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom : 16, right: 16),
        child:FloatingActionButton(
          onPressed: () {
            // Mostra il dialog quando viene premuto il FAB
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Visualizzare PDF rendicontato?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        // Chiudi il dialog
                        Navigator.of(context).pop();
                      },
                      child: Text('No'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDFRendicontoInterventiPage(),
                          ),
                        );
                      },
                      child: Text('Si'),
                    ),
                  ],
                );
              },
            );
          },
          backgroundColor: Colors.red,
          child: Icon(Icons.arrow_downward_outlined, color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
        ),
      )
    );
  }

  Future<void> saveImporto(InterventoModel intervento) async {
    try {
      final response = await http.post(
        Uri.parse('${ipaddress}/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': intervento.id,
          'numerazione_danea' : intervento.numerazione_danea,
          'data': intervento.data?.toIso8601String(),
          'orario_appuntamento' : intervento.orario_appuntamento?.toIso8601String(),
          'posizione_gps' : intervento.posizione_gps,
          'orario_inizio': intervento.orario_inizio?.toIso8601String(),
          'orario_fine': intervento.orario_fine?.toIso8601String(),
          'descrizione': intervento.descrizione,
          'importo_intervento': double.parse(importoController.text),
          'prezzo_ivato' : intervento.prezzo_ivato,
          'assegnato': intervento.assegnato,
          'accettato_da_tecnico' : intervento.accettato_da_tecnico,
          'conclusione_parziale': intervento.conclusione_parziale,
          'concluso': intervento.concluso,
          'saldato': intervento.saldato,
          'saldato_da_tecnico' : intervento.saldato_da_tecnico,
          'note': intervento.note,
          'relazione_tecnico' : intervento.relazione_tecnico,
          'firma_cliente': intervento.firma_cliente,
          'utente': intervento.utente?.toMap(),
          'cliente': intervento.cliente?.toMap(),
          'veicolo': intervento.veicolo?.toMap(),
          'merce': intervento.merce?.toMap(),
          'tipologia': intervento.tipologia?.toMap(),
          'categoria': intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': intervento.tipologia_pagamento?.toMap(),
          'destinazione': intervento.destinazione?.toMap(),
        }),
      );
      if (response.statusCode == 201) {
        print('EVVAIIIIIIII');
        Navigator.pop(context);

        // Aggiorna la lista dei dati filtrati con l'importo aggiornato
        setState(() {
          intervento.importo_intervento = double.parse(importoController.text);
        });
      }
    } catch (e) {
      print('Errore durante il salvataggio del preventivo: $e');
    }
  }
}
