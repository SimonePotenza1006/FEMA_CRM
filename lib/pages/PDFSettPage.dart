import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:fema_crm/model/MarcaTempoModel.dart';
import 'package:flutter/rendering.dart';

import 'package:fema_crm/model/PreventivoModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:email_validator/email_validator.dart';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;

import '../model/RelazionePreventivoProdottiModel.dart';
import '../model/UtenteModel.dart';
import 'PDFInterventoPage.dart';

class PDFSettPage extends StatefulWidget {
  final List<MarcaTempoModel> timbrature;
  PDFSettPage({required this.timbrature});

  @override
  _PDFSettPageState createState() => _PDFSettPageState();
}

class _PDFSettPageState extends State<PDFSettPage> {
  late Future<Uint8List> _pdfFuture;
  List<RelazionePreventivoProdottiModel> allProdotti = [];
  GlobalKey globalKey = GlobalKey();
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  List<MarcaTempoModel> marcasss = [];
  int totore=0;
  List<pw.Widget> tabelleM = [];

  @override
  void initState() {
    super.initState();
    marcasss = widget.timbrature;
    calcolaOreLavoro(widget.timbrature);
    calcolaOreLavoroMese(widget.timbrature);
    _pdfFuture = makePdf();//_generatePDF();
    globalKey = GlobalKey();

  }

  int getSettimana(DateTime date) {
    int dayOfYear = getDayOfYear(date);
    int week = (dayOfYear - date.weekday + 10) ~/ 7;
    return week;
  }

  int getDayOfYear(DateTime date) {
    return date.difference(DateTime(date.year, 1, 1)).inDays + 1;
  }

  void calcolaOreLavoroMese(List<MarcaTempoModel> listaMarcaTempo) {
    List<String> nomiMesi = [
      'GENNAIO',
      'FEBBRAIO',
      'MARZO',
      'APRILE',
      'MAGGIO',
      'GIUGNO',
      'LUGLIO',
      'AGOSTO',
      'SETTEMBRE',
      'OTTOBRE',
      'NOVEMBRE',
      'DICEMBRE'
    ];
    // Creo una mappa per memorizzare le ore di lavoro per utente e mese
    Map<String, Map<String, double>> oreLavoroMese = {};

    // Itero sulla lista di marca tempo
    listaMarcaTempo.forEach((marcaTempo) {
      // Controllo se l'utente è presente nella mappa
      if (!oreLavoroMese.containsKey(marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!)) {
        oreLavoroMese[marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!] = {};
      }

      // Calcolo il mese dell'anno
      int mese = marcaTempo.data!.month;
      String nomeMese = nomiMesi[marcaTempo.data!.month - 1]+' '+marcaTempo.data!.year.toString();

      // Controllo se il mese è presente nella mappa dell'utente
      if (!oreLavoroMese[marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!]!.containsKey(nomeMese)) {
        oreLavoroMese[marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!]![nomeMese] = 0;
      }

      // Calcolo le ore e minuti di lavoro
      int minuti = marcaTempo.datau != null
          ? marcaTempo.datau!.difference(marcaTempo.data!).inMinutes
          : 0;

      double ore = minuti / 60.0;

      // Aggiungo le ore di lavoro alla mappa
      oreLavoroMese[marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!]![nomeMese] = oreLavoroMese[marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!]![nomeMese]! + ore;
    });

    // Creo una mappa per memorizzare le tabelle per ogni mese
    Map<String, List<pw.Row>> tabelleMese = {};

    // Itero sulla mappa di ore di lavoro
    oreLavoroMese.forEach((utente, mesi) {
      mesi.forEach((mese, ore) {
        int oreInt = ore.toInt();
        int minuti = ((ore - oreInt) * 60).toInt();

        // Controllo se il mese è presente nella mappa delle tabelle
        if (!tabelleMese.containsKey(mese)) {
          tabelleMese[mese] = [];
        }

        // Aggiungo la riga alla tabella del mese corrente
        tabelleMese[mese]!.add(
          pw.Row(children: [

                  pw.Container(width: 130,
                    alignment: pw.Alignment.center,
                    child:
                    pw.Text(utente, style: pw.TextStyle(fontSize: 9)),),


                  pw.Container(width: 110,
                      alignment: pw.Alignment.center,
                      child:
                      pw.Text('$oreInt ore $minuti minuti', style: pw.TextStyle(fontSize: 9)))

            ],
          ),
        );
      });
    });


    // Itero sulla mappa delle tabelle
    tabelleMese.forEach((mese, righe) {
      // Creo la tabella del mese corrente
      pw.Table tabellaMese = pw.Table(
        border: pw.TableBorder.all(color: PdfColors.black),
        children: righe.map((row) => pw.TableRow(children: [row])).toList(),
        /*children: [
        //columns: [
          pw.Column(label: pw.Text('UTENTE'), ),
          pw.Column(label: Text('ORE')),
        ],*/
        //rows: righe,
      );

      // Aggiungo la tabella alla lista di tabelle
      tabelleM.add(
        pw.Column(
          children: [
            //SizedBox(height: 15,),
            pw.Text('\n$mese'),
            tabellaMese,
          ],
        ),
      );
    });

    // Ordino la lista di tabelle in ordine decrescente di mese
   /* tabelleM.sort((a, b) {
      Column columnA = a as Column;
      Column columnB = b as Column;

      //int meseA = int.parse((columnA.children.first as Text).data!.split(' ')[1]);
      Text textWidget = columnA.children.first as Text;
      List<String> parts = textWidget.data!.split(' ');
      int meseA;
      if (parts.length > 1) {
        meseA = int.parse(parts[1]);
      } else {
        // Handle the case where there's no space in the text
        meseA = 0; // or some other default value
      }

      Text textWidget2 = columnB.children.first as Text;
      List<String> parts2 = textWidget2.data!.split(' ');
      int meseB;
      if (parts2.length > 1) {
        meseB = int.parse(parts2[1]);
      } else {
        // Handle the case where there's no space in the text
        meseB = 0; // or some other default value
      }

      //int meseB = int.parse((columnB.children.first as Text).data!.split(' ')[1]);
      return meseB.compareTo(meseA);
    });*/

    // Mostra le tabelle
    // ...
  }

