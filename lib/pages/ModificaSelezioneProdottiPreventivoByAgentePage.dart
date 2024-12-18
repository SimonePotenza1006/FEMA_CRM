import 'dart:async';
import 'package:fema_crm/pages/HomeFormTecnicoNewPage.dart';
import 'package:fema_crm/pages/ReportPreventiviPage.dart';
import 'package:flutter/material.dart';
import 'package:fema_crm/model/ProdottoModel.dart';
import '../model/PreventivoModel.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/RelazionePreventivoProdottiModel.dart';

class ModificaSelezioneProdottiPreventivoByAgentePage extends StatefulWidget {
  final List<ProdottoModel> prodottiSelezionati;
  final PreventivoModel preventivo;

  const ModificaSelezioneProdottiPreventivoByAgentePage({
    Key? key,
    required this.prodottiSelezionati,
    required this.preventivo,
  }) : super(key: key);

  @override
  _ModificaSelezioneProdottiPreventivoByAgentePageState createState() =>
      _ModificaSelezioneProdottiPreventivoByAgentePageState();
}

class _ModificaSelezioneProdottiPreventivoByAgentePageState
    extends State<ModificaSelezioneProdottiPreventivoByAgentePage> {
  late List<double> quantitaProdotti;
  late List<TextEditingController> quantityControllers;
  late Timer _debounce;
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';
  List<RelazionePreventivoProdottiModel> allProdotti = [];

  @override
  void initState() {
    print("Id preventivo:" + widget.preventivo.id.toString());
    print("Provvigioni preventivo:" + widget.preventivo.listino.toString());
    print("Provvigioni agente:" +
        widget.preventivo.agente!.categoria_provvigione.toString());
    super.initState();
    quantitaProdotti = List.filled(widget.prodottiSelezionati.length, 1);
    quantityControllers = List.generate(
        widget.prodottiSelezionati.length, (index) => TextEditingController());
    for (int i = 0; i < widget.prodottiSelezionati.length; i++) {
      quantityControllers[i].text = '1';
    }
    _debounce = Timer(Duration(milliseconds: 500), () {});
    getProdotti(); // Inizializzazione del timer debounce
  }

  @override
  void dispose() {
    // Assicurati di cancellare il timer quando lo stato viene eliminato
    _debounce.cancel();
    super.dispose();
  }

  void _onQuantityChanged(String value, int index) {
    // Cancella il debounce se esiste già
    if (_debounce.isActive) _debounce.cancel();

    // Avvia un nuovo debounce
    _debounce = Timer(Duration(milliseconds: 500), () {
      setState(() {
        quantitaProdotti[index] = double.tryParse(value) ?? 0;
      });
    });
  }

  double _calculateTotalAmount() {
    double totalAmount = 0;

    // Calcola il totale per i prodotti selezionati
    for (int i = 0; i < widget.prodottiSelezionati.length; i++) {
      double productPrice = widget.prodottiSelezionati[i].prezzo_fornitore ?? 0;
      double listino = double.tryParse(widget.preventivo.listino!.substring(0, 2)) ?? 0;
      double quantity = quantitaProdotti[i];

      totalAmount += (productPrice + (productPrice * (listino / 100))) * quantity;
    }

    // Calcola il totale per i prodotti ottenuti dalla chiamata API
    for (int i = 0; i < allProdotti.length; i++) {
      double productPrice = allProdotti[i].prodotto?.prezzo_fornitore ?? 0;
      double listino = double.tryParse(widget.preventivo.listino!.substring(0, 2)) ?? 0;
      double quantity = 1; // Quantità fissa per i prodotti ottenuti dalla chiamata API

      totalAmount += (productPrice + (productPrice * (listino / 100))) * quantity;
    }

    return totalAmount;
  }

  double _calculateAgentCommission() {
    double totalCommission = 0;
    double agentCommissionPercentage = widget.preventivo.agente!.categoria_provvigione ?? 0;

    // Calcola le provvigioni per i prodotti selezionati
    for (int i = 0; i < widget.prodottiSelezionati.length; i++) {
      double productPrice = widget.prodottiSelezionati[i].prezzo_fornitore ?? 0;
      double listino = double.tryParse(widget.preventivo.listino!.substring(0, 2)) ?? 0;
      double quantity = quantitaProdotti[i];

      // Calcola il prezzo finale del prodotto con il listino applicato
      double finalProductPrice = productPrice + (productPrice * (listino / 100));

      // Calcola la differenza tra il prezzo finale e il prezzo di fornitore del prodotto, moltiplicato per la quantità
      double priceDifference = (finalProductPrice - productPrice) * quantity;

      // Calcola le provvigioni dell'agente per questo prodotto
      double productCommission = priceDifference * (agentCommissionPercentage / 100);

      // Aggiungi le provvigioni dell'agente al totale
      totalCommission += productCommission;
    }

    // Calcola le provvigioni per i prodotti ottenuti dalla chiamata API
    for (int i = 0; i < allProdotti.length; i++) {
      double productPrice = allProdotti[i].prodotto?.prezzo_fornitore ?? 0;
      double listino = double.tryParse(widget.preventivo.listino!.substring(0, 2)) ?? 0;
      double quantity = 1; // Quantità fissa per i prodotti ottenuti dalla chiamata API

      // Calcola il prezzo finale del prodotto con il listino applicato
      double finalProductPrice = productPrice + (productPrice * (listino / 100));

      // Calcola la differenza tra il prezzo finale e il prezzo di fornitore del prodotto
      double priceDifference = finalProductPrice - productPrice;

      // Calcola le provvigioni dell'agente per questo prodotto
      double productCommission = priceDifference * (agentCommissionPercentage / 100);

      // Aggiungi le provvigioni dell'agente al totale
      totalCommission += productCommission;
    }

    return totalCommission;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Modifica Selezione Prodotti Preventivo',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.prodottiSelezionati.length + allProdotti.length,
              itemBuilder: (context, index) {
                if (index < widget.prodottiSelezionati.length) {
                  final prodotto = widget.prodottiSelezionati[index];
                  return ListTile(
                    title: Text(prodotto.descrizione ?? ''),
                    subtitle: Text('Prezzo: ${prodotto.prezzo_fornitore} €'),
                    trailing: SizedBox(
                      width: 150, // Limita la larghezza del trailing
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Quantità:'),
                          SizedBox(width: 5),
                          SizedBox(
                            width:
                            50, // Imposta una larghezza fissa per il TextField
                            child: TextField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              controller: quantityControllers[index],
                              onChanged: (value) {
                                _onQuantityChanged(value, index);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  final prodotto =
                  allProdotti[index - widget.prodottiSelezionati.length];
                  return ListTile(
                    title: Text(prodotto.prodotto?.descrizione ?? ''),
                    subtitle:
                    Text('Prezzo: ${prodotto.prodotto?.prezzo_fornitore} €'),
                    trailing: SizedBox(
                      width: 150, // Limita la larghezza del trailing
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Quantità:'),
                          SizedBox(width: 5),
                          SizedBox(
                            width:
                            50, // Imposta una larghezza fissa per il TextField
                            child: TextField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              controller: TextEditingController(text: '1'),
                              onChanged: (value) {
                                // Implementa la logica di aggiornamento della quantità per i prodotti ottenuti dalla chiamata API
                                // Suggerimento: puoi mantenere una lista separata di controller per questi prodotti se necessario
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Totale preventivo: ${_calculateTotalAmount().toStringAsFixed(2)} €',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Totale provvigioni: ${_calculateAgentCommission().toStringAsFixed(2)} €',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Riepilogo Prodotti',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: widget.prodottiSelezionati.length,
                              itemBuilder: (context, index) {
                                final prodotto =
                                widget.prodottiSelezionati[index];
                                return ListTile(
                                  title: Text(prodotto.descrizione ?? ''),
                                  subtitle: Text(
                                      'Quantità: ${quantitaProdotti[index]}'),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Totale Preventivo: ${_calculateTotalAmount().toStringAsFixed(2)} €',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Totale Provvigioni: ${_calculateAgentCommission().toStringAsFixed(2)} €',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  aggiornaPreventivo();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          HomeFormTecnicoNewPage(userData: widget.preventivo.utente),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: Colors.red,
                                  padding: EdgeInsets.all(12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: Text(
                                  'Inserisci',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                'Conferma inserimento',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getProdotti() async {
    try {
      var apiUrl = Uri.parse(
          '$ipaddress/api/relazionePreventivoProdotto/preventivo/${widget.preventivo.id}');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        debugPrint('JSON ricevuto: ${response.body}', wrapWidth: 1024);
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<RelazionePreventivoProdottiModel> prodotti = [];
        for (var item in jsonData) {
          prodotti.add(RelazionePreventivoProdottiModel.fromJson(item));
        }
        setState(() {
          allProdotti = prodotti;
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

  Future<void> aggiornaPreventivo() async {
    double importoPreventivo = _calculateTotalAmount();
    double totaleProvvigioni = _calculateAgentCommission();

    late http.Response response;
    try {
      // Chiamata POST per aggiornare il preventivo
      response = await http.post(
        Uri.parse('$ipaddress/api/preventivo'),
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
          'importo': importoPreventivo,
          'cliente': widget.preventivo.cliente?.toJson(),
          'destinazione': widget.preventivo.destinazione?.toJson(),
          'accettato': widget.preventivo.accettato,
          'rifiutato': widget.preventivo.rifiutato,
          'attesa': widget.preventivo.attesa,
          'pendente': widget.preventivo.pendente,
          'consegnato': widget.preventivo.consegnato,
          'provvigioni': totaleProvvigioni,
          'data_consegna': null,
          'data_accettazione': null,
          'utente': widget.preventivo.utente?.toJson(),
          'agente': widget.preventivo.agente?.toJson(),
        }),
      );

      if (response.statusCode == 201) {
        print("Preventivo aggiornato con successo");

        // Chiamata POST per ogni prodotto della lista dei prodotti selezionati
        for (int i = 0; i < widget.prodottiSelezionati.length; i++) {
          final prodotto = widget.prodottiSelezionati[i];
          final quantita = quantitaProdotti[i];

          response = await http.post(
            Uri.parse('$ipaddress/api/relazionePreventivoProdotto'),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json"
            },
            body: json.encode({
              'preventivo': widget.preventivo.toJson(),
              'prodotto': prodotto.toJson(),
              'quantita': quantita,
            }),
          );

          if (response.statusCode == 201) {
            print(
                "Relazione preventivo-prodotto aggiornata con successo per il prodotto ${prodotto.id}");
          } else {
            print(
                "Errore durante l'aggiornamento della relazione preventivo-prodotto per il prodotto ${prodotto.id}");
            debugPrint(response.body, wrapWidth: 1024);
          }
        }
      } else {
        print("Errore durante l'aggiornamento del preventivo");
        print(response.body);
      }
    } catch (e) {
      print("Errore durante l'aggiornamento del preventivo: $e");
    }
  }
}
