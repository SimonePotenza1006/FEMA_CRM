import 'dart:convert';
import 'dart:core';

import 'package:fema_crm/model/ClienteModel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/ProdottoModel.dart';
import '../model/FornitoreModel.dart';
import '../model/ProdottoModel.dart';
import '../model/UtenteModel.dart';


class FormOrdineFornitorePage extends StatefulWidget {
  final UtenteModel utente;

  const FormOrdineFornitorePage({Key? key, required this.utente}) : super(key:key);
  @override
  _FormOrdineFornitorePageState createState() => _FormOrdineFornitorePageState();
}

class _FormOrdineFornitorePageState extends State<FormOrdineFornitorePage>{

  List<FornitoreModel> allFornitori = [];
  List<FornitoreModel> filteredFornitori = [];
  List<ProdottoModel> allProdotti = [];
  List<ProdottoModel> filteredProdotti = [];
  List<ClienteModel> allClienti = [];
  List<ClienteModel> filteredClienti = [];
  List<ProdottoModel> prodottiOrdinati = [];
  ProdottoModel? selectedProdotto;
  //FornitoreModel? selectedFornitore;
  ClienteModel? selectedCliente;
  late TextEditingController searchController;
  final TextEditingController _descrizioneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _quantitaController = TextEditingController();
  final TextEditingController _prodottoNonPresenteController = TextEditingController();
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  late DateTime selectedDate;
  late DateTime selectedDate2;
  bool isSearching = false;
  bool _prodottoNonPresente = false;


