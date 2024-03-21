import 'package:flutter/material.dart';

import 'AssegnazioneCommissionePage.dart';
import 'ReportCommissioniPage.dart';
import 'ReportCommissioniPerAgentePage.dart';

class MenuCommissioniPage extends StatefulWidget {
  const MenuCommissioniPage ({Key? key}) : super(key: key);

  @override
  _MenuCommissioniPageState createState() => _MenuCommissioniPageState();
}

class _MenuCommissioniPageState extends State<MenuCommissioniPage> {


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commissioni', style: TextStyle(color: Colors.white)),
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
                  icon: Icons.playlist_add_outlined,
                  text: 'Assegna Commissione',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AssegnazioneCommissionePage()),
                    );
                  },
                ),
                SizedBox(height: 10),
                buildMenuButton(
                  icon: Icons.bar_chart_outlined,
                  text: 'Report Commissioni',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReportCommissioniPage()),
                    );
                  },
                ),
                SizedBox(height: 10),
                buildMenuButton(
                  icon: Icons.folder_shared_outlined,
                  text: 'Report Commissioni per utente',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ReportCommissioniPerAgentePage()),
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