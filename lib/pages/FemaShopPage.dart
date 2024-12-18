import 'dart:convert';
import 'dart:core';
import 'package:fema_crm/databaseHandler/DbHelper.dart';
import 'package:fema_crm/model/DDTModel.dart';
import 'package:fema_crm/model/InterventoModel.dart';
import 'package:fema_crm/model/RelazioneClientiProdottiModel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/ClienteModel.dart';
import '../model/DestinazioneModel.dart';
import '../model/ProdottoModel.dart';
import '../model/RelazioneProdottiInterventoModel.dart';
import '../model/UtenteModel.dart';

class FemaShopPage extends StatefulWidget {
  final UtenteModel utente;

  const FemaShopPage({Key? key, required this.utente}) : super(key: key);

  @override
  _FemaShopPageState createState() => _FemaShopPageState();
}

class _FemaShopPageState extends State<FemaShopPage> {
  DbHelper? dbhelper;
  Map<String, int> productQuantities = {};
  Map<String, double> productPrices = {};
  Map<String, TextEditingController> priceControllers = {};
  Map<String, TextEditingController> quantityControllers = {};
  Map<String, SelezioneProdotto> selectedProductsMap = {};
  late TextEditingController searchController;
  bool isSearching = false;
  List<ProdottoModel> allProdotti = [];
  List<ProdottoModel> filteredProdotti = [];
  List<SelezioneProdotto> selectedProdotti = [];
  List<ClienteModel> allClienti = [];
  List<ClienteModel> filteredClienti = [];
  List<DestinazioneModel> destinazioni = [];
  List<RelazioneClientiProdottiModel> relazioniVecchieVendite = [];
  DestinazioneModel? selectedDestinazione;
  final TextEditingController _descrizioneController = TextEditingController();
  final TextEditingController _titoloController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  ClienteModel? selectedCliente;
  final _formKey = GlobalKey<FormState>();
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';
  List<UtenteModel> allUtenti = [];
  UtenteModel? selectedUtenteSegreteria;

  Future<void> getAllRelazioniVendite(String clienteId) async{
    try{
      final response = await http.get(Uri.parse('$ipaddress2/api/relazioniClientiProdotti/cliente/$clienteId'));
      if(response.statusCode == 200){
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<RelazioneClientiProdottiModel> relazioni = [];
        for(var item in jsonData){
          relazioni.add(RelazioneClientiProdottiModel.fromJson(item));
        }
        setState(() {
          relazioniVecchieVendite = relazioni;
        });
      } else{
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Errore durante la chiamata all\'API: $e');
    }
  }

