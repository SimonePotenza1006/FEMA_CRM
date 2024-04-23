import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/UtenteModel.dart';
import 'DettaglioUtentePage.dart';

class ListaUtentiPage extends StatefulWidget{
  const ListaUtentiPage({Key? key}) : super(key: key);

  @override
  _ListaUtentiPageState createState() => _ListaUtentiPageState();
}

class _ListaUtentiPageState extends State<ListaUtentiPage>{
  List<UtenteModel> allUtenti = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getAllUtenti();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Lista utenti', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                    child: ListView.separated(
                      itemCount: allUtenti.length,
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, index){
                        final utente = allUtenti[index];
                        return buildViewUtenti(utente);
                      },
                    ))
              ],
      )
    );
  }
  
  
  Future<void> getAllUtenti() async{
    try{
      var apiUrl = Uri.parse('${ipaddress}/api/utente');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<UtenteModel> utenti = [];
        for(var item in jsonData){
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          allUtenti = utenti;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      // Gestione degli errori
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

  Widget buildViewUtenti(UtenteModel utente) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      color: Colors.white.withOpacity(0.4),
      child: ListTile(
        minLeadingWidth: 12,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      DettaglioUtentePage(utente: utente)));
        },
        leading: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[Icon(Icons.lock_person)],
        ),
        trailing: Text('Id. ${utente.id}'),
        title: Text(
          '${utente.nome} ${utente.cognome}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Ruolo: ${utente.ruolo?.descrizione}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}