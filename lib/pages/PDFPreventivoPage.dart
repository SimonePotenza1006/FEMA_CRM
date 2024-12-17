import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
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
import 'PDFInterventoPage.dart';

class PDFPreventivoPage extends StatefulWidget {
  final PreventivoModel preventivo;

  PDFPreventivoPage({required this.preventivo});

  @override
  _PDFPreventivoPageState createState() => _PDFPreventivoPageState();
}

class _PDFPreventivoPageState extends State<PDFPreventivoPage> {
  late Future<Uint8List> _pdfFuture;
  List<RelazionePreventivoProdottiModel> allProdotti = [];
  GlobalKey globalKey = GlobalKey();
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';

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
                      // 1. Chiudi il Dialog
                      Navigator.of(context).pop();

                      // 2. Genera il PDF
                      final pdfBytes = await _pdfFuture;

                      // 3. Invia l'email
                      try {
                        final String subject =
                            '(PREVENTIVO) ${widget.preventivo.id} ${DateFormat('yyyy').format(widget.preventivo.data_creazione!)} del ${DateFormat('dd/MM/yyyy').format(widget.preventivo.data_creazione!)}';
                        final String body =
                            'Allego il preventivo come richiesto.';
                        final List<String> recipients = ['info@femasistemi.it'];

                        // Genera un URL con i parametri dell'email
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: recipients.join(','),
                          queryParameters: {
                            'subject': subject,
                            'body': body,
                            'attachment':
                                'data:application/pdf;base64,${base64Encode(pdfBytes)}'
                          },
                        );

