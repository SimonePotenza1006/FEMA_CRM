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
import 'dart:io';
import '../model/AgenteModel.dart';
import 'package:intl/intl.dart';

import '../model/PreventivoModel.dart';
import 'PDFInterventoPage.dart';

class PDFRendicontoMensilePreventiviPage extends StatefulWidget {
  final String? mese;

  PDFRendicontoMensilePreventiviPage({
    required this.mese,
  });

  @override
  _PDFRendicontoMensilePreventiviPageState createState() =>
      _PDFRendicontoMensilePreventiviPageState();
}

class _PDFRendicontoMensilePreventiviPageState
    extends State<PDFRendicontoMensilePreventiviPage> {
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  late Future<Uint8List> _pdfFuture;
  List<AgenteModel> allAgenti = [];
  Map<String, List<PreventivoModel>> preventiviPerAgenteMap = {};

  Map<String, int> monthMap = {
    'gennaio': 1,
    'febbraio': 2,
    'marzo': 3,
    'aprile': 4,
    'maggio': 5,
    'giugno': 6,
    'luglio': 7,
    'agosto': 8,
    'settembre': 9,
    'ottobre': 10,
    'novembre': 11,
    'dicembre': 12,
  };

  Future<void> _generateAndSendPDF() async {
    try {
      print('Inizio generazione PDF...');
      final Uint8List pdfBytes = await _generatePDF();
      print('PDF generato. Lunghezza: ${pdfBytes.length}');

      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/preventivo.pdf';
      final tempFile = File(tempFilePath);

      await tempFile.writeAsBytes(pdfBytes);

      final String smtpServerHost = 'mail.femasistemi.it';
      final int smtpServerPort = 465;
      final String username = 'noreply@femasistemi.it';
      final String password = 'WGnr18@59.';
      final String recipient = 'info@femasistemi.it';

      final String subject =
          '(REPORT) Report commissioni per agente del mese ${widget.mese}';
      final String body =
          'In allegato il PDF riepilogativo delle provvigioni dei preventivi del mese di ${widget.mese}';

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
          fileName: 'Report provvigioni ${widget.mese}.pdf',
        ));

      final sendReport = await send(message, smtpServer);
      print('Email inviata con successo: $sendReport');

      await tempFile.delete();
      print('File temporaneo eliminato.');
    } catch (e) {
      print('Errore durante l\'invio dell\'email: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _pdfFuture = _generatePDF();
    getAllAgenti();
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
                    } else if (!snapshot.hasData) {
                      return Center(
                        child: Text(
                          'PDF non generato',
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
                  if (_pdfFuture != null) { // Assicurarsi che _pdfFuture non sia null prima di chiamare _generateAndSendPDF()
                    _generateAndSendPDF();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
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

  Future<Uint8List> _generatePDF() async {
    try {
      print('Inizio generazione dati per il PDF...');
      final pdf = pw.Document();

      // Creazione della tabella per agenti e totali delle provvigioni
      final List<pw.TableRow> rows = [];

      for (var agente in allAgenti) {
        final preventivi = preventiviPerAgenteMap[agente.id!] ?? [];
        print('Preventivi prima del filtro per il mese ${widget.mese}: $preventivi');
        final filteredPreventivi = preventivi.where((preventivo) =>
        preventivo.consegnato == true &&
            preventivo.data_consegna != null &&
            preventivo.data_consegna!.month == monthMap[widget.mese]).toList();

        // Calcolo del totale delle provvigioni per gli preventivi consegnati nell'agente corrente
        double totalProvvigioni = filteredPreventivi.fold<double>(
            0.0, (acc, preventivo) => acc + (preventivo.provvigioni ?? 0.0));

        // Aggiunta della riga alla tabella
        rows.add(
          pw.TableRow(
            children: [
              pw.Padding(
                padding: pw.EdgeInsets.all(5), // Imposta il padding desiderato
                child: pw.Text(agente.nome! + ' ' + agente.cognome!),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(5), // Imposta il padding desiderato
                child: pw.Text(totalProvvigioni.toStringAsFixed(2) + String.fromCharCode(128)),
              ),
            ],
          ),
        );
      }

      // Aggiunta della tabella al documento PDF
      pdf.addPage(
        pw.Page(
          margin: pw.EdgeInsets.all(10),
          build: (context) {
            return pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: pw.FixedColumnWidth(200),
                1: pw.FixedColumnWidth(100),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Text('Agente', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Totale Prov.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                ...rows, // Aggiungiamo tutte le righe generate
              ],
            );
          },
        ),
      );

      print('Fine generazione dati per il PDF.');
      return pdf.save();
    } catch (e) {
      print('Errore durante la generazione del PDF: $e');
      rethrow;
    }
  }

  Future<void> getAllAgenti() async {
    try {
      print('Recupero agenti...');
      var apiUrl = Uri.parse('$ipaddress/api/agente');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<AgenteModel> agenti = [];
        for (var item in jsonData) {
          agenti.add(AgenteModel.fromJson(item));
        }
        setState(() {
          allAgenti = agenti;
        });
        await getAllPreventiviOrderedByAgente();
        print('Recupero agenti completato.');
      } else {
        throw Exception(
            'Failed to load agenti data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching agenti data from API: $e');
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

  Future<void> getAllPreventiviOrderedByAgente() async {
    try {
      print('Recupero preventivi...');
      for (var agente in allAgenti) {
        await getAllPreventiviForAgente(agente.id!);
      }
      print('Recupero preventivi completato.');
    } catch (e) {
      print('Error fetching preventivi data: $e');
    }
  }

  Future<void> getAllPreventiviForAgente(String agenteId) async {
    print('Inizio getAllPreventiviForAgente per agente $agenteId');
    try {
      var apiUrl = Uri.parse('$ipaddress/api/preventivo/agente/$agenteId');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<PreventivoModel> preventivi = [];
        for (var item in jsonData) {
          PreventivoModel preventivo = PreventivoModel.fromJson(item);
          preventivi.add(preventivo);
        }
        setState(() {
          preventiviPerAgenteMap[agenteId] = preventivi;
        });
      } else {
        throw Exception(
            'Failed to load preventivi data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching preventivi data from API for agente $agenteId: $e');
    }
    print('Fine getAllPreventiviForAgente per agente $agenteId');
  }
}
