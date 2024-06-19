import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../model/OrdinePerInterventoModel.dart';
import '../model/UtenteModel.dart';
import 'FormOrdineFornitorePage.dart';
import 'ReportOrdineFornitorePage.dart';
import 'ReportOrdiniPerUtentePage.dart';

class MenuOrdiniFornitorePage extends StatefulWidget {
  final UtenteModel utente;

  const MenuOrdiniFornitorePage({Key? key, required this.utente}) : super(key: key);

  @override
  _MenuOrdiniFornitorePageState createState() => _MenuOrdiniFornitorePageState();
}

class _MenuOrdiniFornitorePageState extends State<MenuOrdiniFornitorePage> {
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  List<OrdinePerInterventoModel> allOrdini = [];

  @override
  void initState() {
    super.initState();
    getAllOrdini();
    _scheduleGetAllOrdini();
  }

  Future<void> getAllOrdini() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/ordine');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<OrdinePerInterventoModel> ordini = [];
        for (var item in jsonData) {
          var ordine = OrdinePerInterventoModel.fromJson(item);
          if (ordine.presa_visione == false && ordine.ordinato == false && ordine.arrivato == false && ordine.consegnato == false) {
            ordini.add(ordine);
          }
        }
        setState(() {
          allOrdini = ordini;
        });
      }
    } catch (e) {
      print('Errore getAllOrdini: $e');
    }
  }

  void _scheduleGetAllOrdini() {
    Timer.periodic(Duration(minutes: 10), (timer) {
      getAllOrdini();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordini al fornitore', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Add this line
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10),
                buildButton(
                  icon: Icons.playlist_add_outlined,
                  text: 'Nuovo ordine',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FormOrdineFornitorePage(utente: widget.utente)),
                    );
                  },
                ),
                SizedBox(height: 10),
                buildButtonWithBadge(
                  icon: Icons.bar_chart_outlined,
                  text: 'Report Ordini',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReportOrdineFornitorePage(utente: widget.utente)),
                    );
                  },
                ),
                SizedBox(height: 10),
                buildButton(
                  icon: Icons.folder_shared_outlined,
                  text: 'Report ordini per utente',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReportOrdiniPerUtentePage(utente: widget.utente)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButton({required IconData icon, required String text, required VoidCallback onPressed}) {
    double textSize = 20;

    return Flexible( // Replace Expanded with Flexible
      child: Card(
        color: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 10,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: textSize,
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: textSize,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButtonWithBadge({required IconData icon, required String text, required VoidCallback onPressed}) {
    double textSize = 20;

    return Card(
      color: Colors.red,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 10,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.only(top : 30.0, bottom: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: textSize,
              ),
              SizedBox(width: 10.0),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: textSize,
                ),
              ),
              if (allOrdini.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    padding: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.red[900],
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      allOrdini.length.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}