  static List<DataColumn> _columns = [
    DataColumn(label: Text('UTENTE')),
    DataColumn(label: Text('SETTIMANA')),
    DataColumn(label: Text('ORE')),
  ];
  DataTable tabella = DataTable(
    columns: _columns,
    rows: [], // You can leave the rows empty for now
  );

  List<pw.Widget> tabelle = [];

  void calcolaOreLavoro(List<MarcaTempoModel> listaMarcaTempo) {
    // Creo una mappa per memorizzare le ore di lavoro per utente e settimana
    Map<String, Map<int, double>> oreLavoro = {};

    // Itero sulla lista di marca tempo
    listaMarcaTempo.forEach((marcaTempo) {
      // Controllo se l'utente è presente nella mappa
      if (!oreLavoro.containsKey(marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!)) {
        oreLavoro[marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!] = {};
      }

      // Calcolo la settimana dell'anno
      int settimana = getSettimana(marcaTempo.data!);

      // Controllo se la settimana è presente nella mappa dell'utente
      if (!oreLavoro[marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!]!.containsKey(settimana)) {
        oreLavoro[marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!]![settimana] = 0;
      }

      // Calcolo le ore e minuti di lavoro
      int minuti = marcaTempo.datau != null
          ? marcaTempo.datau!.difference(marcaTempo.data!).inMinutes
          : 0;

      double ore = minuti / 60.0;

      // Aggiungo le ore di lavoro alla mappa
      oreLavoro[marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!]![settimana] = oreLavoro[marcaTempo.utente!.nome! +' '+marcaTempo.utente!.cognome!]![settimana]! + ore;
    });

    // Creo una mappa per memorizzare le tabelle per ogni settimana
    Map<int, List<pw.Row>> tabelleSettimana = {};

    // Itero sulla mappa di ore di lavoro
    oreLavoro.forEach((utente, settimane) {
      settimane.forEach((settimana, ore) {
        int oreInt = ore.toInt();
        int minuti = ((ore - oreInt) * 60).toInt();

        // Controllo se la settimana è presente nella mappa delle tabelle
        if (!tabelleSettimana.containsKey(settimana)) {
          tabelleSettimana[settimana] = [];
        }

        // Aggiungo la riga alla tabella della settimana corrente
        tabelleSettimana[settimana]!.add(
          pw.Row(children: [

                  pw.Container(width: 130,
                    alignment: pw.Alignment.center,
                    child:
                    pw.Text(utente, style: pw.TextStyle(fontSize: 9)),)
              ,

            pw.Container(width: 110,
                      alignment: pw.Alignment.center,
                      child:
                      pw.Text('$oreInt ore $minuti minuti', style: pw.TextStyle(fontSize: 9)))
              ,
            ],
          ),
        );
      });
    });

    // Creo la lista di tabelle
    //List<DataTable> tabelle = [];

    // Itero sulla mappa delle tabelle
    tabelleSettimana.forEach((settimana, righe) {
      // Creo la tabella della settimana corrente
     pw.Table tabellaSettimana = pw.Table(
        border: pw.TableBorder.all(color: PdfColors.black),
        children: righe.map((row) => pw.TableRow(children: [row])).toList(),
        /*columns: [
          DataColumn(label: Text('UTENTE')),
          DataColumn(label: Text('ORE')),
        ],
        rows: righe,*/
      );

      // Aggiungo la tabella alla lista di tabelle
      tabelle.add(
        pw.Column(
          children: [
            pw.Text('\n'+DateFormat('dd/MM/yyyy').format(DateFormat('yyyy-MM-dd').parse(Settimana.getSettimana(settimana, DateTime.now().year)['lunedì']!.toString()),)+' - '+DateFormat('dd/MM/yyyy').format(DateFormat('yyyy-MM-dd').parse(Settimana.getSettimana(settimana, DateTime.now().year)['domenica']!.toString()),)),
            //Text('\nSettimana $settimana'),
            tabellaSettimana,
          ],
        ),
      );
    });

    // Ordino la lista di tabelle in ordine decrescente di settimana
    tabelle.sort((a, b) {
      pw.Column columnA = a as pw.Column;
      pw.Column columnB = b as pw.Column;

      //int meseA = int.parse((columnA.children.first as Text).data!.split(' ')[1]);
      pw.Text textWidget = columnA.children.first as pw.Text;
      String text = textWidget.text.toPlainText();
      List<String> parts = text.split(' ');
      int settimanaA;
      try {
        settimanaA = getSettimana(DateFormat('dd/MM/yyyy').parse(parts[0].trim()));//int.parse(parts[1]);
      } catch (e) {
        // Handle the case where the week number cannot be parsed
        settimanaA = 0; // or some other default value
      }
      /*if (parts.length > 1) {
        String valore = parts[1].trim(); // Rimuove gli spazi bianchi
        print(parts.toString()+' asqwghio '+valore);
        if (valore.isNotEmpty && RegExp(r'^\d+$').hasMatch(valore)) { // Controlla se il valore è un numero
          settimanaA = int.parse(valore);
        } else {
          // Handle the case where the value is not a number
          settimanaA = 0; // or some other default value
        }
      } else {
        // Handle the case where there's no space in the text
        settimanaA = 0; // or some other default value
      }*/

      pw.Text textWidget2 = columnB.children.first as pw.Text;
      String text2 = textWidget2.text.toPlainText();
      List<String> parts2 = text2.split(' ');
      int settimanaB;
      try {
        settimanaB = getSettimana(DateFormat('dd/MM/yyyy').parse(parts2[0].trim()));//int.parse(parts2[1]);
      } catch (e) {
        // Handle the case where the week number cannot be parsed
        settimanaB = 0; // or some other default value
      }
      /*if (parts2.length > 1) {
        String valore = parts2[1].trim(); // Rimuove gli spazi bianchi
        if (valore.isNotEmpty && RegExp(r'^\d+$').hasMatch(valore)) { // Controlla se il valore è un numero
          settimanaB = int.parse(valore);
        } else {
          // Handle the case where the value is not a number
          settimanaB = 0; // or some other default value
        }
      } else {
        // Handle the case where there's no space in the text
        settimanaB = 0; // or some other default value
      }*/
      print(settimanaA.toString()+' GT '+settimanaB.toString());
      return settimanaA.compareTo(settimanaB);
    });

    // Mostra le tabelle
    // ...
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generazione PDF report timbrature'),
      ),
      body: FutureBuilder<Uint8List>(
        future: _pdfFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    'Errore durante la generazione del PDF: ${snapshot.error.toString()}'));
          } else {
            return PDFViewerPage(pdfBytes: snapshot.data!);
          }
        },
      ),

    );
  }

  String getTimeString(int value) {
    final int hour = value ~/ 60;
    final int minutes = value % 60;
    return '${hour.toString().padLeft(2, "0")}:${minutes.toString().padLeft(2, "0")}';
  }

