import 'package:fema_crm/model/GruppoInterventiModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../model/InterventoModel.dart';
import '../model/UtenteModel.dart';
import 'DettaglioInterventoNewPage.dart';
import 'DettaglioInterventoNewPageAndroid.dart';

class DettaglioGruppoInterventiPage extends StatefulWidget {
  final GruppoInterventiModel gruppo;
  final UtenteModel utente;

  const DettaglioGruppoInterventiPage(
      {Key? key, required this.gruppo, required this.utente}) : super(key : key);

  @override
  _DettaglioGruppoInterventiPageState createState() =>
      _DettaglioGruppoInterventiPageState();
}

class _DettaglioGruppoInterventiPageState extends State<DettaglioGruppoInterventiPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';
  List<InterventoModel> filteredInterventi = [];
  List<InterventoModel> allInterventi = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  TextEditingController importoController = TextEditingController();
  bool isSearching = false;
  final ScrollController _scrollController = ScrollController();
  double dataTableHeight = 0;


  Map<String, Map<String, dynamic>> _calculateUtenteImportoMap(List<InterventoModel> interventi) {
    Map<String, Map<String, dynamic>> utenteInterventiMap = {};
    for (var intervento in interventi) {
      if (intervento.utente != null) {
        String utenteName = intervento.utente!.cognome ?? '';
        double importo = intervento.importo_intervento ?? 0.0;
        if (!utenteInterventiMap.containsKey(utenteName)) {
          utenteInterventiMap[utenteName] = {'num_interventi': 1, 'importo_totale': importo};
        } else {
          utenteInterventiMap[utenteName]?['num_interventi'] += 1;
          utenteInterventiMap[utenteName]?['importo_totale'] += importo;
        }
      }
    }
    return utenteInterventiMap;
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

  Future<void> concludiGruppo() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/gruppi'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id' : widget.gruppo.id,
          'descrizione' : widget.gruppo.descrizione,
          'note' : widget.gruppo.note,
          'importo' : widget.gruppo.importo,
          'concluso' : true,
          'cliente' : widget.gruppo.cliente?.toMap()
        })
      );
      if(response.statusCode == 201){
        print('EVVAI');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gruppo di interventi concluso!'),
          ),
        );
      }
    } catch(e){
      print('Errore: $e');
    }
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

  Future<void> saveImporto(InterventoModel intervento) async {
    try {
      final response = await http.post(
        Uri.parse('$ipaddress/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': intervento.id,
          'attivo' : intervento.attivo,
          'visualizzato' : intervento.visualizzato,
          'titolo' : intervento.titolo,
          'numerazione_danea' : intervento.numerazione_danea,
          'data_apertura_intervento': intervento.data_apertura_intervento?.toIso8601String(),
          'data': intervento.data?.toIso8601String(),
          'orario_appuntamento' : intervento.orario_appuntamento?.toIso8601String(),
          'posizione_gps' : intervento.posizione_gps,
          'orario_inizio': intervento.orario_inizio?.toIso8601String(),
          'orario_fine': intervento.orario_fine?.toIso8601String(),
          'descrizione': intervento.descrizione,
          'utente_importo' : widget.utente.nomeCompleto(),
          'importo_intervento': double.parse(importoController.text),
          'saldo_tecnico' : intervento.saldo_tecnico,
          'prezzo_ivato' : intervento.prezzo_ivato,
          'iva' : intervento.iva,
          'assegnato': intervento.assegnato,
          'accettato_da_tecnico' : intervento.accettato_da_tecnico,
          'annullato' : intervento.annullato,
          'conclusione_parziale': intervento.conclusione_parziale,
          'concluso': intervento.concluso,
          'saldato': intervento.saldato,
          'saldato_da_tecnico' : intervento.saldato_da_tecnico,
          'note': intervento.note,
          'relazione_tecnico' : intervento.relazione_tecnico,
          'firma_cliente': intervento.firma_cliente,
          'utente_apertura' : intervento.utente_apertura?.toMap(),
          'utente': intervento.utente?.toMap(),
          'cliente': intervento.cliente?.toMap(),
          'veicolo': intervento.veicolo?.toMap(),
          'merce': intervento.merce?.toMap(),
          'tipologia': intervento.tipologia?.toMap(),
          'categoria': intervento.categoria_intervento_specifico?.toMap(),
          'tipologia_pagamento': intervento.tipologia_pagamento?.toMap(),
          'destinazione': intervento.destinazione?.toMap(),
          'gruppo' : intervento.gruppo?.toMap()
        }),
      );
      if (response.statusCode == 201) {
        print('EVVAIIIIIIII');
        Navigator.pop(context);
        setState(() {
          intervento.importo_intervento = double.parse(importoController.text);
        });
      }
    } catch (e) {
      print('Errore durante il salvataggio del preventivo: $e');
    }
  }

  @override
  Widget build(BuildContext context){
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
          'Dettaglio gruppo ${widget.gruppo.id}, ${widget.gruppo.descrizione}',
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
        ],
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Scrollbar(
          thumbVisibility: true,
          trackVisibility: true,
          controller: _scrollController,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Text('Tabella riepilogativa dei tecnici e degli importi complessivi dei loro interventi:', style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16, )
                        ),
                      ],
                    ),
                  ),
                  _UtenteImportoTable(_calculateUtenteImportoMap(allInterventi)),
                  Padding(padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text('Nota:', style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16, )
                            ),
                            SizedBox(width: 10),
                            Text('${widget.gruppo.note}', style: TextStyle(
                              fontSize: 14, )
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    child: DataTable(
                      showCheckboxColumn: false,
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
                          label: Text('Gruppo di interventi', style: TextStyle(fontWeight: FontWeight.bold)),
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
                          label: Text('Acconto', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Totale', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                      rows: filteredInterventi
                          .map((intervento) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(DateFormat('dd/MM/yyyy').format(intervento.data_apertura_intervento?? DateTime.now())),
                            ),
                            DataCell(
                              Text(DateFormat('dd/MM/yyyy').format(intervento.data?? DateTime.now())),
                            ),
                            DataCell(
                              Text(intervento.cliente?.denominazione?? 'N/A'),
                            ),
                            DataCell(
                              Text(intervento.gruppo?.descrizione ?? 'N/A'),
                            ),
                            DataCell(
                              Text(intervento.utente?.cognome?? 'N/A'),
                            ),
                            DataCell(
                              Text(intervento.descrizione?? 'N/A'),
                            ),
                            DataCell(
                              Container(
                                decoration: BoxDecoration(
                                  color: intervento.assegnato?? false? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  intervento.assegnato?? false? 'Assegnato' : 'Non assegnato',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                decoration: BoxDecoration(
                                  color: intervento.concluso?? false? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  intervento.concluso?? false? 'Concluso' : 'Non concluso',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                decoration: BoxDecoration(
                                  color: intervento.conclusione_parziale?? false? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  intervento.conclusione_parziale?? false? 'Terminato' : 'Conclusione Parziale',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(intervento.tipologia?.descrizione?.toString()?? 'N/A'),
                            ),
                            DataCell(
                              Text(
                                intervento.note!= null
                                    ? (intervento.note!.length > 30? intervento.note!.substring(0, 30) : intervento.note!)
                                    : 'N/A',
                              ),
                            ),
                            DataCell(
                              Container(
                                decoration: BoxDecoration(
                                  color: intervento.saldato?? false? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  intervento.saldato?? false? 'Saldato' : 'Non saldato',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(intervento.importo_intervento?.toStringAsFixed(2)?? 'N/A'),
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
                              Text(intervento.acconto?.toStringAsFixed(2)?? 'N/A'),
                            ),
                            DataCell(
                              Text(intervento.acconto!= null && intervento.importo_intervento!= null
                                  ? (intervento.importo_intervento! - intervento.acconto!).toStringAsFixed(2)
                                  : intervento.importo_intervento?.toStringAsFixed(2)?? 'N/A'),
                            ),
                          ],
                          onSelectChanged: (isSelected) {
                            if (isSelected!= null) {
                              if(Platform.isWindows){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DettaglioInterventoNewPage(intervento: intervento, utente : widget.utente),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DettaglioInterventoNewPageAndroid(intervento: intervento, utente : widget.utente),
                                  ),
                                );
                              }
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 50)
                ],
              ),
            ),
          ),
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Il gruppo di interventi è concluso?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      concludiGruppo();
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text('Si'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.check, color: Colors.white),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> getInterventiByGruppo() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/intervento/gruppo/${int.parse(widget.gruppo.id.toString())}');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<InterventoModel> interventi = [];
        for(var item in jsonData){
          interventi.add(InterventoModel.fromJson(item));
        }
        setState(() {
          allInterventi = interventi;
          filteredInterventi = interventi;
          isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load interventi data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching interventi: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getInterventiByGruppo();
  }


}

Widget _UtenteImportoTable(Map<String, Map<String, dynamic>> utenteInterventiMap) {
  return DataTable(
    columns: [
      DataColumn(label: Text('Utente')),
      DataColumn(label: Text('Numero Interventi')),
      DataColumn(label: Text('Importo Totale')),
    ],
    rows: utenteInterventiMap.entries.map((entry) {
      final utenteName = entry.key;
      final utenteInterventi = entry.value;
      final numInterventi = utenteInterventi['num_interventi'];
      final importoTotale = utenteInterventi['importo_totale'];

      return DataRow(
        cells: [
          DataCell(Text(utenteName)),
          DataCell(
              Center(
                child: Text(numInterventi.toString())),
              ),
          DataCell(Text(importoTotale.toStringAsFixed(2))),
        ],
      );
    }).toList(),
  );
}