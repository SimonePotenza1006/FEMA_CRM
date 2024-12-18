import 'dart:convert';

import 'package:flutter/material.dart';
import '../databaseHandler/DbHelper.dart';
import '../model/ClienteModel.dart';
import 'DettaglioClientePage.dart';
import 'CreazioneClientePage.dart';
import 'package:http/http.dart' as http;

class ListaClientiPage extends StatefulWidget {
  const ListaClientiPage({Key? key}) : super(key: key);

  @override
  _ListaClientiPageState createState() => _ListaClientiPageState();
}

class _ListaClientiPageState extends State<ListaClientiPage> {
  DbHelper? dbHelper;
  List<ClienteModel> allClienti = [];
  List<ClienteModel> filteredClienti = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';

  @override
  void initState() {
    dbHelper = DbHelper();
    super.initState();
    getAllClienti();
  }

  Future<void> getAllClienti() async {
    try {
      final response = await http.get(Uri.parse('$ipaddress/api/cliente'));
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<ClienteModel> clienti = [];
        for (var item in jsonData) {
          clienti.add(ClienteModel.fromJson(item));
        }
        setState(() {
          allClienti = clienti;
          filteredClienti = clienti;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
    }
  }

  void filterClienti(String query) {
    setState(() {
      filteredClienti = allClienti.where((cliente) {
        final denominazione = cliente.denominazione?.toLowerCase() ?? '';
        final codice_fiscale = cliente.codice_fiscale?.toLowerCase() ?? '';
        final partita_iva = cliente.partita_iva?.toLowerCase() ?? '';
        final telefono = cliente.telefono?.toLowerCase() ?? '';
        final cellulare = cliente.cellulare?.toLowerCase() ?? '';
        final citta = cliente.citta?.toLowerCase() ?? '';
        final email = cliente.email?.toLowerCase() ?? '';
        final cap = cliente.cap?.toLowerCase() ?? '';

        return denominazione.contains(query.toLowerCase()) ||
            codice_fiscale.contains(query.toLowerCase()) ||
            partita_iva.contains(query.toLowerCase()) ||
            telefono.contains(query.toLowerCase()) ||
            cellulare.contains(query.toLowerCase()) ||
            citta.contains(query.toLowerCase()) ||
            email.contains(query.toLowerCase()) ||
            cap.contains(query.toLowerCase());
      }).toList();
    });
  }


  void startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  void stopSearch() {
    setState(() {
      isSearching = false;
      searchController.clear();
      filterClienti('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                onChanged: filterClienti,
                decoration: InputDecoration(
                  hintText: 'Cerca per denominazione cliente',
                  hintStyle: TextStyle(
                      color: Colors.white), // colore del testo dell'hint
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white),
              )
            : Text('Lista Clienti', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: isSearching
                ? Icon(Icons.cancel,
                    color: Colors.white) // colore dell'icona di cancellazione
                : Icon(Icons.search,
                    color: Colors.white), // colore dell'icona di ricerca
            onPressed: () {
              if (isSearching) {
                stopSearch();
              } else {
                startSearch();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.person_add_alt_1, size: 40, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreazioneClientePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.refresh, // Icona di ricarica, puoi scegliere un'altra icona se preferisci
              color: Colors.white,
            ),
            onPressed: () {
              getAllClienti();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: filteredClienti.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final cliente = filteredClienti[index];
                      return buildViewClienti(cliente);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildViewClienti(ClienteModel cliente) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Arrotondamento del bordo
      ),
      elevation: 5, // Aggiunge un'ombra per creare profondità
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Più spazio tra le card
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade300], // Aggiunge un gradiente di colore
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15), // Arrotondamento anche per il contenitore interno
        ),
        child: ListTile(
          minLeadingWidth: 20, // Aumenta la larghezza minima per maggiore spaziatura
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16), // Più padding interno
          visualDensity: const VisualDensity(horizontal: 0, vertical: -2), // Riduce leggermente la densità verticale
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DettaglioClientePage(cliente: cliente)),
            );
          },
          leading: CircleAvatar(
            radius: 25, // Aumenta la dimensione dell'icona
            backgroundColor: Colors.red, // Cambia il colore dello sfondo dell'icona
            child: Icon(Icons.account_circle_rounded, color: Colors.white, size: 30), // Icona più grande e bianca
          ),
          trailing: Text(
            'Id. ${cliente.id}, Codice Danea : ${cliente.cod_danea != null ? cliente.cod_danea : "N/A"}'.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black, // Colore più discreto per l'id
            ),
          ),
          title: Text(
            cliente.denominazione!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16, // Dimensione del testo leggermente più grande
            ),
          ),
          subtitle:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Codice Fiscale: ${cliente.codice_fiscale != null ? cliente.codice_fiscale! : 'Non inserito'}'.toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black // Colore del testo del sottotitolo
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Telefono: ${cliente.cellulare != null ? cliente.cellulare! : "Non inserito"}'.toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black // Colore del testo del sottotitolo
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}
