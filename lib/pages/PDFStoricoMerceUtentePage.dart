import 'dart:convert';
import 'dart:typed_data';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:intl/intl.dart';
import '../model/RelazioneUtentiProdottiModel.dart';
import 'PDFInterventoPage.dart';

class PDFStoricoMerceUtentePage extends StatefulWidget{
  final List<RelazioneUtentiProdottiModel> merce;
  final UtenteModel? utente;

  PDFStoricoMerceUtentePage({
    required this.merce,
    required this.utente
  });

  @override
  _PDFStoricoMerceUtentePageState createState() => _PDFStoricoMerceUtentePageState();
}

class _PDFStoricoMerceUtentePageState extends State<PDFStoricoMerceUtentePage>{
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
                    'Elenco della merce assegnata a ${widget.utente?.nomeCompleto()}:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  // Utilizziamo un ciclo for per aggiungere ogni prelievo separatamente
                  for (var item in widget.merce)
                    pw.Container(
                      margin: pw.EdgeInsets.only(bottom: 5),
                      child: pw.Text(
                        '- ${DateFormat('dd/MM/yyyy').format(item.data_creazione!)}, DDT: ${item.ddt?.id ?? 'N/A'}, Prodotto: ${item.prodotto?.descrizione?.substring(0,40) ?? 'N/A'}, materiale: ${item.materiale ?? 'N/A'}, quantità: ${item.quantita}',
                      ),
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