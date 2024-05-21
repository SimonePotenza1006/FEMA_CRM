import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/RelazioneUtentiProdottiModel.dart';
import '../model/UtenteModel.dart';
import 'AggiuntaMerceStoricoUtentePage.dart';
import 'PDFStoricoMerceUtentePage.dart';

class DettaglioStoricoMerceUtentePage extends StatefulWidget{
  final UtenteModel utente;

  const DettaglioStoricoMerceUtentePage({Key? key, required this.utente}) : super(key : key);

  @override
  _DettaglioStoricoMerceUtentePageState createState() => _DettaglioStoricoMerceUtentePageState();
}

class _DettaglioStoricoMerceUtentePageState extends State<DettaglioStoricoMerceUtentePage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  List<RelazioneUtentiProdottiModel> allRelazioni = [];

  @override
  void initState(){
    super.initState();
    getRelazioni();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Storico merce ${widget.utente.nomeCompleto()}',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AggiuntaMerceStoricoUtentePage(utente: widget.utente)),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_downward_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PDFStoricoMerceUtentePage(utente: widget.utente, merce: allRelazioni)),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: ListView.builder(
          itemCount: allRelazioni.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(
                  allRelazioni[index].prodotto?.descrizione?.substring(0, 40)?? 'N/A',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Materiale: ${allRelazioni[index].materiale?? 'N/A'}'),
                    Text(
                      'DDT: ${allRelazioni[index].ddt?.id?? 'N/A'}, data: ${DateFormat('dd/MM/yyyy').format(allRelazioni[index].data_creazione!)}',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> getRelazioni() async {
    try{
      var apiUrl = Uri.parse(
        '$ipaddress/api/relazioneUtentiProdotti/utente/${widget.utente.id}'
      );
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<RelazioneUtentiProdottiModel> relazioni = [];
        for(var item in jsonData){
          relazioni.add(RelazioneUtentiProdottiModel.fromJson(item));
        }
        setState(() {
          allRelazioni = relazioni;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Errore durante la chiamata all\'API: $e');
    }
  }



}