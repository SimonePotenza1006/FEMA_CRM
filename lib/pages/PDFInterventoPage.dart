import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../model/InterventoModel.dart';
import 'package:flutter/services.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:url_launcher/url_launcher.dart';

// Definiamo il widget per la generazione del PDF
class PDFInterventoPage extends StatefulWidget {
  final InterventoModel intervento;
  final String descrizione;
  final String importo;

  PDFInterventoPage(
      {required this.intervento,
      required this.descrizione,
      required this.importo});

  @override
  _PDFInterventoPageState createState() => _PDFInterventoPageState();
}

class _PDFInterventoPageState extends State<PDFInterventoPage> {
  late Future<Uint8List> _pdfFuture;
  String ipaddress = 'http://gestione.femasistemi.it:8090';

  @override
  void initState() {
    super.initState();
    _pdfFuture = _generatePDF();
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
            return Center(child: Text('Errore durante la generazione del PDF'));
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
                title: Text('Confermare il preventivo?'),
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
      final tempFilePath = '${tempDir.path}/rapportino.pdf';
      final File tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(pdfBytes);

      // Prepara i dati per l'email
      final String smtpServerHost = 'mail.femasistemi.it';
      final String subject =
          '(INTERVENTO) n ${widget.intervento.id} del ${widget.intervento.data}';
      final String body =
          'In allegato il PDF del rapportino d\'intervento del cliente ${widget.intervento.cliente?.denominazione}';
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

  // Metodo per generare il PDF
  Future<Uint8List> _generatePDF() async {
    final pdf = pw.Document();
    const IconData euro_symbol = IconData(0xe23c, fontFamily: 'MaterialIcons');
    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.symmetric(
            horizontal: 20), // Aggiungi margine a destra e sinistra
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Prima riga
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  // Prima colonna
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Padding(
                        // Applichiamo il padding solo nella parte superiore
                        // Il valore 10 può essere personalizzato a seconda delle tue esigenze
                        padding: pw.EdgeInsets.only(top: 10),
                        child: pw.Text(
                          'FEDERICO MAZZEI',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Text(
                        'TEL. 0832 / 401296',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Seconda colonna
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Padding(
                        // Applichiamo il padding solo nella parte superiore
                        // Il valore 10 può essere personalizzato a seconda delle tue esigenze
                        padding: pw.EdgeInsets.only(top: 10),
                        child: pw.Text(
                          'INTERVENTO TECNICO',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 20,
                            decoration: pw.TextDecoration.underline,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 20),
                      pw.Text(
                        'TECNICO: ${widget.intervento.utente?.nome} ${widget.intervento.utente?.cognome}',
                        style: pw.TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      pw.SizedBox(height: 1),
                      pw.Container(
                        width: PdfPageFormat.cm * 7.5,
                        height: 1,
                        color: PdfColors.black,
                      ),
                      pw.SizedBox(height: 15),
                      pw.Text(
                        'MEZZO: ${widget.intervento.veicolo?.descrizione}',
                        style: pw.TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      pw.Container(
                        width: PdfPageFormat.cm * 7.5,
                        height: 1,
                        color: PdfColors.black,
                      )
                    ],
                  ),
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 23),
                      pw.Text(
                        'Rapporto d\'intervento nr. ${widget.intervento.id} del ${DateFormat('dd/MM/yyyy').format(widget.intervento.data!)}',
                        style: pw.TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'ORA INIZIO INTERVENTO: ${DateFormat('HH:mm').format(widget.intervento.orario_inizio!)}',
                        style: pw.TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'ORA FINE INTERVENTO: ${DateFormat('HH:mm').format(widget.intervento.orario_fine!)}',
                        style: pw.TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
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
                                  padding:
                                      pw.EdgeInsets.only(left: 3, right: 3),
                                  child: pw.Text(
                                    'DENOMINAZIONE',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(right: 3),
                                  child: pw.Text(
                                    widget.intervento.cliente?.denominazione ??
                                        '',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                              ],
                            ),
                            pw.Row(
                              children: [
                                pw.Padding(
                                  padding:
                                      pw.EdgeInsets.only(left: 3, right: 3),
                                  child: pw.Text(
                                    'INDIRIZZO',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(right: 3),
                                  child: pw.Text(
                                    widget.intervento.cliente?.indirizzo ?? '',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                              ],
                            ),
                            pw.Row(
                              children: [
                                pw.Padding(
                                  padding:
                                      pw.EdgeInsets.only(left: 3, right: 3),
                                  child: pw.Text(
                                    'CAP',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(right: 3),
                                  child: pw.Text(
                                    widget.intervento.cliente?.cap ?? '',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding:
                                      pw.EdgeInsets.only(left: 30, right: 3),
                                  child: pw.Text(
                                    'CITTÀ',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(right: 3),
                                  child: pw.Text(
                                    widget.intervento.cliente?.citta ?? '',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding:
                                      pw.EdgeInsets.only(left: 45, right: 3),
                                  child: pw.Text(
                                    '(${widget.intervento.cliente?.provincia})',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                              ],
                            ),
                            pw.Row(
                              children: [
                                pw.Padding(
                                  padding:
                                      pw.EdgeInsets.only(left: 3, right: 3),
                                  child: pw.Text(
                                    'C.F./P.Iva',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(right: 3),
                                  child: pw.Text(
                                    (widget.intervento.cliente
                                                    ?.codice_fiscale ??
                                                '') !=
                                            ''
                                        ? widget
                                            .intervento.cliente!.codice_fiscale!
                                        : widget.intervento.cliente
                                                ?.partita_iva ??
                                            '',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                              ],
                            ),
                            pw.Row(
                              children: [
                                pw.Padding(
                                  padding:
                                      pw.EdgeInsets.only(left: 3, right: 3),
                                  child: pw.Text(
                                    'Tel.',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(right: 3),
                                  child: pw.Text(
                                    widget.intervento.cliente?.telefono ?? '',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding:
                                      pw.EdgeInsets.only(left: 40, right: 3),
                                  child: pw.Text(
                                    'Cell.',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(right: 3),
                                  child: pw.Text(
                                    widget.intervento.cliente?.cellulare ?? '',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
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
                                  padding:
                                      pw.EdgeInsets.only(left: 3, right: 3),
                                  child: pw.Text(
                                    'DENOMINAZIONE',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(right: 3),
                                  child: pw.Text(
                                    widget.intervento.destinazione
                                            ?.denominazione ??
                                        '',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                              ],
                            ),
                            pw.Row(
                              children: [
                                pw.Padding(
                                  padding:
                                      pw.EdgeInsets.only(left: 3, right: 3),
                                  child: pw.Text(
                                    'INDIRIZZO',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(right: 3),
                                  child: pw.Text(
                                    widget.intervento.destinazione?.indirizzo ??
                                        '',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                              ],
                            ),
                            pw.Row(
                              children: [
                                pw.Padding(
                                  padding:
                                      pw.EdgeInsets.only(left: 3, right: 3),
                                  child: pw.Text(
                                    'CAP',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(right: 3),
                                  child: pw.Text(
                                    widget.intervento.destinazione?.cap ?? '',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding:
                                      pw.EdgeInsets.only(left: 30, right: 3),
                                  child: pw.Text(
                                    'CITTÀ',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(right: 3),
                                  child: pw.Text(
                                    widget.intervento.destinazione?.citta ?? '',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding:
                                      pw.EdgeInsets.only(left: 45, right: 3),
                                  child: pw.Text(
                                    '(${widget.intervento.destinazione?.provincia})',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                              ],
                            ),
                            pw.Row(
                              children: [
                                pw.Padding(
                                  padding:
                                      pw.EdgeInsets.only(left: 3, right: 3),
                                  child: pw.Text(
                                    'C.F./P.Iva',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(right: 3),
                                  child: pw.Text(
                                    (widget.intervento.destinazione
                                                    ?.codice_fiscale ??
                                                '') !=
                                            ''
                                        ? widget.intervento.destinazione!
                                            .codice_fiscale!
                                        : widget.intervento.destinazione
                                                ?.partita_iva ??
                                            '',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                              ],
                            ),
                            pw.Row(
                              children: [
                                pw.Padding(
                                  padding:
                                      pw.EdgeInsets.only(left: 3, right: 3),
                                  child: pw.Text(
                                    'Tel.',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(right: 3),
                                  child: pw.Text(
                                    widget.intervento.destinazione?.telefono ??
                                        '',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding:
                                      pw.EdgeInsets.only(left: 40, right: 3),
                                  child: pw.Text(
                                    'Cell.',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(right: 3),
                                  child: pw.Text(
                                    widget.intervento.destinazione?.cellulare ??
                                        '',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                height: PdfPageFormat.cm * 16,
                child: pw.Table(
                  border: pw.TableBorder(
                    bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                  ),
                  columnWidths: {
                    0: pw.FractionColumnWidth(0.5),
                    1: pw.FractionColumnWidth(0.1),
                    2: pw.FractionColumnWidth(0.1),
                    3: pw.FractionColumnWidth(0.1),
                    4: pw.FractionColumnWidth(0.1),
                    5: pw.FractionColumnWidth(0.1),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Container(
                              padding: pw.EdgeInsets.only(bottom: 5),
                              child: pw.Text(
                                'Prodotto',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9,
                                  color: PdfColors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Container(
                              padding: pw.EdgeInsets.only(bottom: 5),
                              child: pw.Text(
                                'Quantità',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9,
                                  color: PdfColors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Container(
                              padding: pw.EdgeInsets.only(bottom: 5),
                              child: pw.Text(
                                'Prezzo Ivato',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9,
                                  color: PdfColors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Container(
                              padding: pw.EdgeInsets.only(bottom: 5),
                              child: pw.Text(
                                'Sconto',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9,
                                  color: PdfColors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Container(
                              padding: pw.EdgeInsets.only(bottom: 5),
                              child: pw.Text(
                                'Importo',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9,
                                  color: PdfColors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Container(
                              padding: pw.EdgeInsets.only(bottom: 5),
                              child: pw.Text(
                                'Iva',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9,
                                  color: PdfColors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Aggiungo la row richiesta

              pw.SizedBox(height: 30),
              pw.Text('${widget.descrizione}',
                  style: pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 120),
              if(widget.intervento.conclusione_parziale == false)
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 8),
                  child: pw.Text(
                    'INTERVENTO NON CONCLUSO',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              pw.Container(
                height: PdfPageFormat.cm * 3.5,
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            top:
                                pw.BorderSide(color: PdfColors.black, width: 1),
                            bottom:
                                pw.BorderSide(color: PdfColors.black, width: 1),
                            right:
                                pw.BorderSide(color: PdfColors.black, width: 1),
                          ),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            // Testo "Pagamento" con valore di widget.intervento?.tipologiaPagamento.descrizione
                            pw.Padding(
                              padding:
                                  pw.EdgeInsets.only(top: 8, left: 8, right: 8),
                              child: pw.Text(
                                'Pagamento: ${widget.intervento.tipologia_pagamento?.descrizione.toString()}',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 20),
                            pw.Padding(
                              padding: pw.EdgeInsets.symmetric(horizontal: 8),
                              child: pw.Text(
                                'Acconto',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              top: pw.BorderSide(
                                  color: PdfColors.black, width: 1),
                              bottom: pw.BorderSide(
                                  color: PdfColors.black, width: 1),
                            ),
                          ),
                          child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(
                                      top: 8, left: 8, right: 8),
                                  child: pw.Text(
                                    'Tot. imponibile:',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.SizedBox(height: 2),
                                pw.Padding(
                                  padding:
                                      pw.EdgeInsets.only(left: 8, right: 8),
                                  child: pw.Text(
                                    'Tot. Iva:',
                                    style: pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                                pw.SizedBox(height: 10),
                                pw.Padding(
                                  padding:
                                      pw.EdgeInsets.only(left: 8, right: 8),
                                  child: pw.Row(
                                    children: [
                                      pw.Text(
                                        'Tot. documento: ${widget.importo}' +
                                            String.fromCharCode(128),
                                        style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                pw.SizedBox(height: 2),
                                pw.Container(
                                  width: PdfPageFormat.cm * 7.5,
                                  height: 1,
                                  color: PdfColors.black,
                                ),
                                pw.SizedBox(height: 2),
                                pw.Padding(
                                  padding: pw.EdgeInsets.only(left: 8),
                                  child: pw.Row(
                                    children: [
                                      pw.SizedBox(height: 30),
                                      pw.Text('SALDATO:'),
                                      pw.Padding(
                                        padding:
                                            const pw.EdgeInsets.only(left: 8.0),
                                        child: pw.Container(
                                          decoration: pw.BoxDecoration(
                                            border: pw.Border.all(
                                                color: PdfColors.black,
                                                width: 1.0),
                                          ),
                                          padding: const pw.EdgeInsets.all(4.0),
                                          child: pw.Row(
                                            children: [
                                              pw.Checkbox(
                                                value: widget
                                                        .intervento.saldato ==
                                                    true, // Imposta il valore della checkbox "SI" in base a widget.intervento.saldato
                                                name: '',
                                              ), // Checkbox "SI" se widget.intervento.saldato è true, altrimenti "NO"
                                              pw.Container(
                                                padding: const pw
                                                    .EdgeInsets.symmetric(
                                                    horizontal: 4.0),
                                                child: pw.FittedBox(
                                                  fit: pw.BoxFit.scaleDown,
                                                  alignment:
                                                      pw.Alignment.center,
                                                  child: pw.Text('SI'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      pw.Padding(
                                        padding:
                                            const pw.EdgeInsets.only(left: 8.0),
                                        child: pw.Container(
                                          decoration: pw.BoxDecoration(
                                            border: pw.Border.all(
                                                color: PdfColors.black,
                                                width: 1.0),
                                          ),
                                          padding: const pw.EdgeInsets.all(4.0),
                                          child: pw.Row(
                                            children: [
                                              pw.Checkbox(
                                                value: widget
                                                        .intervento.saldato ==
                                                    false, // Imposta il valore della checkbox "NO" in base a widget.intervento.saldato
                                                name: '',
                                              ), // Checkbox "NO" se widget.intervento.saldato è true, altrimenti "SI"
                                              pw.Container(
                                                padding: const pw
                                                    .EdgeInsets.symmetric(
                                                    horizontal: 2.0),
                                                child: pw.FittedBox(
                                                  fit: pw.BoxFit.scaleDown,
                                                  alignment:
                                                      pw.Alignment.center,
                                                  child: pw.Text('NO'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ])),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }
}

// Widget per visualizzare il PDF generato
class PDFViewerPage extends StatelessWidget {
  final Uint8List pdfBytes;

  PDFViewerPage({required this.pdfBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Visualizzato'),
      ),
      body: PdfPreview(
        // Utilizza il widget PdfPreview fornito dalla libreria pdf per visualizzare il PDF
        build: (format) => pdfBytes,
      ),
    );
  }
}