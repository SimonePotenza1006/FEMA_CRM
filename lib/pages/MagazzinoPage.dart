import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/ProdottoModel.dart';
import 'DettaglioProdottoPage.dart';

class MagazzinoPage extends StatefulWidget {
  const MagazzinoPage({Key? key}) : super(key: key);

  @override
  _MagazzinoPageState createState() => _MagazzinoPageState();
}

class _MagazzinoPageState extends State<MagazzinoPage> {
  List<ProdottoModel> prodottiList = [];
  List<ProdottoModel> filteredProdottiList = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  int currentPage = 0;
  int itemsPerPage = 50;
  String ipaddress = 'http://gestione.femasistemi.it:8090';
String ipaddressProva = 'http://gestione.femasistemi.it:8095';

  @override
  void initState() {
    super.initState();
    getAllProdotti();
  }

  Future<void> getAllProdotti() async {
    try {
      var apiUrl = Uri.parse("$ipaddress/api/prodotto");
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<ProdottoModel> prodotti = [];
        for (var item in jsonData) {
          prodotti.add(ProdottoModel.fromJson(item));
        }
        setState(() {
          prodottiList = prodotti;
          filteredProdottiList =
              prodotti; // Inizialmente, la lista filtrata è uguale a quella completa
          isLoading = false;
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
    }
  }

  void filterProdotti(String query) {
    setState(() {
      filteredProdottiList = prodottiList.where((prodotto) {
        final descrizione = prodotto.descrizione?.toLowerCase();
        final cod = prodotto.codice_danea?.toLowerCase();

        return descrizione!.contains(query.toLowerCase()) ||
                cod!.contains(query.toLowerCase());
      }).toList();
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
      filterProdotti('');
    });
  }

  List<ProdottoModel> getCurrentPageItems() {
    final int startIndex = currentPage * itemsPerPage;
    final int endIndex = (currentPage + 1) * itemsPerPage;
    return filteredProdottiList.sublist(
        startIndex,
        endIndex < filteredProdottiList.length
            ? endIndex
            : filteredProdottiList.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                onChanged: filterProdotti,
                decoration: InputDecoration(
                  hintText: 'Cerca per descrizione prodotto',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white),
              )
            : Text('Magazzino', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          isSearching
              ? IconButton(
                  icon: Icon(Icons.cancel, color: Colors.white),
                  onPressed: stopSearch,
                )
              : IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: startSearch,
                ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: currentPage > 0
                              ? () {
                                  setState(() {
                                    currentPage--;
                                  });
                                }
                              : null,
                          icon: Icon(Icons.arrow_back_ios),
                        ),
                        Text(
                          'Pagina ${currentPage + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: (currentPage + 1) * itemsPerPage <
                                  filteredProdottiList.length
                              ? () {
                                  setState(() {
                                    currentPage++;
                                  });
                                }
                              : null,
                          icon: Icon(Icons.arrow_forward_ios),
                        ),
                      ],
                    ),
                    DataTable(
                      columns: [
                        DataColumn(
                          label: Center(
                            child: Text('Codice a Barre',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700)),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Descrizione',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text('Giacenza',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700)),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text('Unità di misura',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700)),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text('Prezzo fornitore',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700)),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text('Prezzo medio di vendita',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700)),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text('Ultimo costo acquisto',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700)),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text('Fornitore',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700)),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text('IVA',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700)),
                          ),
                        ),
                      ],
                      rows: getCurrentPageItems().map((prodotto) {
                        return DataRow(cells: [
                          DataCell(
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DettaglioProdottoPage(
                                        prodotto: prodotto),
                                  ),
                                );
                              },
                              child: Center(
                                child: Text(prodotto.codice_danea ?? 'N/A',
                                    style:
                                        TextStyle(color: Colors.grey.shade800)),
                              ),
                            ),
                          ),
                          DataCell(
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DettaglioProdottoPage(
                                        prodotto: prodotto),
                                  ),
                                );
                              },
                              child: Text(
                                prodotto.descrizione != null &&
                                        prodotto.descrizione!.length > 30
                                    ? prodotto.descrizione!.substring(0, 30)
                                    : prodotto.descrizione ?? 'N/A',
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DettaglioProdottoPage(
                                        prodotto: prodotto),
                                  ),
                                );
                              },
                              child: Center(
                                child: Text(
                                  prodotto.qta_giacenza != null
                                      ? prodotto.qta_giacenza.toString()
                                      : '0.0',
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DettaglioProdottoPage(
                                        prodotto: prodotto),
                                  ),
                                );
                              },
                              child: Center(
                                child: Text(prodotto.unita_misura ?? 'N/A',
                                    style:
                                        TextStyle(color: Colors.grey.shade800)),
                              ),
                            ),
                          ),
                          DataCell(
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DettaglioProdottoPage(
                                        prodotto: prodotto),
                                  ),
                                );
                              },
                              child: Center(
                                child: Text(
                                  prodotto.prezzo_fornitore != null
                                      ? '${prodotto.prezzo_fornitore.toString()} €'
                                      : 'N/A',
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DettaglioProdottoPage(
                                        prodotto: prodotto),
                                  ),
                                );
                              },
                              child: Center(
                                child: Text(
                                  prodotto.prezzo_medio_vendita != null
                                      ? '${prodotto.prezzo_medio_vendita.toString()} €'
                                      : 'N/A',
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DettaglioProdottoPage(
                                        prodotto: prodotto),
                                  ),
                                );
                              },
                              child: Center(
                                child: Text(
                                  prodotto.ultimo_costo_acquisto != null
                                      ? '${prodotto.ultimo_costo_acquisto.toString()} €'
                                      : '0.0',
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DettaglioProdottoPage(
                                        prodotto: prodotto),
                                  ),
                                );
                              },
                              child: Text(
                                prodotto.fornitore ?? 'N/A',
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DettaglioProdottoPage(
                                        prodotto: prodotto),
                                  ),
                                );
                              },
                              child: Center(
                                child: Text(
                                  prodotto.iva != null
                                      ? '${prodotto.iva.toString()} %'
                                      : 'N/A',
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: currentPage > 0
                              ? () {
                                  setState(() {
                                    currentPage--;
                                  });
                                }
                              : null,
                          icon: Icon(Icons.arrow_back_ios),
                        ),
                        Text(
                          'Pagina ${currentPage + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: (currentPage + 1) * itemsPerPage <
                                  filteredProdottiList.length
                              ? () {
                                  setState(() {
                                    currentPage++;
                                  });
                                }
                              : null,
                          icon: Icon(Icons.arrow_forward_ios),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
