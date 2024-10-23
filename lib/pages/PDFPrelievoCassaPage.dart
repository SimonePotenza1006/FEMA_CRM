import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'dart:io';
import '../model/MovimentiModel.dart';
import '../model/UtenteModel.dart';
import 'package:intl/intl.dart';

import 'PDFInterventoPage.dart';

class PDFPrelievoCassaPage extends StatefulWidget {
  final String? descrizione;
  final UtenteModel? utente;
  final DateTime? data;
  final String? importo;
  final TipoMovimentazione tipoMovimentazione;
  final Uint8List? firmaIncaricato;

  PDFPrelievoCassaPage({
    required this.descrizione,
    required this.utente,
    required this.data,
    required this.importo,
    required this.tipoMovimentazione,
    required this.firmaIncaricato,
  });

  @override
  _PDFPrelievoCassaPageState createState() => _PDFPrelievoCassaPageState();
}

class _PDFPrelievoCassaPageState extends State<PDFPrelievoCassaPage> {
  late Future<Uint8List> _pdfFuture;
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();
  final GlobalKey<SfSignaturePadState> signatureGlobalKeyDip = GlobalKey();
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  List<MovimentiModel> allPrelievi = [];

  @override
  void initState() {
    super.initState();
    _pdfFuture = _generatePDF();
    getAllPrelievi();
  }

  Future<void> getAllPrelievi() async {
    try {
      var apiUrl = Uri.parse('$ipaddressProva/api/movimenti');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print('Response Body: $jsonData'); // Aggiungi questo log

        List<MovimentiModel> movimenti = [];
        DateTime now = DateTime.now();
        DateTime startOfWeek = DateTime(now.year, now.month, now.day - now.weekday);
        DateTime endOfWeek = startOfWeek.add(Duration(days: 7));

        for (var item in jsonData) {
          MovimentiModel movimento = MovimentiModel.fromJson(item);
          if ((movimento.tipo_movimentazione == TipoMovimentazione.Entrata || movimento.tipo_movimentazione == TipoMovimentazione.Uscita) &&
              movimento.dataCreazione != null &&
              movimento.dataCreazione!.isAfter(startOfWeek) &&
              movimento.dataCreazione!.isBefore(endOfWeek)) {
            movimenti.add(movimento);
          }
        }
        setState(() {
          allPrelievi = movimenti;
        });
        print('Movimenti: $allPrelievi'); // Aggiungi questo log
      }
    } catch (e) {
      print('Errore durante il recupero dei prelievi: $e');
    }
  }

  pw.Widget _buildPrelieviList() {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: allPrelievi.map((prelievo) {
          return pw.Container(
            margin: pw.EdgeInsets.only(bottom: 5),
            child: pw.Text(
              '${DateFormat('dd/MM/yyyy').format(prelievo.dataCreazione!)} - ${prelievo.descrizione} - ${prelievo.importo?.toStringAsFixed(2)} ${String.fromCharCode(128)}',
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generazione PDF'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _pdfFuture = _generatePDF();
              });
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: RepaintBoundary(
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<Uint8List>(
                  future: _pdfFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Errore durante la generazione del PDF: ${snapshot.error.toString()}',
                        ),
                      );
                    } else {
                      return PDFViewerPage(pdfBytes: snapshot.data!);
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Inviare pdf via mail?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _generateAndSendPDF();
                            },
                            child: Text("Si"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("No"),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                ),
                child: Text(
                  'Invia PDF via email',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateAndSendPDF() async {
    try {
      final Uint8List pdfBytes = await _generatePDF();
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/${widget.tipoMovimentazione.toString().substring(19)}.pdf';
      final tempFile = File(tempFilePath);

      await tempFile.writeAsBytes(pdfBytes);

      final String smtpServerHost = 'mail.femasistemi.it';
      final int smtpServerPort = 465;
      final String username = 'noreply@femasistemi.it';
      final String password = 'WGnr18@59.';
      final String recipient = 'info@femasistemi.it';

      final String subject =
          '(MOVIMENTOCASSA) ${widget.tipoMovimentazione.toString().substring(19)} in data ${DateFormat('dd/MM/yyyy').format(widget.data!)}, utente: ${widget.utente?.nome} ${widget.utente?.cognome}.';
      final String body =
          'In allegato il PDF riepilogativo della movimentazione in ${widget.tipoMovimentazione.toString().substring(19)}  dalla cassa pari a ${widget.importo}, con descrizione ${widget.descrizione}';

      final smtpServer = SmtpServer(
        smtpServerHost,
        port: smtpServerPort,
        username: username,
        password: password,
        ssl: true,
      );

      final message = Message()
        ..from = Address(username, 'App FEMA')
        ..recipients.add(recipient)
        ..subject = subject
        ..text = body
        ..attachments.add(FileAttachment(
          tempFile,
          fileName: 'Movimento ${widget.tipoMovimentazione.toString().substring(19)} ${DateFormat('dd-MM-yyyy').format(widget.data!)}.pdf',
        ));

      final sendReport = await send(message, smtpServer);
      print('Email inviata con successo: $sendReport');

      await tempFile.delete();
    } catch (e) {
      print('Errore durante l\'invio dell\'email: $e');
    }
  }

  Future<Uint8List> _generatePDF() async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          margin: pw.EdgeInsets.zero,
          build: (context) {
            return pw.Container(
              padding: pw.EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 20),
                  pw.Text(
                    "Documento relativo alla movimentazione in ${widget.tipoMovimentazione.toString().substring(19)} in data ${DateFormat('dd/MM/yyyy').format(widget.data!)}",
                    style: pw.TextStyle(fontSize: 17, fontStyle: pw.FontStyle.italic),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    "Si attesta che, in data ${DateFormat('dd/MM/yyyy').format(widget.data!)}, l'utente ${widget.utente?.cognome} ${widget.utente?.nome} ha effettuato un movimento di ${widget.tipoMovimentazione.toString().substring(19)} dal fondocassa aziendale un importo pari a ${widget.importo}. Tale movimentazione è dovuta a: \' ${widget.descrizione} \' ",
                  ),
                  pw.SizedBox(height: 60),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      pw.Column(
                        children: [
                          pw.Text("Firma incaricato a ritiro"),
                          pw.SizedBox(height: 20),
                          pw.SizedBox(
                            height: 100,
                            width: 130,
                            child: pw.Image(
                              pw.MemoryImage(widget.firmaIncaricato!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  /*pw.SizedBox(height: 40),
                  pw.Text(
                    'Elenco delle movimenti:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  // Utilizziamo un ciclo for per aggiungere ogni prelievo separatamente
                  for (var prelievo in allPrelievi)
                    pw.Container(
                      margin: pw.EdgeInsets.only(bottom: 5),
                      child: pw.Text(
                        '${DateFormat('dd/MM/yyyy').format(prelievo.dataCreazione!)} - ${prelievo.descrizione} - ${prelievo.importo}',
                      ),
                    ),*/
                ],
              ),
            );
          },
        ),
      );
      return pdf.save();
    } catch (e) {
      print('Errore durante la generazione del PDF: $e');
      rethrow;
    }
  }
}
