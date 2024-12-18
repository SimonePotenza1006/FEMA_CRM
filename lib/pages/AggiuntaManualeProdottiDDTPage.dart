import 'package:fema_crm/model/DDTModel.dart';
import 'package:fema_crm/pages/CompilazioneDDTByTecnicoPage.dart';
import 'package:http/http.dart' as http;
import '../model/InterventoModel.dart';
import '../model/ProdottoModel.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/InterventoModel.dart';

class AggiuntaManualeProdottiDDTPage extends StatefulWidget {
  final InterventoModel intervento;

  AggiuntaManualeProdottiDDTPage({
    Key? key,
    required this.intervento,
  }) : super(key: key);

  @override
  _AggiuntaManualeProdottiDDTPageState createState() =>
      _AggiuntaManualeProdottiDDTPageState();
}

class _AggiuntaManualeProdottiDDTPageState
    extends State<AggiuntaManualeProdottiDDTPage> {
  List<ProdottoModel> prodottiList = [];
  List<ProdottoModel> selectedProducts = [];
  bool isSearching = false;
  bool isLoading = true;
  late TextEditingController searchController;
  List<ProdottoModel> filteredProdottiList = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';
  DDTModel? ddt;



  Future<void> savePrimeDDT() async {
    try {
      Map<String, dynamic> body = {
        'data': widget.intervento.data?.toIso8601String(),
        'orario': DateTime.now().toIso8601String(),
        'concluso': false,
        'firmaUser': null,
        'imageData': null,
        'cliente': widget.intervento.cliente?.toMap(),
        'destinazione': widget.intervento.destinazione?.toMap(),
        'categoriaDdt': {'id': 1, 'descrizione': "DDT Intervento"},
        'utente': widget.intervento.utente?.toMap(),
        'intervento': widget.intervento.toMap(),
        'relazioni_prodotti': null,
      };

      debugPrint('Body della richiesta: $body', wrapWidth: 1024);

      final response = await http.post(
        Uri.parse('$ipaddress/api/ddt'),
        body: jsonEncode(body),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('Risposta: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        print('DDT inizializzato, daje');
      } else {
        print('Qualcosa non va');
      }
    } catch (e) {
      print('Errore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching ? _buildSearchField() : Text('Aggiunta prodotti per DDT', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: _buildActions(),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildSelectedProductsList(),
          Expanded(
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
          icon: Icon(Icons.clear),
          onPressed: () {
            stopSearch();
          },
        ),
      ];
    } else {
      return [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            startSearch();
          },
        ),
      ];
    }
  }

  Widget _buildSelectedProductsList() {
    if (selectedProducts.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Text('Nessun prodotto selezionato', style: TextStyle(fontSize: 16)),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: selectedProducts.map((product) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(product.descrizione ?? ''),
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
    if (filteredProdottiList.isEmpty) {
      return Center(
        child: Text("Nessun prodotto trovato", style: TextStyle(fontSize: 18)),
      );
    }

    return ListView.builder(
      itemCount: filteredProdottiList.length,
      itemBuilder: (context, index) {
        final prodotto = filteredProdottiList[index];
        final isSelected = selectedProducts.contains(prodotto);

        return ListTile(
          title: Text(prodotto.descrizione ?? ''),
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
      filteredProdottiList = prodottiList;
    });
  }

  Future<http.Response?> checkExistingDDT() async{
    try{
      var apiUrl = Uri.parse("$ipaddress/api/ddt/intervento/${widget.intervento.id}");
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          ddt = DDTModel.fromJson(jsonData);
        });
        return response;
      } else {
        return null;
      }
    } catch(e){
      print('error: $e');
    }
  }

  Future<void> getAllProdotti() async {
    try {
      var apiUrl = Uri.parse("$ipaddress/api/prodotto");
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
          isLoading = false;  // Aggiorna lo stato di caricamento
        });
        print("Prodotti caricati: ${prodotti.length}");
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    getAllProdotti().then((_) {
      setState(() {
        isLoading = false;
      });
    });
    checkExistingDDT().then((response){
      if(response == null){
        savePrimeDDT();
      } else {

      }
    });
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
              builder: (context) => CompilazioneDDTByTecnicoPage(
                  prodotti: selectedProducts.toList(),
                  intervento: widget.intervento),
            ),
          );
        },
        child: Icon(Icons.arrow_forward, color: Colors.white),
      ),
    );
  }
}
