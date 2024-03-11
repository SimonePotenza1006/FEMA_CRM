import 'dart:async';
import 'package:fema_crm/pages/ReportPreventiviPage.dart';
import 'package:flutter/material.dart';
import 'package:fema_crm/model/ProdottoModel.dart';
import '../model/PreventivoModel.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class ModificaSelezioneProdottiPreventivoPage extends StatefulWidget {
  final List<ProdottoModel> prodottiSelezionati;
  final PreventivoModel preventivo;

  const ModificaSelezioneProdottiPreventivoPage({
    Key? key,
    required this.prodottiSelezionati,
    required this.preventivo,
  }) : super(key: key);

  @override
  _ModificaSelezioneProdottiPreventivoPageState createState() =>
      _ModificaSelezioneProdottiPreventivoPageState();
}

class _ModificaSelezioneProdottiPreventivoPageState
    extends State<ModificaSelezioneProdottiPreventivoPage> {
  late List<int> quantitaProdotti;
  late List<TextEditingController> quantityControllers;
  late Timer _debounce;

  @override
  void initState() {
    print("Id preventivo:" + widget.preventivo.id.toString());
    print("Provvigioni preventivo:" + widget.preventivo.listino.toString());
    print("Provvigioni agente:" +
        widget.preventivo.agente!.categoria_provvigione.toString());
    super.initState();
    quantitaProdotti =
        List.filled(widget.prodottiSelezionati.length, 1);
    quantityControllers = List.generate(
        widget.prodottiSelezionati.length,
            (index) => TextEditingController());
    for (int i = 0; i < widget.prodottiSelezionati.length; i++) {
      quantityControllers[i].text = '1';
    }
    _debounce =
        Timer(Duration(milliseconds: 500), () {}); // Inizializzazione del timer debounce
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
        quantitaProdotti[index] = int.tryParse(value) ?? 0;
      });
    });
  }

  double _calculateTotalAmount() {
    double totalAmount = 0;

    for (int i = 0; i < widget.prodottiSelezionati.length; i++) {
      double productPrice =
          widget.prodottiSelezionati[i].prezzo_fornitore ?? 0;
      double listino =
          double.tryParse(widget.preventivo.listino!.substring(0, 2)) ?? 0;
      int quantity = quantitaProdotti[i];

      totalAmount +=
          (productPrice + (productPrice * (listino / 100))) * quantity;
    }

    return totalAmount;
  }

  double _calculateAgentCommission() {
    double totalCommission = 0;
    double agentCommissionPercentage =
        widget.preventivo.agente!.categoria_provvigione ?? 0;

    for (int i = 0; i < widget.prodottiSelezionati.length; i++) {
      double productPrice =
          widget.prodottiSelezionati[i].prezzo_fornitore ?? 0;
      double listino =
          double.tryParse(widget.preventivo.listino!.substring(0, 2)) ?? 0;
      int quantity = quantitaProdotti[i];

      // Calcola il prezzo finale del prodotto con il listino applicato
      double finalProductPrice = productPrice + (productPrice * (listino / 100));

      // Calcola la differenza tra il prezzo finale e il prezzo di fornitore del prodotto, moltiplicato per la quantità
      double priceDifference = (finalProductPrice - productPrice) * quantity;

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
              itemCount: widget.prodottiSelezionati.length,
              itemBuilder: (context, index) {
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
                          width: 50, // Imposta una larghezza fissa per il TextField
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
                                      builder: (context) => ReportPreventiviPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.red,
                                  onPrimary: Colors.white,
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
                primary: Colors.red,
                onPrimary: Colors.white,
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

  Future<void> inserisciProdotti() async {

  }

  Future<void> aggiornaPreventivo() async {
    double importoPreventivo = _calculateTotalAmount();
    double totaleProvvigioni = _calculateAgentCommission();

    late http.Response response;
    try {
      // Chiamata POST per aggiornare il preventivo
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
          'importo': importoPreventivo,
          'cliente': widget.preventivo.cliente?.toJson(),
          'accettato': widget.preventivo.accettato,
          'rifiutato': widget.preventivo.rifiutato,
          'attesa': widget.preventivo.attesa,
          'pendente': widget.preventivo.pendente,
          'consegnato': widget.preventivo.consegnato,
          'provvigioni': totaleProvvigioni,
          'data_consegna': DateTime.now().toIso8601String(),
          'data_accettazione' : widget.preventivo.data_accettazione?.toIso8601String(),
          'utente': widget.preventivo.utente?.toJson(),
          'agente': widget.preventivo.agente?.toJson(),
          'prodotti': widget.preventivo.prodotti
        }),
      );

      if (response.statusCode == 201) {
        print("Preventivo aggiornato con successo");

        // Chiamata POST per ogni prodotto della lista dei prodotti selezionati
        for (int i = 0; i < widget.prodottiSelezionati.length; i++) {
          final prodotto = widget.prodottiSelezionati[i];
          final quantita = quantitaProdotti[i];

          response = await http.post(
            Uri.parse('http://192.168.1.52:8080/api/relazionePreventivoProdotto'),
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
            print("Relazione preventivo-prodotto aggiornata con successo per il prodotto ${prodotto.id}");
          } else {
            print("Errore durante l'aggiornamento della relazione preventivo-prodotto per il prodotto ${prodotto.id}");
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
