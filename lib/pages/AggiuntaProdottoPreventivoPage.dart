import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:fema_crm/model/PreventivoModel.dart';
import 'package:fema_crm/model/ProdottoModel.dart';
import 'ModificaSelezioneProdottiPreventivoPage.dart';

class AggiuntaProdottoPreventivoPage extends StatefulWidget {
  final PreventivoModel preventivo;

  const AggiuntaProdottoPreventivoPage({Key? key, required this.preventivo})
      : super(key: key);

  @override
  _AggiuntaProdottoPreventivoPageState createState() =>
      _AggiuntaProdottoPreventivoPageState();
}

class _AggiuntaProdottoPreventivoPageState
    extends State<AggiuntaProdottoPreventivoPage> {
  bool isSearching = false;
  bool isLoading = true;  // Stato per il caricamento
  late TextEditingController searchController;
  List<ProdottoModel> prodottiList = [];
  List<ProdottoModel> filteredProdottiList = [];
  Set<ProdottoModel> selectedProducts = {};
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';

  @override
  void initState() {
    print("Id preventivo:" + widget.preventivo.id.toString());
    print("Provvigioni preventivo:" + widget.preventivo.listino.toString());
    // print("Provvigioni agente:" +
    //     widget.preventivo.agente!.categoria_provvigione.toString());
    super.initState();
    searchController = TextEditingController();
    getAllProdotti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? _buildSearchField()
            : Text(
          'Aggiunta prodotti al preventivo',
          style: TextStyle(
              color: Colors.white), // Imposta il colore del testo su bianco
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: _buildActions(),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          _buildSelectedProductsList(),
          Expanded( // or Flexible
            child: _buildFilteredProductList(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Cerca prodotti...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white54),
      ),
      style: TextStyle(color: Colors.white),
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

  Widget _buildSelectedProductsList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: selectedProducts.map((product) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(
                  0.3), // Sfondo azzurro per i prodotti selezionati
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.descrizione ?? '',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      selectedProducts.remove(product);
                    });
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilteredProductList() {
    return ListView.builder(
      itemCount: filteredProdottiList.length,
      itemBuilder: (context, index) {
        final prodotto = filteredProdottiList[index];
        final isSelected = selectedProducts.contains(prodotto);
        final seriale = filteredProdottiList[index].lotto_seriale != null ? 'Lotto/Seriale: ${filteredProdottiList[index].lotto_seriale}' : 'N/A';
        final fornitore = filteredProdottiList[index].fornitore != null ? 'Fornitore: ${filteredProdottiList[index].fornitore}' : 'Nessun fornitore segnalato';
        final prezzo = filteredProdottiList[index].prezzo_fornitore != null ? 'P. Fornitore: ${filteredProdottiList[index].prezzo_fornitore?.toStringAsFixed(2)}€' : 'Nessun prezzo fornitore presente';
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Table(
            border: TableBorder.all(),
            columnWidths: {
              0 : FlexColumnWidth(0.5),
              1 : FlexColumnWidth(2.2),
              2 : FlexColumnWidth(0.8),
              3 : FlexColumnWidth(0.7),
              4 : FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value!) {
                                selectedProducts.add(prodotto);
                              } else {
                                selectedProducts.remove(prodotto);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                          child: Text(
                            '${prodotto.descrizione}',
                            overflow: TextOverflow.clip,
                            maxLines: null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                          child: Text(
                            prezzo,
                            overflow: TextOverflow.clip,
                            maxLines: null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                          child: Text(
                            seriale,
                            overflow: TextOverflow.clip,
                            maxLines: null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Expanded(
                          child: Text(
                            fornitore,
                            overflow: TextOverflow.clip,
                            maxLines: null,
                          ),
                        ),
                      ],
                    ),
                  )
                ]
              )
            ],
          ),
        );
      },
    );
  }

  void filterProdotti(String query) {
    final filtered = prodottiList.where((prodotto) {
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
      filteredProdottiList = prodottiList; // Reimposta la lista filtrata all'originale
    });
  }

  Future<void> getAllProdotti() async {
    try {
      var apiUrl = Uri.parse("$ipaddressProva2/api/prodotto");
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<ProdottoModel> prodotti = [];
        for (var item in jsonData) {
          prodotti.add(ProdottoModel.fromJson(item));
        }
        setState(() {
          prodottiList = prodotti;
          filteredProdottiList = prodotti;
          isLoading = false; // Indica che il caricamento è completato
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
      setState(() {
        isLoading = false; // Ferma il caricamento anche in caso di errore
      });
    }
  }

  Widget _buildFloatingActionButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ModificaSelezioneProdottiPreventivoPage(
                  prodottiSelezionati: selectedProducts.toList(),
                  preventivo: widget.preventivo),
            ),
          );
        },
        child: Icon(Icons.arrow_forward, color: Colors.white),
      ),
    );
  }
}
