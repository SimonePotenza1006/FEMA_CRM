import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../databaseHandler/DbHelper.dart';
import '../model/CredenzialiClienteModel.dart';
import 'DettaglioCredenzialiPage.dart';

class ListaCredenzialiPage extends StatefulWidget {
  const ListaCredenzialiPage({Key? key}) : super(key: key);

  @override
  _ListaCredenzialiPageState createState() => _ListaCredenzialiPageState();
}

class _ListaCredenzialiPageState extends State<ListaCredenzialiPage> {
  DbHelper? dbHelper;
  List<CredenzialiClienteModel> allCredenziali = [];
  List<CredenzialiClienteModel> filteredCredenziali = [];
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
    init();
    super.initState();
  }

  Future<void> init() async {
    try {
      var apiUrl = Uri.parse('$ipaddress2/api/credenziali');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<CredenzialiClienteModel> credenziali = [];
        for (var item in jsonData) {
          credenziali.add(CredenzialiClienteModel.fromJson(item));
        }
        setState(() {
          allCredenziali = credenziali;
          filteredCredenziali =
              allCredenziali; // Inizialmente, la lista filtrata è uguale a quella completa
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

  void filterCredenziali(String query) {
    setState(() {
      filteredCredenziali = allCredenziali.where((credenziale) {
        final utenteCognome = credenziale.utente?.cognome?.toLowerCase() ?? '';
        final utenteNome = credenziale.utente?.nome?.toLowerCase() ?? '';
        final cliente = credenziale.cliente?.denominazione?.toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();
        return utenteCognome.contains(searchQuery) ||
            utenteNome.contains(searchQuery) ||
            cliente.contains(searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: !isSearching
            ? Text('Lista credenziali', style: TextStyle(color: Colors.white))
            : TextField(
                controller: searchController,
                onChanged: filterCredenziali,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Cerca per nome e cognome',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
              ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          isSearching
              ? IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      this.isSearching = false;
                      this.searchController.clear();
                      this.filteredCredenziali = allCredenziali;
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      this.isSearching = true;
                    });
                  },
                ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: filteredCredenziali.length,
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      final credenziale = filteredCredenziali[index];
                      return buildViewCredenziali(credenziale);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildViewCredenziali(CredenzialiClienteModel credenziale) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      color: Colors.white.withOpacity(0.9),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DettaglioCredenzialiPage(credenziale: credenziale)),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2), // Colore di sfondo dell'icona
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lock_person, color: Colors.red),
        ),
        trailing: Text(
          'Id. ${credenziale.id}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        title: Text(
          '${credenziale.cliente?.denominazione}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Descrizione: ${credenziale.descrizione}\nUtente: ${credenziale.utente?.cognome}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    );

  }
}