  Future<void> getAllUtentiAttivi() async {
    try {
      var apiUrl = Uri.parse('$ipaddress2/api/utente/attivo');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<UtenteModel> utenti = [];
        for(var item in jsonData){
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          allUtenti = utenti;
        });
      } else {
        throw Exception(
            'Failed to load agenti data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching agenti data from API: $e');
    }
  }

  Future<void> getAllClienti() async {
    try {
      final response = await http.get(Uri.parse('$ipaddress2/api/cliente'));
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<ClienteModel> clienti = [];
        for (var item in jsonData) {
          clienti.add(ClienteModel.fromJson(item));
        }
        setState(() {
          allClienti = clienti;
          filteredClienti = clienti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
    }
  }

  void _toggleProductSelection(ProdottoModel prodotto, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedProductsMap[prodotto.id.toString()] = SelezioneProdotto(
          prodotto: prodotto,
          quantity: 1,
          price: prodotto.prezzo_fornitore ?? 0.00,
        );
        print('Aggiunto prodotto: ${prodotto.id} - ${prodotto.descrizione}');
      } else {
        selectedProductsMap.remove(prodotto.id.toString());
        print('Rimosso prodotto: ${prodotto.id}');
      }
      print('Prodotti selezionati: $selectedProductsMap');
    });
  }


  Widget _buildSelectedProducts(List<RelazioneClientiProdottiModel> relazioniCliente) {
    if (selectedProductsMap.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PRODOTTI SELEZIONATI',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Column(
          children: selectedProductsMap.entries.map((entry) {
            final key = entry.key;
            final selezione = entry.value;

            // Ensure controllers are created and linked to the correct SelezioneProdotto
            if (!priceControllers.containsKey(key)) {
              priceControllers[key] = TextEditingController(text: selezione.price.toStringAsFixed(2));
            }
            if (!quantityControllers.containsKey(key)) {
              quantityControllers[key] = TextEditingController(text: selezione.quantity.toString());
            }

            // Ottieni l'ultimo prezzo del prodotto per il cliente
            final ultimoPrezzo = _getUltimoPrezzoProdotto(selezione.prodotto, relazioniCliente);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selezione.prodotto.descrizione?.toUpperCase() ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (ultimoPrezzo != null) // Se esiste un prezzo, mostralo
                          Text(
                            ' - Ultimo prezzo: €${ultimoPrezzo.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14, color: Colors.black),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      controller: priceControllers[key],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prezzo',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final double? prezzo = double.tryParse(value);
                        setState(() {
                          selezione.price = prezzo ?? 0.00;
                          selectedProductsMap[key] = selezione;
                        });
                      },
                      onFieldSubmitted: (_) {
                        setState(() {
                          selezione.price = double.tryParse(priceControllers[key]?.text ?? "0.00") ?? 0.00;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      controller: quantityControllers[key],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantità',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final int? quantity = int.tryParse(value);
                        setState(() {
                          selezione.quantity = quantity ?? 0;
                          selectedProductsMap[key] = selezione;
                        });
                      },
                      onFieldSubmitted: (_) {
                        setState(() {
                          selezione.quantity = int.tryParse(quantityControllers[key]?.text ?? "0") ?? 0;
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }



  Future<void> getAllDestinazioniByCliente(String clientId) async {
    try {
      final response = await http.get(Uri.parse('$ipaddress2/api/destinazione/cliente/$clientId'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          destinazioni = responseData.map((data) => DestinazioneModel.fromJson(data)).toList();
        });
      } else {
        throw Exception('Failed to load Destinazioni per cliente');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
    }
  }

  void _showClientiDialog() {
    TextEditingController searchController = TextEditingController(); // Aggiungi un controller
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) { // Usa StatefulBuilder per aggiornare lo stato del dialogo
            return AlertDialog(
              title: const Text('Seleziona Cliente', textAlign: TextAlign.center),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController, // Aggiungi il controller
                      onChanged: (value) {
                        setState(() {
                          filteredClienti = allClienti
                              .where((cliente) => cliente.denominazione!
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Cerca Cliente',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: filteredClienti.map((cliente) {
                            return ListTile(
                              leading: const Icon(Icons.contact_page_outlined),
                              title: Text(
                                  '${cliente.denominazione}, ${cliente.indirizzo}'),
                              onTap: () {
                                setState(() {
                                  selectedCliente = cliente;
                                  getAllDestinazioniByCliente(cliente.id!);
                                  getAllRelazioniVendite(cliente.id!);
                                });
                                Navigator.of(context).pop();
                              },
                            );
                          }).toList(),
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
    );
  }

  void _showDestinazioniDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleziona la destinazione', textAlign: TextAlign.center),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: destinazioni.map((destinazione) {
                        return ListTile(
                          leading: const Icon(Icons.warehouse_outlined),
                          title: Text('${destinazione.denominazione!}'),
                          onTap: () {
                            setState(() {
                              selectedDestinazione = destinazione;
                            });
                            Navigator.of(context).pop();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> getAllProdotti() async {
    try {
      final response = await http.get(Uri.parse('$ipaddress2/api/prodotto'));
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<ProdottoModel> prodotti = [];
        for (var item in jsonData) {
          prodotti.add(ProdottoModel.fromJson(item));
        }
        setState(() {
          allProdotti = prodotti;
          filteredProdotti = prodotti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
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
      filteredProdotti = filtered;
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
      filteredProdotti = allProdotti; // Ripristina la lista dei prodotti filtrati
    });
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Cerca prodotti...'.toUpperCase(),
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.black),
      ),
      style: TextStyle(color: Colors.black),
      onChanged: filterProdotti,
    );
  }

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    dbhelper = DbHelper();
    getAllClienti();
    getAllProdotti();
    getAllUtentiAttivi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'VENDITA AL BANCO',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Center(
            child: Container(
              child: Column(
                children: [
                  SizedBox(
                    width: 500,
                    child: TextFormField(
                      controller: _descrizioneController,
                      onChanged: (value) {
                        setState(() {}); // Aggiorna lo stato per verificare il form
                      },
                      decoration: InputDecoration(
                        labelText: "Descrizione".toUpperCase(),
                        hintText: "Inserire una descrizione per la movimentazione".toUpperCase(),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: 500,
                    child: Container(
                      child: GestureDetector(
                        onTap: () {
                          _showClientiDialog();
                        },
                        child: SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(selectedCliente?.denominazione ?? 'Seleziona Cliente'.toUpperCase(), style: const TextStyle(fontSize: 16)),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: 500,
                    child: Container(
                      child: GestureDetector(
                        onTap: () {
                          _showDestinazioniDialog();
                        },
                        child: SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(selectedDestinazione?.denominazione ?? 'Seleziona la destinazione'.toUpperCase(), style: const TextStyle(fontSize: 16)),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text('SELEZIONARE I PRODOTTI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  SizedBox(height: 12),
                  Container(
                    width: 500,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSearchField(),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.search),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: 700,
                    height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: FutureBuilder<List<ProdottoModel>>(
                      future: Future.value(allProdotti),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Errore: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          List<ProdottoModel> prodotti = filteredProdotti;
                          return ListView.builder(
                            itemCount: prodotti.length,
                            itemBuilder: (context, index) {
                              ProdottoModel prodotto = prodotti[index];
                              final isSelected = selectedProductsMap.containsKey(prodotto.id);
                              return CheckboxListTile(
                                title: Text('${prodotto.descrizione}'.toUpperCase()),
                                value: isSelected,
                                onChanged: (value) {
                                  _toggleProductSelection(prodotto, value ?? false);
                                },
                              );
                            },
                          );
                        } else {
                          return Center(child: Text('Nessun prodotto nello storico'));
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSelectedProducts(relazioniVecchieVendite),
                  const SizedBox(height: 20),
                  _buildTotalDisplay(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: isFormValid() ? _confermaDialog : null,  // Abilita o disabilita in base alla validità del form
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: isFormValid() ? Colors.red : Colors.grey,
                        padding: EdgeInsets.all(24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text("CONFERMA")
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showVerificaDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('VERIFICA UTENZA'),
          content: Form( // Avvolgi tutto dentro un Form
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                  children: [
                    DropdownButtonFormField<UtenteModel>(
                      decoration: InputDecoration(
                        labelText: 'SELEZIONA UTENTE',
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.redAccent,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                      ),
                      value: selectedUtenteSegreteria,
                      items: allUtenti.map((utente) {
                        return DropdownMenuItem<UtenteModel>(
                          value: utente,
                          child: Text(utente.nomeCompleto() ??
                              'Nome non disponibile'),
                        );
                      }).toList(),
                      onChanged: (UtenteModel? val) {
                        setState(() {
                          selectedUtenteSegreteria = val;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Seleziona un utente';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'PASSWORD UTENTE',
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                        hintText: 'Inserire la password dell\'utente',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.redAccent,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci una password valida';
                        }
                        return null;
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () { // Convalida il form
                if(_passwordController.text == selectedUtenteSegreteria?.password){
                  savePrezzi();
                  saveMovimento();
                } else {
                  showPasswordErrorDialog(context);
                }
              },
              child: Text('Conferma'.toUpperCase()),
            ),
          ],
        );
      },
    );
  }

  Future<void> showPasswordErrorDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Impedisce la chiusura toccando fuori dal dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Errore'),
          content: Text('Password errata, impossibile creare il movimento'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Chiude il dialog
              },
              child: Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  double? _getUltimoPrezzoProdotto(ProdottoModel prodotto, List<RelazioneClientiProdottiModel> relazioniCliente) {
    final relazioniProdotto = relazioniCliente
        .where((relazione) => relazione.prodotto?.id == prodotto.id)
        .toList();
    if (relazioniProdotto.isEmpty) {
      return null; // Nessun prezzo trovato
    }
    relazioniProdotto.sort((a, b) => b.data!.compareTo(a.data!));
    return relazioniProdotto.first.prezzo;
  }

  void _confermaDialog(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            content: Container(
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text('Descrizione: ${_descrizioneController.text}'.toUpperCase(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                  Text('Cliente: ${selectedCliente?.denominazione}'.toUpperCase(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                  SizedBox(height: 8),
                  Text('Destinazione: ${selectedDestinazione?.denominazione}'.toUpperCase(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  _buildTotalDisplay(),
                  SizedBox(height: 8),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: (){
                  if(widget.utente.nome == "Segreteria"){
                    _showVerificaDialog();
                  } else {
                    savePrezzi();
                    saveMovimento();
                  }
                },
                child: Text('Conferma vendita'.toUpperCase(), style: TextStyle(color: Colors.red),),
              )
            ],
          );
        }
    );
  }

  bool isFormValid() {
    return _descrizioneController.text.isNotEmpty &&
        selectedCliente != null &&
        selectedDestinazione != null &&
        selectedProductsMap.isNotEmpty;
  }

  double calcolaTotaleSelezionati() {
    double totale = 0.0;
    selectedProductsMap.forEach((id, selezioneProdotto) {
      totale += selezioneProdotto.price * selezioneProdotto.quantity;
    });
    return totale;
  }

  Future<http.Response?> saveIntervento() async{
    late http.Response response;
    double totaleVendita = calcolaTotaleSelezionati();
    try{
      response = await http.post(
        Uri.parse('$ipaddress2/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'attivo' : true,
          'visualizzato' : false,
          'numerazione_danea' : null,
          'titolo' : "Vendita al banco",
          'data': DateTime.now().toIso8601String(),
          'data_apertura_intervento' : DateTime.now().toIso8601String(),
          'orario_appuntamento' : null,
          'posizione_gps' : null,
          'orario_inizio': DateTime.now().toIso8601String(),
          'orario_fine': DateTime.now().toIso8601String(),
          'descrizione': _descrizioneController.text,
          'importo_intervento': totaleVendita,
          'saldo_tecnico' : null,
          'prezzo_ivato' : null,
          'iva' : null,
          'assegnato': true,
          'accettato_da_tecnico' : false,
          'annullato' : false,
          'conclusione_parziale' : false,
          'concluso': true,
          'saldato': true,
          'saldato_da_tecnico' : false,
          'note': null,
          'relazione_tecnico' : _descrizioneController.text,
          'firma_cliente': null,
          'utente_apertura' : widget.utente.nome == "Segreteria" ? selectedUtenteSegreteria?.toMap() : widget.utente.toMap(),
          'utente': widget.utente.nome == "Segreteria" ? selectedUtenteSegreteria?.toMap() : widget.utente.toMap(),
          'cliente': selectedCliente?.toMap(),
          'veicolo': null,
          'merce' : null,
          'tipologia': {
            'id' : 7,
            'descrizione' : 'Vendita'
          },
          'categoria_intervento_specifico': null,
          'tipologia_pagamento': null,
          'destinazione': selectedDestinazione?.toMap(),
        })
      );
      if(response.statusCode == 201){
        return response;
      } else {
        return null;
      }
    } catch(e){
      print("Qualcosa non va intervento: $e");
      return null;
    }
  }

  Future<http.Response?> saveDdt() async{
    final data = await saveIntervento();
    try{
      if(data == null){
        throw Exception('Dati dell\'intervento non disponibili');
      }
      final intervento = InterventoModel.fromJson(jsonDecode(data.body));
      try{
        final response = await http.post(
          Uri.parse('$ipaddress2/api/ddt'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'data' : DateTime.now().toIso8601String(),
            'orario' : DateTime.now().toIso8601String(),
            'concluso' : true,
            'firmaUser': null,
            'imageData' : null,
            'cliente' : selectedCliente?.toMap(),
            'destinazione' : selectedDestinazione?.toMap(),
            'categoriaDdt' : {
              'id' : 2,
              'descrizione' : 'DDT vendita',
            },
            'utente' : widget.utente.nome == "Segreteria" ? selectedUtenteSegreteria?.toMap() : widget.utente.toMap(),
            'intervento' : intervento.toMap(),
          })
        );
        if(response.statusCode == 201){
          return response;
        }
        return null;
      } catch(e){
        print('1 Errore nel salvataggio del DDT: $e');
        return null;
      }
    } catch(e){
      print('2 Errore nel salvataggio');
    }
  }

  Future<void> savePrezzi() async{
    try{
      for(final entry in selectedProductsMap.entries){
        final selezione = entry.value;
        final relazione = {
          'prodotto' : selezione.prodotto.toMap(),
          'cliente' : selectedCliente?.toMap(),
          'prezzo' : selezione.price,
          'data' : DateTime.now().toIso8601String()
        };
        final response = await http.post(
          Uri.parse('$ipaddress2/api/relazioniClientiProdotti'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(relazione),
        );
        if(response.statusCode == 201 || response.statusCode == 200){
          print('dajeeee');
        }
      }
    } catch(e){
      print('Qualcosa non va');
    }
  }

  Future<List<RelazioneProdottiInterventoModel>?> saveRelazioni() async {
    final ddtResponse = await saveDdt(); // Recupera il DDT
    try {
      if (ddtResponse == null) {
        throw Exception('Dati del DDT non disponibili.');
      }
      final ddt = DDTModel.fromJson(jsonDecode(ddtResponse.body));
      final intervento = ddt.intervento;
      final List<RelazioneProdottiInterventoModel> relazioniCreate = [];
      for (final entry in selectedProductsMap.entries) {
        final selezione = entry.value;
        final relazione = {
          'prodotto': selezione.prodotto.toMap(),
          'ddt': ddt.toMap(),
          'intervento': intervento?.toMap(), // Usa l'intervento estratto dal DDT
          'quantita': double.parse(selezione.quantity.toString()),
          'prezzo': selezione.price,
          'presenza_storico_utente': false,
          'seriale': selezione.prodotto.lotto_seriale,
        };
        final response = await http.post(
          Uri.parse('$ipaddress2/api/relazioneProdottoIntervento'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(relazione),
        );
        if (response.statusCode == 200) {
          final relazioneCreata = RelazioneProdottiInterventoModel.fromJson(jsonDecode(response.body));
          relazioniCreate.add(relazioneCreata);
        } else {
          print('1 Errore nel salvataggio della relazione prodotto: ${response.statusCode}');
          return null;
        }
      }

      return relazioniCreate; // Ritorna le relazioni create
    } catch (e) {
      print('2 Errore nel salvataggio delle relazioni: $e');
      return null;
    }
  }



  Future<void> saveMovimento() async {
    final relazioniCreate = await saveRelazioni();
    try {
      if (relazioniCreate == null || relazioniCreate.isEmpty) {
        throw Exception('Dati delle relazioni non disponibili.');
      }
      final intervento = relazioniCreate.first.intervento;
      if (intervento == null) {
        throw Exception('Intervento non disponibile.');
      }
      double totaleVendita = calcolaTotaleSelezionati();
      final response = await http.post(
        Uri.parse('$ipaddress2/api/movimenti'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data' : DateTime.now().toIso8601String(),
          'dataCreazione' : DateTime.now().toIso8601String(),
          'descrizione' : _descrizioneController.text.toString(),
          'tipo_movimentazione' : "Entrata",
          'importo' : totaleVendita,
          'utente' : widget.utente.nome == "Segreteria" ? selectedUtenteSegreteria?.toMap() : widget.utente.toMap(),
          'intervento' : intervento.toMap(),
          'cliente' : selectedCliente?.toMap()
        }),
      );
      if (response.statusCode == 201) {
        print('Movimento salvato con successo');
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vendita salvata!'),
          ),
        );
      } else {
        print('Errore nel salvataggio del movimento: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore nel salvataggio del movimento: $e');
    }
  }

  Widget _buildTotalDisplay() {
    double totale = calcolaTotaleSelezionati();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Totale: €${totale.toStringAsFixed(2)}'.toUpperCase(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class SelezioneProdotto {
  final ProdottoModel prodotto;
  int quantity;
  double price;

  SelezioneProdotto({
    required this.prodotto,
    this.quantity = 1,
    this.price = 0.00,
  });

  @override
  String toString() {
    return 'SelezioneProdotto(prodotto: ${prodotto.descrizione}, quantity: $quantity, price: $price)';
  }
}


