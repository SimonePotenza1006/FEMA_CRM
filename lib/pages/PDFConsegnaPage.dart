import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:fema_crm/model/DDTModel.dart';
import 'package:fema_crm/model/PreventivoModel.dart';
import 'package:fema_crm/model/RelazioneDdtProdottiModel.dart';
import 'package:fema_crm/model/RelazionePreventivoProdottiModel.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;

import '../model/AziendaModel.dart';
import '../model/DestinazioneModel.dart';
import 'PDFInterventoPage.dart';

class PDFConsegnaPage extends StatefulWidget {
  final PreventivoModel preventivo;
  final DestinazioneModel? destinazione;
  final DateTime? data;
  final AziendaModel? azienda;


  PDFConsegnaPage({required this.preventivo, required this.destinazione, required this.data, required this.azienda});

  @override
  _PDFConsegnaPageState createState() => _PDFConsegnaPageState();
}

class _PDFConsegnaPageState extends State<PDFConsegnaPage> {
  late Future<Uint8List> _pdfFuture;
  List<RelazionePreventivoProdottiModel> allProdotti = [];
  GlobalKey globalKey = GlobalKey();
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';

  @override
  void initState() {
    super.initState();
    _pdfFuture = _generatePDF();
    globalKey = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generazione PDF'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Mostra il dialog quando viene premuto il FAB
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Confermare il documento di consegna?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      // Chiudi il dialog
                      Navigator.of(context).pop();
                    },
                    child: Text('No'),
                  ),
                  TextButton(
                    onPressed: () async {
                      // 1. Chiudi il Dialog
                      Navigator.of(context).pop();
                      await _generateAndSendPDF();
                    },
                    child: Text('Si'),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.arrow_forward, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Future<void> _generateAndSendPDF() async {
    try {
      // Genera il PDF
      final Uint8List pdfBytes = await _generatePDF();

      // Crea un file temporaneo
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/preventivo.pdf';
      final File tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(pdfBytes);

      // Prepara i dati per l'email
      final String smtpServerHost = 'mail.femasistemi.it';
      final String subject =
          '(DDT) DDT di consegna del preeventivo${widget.preventivo.id}, utente: ${widget.preventivo.utente?.nome} ${widget.preventivo.utente?.cognome} del ${widget.data}';
      final String body =
          'In allegato il PDF del preventivo numero ${widget.preventivo.id} rivolto al cliente ${widget.preventivo.cliente?.denominazione}';
      final String username =
          'noreply@femasistemi.it'; // Inserisci il tuo indirizzo email
      final String password = 'WGnr18@59.'; // Inserisci la tua password
      final int smtpServerPort = 465;
      final String recipient = 'info@femasistemi.it';

      // Configura il server SMTP
      final smtpServer = SmtpServer(
        smtpServerHost,
        port: smtpServerPort,
        username: username,
        password: password,
        ssl: true, // Utilizza SSL/TLS per la connessione SMTP
      );

      // Crea il messaggio email con allegato
      final message = Message()
        ..from = Address(username, 'App FEMA')
        ..recipients.add(recipient)
        ..subject = subject
        ..text = body
        ..attachments.add(FileAttachment(
          tempFile,
          fileName: 'rapportino.pdf',
        ));

      // Invia l'email
      final sendReport = await send(message, smtpServer);
      print('Email inviata con successo: $sendReport');

      // Elimina il file temporaneo
      await tempFile.delete();
    } catch (e) {
      print('Errore durante l\'invio dell\'email: $e');
    }
  }

  Future<Uint8List> _generatePDF() async {
    try {
      await getProdotti();

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          margin: pw.EdgeInsets.zero, // Rimuove tutti i margini
          build: (context) {
            return pw.Container(
              padding: pw.EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Intestazione con nome azienda, luogo di lavoro, telefono e partita IVA
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Container(
                        padding: pw.EdgeInsets.only(
                            left: 50), // Aggiunge un margine a sinistra
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              widget.azienda!.nome!.toUpperCase(),
                              style: pw.TextStyle(
                                  fontSize:
                                  17), // Riduci la dimensione del font
                            ),
                            pw.SizedBox(height: 7),
                            pw.Text(widget.azienda!.luogo_di_lavoro!,
                                style: pw.TextStyle(
                                    fontSize:
                                    6)), // Riduci la dimensione del font
                            pw.SizedBox(height: 2),
                            pw.Text('Tel. ${widget.azienda!.telefono!}',
                                style: pw.TextStyle(
                                    fontSize:
                                    6)), // Riduci la dimensione del font
                            pw.SizedBox(height: 2),
                            pw.Text(
                                'C.F / P. iva ${widget.azienda!.partita_iva!}',
                                style: pw.TextStyle(
                                    fontSize:
                                    6)), // Riduci la dimensione del font
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    "Doc. di Trasporto",
                    style: pw.TextStyle(
                        fontSize: 20, fontStyle: pw.FontStyle.italic),
                  ),
                  pw.SizedBox(height: 3),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDestinatarioSection(),
                      // Intestazione della destinazione
                      _buildDestinazioneSection(),
                    ],
                  ),
                  pw.SizedBox(
                      height:
                      10), // Aggiungi uno spazio prima della tabella dei prodott
                  _buildProdottiTable(
                      allProdotti), // Aggiungi la tabella dei prodotti
                ],
              ),
            );
          },
        ),
      );

      // Restituisci il PDF come byte array
      return pdf.save();
    } catch (e) {
      print('Errore durante la generazione del PDF: $e');
      rethrow;
    }
  }

  pw.Widget _buildDestinatarioSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Destinatario',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 9,
          ),
        ),
        pw.SizedBox(height: 1),
        pw.Container(
          width: PdfPageFormat.cm * 9.5,
          height: PdfPageFormat.cm * 3,
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            border: pw.Border.all(
              color: PdfColors.black,
              width: 1,
            ),
          ),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: 3, right: 3),
                    child: pw.Text(
                      'DENOMINAZIONE',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 3),
                    child: pw.Text(
                      widget.preventivo.cliente?.denominazione ?? '',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: 3, right: 3),
                    child: pw.Text(
                      'INDIRIZZO',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 3),
                    child: pw.Text(
                      widget.preventivo.cliente?.indirizzo ?? '',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: 3, right: 3),
                    child: pw.Text(
                      'CAP',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 3),
                    child: pw.Text(
                      widget.preventivo.cliente?.cap ?? '',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: 30, right: 3),
                    child: pw.Text(
                      'CITTÀ',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 3),
                    child: pw.Text(
                      widget.preventivo.cliente?.citta ?? '',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: 45, right: 3),
                    child: pw.Text(
                      '(${widget.preventivo.cliente?.provincia})',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: 3, right: 3),
                    child: pw.Text(
                      'C.F./P.Iva',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 3),
                    // child: pw.Text(
                    //   (widget.ddt.intervento?.cliente.codice_fiscale ?? '') != ''
                    //       ? widget.ddt.intervento?.cliente.codice_fiscale
                    //       : widget.ddt.intervento?.cliente.partita_iva ?? '',
                    //   style: pw.TextStyle(fontSize: 9),
                    // ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: 3, right: 3),
                    child: pw.Text(
                      'Tel.',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 3),
                    child: pw.Text(
                      widget.preventivo.cliente?.telefono ?? '',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: 40, right: 3),
                    child: pw.Text(
                      'Cell.',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 3),
                    child: pw.Text(
                      widget.preventivo.cliente?.cellulare ?? '',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Metodo per costruire la sezione della destinazione
  pw.Widget _buildDestinazioneSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Destinazione',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 9,
          ),
        ),
        pw.SizedBox(height: 1),
        pw.Container(
          width: PdfPageFormat.cm * 9.5,
          height: PdfPageFormat.cm * 3,
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            border: pw.Border.all(
              color: PdfColors.black,
              width: 1,
            ),
          ),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: 3, right: 3),
                    child: pw.Text(
                      'DENOMINAZIONE',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 3),
                    child: pw.Text(
                      widget.destinazione?.denominazione ?? '',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: 3, right: 3),
                    child: pw.Text(
                      'INDIRIZZO',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 3),
                    child: pw.Text(
                      widget.destinazione?.indirizzo ?? '',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: 3, right: 3),
                    child: pw.Text(
                      'CAP',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 3),
                    child: pw.Text(
                      widget.destinazione?.cap ?? '',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: 30, right: 3),
                    child: pw.Text(
                      'CITTÀ',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 3),
                    child: pw.Text(
                      widget.destinazione?.citta ?? '',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: 45, right: 3),
                    child: pw.Text(
                      '(${widget.destinazione?.provincia})',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: 3, right: 3),
                    child: pw.Text(
                      'C.F./P.Iva',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 3),
                    // child: pw.Text(
                    //   (widget.ddt.intervento?.destinazione?.codice_fiscale ?? '') != ''
                    //       ? widget.ddt.intervento!.destinazione.codice_fiscale
                    //       : widget.ddt.intervento?.destinazione.partita_iva ?? '',
                    //   style: pw.TextStyle(fontSize: 9),
                    // ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: 3, right: 3),
                    child: pw.Text(
                      'Tel.',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 3),
                    child: pw.Text(
                      widget.destinazione?.telefono ?? '',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: 40, right: 3),
                    child: pw.Text(
                      'Cell.',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 3),
                    child: pw.Text(
                      widget.destinazione?.cellulare ?? '',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> getProdotti() async {
    try {
      var apiUrl = Uri.parse(
          '$ipaddress2/api/relazionePreventivoProdotto/preventivo/${widget.preventivo.id}');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<RelazionePreventivoProdottiModel> prodotti = [];
        for (var item in jsonData) {
          prodotti.add(RelazionePreventivoProdottiModel.fromJson(item));
          debugPrint("PROVA PROVA" + item.toString(), wrapWidth: 1024);
        }
        setState(() {
          allProdotti = prodotti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
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

  pw.Widget _buildProdottiTable(List<RelazionePreventivoProdottiModel> relazione) {
    final headers = ['Codice', 'Descrizione', 'Quantità'];
    final List<List<dynamic>> data = relazione.map((relazione) {
      double? prezzo = relazione.prodotto?.prezzo_fornitore ?? 0;

      String unitaMisura = relazione.prodotto?.unita_misura ?? '';
      bool isPezzi = unitaMisura == 'pz' || unitaMisura == 'PZ';

      String formattedQuantita = isPezzi
          ? relazione.quantita!.toInt().toString()
          : relazione.quantita!.toStringAsFixed(2);
      double? importo = double.parse(formattedQuantita) *
          double.parse(relazione.prodotto!.prezzo_fornitore.toString());

      return [
        relazione.prodotto?.codice_danea,
        relazione.prodotto?.descrizione,
        formattedQuantita,
      ];
    }).toList();

    // Imposta la larghezza fissa per ogni colonna
    final List<pw.TableColumnWidth> columnWidths = [
      pw.FixedColumnWidth(60),
      // Codice
      pw.FixedColumnWidth(300),
      // Descrizione (aumentata la larghezza rispetto alle altre colonne)
      pw.FixedColumnWidth(50),
      // Quantità
    ];

    // Calcolare il totale dell'imponibile e dell'IVA
    // Calcolare il totale dell'imponibile e dell'IVA
    num totaleImponibile = data.fold<num>(
        0, (previous, current) => previous + (double.parse(current[2]) ?? 0));
    num totaleDocumento = totaleImponibile;

    return pw.Column(
      children: [
        pw.Table.fromTextArray(
          headers: headers,
          data: data,
          border: null,
          headerStyle:
          pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
          // Intestazioni più piccole
          cellAlignment: pw.Alignment.center,
          // Centra i dati delle colonne
          cellStyle: pw.TextStyle(fontSize: 9),
          headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
          cellHeight: 30,
          columnWidths: Map.fromIterables(
              Iterable<int>.generate(headers.length, (i) => i), columnWidths),
        ),
        pw.SizedBox(height: 20),
        pw.Container(
          height: 1, // Altezza della riga nera
          color: PdfColors.black, // Colore della riga nera
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          margin: pw.EdgeInsets.only(top: 1),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Incaricato del trasporto',
                  style: pw.TextStyle(fontSize: 7)),
              pw.Text('Causale del trasporto',
                  style: pw.TextStyle(fontSize: 7)),
              pw.Text('Porto', style: pw.TextStyle(fontSize: 6)),
              pw.Text('Firma incaricato del trasporto',
                  style: pw.TextStyle(fontSize: 7)),
              pw.Text('Firma destinatario', style: pw.TextStyle(fontSize: 7))
            ],
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Container(
          margin: pw.EdgeInsets.only(top: 1),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment
                .start, // Allinea gli elementi all'inizio della riga
            children: [
              pw.Container(
                width: PdfPageFormat.cm * 2, // Larghezza per ogni elemento
                child: pw.Text('Nr. colli', style: pw.TextStyle(fontSize: 7)),
              ),
              pw.Container(
                width: PdfPageFormat.cm * 2, // Larghezza per ogni elemento
                child: pw.Text('Peso', style: pw.TextStyle(fontSize: 7)),
              ),
              pw.Container(
                width: PdfPageFormat.cm * 3.5, // Larghezza per ogni elemento
                child: pw.Text('Aspetto esteriore dei beni',
                    style: pw.TextStyle(fontSize: 7)),
              ),
              pw.Container(
                width: PdfPageFormat.cm * 3, // Larghezza per ogni elemento
                child: pw.Text('Data e ora inizio trasporto',
                    style: pw.TextStyle(fontSize: 7)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
