import 'dart:convert';

import 'package:fema_crm/pages/DettaglioSopralluogoPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/SopralluogoModel.dart';
import '../model/UtenteModel.dart';
import 'package:http/http.dart' as http;

class ListaSopralluoghiTecnicoPage extends StatefulWidget{
  final UtenteModel utente;

  const ListaSopralluoghiTecnicoPage({Key? key, required this.utente}) : super(key : key);

  @override
  _ListaSopralluoghiTecnicoPageState createState() => _ListaSopralluoghiTecnicoPageState();
}

class _ListaSopralluoghiTecnicoPageState extends State<ListaSopralluoghiTecnicoPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  List<SopralluogoModel> sopralluoghiList = [];
  List<SopralluogoModel> originalSopralluoghiList = [];
  TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  bool isLoading = true;

  @override
  void initState(){
    super.initState();
    getSopralluoghiByUtente();
  }

  void filterSopralluoghi(String query) {
    setState(() {
      if (query.isNotEmpty) {
        sopralluoghiList = originalSopralluoghiList.where((sopralluogo) {
          final cliente = sopralluogo.cliente?.denominazione ?? '';
          final tipologia = sopralluogo.tipologia?.descrizione ?? '';
          final posizione = sopralluogo.posizione ?? '';
          final descrizione = sopralluogo.descrizione ?? '';

          return cliente.toLowerCase().contains(query.toLowerCase()) ||
              tipologia.toLowerCase().contains(query.toLowerCase()) ||
              posizione.toLowerCase().contains(query.toLowerCase()) ||
              descrizione.toLowerCase().contains(query.toLowerCase());
        }).toList();
      } else {
        sopralluoghiList = List.from(originalSopralluoghiList);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchActive
            ? Padding(
          padding: const EdgeInsets.only(right: 50.0),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Cerca per cliente',
              hintStyle: TextStyle(color: Colors.white),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              filterSopralluoghi(value);
            },
          ),
        )
            : Text(
          'Report Sopralluoghi',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
              color: Colors.white,
            ),
            onPressed: () {
              // Funzione per ricaricare la pagina
              setState(() {});
            },
          ),
          IconButton(
            icon: _isSearchActive ? Icon(Icons.clear) : Icon(Icons.search),
            color: Colors.white,
            onPressed: () {
              setState(() {
                _isSearchActive = !_isSearchActive;
                if (!_isSearchActive) {
                  _searchController.clear();
                  filterSopralluoghi('');
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(
                label: SizedBox(
                  width: MediaQuery.of(context).size.width /
                      3, // Larghezza 1/3 dello schermo
                  child: Center(
                    child: Text(
                      'Data',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  child: Center(
                    child: Text(
                      'Tipologia',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  child: Center(
                    child: Text(
                      'Cliente',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: SizedBox(
                  child: Center(
                    child: Text(
                      'Descrizione',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
            rows: sopralluoghiList.map((sopralluogo) {
              return DataRow(cells: [
                DataCell(
                  Center(
                    child: Text(DateFormat('dd/MM/yyyy').format(sopralluogo.data ?? DateTime.now())),),
                  onTap: () => _navigateToDetailsPage(sopralluogo),
                ),
                DataCell(
                  Center(
                      child: Text(
                          sopralluogo.tipologia?.descrizione.toString() ??
                              'N/A')),
                  onTap: () => _navigateToDetailsPage(sopralluogo),
                ),
                DataCell(
                  Center(
                      child: Text(
                          sopralluogo.cliente?.denominazione.toString() ??
                              'N/A')),
                  onTap: () => _navigateToDetailsPage(sopralluogo),
                ),
                DataCell(
                  Center(
                    child: Text(sopralluogo.descrizione.toString().length >= 30
                        ? sopralluogo.descrizione.toString().substring(0, 30)
                        : sopralluogo.descrizione.toString()),
                  ),
                  onTap: () => _navigateToDetailsPage(sopralluogo),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _navigateToDetailsPage(SopralluogoModel sopralluogo) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DettaglioSopralluogoPage(sopralluogo: sopralluogo),
      ),
    );
  }

  Future<void> getSopralluoghiByUtente() async {
    try {
      http.Response response = await http.get(Uri.parse('$ipaddress/api/sopralluogo/utente/${widget.utente.id}'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<SopralluogoModel> sopralluoghi = [];

        for (var item in responseData) {
          sopralluoghi.add(SopralluogoModel.fromJson(item));
        }

        // Ordina i sopralluoghi in ordine decrescente in base all'ID
        sopralluoghi.sort((a, b) => b.id!.compareTo(a.id!));

        setState(() {
          sopralluoghiList = sopralluoghi;
          originalSopralluoghiList = List.from(sopralluoghi); // Salva la lista originale
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
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