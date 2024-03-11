import 'package:fema_crm/model/RelazionePreventivoProdottiModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fema_crm/model/PreventivoModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/ProdottoModel.dart';
import 'AggiuntaProdottoPreventivoPage.dart';

class DettaglioPreventivoAmministrazionePage extends StatefulWidget {
  final PreventivoModel preventivo;
  final VoidCallback? onNavigateBack;

  const DettaglioPreventivoAmministrazionePage({Key? key, required this.preventivo, this.onNavigateBack}) : super(key: key);

  @override
  _DettaglioPreventivoAmministrazionePageState createState() => _DettaglioPreventivoAmministrazionePageState();
}

class _DettaglioPreventivoAmministrazionePageState extends State<DettaglioPreventivoAmministrazionePage> {
  late http.Response response;
  List<RelazionePreventivoProdottiModel> allProdotti = [];

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
              Text(
                'Prodotti:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: allProdotti.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(allProdotti[index].prodotto?.descrizione ?? 'N/A'),
                    subtitle: Text('${allProdotti[index].prodotto?.prezzo_fornitore != null ? '${allProdotti[index].prodotto?.prezzo_fornitore?.toStringAsFixed(2)} \u20AC' : 'N/A'}'),
                  );
                },
              ),
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
                          builder: (context) => AggiuntaProdottoPreventivoPage(preventivo: widget.preventivo),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
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
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
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
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    child: Text('Rifiutato'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      consegnato();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    child: Text('Consegnato'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getProdotti() async {
    try {
      var apiUrl = Uri.parse('http://192.168.1.52:8080/api/relazionePreventivoProdotto/preventivo/${widget.preventivo.id}');
      var response = await http.get(apiUrl);

      if(response.statusCode == 200){
        debugPrint('JSON ricevuto: ${response.body}', wrapWidth: 1024);
        var jsonData = jsonDecode(response.body);
        List<RelazionePreventivoProdottiModel> prodotti =[];
        for(var item in jsonData) {
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

  Future<void> accettato() async {
    late http.Response response;
    try {
      response = await http.post(
        Uri.parse('http://192.168.1.52:8080/api/preventivo'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
        body: json.encode({
          'id': widget.preventivo.id,
          'data_creazione' : widget.preventivo.data_creazione?.toIso8601String(),
          'azienda': widget.preventivo.azienda?.toJson(),
          'categoria_merceologica': widget.preventivo.categoria_merceologica,
          'listino': widget.preventivo.listino,
          'descrizione': widget.preventivo.descrizione,
          'importo': widget.preventivo.importo,
          'cliente': widget.preventivo.cliente?.toJson(),
          'accettato': true,
          'rifiutato' : false,
          'attesa': false,
          'pendente': true,
          'consegnato': false,
          'provvigioni': widget.preventivo.provvigioni,
          'data_consegna': widget.preventivo.data_consegna?.toIso8601String(),
          'data_accettazione' : DateTime.now().toIso8601String(),
          'utente': widget.preventivo.utente?.toJson(),
          'agente' : widget.preventivo.agente?.toJson(),
          'prodotti' : widget.preventivo.prodotti
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
        print(response.body.toString());
      }
    } catch(e) {
      print(e.toString());
    }
  }

  Future<void> rifiutato() async {
    late http.Response response;
    try {
      response = await http.post(
        Uri.parse('http://192.168.1.52:8080/api/preventivo'),
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
          'accettato': false,
          'rifiutato': true,
          'attesa': false,
          'pendente': false,
          'consegnato': false,
          'provvigioni': widget.preventivo.provvigioni,
          'data_consegna': widget.preventivo.data_consegna?.toIso8601String(),
          'data_accettazione' : widget.preventivo.data_accettazione?.toIso8601String(),
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
        print(response.body.toString());
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> consegnato() async {
    late http.Response response;
    try {
      response = await http.post(
        Uri.parse('http://192.168.1.52:8080/api/preventivo'),
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
          'accettato': false,
          'rifiutato': false,
          'attesa': false,
          'pendente': false,
          'consegnato': true,
          'provvigioni': widget.preventivo.provvigioni,
          'data_consegna': DateTime.now().toIso8601String(),
          'data_accettazione' : widget.preventivo.data_accettazione?.toIso8601String(),
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
        print(response.body.toString());
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
