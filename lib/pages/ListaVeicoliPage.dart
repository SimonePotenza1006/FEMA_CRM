import 'package:fema_crm/pages/CreazioneNuovoVeicoloPage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/VeicoloModel.dart';
import 'DettaglioVeicoloPage.dart';

class ListaVeicoliPage extends StatefulWidget {
  const ListaVeicoliPage({Key? key}) : super(key : key);

  @override
  _ListaVeicoliPageState createState() => _ListaVeicoliPageState();
}

class _ListaVeicoliPageState extends State<ListaVeicoliPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  List<VeicoloModel> allVeicoli = [];

  @override
  void initState() {
    super.initState();
    getAllVeicoli();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lista veicoli",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
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
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CreazioneNuovoVeicoloPage()),
              );
            },
          ),
        ],
      ),
      body: allVeicoli.isEmpty
          ? Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
          itemCount: allVeicoli.length,
          itemBuilder: (context, index){
            VeicoloModel veicolo = allVeicoli[index];
            return
              Center(
              child: Container(
                width: MediaQuery.of(context).size.width / 2,
                child: Card(
                  margin: EdgeInsets.all(16),
                  color: Colors.grey.shade300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Center(
                          child: Text(
                            '${veicolo.descrizione}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        onTap: (){
                          _handleRowTap(veicolo);
                        },
                      )
                    ],
                  ),
                ),
              ),
            );
          })
    );
  }

  Future<void> getAllVeicoli() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/veicolo');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<VeicoloModel> veicoli = [];
        for (var item in jsonData) {
          veicoli.add(VeicoloModel.fromJson(item));
        }
        setState(() {
          allVeicoli = veicoli;
        });
      } else {
        throw Exception('Failed to load utenti data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching agenti data from API: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Connection Error'),
            content: Text('Unable to load data from API. Please check your internet connection and try again.'),
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

  void _handleRowTap(VeicoloModel veicolo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DettaglioVeicoloPage(veicolo: veicolo),
      ),
    );
  }
}