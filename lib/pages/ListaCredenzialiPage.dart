import 'package:flutter/material.dart';

import '../databaseHandler/DbHelper.dart';
import '../model/CredenzialiClienteModel.dart';
import 'DettaglioCredenzialiPage.dart';

class ListaCredenzialiPage extends StatefulWidget {
  const ListaCredenzialiPage({super.key});

  @override
  _ListaCredenzialiPageState createState() => _ListaCredenzialiPageState();
}

class _ListaCredenzialiPageState extends State<ListaCredenzialiPage>{
  DbHelper? dbHelper;
  List<CredenzialiClienteModel> allCredenziali = [];
  bool isLoading = true;

  @override
  void initState(){
    dbHelper = DbHelper();
    init();
    super.initState();
  }

  Future<void> init() async {
    print('Tiro giù tutte le credenziali');
    //allCredenziali = await dbHelper?.getAllCredenziali() ?? [];
    print('Numero totale di credenziali: ${allCredenziali.length}');
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lista credenziali',
          style: TextStyle(color: Colors.white)
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: (){
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => DettaglioCredenzialiPage(credenziali : credenziali))
              //)
            },
          ),
        ],
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
          itemCount: allCredenziali.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final credenziale = allCredenziali[index];
            return buildViewCredenziali(credenziale);
          }),
    );
  }


  Widget buildViewCredenziali(CredenzialiClienteModel credenziale){
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      color: Colors.white.withOpacity(0.4),
      child: ListTile(
        minLeadingWidth: 12,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
        onTap: (){
          Navigator.push(
              context,
              MaterialPageRoute(
              builder: (context) => DettaglioCredenzialiPage(credenziale : credenziale))
          );
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
          'Utente incaricato: ${credenziale.utente?.cognome}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}