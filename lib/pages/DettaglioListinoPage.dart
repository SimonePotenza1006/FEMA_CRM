import 'dart:convert';

import 'package:fema_crm/databaseHandler/DbHelper.dart';
import 'package:fema_crm/model/CategoriaInterventoSpecificoModel.dart';
import 'package:flutter/material.dart';
import 'package:io/ansi.dart';
import 'package:http/http.dart' as http;

import '../model/CategoriaPrezzoListinoModel.dart';
import 'NuovoListinoPage.dart';

class DettaglioListinoPage extends StatefulWidget {
  final CategoriaInterventoSpecificoModel categoria;

  const DettaglioListinoPage({Key? key1, required this.categoria})
      : super(key: key1);

  @override
  _DettaglioListinoPageState createState() => _DettaglioListinoPageState();
}

class _DettaglioListinoPageState extends State<DettaglioListinoPage> {
  DbHelper? dbHelper;
  List<CategoriaPrezzoListinoModel> allListiniForCategoria = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';
  bool isLoading = true;

  @override
  void initState() {
    dbHelper = DbHelper();
    init();
    super.initState();
    getAllListiniForCategoria();
  }

  Future<void> init() async {
    print("Tiro giù i listini");
    await getAllListiniForCategoria();
    print(
        "Numero totale di listini data la categoria specifica: ${allListiniForCategoria.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Management Listini',
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.red,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.add,
                size: 40,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NuovoListinoPage(categoria: widget.categoria),
                    ));
              },
            )
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: allListiniForCategoria.length,
                itemBuilder: (context, index) {
                  final listino = allListiniForCategoria[index];
                  return buildViewListini(listino);
                }));
  }

  Future<void> getAllListiniForCategoria() async {
    try {
      final response = await http.get(Uri.parse(
          '$ipaddress2/api/listino/categoria/${widget.categoria.id}'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          allListiniForCategoria = responseData
              .map((data) => CategoriaPrezzoListinoModel.fromJson(data))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Faildet to load Listini');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildViewListini(CategoriaPrezzoListinoModel listino) {
    return Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        color: Colors.white.withOpacity(0.4),
        child: ListTile(
          minLeadingWidth: 12,
          visualDensity: const VisualDensity(horizontal: 0, vertical: 4),
          onTap: () {},
          leading: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[Icon(Icons.attach_money_outlined, size: 40)],
          ),
          title: Text(
            '${listino.descrizione}, prezzo: ${listino.prezzo} €',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
          ),
        ));
  }
}
