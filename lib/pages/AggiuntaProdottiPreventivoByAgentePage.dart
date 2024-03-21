import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:fema_crm/model/PreventivoModel.dart';
import 'package:fema_crm/model/ProdottoModel.dart';
import 'ModificaSelezioneProdottiPreventivoByAgentePage.dart';
import 'ModificaSelezioneProdottiPreventivoPage.dart';

class AggiuntaProdottoPreventivoByAgentePage extends StatefulWidget {
  final PreventivoModel preventivo;

  const AggiuntaProdottoPreventivoByAgentePage({Key? key, required this.preventivo}) : super(key: key);

  @override
  _AggiuntaProdottoPreventivoByAgentePageState createState() => _AggiuntaProdottoPreventivoByAgentePageState();
}

class _AggiuntaProdottoPreventivoByAgentePageState extends State<AggiuntaProdottoPreventivoByAgentePage> {
  bool isSearching = false;
  late TextEditingController searchController;
  List<ProdottoModel> prodottiList = [];
  List<ProdottoModel> filteredProdottiList = [];
  Set<ProdottoModel> selectedProducts = {};

  @override
  void initState() {
    print("Id preventivo:" + widget.preventivo.id.toString());
    print("Provvigioni preventivo:" + widget.preventivo.listino.toString());
    print("Provvigioni agente:" + widget.preventivo.agente!.categoria_provvigione.toString());
    super.initState();
    searchController = TextEditingController();
    getAllProdotti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching ? _buildSearchField() : Text(
          'Aggiunta prodotti al preventivo',
          style: TextStyle(color: Colors.white), // Imposta il colore del testo su bianco
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: _buildActions(),
      ),
      body: Column(
        children: [
          _buildSelectedProductsList(),
          Expanded(
            child: isSearching ? _buildFilteredProductList() : SizedBox(),
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
              color: Colors.yellowAccent.withOpacity(0.3),
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

        return ListTile(
          title: Text(prodotto.descrizione ?? ''),
          subtitle: Text('Prezzo: ${prodotto.prezzo_fornitore}'),
          leading: Checkbox(
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
          onTap: () {
            // Se vuoi gestire anche la selezione tramite tap sul prodotto
            // aggiungi qui la logica
          },
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
      filteredProdottiList.clear();
    });
  }

  Future<void> getAllProdotti() async {
    try {
      var apiUrl = Uri.parse("http://192.168.1.52:8080/api/prodotto");
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<ProdottoModel> prodotti = [];
        for (var item in jsonData) {
          prodotti.add(ProdottoModel.fromJson(item));
        }

        setState(() {
          prodottiList = prodotti;
          filteredProdottiList = prodotti;
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

  Widget _buildFloatingActionButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ModificaSelezioneProdottiPreventivoByAgentePage(prodottiSelezionati: selectedProducts.toList(), preventivo: widget.preventivo),
            ),
          );
        },
        child: Icon(Icons.arrow_forward, color: Colors.white),
      ),
    );
  }
}
