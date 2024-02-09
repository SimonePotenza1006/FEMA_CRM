import 'package:flutter/material.dart';
// necessario per codificare/decodificare dati JSON

import '../databaseHandler/DbHelper.dart';
import '../model/ClienteModel.dart';
import 'DettaglioClientePage.dart';

class ListaClientiPage extends StatefulWidget {
  const ListaClientiPage({super.key, Key? key1});

  @override
  _ListaClientiPageState createState() => _ListaClientiPageState();
}

class _ListaClientiPageState extends State<ListaClientiPage> {
  DbHelper? dbHelper;
  List<ClienteModel> allClienti = [];
  bool isLoading = true;

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
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lista Clienti',
          style: TextStyle(color: Colors.white)
      ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
          itemCount: allClienti.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final cliente = allClienti[index];
            return buildViewClienti(cliente);
          }),
    );
  }

  Widget buildViewClienti(ClienteModel cliente) {
    print(cliente.codice_fiscale);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      color: Colors.white.withOpacity(0.4),
      child: ListTile(
        minLeadingWidth: 12,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
        onTap: () {
          print(cliente.codice_fiscale);
          Navigator.push(
              context,
              MaterialPageRoute(
              builder: (context) => DettaglioClientePage(cliente: cliente),));
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

