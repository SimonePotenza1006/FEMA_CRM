import 'dart:convert';
import 'dart:typed_data';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'dart:io';

import '../model/ClienteModel.dart';
import '../model/InterventoModel.dart';
import '../model/MovimentiModel.dart';
import 'PDFInterventoPage.dart';

class PDFPagamentoAccontoPage extends StatefulWidget{
  final UtenteModel? utente;
  final DateTime? data;
  final String? importo;
  final TipoMovimentazione tipoMovimentazione;
  final String? descrizione;
  final ClienteModel? cliente;
  final InterventoModel? intervento;
  final Uint8List? firmaCassa;
  final Uint8List? firmaIncaricato;

  PDFPagamentoAccontoPage({
    required this.descrizione,
    required this.utente,
    required this.data,
    required this.importo,
    required this.tipoMovimentazione,
    required this.cliente,
    required this.intervento,
    required this.firmaCassa,
    required this.firmaIncaricato,
  });

  @override
  _PDFPagamentoAccontoPageState createState() => _PDFPagamentoAccontoPageState();
}

class _PDFPagamentoAccontoPageState extends State<PDFPagamentoAccontoPage>{
  late Future<Uint8List> _pdfFuture;
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();
  final GlobalKey<SfSignaturePadState> signatureGlobalKeyDip = GlobalKey();

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
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       setState(() {
        //         _pdfFuture = _generatePDF();
        //       });
        //     },
        //     icon: Icon(Icons.refresh),
        //   ),
        // ],
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
            ],
          ),
        ),
      ),
    );
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
                    "Documento di ${widget.tipoMovimentazione.toString().substring(19)} in data ${DateFormat('dd/MM/yyyy').format(widget.data!)}, relativa all\'intervento con ID ${widget.intervento?.id}, descrizione: ${widget.intervento?.descrizione} ",
                    style: pw.TextStyle(fontSize: 17, fontStyle: pw.FontStyle.italic),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    "Si attesta che, in data ${DateFormat('dd/MM/yyyy').format(widget.data!)}, l'utente ${widget.utente?.nomeCompleto()} ha effettuato un movimento di ${widget.tipoMovimentazione.toString().substring(19)} dell\' importo pari a ${widget.importo}, in merito all\'intervento con ID ${widget.intervento?.id} effettuato in data ${DateFormat('dd/MM/yyyy').format(widget.intervento!.data!)} al cliente ${widget.cliente?.denominazione}.  ",
                  ),
                  pw.SizedBox(height: 60),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      pw.Column(
                        children: [
                          pw.SizedBox(height: 20),
                          pw.SizedBox(
                            height: 100,
                            width: 130,
                            child: pw.Image(
                              pw.MemoryImage(widget.firmaIncaricato!),
                            ),
                          ),
                          pw.Column(
                            children: [
                              pw.Text("Firma utente alla cassa"),
                              pw.SizedBox(height: 20),
                              pw.SizedBox(
                                height: 100,
                                width: 130,
                                child: pw.Image(
                                  pw.MemoryImage(widget.firmaCassa!),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
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