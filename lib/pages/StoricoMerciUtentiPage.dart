import 'package:excel/excel.dart';
import 'package:fema_crm/model/RelazioneUtentiProdottiModel.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../model/UtenteModel.dart';
import 'DettaglioStoricoMerceUtentePage.dart';

class StoricoMerciUtentiPage extends StatefulWidget {
  const StoricoMerciUtentiPage({Key? key}) : super(key: key);

  @override
  _StoricoMerciUtentiPageState createState() => _StoricoMerciUtentiPageState();
}

class _StoricoMerciUtentiPageState extends State<StoricoMerciUtentiPage> {
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';
  List<UtenteModel> utentiList = [];
  Map<String, List<RelazioneUtentiProdottiModel>> prodottiPerUtenteMap = {};

  @override
  void initState() {
    super.initState();
    getAllUtenti();
  }

  Future<void> getAllUtenti() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/utente');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<UtenteModel> utenti = [];
        for (var item in jsonData) {
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          utentiList = utenti;
        });
        await getAllProdottiOrderedByUtente();
      } else {
        throw Exception('Failed to load utenti from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching agenti data from API: $e');
    }
  }

  Future<void> getAllProdottiOrderedByUtente() async {
    for (var utente in utentiList) {
      await getAllProdottiForUtente(utente.id!);
    }
  }

  Future<void> getAllProdottiForUtente(String utenteId) async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/relazioneUtentiProdotti/utente/$utenteId');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<RelazioneUtentiProdottiModel> relazioni = [];
        for (var item in jsonData) {
          relazioni.add(RelazioneUtentiProdottiModel.fromJson(item));
        }
        setState(() {
          prodottiPerUtenteMap[utenteId] = relazioni;
        });
      } else {
        throw Exception('Failed to load preventivi data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching preventivi data from API for utente $utenteId: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Prodotti assegnati agli utenti',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
        elevation: 0,
      ),
      body: utentiList.isEmpty
          ? Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: utentiList.length,
        itemBuilder: (context, index) {
          UtenteModel utente = utentiList[index];
          List<RelazioneUtentiProdottiModel> relazioni = prodottiPerUtenteMap[utente.id!]?? [];

          return Center(
            child: Container(
              width: MediaQuery.of(context).size.width / 2, // Set the width to half of the screen
              child: Card(
                margin: EdgeInsets.all(16),
                color: Colors.grey.shade300,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Set the mainAxisSize to min to center the content vertically
                  children: [
                    ListTile(
                      title: Center( // Center the title horizontally
                        child: Text(
                          'Utente: ${utente.nomeCompleto()}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      onTap: () {
                        _handleRowTap(utente);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 16),
                      child: Center( // Center the text horizontally
                        child: Text(
                          'Numero di prodotti: ${relazioni.length}',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleRowTap(UtenteModel utente) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DettaglioStoricoMerceUtentePage(utente: utente),
      ),
    );
  }
}