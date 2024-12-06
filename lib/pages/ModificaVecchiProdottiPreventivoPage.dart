import 'package:fema_crm/pages/ReportPreventiviPage.dart';
import 'package:flutter/material.dart';
import 'package:fema_crm/model/ProdottoModel.dart';
import '../model/PreventivoModel.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/RelazionePreventivoProdottiModel.dart';

class ModificaVecchiProdottiPreventivoPage extends StatefulWidget{
  final List<RelazionePreventivoProdottiModel> prodotti;
  final PreventivoModel preventivo;

  const ModificaVecchiProdottiPreventivoPage({
    Key? key,
    required this.prodotti,
    required this.preventivo,
  }) : super(key: key);

  @override
  _ModificaVecchiProdottiPreventivoPageState createState() =>
      _ModificaVecchiProdottiPreventivoPageState();
}

class _ModificaVecchiProdottiPreventivoPageState extends State<ModificaVecchiProdottiPreventivoPage> {
  List<double> quantitaProdotti = [];
  List<TextEditingController> quantityControllers = [];
  List<double> nuoviPrezzi = [];
  List<TextEditingController> prezziControllers = [];
  Timer? _debounce;
  String ipaddress = 'http://gestione.femasistemi.it:8090';
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    quantitaProdotti = widget.prodotti.map((prodotto) => prodotto.quantita ?? 0.0).toList();
    quantityControllers = List.generate(widget.prodotti.length, (index) => TextEditingController());

    for (int i = 0; i < widget.prodotti.length; i++) {
      quantityControllers[i].text = widget.prodotti[i].quantita.toString();
    }

    nuoviPrezzi = List.filled(widget.prodotti.length, 1);
    prezziControllers = List.generate(widget.prodotti.length, (index) => TextEditingController());

