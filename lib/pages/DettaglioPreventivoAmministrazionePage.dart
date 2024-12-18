import 'package:fema_crm/model/RelazionePreventivoProdottiModel.dart';
import 'package:fema_crm/pages/ModificaVecchiProdottiPreventivoPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fema_crm/model/PreventivoModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'AggiuntaProdottoPreventivoPage.dart';
import 'ConsegnaMaterialePreventivoPage.dart';
import 'PDFPreventivoNewPage.dart';
import 'PDFPreventivoPage.dart';

class DettaglioPreventivoAmministrazionePage extends StatefulWidget {
  final PreventivoModel preventivo;
  final VoidCallback? onNavigateBack;

  const DettaglioPreventivoAmministrazionePage(
      {Key? key, required this.preventivo, this.onNavigateBack})
      : super(key: key);

  @override
  _DettaglioPreventivoAmministrazionePageState createState() =>
      _DettaglioPreventivoAmministrazionePageState();
}

class _DettaglioPreventivoAmministrazionePageState
    extends State<DettaglioPreventivoAmministrazionePage> {
  late http.Response response;
  List<RelazionePreventivoProdottiModel> allProdotti = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';

  @override
  void initState() {
    super.initState();
    getProdotti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dettaglio Preventivo',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildDettagliPreventivo(),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: _buildProdottiPreventivo(),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildActionButtons()
                          ],
                        )
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDettagliPreventivo(),
                        SizedBox(height: 20),
                        _buildProdottiPreventivo(),
                        SizedBox(height: 20),
                        _buildActionButtons()
                      ],
                    );
                  }
                },
              ),
            ],
          )
        ),
      ),
    );
  }

  Widget _buildDettagliPreventivo() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: DataTable(
        showCheckboxColumn: false,
        columns: [
          DataColumn(
            label: Text(
              'Codice identificativo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(label: Text('ID ${widget.preventivo.id}')),
        ],
        rows: [
          DataRow(
            cells: [
              DataCell(
                Text(
                  'Azienda',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text('${widget.preventivo.azienda?.nome ?? 'N/A'}'),
              ),
            ],
          ),
          DataRow(
            cells: [
              DataCell(
                Text(
                  'Categoria Merceologica',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text('${widget.preventivo.categoria_merceologica ?? 'N/A'}'),
              ),
            ],
          ),
          DataRow(
            cells: [
              DataCell(
                Text(
                  'Cliente',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text('${widget.preventivo.cliente?.denominazione ?? 'N/A'}'),
              ),
            ],
          ),
          DataRow(
            cells: [
              DataCell(
                Text(
                  'Agente',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text('${widget.preventivo.agente?.nome ?? 'N/A'}'),
              ),
            ],
          ),
          DataRow(
            cells: [
              DataCell(
                Text(
                  'Utente',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text('${widget.preventivo.utente?.cognome ?? 'N/A'}'),
              ),
            ],
          ),
          DataRow(
            cells: [
              DataCell(
                Text(
                  'Listino',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text('${widget.preventivo.listino ?? 'N/A'}'),
              ),
            ],
          ),
          DataRow(
            cells: [
              DataCell(
                Text(
                  'Importo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text('${widget.preventivo.importo != null ? '${widget.preventivo.importo?.toStringAsFixed(2)} €' : 'N/A'}'),
              ),
            ],
          ),
          DataRow(
            cells: [
              DataCell(
                Text(
                  'Provvigioni',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text('${widget.preventivo.provvigioni != null ? '${widget.preventivo.provvigioni?.toStringAsFixed(2)} €' : 'N/A'}'),
              ),
            ],
          ),
          DataRow(
            cells: [
              DataCell(
                Text(
                  'Accettato',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text('${widget.preventivo.accettato ?? false ? 'SI' : 'NO'}'),
              ),
            ],
          ),
          DataRow(
            cells: [
              DataCell(
                Text(
                  'Rifiutato',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text('${widget.preventivo.rifiutato ?? false ? 'SI' : 'NO'}'),
              ),
            ],
          ),
          DataRow(
            cells: [
              DataCell(
                Text(
                  'Attesa',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text('${widget.preventivo.attesa ?? false ? 'SI' : 'NO'}'),
              ),
            ],
          ),
          DataRow(
            cells: [
              DataCell(
                Text(
                  'Consegnato',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text('${widget.preventivo.consegnato ?? false ? 'SI' : 'NO'}'),
              ),
            ],
          ),
          DataRow(
            cells: [
              DataCell(
                Text(
                  'Data Creazione',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text('${widget.preventivo.data_creazione != null ? DateFormat('yyyy-MM-dd').format(widget.preventivo.data_creazione!) : 'N/A'}'),
              ),
            ],
          ),
          DataRow(
            cells: [
              DataCell(
                Text(
                  'Data Accettazione',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text('${widget.preventivo.data_accettazione != null ? DateFormat('yyyy-MM-dd').format(widget.preventivo.data_accettazione!) : 'Non consegnato'}'),
              ),
            ],
          ),
          DataRow(
            cells: [
              DataCell(
                Text(
                  'Data Consegna',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text('${widget.preventivo.data_consegna != null ? DateFormat('yyyy-MM-dd').format(widget.preventivo.data_consegna!) : 'Non consegnato'}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProdottiPreventivo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRODOTTI',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.0),
        Container(
          height: 745,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text(
                      'Descrizione',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'P. Fornitore',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'P. Vendita',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Quantità',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: List<DataRow>.generate(
                  allProdotti.length,
                      (index) {
                    final prodotto = allProdotti[index].prodotto;
                    final prezzoFornitore = prodotto?.prezzo_fornitore ?? 0;
                    final prezzoNoListino = allProdotti[index].prezzo ?? 0;
                    final listino = widget.preventivo.listino != null &&
                        widget.preventivo.listino!.length >= 2
                        ? double.tryParse(widget.preventivo.listino!.substring(0, 2)) ?? 0
                        : 0;
                    final prezzoVendita = prezzoNoListino * (1 + listino / 100);
                    final quantita = allProdotti[index].quantita!;

                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(prodotto?.descrizione ?? 'N/A')),
                        DataCell(
                          Text(
                            '${prezzoFornitore.toStringAsFixed(2)}€',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${prezzoNoListino.toStringAsFixed(2)}€',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${quantita}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        //SizedBox(height: 50.0),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          height: 43,
        ),
        SizedBox(
          width: 200,
          child: ElevatedButton(

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AggiuntaProdottoPreventivoPage(
                          preventivo: widget.preventivo),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),

            ),
            child: Text('Aggiungi prodotto'),
          ),
        ),

            SizedBox(height: 16.0),
            if(allProdotti.isNotEmpty)
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ModificaVecchiProdottiPreventivoPage(prodotti: allProdotti, preventivo : widget.preventivo),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  child: Text('Modifica prodotti'),
                ),
              ),
        SizedBox(height: 16.0),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  accettato();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: Text('Accettato'),
              ),
            ),
        SizedBox(height: 18),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  rifiutato();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: Text('Rifiutato'),
              ),
            ),
        SizedBox(height: 18),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ConsegnaMaterialePreventivoPage(
                              preventivo: widget.preventivo),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: Text('Consegna'),
              ),
            ),
            SizedBox(height: 18),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PDFPreventivoPage(preventivo: widget.preventivo),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: Text('Genera PDF'),
              ),
            ),
      ],
    );
  }

  // Funzione per creare una riga divisoria grigia chiara
  Widget buildLightDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[300],
    );
  }

  // Funzione per creare una riga divisoria grigia scura
  Widget buildDarkDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[600],
    );
  }



  // Funzione per ottenere i prodotti dal backend
  Future<void> getProdotti() async {
    try {
      var apiUrl = Uri.parse(
          '$ipaddress2/api/relazionePreventivoProdotto/preventivo/${widget.preventivo.id}');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<RelazionePreventivoProdottiModel> prodotti = [];
        for (var item in jsonData) {
          prodotti.add(RelazionePreventivoProdottiModel.fromJson(item));
        }
        setState(() {
          allProdotti = prodotti;
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

  Future<void> accettato() async {
    late http.Response response;
    try {
      response = await http.post(
        Uri.parse('$ipaddress2/api/preventivo'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
        body: json.encode({
          'id': widget.preventivo.id,
          'data_creazione': widget.preventivo.data_creazione?.toIso8601String(),
          'azienda': widget.preventivo.azienda?.toJson(),
          'categoria_merceologica': widget.preventivo.categoria_merceologica,
          'listino': widget.preventivo.listino,
          'descrizione': widget.preventivo.descrizione,
          'importo': widget.preventivo.importo,
          'cliente': widget.preventivo.cliente?.toJson(),
          'destinazione': widget.preventivo.destinazione?.toJson(),
          'accettato': true,
          'rifiutato': false,
          'attesa': false,
          'pendente': true,
          'consegnato': false,
          'provvigioni': widget.preventivo.provvigioni,
          'data_consegna': null,
          'data_accettazione': DateTime.now().toIso8601String(),
          'utente': widget.preventivo.utente?.toJson(),
          'agente': widget.preventivo.agente?.toJson(),
        }),
      );
      if (response.statusCode == 201) {
        print("Preventivo accettato");
        Navigator.pop(context);
        if (widget.onNavigateBack != null) {
          widget.onNavigateBack!();
        }
      } else {
        print("Hai toppato :(");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> rifiutato() async {
    late http.Response response;
    try {
      response = await http.post(
        Uri.parse('$ipaddress2/api/preventivo'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
        body: json.encode({
          'id': widget.preventivo.id,
          'data_creazione': widget.preventivo.data_creazione?.toIso8601String(),
          'azienda': widget.preventivo.azienda?.toJson(),
          'categoria_merceologica': widget.preventivo.categoria_merceologica,
          'listino': widget.preventivo.listino,
          'descrizione': widget.preventivo.descrizione,
          'importo': widget.preventivo.importo,
          'cliente': widget.preventivo.cliente?.toJson(),
          'destinazione': widget.preventivo.destinazione?.toJson(),
          'accettato': false,
          'rifiutato': true,
          'attesa': false,
          'pendente': false,
          'consegnato': false,
          'provvigioni': widget.preventivo.provvigioni,
          'data_consegna': null,
          'data_accettazione':
          null,
          'utente': widget.preventivo.utente?.toJson(),
          'agente': widget.preventivo.agente?.toJson(),
        }),
      );
      if (response.statusCode == 201) {
        print("Preventivo rifiutato");
        Navigator.pop(context);
        if (widget.onNavigateBack != null) {
          widget.onNavigateBack!();
        }
      } else {
        print("Hai toppato :(");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> consegnato() async {
    late http.Response response;
    try {
      response = await http.post(
        Uri.parse('$ipaddress2/api/preventivo'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
        body: json.encode({
          'id': widget.preventivo.id,
          'data_creazione': widget.preventivo.data_creazione?.toIso8601String(),
          'azienda': widget.preventivo.azienda?.toJson(),
          'categoria_merceologica': widget.preventivo.categoria_merceologica,
          'listino': widget.preventivo.listino,
          'descrizione': widget.preventivo.descrizione,
          'importo': widget.preventivo.importo,
          'cliente': widget.preventivo.cliente?.toJson(),
          'destinazione': widget.preventivo.destinazione?.toJson(),
          'accettato': false,
          'rifiutato': false,
          'attesa': false,
          'pendente': false,
          'consegnato': true,
          'provvigioni': widget.preventivo.provvigioni,
          'data_consegna': DateTime.now().toIso8601String(),
          'data_accettazione':
          widget.preventivo.data_accettazione?.toIso8601String(),
          'utente': widget.preventivo.utente?.toJson(),
          'agente': widget.preventivo.agente?.toJson(),
        }),
      );
      if (response.statusCode == 201) {
        print("Preventivo consegnato");
        Navigator.pop(context);
        if (widget.onNavigateBack != null) {
          widget.onNavigateBack!();
        }
      } else {
        print("Hai toppato :(");
      }
    } catch (e) {
      print(e.toString());
    }
  }
}