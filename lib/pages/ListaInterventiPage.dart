import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/CategoriaInterventoSpecificoModel.dart';
import '../model/CategoriaPrezzoListinoModel.dart';
import '../model/InterventoModel.dart';
import '../model/VeicoloModel.dart';
import 'DettaglioInterventoPage.dart';

class ListaInterventiPage extends StatefulWidget {
  const ListaInterventiPage({Key? key}) : super(key: key);

  @override
  _ListaInterventiPageState createState() => _ListaInterventiPageState();
}

class _ListaInterventiPageState extends State<ListaInterventiPage> {
  List<InterventoModel> interventiList = [];

  @override
  void initState() {
    super.initState();
    // Chiamata all'API
    getAllInterventi();
  }

  Future<List<VeicoloModel>> getAllVeicoli() async {
    try {
      http.Response response = await http.get(Uri.parse('http://192.168.1.52:8080/api/veicolo'));
      var responseData = json.decode(response.body.toString());
      if (response.statusCode == 200) {
        List<VeicoloModel> allVeicoli = [];
        for (var veicoloJson in responseData) {
          VeicoloModel veicolo = VeicoloModel.fromJson(veicoloJson);
          allVeicoli.add(veicolo);
        }
        return allVeicoli;
      } else {
        return [];
      }
    } catch (e) {
      print('Errore durante il fetch dei veicoli: $e');
      return [];
    }
  }


  Future<List<CategoriaInterventoSpecificoModel>> getCategoriaByTipologia(String tipologiaId) async {
    try {
      http.Response response = await http.get(Uri.parse('http://192.168.1.52:8080/api/categorieIntervento/tipologia/$tipologiaId'));
      var responseData = json.decode(response.body.toString());
      if (response.statusCode == 200) {
        List<CategoriaInterventoSpecificoModel> allCategorieByTipologia = [];
        for (var categoriaJson in responseData) {
          CategoriaInterventoSpecificoModel categoria = CategoriaInterventoSpecificoModel.fromJson(categoriaJson);
          allCategorieByTipologia.add(categoria);
        }
        return allCategorieByTipologia;
      } else {
        return [];
      }
    } catch (e) {
      print('Errore durante il fetch delle categorie: $e');
      return [];
    }
  }

  Future<List<CategoriaPrezzoListinoModel>> getListiniByCategoria(String categoriaId) async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.52:8080/api/listino/categoria/$categoriaId'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        List<CategoriaPrezzoListinoModel> listini = responseData.map((data) => CategoriaPrezzoListinoModel.fromJson(data)).toList();
        return listini;
      } else {
        throw Exception('Failed to load listini');
      }
    } catch (e) {
      print('Error fetching listini: $e');
      throw Exception('Failed to load listini');
    }
  }

  Future<void> getAllInterventi() async {
    try {
      var apiUrl = Uri.parse('http://192.168.1.52:8080/api/intervento/ordered');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        debugPrint('JSON ricevuto: ${response.body}', wrapWidth: 1024);
        var jsonData = jsonDecode(response.body);
        List<InterventoModel> interventi = [];
        for (var item in jsonData) {
          interventi.add(InterventoModel.fromJson(item));
        }
        setState(() {
          interventiList = interventi;
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
            content: Text('Impossibile caricare i dati dall\'API. Controlla la tua connessione internet e riprova.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista Interventi',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Data', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Assegnato', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Concluso', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Destinazione', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Tipologia Intervento', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Note', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Saldato', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: interventiList.map((intervento) {
              return DataRow(
                cells: [
                  DataCell(Text(DateFormat('dd/MM/yyyy').format(intervento.data ?? DateTime.now()))),
                  DataCell(Text(intervento.cliente?.denominazione ?? 'N/A')),
                  DataCell(
                    Container(
                      decoration: BoxDecoration(
                        color: intervento.assegnato ?? false ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Text(
                        intervento.assegnato ?? false ? 'Assegnato' : 'Non assegnato',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      decoration: BoxDecoration(
                        color: intervento.concluso ?? false ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Text(
                        intervento.concluso ?? false ? 'Concluso' : 'Non concluso',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  DataCell(Text(intervento.destinazione?.denominazione ?? 'N/A')),
                  DataCell(Text(intervento.tipologia?.descrizione.toString() ?? 'N/A')),
                  DataCell(Text(intervento.note ?? "N/A")),
                  DataCell(
                    Container(
                      decoration: BoxDecoration(
                        color: intervento.saldato ?? false ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Text(
                        intervento.saldato ?? false ? 'Saldato' : 'Non saldato',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
                onSelectChanged: (isSelected) {
                  if (isSelected != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DettaglioInterventoPage(intervento: intervento),
                      ),
                    );
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
