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

class VerificaMaterialeNewPage extends StatefulWidget {
  final UtenteModel utente;
  final InterventoModel intervento;

  VerificaMaterialeNewPage({
    Key? key,
    required this.utente,
    required this.intervento,
  }) : super(key: key);

  @override
  _VerificaMaterialeNewPageState createState() => _VerificaMaterialeNewPageState();
}

class _VerificaMaterialeNewPageState extends State<VerificaMaterialeNewPage> {

  bool isLoading = true;
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';
  List<ProdottoModel> allProdotti = [];
  late List<TextEditingController> quantityControllersProdotti;
  List<TextEditingController> serialControllersProdotti = [];
  late List<double> quantitaProdottiDdt;
  late List<double> quantitaProdotti;
  late DDTModel? ddt;
  late Timer _debounce;
  late TextEditingController searchController;
  List<ProdottoModel> filteredProdottiList = [];
  bool isSearching = false;
  List<RelazioneDdtProdottoModel> prodottiDDT = [];
  List<RelazioneUtentiProdottiModel> prodottiStoricoUtente = [];
  List<RelazioneUtentiProdottiModel> oldStoricoUpdated = [];
  List<ProdottoModel> prodottiUsati = [];

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    _debounce = Timer(Duration(milliseconds: 500), () {});
    getAllProdotti();
    getProdottiStoricoUtente();
    getProdottiDdt();
  }

  Future<http.Response?> getDDTByIntervento() async{
    try{
      final response = await http.get(Uri.parse('$ipaddressProva2/api/ddt/intervento/${widget.intervento.id}'));
      if(response.statusCode == 200){
        print('DDT recuperato');
        setState(() {
          ddt = DDTModel.fromJson(jsonDecode(response.body));
        });
        return response;
      } else {
        print('DDT non presente');
        return null;
      }
    } catch(e){
      print('Errore nel recupero del DDT: $e');
      return null;
    }
  }

  Future<void> getProdottiDdt() async {
    final data = await getDDTByIntervento();
    try{
      if(data == null){
        throw Exception('Dati del DDT non disponibili.');
      } else {
        final ddt = DDTModel.fromJson(jsonDecode(data.body));
        try{
          final response = await http.get(Uri.parse('$ipaddressProva2/api/relazioneDDTProdotto/ddt/${ddt.id}'));
          var responseData = json.decode(response.body);
          if(response.statusCode == 200){
            List<RelazioneDdtProdottoModel> prodotti = [];
            for(var item in responseData){
              prodotti.add(RelazioneDdtProdottoModel.fromJson(item));
            }
            setState(() {
              prodottiDDT = prodotti;
            });
          }
        } catch(e){
          print('Errore 1 nel recupero delle relazioni: $e');
        }
      }
    } catch(e) {
      print('Errore 2 nel recupero delle relazioni: $e');
    }
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
              if(prodottiUsati.isEmpty)
                _showDialog();
              _showConfirmationDialog();
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
              SizedBox(height: 20),
              Column(
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
                    height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade700),
                    ),
                    child: FutureBuilder<List<ProdottoModel>>(
                        future: Future.value(allProdotti),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Errore: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            List<ProdottoModel> prodotti = filteredProdottiList;
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: prodotti.length,
                              itemBuilder: (context, index) {
                                ProdottoModel prodotto = prodotti[index];
                                return CheckboxListTile(
                                  title: Text('${prodotto.descrizione}'),
                                  value: prodottiUsati.contains(prodotto),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value!) {
                                        prodottiUsati.add(prodotto);
                                        print("allProdottiByStoricoNew: ${prodottiStoricoUtente.map((e) => e.prodotto?.descrizione).toList()}");
                                        print("allProdottiByStoricoList1: ${oldStoricoUpdated.map((e) => e.prodotto?.descrizione).toList()}");
                                        print('prodottiUsati: ${prodottiUsati.map((e) => e.descrizione).toList()}');
                                      } else {
                                        prodottiUsati.remove(prodotto);
                                      }
                                    });
                                  },
                                );
                              },
                            );
                          } else {
                            return Center(child: Text('Nessun prodotto nello storico'));
                          }
                        }),
                  ),
                ],
              ),
              SizedBox(height: 12),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  void saveProdottiIntervento() async {
    print('Inizio funzione');
    try {
      for (int i = 0; i < prodottiUsati.length; i++) {
        var prodotto = prodottiUsati[i];
        bool presenzaStorico = prodottiStoricoUtente.any((rel) => rel.prodotto?.id == prodotto.id) ? true : false;
        var DDT = prodottiDDT.any((rel) => rel.prodotto?.id == prodotto.id) ? ddt?.toMap() : null;
        final response = await http.post(
          Uri.parse('$ipaddressProva2/api/relazioneProdottoIntervento'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'prodotto': prodotto.toMap(),
            'intervento': widget.intervento.toMap(),
            'ddt': DDT,
            'quantita': double.parse(quantityControllersProdotti[i].text),
            'presenza_storico_utente': presenzaStorico,
            'seriale': prodotto.lotto_seriale != null ? serialControllersProdotti[i].text : null,
          }),
        );
        if (response.statusCode != 200) {
          throw Exception('Failed to save data: ${response.statusCode}');
        }
        if (prodottiDDT.any((relazione) => relazione.prodotto?.id == prodotto.id)) {
          checkAndRemoveFromStorico(prodotto);
          oldStoricoUpdated.removeWhere((relazione) => relazione.prodotto?.id == prodotto.id);
        }
      }
    } catch (e) {
      print("Error saving product data: $e");
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Prodotti salvati con successo!'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void initializeQuantitaAndControllers() {
    quantityControllersProdotti = [];
    serialControllersProdotti = [];
    for (var prodotto in prodottiUsati) {
      quantityControllersProdotti.add(TextEditingController());
      serialControllersProdotti.add(TextEditingController());
    }
  }

  void _showConfirmationDialog() {
    initializeQuantitaAndControllers();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confermi di aver usato i seguenti prodotti?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(prodottiUsati.length, (index) {
                final prodotto = prodottiUsati[index];
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prodotto.descrizione != null && prodotto.descrizione!.length > 40
                                ? prodotto.descrizione!.substring(0, 40)
                                : prodotto.descrizione ?? '',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8.0),
                          Row(
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
                                    // Update the quantity in the list
                                    setState(() {
                                      quantitaProdotti[index] = double.parse(value);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (prodotto.lotto_seriale != null) ...[
                            SizedBox(height: 8.0),
                            Text('Seriale:'),
                            SizedBox(height: 5),
                            SizedBox(
                              width: 150,
                              child: TextField(
                                controller: serialControllersProdotti[index], // Usa il controller corrispondente
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (index < prodottiUsati.length - 1) Divider(), // Aggiungi Divider qui
                  ],
                );
              }),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                for (var prodotto in prodottiUsati) {
                  if (prodottiDDT.any((relazione) => relazione.prodotto?.id == prodotto.id)) {
                    oldStoricoUpdated.removeWhere((relazione) => relazione.prodotto?.id == prodotto.id);
                  }
                }
                saveProdottiIntervento();
                addRemainingProductsToHistory();
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


  void _showDialog(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text(
                'Confermi di non aver utilizzato nessun prodotto durante l\'intervento?'
            ),
            content: TextButton(
              onPressed: () {
                addRemainingProductsToHistory();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Hai confermato di non aver usato alcun prodotto!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text('Si'),
            ),
          );
        });
  }





  void checkAndRemoveFromStorico(ProdottoModel prodotto) {
    RelazioneUtentiProdottiModel? relazione;
    for (var rel in prodottiStoricoUtente) {
      if (rel.prodotto?.id == prodotto.id) {
        relazione = rel;
        break;
      }
    }
    if (relazione != null) {
      setState(() {
        oldStoricoUpdated.remove(relazione);
      });
    }
  }

  Future<void> deleteRelazioneUtentiProdotti(int? relazioneId) async {
    try {
      final response = await http.delete(
        Uri.parse('$ipaddressProva2/api/relazioneUtentiProdotti/$relazioneId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete data: ${response.statusCode}');
      } else {
        print('Deleted relazione: $relazioneId');
      }
    } catch (e) {
      print('Errore durante l\'eliminazione: $e');
    }
  }

  Future<void> getAllProdotti() async {
    try {
      var apiUrl = Uri.parse('$ipaddressProva2/api/prodotto');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<ProdottoModel> prodotti = [];
        for (var item in jsonData) {
          prodotti.add(ProdottoModel.fromJson(item));
        }
        setState(() {
          allProdotti = prodotti;
          filteredProdottiList = prodotti; // Initialize filtered list
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore! $e');
    }
  }

  Future<void> getProdottiStoricoUtente() async {
    try {
      var apiUrl = Uri.parse('$ipaddressProva2/api/relazioneUtentiProdotti/utente/${widget.utente.id}');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<RelazioneUtentiProdottiModel> relazioni = [];
        for (var item in jsonData) {
          RelazioneUtentiProdottiModel relazione = RelazioneUtentiProdottiModel.fromJson(item);
          if (relazione.prodotto != null && relazione.materiale == null) {
            relazioni.add(relazione);
          }
        }
        setState(() {
          isLoading = false;
          prodottiStoricoUtente = relazioni;
          oldStoricoUpdated = relazioni; // Create a copy for further use
        });
        // Debug prints
        print("allProdottiByStoricoNew: ${prodottiStoricoUtente.map((e) => e.prodotto?.descrizione).toList()}");
        print("allProdottiByStoricoList1: ${oldStoricoUpdated.map((e) => e.prodotto?.descrizione).toList()}");
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore! $e');
    }
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

  void addRemainingProductsToHistory() async {
    // Get the products that were not used
    List<RelazioneDdtProdottoModel> remainingProducts = prodottiDDT
        .where((relazione) => !prodottiUsati.any((prodottoUsato) => prodottoUsato.id == relazione.prodotto?.id))
        .toList();

    for (var relazione in remainingProducts) {
      try {
        final response = await http.post(
          Uri.parse('$ipaddressProva2/api/relazioneUtentiProdotti'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'data_creazione': DateTime.now().toIso8601String(),
            'prodotto': relazione.prodotto?.toMap(),
            'quantita': relazione.quantita,
            'materiale': null,
            'utente': widget.utente.toMap(),
            'ddt': ddt?.toMap(), // Set DDT to null since it's not part of the DDT
            'intervento': widget.intervento.toMap(), // Set intervento to null since it's not part of the intervention
            'assegnato': false
          }),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to add product to history: ${response.statusCode}');
        }
      } catch (e) {
        print('Error adding product to history: $e');
      }
    }
  }
}
