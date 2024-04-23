import 'package:fema_crm/model/RelazionePreventivoProdottiModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fema_crm/model/PreventivoModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/ProdottoModel.dart';
import 'AggiuntaProdottoPreventivoPage.dart';
import 'ConsegnaMaterialePreventivoPage.dart';
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

  @override
  void initState() {
    super.initState();
    // Chiamata all'API
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
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Azienda:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text(
                '${widget.preventivo.azienda?.nome.toString() ?? 'N/A'}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              buildLightDivider(), // Riga divisoria grigia chiara
              SizedBox(height: 8.0),
              Text(
                'Categoria Merceologica:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text(
                '${widget.preventivo.categoria_merceologica ?? 'N/A'}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              buildDarkDivider(), // Riga divisoria grigia scura
              SizedBox(height: 8.0),
              Text(
                'Cliente:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text(
                '${widget.preventivo.cliente?.denominazione ?? 'N/A'}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              buildLightDivider(), // Riga divisoria grigia chiara
              SizedBox(height: 8.0),
              Text(
                'Agente:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text(
                '${widget.preventivo.agente?.nome ?? 'N/A'}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              buildDarkDivider(), // Riga divisoria grigia scura
              SizedBox(height: 8.0),
              Text(
                'Utente:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text(
                '${widget.preventivo.utente?.cognome ?? 'N/A'}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              buildLightDivider(), // Riga divisoria grigia chiara
              SizedBox(height: 8.0),
              Text(
                'Listino:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text(
                '${widget.preventivo.listino ?? 'N/A'}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              buildDarkDivider(), // Riga divisoria grigia scura
              SizedBox(height: 8.0),
              Text(
                'Prodotti:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4, // Altezza massima desiderata
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allProdotti.length,
                  itemBuilder: (context, index) {
                    final prezzoFornitore =
                        allProdotti[index].prodotto?.prezzo_fornitore ?? 0;
                    final listino = widget.preventivo.listino != null &&
                        widget.preventivo.listino!.length >= 2
                        ? double.tryParse(
                        widget.preventivo.listino!.substring(0, 2)) ??
                        0
                        : 0;
                    final prezzoVendita = prezzoFornitore * (1 + listino / 100);
                    return ListTile(
                      title:
                      Text(allProdotti[index].prodotto?.descrizione ?? 'N/A'),
                      subtitle: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Prezzo di vendita: ',
                            ),
                            TextSpan(
                              text: '${prezzoFornitore.toStringAsFixed(2)} € ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.blue, // Colore blu
                              ),
                            ),
                            TextSpan(
                              text:
                              '(Prezzo fornitore) + ${listino.toStringAsFixed(2)}% = ',
                            ),
                            TextSpan(
                              text: '${prezzoVendita.toStringAsFixed(2)} €',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.lightGreen[700], // Colore verde
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 8.0),
              buildLightDivider(), // Riga divisoria grigia chiara
              SizedBox(height: 8.0),
              Text(
                'Importo:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text(
                '${widget.preventivo.importo != null ? '${widget.preventivo.importo?.toStringAsFixed(2)} \u20AC' : 'N/A'}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              buildDarkDivider(), // Riga divisoria grigia scura
              SizedBox(height: 8.0),
              Text(
                'Provvigioni:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text(
                '${widget.preventivo.provvigioni != null ? '${widget.preventivo.provvigioni?.toStringAsFixed(2)} \u20AC' : 'N/A'}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              buildLightDivider(), // Riga divisoria grigia chiara
              SizedBox(height: 8.0),
              Text(
                'Accettato:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text(
                '${widget.preventivo.accettato ?? false ? 'SI' : 'NO'}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              buildDarkDivider(), // Riga divisoria grigia scura
              SizedBox(height: 8.0),
              Text(
                'Rifiutato:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text(
                '${widget.preventivo.rifiutato ?? false ? 'SI' : 'NO'}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              buildLightDivider(), // Riga divisoria grigia chiara
              SizedBox(height: 8.0),
              Text(
                'Attesa:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text(
                '${widget.preventivo.attesa ?? false ? 'SI' : 'NO'}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              buildDarkDivider(), // Riga divisoria grigia scura
              SizedBox(height: 8.0),
              Text(
                'Consegnato:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text(
                '${widget.preventivo.consegnato ?? false ? 'SI' : 'NO'}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              buildLightDivider(), // Riga divisoria grigia chiara
              SizedBox(height: 8.0),
              Text(
                'Data Creazione:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text(
                '${widget.preventivo.data_creazione != null ? DateFormat('yyyy-MM-dd').format(widget.preventivo.data_creazione!) : 'N/A'}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              buildDarkDivider(), // Riga divisoria grigia scura
              SizedBox(height: 8.0),
              Text(
                'Data Accettazione:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text(
                '${widget.preventivo.data_accettazione != null ? DateFormat('yyyy-MM-dd').format(widget.preventivo.data_accettazione!) : 'Non consegnato'}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 8.0),
              buildLightDivider(), // Riga divisoria grigia chiara
              SizedBox(height: 8.0),
              Text(
                'Data Consegna:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text(
                '${widget.preventivo.data_consegna != null ? DateFormat('yyyy-MM-dd').format(widget.preventivo.data_consegna!) : 'Non consegnato'}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AggiuntaProdottoPreventivoPage(
                              preventivo: widget.preventivo),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    child: Text('Aggiungi prodotto'),
                  ),
                ],
              ),

              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      accettato();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    child: Text('Accettato'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      rifiutato();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    child: Text('Rifiutato'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ConsegnaMaterialePreventivoPage(preventivo: widget.preventivo),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    child: Text('Consegna'),
                  ),
                ],
              ),
              SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
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
                      primary: Colors.red,
                      onPrimary: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    child: Text('Genera PDF'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
          '${ipaddress}/api/relazionePreventivoProdotto/preventivo/${widget.preventivo.id}');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
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
        Uri.parse('${ipaddress}/api/preventivo'),
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
          'prodotti': widget.preventivo.prodotti
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
        Uri.parse('${ipaddress}/api/preventivo'),
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
          'prodotti': widget.preventivo.prodotti
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
         Uri.parse('${ipaddress}/api/preventivo'),
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
           'prodotti': widget.preventivo.prodotti
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
