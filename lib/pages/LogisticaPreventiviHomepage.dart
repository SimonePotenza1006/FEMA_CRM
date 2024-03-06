import 'package:fema_crm/model/UtenteModel.dart';
import 'package:flutter/material.dart';

import 'RegistrazioneAgentePage.dart';
import 'RegistrazioneAziendaPage.dart';

class LogisticaPreventiviHomepage extends StatefulWidget {
  final UtenteModel userData;

  const LogisticaPreventiviHomepage({Key? key, required this.userData}) : super(key: key);

  @override
  _LogisticaPreventiviHomepageState createState() => _LogisticaPreventiviHomepageState();
}

class _LogisticaPreventiviHomepageState extends State<LogisticaPreventiviHomepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logistica e Preventivi', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildMenuButton(
                icon: Icons.business_outlined,
                text: 'Registra Azienda',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegistrazioneAziendaPage()),
                  );
                },
              ),
              SizedBox(height: 10),
              buildMenuButton(
                icon: Icons.person_add_alt_1_outlined,
                text: 'Registra Agente',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegistrazioneAgentePage()),
                  );
                },
              ),
              SizedBox(height: 10),
              buildMenuButton(
                icon: Icons.playlist_add_outlined,
                text: 'Registra Preventivo',
                onPressed: () {

                },
              ),
              SizedBox(height: 10),
              buildMenuButton(
                icon: Icons.bar_chart_outlined,
                text: 'Report Preventivi',
                onPressed: () {

                },
              ),
              SizedBox(height: 10),
              buildMenuButton(
                icon: Icons.article_outlined,
                text: 'I Tuoi Preventivi',
                onPressed: () {

                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuButton({required IconData icon, required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          primary: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Icon(
          icon,
          color: Colors.white,
          size: 50,
        ),
        label: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
      ),
    );
  }
}
