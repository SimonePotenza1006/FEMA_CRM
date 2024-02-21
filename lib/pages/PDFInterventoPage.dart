// Importiamo le librerie necessarie
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../model/InterventoModel.dart';

// Definiamo il widget per la generazione del PDF
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

  // Metodo per generare il PDF
  Future<Uint8List> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.symmetric(horizontal: 20), // Aggiungi margine a destra e sinistra
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
                                    widget.intervento.destinazione?.cellulare ?? '',
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
              pw.SizedBox(height: 10),
              pw.Container(
                height: PdfPageFormat.cm * 3.5,
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            top: pw.BorderSide(color: PdfColors.black, width: 1),
                            bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                            right: pw.BorderSide(color: PdfColors.black, width: 1),
                          ),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            // Testo "Pagamento" con valore di widget.intervento?.tipologiaPagamento.descrizione
                            pw.Padding(
                              padding: pw.EdgeInsets.only(top: 8, left: 8, right: 8),
                              child: pw.Text(
                                'Pagamento: ${widget.intervento.tipologia_pagamento?.descrizione.toString()}',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
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
                            top: pw.BorderSide(color: PdfColors.black, width: 1),
                            bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                          ),
                        ),
                        // Contenuto della colonna di destra
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
