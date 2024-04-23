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
import 'package:http/http.dart' as http;

import '../model/TipologiaInterventoModel.dart';

class PDFRendicontoInterventiPage extends StatefulWidget {
  const PDFRendicontoInterventiPage({Key? key}) : super(key: key);

  @override
  _PDFRendicontoInterventiPageState createState() =>
      _PDFRendicontoInterventiPageState();
}

class _PDFRendicontoInterventiPageState
    extends State<PDFRendicontoInterventiPage> {
  late Future<Uint8List> _pdfFuture;
  Map<String, List<InterventoModel>> interventoPerTipologiaMap = {};
  List<InterventoModel> interventiList = [];
  List<TipologiaInterventoModel> tipologieList = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090';

  @override
  void initState() {
    super.initState();
    getAllTipologieIntervento();
    _pdfFuture = _generatePDF();
  }

  Future<void> getAllTipologieIntervento() async {
    try {
      var apiUrl = Uri.parse('${ipaddress}/api/tipologiaIntervento');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<TipologiaInterventoModel> tipologie = [];
        for (var item in jsonData) {
          tipologie.add(TipologiaInterventoModel.fromJson(item));
        }
        setState(() {
          tipologieList = tipologie;
        });
        await getAllInterventiOrderByTipologia();
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

  Future<void> getAllInterventiOrderByTipologia() async {
    for (var tipologia in tipologieList) {
      await getAllInterventiForTipologia(tipologia.id!);
    }
    // Chiamata a _generatePDF() dopo il completamento del caricamento dei dati
    setState(() {
      _pdfFuture = _generatePDF();
    });
  }

  Future<void> getAllInterventiForTipologia(String tipologiaId) async {
    try {
      var apiUrl = Uri.parse(
          '${ipaddress}/api/intervento/categoriaIntervento/$tipologiaId');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<InterventoModel> interventi = [];
        for (var item in jsonData) {
          interventi.add(InterventoModel.fromJson(item));
        }
        setState(() {
          interventoPerTipologiaMap[tipologiaId] = interventi;
        });
        print('Interventi for tipologia $tipologiaId: ${interventi}');
      } else {
        throw Exception(
            'Failed to load preventivi data from API: ${response.statusCode}');
      }
    } catch (e) {
      print(
          'Error fetching interventi data from API for tipologia $tipologiaId: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF rendiconto interventi'),
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

    // Aggiungi una pagina al documento PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          // Costruisci il contenuto della pagina
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Intestazione della pagina
              pw.Header(
                level: 0,
                child: pw.Text('Rendiconto Interventi',
                    style: pw.TextStyle(
                        font: pw.Font.helvetica(),
                        fontSize: 24)), // Utilizzo del font Helvetica
              ),
              // Spaziatura tra l'intestazione e i dati
              pw.SizedBox(height: 20),
              // Scritta "Totali degli interventi per tipologia"
              pw.Container(
                child: pw.Text(
                  'Totali degli interventi per tipologia',
                  style: pw.TextStyle(
                    font: pw.Font.helveticaBold(), // Font in grassetto
                    fontSize: 18, // Dimensione del font leggermente più grande
                  ),
                ),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(
                      color: PdfColors.black, // Colore nero
                      width: 1, // Spessore della riga
                    ),
                  ),
                ),
                padding: pw.EdgeInsets.only(bottom: 8), // Padding inferiore
              ),
              pw.SizedBox(height: 8),
              // Elenco delle tipologie di intervento e il numero totale di interventi per ciascuna
              for (var tipologia in tipologieList)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${tipologia.descrizione}:',
                        style: pw.TextStyle(
                            font: pw.Font.helvetica(),
                            fontSize: 16)), // Utilizzo del font Helvetica
                    pw.Text(
                      _calculateTotalInterventionsForTipologia(tipologia.id!)
                          .toString(),
                      style:
                          pw.TextStyle(font: pw.Font.helvetica(), fontSize: 12),
                    ), // Utilizzo del font Helvetica
                  ],
                ),
              pw.SizedBox(height: 12),
              // Scritta "Totali degli importi per tipologia di intervento"
              pw.Container(
                child: pw.Text(
                  'Totali degli importi per tipologia di intervento',
                  style: pw.TextStyle(
                    font: pw.Font.helveticaBold(), // Font in grassetto
                    fontSize: 18, // Dimensione del font leggermente più grande
                  ),
                ),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(
                      color: PdfColors.black, // Colore nero
                      width: 1, // Spessore della riga
                    ),
                  ),
                ),
                padding: pw.EdgeInsets.only(bottom: 8), // Padding inferiore
              ),
              pw.SizedBox(height: 8),
              // Elenco delle tipologie di intervento e l'importo totale per ciascuna
              for (var tipologia in tipologieList)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Importo ramo ${tipologia.descrizione}:',
                        style: pw.TextStyle(
                            font: pw.Font.helvetica(), fontSize: 16)),
                    pw.Text(
                      _calculateTotalAmountForTipologia(tipologia.id!)
                          .toString(),
                      style:
                          pw.TextStyle(font: pw.Font.helvetica(), fontSize: 12),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );

    // Salva il documento PDF come byte array
    return pdf.save();
  }

  int _calculateTotalInterventionsForTipologia(String tipologiaId) {
    final List<InterventoModel>? interventi =
        interventoPerTipologiaMap[tipologiaId];
    return interventi?.length ?? 0;
  }

  double _calculateTotalAmountForTipologia(String tipologiaId) {
    double totalAmount = 0;
    final List<InterventoModel>? interventi =
        interventoPerTipologiaMap[tipologiaId];
    if (interventi != null) {
      for (var intervento in interventi) {
        totalAmount += intervento.importo_intervento ?? 0;
      }
    }
    return totalAmount;
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
