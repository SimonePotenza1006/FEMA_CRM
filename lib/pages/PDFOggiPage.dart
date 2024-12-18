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

class PDFOggiPage extends StatefulWidget {
  final List<MarcaTempoModel> timbrature;
  PDFOggiPage({required this.timbrature});

  @override
  _PDFOggiPageState createState() => _PDFOggiPageState();
}

class _PDFOggiPageState extends State<PDFOggiPage> {
  late Future<Uint8List> _pdfFuture;
  List<RelazionePreventivoProdottiModel> allProdotti = [];
  GlobalKey globalKey = GlobalKey();
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = '192.128.1.248:8090';
  String ipaddressProva2 = '192.168.1.198:8095';
  List<MarcaTempoModel> marcasss = [];
  int totore=0;

  @override
  void initState() {
    super.initState();
    marcasss = widget.timbrature;
    _pdfFuture = makePdf();//_generatePDF();
    globalKey = GlobalKey();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generazione PDF timbrature odierne'),
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
            pw.Padding(
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
                          fontSize: 13,
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
                      ['ING', 'Gps Ingresso', 'USC', 'Gps Uscita', 'Durata'],
                      ...marcasss
                          .where((marca) => marca.utente!.id == user.id)
                          .map((marca) => [
                        pw.Container(
                          width: 66, // Imposta la larghezza del contenitore
                          child:
                          pw.Text(DateFormat('HH:mm').format(marca.data!),
                              style: pw.TextStyle(
                                  fontSize: 15
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
                                  fontSize: 15
                              )),
                          //'dd/MM/yyyy HH:mm'
                        ) //'dd/MM/yyyy HH:mm'
                            : 'Uscita non timbrata',
                        marca.gpsu != null ? marca.gpsu! : '-',
    pw.Container(
    width: 66, // Imposta la larghezza del contenitore
    child:
    pw.Text(style: pw.TextStyle(
    fontSize: 15
    ),
                        marca.datau != null ?
                        getTimeString(marca.datau!.difference(marca.data!).inMinutes)
                             //'${marca.datau!.difference(marca.data!).inHours} ore e ${marca.datau!.difference(marca.data!).inMinutes % 60} minuti'
                            : '-'))
                        ,
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
              ),
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