    for (int i = 0; i < widget.prodotti.length; i++) {
      prezziControllers[i].text = widget.prodotti[i].prezzo!.toStringAsFixed(2);
    }
    _debounce = Timer(Duration(milliseconds: 500), () {});
  }

  @override
  void dispose() {
    // Dispose of the controllers to avoid memory leaks
    for (var controller in quantityControllers) {
      controller.dispose();
    }
    for (var controller in prezziControllers) {
      controller.dispose();
    }
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Modifica prodotti preventivo ${widget.prodotti.first.preventivo!.id}',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: widget.prodotti.length,
                itemBuilder: (context, index) {
                  final prodotto = widget.prodotti[index];
                  final quantita = widget.prodotti[index].quantita;
                  final prezzo = widget.prodotti[index].prezzo;
                  final prezzoFornitore = widget.prodotti[index].prodotto!.prezzo_fornitore;
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Table(
                      border: TableBorder.all(),
                      columnWidths: {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1.6),
                        2: FlexColumnWidth(1.8),
                        3: FlexColumnWidth(0.8
                        )
                      },
                      children: [
                        TableRow(children: [
                          // Colonna 1: Descrizione prodotto e prezzo fornitore
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prodotto.prodotto!.descrizione ?? '',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                SizedBox(height: 3),
                                Column(
                                  children: [
                                    Text(
                                      'Prezzo fornitore: ${prezzoFornitore.toString()}€',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Colonna 2: Prezzo di vendita con TextFormField
                          LayoutBuilder(
                              builder: (context, constraints){
                                if(constraints.maxWidth > 800){
                                  return Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Prezzo di vendita:',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 8),
                                        SizedBox(
                                          width: 150,
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            controller: prezziControllers[index],
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Inserisci un prezzo';
                                              }
                                              double nuovoPrezzo =
                                                  double.tryParse(value) ?? 0;
                                              double? prezzoFornitore =
                                                  prodotto.prodotto!.prezzo_fornitore;
                                              if (prezzoFornitore != null &&
                                                  nuovoPrezzo < prezzoFornitore) {
                                                return 'Il prezzo non può essere inferiore al prezzo fornitore';
                                              }
                                              return null;
                                            },
                                            onChanged: (value) {
                                              _onPriceChanged(value, index);
                                            },
                                          ),
                                        )

                                      ],
                                    ),
                                  );
                                } else{
                                  return Padding(
                                    padding: const EdgeInsets.all(8),
                                    child:
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Prezzo di vendita:',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 8),
                                        SizedBox(
                                          width: 150,
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            controller: prezziControllers[index],
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Inserisci un prezzo';
                                              }
                                              double nuovoPrezzo =
                                                  double.tryParse(value) ?? 0;
                                              double? prezzoFornitore =
                                                  prodotto.prodotto!.prezzo_fornitore;
                                              if (prezzoFornitore != null &&
                                                  nuovoPrezzo < prezzoFornitore) {
                                                return 'Il prezzo non può essere inferiore al prezzo fornitore';
                                              }
                                              return null;
                                            },
                                            onChanged: (value) {
                                              _onPriceChanged(value, index);
                                            },
                                          ),
                                        )

                                      ],
                                    ),
                                  );
                                }
                              }
                          ),

                          // Colonna 3: Quantità con TextFormField

                          LayoutBuilder(
                              builder: (context, constraints){
                                if(constraints.maxWidth > 800){
                                  return Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Quantità:',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 8),
                                        SizedBox(
                                          width: 150,
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            controller: quantityControllers[index],
                                            onChanged: (value) {
                                              _onQuantityChanged(value, index);
                                            },
                                          ),
                                        )

                                      ],
                                    ),
                                  );
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Quantità:',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 8),
                                        SizedBox(
                                          width: 150,
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            controller: quantityControllers[index],
                                            onChanged: (value) {
                                              _onQuantityChanged(value, index);
                                            },
                                          ),
                                        )

                                      ],
                                    ),
                                  );
                                }
                              }
                          ),
                          Padding(
                            padding: const EdgeInsets.all(17),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment : CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    child: Icon(
                                      Icons.delete_forever,
                                    ),
                                    onTap: () {
                                      _showDeleteConfirmationDialog(prodotto, index);
                                    },
                                  ),
                                  Text('ELIMINA')
                                ],
                              ),
                            ),
                          )
                        ]),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Totale preventivo: ${_calculateTotalAmount().toStringAsFixed(2)} €',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Totale provvigioni: ${_calculateAgentCommission().toStringAsFixed(2)} €',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  bool isValid = true;
                  String errorMessage = '';
                  int invalidProductIndex = -1;

                  for (int i = 0; i < widget.prodotti.length; i++) {
                    final prodotto = widget.prodotti[i].prodotto;
                    final prezzoInserito =
                        double.tryParse(prezziControllers[i].text) ?? 0;

                    if (prezzoInserito < (prodotto?.prezzo_fornitore ?? 0)) {
                      isValid = false;
                      errorMessage =
                      'Il prezzo inserito per il prodotto "${prodotto?.descrizione}" è inferiore al prezzo fornitore.';
                      invalidProductIndex = i;
                      break;
                    }
                  }

                  if (isValid) {
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
                                  itemCount: widget.prodotti.length,
                                  itemBuilder: (context, index) {
                                    final prodotto =
                                    widget.prodotti[index].prodotto;
                                    return ListTile(
                                      title: Text(prodotto!.descrizione ?? ''),
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
                                        fontSize: 18),
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
                                              ReportPreventiviPage(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white, backgroundColor: Colors.red,
                                      padding: EdgeInsets.all(12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10.0),
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
                  } else {

                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  padding:
                  EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0),
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
      ),
    );
  }

  double _calculateTotalAmount() {
    double totalAmount = 0;
    // Calcola il totale per i prodotti selezionati
    for (int i = 0; i < widget.prodotti.length; i++) {
      double productPrice = double.tryParse(prezziControllers[i].text) ?? 0;
      double quantity = quantitaProdotti[i];
      totalAmount += productPrice * quantity;
    }

    // Calcola il totale per i prodotti ottenuti dalla chiamata API
    // for (int i = 0; i < widget.prodotti.length; i++) {
    //   double productPrice = widget.prodotti[i].prodotto?.prezzo_fornitore ?? 0;
    //   double quantity = 1; // Quantità fissa per i prodotti ottenuti dalla chiamata API
    //   totalAmount += productPrice * quantity;
    // }
    return totalAmount;
  }

  double _calculateAgentCommission() {
    double totalCommission = 0;
    double agentCommissionPercentage = widget.preventivo.agente!.categoria_provvigione ?? 0;
    // Calcola le provvigioni per i prodotti selezionati
    for (int i = 0; i < widget.prodotti.length; i++) {
      double productPrice = double.tryParse(prezziControllers[i].text) ?? 0;
      double? prezzoFornitore = widget.prodotti[i].prodotto?.prezzo_fornitore != null ? widget.prodotti[i].prodotto?.prezzo_fornitore : 0;
      double quantity = quantitaProdotti[i];
      double priceDifference = (productPrice * quantity) - (prezzoFornitore! * quantity);
      double productCommission = priceDifference * (agentCommissionPercentage / 100);
      totalCommission += productCommission;
    }
    // Calcola le provvigioni per i prodotti ottenuti dalla chiamata API
    // for (int i = 0; i < widget.prodotti.length; i++) {
    //   double productPrice = double.tryParse(prezziControllers[i].text) ?? 0;
    //   double quantity = double.tryParse(quantityControllers[i].text) ?? 1; // Quantità fissa per i prodotti ottenuti dalla chiamata API
    //   double priceDifference = productPrice * quantity;
    //   double productCommission = priceDifference * (agentCommissionPercentage / 100);
    //   totalCommission += productCommission;
    // }
    return totalCommission;
  }


  void _onPriceChanged(String value, int index) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () {
      setState(() {
        nuoviPrezzi[index] = double.tryParse(value) ?? 0;
      });
    });
  }

  void _onQuantityChanged(String value, int index) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () {
      setState(() {
        quantitaProdotti[index] = double.tryParse(value) ?? 0;
      });
    });
  }

  Future<void> eliminaProdotto(int relazioneId, int index) async{
    try{
      final response = await http.delete(
        Uri.parse('$ipaddressProva/api/relazionePreventivoProdotto/${relazioneId}'),
        headers: {'Content-Type': 'application/json'},
      );
      if(response.statusCode == 200){
        setState(() {
          widget.prodotti.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Prodotto eliminato con successo.')),
        );
        aggiornaPreventivo();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante l\'eliminazione del prodotto.')),
        );
      }
    } catch(e){
      print('Qualcosa non va');
    }
  }

  Future<void> aggiornaPreventivo() async {
    double importoPreventivo = _calculateTotalAmount();
    double totaleProvvigioni = _calculateAgentCommission();

    late http.Response response;
    try {
      // Chiamata POST per aggiornare il preventivo
      response = await http.post(
        Uri.parse('$ipaddressProva/api/preventivo'),
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
          'data_consegna': DateTime.now().toIso8601String(),
          'data_accettazione':
          widget.preventivo.data_accettazione?.toIso8601String(),
          'utente': widget.preventivo.utente?.toJson(),
          'agente': widget.preventivo.agente?.toJson(),
        }),
      );

      if (response.statusCode == 201) {
        print("Preventivo aggiornato con successo");

        // Chiamata POST per ogni prodotto della lista dei prodotti selezionati
        for (int i = 0; i < widget.prodotti.length; i++) {
          final id = widget.prodotti[i].id;
          final prodotto = widget.prodotti[i].prodotto;
          final quantita = double.tryParse(quantityControllers[i].text);
          final prezzo = double.tryParse(prezziControllers[i].text);

          response = await http.post(
            Uri.parse('$ipaddressProva/api/relazionePreventivoProdotto'),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json"
            },
            body: json.encode({
              'id' : id,
              'preventivo': widget.preventivo.toJson(),
              'prodotto': prodotto!.toJson(),
              'quantita': quantita,
              'prezzo' : prezzo,
            }),
          );

          if (response.statusCode == 201) {
            print(
                "Relazione preventivo-prodotto aggiornata con successo per il prodotto ${prodotto!.id}");
          } else {
            print(
                "Errore durante l'aggiornamento della relazione preventivo-prodotto per il prodotto ${prodotto!.id}");
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

  void _showDeleteConfirmationDialog(RelazionePreventivoProdottiModel prodotto, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Conferma eliminazione'),
          content: Text('Sei sicuro di voler eliminare questo prodotto?'),
          actions: [
            TextButton(
              child: Text('Annulla'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Elimina'),
              onPressed: () {
                eliminaProdotto(prodotto.id!, index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}