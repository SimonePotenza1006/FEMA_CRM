import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/MerceInRiparazioneModel.dart';
import 'DettaglioMerceInRiparazioneAmministrazionePage.dart';

class ReportMerceInRiparazionePage extends StatefulWidget{
  const ReportMerceInRiparazionePage({Key? key}) : super(key:key);

  @override
  _ReportMerceInRiparazionePageState createState() => _ReportMerceInRiparazionePageState();

}

class _ReportMerceInRiparazionePageState extends State<ReportMerceInRiparazionePage>{
  List<MerceInRiparazioneModel> merceList =[];
  List<MerceInRiparazioneModel> originalMerceList =[];
  bool _isSearchActive = false;
  String? _filterValue;
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAllMerce();
  }

  @override
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
              filterMerce(value);
            },
          ),
        )
            : Text(
          'Report Merce in riparazione',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: _isSearchActive ? Icon(Icons.clear) : Icon(Icons.search),
            color: Colors.white,
            onPressed: () {
              setState(() {
                _isSearchActive = !_isSearchActive;
                if (!_isSearchActive) {
                  _searchController.clear();
                  filterMerce('');
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.info),
            color: Colors.white,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Legenda colori:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Giallo: Da saldare'),
                        Text('Azzurro: Assegnato e in lavorazione'),
                        Text('Verde: Saldato'),
                        Text('Bianco: Non assegnato'),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 20,
            columns: [
              DataColumn(
                  label: Text('Data arrivo merce',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Articolo',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Difetto riscontrato',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Richiesta preventivo',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Importo preventivato',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Data assegnazione',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Risoluzione',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Prodotti installati',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Data di consegna',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: merceList.map((merce) {
              Color backgroundColor = Colors.white;
              Color textColor = Colors.black;


// Imposta il colore del testo su bianco per i colori di sfondo azzurro e verde
              if (backgroundColor == Colors.lightBlueAccent || backgroundColor == Colors.green) {
                textColor = Colors.white;
              }

              return DataRow(
                color:
                MaterialStateColor.resolveWith((states) => backgroundColor),
                cells: [
                  DataCell(
                    Center(
                        child: Text(
                            merce.data != null ? DateFormat('dd/MM/yyyy').format(merce.data!) : 'N/A',
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(merce),
                  ),
                  DataCell(
                    Center(
                        child: Text(merce.articolo ?? 'N/A',
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(merce),
                  ),
                  DataCell(
                    Center(
                        child: Text(merce.difetto_riscontrato ?? 'N/A',
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(merce),
                  ),
                  DataCell(
                    Center(
                        child: Text(merce.preventivo ?? false ? "SI" : "NO",
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(merce),
                  ),
                  DataCell(
                    Center(
                        child: Text(merce.importo_preventivato?.toString() ?? 'N/A',
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(merce),
                  ),
                  DataCell(
                    Center(
                        child: Text(
                            merce.data_presa_in_carico != null ? DateFormat('dd/MM/yyyy').format(merce.data_presa_in_carico!) : 'N/A',
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(merce),
                  ),
                  DataCell(
                    Center(
                        child: Text(merce.risoluzione ?? "N/A",
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(merce),
                  ),
                  DataCell(
                    Center(
                        child: Text(merce.prodotti_installati ?? "N/A",
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(merce),
                  ),
                  DataCell(
                    Center(
                        child: Text(merce.data_consegna != null ? DateFormat('dd/MM/yyyy').format(merce.data_consegna!) : 'N/A',
                            style: TextStyle(color: textColor))),
                    onTap: () => _navigateToDetailsPage(merce),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> getAllMerce() async {
    try{
      var apiUrl = Uri.parse('${ipaddress}/api/merceInRiparazione/ordered');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<MerceInRiparazioneModel> merce = [];
        for(var item in jsonData){
          merce.add(MerceInRiparazioneModel.fromJson(item));
        }
        setState(() {
          merceList = merce;
          originalMerceList = List.from(merce);
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

  void filterMerce(String query) {
    setState(() {
      if (query.isNotEmpty) {
        merceList = originalMerceList.where((merce) {
          final articolo = merce.articolo ?? '';
          final difetto = merce.difetto_riscontrato ?? '';

          return
              articolo
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              difetto.toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      } else {
        merceList =
            List.from(originalMerceList); // Ripristina la lista originale
      }
    });
  }

  void _navigateToDetailsPage(MerceInRiparazioneModel merce) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DettaglioMerceInRiparazioneAmministrazionePage(
            merce: merce, onNavigateBack: getAllMerce),
      ),
    );
  }








}