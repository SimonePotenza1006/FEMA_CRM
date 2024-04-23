import 'package:fema_crm/pages/MenuCommissioniPage.dart';
import 'package:fema_crm/pages/SopralluogoTecnicoForm.dart';
import 'package:flutter/material.dart';

import '../model/UtenteModel.dart';
import 'ListaClientiPage.dart';
import 'ReportSopralluoghiPage.dart';

class MenuSopralluoghiPage extends StatefulWidget {
  final UtenteModel utente;

  const MenuSopralluoghiPage ({Key? key, required this.utente}) : super(key:key);

  @override
  _MenuSopralluoghiPageState createState() => _MenuSopralluoghiPageState();
}

class _MenuSopralluoghiPageState extends State<MenuSopralluoghiPage>{


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sopralluoghi', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt_1, size: 40, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ListaClientiPage()),
              );
            },
          )
        ],
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
                  icon: Icons.playlist_add_outlined,
                  text: 'Registra sopralluogo',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SopralluogoTecnicoForm(utente: widget.utente)),
                    );
                  },
                ),
                SizedBox(height: 10),
                buildMenuButton(
                  icon: Icons.folder_shared_outlined,
                  text: 'Report Sopralluoghi',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReportSopralluoghiPage()),
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