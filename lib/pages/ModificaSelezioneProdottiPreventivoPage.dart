import 'dart:async';
import 'package:fema_crm/pages/ReportPreventiviPage.dart';
import 'package:flutter/material.dart';
import 'package:fema_crm/model/ProdottoModel.dart';
import '../model/PreventivoModel.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/RelazionePreventivoProdottiModel.dart';

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
  late List<double> quantitaProdotti;
  late List<TextEditingController> quantityControllers;

  late List<double> nuoviPrezzi;
  late List<TextEditingController> prezziControllers;

  late List<double> quantitaOldProdotti;
  late List<TextEditingController> oldQuantitiesController;

  late List<double> oldPrices;
  late List<TextEditingController> oldPricesController;

  late Timer _debounce;
  Map<int, double> lastPrices = {};
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';
  List<RelazionePreventivoProdottiModel> allProdotti = [];
  List<PreventivoModel> allPreventivi = [];
  List<RelazionePreventivoProdottiModel> pastProdotti = [];
  final _formKey = GlobalKey<FormState>();

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

    getProdotti(); // Inizializzazione del timer debounce
    getPreventiviByCliente().then((value) => getAllProdottiFromPastPreventivi(allPreventivi, int.parse(widget.preventivo.id!))).then((_) {
      oldPricesController = List.generate(
          pastProdotti.length, (index) => TextEditingController()
      );
      oldQuantitiesController = List.generate(
          pastProdotti.length, (index) => TextEditingController()
      );
      for(int i = 0; i < pastProdotti.length; i++){
        oldPricesController[i].text = pastProdotti[i].prezzo.toString();
        oldQuantitiesController[i].text = pastProdotti[i].quantita.toString();
      }
    });



    nuoviPrezzi = List.filled(widget.prodottiSelezionati.length, 1);
    prezziControllers =List.generate(
        widget.prodottiSelezionati.length, (index) => TextEditingController()
    );
    for(int i = 0; i < widget.prodottiSelezionati.length; i++){
      double listinoPercentage = double.tryParse(widget.preventivo.listino!.substring(0, 2)) ?? 0;
      double initialPrice = widget.prodottiSelezionati[i].prezzo_fornitore != null ? widget.prodottiSelezionati[i].prezzo_fornitore! + (widget.prodottiSelezionati[i].prezzo_fornitore! * (listinoPercentage / 100)) : 0;
      prezziControllers[i].text = initialPrice.toStringAsFixed(2);



    }
    _debounce = Timer(Duration(milliseconds: 500), () {});
  }

  double? getLastPrice(int productId) {
    return lastPrices[productId];
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

  void _onPriceChanged(String value, int index){
    if (_debounce.isActive) _debounce.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () {
      setState(() {
        nuoviPrezzi[index] = double.tryParse(value) ?? 0;
      });
    });
  }

  void _onOldPriceChanged(String value, int index){
    if(_debounce.isActive) _debounce.cancel();
    _debounce = Timer(Duration(milliseconds: 500), (){
      setState(() {
        oldPrices[index] = double.tryParse(value) ?? 0;
      });
    });
  }



  double _calculateTotalAmount() {
    double totalAmount = 0;
    // Calcola il totale per i prodotti selezionati
    for (int i = 0; i < widget.prodottiSelezionati.length; i++) {
      double productPrice = double.tryParse(prezziControllers[i].text) ?? 0;
      double quantity = quantitaProdotti[i];
      totalAmount += productPrice * quantity;
    }

    // Calcola il totale per i prodotti ottenuti dalla chiamata API
    for (int i = 0; i < allProdotti.length; i++) {
      double productPrice = allProdotti[i].prezzo ?? 0;
      double quantity = allProdotti[i].quantita!; // Quantità fissa per i prodotti ottenuti dalla chiamata API
      totalAmount += productPrice * quantity;
    }
    return totalAmount;
  }

  double _calculateAgentCommission() {
    double totalCommission = 0;
    double agentCommissionPercentage = widget.preventivo.agente!.categoria_provvigione ?? 0;
    // Calcola le provvigioni per i prodotti selezionati
    for (int i = 0; i < widget.prodottiSelezionati.length; i++) {
      double? prezzoFornitore = widget.prodottiSelezionati[i].prezzo_fornitore != null ? widget.prodottiSelezionati[i].prezzo_fornitore : 0;
      double productPrice = double.tryParse(prezziControllers[i].text) ?? 0;
      double quantity = quantitaProdotti[i];
      double priceDifference = (productPrice * quantity) - (prezzoFornitore! * quantity) ;
      double productCommission = priceDifference * (agentCommissionPercentage / 100);
      totalCommission += productCommission;
    }
    // Calcola le provvigioni per i prodotti ottenuti dalla chiamata API
    for (int i = 0; i < allProdotti.length; i++) {
      double productPrice = allProdotti[i].prezzo ?? 0;
      double quantity = allProdotti[i].quantita!; // Quantità fissa per i prodotti ottenuti dalla chiamata API
      double priceDifference = (productPrice * quantity) - (allProdotti[i].prodotto!.prezzo_fornitore!);
      double productCommission = priceDifference * (agentCommissionPercentage / 100);
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
      body: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.prodottiSelezionati.length + (allProdotti.isNotEmpty ? allProdotti.length : 0),
                  itemBuilder: (context, index) {
                    if (index < widget.prodottiSelezionati.length) {
                      final prodotto = widget.prodottiSelezionati[index];
                      final lastPrice = getLastPrice(int.parse(prodotto.id!));
                      final prezzo = prodotto.prezzo_fornitore != null ? prodotto.prezzo_fornitore.toString() : '';
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Table(
                          border: TableBorder.all(),
                          columnWidths: {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(2),
                          },
                          children: [
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children : [
                                        Text(
                                          prodotto.descrizione ?? '',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize:16 ),
                                        ),
                                        SizedBox(height: 3),
                                            Text('Prezzo fornitore:  ${prezzo}€',
                                              style: TextStyle(fontSize: 18),
                                            ),

                                      ]
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  //mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 12,),
                                    Text(
                                      'Ultimo prezzo: ${lastPrice ?? 'N/A'}€',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                LayoutBuilder(
                                    builder: (context, constraints){
                                      if(constraints.maxWidth > 800){
                                        return Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [

                                            Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(
                                                'Prezzo di vendita:',
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            SizedBox(
                                              width: 158,
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
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
                                                        prodotto.prezzo_fornitore;
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
                                              ),
                                            )

                                          ],
                                        );
                                      } else {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 5,),
                                            Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(
                                                'Prezzo di vendita:',
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            SizedBox(
                                              width: 158,
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
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
                                                        prodotto.prezzo_fornitore;
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
                                              ),
                                            )

                                          ],
                                        );
                                      }
                                    }
                                ),
                                LayoutBuilder(
                                    builder: (context, constraints){
                                      if(constraints.maxWidth > 800){
                                        return Row(
                                          crossAxisAlignment : CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(
                                                'Quantità',
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(width: 8,),
                                            SizedBox(
                                              width: 158,
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: TextFormField(
                                                  keyboardType: TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  controller: quantityControllers[index],
                                                  onChanged: (value) {
                                                    _onQuantityChanged(value, index);
                                                  },
                                                ),
                                              ),
                                            )
                                          ],
                                        );
                                      } else {
                                        return Column(
                                          crossAxisAlignment : CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 5),
                                            Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(
                                                'Quantità:',
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(width: 8,),
                                            SizedBox(
                                              width: 158,
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: TextFormField(
                                                  keyboardType: TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  controller: quantityControllers[index],
                                                  onChanged: (value) {
                                                    _onQuantityChanged(value, index);
                                                  },
                                                ),
                                              ),
                                            )
                                          ],
                                        );
                                      }
                                    }
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    } else {
                      // if(allProdotti.isNotEmpty){
                      //   final prodotto = allProdotti[index - widget.prodottiSelezionati.length];
                      //   return Padding(
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: Column(
                      //       children: [
                      //         Table(
                      //           border: TableBorder.all(),
                      //           columnWidths: {
                      //             0: FlexColumnWidth(2),
                      //             1: FlexColumnWidth(2),
                      //             2: FlexColumnWidth(2),
                      //             3: FlexColumnWidth(2),
                      //           },
                      //           children: [
                      //             TableRow(
                      //               children: [
                      //                 Padding(
                      //                   padding: const EdgeInsets.all(8.0),
                      //                   child: Text(
                      //                     prodotto.prodotto?.descrizione ?? '',
                      //                     style: TextStyle(fontWeight: FontWeight.bold),
                      //                   ),
                      //                 ),
                      //                 Padding(
                      //                   padding: const EdgeInsets.all(8.0),
                      //                   child: Text(
                      //                     'Prezzo finale: ${prodotto.prezzo ?? 'N/A'} €',
                      //                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      //                   ),
                      //                 ),
                      //                 Padding(
                      //                   padding: const EdgeInsets.all(8),
                      //                   child: TextFormField(
                      //                     keyboardType: TextInputType.number,
                      //                     textAlign: TextAlign.center,
                      //                     controller: oldPricesController[index - widget.prodottiSelezionati.length],
                      //                     validator: (value) {
                      //                       if (value!.isEmpty) {
                      //                         return 'Inserisci un prezzo';
                      //                       }
                      //                       return null;
                      //                     },
                      //                     onChanged: (value) {
                      //                       _onOldPriceChanged(value, index - widget.prodottiSelezionati.length);
                      //                     },
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ],
                      //         ),
                      //       ],
                      //     ),
                      //   );
                      // } else {
                      //   return Container();
                      // }
                    }
                  },
                ),
              ),
              //SizedBox(height: 200,),
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

                    for (int i = 0; i < widget.prodottiSelezionati.length; i++) {
                      final prodotto = widget.prodottiSelezionati[i];
                      final prezzoInserito =
                          double.tryParse(prezziControllers[i].text) ?? 0;

                      if (prezzoInserito < (prodotto.prezzo_fornitore ?? 0)) {
                        isValid = false;
                        errorMessage =
                        'Il prezzo inserito per il prodotto "${prodotto.descrizione}" è inferiore al prezzo fornitore.';
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
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Errore di validazione'),
                            content: Text(errorMessage),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  if (invalidProductIndex != -1) {
                                    final prodotto = widget
                                        .prodottiSelezionati[invalidProductIndex];
                                    prezziControllers[invalidProductIndex].text =
                                        prodotto.prezzo_fornitore.toString();
                                  }

                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
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

  Future<void> getAllProdottiFromPastPreventivi(List<PreventivoModel> preventivi, int excludeId) async {
    try {
      for (var preventivo in preventivi) {
        if (preventivo.id != excludeId) {
          try {
            var apiUrl = Uri.parse('$ipaddress2/api/relazionePreventivoProdotto/preventivo/${preventivo.id}');
            var response = await http.get(apiUrl);
            if (response.statusCode == 200) {
              var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
              List<RelazionePreventivoProdottiModel> prodotti = [];
              for (var item in jsonData) {
                var relazione = RelazionePreventivoProdottiModel.fromJson(item);
                prodotti.add(relazione);
                // Memorizza l'ultimo prezzo applicato per il prodotto
                if (!lastPrices.containsKey(relazione.prodotto!.id) ||
                    relazione.preventivo!.data_creazione!.isAfter(allProdotti.last.preventivo!.data_creazione!)) {
                  lastPrices[int.parse(relazione.prodotto!.id!)] = relazione.prezzo!;
                }
              }
              setState(() {
                pastProdotti = prodotti;
              });
            }
          } catch (e) {
            print('1 error: $e');
          }
        }
      }
    } catch (e) {
      print('2 error: $e');
    }
  }

  Future<http.Response?> getPreventiviByCliente() async{
    try{
      var apiUrl = Uri.parse('$ipaddress2/api/preventivo/cliente/${widget.preventivo.cliente?.id}');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<PreventivoModel> preventivi = [];
        for(var item in jsonData){
          preventivi.add(PreventivoModel.fromJson(item));
        }
        setState(() {
          allPreventivi = preventivi;
        });
        getAllProdottiFromPastPreventivi(preventivi, int.parse(widget.preventivo.id!));
        return response;
      }
    } catch(e){
      print('Errore nel recupero dei preventivi: $e');
      return null;
    }
    return null;
  }

  Future<void> getProdotti() async {
    try {
      var apiUrl = Uri.parse(
          '$ipaddress2/api/relazionePreventivoProdotto/preventivo/${widget.preventivo.id}');
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
        for (int i = 0; i < widget.prodottiSelezionati.length; i++) {
          final prodotto = widget.prodottiSelezionati[i];
          final quantita = quantitaProdotti[i];
          final prezzo = double.tryParse(prezziControllers[i].text);

          response = await http.post(
            Uri.parse('$ipaddress2/api/relazionePreventivoProdotto'),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json"
            },
            body: json.encode({
              'preventivo': widget.preventivo.toJson(),
              'prodotto': prodotto.toJson(),
              'quantita': quantita,
              'prezzo' : prezzo,
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
