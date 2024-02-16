import 'package:flutter/material.dart';

import 'ListaClientiPage.dart';
import 'ListaCredenzialiPage.dart';
import 'ListaInterventiPage.dart';
import 'ListiniPage.dart';
import 'MagazzinoPage.dart';
import 'RegistroCassaPage.dart';

class HomeFormAmministrazione extends StatefulWidget {
  const HomeFormAmministrazione({Key? key}) : super(key: key);

  @override
  _HomeFormAmministrazioneState createState() => _HomeFormAmministrazioneState();
}

class _HomeFormAmministrazioneState extends State<HomeFormAmministrazione> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'F.E.M.A. Amministrazione', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.30,
                      height: MediaQuery
                          .of(context)
                          .size
                          .width * 0.30,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (
                                context) => const ListaInterventiPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35.0),
                          ),
                          shadowColor: Colors.black,
                          elevation: 15,
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
                              'Lista Interventi',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 25),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.30,
                      height: MediaQuery
                          .of(context)
                          .size
                          .width * 0.30,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (
                                context) => const ListaCredenzialiPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35.0),
                          ),
                          shadowColor: Colors.black,
                          elevation: 15,
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.do_disturb_rounded,
                              size: 75,
                              color: Colors.white,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Credenziali',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 25),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.30,
                      height: MediaQuery
                          .of(context)
                          .size
                          .width * 0.30,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ListaClientiPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35.0),
                          ),
                          shadowColor: Colors.black,
                          elevation: 15,
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.contact_emergency_rounded,
                              size: 75,
                              color: Colors.white,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Lista Clienti',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 25),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.30,
                      height: MediaQuery
                          .of(context)
                          .size
                          .width * 0.30,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MagazzinoPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35.0),
                          ),
                          shadowColor: Colors.black,
                          elevation: 15,
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.warehouse_sharp,
                              size: 75,
                              color: Colors.white,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Magazzino',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 25),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.30,
                      height: MediaQuery
                          .of(context)
                          .size
                          .width * 0.30,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (
                                context) => const RegistroCassaPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35.0),
                          ),
                          shadowColor: Colors.black,
                          elevation: 15,
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.euro_sharp,
                              size: 75,
                              color: Colors.white,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Registro Cassa',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 25),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.30,
                      height: MediaQuery
                          .of(context)
                          .size
                          .width * 0.30,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (
                                context) => const ListiniPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35.0),
                          ),
                          shadowColor: Colors.black,
                          elevation: 15,
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
                              'Listini e interventi specifici',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 25),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                const Text(
                  'Agenda',
                  style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20.0),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 10, // Numero di elementi nell'agenda
                  itemBuilder: (context, index) {
                    // Costruisci un elemento dell'agenda
                    return ListTile(
                      title: Text('Evento $index'),
                      subtitle: Text('Dettagli evento $index'),
                      trailing: const Icon(Icons.event),
                      onTap: () {
                        // Azione da eseguire quando un elemento dell'agenda viene premuto
                      },
                    );
                  },
                ),
              ]
          ),
        ),
      ),
    );
  }
}