                        // Apre il client email predefinito del dispositivo
                        await launch(emailLaunchUri.toString());
                        print('Email inviata con successo.');
                      } catch (e) {
                        print('Errore durante l\'invio dell\'email: $e');
                      }
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
          '(PREVENTIVO) n ${widget.preventivo.id} del ${widget.preventivo.data_creazione}';
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

      // Determina il percorso del logo in base al nome dell'azienda
      String logoPath;
      switch (widget.preventivo.azienda?.nome) {
        case 'Fema srls':
          logoPath = 'assets/images/fema_logo.jpg';
          break;
        case 'NS Informatica di Federico Mazzei':
          logoPath = 'assets/images/ns_logo.jpg';
          break;
        case 'TEK SRL':
          logoPath = 'assets/images/fema_logo.jpg';
          break;
        default:
          // Logo di default nel caso in cui non corrisponda a nessuna delle aziende con logo specifico
          logoPath = 'assets/images/fema_logo.jpg';
      }

      final Uint8List logoBytes = await loadLogo(logoPath);



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
                              widget.preventivo.azienda!.nome!.toUpperCase(),
                              style: pw.TextStyle(
                                  fontSize:
                                      17), // Riduci la dimensione del font
                            ),
                            pw.SizedBox(height: 7),
                            pw.Text(widget.preventivo.azienda!.luogo_di_lavoro!,
                                style: pw.TextStyle(
                                    fontSize:
                                        6)), // Riduci la dimensione del font
                            pw.SizedBox(height: 2),
                            pw.Text(
                                'Tel. ${widget.preventivo.azienda!.telefono!}',
                                style: pw.TextStyle(
                                    fontSize:
                                        6)), // Riduci la dimensione del font
                            pw.SizedBox(height: 2),
                            pw.Text(
                                'C.F / P. iva ${widget.preventivo.azienda!.partita_iva!}',
                                style: pw.TextStyle(
                                    fontSize:
                                        6)), // Riduci la dimensione del font
                          ],
                        ),
                      ),
                      pw.Container(
                        margin: pw.EdgeInsets.only(
                            right: 25), // Aggiunge del margine a sinistra
                        width: 100, // Larghezza del logo
                        height: 100, // Altezza del logo
                        child: pw.Image(
                          pw.MemoryImage(logoBytes),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 1),
                  pw.Text("Preventivo ${widget.preventivo.azienda?.nome}",
                      style: pw.TextStyle(fontSize: 15)),
                  pw.SizedBox(height: 3),
                  pw.Text(
                      "n. ${widget.preventivo.id} / ${DateFormat('yyyy').format(widget.preventivo.data_creazione!)} del ${DateFormat('dd/MM/yyyy').format(widget.preventivo.data_creazione!)}"),
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

  // Metodo per recuperare i dati dei prodotti dal server
  Future<void> getProdotti() async {
    try {
      var apiUrl = Uri.parse(
          '$ipaddress/api/relazionePreventivoProdotto/preventivo/${widget.preventivo.id}');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<RelazionePreventivoProdottiModel> prodotti = [];
        for (var item in jsonData) {
          prodotti.add(RelazionePreventivoProdottiModel.fromJson(item));
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

  // Metodo per caricare il logo dell'azienda
  Future<Uint8List> loadLogo(String logoPath) async {
    final ByteData imageData = await rootBundle.load(logoPath);
    return Uint8List.view(imageData.buffer);
  }

  // Metodo per costruire la sezione del destinatario
  pw.Widget _buildDestinatarioSection() {
    final cliente = (widget.preventivo.cliente!.denominazione != null && widget.preventivo.cliente!.denominazione!.length > 20)
        ? widget.preventivo.cliente!.denominazione!.substring(0, 40)
        : widget.preventivo.cliente!.denominazione;
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
                      cliente.toString(),
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
                    child: pw.Text(
                      (widget.preventivo.cliente?.codice_fiscale ?? '') != ''
                          ? widget.preventivo.cliente!.codice_fiscale!
                          : widget.preventivo.cliente?.partita_iva ?? '',
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
    final cliente = (widget.preventivo.destinazione!.denominazione != null && widget.preventivo.destinazione!.denominazione!.length > 20)
        ? widget.preventivo.destinazione!.denominazione!.substring(0, 40)
        : widget.preventivo.destinazione!.denominazione;
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
                      cliente.toString(),
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
                      widget.preventivo.destinazione?.indirizzo ?? '',
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
                      widget.preventivo.destinazione?.cap ?? '',
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
                      widget.preventivo.destinazione?.citta ?? '',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: 45, right: 3),
                    child: pw.Text(
                      '(${widget.preventivo.destinazione?.provincia})',
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
                    child: pw.Text(
                      (widget.preventivo.destinazione?.codice_fiscale ?? '') !=
                              ''
                          ? widget.preventivo.destinazione!.codice_fiscale!
                          : widget.preventivo.destinazione?.partita_iva ?? '',
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
                      'Tel.',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 3),
                    child: pw.Text(
                      widget.preventivo.destinazione?.telefono ?? '',
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
                      widget.preventivo.destinazione?.cellulare ?? '',
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

  // Metodo per costruire la tabella dei prodotti
  pw.Widget _buildProdottiTable(
      List<RelazionePreventivoProdottiModel> relazione) {
    final headers = [
      'Codice',
      'Descrizione',
      'Quantità',
      'Prezzo',
      'Sconto',
      'Importo',
      'Iva'
    ];
    final List<List<dynamic>> data = relazione.map((relazione) {
      // Estrai il valore numerico dalla stringa percentuale
      double percentuale =
          double.parse(widget.preventivo.listino!.replaceAll('%', '')) / 100;
      double? prezzoListino = relazione.prodotto?.prezzo_fornitore ?? 0;

      // Calcola il prezzo considerando lo sconto
      double prezzo = prezzoListino + (prezzoListino * percentuale);

      double? importo = prezzo * relazione.quantita!;

      // Determina l'unità di misura
      String unitaMisura = relazione.prodotto?.unita_misura ?? '';
      bool isPezzi = unitaMisura == 'pz' || unitaMisura == 'PZ';

      // Formatta la quantità in base all'unità di misura
      String formattedQuantita = isPezzi
          ? relazione.quantita!.toInt().toString()
          : relazione.quantita!.toStringAsFixed(2);

      return [
        relazione.prodotto?.codice_danea,
        relazione.prodotto?.descrizione,
        formattedQuantita, // Usa la quantità formattata
        String.fromCharCode(128) + prezzo.toStringAsFixed(2),
        '',
        String.fromCharCode(128) + importo.toStringAsFixed(2),
        relazione.prodotto?.iva,
      ];
    }).toList();

    // Imposta la larghezza fissa per ogni colonna
    final List<pw.TableColumnWidth> columnWidths = [
      pw.FixedColumnWidth(60), // Codice
      pw.FixedColumnWidth(200), // Descrizione
      pw.FixedColumnWidth(50), // Quantità
      pw.FixedColumnWidth(50), // Prezzo
      pw.FixedColumnWidth(40), // Sconto
      pw.FixedColumnWidth(50), // Importo
      pw.FixedColumnWidth(30), // Iva
    ];

    num totaleImponibile = data.fold<num>(
        0,
        (previous, current) =>
            previous + (double.parse(current[5].substring(1)) ?? 0));
    num totaleIVA = data.fold<num>(
        0,
        (previous, current) =>
            previous +
            ((double.parse(current[5].substring(1)) ?? 0) *
                (double.parse(current[6]) ?? 0) /
                100));
    num totaleDocumento = totaleImponibile + totaleIVA;

    return pw.Column(
      children: [
        pw.Table.fromTextArray(
          headers: headers,
          data: data,
          border: null,
          headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 8), // Intestazioni più piccole
          cellAlignment: pw.Alignment.center, // Centra i dati delle colonne
          cellStyle: pw.TextStyle(fontSize: 9),
          headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
          cellHeight: 30,
          columnWidths: Map.fromIterables(
              Iterable<int>.generate(headers.length, (i) => i), columnWidths),
        ),
        //pw.SizedBox(height: 100),
        pw.Container(
          height: 1, // Altezza della riga nera
          color: PdfColors.black, // Colore della riga nera
        ),
        pw.Container(
          margin: pw.EdgeInsets.only(top: 1),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 4,
                child: pw.Container(
                  height: PdfPageFormat.cm * 4.5,
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Modalità di pagamento',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 8),
                      ),
                      pw.SizedBox(height: 55),
                      pw.Text(
                        'Tutti i prezzi indicati hanno validità 10 giorni',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontStyle:
                              pw.FontStyle.italic, // Aggiunge lo stile corsivo
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  height: PdfPageFormat.cm * 4.5,
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Acconto',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ),
              pw.Expanded(
                flex: 4,
                child: pw.Container(
                  color: PdfColors.grey200,
                  height: PdfPageFormat.cm * 4.5, // Altezza fissa
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Tot. Imponibile',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 8),
                          ),
                          pw.Spacer(), // Aggiunge spazio tra "Tot. Imponibile" e il risultato
                          pw.Text(
                            '${String.fromCharCode(128)} ${totaleImponibile.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 8),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 3),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Tot. IVA',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 8),
                          ),
                          pw.Spacer(), // Aggiunge spazio tra "Tot. IVA" e il risultato
                          pw.Text(
                            '${String.fromCharCode(128)} ${totaleIVA.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 8),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 90),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Tot. Documento',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 13),
                          ),
                          pw.Spacer(), // Aggiunge spazio tra "Tot. Documento" e il suo valore
                          pw.Text(
                            '${String.fromCharCode(128)} ${totaleDocumento.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
