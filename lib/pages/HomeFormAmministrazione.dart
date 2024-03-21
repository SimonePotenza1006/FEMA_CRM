import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fema_crm/pages/LogisticaPreventiviHomepage.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../model/CommissioneModel.dart';
import '../model/InterventoModel.dart';
import '../model/UtenteModel.dart';
import 'DettaglioCommissioneAmministrazionePage.dart';
import 'DettaglioInterventoByTecnicoPage.dart';
import 'ListaClientiPage.dart';
import 'ListaCredenzialiPage.dart';
import 'ListaInterventiPage.dart';
import 'ListiniPage.dart';
import 'MagazzinoPage.dart';
import 'MenuCommissioniPage.dart';
import 'RegistroCassaPage.dart';

class HomeFormAmministrazione extends StatefulWidget {
  final UtenteModel userData;

  const HomeFormAmministrazione({Key? key, required this.userData}) : super(key: key);

  @override
  _HomeFormAmministrazioneState createState() => _HomeFormAmministrazioneState();
}

class _HomeFormAmministrazioneState extends State<HomeFormAmministrazione> {

  Future<List<CommissioneModel>> getAllCommissioniByUtente(String userId) async {
    try {
      String userId = widget.userData!.id.toString();
      http.Response response = await http.get(Uri.parse('http://192.168.1.52:8080/api/commissione/utente/$userId'));
      if (response.statusCode == 200){
        var responseData = json.decode(response.body);
        List<CommissioneModel> allCommissioniByUtente = [];
        for (var item in responseData){
          CommissioneModel commissione = CommissioneModel.fromJson(item);
          if(commissione.concluso == false) {
            allCommissioniByUtente.add(commissione);
          }
        }
        return allCommissioniByUtente;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching commissioni: $e');
      return [];
    }
  }

  Future<List<InterventoModel>> getAllInterventiByUtente(String userId) async {
    try {
      String userId = widget.userData!.id.toString();
      http.Response response = await http.get(Uri.parse('http://192.168.1.52:8080/api/intervento/utente/$userId'));
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        List<InterventoModel> allInterventiByUtente = [];
        for (var interventoJson in responseData) {
          InterventoModel intervento = InterventoModel.fromJson(interventoJson);
          // Aggiungi il filtro per interventi non conclusi
          if (intervento.concluso == false) {
            allInterventiByUtente.add(intervento);
          }
        }
        return allInterventiByUtente;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching interventi: $e');
      return [];
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'F.E.M.A. Amministrazione',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginForm()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Bentornato ${widget.userData.nome.toString()}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                buildMenuButton(
                  icon: Icons.build,
                  text: 'Lista Interventi',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ListaInterventiPage()),
                    );
                  },
                ),
                SizedBox(height: 5),
                buildMenuButton(
                  icon: Icons.class_outlined,
                  text: 'Commissioni',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MenuCommissioniPage()),
                    );
                  },
                ),
                SizedBox(height: 5),
                buildMenuButton(
                  icon: Icons.do_disturb_rounded,
                  text: 'Credenziali',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ListaCredenzialiPage()),
                    );
                  },
                ),
                SizedBox(height: 5),
                buildMenuButton(
                  icon: Icons.contact_emergency_rounded,
                  text: 'Lista Clienti',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ListaClientiPage()),
                    );
                  },
                ),
                SizedBox(height: 5),
                buildMenuButton(
                  icon: Icons.warehouse_sharp,
                  text: 'Magazzino',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MagazzinoPage()),
                    );
                  },
                ),
                SizedBox(height: 5),
                buildMenuButton(
                  icon: Icons.euro_sharp,
                  text: 'Registro Cassa',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          RegistroCassaPage(userData: widget.userData)),
                    );
                  },
                ),
                SizedBox(height: 5),
                buildMenuButton(
                  icon: Icons.assignment_outlined,
                  text: 'Listini e Interventi',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ListiniPage()),
                    );
                  },
                ),
                SizedBox(height: 5),
                buildMenuButton(
                  icon: Icons.work_history_outlined,
                  text: 'DDT',
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const DDTPage()),
                    // );
                  },
                ),
                SizedBox(height: 5),
                buildMenuButton(
                  icon: Icons.business_center_outlined,
                  text: 'Logistica e Preventivi',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          LogisticaPreventiviHomepage(
                              userData: widget.userData)),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50.0),
                      Center(
                        child: Text(
                          'Agenda Interventi',
                          style: TextStyle(
                              fontSize: 30.0, fontWeight: FontWeight.bold),
                        ),
                      ),

                      const SizedBox(height: 10.0),
                    ],
                  ),
                ),
                FutureBuilder<List<InterventoModel>>(
                  future: getAllInterventiByUtente(
                      widget.userData!.id.toString()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Errore: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      List<InterventoModel> interventi = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: interventi.length,
                        itemBuilder: (context, index) {
                          InterventoModel intervento = interventi[index];
                          return ListTile(
                            title: Text('${intervento.cliente?.denominazione
                                .toString()}'),
                            subtitle: Text(intervento.descrizione ?? ''),
                            trailing: Text(
                              // Formatta la data secondo il tuo formato desiderato
                              intervento.data != null
                                  ? '${intervento.data!.day}/${intervento.data!
                                  .month}/${intervento.data!.year}'
                                  : 'Data non disponibile',
                              style: TextStyle(
                                  fontSize: 16), // Stile opzionale per la data
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DettaglioInterventoByTecnicoPage(
                                          intervento: intervento),
                                ),
                              );
                            },
                          );
                        },
                      );
                    } else {
                      return Center(child: Text('Nessun intervento trovato'));
                    }
                  },
                ),
                const SizedBox(height: 50.0),
                Center(
                  child: Text(
                    'Agenda commissioni',
                    style: TextStyle(
                        fontSize: 30.0, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20.0),
                FutureBuilder<List<CommissioneModel>>(
                  future: getAllCommissioniByUtente(
                      widget.userData!.id.toString()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Errore: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      List<CommissioneModel> commissioni = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: commissioni.length,
                        itemBuilder: (context, index) {
                          CommissioneModel commissione = commissioni[index];
                          return ListTile(
                            title: Text(
                                '${commissione.descrizione.toString()}'),
                            subtitle: Text(commissione.note ?? ''),
                            trailing: Text(
                              // Formatta la data secondo il tuo formato desiderato
                              commissione.data != null
                                  ? '${commissione.data!.day}/${commissione
                                  .data!.month}/${commissione.data!
                                  .year} ${commissione.data!.hour}:${commissione
                                  .data!.minute.toStringAsFixed(1)}'
                                  : 'Data non disponibile',
                              style: TextStyle(
                                  fontSize: 16), // Stile opzionale per la data
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DettaglioCommissioneAmministrazionePage(commissione: commissione),
                                ),
                              );
                            },
                          );
                        },
                      );
                    } else {
                      return Center(child: Text('Nessun intervento trovato'));
                    }
                  },
                ),
              ],
            ),

          )
      ),
    );
  }


  Widget buildMenuButton({required IconData icon, required String text, required VoidCallback onPressed}) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 10), // Spazio tra i pulsanti
          SizedBox(
            width: 500,
            height: 60,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Text(
                    text,
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ],
              ),

            ),
          ),
        ],

      ),
    );
  }
}
