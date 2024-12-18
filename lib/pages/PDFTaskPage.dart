import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
//import 'package:fema_crm/model/MarcaTempoModel.dart';
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
import '../model/TaskModel.dart';
import '../model/UtenteModel.dart';
import 'PDFInterventoPage.dart';

class PDFTaskPage extends StatefulWidget {
  final List<TaskModel> timbrature;
  PDFTaskPage({required this.timbrature});

  @override
  _PDFTaskPageState createState() => _PDFTaskPageState();
}

class _PDFTaskPageState extends State<PDFTaskPage> {
  late Future<Uint8List> _pdfFuture;
  List<RelazionePreventivoProdottiModel> allProdotti = [];
  GlobalKey globalKey = GlobalKey();
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';
  List<TaskModel> marcasss = [];
  int totore=0;
  List<pw.Widget> tabelleM = [];

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
        backgroundColor: Colors.red,
        title: Text('Generazione PDF report TASK', style: TextStyle(color: Colors.white)),
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



  // Function to get unique users with time entries

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

            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FixedColumnWidth(80),
                1: pw.FixedColumnWidth(170),
                2: pw.FixedColumnWidth(150),
                3: pw.FixedColumnWidth(100),
                4: pw.FixedColumnWidth(90),
                5: pw.FixedColumnWidth(100),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                        padding: pw.EdgeInsets.all(3), // Imposta il padding desiderato
                        child: pw.Text('DATA CREAZIONE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(3), // Imposta il padding desiderato
                        child: pw.Text('TITOLO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(3), // Imposta il padding desiderato
                        child: pw.Text('RIFERIMENTO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(3), // Imposta il padding desiderato
                        child: pw.Text('UTENTE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(3), // Imposta il padding desiderato
                        child: pw.Text('ACCETTATO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                    pw.Padding(
                        padding: pw.EdgeInsets.all(3), // Imposta il padding desiderato
                        child: pw.Text('DATA CONCLUSIONE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8))),
                    //pw.Text('TITOLO', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                for (var task in marcasss)


                  pw.TableRow(
                    children: [
                      createCellWithLine(
                        text: DateFormat('dd/MM/yyyy').format(task.data_creazione!),
                        isConcluded: task.concluso!,
                      ),
                      createCellWithLine(
                        text: task.titolo.toString().toUpperCase(),
                        isConcluded: task.concluso!,
                      ),
                      createCellWithLine(
                        text: task.riferimento != null ? task.riferimento.toString().toUpperCase() : '//',
                        isConcluded: task.concluso!,
                      ),
                      createCellWithLine(
                        text: task.utente!.nomeCompleto()!,
                        isConcluded: task.concluso!,
                      ),
                      createCellWithLine(
                        text: task.accettato! ? 'ACCETTATO' : 'NON ACCETTATO',
                        isConcluded: task.concluso!,
                      ),
                      createCellWithLine(
                        text: task.data_conclusione != null
                            ? DateFormat('dd/MM/yyyy HH:mm').format(task.data_conclusione!)
                            : 'N.C.',
                        isConcluded: false,//task.concluso!,
                      ),
                    ],
                  ),







                //...rows, // Aggiungiamo tutte le righe generate
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

  pw.Widget createCellWithLine({
    required String text,
    required bool isConcluded,
  }) {
    // Se il testo supera i 20 caratteri, lo troncamo a 20
    String displayText = text.length > 36 ? text.substring(0, 36)+"..." : text;

    return pw.Stack(
      alignment: pw.Alignment.center,
      children: [
        // Linea orizzontale se "concluso"
        if (isConcluded)
          pw.Divider(//borderStyle: BorderStyle.,
            thickness: 0.1, // Spessore linea
            color: PdfColors.grey900,
          ),
        // Testo normale sopra la linea
        pw.Padding(
          padding: pw.EdgeInsets.all(3),
          child: pw.Text(
            displayText,
            style: pw.TextStyle(
              fontSize: 6,
            ),
          ),
        ),
      ],
    );
  }



}