  Future<void> getAllProdotti() async{
    try{
      final response = await http.get(Uri.parse('$ipaddress/api/prodotto'));
      if(response.statusCode == 200){
        final jsonData = jsonDecode(response.body);
        List<ProdottoModel> prodotti = [];
        for(var item in jsonData){
          prodotti.add(ProdottoModel.fromJson(item));
        }
        setState(() {
          allProdotti = prodotti;
          filteredProdotti = prodotti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Errore durante la chiamata all\'API: $e');
    }
  }


  Future<void> getAllClienti() async {
    try {
      final response = await http.get(Uri.parse('$ipaddress/api/cliente'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectDate2(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate2) {
      setState(() {
        selectedDate2 = picked;
      });
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

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    getAllClienti();
    getAllProdotti();
    //getAllFornitori();
    selectedDate = DateTime.now();
    selectedDate2 = DateTime.now();// Inizializza la data selezionata con la data corrente
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ORDINE AL FORNITORE',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              SizedBox(
                width: 500,
                child: TextFormField(
                  controller: _descrizioneController,
                  decoration: InputDecoration(
                    labelText: "Descrizione ordine",
                    hintText: "Inserire la descrizione dell'ordine",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      _showClientiDialog();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedCliente?.denominazione ?? 'Seleziona Cliente',
                            style: TextStyle(fontSize: 16),
                          ),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: 500,
                child: TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: "Note (Cliente non in elenco, informazioni aggiuntive, etc.)",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _selectDate(context);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Seleziona la data in cui il prodotto deve essere disponibile',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Data selezionata: ${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year.toString().substring(2)}',
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      _selectDate2(context);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Seleziona la data ultima in cui il prodotto DEVE essere in azienda',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Data selezionata: ${selectedDate2.day.toString().padLeft(2, '0')}-${selectedDate2.month.toString().padLeft(2, '0')}-${selectedDate2.year.toString().substring(2)}',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Column(
                children: [
                  Container(
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
                  SizedBox(height: 10),
                  Container(
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
                              return CheckboxListTile(
                                title: Text('${prodotto.descrizione}'),
                                value: prodottiOrdinati.contains(prodotto),
                                onChanged: (value) {
                                  setState(() {
                                    if (value!) {
                                      prodottiOrdinati.add(prodotto);
                                    } else {
                                      prodottiOrdinati.remove(prodotto);
                                    }
                                  });
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
                ],
              ),
              SizedBox(height: 12),
              if (prodottiOrdinati.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Prodotti selezionati:'),
                      for (var prodotto in prodottiOrdinati)
                        Text('- ${prodotto.descrizione}'),
                    ],
                  ),
                ),
              SizedBox(height: 24),
              SizedBox(
                width: 370,
                child: CheckboxListTile(
                  title: Text('Prodotto non presente in magazzino'),
                  value: _prodottoNonPresente,
                  onChanged: (value) {
                    setState(() {
                      _prodottoNonPresente = value!;
                      if (_prodottoNonPresente) {
                        _prodottoNonPresenteController.clear();
                      }
                    });
                  },
                ),
              ),

              SizedBox(height: 20),
              _prodottoNonPresente
                  ? SizedBox(
                width: 400,
                child: TextFormField(
                  controller: _prodottoNonPresenteController,
                  decoration: InputDecoration(
                    labelText: "Inserire il prodotto",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                )
              ) : Container(),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (prodottiOrdinati.isNotEmpty) {
                      saveOrdineProdottiPresenti();
                    }
                    if (_prodottoNonPresente == true) {
                      saveOrdineProdottoNonPresente();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    onPrimary: Colors.white,
                    padding: EdgeInsets.all(24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Salva ordine'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveNota() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/noteTecnico'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'utente' : widget.utente.toMap(),
          'data' : DateTime.now().toIso8601String(),
          'nota' : 'Creato ordine per il cliente ${selectedCliente?.denominazione}, richiesta disponibilità per la data ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
          'cliente' : selectedCliente?.toMap()
        }),
      );
    } catch(e){
      print("Errore nota : $e");
    }
  }

  Future<void> saveOrdineProdottoNonPresente() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/ordine'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'descrizione' : _descrizioneController.text,
          'cliente' : selectedCliente?.toMap(),
          'data_creazione' : DateTime.now().toIso8601String(),
          'data_richiesta' : DateTime.now().toIso8601String(),
          'data_disponibilita' : selectedDate.toIso8601String(),
          'data_ultima' : selectedDate2.toIso8601String(),
          'utente' : widget.utente.toMap(),
          //'fornitore' : selectedFornitore?.toMap(),
          'prodotto_non_presente' : _prodottoNonPresenteController.text,
          'note' : _noteController.text,
          'presa_visione' : false,
          'ordinato' : false,
          'arrivato' : false,
          'consegnato' : false
        }),
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Prodotto aggiunto correttamente all\'ordine'),
          ),
        );
        saveNota();
      }
    } catch(e){
      print('Errore 3: $e');
    }
  }
  
  Future<void> saveOrdineProdottiPresenti() async{
    try{
      for(var prodotto in prodottiOrdinati){
        try{
          final response = await http.post(
            Uri.parse('$ipaddress/api/ordine'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'descrizione' : _descrizioneController.text,
              'cliente' : selectedCliente?.toMap(),
              'data_creazione' : DateTime.now().toIso8601String(),
              'data_richiesta' : DateTime.now().toIso8601String(),
              'data_disponibilita' : selectedDate.toIso8601String(),
              'data_ultima' : selectedDate2.toIso8601String(),
              'utente' : widget.utente.toMap(),
              'prodotto' : prodotto.toMap(),
              //'fornitore' : selectedFornitore?.toMap(),
              'prodotto_non_presente' : null,
              'note' : _noteController.text,
              'presa_visione' : false,
              'ordinato' : false,
              'arrivato' : false,
              'consegnato' : false
            }),
          );
          if(response.statusCode == 201){
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Prodotto aggiunto correttamente all\'ordine'),
                ),
            );
            saveNota();
          }
        } catch(e){
          print('Errore 1: $e');
        }
      }
    } catch(e){
      print('Errore 2: $e');
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
      isSearching = true;
      searchController.clear();
      filteredProdotti.clear();
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

}
