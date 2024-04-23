import 'dart:convert';

import 'package:fema_crm/pages/DettaglioSopralluogoPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/SopralluogoModel.dart';
import '../model/UtenteModel.dart';
import 'package:http/http.dart' as http;

class ListaSopralluoghiTecnicoPage extends StatefulWidget{
  final UtenteModel utente;

  const ListaSopralluoghiTecnicoPage({Key? key, required this.utente}) : super(key : key);

  @override
  _ListaSopralluoghiTecnicoPageState createState() => _ListaSopralluoghiTecnicoPageState();
}

class _ListaSopralluoghiTecnicoPageState extends State<ListaSopralluoghiTecnicoPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  List<SopralluogoModel> allSopralluoghi = [];
  bool isLoading = true;

  @override
  void initState(){
    super.initState();
    getSopralluoghiByUtente();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'I tuoi sopralluoghi',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding : const EdgeInsets.all(8.0),
                    child: Text(
                      'Totale sopralluoghi effettuati: ${allSopralluoghi.length}',
                      style: TextStyle(fontSize: 18),
                    ),
                ),
                Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('Data')),
                            DataColumn(label: Text('Cliente')),
                            DataColumn(label: Text('Posizione')),
                            DataColumn(label: Text('Descrizione'))
                          ],
                          rows: allSopralluoghi.map((sopralluogo) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DettaglioSopralluogoPage(sopralluogo: sopralluogo)
                                        ),
                                      );
                                    },
                                    child: Text(sopralluogo.data != null
                                        ? DateFormat('yyyy-MM-dd')
                                            .format(sopralluogo.data!)
                                    : ''),
                                  ),
                                ),
                                DataCell(Text(sopralluogo.cliente?.denominazione ?? '')),
                                DataCell(Text(sopralluogo.posizione ?? '')),
                                DataCell(Text(sopralluogo.descrizione != null
                                    ? (sopralluogo.descrizione!.length > 30
                                    ? sopralluogo.descrizione!.substring(0, 30)
                                    : sopralluogo.descrizione!)
                                    : "N/A")),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    )
                )
              ],
      )
    );
  }

  Future<void> getSopralluoghiByUtente() async{
    try{
      http.Response response = await http.get(Uri.parse('${ipaddress}/api/sopralluogo/utente/${widget.utente.id}'));
      if(response.statusCode == 200){
        var responseData = json.decode(response.body);
        List<SopralluogoModel> sopralluoghi =[];
        for (var item in responseData){
          sopralluoghi.add(SopralluogoModel.fromJson(item));
        }
        setState(() {
          allSopralluoghi = sopralluoghi;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch(e) {
      print('Errore durante la chiamata all\'API: $e');
      _showErrorDialog();
    }
  }
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Errore di connessione'),
          content: Text(
              'Impossibile caricare i dati dall\'API. Controlla la tua connessione internet e riprova.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}