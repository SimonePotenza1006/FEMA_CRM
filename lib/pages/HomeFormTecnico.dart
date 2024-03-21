import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';
import '../model/CommissioneModel.dart';
import '../model/InterventoModel.dart';
import '../model/UtenteModel.dart';
import 'DettaglioCommissioneTecnicoPage.dart';
import 'DettaglioInterventoByTecnicoPage.dart';
import 'InterventoTecnicoForm.dart';
import 'InizializzazionePreventivoByTecnicoPage.dart';
import 'ListaPreventiviTecnicoPage.dart';

class HomeFormTecnico extends StatefulWidget {
  final UtenteModel? userData;

  const HomeFormTecnico({Key? key, required this.userData}) : super(key: key);

  @override
  _HomeFormTecnicoState createState() => _HomeFormTecnicoState();
}

class _HomeFormTecnicoState extends State<HomeFormTecnico> {

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
        child: Column(
          mainAxisSize: MainAxisSize.min, // Imposta grandezza minima per la colonna
          children: [
            Padding(
              padding: const EdgeInsets.all(60.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      "Bentornato ${widget.userData!.nome.toString()}!",
                      textAlign: TextAlign.center, // Centra il testo
                      style: TextStyle(
                        fontSize: 24, // Imposta la dimensione del testo
                        fontWeight: FontWeight.bold, // Imposta il grassetto
                      ),
                    ),
                  ),
                  SizedBox(height: 40,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        height: MediaQuery.of(context).size.width * 0.35,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context, MaterialPageRoute(builder:(context) => InterventoTecnicoForm(userData: widget.userData!)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35.0),
                              ),
                              shadowColor: Colors.black,
                              elevation: 15
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.build,
                                size: 75,
                                color: Colors.white,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Intervento',
                                style: TextStyle(color: Colors.white,
                                    fontSize: 25),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        height: MediaQuery.of(context).size.width * 0.35,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder:(context) => InizializzazionePreventivoByTecnicoPage(utente : widget.userData!)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35.0),
                              ),
                              shadowColor: Colors.black,
                              elevation: 15
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 75,
                                color: Colors.white,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Registrazione preventivo',
                                style: TextStyle(color: Colors.white,
                                    fontSize: 25),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        height: MediaQuery.of(context).size.width * 0.35,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context, MaterialPageRoute(builder:(context) => ListaPreventiviTecnicoPage(utente : widget.userData!)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35.0),
                              ),
                              shadowColor: Colors.black,
                              elevation: 15
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.badge_outlined,
                                size: 75,
                                color: Colors.white,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'I tuoi preventivi',
                                style: TextStyle(color: Colors.white,
                                    fontSize: 25),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50.0),
                  Center(
                    child: Text(
                      'Agenda Interventi',
                      style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 10.0),
                ],
              ),
            ),
            FutureBuilder<List<InterventoModel>>(
              future: getAllInterventiByUtente(widget.userData!.id.toString()),
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
                        title: Text('${intervento.cliente?.denominazione.toString()}'),
                        subtitle: Text(intervento.descrizione ?? ''),
                        trailing: Text(
                          // Formatta la data secondo il tuo formato desiderato
                          intervento.data != null
                              ? '${intervento.data!.day}/${intervento.data!.month}/${intervento.data!.year}'
                              : 'Data non disponibile',
                          style: TextStyle(fontSize: 16), // Stile opzionale per la data
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DettaglioInterventoByTecnicoPage(intervento: intervento),
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
            const Text(
              'Agenda Commissioni',
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            FutureBuilder<List<CommissioneModel>>(
              future: getAllCommissioniByUtente(widget.userData!.id.toString()),
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
                        title: Text('${commissione.descrizione.toString()}'),
                        subtitle: Text(commissione.note ?? ''),
                        trailing: Text(
                          // Formatta la data secondo il tuo formato desiderato
                          commissione.data != null
                              ? '${commissione.data!.day}/${commissione.data!.month}/${commissione.data!.year} ${commissione.data!.hour}:${commissione.data!.minute.toStringAsFixed(1)}'
                              : 'Data non disponibile',
                          style: TextStyle(fontSize: 16), // Stile opzionale per la data
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DettaglioCommissioneTecnicoPage(commissione: commissione),
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
      ),
    );
  }
}
