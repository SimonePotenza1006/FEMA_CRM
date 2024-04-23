import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  double? fondoCassaSettimana1;
  double? fondoCassaSettimana2;
  double? fondoCassaSettimana3;

  @override
  void initState() {
    super.initState();
    getAllMovimentazioni();
  }

  @override
  Widget build(BuildContext context) {
    double fondoCassa = calcolaFondoCassa(movimentiList);
    fondoCassa = fondoCassa.clamp(0, 2000); // Limita il fondo cassa a 2000
    fondoCassa = double.parse(
        fondoCassa.toStringAsFixed(2)); // Arrotonda a 2 cifre decimali

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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AggiungiMovimentoPage(userData: widget.userData)),
              );
            },
            backgroundColor: Colors.red,
            child: Icon(Icons.add, color: Colors.white),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              _showPreviousWeeksDialog();
            },
            backgroundColor: Colors.red,
            child: Icon(Icons.currency_exchange, color: Colors.white),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              _showConfirmationDialog();
            },
            backgroundColor: Colors.red,
            child: Icon(Icons.arrow_downward, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView( // Aggiunto SingleChildScrollView
        child: Column(
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
            SingleChildScrollView(
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
                      DataColumn(
                        label: Text('Utente'),
                      ),
                    ],
                    rows: movimentiList.map((movimento) {
                      return DataRow(
                        cells: [
                          DataCell(Text(DateFormat('yyyy-MM-dd HH:mm')
                              .format(movimento.data!))),
                          DataCell(Text(movimento.descrizione ?? '')),
                          DataCell(Text(_getTipoMovimentazioneString(
                              movimento.tipo_movimentazione))),
                          DataCell(Text(movimento.importo != null
                              ? movimento.importo.toString()
                              : '')),
                          DataCell(Text(movimento.utente != null
                              ? movimento.utente!.cognome ?? ''
                              : '')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _generateExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    sheetObject.appendRow([
      'Data',
      'Tipo di movimentazione',
      'Importo',
      'Descrizione',
      'Utente',
    ]);
    for(var spesa in movimentiList){
      sheetObject.appendRow([
        spesa.data != null
            ? DateFormat('yyyy-MM-dd').format(spesa.data!)
            : 'N/A',
        spesa.tipo_movimentazione.toString() ?? 'N/A',
        spesa.importo?.toStringAsFixed(2) ?? 'N/A',
        spesa.descrizione ?? 'N/A',
        spesa.utente?.cognome ?? 'N/A'
      ]);
    }
    try {
      late String filePath;
      if (Platform.isWindows) {
        // Percorso di salvataggio su Windows
        String appDocumentsPath = 'C:\\ReportRegistroCassa';
        filePath = '$appDocumentsPath\\report_registro_cassa.xlsx';
      } else if (Platform.isAndroid) {
        // Percorso di salvataggio su Android
        Directory? externalStorageDir = await getExternalStorageDirectory();
        if (externalStorageDir != null) {
          String appDocumentsPath = externalStorageDir.path;
          filePath = '$appDocumentsPath/report_registro_cassa.xlsx';
        } else {
          throw Exception('Impossibile ottenere il percorso di salvataggio.');
        }
      }

      var excelBytes = await excel.encode();
      if (excelBytes != null) {
        await File(filePath).create(recursive: true).then((file) {
          file.writeAsBytesSync(excelBytes);
        });
        // Notifica all'utente che il file è stato salvato con successo
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Excel salvato in $filePath')));
      } else {
        // Gestisci il caso in cui excel.encode() restituisce null
        print('Errore durante la codifica del file Excel');
      }
    } catch (error) {
      // Gestisci eventuali errori durante il salvataggio del file
      print('Errore durante il salvataggio del file Excel: $error');
    }
  }

  String _getTipoMovimentazioneString(TipoMovimentazione? tipoMovimentazione) {
    if (tipoMovimentazione == TipoMovimentazione.Entrata) {
      return 'Entrata';
    } else if (tipoMovimentazione == TipoMovimentazione.Uscita) {
      return 'Uscita';
    } else {
      return 'Prelievo';
    }
  }

  double calcolaFondoCassa(List<MovimentiModel> movimenti) {
    double fondoCassa = 0;
    for (var movimento in movimenti) {
      if (movimento.tipo_movimentazione == TipoMovimentazione.Entrata) {
        fondoCassa += movimento.importo ?? 0;
      } else if (movimento.tipo_movimentazione == TipoMovimentazione.Uscita ||
          movimento.tipo_movimentazione == TipoMovimentazione.Prelievo) {
        fondoCassa -= movimento.importo ?? 0;
      }
    }
    return fondoCassa;
  }

  Future<void> getAllMovimentazioni() async {
    try {
      var apiUrl = Uri.parse('${ipaddress}/api/movimenti');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        List<MovimentiModel> movimenti = [];
        for (var item in jsonData) {
          MovimentiModel movimento = MovimentiModel.fromJson(item);

          // Controllo se la data dell'oggetto movimento è nella settimana corrente
          DateTime now = DateTime.now();
          DateTime startOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 1);
          DateTime endOfWeek = startOfWeek.add(Duration(days: 7));
          if (movimento.data!.isAfter(startOfWeek) && movimento.data!.isBefore(endOfWeek)) {
            movimenti.add(movimento);
          }

          // Controllo se la data dell'oggetto movimento è nelle settimane precedenti
          DateTime startOfPreviousWeek1 = startOfWeek.subtract(Duration(days: 7));
          DateTime endOfPreviousWeek1 = startOfWeek;
          DateTime startOfPreviousWeek2 = startOfWeek.subtract(Duration(days: 14));
          DateTime endOfPreviousWeek2 = startOfPreviousWeek1;
          DateTime startOfPreviousWeek3 = startOfWeek.subtract(Duration(days: 21));
          DateTime endOfPreviousWeek3 = startOfPreviousWeek2;

          if (movimento.data!.isAfter(startOfPreviousWeek1) && movimento.data!.isBefore(endOfPreviousWeek1)) {
            fondoCassaSettimana1 = calcolaFondoCassa([movimento]);
          } else if (movimento.data!.isAfter(startOfPreviousWeek2) && movimento.data!.isBefore(endOfPreviousWeek2)) {
            fondoCassaSettimana2 = calcolaFondoCassa([movimento]);
          } else if (movimento.data!.isAfter(startOfPreviousWeek3) && movimento.data!.isBefore(endOfPreviousWeek3)) {
            fondoCassaSettimana3 = calcolaFondoCassa([movimento]);
          }
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
            content: Text(
                'Unable to load data from API. Please check your internet connection and try again.'),
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

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Scaricare excel del report?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _generateExcel();
                Navigator.of(context).pop();
              },
              child: Text('Conferma', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showPreviousWeeksDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Fondo cassa settimane precedenti'),
          content: Container(
            height: 200, // Personalizza l'altezza del dialog
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fondo cassa ${DateFormat('dd/MM').format(getStartOfPreviousWeek(1))}: ${fondoCassaSettimana1 ?? 'N/A'}'), // Aggiungi il fondo cassa della prima settimana
                SizedBox(height: 8),
                Text('Fondo cassa ${DateFormat('dd/MM').format(getStartOfPreviousWeek(2))}: ${fondoCassaSettimana2 ?? 'N/A'}'), // Aggiungi il fondo cassa della seconda settimana
                SizedBox(height: 8),
                Text('Fondo cassa ${DateFormat('dd/MM').format(getStartOfPreviousWeek(3))}: ${fondoCassaSettimana3 ?? 'N/A'}'), // Aggiungi il fondo cassa della terza settimana
              ],
            ),
          ),
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

  DateTime getStartOfPreviousWeek(int weekNumber) {
    DateTime now = DateTime.now();
    DateTime startOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 1);
    return startOfWeek.subtract(Duration(days: 7 * weekNumber));
  }
}
