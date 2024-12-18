import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/ProdottoModel.dart';
import '../model/UtenteModel.dart';

class AggiuntaMerceStoricoUtentePage extends StatefulWidget {
  final UtenteModel utente;

  const AggiuntaMerceStoricoUtentePage({Key? key, required this.utente}) : super(key:key);

  @override
  _AggiuntaMerceStoricoUtentePageState createState() => _AggiuntaMerceStoricoUtentePageState();
}

class _AggiuntaMerceStoricoUtentePageState extends State<AggiuntaMerceStoricoUtentePage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';
  final TextEditingController _quantitaController = TextEditingController();
  List<ProdottoModel> allProdotti = [];
  List<ProdottoModel> filteredProdottiList = [];
  List<ProdottoModel> prodottiAssegnati = [];
  late TextEditingController searchController;
  bool isSearching = false;
  late List<TextEditingController> quantityControllersProdotti;
  late List<double> quantitaProdotti;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    getAllProdotti();
  }

  Future<void> getAllProdotti() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/prodotto');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aggiunta allo storico di ${widget.utente.nomeCompleto()}', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
                            value: prodottiAssegnati.contains(prodotto),
                            onChanged: (value) {
                              setState(() {
                                if (value!) {
                                  prodottiAssegnati.add(prodotto);

                                } else {
                                  prodottiAssegnati.remove(prodotto);
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
            SizedBox(height: 20),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: (){
                _showConfirmationDialog();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Aggiungi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void initializeQuantitaAndControllers() {
    quantitaProdotti = List.generate(
        prodottiAssegnati.length,
            (index) => (prodottiAssegnati[index].quantita?.toDouble() ?? 1.0)
    );
    quantityControllersProdotti = List.generate(
        prodottiAssegnati.length,
            (index) => TextEditingController(
            text: quantitaProdotti[index].toString()
        )
    );
  }

  void _showConfirmationDialog() {
    initializeQuantitaAndControllers();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confermi di aver usato i seguenti prodotti?'),
          content: Column(
            children: [
              Container(
                height: 600,
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: prodottiAssegnati.length,
                  itemBuilder: (context, index) {
                    final prodotto = prodottiAssegnati[index];
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
                for (int i = 0; i < prodottiAssegnati.length; i++) {
                  ProdottoModel prodotto = prodottiAssegnati[i];
                  double quantita = double.parse(quantityControllersProdotti[i].text);
                  addMerce(prodotto, quantita);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Prodotti assegnati con successo all\'utente ${widget.utente.nomeCompleto()}!'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('Conferma', style: TextStyle(color: Colors.white)),
              style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> addMerce(ProdottoModel? prodotto, double quantita) async {
    Map<String, dynamic> body = {
      'data_creazione' : DateTime.now().toIso8601String(),
      'prodotto' : prodotto?.toMap(),
      'quantita' : quantita,
      'utente' : widget.utente.toMap(),
      'assegnato' : true,
    };
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/relazioneUtentiProdotti'),
        body: jsonEncode(body),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
    } catch(e){
      print('Errore durante il salvataggio della movimentazione: $e');
    }
  }
}


