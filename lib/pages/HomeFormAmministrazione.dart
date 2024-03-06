import 'package:fema_crm/pages/LogisticaPreventiviHomepage.dart';
import 'package:flutter/material.dart';

import '../model/UtenteModel.dart';
import 'ListaClientiPage.dart';
import 'ListaCredenzialiPage.dart';
import 'ListaInterventiPage.dart';
import 'ListiniPage.dart';
import 'MagazzinoPage.dart';
import 'RegistroCassaPage.dart';

class HomeFormAmministrazione extends StatefulWidget {
  final UtenteModel userData;

  const HomeFormAmministrazione({Key? key, required this.userData}) : super(key: key);

  @override
  _HomeFormAmministrazioneState createState() => _HomeFormAmministrazioneState();
}

class _HomeFormAmministrazioneState extends State<HomeFormAmministrazione> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('F.E.M.A. Amministrazione', style: TextStyle(color: Colors.white)),
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
                    MaterialPageRoute(builder: (context) => const ListaInterventiPage()),
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
                    MaterialPageRoute(builder: (context) => const ListaCredenzialiPage()),
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
                    MaterialPageRoute(builder: (context) => const ListaClientiPage()),
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
                    MaterialPageRoute(builder: (context) => const MagazzinoPage()),
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
                    MaterialPageRoute(builder: (context) => RegistroCassaPage(userData: widget.userData)),
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
                    MaterialPageRoute(builder: (context) => const ListiniPage()),
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
                    MaterialPageRoute(builder: (context) => LogisticaPreventiviHomepage(userData: widget.userData)),
                  );
                },
              ),
              SizedBox(height: 20),
              Text(
                'Agenda',
                style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
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
            ],
          ),
        ),
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