// Function to calculate total hours for a user
  int getTotalHoursForUser(UtenteModel user) {
    int totalMinutes = 0;
    for (var marca in marcasss) {
      if (marca.utente!.id == user.id) {
        totalMinutes += marca.datau != null
            ? marca.datau!.difference(marca.data!).inMinutes
            : 0;
      }
    }
    return totalMinutes;
  }

  // Function to get unique users with time entries
  List<UtenteModel> getUsersWithTimeEntries() {
    List<MarcaTempoModel> uniqueEntries = [];
    List<UtenteModel> users = [];

    for (var entry in marcasss) {
      if (!uniqueEntries.any((element) => element.utente!.id == entry.utente!.id)) {
        uniqueEntries.add(entry);
        users.add(entry.utente!);
      }
    }

    return users;
  }

  Future<Uint8List> makePdf()  async {
   // calcolaOreLavoro(widget.timbrature);
    //calcolaOreLavoroMese(widget.timbrature);
    try {
      final pdf = pw.Document();
      var assetImage = pw.MemoryImage(
        (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
      );

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Row(
              children: [
                pw.Container(
                  width: 170,
                  child: pw.Image(assetImage),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                //children: [Stack(
                //alignment: AlignmentDirectional.topStart,
                children: [

                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.values[0],
                    mainAxisSize: pw.MainAxisSize.min,
                    children:[ pw.Text('SETTIMANALE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                      pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.values[0],
                          mainAxisSize: pw.MainAxisSize.min,
                          children:
                          tabelle.reversed.toList()//.map((table) => table).toList(),
                      )]),
                  pw.SizedBox(width: 10),
                  pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.values[0],
                      mainAxisSize: pw.MainAxisSize.min,
                      children:[
                        pw.Text('MENSILE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                        pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.values[0],
                            mainAxisSize: pw.MainAxisSize.min,
                            children:
                            tabelleM.reversed.toList()//.map((table) => table).toList(),
                        )])
                ]),



       /*     pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Text(
                "MARCA TEMPO " +
                    DateFormat('dd/MM/yyyy').format(marcasss.last.data!),
                style: pw.TextStyle(fontSize: 14),
              ),
            ),
            for (var user in getUsersWithTimeEntries())
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [

                  pw.Container(height: 14),
                  // User info (Nome Cognome)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Text(
                        user.nome! + ' ' + user.cognome!,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                  // Table for user's time entries
                  pw.Table.fromTextArray(
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                    cellStyle: const pw.TextStyle(color: PdfColors.black),
                    data: [
                      ['Ingresso', 'Gps Ingresso', 'Uscita', 'Gps Uscita', 'Durata'],
                      ...marcasss
                          .where((marca) => marca.utente!.id == user.id)
                          .map((marca) => [
                        pw.Container(
                          width: 66, // Imposta la larghezza del contenitore
                          child:
                          pw.Text(DateFormat('HH:mm').format(marca.data!),
                              style: pw.TextStyle(
                                  fontSize: 18
                              )),
                          //'dd/MM/yyyy HH:mm'
                        ),
                        marca.gps!,
                        marca.datau != null
                            ? pw.Container(
                          width: 66, // Imposta la larghezza del contenitore
                          child:
                          pw.Text(DateFormat('HH:mm').format(marca.datau!),
                              style: pw.TextStyle(
                                  fontSize: 18
                              )),
                          //'dd/MM/yyyy HH:mm'
                        ) //'dd/MM/yyyy HH:mm'
                            : 'Uscita non timbrata',
                        marca.gpsu != null ? marca.gpsu! : '-',
                        marca.datau != null
                            ? '${marca.datau!.difference(marca.data!).inHours} ore e ${marca.datau!.difference(marca.data!).inMinutes % 60} minuti'
                            : '-',
                      ]),
                    ],
                  ),
                  // Total hours for the user
                  pw.Text(
                    'Totale ore ${user.nome!} ${user.cognome!}: ' +
                        getTimeString(getTotalHoursForUser(user)),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                ],
              ),*/
          ],
        ),
      );

      // Restituisci il PDF come byte array
      return pdf.save();
    } catch (e) {
      print('Errore durante la generazione del PDF: $e');
      rethrow;
    }
  }
}

class Settimana {
  static DateTime getLunedi(int numeroSettimana, int anno) {
    DateTime primoGiornoAnno = DateTime(anno, 1, 1);
    while (primoGiornoAnno.weekday != 1) {
      primoGiornoAnno = primoGiornoAnno.add(Duration(days: 1));
    }
    return primoGiornoAnno.add(Duration(days: (numeroSettimana - 1) * 7));
  }

  static DateTime getDomenica(int numeroSettimana, int anno) {
    return getLunedi(numeroSettimana, anno).add(Duration(days: 6));
  }

  static Map<String, DateTime> getSettimana(int numeroSettimana, int anno) {
    DateTime lunedi = getLunedi(numeroSettimana, anno);
    DateTime domenica = getDomenica(numeroSettimana, anno);
    return {
      'lunedì': lunedi,
      'domenica': domenica,
    };
  }
}