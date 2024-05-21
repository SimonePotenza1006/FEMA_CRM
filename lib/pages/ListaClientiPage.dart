import 'package:flutter/material.dart';
import '../databaseHandler/DbHelper.dart';
import '../model/ClienteModel.dart';
import 'DettaglioClientePage.dart';
import 'CreazioneClientePage.dart';

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

  @override
  void initState() {
    dbHelper = DbHelper();
    init();
    super.initState();
  }

  Future<void> init() async {
    print("Tiro giù tutti i clienti");
    allClienti = await dbHelper?.getAllClienti() ?? [];
    print("Numero totale di clienti: ${allClienti.length}");
    setState(() {
      filteredClienti = allClienti;
      isLoading = false;
    });
  }



  void filterClienti(String query) {
    setState(() {
      filteredClienti = allClienti.where((cliente) {
        final denominazione = cliente.denominazione?.toLowerCase();
        final codice_fiscale = cliente.codice_fiscale?.toLowerCase();
        final partita_iva = cliente.partita_iva?.toLowerCase();
        final telefono = cliente.telefono?.toLowerCase();
        final cellulare = cliente.cellulare?.toLowerCase();
        final citta = cliente.citta?.toLowerCase();
        final email = cliente.email?.toLowerCase();
        final cap = cliente.cap?.toLowerCase();

        return denominazione!.contains(query.toLowerCase()) ||
            codice_fiscale!.contains(query.toLowerCase()) ||
            partita_iva!.contains(query.toLowerCase()) ||
            telefono!.contains(query.toLowerCase()) ||
            cellulare!.contains(query.toLowerCase()) ||
            citta!.contains(query.toLowerCase()) ||
            email!.contains(query.toLowerCase()) ||
            cap!.contains(query.toLowerCase());
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
              // Funzione per ricaricare la pagina
              setState(() {});
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      color: Colors.white.withOpacity(0.4),
      child: ListTile(
        minLeadingWidth: 12,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DettaglioClientePage(cliente: cliente)),
          );
        },
        leading: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[Icon(Icons.account_circle_rounded)],
        ),
        trailing: Text('Id. ${cliente.id}'),
        title: Text(
          '${cliente.denominazione}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Codice Fiscale: ${cliente.codice_fiscale}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
