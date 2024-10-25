import 'package:fema_crm/pages/CompilazioneRapportinoPage.dart';
import 'package:flutter/material.dart';

import '../model/InterventoModel.dart';
import '../model/UtenteModel.dart';
import 'AggiuntaFotoRapportinoPage.dart';
import 'ListaSopralluoghiTecnicoPage.dart';
import 'SopralluogoTecnicoForm.dart';

class SceltaRapportinoPage extends StatefulWidget{
  final UtenteModel utente;
  final InterventoModel intervento;

  SceltaRapportinoPage ({Key? key, required this.utente, required this.intervento}) : super(key : key);

  @override
  _SceltaRapportinoPageState createState() =>
      _SceltaRapportinoPageState();
}

class _SceltaRapportinoPageState extends State<SceltaRapportinoPage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RAPPORTINO', style: TextStyle(color: Colors.white)),
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
                  icon: Icons.camera,
                  text: 'SCATTA FOTO RAPPORTINO',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AggiuntaFotoRapportinoPage(utente: widget.utente, intervento: widget.intervento)),
                    );
                  },
                ),
                SizedBox(height: 20),
                if(widget.utente.id!.toString() == "9" || widget.utente.id!.toString() == "4" || widget.utente.id!.toString() == "5")
                  buildMenuButton(
                    icon: Icons.edit,
                    text: 'COMPILA RAPPORTINO',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CompilazioneRapportinoPage(intervento: widget.intervento)),
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

  Widget buildMenuButton(
      {required IconData icon, required String text, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade400, Colors.red.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 40,
              ),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}