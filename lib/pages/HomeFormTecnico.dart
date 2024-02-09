import 'package:flutter/material.dart';

import 'InterventoTecnicoForm.dart';
import 'SopralluogoTecnicoForm.dart';

class HomeFormTecnico extends StatefulWidget {
  const HomeFormTecnico({super.key});

  @override
  _HomeFormTecnicoState createState() => _HomeFormTecnicoState();
}


class _HomeFormTecnicoState extends State<HomeFormTecnico>{


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('F.E.M.A.',
        style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,

      ),
      body: Padding(
        padding: const EdgeInsets.all(60.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: MediaQuery.of(context).size.width * 0.35,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context, MaterialPageRoute(builder:(context) => const InterventoTecnicoForm()),
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
                      context, MaterialPageRoute(builder:(context) => const SopralluogoTecnicoForm()),
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
                          Icons.search,
                          size: 75,
                          color: Colors.white,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Sopralluogo',
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
            const Text(
              'Agenda',
              style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
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
            ),
          ],
        ),
      ),
    );
    throw UnimplementedError();
  }
}