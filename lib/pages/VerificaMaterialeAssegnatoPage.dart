import 'dart:async';
import 'dart:convert';
import 'package:fema_crm/model/InterventoModel.dart';
import 'package:fema_crm/model/ProdottoModel.dart';
import 'package:fema_crm/model/RelazioneDdtProdottiModel.dart';
import 'package:fema_crm/model/RelazioneUtentiProdottiModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/DDTModel.dart';

class VerificaMaterialeAssegnatoPage extends StatefulWidget {
  final UtenteModel utente;
  final InterventoModel intervento;
  final List<RelazioneDdtProdottoModel> relazioni;
  final DDTModel ddt;

  VerificaMaterialeAssegnatoPage(
      {Key? key,
        required this.utente,
        required this.intervento,
        required this.ddt,
        required this.relazioni})
      : super(key: key);

  @override
  _VerificaMaterialeAssegnatoPageState createState() =>
      _VerificaMaterialeAssegnatoPageState();
}

class _VerificaMaterialeAssegnatoPageState
    extends State<VerificaMaterialeAssegnatoPage> {
  bool isLoading = true;
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  List<RelazioneUtentiProdottiModel> allProdottiByStoricoList1 = [];
  List<RelazioneUtentiProdottiModel> allProdottiByStoricoNew = [];
  List<RelazioneDdtProdottoModel> prodottiDaScaricare = [];
  List<ProdottoModel> prodottiGeneraliDaScaricare = [];
  List<ProdottoModel> allProdotti = [];
  bool pressedButton = false;
  late List<TextEditingController> quantityControllersDdt;
  late List<TextEditingController> quantityControllersProdotti;
  late List<double> quantitaProdottiDdt;
  late List<double> quantitaProdotti;
  late Timer _debounce;
  late TextEditingController searchController;
  List<ProdottoModel> filteredProdottiList = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    getAllProdotti();
    getProdottiStoricoUtente().then((value) => print("${allProdottiByStoricoNew.toString()}"));
    _debounce = Timer(Duration(milliseconds: 500), () {});
  }

  void checkAndRemoveFromStorico(ProdottoModel prodotto) {
    RelazioneUtentiProdottiModel? relazione;
    for (var rel in allProdottiByStoricoNew) {
      if (rel.prodotto?.id == prodotto.id) {
        relazione = rel;
        break;
      }
    }
    if (relazione != null) {
      setState(() {
        allProdottiByStoricoNew.remove(relazione);
      });
      // Make a DELETE request to the server to remove the product from the user's history
      deleteRelazioneUtentiProdotti(relazione.id);
    }
  }

  List<RelazioneDdtProdottoModel> getUncheckedRelazioni() {
    // Convert the lists to sets
    final allRelazioniSet = widget.relazioni.toSet();
    final checkedRelazioniSet = prodottiDaScaricare.toSet();
    // Find the difference
    final uncheckedRelazioniSet = allRelazioniSet.difference(checkedRelazioniSet);
    // Convert the set back to a list and return
    return uncheckedRelazioniSet.toList();
  }

  List<ProdottoModel?> getProdottiFromUncheckedRelazioni() {
    List<RelazioneDdtProdottoModel> uncheckedRelazioni = getUncheckedRelazioni();

    // Estrai la proprietà 'prodotto' da ciascuna relazione non checkata
    List<ProdottoModel?> prodottiNonCheckati = uncheckedRelazioni
        .map((relazione) => relazione.prodotto)
        .toList();
    return prodottiNonCheckati;
  }

  Future<void> deleteAndUpdateOldStorico() async {
    if (allProdottiByStoricoList1.isNotEmpty) {
      for (var relazione in allProdottiByStoricoList1) {
        try {
          final response = await http.delete(
            Uri.parse('$ipaddress/api/relazioneUtentiProdotti/${relazione.id}'),
            headers: {'Content-Type': 'application/json'},
          );
          if (response.statusCode != 200) {
            throw Exception('Failed to delete data: ${response.statusCode}');
          } else {
            print('Deleted relazione: ${relazione.id}');
          }
        } catch (e) {
          print('Errore durante l\'eliminazione: $e');
        }
      }
    }
    try {
      for (var relazione in allProdottiByStoricoNew) {
        final response = await http.post(
          Uri.parse('$ipaddress/api/relazioneUtentiProdotti'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'prodotto': relazione.prodotto?.toMap(),
            'quantita': relazione.quantita,
            'materiale': relazione.materiale,
            'utente': widget.utente.toMap(),
            'ddt': null,
            'intervento': null,
            'assegnato': relazione.assegnato,
          }),
        );
        if (response.statusCode == 200) {
          print('Added relazione: ${relazione.prodotto?.descrizione}');
        } else {
          throw Exception('Failed to add data: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Errore nell\'aggiornamento dello storico: $e');
    }
  }

  Future<void> inviaProdottiStoricoUtente() async {
    List<RelazioneDdtProdottoModel> prodottiNonUsati = getUncheckedRelazioni();
    for (var relazione in prodottiNonUsati) {
      var prodotto = relazione.prodotto!;
      try {
        final response = await http.post(
          Uri.parse('$ipaddress/api/relazioneUtentiProdotti'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'prodotto': prodotto.toMap(),
            'utente': widget.utente.toMap(),
            'ddt': widget.ddt.toMap(),
            'quantita': relazione.quantita,
            'intervento': widget.intervento.toMap(),
            'assegnato': true,
          }),
        );
        if (response.statusCode != 200) {
          throw Exception('Failed to add data: ${response.statusCode}');
        } else {
          print('Added relazione: ${prodotto.descrizione}');
        }
      } catch (e) {
        print('Errore durante l\'aggiornamento dello storico: $e');
      }
    }
  }

  void initializeQuantitaAndControllers(){
    quantitaProdotti = List.generate(
      prodottiGeneraliDaScaricare.length,
          (index) => (prodottiGeneraliDaScaricare[index].quantita?.toDouble() ?? 1.0)
    );
    quantityControllersProdotti = List.generate(
      prodottiGeneraliDaScaricare.length,
          (index) => TextEditingController(
            text: quantitaProdotti[index].toString()
          )
    );
  }

  void initializeQuantitaAndControllersDdt() {
    quantitaProdottiDdt = List.generate(
        prodottiDaScaricare.length,
            (index) => (prodottiDaScaricare[index].quantita?.toDouble() ?? 1)
    );
    quantityControllersDdt = List.generate(
        prodottiDaScaricare.length,
            (index) => TextEditingController(
            text: quantitaProdottiDdt[index].toString()
        )
    );
  }

  void filterProdotti(String query) {
    final filtered = allProdotti.where((prodotto) {
      final descrizione = prodotto.descrizione?.toLowerCase() ?? '';
      final codProdForn = prodotto.cod_prod_forn?.toLowerCase() ?? '';
      final codiceDanea = prodotto.codice_danea?.toLowerCase() ?? '';
      final lottoSeriale = prodotto.lotto_seriale?.toLowerCase() ?? '';
      final categoria = prodotto.categoria?.toUpperCase() ?? '';

      return descrizione.contains(query.toLowerCase()) ||
          codProdForn.contains(query.toLowerCase()) ||
          codiceDanea.contains(query.toLowerCase()) ||
          lottoSeriale.contains(query.toLowerCase()) ||
          categoria.contains(query.toUpperCase());
    }).toList();

    setState(() {
      filteredProdottiList = filtered;
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
      filteredProdottiList.clear();
    });
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Cerca prodotti...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.black),
      ),
      style: TextStyle(color: Colors.black),
      onChanged: filterProdotti,
    );
  }

  List<Widget> _buildActions() {
    if (isSearching) {
      return [
        IconButton(
          icon: Icon(Icons.cancel, color: Colors.white),
          onPressed: stopSearch,
        ),
      ];
    } else {
      return [
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: startSearch,
        ),
      ];
    }
  }

  Future<void> getAllProdotti()async{
    try{
      var apiUrl = Uri.parse(
          '$ipaddress/api/prodotto');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<ProdottoModel> prodotti = [];
        for(var item in jsonData){
          prodotti.add(ProdottoModel.fromJson(item));
        }
        setState(() {
          allProdotti = prodotti;
          filteredProdottiList = prodotti;  // Initialize filtered list
        });
      } else {
        throw Exception(
            'Failed to load data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Errore! $e');
    }
  }

  Future<void> getProdottiStoricoUtente() async {
    try {
      var apiUrl = Uri.parse(
          '$ipaddress/api/relazioneUtentiProdotti/utente/${widget.utente.id}');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<RelazioneUtentiProdottiModel> relazioni = [];
        for (var item in jsonData) {
          RelazioneUtentiProdottiModel relazione =
          RelazioneUtentiProdottiModel.fromJson(item);
          if (relazione.prodotto != null && relazione.materiale == null) {
            relazioni.add(relazione);
          }
        }
        setState(() {
          isLoading = false;
          allProdottiByStoricoNew = relazioni;
          allProdottiByStoricoList1 = relazioni;
          initializeQuantitaAndControllersDdt();
          initializeQuantitaAndControllers();
        });
      } else {
        throw Exception(
            'Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore! $e');
    }
  }

  @override
  void dispose() {
    _debounce.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _onQuantityChanged(String value, int index) {
    if (_debounce.isActive) _debounce.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () {
      setState(() {
        quantitaProdottiDdt[index] = double.tryParse(value) ?? 0;
      });
    });
  }

  Future<void> saveProdottiGeneralIntervento() async{
    if(prodottiGeneraliDaScaricare.isNotEmpty){
      for(int i = 0; i < prodottiGeneraliDaScaricare.length; i++){
        var prodotto = prodottiGeneraliDaScaricare[i];
        try{
          final response = await http.post(
            Uri.parse('$ipaddress/api/relazioneProdottoIntervento'),
              headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'prodotto' : prodotto.toMap(),
              'intervento' : widget.intervento.toMap(),
              'quantita' : double.parse(quantityControllersProdotti[i].text),
            }),
          );
          if(response.statusCode != 200) {
            throw Exception('Failed to save data: ${response.statusCode}');
          }
        } catch(e){
          print("Error saving product data: $e");
        }
      }
    }
    saveProdottiIntervento();
  }

  Future<void> saveProdottiIntervento() async {
    for (int i = 0; i < prodottiDaScaricare.length; i++) {
      var relazione = prodottiDaScaricare[i];
      try {
        final response = await http.post(
          Uri.parse('$ipaddress/api/relazioneProdottoIntervento'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'prodotto': relazione.prodotto?.toMap(),
            'ddt': relazione.ddt?.toMap(),
            'intervento': widget.intervento.toMap(),
            'quantita': double.parse(quantityControllersDdt[i].text),  // Get the quantity from the corresponding controller
          }),
        );
        if (response.statusCode != 200) {
          throw Exception('Failed to save data: ${response.statusCode}');
        }
      } catch (e) {
        print("Error saving product data: $e");
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Prodotti salvati con successo!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showConfirmationDialog() {
    initializeQuantitaAndControllersDdt();
    initializeQuantitaAndControllers();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confermi di aver usato i seguenti prodotti?'),
          content: Column(
            children: [
              Container(
                height: 300,
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: prodottiDaScaricare.length,
                  itemBuilder: (context, index) {
                    final relazione = prodottiDaScaricare[index];
                    return ListTile(
                      title: Text(
                        relazione.prodotto?.descrizione != null && relazione.prodotto!.descrizione!.length > 40
                            ? relazione.prodotto!.descrizione!.substring(0, 40)
                            : relazione.prodotto?.descrizione ?? '',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Quantità:'),
                          SizedBox(width: 5),
                          SizedBox(
                            width: 50,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              controller: quantityControllersDdt[index],
                              onChanged: (value) {
                                _onQuantityChanged(value, index);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                height: 300,
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: prodottiGeneraliDaScaricare.length,
                  itemBuilder: (context, index) {
                    final prodotto = prodottiGeneraliDaScaricare[index];
                    return ListTile(
                      title: Text(
                        prodotto.descrizione != null && prodotto.descrizione!.length > 40
                            ? prodotto.descrizione!.substring(0, 40)
                            : prodotto.descrizione ?? '',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Quantità:'),
                          SizedBox(width: 5),
                          SizedBox(
                            width: 50,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              controller: quantityControllersProdotti[index],
                              onChanged: (value) {
                                _onQuantityChanged(value, index);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                deleteAndUpdateOldStorico();
                saveProdottiGeneralIntervento();
                inviaProdottiStoricoUtente();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Conferma', style: TextStyle(color: Colors.white)),
              style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.red)),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Prodotti utilizzati',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.red,
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                if (prodottiDaScaricare.isNotEmpty) {
                  _showConfirmationDialog();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Nessun prodotto aggiunto!'),
                        duration : Duration(seconds: 2),
                    )
                  );
                }
              },
              backgroundColor: Colors.red,
              child: Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: isLoading
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : Column(
                children: [
                  SizedBox(height: 9),
                  Text(
                      'Spunta il materiale che hai utilizzato durante l\'intervento',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                  SizedBox(height: 20),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade700),
                    ),
                    child: FutureBuilder<
                        List<RelazioneDdtProdottoModel>>(
                        future: Future.value(widget.relazioni),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text(
                                    'Errore: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            List<RelazioneDdtProdottoModel> relazioni =
                            snapshot.data!
                                .cast<RelazioneDdtProdottoModel>();
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: relazioni.length,
                              itemBuilder: (context, index) {
                                RelazioneDdtProdottoModel relazione =
                                relazioni[index];
                                return CheckboxListTile(
                                  title: Text(
                                      '${index + 1}) ${relazione.prodotto?.descrizione}'),
                                  value: prodottiDaScaricare
                                      .contains(relazione),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value!) {
                                        prodottiDaScaricare
                                            .add(relazione);
                                      } else {
                                        prodottiDaScaricare
                                            .remove(relazione);
                                      }
                                    });
                                  },
                                );
                              },
                            );
                          } else {
                            return Center(
                                child: Text(
                                    'Nessun prodotto disponibile'));
                          }
                        }),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          pressedButton = !pressedButton;
                        });
                      },
                      child: Text(
                        pressedButton
                            ? 'Nascondi altri prodotti'
                            : 'Cerca altri prodotti',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Visibility(
                    visible: pressedButton,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey.shade700),
                          ),
                          child: _buildSearchField(),
                        ),
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade700),
                          ),
                          child: FutureBuilder<
                              List<ProdottoModel>>(
                              future: Future.value(allProdotti),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child:
                                      CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text(
                                          'Errore: ${snapshot.error}'));
                                } else if (snapshot.hasData) {
                                  List<ProdottoModel>
                                  prodotti = filteredProdottiList;
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: prodotti.length,
                                    itemBuilder: (context, index) {
                                      ProdottoModel
                                      prodotto = prodotti[index];
                                      return CheckboxListTile(
                                        title: Text(
                                            '${prodotto.descrizione}'),
                                        value:
                                        prodottiGeneraliDaScaricare
                                            .contains(prodotto),
                                        onChanged: (value) {
                                          setState(() {
                                            if (value!) {
                                              prodottiGeneraliDaScaricare.add(prodotto);
                                              print('${allProdottiByStoricoNew.toString()}');
                                              checkAndRemoveFromStorico(prodotto); // Verifica e rimuove dal storico se necessario
                                            } else {
                                              prodottiGeneraliDaScaricare.remove(prodotto);
                                            }
                                          });
                                        },

                                      );
                                    },
                                  );
                                } else {
                                  return Center(
                                      child: Text(
                                          'Nessun prodotto nello storico'));
                                }
                              }),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(height: 15),
                ],
              )
          ),
        ),
    );
  }
}
