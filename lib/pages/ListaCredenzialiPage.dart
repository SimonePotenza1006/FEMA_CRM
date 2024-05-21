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

  @override
  void initState() {
    dbHelper = DbHelper();
    init();
    super.initState();
  }

  Future<void> init() async {
    print('Tiro giù tutte le credenziali');
    try {
      var apiUrl = Uri.parse('${ipaddress}/api/credenziali');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
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
                      DettaglioCredenzialiPage(credenziale: credenziale)));
        },
        leading: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[Icon(Icons.lock_person)],
        ),
        trailing: Text('Id. ${credenziale.id}'),
        title: Text(
          '${credenziale.cliente?.denominazione}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Descrizione: ${credenziale.credenziali} , utente incaricato: ${credenziale.utente?.cognome}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
