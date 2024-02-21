import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../model/InterventoModel.dart';

class PDFInterventoPage extends StatefulWidget {
  final InterventoModel intervento;

  PDFInterventoPage({required this.intervento});

  @override
  _PDFInterventoPageState createState() => _PDFInterventoPageState();
}

class _PDFInterventoPageState extends State<PDFInterventoPage> {
  late Future<Uint8List> _pdfFuture;

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
    );
  }

  Future<Uint8List> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Container(
                margin: pw.EdgeInsets.only(top: 30),
                alignment: pw.Alignment.topCenter,
                height: PdfPageFormat.cm * 3.7,
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
              pw.Positioned(
                left: 30,
                top: 80,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
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
                    pw.SizedBox(height: 1),
                    pw.Container(
                      width: PdfPageFormat.cm * 7.5,
                      height: 1,
                      color: PdfColors.black,
                    ),
                    pw.SizedBox(height: 15),
                    pw.Text(
                      'Destinatario',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                    pw.SizedBox(height: 1),
                    pw.Container(
                      width: PdfPageFormat.cm * 9,
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
                                padding: pw.EdgeInsets.only(left: 3, right: 3),
                                child: pw.Text(
                                  'DENOMINAZIONE',
                                  style: pw.TextStyle(fontSize: 9),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.only(right: 3),
                                child: pw.Text(
                                  widget.intervento.cliente?.denominazione ?? '',
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
                                  widget.intervento.cliente?.indirizzo ?? '',
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
                                  widget.intervento.cliente?.cap ?? '',
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
                                  widget.intervento.cliente?.citta ?? '',
                                  style: pw.TextStyle(fontSize: 9),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.only(left: 45, right: 3),
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
                                padding: pw.EdgeInsets.only(left: 3, right: 3),
                                child: pw.Text(
                                  'C.F./P.Iva',
                                  style: pw.TextStyle(fontSize: 9),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.only(right: 3),
                                child: pw.Text(
                                  (widget.intervento.cliente?.codice_fiscale ?? '') != ''
                                      ? widget.intervento.cliente!.codice_fiscale!
                                      : widget.intervento.cliente?.partita_iva ?? '',
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
                                  widget.intervento.cliente?.telefono ?? '',
                                  style: pw.TextStyle(fontSize: 9),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Stack(
                      children: [
                        pw.Expanded(
                          child: pw.Positioned(
                            left: 30,
                            top: 220,
                            child: pw.Table(
                              border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                              columnWidths: {
                                0: pw.FlexColumnWidth(1), // Colonna 1
                                1: pw.FlexColumnWidth(1), // Colonna 2
                                2: pw.FlexColumnWidth(1), // Colonna 3
                                3: pw.FlexColumnWidth(1), // Colonna 4
                                4: pw.FlexColumnWidth(1), // Colonna 5
                                5: pw.FlexColumnWidth(1), // Colonna 6
                              },
                              children: [
                                pw.TableRow(
                                  children: [
                                    pw.Padding(
                                      padding: pw.EdgeInsets.all(5),
                                      child: pw.Text('Prodotto'),
                                    ),
                                    pw.Padding(
                                      padding: pw.EdgeInsets.all(5),
                                      child: pw.Text('Quantità'),
                                    ),
                                    pw.Padding(
                                      padding: pw.EdgeInsets.all(5),
                                      child: pw.Text('Prezzo Ivato'),
                                    ),
                                    pw.Padding(
                                      padding: pw.EdgeInsets.all(5),
                                      child: pw.Text('Sconto'),
                                    ),
                                    pw.Padding(
                                      padding: pw.EdgeInsets.all(5),
                                      child: pw.Text('Importo'),
                                    ),
                                    pw.Padding(
                                      padding: pw.EdgeInsets.all(5),
                                      child: pw.Text('Iva'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.topRight,
                margin: pw.EdgeInsets.only(top: 10, right: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'FEDERICO MAZZEI',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
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
              ),
              pw.Positioned(
                right: 30,
                top: 80,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(
                      children: [
                        pw.Text(
                          'Rapporto d\'intervento nr. ${widget.intervento.id}',
                          style: pw.TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        pw.SizedBox(width: 5),
                        pw.Text(
                          'del ${DateFormat('dd/MM/yyyy').format(widget.intervento.data!)}',
                          style: pw.TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
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
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Destinazione',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                    pw.SizedBox(height: 1),
                    pw.Container(
                      width: PdfPageFormat.cm * 9,
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
                                padding: pw.EdgeInsets.only(left: 3, right: 3),
                                child: pw.Text(
                                  'DENOMINAZIONE',
                                  style: pw.TextStyle(fontSize: 9),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.only(right: 3),
                                child: pw.Text(
                                  widget.intervento.destinazione?.denominazione ?? '',
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
                                  widget.intervento.destinazione?.indirizzo ?? '',
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
                                  widget.intervento.destinazione?.cap ?? '',
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
                                  widget.intervento.destinazione?.citta ?? '',
                                  style: pw.TextStyle(fontSize: 9),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.only(left: 45, right: 3),
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
                                padding: pw.EdgeInsets.only(left: 3, right: 3),
                                child: pw.Text(
                                  'C.F./P.Iva',
                                  style: pw.TextStyle(fontSize: 9),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.only(right: 3),
                                child: pw.Text(
                                  (widget.intervento.destinazione?.codice_fiscale ?? '') != ''
                                      ? widget.intervento.destinazione!.codice_fiscale!
                                      : widget.intervento.destinazione?.partita_iva ?? '',
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
                                  widget.intervento.destinazione?.telefono ?? '',
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
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}

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