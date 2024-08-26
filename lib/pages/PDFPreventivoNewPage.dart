import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:fema_crm/pages/DettaglioPreventivoAmministrazionePage.dart';
import 'package:flutter/rendering.dart';
import 'package:fema_crm/model/PreventivoModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:email_validator/email_validator.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'dart:io' as io;
import '../databaseHandler/DbHelper.dart';
import '../model/RelazionePreventivoProdottiModel.dart';
import 'PDFInterventoPage.dart';

class PDFPreventivoNewPage extends StatefulWidget{
  final PreventivoModel preventivo;
  final List<RelazionePreventivoProdottiModel> relazioni;

  PDFPreventivoNewPage({required this.preventivo, required this.relazioni});

  @override
  _PDFPreventivoNewPageState createState() => _PDFPreventivoNewPageState();
}

class _PDFPreventivoNewPageState extends State<PDFPreventivoNewPage>{
  late DateTime dateora;
  late io.File fileAss;
  DbHelper? dbHelper;
  late String path;
  Future<io.File>? _pdfFileFuture;
  late Future<void> _future;
  bool _isFileInitialized = false;

  @override
  void initState() {
    dateora = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch);
    dbHelper = DbHelper();
    super.initState();
    _pdfFileFuture = initializeFile(); // Initialize the file when the state is initialized
  }

  Future<io.File> initializeFile() async {
    final directory = await getApplicationSupportDirectory();
    path = directory.path;
    dateora = DateTime.now();
    fileAss = io.File('$path/Noleggio_Auto_${dateora.millisecondsSinceEpoch}.pdf');
    await makePdfAss();
    setState(() {
      _isFileInitialized = true; // Set flag to true once file is initialized
    });
    print('Directory path: $path');
    return fileAss;
  }

  Future<io.File> makePdfAss() async{
    final List<List<dynamic>> data = widget.relazioni.map((relazione) {
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

    final pdfAss = pw.Document();
    double? TotDocumento = widget.preventivo.importo;
    final logoImageFema = pw.MemoryImage(
        (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
    );
    final logoImageNs = pw.MemoryImage(
        (await rootBundle.load('assets/images/ns_logo.jpg')).buffer.asUint8List(),
    );
    pdfAss.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        footer: (context) => pw.Column(
          children:[
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
                                '${String.fromCharCode(128)} ${widget.preventivo.importo?.toStringAsFixed(2)}',
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
          ]
        ),
        //FINE FOOTER
        build: (context) =>[
          pw.Container(
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
                  pw.MemoryImage(logoImageFema.bytes),
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
              widget.relazioni), // Aggiungi la tabella dei prodotti
        ],
      ),
    )
        ]
      )
    );
    final bytes = await pdfAss.save();
    final dir = await getApplicationSupportDirectory();
    final file = io.File('${dir.path}/Noleggio_Auto_${dateora.millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes);
    await fileAss.writeAsBytes(await pdfAss.save().whenComplete(() async {
      await Future.delayed(Duration(seconds: 2)).then((val) async {
        dbHelper?.uploadPdfNoleggio((fileAss.path), fileAss).whenComplete(() {
          //alertDialog('Pdf salvato con successo');
        });
      });
    }));
    return file;
  }

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
      ],
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 40,),
                      //spPlatform == 'windows' ?
                      FloatingActionButton.extended(heroTag: 'stampa',
                          icon: Icon(Icons.print),
                          label: Text("Stampa"),
                          onPressed: () async {
                            // await Printing.layoutPdf(
                            //     onLayout: (PdfPageFormat format) async => unita!);
                          }),
                    ]) //: Container(),
              ])),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Preventivo N ${widget.preventivo.id}',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        ),
        leading: BackButton(
          onPressed: (){Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>  DettaglioPreventivoAmministrazionePage(preventivo: widget.preventivo)
            ),
          );},
          color: Colors.white,
        ),
      ),
      body: FutureBuilder<io.File>(
        future: _pdfFileFuture,
        builder: (BuildContext context, AsyncSnapshot<io.File> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final file = snapshot.data!;
            return SfPdfViewer.file(file);
          } else {
            return Center(child: Text('No PDF file generated.'));
          }
        },
      ),
    );
  }
}

