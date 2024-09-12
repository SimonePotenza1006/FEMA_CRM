import 'package:fema_crm/model/UtenteModel.dart';
import 'package:flutter/material.dart';

import 'ControlloAccessiApplicazionePage.dart';
import 'CreazioneNuovaCartaPage.dart';
import 'CreazioneNuovoUtentePage.dart';
import 'CreazioneNuovoVeicoloPage.dart';
import 'ListaUtentiPage.dart';
import 'ReportSpeseVeicoloPage.dart';
import 'StoricoMerciUtentiPage.dart';

class ImpostazioniPage extends StatefulWidget {
  final UtenteModel userData;

  const ImpostazioniPage({Key? key, required this.userData}) : super(key: key);

  @override
  _ImpostazioniPageState createState() => _ImpostazioniPageState();
}

class _ImpostazioniPageState extends State<ImpostazioniPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => HomeFormAmministrazione(userData: widget.userData)),
            // );
          },
        ),
        title: const Text('Impostazioni', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10),
                buildMenuButton(
                  icon: Icons.person_add_alt_1,
                  text: 'Crea nuovo utente',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreazioneNuovoUtentePage()),
                    );
                  },
                ),
                SizedBox(height: 10),
                buildMenuButton(
                  icon: Icons.add_card_outlined,
                  text: 'Aggiungi carta',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreazioneNuovaCartaPage()),
                    );
                  },
                ),
                SizedBox(height: 10),
                if(widget.userData.cognome! == "Mazzei" || widget.userData.cognome! == "Chiriatti")
                  buildMenuButton(
                    icon: Icons.access_time,
                    text: 'Controllo accessi applicazione',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ControlloAccessiApplicazionePage()),
                      );
                    },
                  ),
                SizedBox(height:10),
                if(widget.userData.cognome! == "Mazzei" || widget.userData.cognome! == "Chiriatti")
                  buildMenuButton(
                      icon: Icons.ballot_outlined,
                      text: 'Storico merci degli utenti',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StoricoMerciUtentiPage()),
                        );
                      }),
                SizedBox(height: 10),
                if(widget.userData.cognome! == "Mazzei" || widget.userData.cognome! == "Chiriatti")
                  buildMenuButton(
                    icon: Icons.phonelink_lock_outlined,
                    text: 'Credenziali utenti',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ListaUtentiPage()),
                      );
                    },
                  ),
                SizedBox(height: 10),
                if(widget.userData.cognome! == "Mazzei" || widget.userData.cognome! == "Chiriatti")
                  buildMenuButton(
                    icon: Icons.monetization_on_outlined,
                    text: 'Report spese su veicolo',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReportSpeseVeicoloPage()),
                      );
                    },
                  ),
              ],
            ),
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
