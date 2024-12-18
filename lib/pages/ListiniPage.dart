import 'package:fema_crm/databaseHandler/DbHelper.dart';
import 'package:fema_crm/pages/DettaglioTipologiePage.dart';
import 'package:flutter/material.dart';

import '../model/TipologiaInterventoModel.dart';

class ListiniPage extends StatefulWidget {
  const ListiniPage({super.key});

  @override
  _ListiniPageState createState() => _ListiniPageState();
}

class _ListiniPageState extends State<ListiniPage> {
  DbHelper? dbHelper;
  List<TipologiaInterventoModel> allTipologie = [];
  bool isLoading = true;
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = '192.128.1.248:8090';
  String ipaddressProva2 = '192.168.1.198:8095';

  @override
  void initState() {
    dbHelper = DbHelper();
    init();
    super.initState();
  }

  Future<void> init() async {
    print("Tiro giù tutte le tipologie");
    allTipologie = await dbHelper?.getAllTipologieIntervento() ?? [];
    print("Numero totale di tipologie: ${allTipologie.length}");
    setState(() {
      isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Management Listini',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: allTipologie.length,
              itemBuilder: (content, index) {
                final tipologia = allTipologie[index];
                return buildViewTipologie(tipologia);
              }),
    );
  }

  Widget buildViewTipologie(TipologiaInterventoModel tipologia) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      color: Colors.white.withOpacity(0.4),
      child: ListTile(
        minLeadingWidth: 12,
        visualDensity: const VisualDensity(horizontal: 0, vertical: 4),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      DettaglioTipologiePage(tipologia: tipologia)));
        },
        leading: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.settings_outlined,
              size: 40,
            )
          ],
        ),
        title: Text(
          '${tipologia.descrizione}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
        ),
      ),
    );
  }
}
