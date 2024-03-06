import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../model/MovimentiModel.dart';
import '../model/UtenteModel.dart';
import 'AggiungiMovimentoPage.dart';

class RegistroCassaPage extends StatefulWidget {
  final UtenteModel userData;

  const RegistroCassaPage({Key? key, required this.userData}) : super(key: key);

  @override
  _RegistroCassaPageState createState() => _RegistroCassaPageState();
}

class _RegistroCassaPageState extends State<RegistroCassaPage> {
  List<MovimentiModel> movimentiList = [];

  @override
  void initState() {
    super.initState();
    getAllMovimentazioni();
  }

  @override
  Widget build(BuildContext context) {
    double fondoCassa = calcolaFondoCassa(movimentiList);
    fondoCassa = fondoCassa.clamp(0, 2000); // Limita il fondo cassa a 2000
    fondoCassa = double.parse(fondoCassa.toStringAsFixed(2)); // Arrotonda a 2 cifre decimali

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Registro cassa',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AggiungiMovimentoPage(userData: widget.userData)),
          );
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              alignment: Alignment.center,
              children: [

                Container(
                  width: 200, // Aumentato il diametro del cerchio
                  height: 200, // Aumentato il diametro del cerchio
                  child: CircularProgressIndicator(
                    value: fondoCassa / 2000,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    strokeWidth: 15.0,
                  ),
                ),
                Text(
                  '€$fondoCassa',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Data')),
                      DataColumn(label: Text('Descrizione')),
                      DataColumn(label: Text('Tipo')),
                      DataColumn(label: Text('Importo')),
                      DataColumn(label: Text('Utente')), // Aggiunta della colonna per l'utente
                    ],
                    rows: movimentiList.map((movimento) {
                      return DataRow(
                        cells: [
                          DataCell(Text(DateFormat('yyyy-MM-dd HH:mm').format(movimento.data!))),
                          DataCell(Text(movimento.descrizione ?? '')),
                          DataCell(Text(_getTipoMovimentazioneString(movimento.tipo_movimentazione))),
                          DataCell(Text(movimento.importo != null ? movimento.importo.toString() : '')),
                          DataCell(Text(movimento.utente != null ? movimento.utente!.cognome ?? '' : '')), // Mostra la denominazione dell'utente
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTipoMovimentazioneString(TipoMovimentazione? tipoMovimentazione) {
    return tipoMovimentazione == TipoMovimentazione.Entrata ? 'Entrata' : 'Uscita';
  }

  double calcolaFondoCassa(List<MovimentiModel> movimenti) {
    double fondoCassa = 0;
    for (var movimento in movimenti) {
      if (movimento.tipo_movimentazione == TipoMovimentazione.Entrata) {
        fondoCassa += movimento.importo ?? 0;
      } else if (movimento.tipo_movimentazione == TipoMovimentazione.Uscita) {
        fondoCassa -= movimento.importo ?? 0;
      }
    }
    return fondoCassa;
  }

  Future<void> getAllMovimentazioni() async {
    try {
      var apiUrl = Uri.parse('http://192.168.1.52:8080/api/movimenti');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        List<MovimentiModel> movimenti = [];
        for (var item in jsonData) {
          movimenti.add(MovimentiModel.fromJson(item));
        }

        setState(() {
          movimentiList = movimenti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during API call: $e');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Connection Error'),
            content: Text('Unable to load data from API. Please check your internet connection and try again.'),
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
}
