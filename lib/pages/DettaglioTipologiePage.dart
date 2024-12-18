import 'dart:convert';

import 'package:fema_crm/model/CategoriaPrezzoListinoModel.dart';
import 'package:fema_crm/model/TipologiaInterventoModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../databaseHandler/DbHelper.dart';
import '../model/CategoriaInterventoSpecificoModel.dart';
import 'DettaglioListinoPage.dart';
import 'NuovaCategoriaPage.dart';

class DettaglioTipologiePage extends StatefulWidget {
  final TipologiaInterventoModel tipologia;

  const DettaglioTipologiePage({Key? key, required this.tipologia})
      : super(key: key);

  @override
  _DettaglioTipologiePageState createState() => _DettaglioTipologiePageState();
}

class _DettaglioTipologiePageState extends State<DettaglioTipologiePage> {
  DbHelper? dbHelper;
  List<CategoriaInterventoSpecificoModel> allCategorieForTipologia = [];
  bool isLoading = true;
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = '192.128.1.248:8090';
  String ipaddressProva2 = '192.168.1.198:8095';

  @override
  void initState() {
    dbHelper = DbHelper();
    init();
    super.initState();
    getAllCategorieForTipologia();
  }

  Future<void> init() async {
    print(
        "Provo a tirare giù le categorie specifiche data una determinata tipologia");
    await getAllCategorieForTipologia();
    print(
        "Numero totale di categorie data la tipologia: ${allCategorieForTipologia.length}");
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
                          NuovaCategoriaPage(tipologia: widget.tipologia),
                    ));
              },
            )
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: allCategorieForTipologia.length,
                itemBuilder: (context, index) {
                  final categoria = allCategorieForTipologia[index];
                  return buildViewCategorie(categoria);
                }));
  }

  Future<void> getAllCategorieForTipologia() async {
    try {
      final response = await http.get(Uri.parse(
          '$ipaddress/api/categorieIntervento/tipologia/${widget.tipologia.id}'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          allCategorieForTipologia = responseData
              .map((data) => CategoriaInterventoSpecificoModel.fromJson(data))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load Categorie Intervento Specifiche');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget? buildViewCategorie(CategoriaInterventoSpecificoModel categoria) {
    return Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        color: Colors.white.withOpacity(0.4),
        child: ListTile(
          minLeadingWidth: 12,
          visualDensity: const VisualDensity(horizontal: 0, vertical: 4),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DettaglioListinoPage(categoria: categoria),
                ));
          },
          leading: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[Icon(Icons.category, size: 40)],
          ),
          title: Text(
            '${categoria.descrizione}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
          ),
        ));
  }
}
