import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' as io;
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfw;
import 'dart:io' show Platform;
import 'package:path/path.dart' as pa;
import 'package:overlay_support/overlay_support.dart' as over;

import '../databaseHandler/DbHelper.dart';

class CertificazioneImpiantoPdfPage extends StatefulWidget{
  String? protocollo;
  String? azienda;
  String? tipologia;
  String? indirizzo_azienda;
  String? telefono_azienda;
  String? p_iva_azienda;
  String? citta_registro_ditta;
  String? cod_registro_ditta;
  String? citta_albo;
  String? cod_albo;
  String? impianto;
  String? altro;
  String? denom_cliente;
  String? comune_cliente;
  String? provincia_cliente;
  String? via_cliente;
  String? numero_cliente;
  String? scala_cliente;
  String? piano_cliente;
  String? interno_cliente;
  String? proprieta_cliente;
  String? progettista;
  String? albo_progettista;
  String? responsabile_tecnico;
  String? norma;
  String? data;
  String? sottoscritto;
  bool? iscrizione_registro;
  bool? iscrizione_albo;
  bool? nuovo_impianto;
  bool? trasformazione;
  bool? ampliamento;
  bool? manutenzione;
  bool? bool_altro;
  bool? industriale;
  bool? civile;
  bool? commercio;
  bool? altri_usi;
  bool? bool_progettista;
  bool? bool_responsabile;
  bool? bool_norma;
  bool? installazione;
  bool? controllo;
  bool? verifica;
  bool? progetto;
  bool? relazione;
  bool? schema;
  bool? riferimento;
  bool? visura;
  bool? conformita;

  CertificazioneImpiantoPdfPage({
    Key? key,
    this.protocollo,
    this.azienda,
    this.tipologia,
    this.indirizzo_azienda,
    this.telefono_azienda,
    this.p_iva_azienda,
    this.citta_registro_ditta,
    this.cod_registro_ditta,
    this.citta_albo,
    this.cod_albo,
    this.impianto,
    this.altro,
    this.denom_cliente,
    this.comune_cliente,
    this.provincia_cliente,
    this.via_cliente,
    this.numero_cliente,
    this.scala_cliente,
    this.piano_cliente,
    this.interno_cliente,
    this.proprieta_cliente,
    this.progettista,
    this.albo_progettista,
    this.responsabile_tecnico,
    this.norma,
    this.data,
    this.sottoscritto,
    this.iscrizione_registro,
    this.iscrizione_albo,
    this.nuovo_impianto,
    this.trasformazione,
    this.ampliamento,
    this.manutenzione,
    this.bool_altro,
    this.industriale,
    this.civile,
    this.commercio,
    this.altri_usi,
    this.bool_progettista,
    this.bool_responsabile,
    this.bool_norma,
    this.installazione,
    this.controllo,
    this.verifica,
    this.progetto,
    this.relazione,
    this.schema,
    this.riferimento,
    this.visura,
    this.conformita
  }) : super(key: key);

  _CertificazioneImpiantoPdfPageState createState() => _CertificazioneImpiantoPdfPageState();
}

class _CertificazioneImpiantoPdfPageState extends State<CertificazioneImpiantoPdfPage>{

  late DateTime dateora;
  late io.File fileAss;
  DbHelper? dbHelper;
  late String path;
  Future<io.File>? _pdfFileFuture;
  late Future<void> _future;
  bool _isFileInitialized = false;
  String? filename;

  @override
  void initState() {
    dateora = DateTime.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch);
    dbHelper = DbHelper();
    super.initState();
    _pdfFileFuture =
        initializeFile();// Initialize the file when the state is initialized
    //saveInfoNoleggio();
  }

  Future<io.File> initializeFile() async {
    final directory = await getTemporaryDirectory();
    path = directory.path;
    dateora = DateTime.now();
    String formattedDate = DateFormat('ddMMyy_HHmmss').format(dateora);
    fileAss = io.File('$path/Certificazione_Impianto_${widget.denom_cliente}_${formattedDate}.pdf');
    setState(() {
      filename = "Noleggio_Auto_${formattedDate}.pdf";
    });
    await makePdfAss();
    setState(() {
      _isFileInitialized = true;
    });
    print('Directory path: $path');
    return fileAss;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text(
          'Certificazione impianto ${widget.protocollo}'.toUpperCase(),
          style: TextStyle(color: Colors.white),
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

  Future<io.File> makePdfAss() async{
    final pdfAss = pdfw.Document();
    final confArtigianatoImage = pdfw.MemoryImage(
      (await rootBundle.load('assets/images/ConfArtigianato.JPG'))
          .buffer
          .asUint8List(),
    );
    pdfAss.addPage(
      pdfw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pdfw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        build: (context) => pdfw.Column(
          mainAxisAlignment: pdfw.MainAxisAlignment.start,
          children:[
            pdfw.Row(
              mainAxisAlignment: pdfw.MainAxisAlignment.spaceBetween,
              children: [
                pdfw.Column(
                  crossAxisAlignment: pdfw.CrossAxisAlignment.start,
                  children: [
                    pdfw.Text(
                        'DICHIARAZIONE DI CONFORMITA\' DELL\'IMPIANTO A REGOLA D\'ARTE',
                        style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold, fontSize: 12)
                    ),
                    pdfw.Text(
                      'Decreto Ministeriale 22 Gennaio 2008, numero 37',
                      style: pdfw.TextStyle(fontSize: 10)
                    ),
                  ]
                ),
                pdfw.Container(
                  width: 120,
                  height: 30,
                  decoration: pdfw.BoxDecoration(
                    border: pdfw.Border.all(
                      color: PdfColors.black,
                      width: 1,
                    )
                  ),
                  child: pdfw.Column(
                    mainAxisAlignment: pdfw.MainAxisAlignment.end,
                    children: [
                      pdfw.Row(
                        mainAxisAlignment: pdfw.MainAxisAlignment.center,
                        children: [
                          pdfw.RichText(
                              text: pdfw
                                  .TextSpan(children: <pdfw
                                  .InlineSpan>[
                                pdfw.TextSpan(
                                    style: pdfw.TextStyle(
                                        color: PdfColors.black,
                                        fontSize: 9),
                                    text:
                                    'Prot. n.(1) '),
                                pdfw.TextSpan(
                                    style: pdfw.TextStyle(
                                        color: PdfColors.black,
                                        fontSize: 9),
                                    text: widget.protocollo)
                              ])),
                        ]
                      ),
                      pdfw.SizedBox(height: 5)
                    ]
                  )
                ),
              ]
            ),
            //fine titolo e protocollo
            pdfw.SizedBox(height: 3),
            pdfw.Column(
              crossAxisAlignment: pdfw.CrossAxisAlignment.start,
              children: [
                pdfw.Row(
                  mainAxisAlignment: pdfw.MainAxisAlignment.start,
                  children: [
                    pdfw.RichText(
                        text: pdfw
                            .TextSpan(children: <pdfw
                            .InlineSpan>[
                          pdfw.TextSpan(
                              style: pdfw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 11),
                              text:
                              'Il sottoscritto MAZZEI FEDERICO, titolare o legale rappresentande del\'impresa '),
                          pdfw.TextSpan(
                              style: pdfw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 11),
                              text: widget.azienda),
                          pdfw.TextSpan(
                              style: pdfw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 11),
                              text:
                              ','),
                        ])),
                  ]
                ),
                pdfw.Row(
                  mainAxisAlignment: pdfw.MainAxisAlignment.start,
                  children: [
                    pdfw.RichText(
                        text: pdfw
                            .TextSpan(children: <pdfw
                            .InlineSpan>[
                          pdfw.TextSpan(
                              style: pdfw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 11),
                              text:
                              'operante nel settore '),
                          pdfw.TextSpan(
                              style: pdfw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 11),
                              text: widget.tipologia),
                          pdfw.TextSpan(
                              style: pdfw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 11),
                              text:
                              ' con sede in '),
                          pdfw.TextSpan(
                              style: pdfw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 11),
                              text: widget.indirizzo_azienda),
                          pdfw.TextSpan(
                              style: pdfw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 11),
                              text:
                              ', tel. '),
                          pdfw.TextSpan(
                              style: pdfw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 11),
                              text: widget.telefono_azienda),
                          pdfw.TextSpan(
                              style: pdfw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 11),
                              text:
                              ','),
                        ])),
                  ]
                ),
                pdfw.Row(
                  mainAxisAlignment: pdfw.MainAxisAlignment.start,
                  children: [
                    pdfw.RichText(
                        text: pdfw
                            .TextSpan(children: <pdfw
                            .InlineSpan>[
                          pdfw.TextSpan(
                              style: pdfw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 11),
                              text:
                              'P. IVA '),
                          pdfw.TextSpan(
                              style: pdfw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 11),
                              text: widget.p_iva_azienda),
                        ])),
                  ]
                ),
                pdfw.SizedBox(height: 3),
                pdfw.Row(
                  mainAxisAlignment: pdfw.MainAxisAlignment.start,
                  children:[
                    pdfw.Container(
                      width: 7,
                      height: 7,
                      decoration: pdfw
                          .BoxDecoration(
                        border: pdfw
                            .Border
                            .all(
                            width:
                            0.1),
                      ),
                      child: widget
                          .iscrizione_registro!
                          ? pdfw.Center(
                          child: pdfw.Text(
                              'X',
                              style: pdfw.TextStyle(
                                  fontSize:
                                  8)))
                          : pdfw
                          .SizedBox(),
                    ),
                    pdfw.RichText(
                        text: pdfw
                            .TextSpan(children: <pdfw
                            .InlineSpan>[
                          pdfw.TextSpan(
                              style: pdfw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 10),
                              text:
                              ' iscritta nel registro delle ditte (DPR 07/12/1995, n 581) della camera C.I.A.A. di'),
                          pdfw.TextSpan(
                              style: pdfw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 10),
                              text: widget.citta_registro_ditta),
                          pdfw.TextSpan(
                              style: pdfw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 10),
                              text:
                              'n. '),
                          pdfw.TextSpan(
                              style: pdfw.TextStyle(
                                  color: PdfColors.black,
                                  fontSize: 10),
                              text: widget.cod_registro_ditta),
                        ])),
                  ]
                ),
                pdfw.Row(
                    mainAxisAlignment: pdfw.MainAxisAlignment.start,
                    children:[
                      pdfw.Container(
                        width: 7,
                        height: 7,
                        decoration: pdfw
                            .BoxDecoration(
                          border: pdfw
                              .Border
                              .all(
                              width:
                              0.1),
                        ),
                        child: widget
                            .iscrizione_albo!
                            ? pdfw.Center(
                            child: pdfw.Text(
                                'X',
                                style: pdfw.TextStyle(
                                    fontSize:
                                    8)))
                            : pdfw
                            .SizedBox(),
                      ),
                      pdfw.RichText(
                          text: pdfw
                              .TextSpan(children: <pdfw
                              .InlineSpan>[
                            pdfw.TextSpan(
                                style: pdfw.TextStyle(
                                    color: PdfColors.black,
                                    fontSize: 10),
                                text:
                                ' iscritta all\'Albo Provinciale delle Imprese Artigiane(L: 8/8/1985, n 443) di '),
                            pdfw.TextSpan(
                                style: pdfw.TextStyle(
                                    color: PdfColors.black,
                                    fontSize: 10),
                                text: widget.citta_albo),
                            pdfw.TextSpan(
                                style: pdfw.TextStyle(
                                    color: PdfColors.black,
                                    fontSize: 10),
                                text:
                                'n. '),
                            pdfw.TextSpan(
                                style: pdfw.TextStyle(
                                    color: PdfColors.black,
                                    fontSize: 10),
                                text: widget.cod_albo),
                          ])),
                    ]
                ),
                pdfw.SizedBox(height: 3),
                pdfw.Row(
                  mainAxisAlignment: pdfw.MainAxisAlignment.start,
                  children: [
                    pdfw.Expanded( // Usa Expanded per occupare tutto lo spazio disponibile
                      child: pdfw.Paragraph(
                        text: 'Esecutrice dell\'impianto (2) ${widget.impianto}',
                        style: pdfw.TextStyle(color: PdfColors.black, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                pdfw.RichText(
                    text: pdfw
                        .TextSpan(children: <pdfw
                        .InlineSpan>[
                      pdfw.TextSpan(
                          style: pdfw.TextStyle(
                              color: PdfColors.black,
                              fontSize: 8),
                          text:
                          'Nota - '),
                      pdfw.TextSpan(
                          style: pdfw.TextStyle(
                              color: PdfColors.black,
                              fontSize: 8,
                              fontWeight: pdfw.FontWeight.bold),
                          text: 'Per gli impianti a gas '),
                      pdfw.TextSpan(
                          style: pdfw.TextStyle(
                              color: PdfColors.black,
                              fontSize: 8),
                          text:
                          'specificare il tipo di gas distribuito: canalizzato 1°, 2°, 3° famiglia: GPL da serbatoio fisso'),
                    ])),
                pdfw.RichText(
                    text: pdfw
                        .TextSpan(children: <pdfw
                        .InlineSpan>[
                      pdfw.TextSpan(
                          style: pdfw.TextStyle(
                              color: PdfColors.black,
                              fontSize: 8,
                              fontWeight: pdfw.FontWeight.bold),
                          text: 'Per gli impianti elettrici '),
                      pdfw.TextSpan(
                          style: pdfw.TextStyle(
                              color: PdfColors.black,
                              fontSize: 8),
                          text:
                          'specificare la potenza massima erogabile'),
                    ])),
                pdfw.Text(
                    style: pdfw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 10),
                    'Inteso come: '),
                pdfw.SizedBox(height: 3),
                pdfw.Row(
                  mainAxisAlignment: pdfw.MainAxisAlignment.start,
                  children:[
                    pdfw.Container(
                      width: 7,
                      height: 7,
                      decoration: pdfw
                          .BoxDecoration(
                        border: pdfw
                            .Border
                            .all(
                            width:
                            0.1),
                      ),
                      child: widget
                          .nuovo_impianto!
                          ? pdfw.Center(
                          child: pdfw.Text(
                              'X',
                              style: pdfw.TextStyle(
                                  fontSize:
                                  9)))
                          : pdfw
                          .SizedBox(),
                    ),
                    pdfw.SizedBox(
                        width: 4),
                    pdfw.Text('nuovo impianto;',
                        style: pdfw
                            .TextStyle(
                            fontSize:
                            9)),
                    pdfw.SizedBox(
                        width: 5),
                    pdfw.Container(
                      width: 7,
                      height: 7,
                      decoration: pdfw
                          .BoxDecoration(
                        border: pdfw
                            .Border
                            .all(
                            width:
                            0.1),
                      ),
                      child: widget
                          .trasformazione!
                          ? pdfw.Center(
                          child: pdfw.Text(
                              'X',
                              style: pdfw.TextStyle(
                                  fontSize:
                                  9)))
                          : pdfw
                          .SizedBox(),
                    ),
                    pdfw.SizedBox(
                        width: 5),
                    pdfw.Text('trasformazione;',
                        style: pdfw
                            .TextStyle(
                            fontSize:
                            9)),
                    pdfw.SizedBox(
                        width: 5),
                    pdfw.Container(
                      width: 7,
                      height: 7,
                      decoration: pdfw
                          .BoxDecoration(
                        border: pdfw
                            .Border
                            .all(
                            width:
                            0.1),
                      ),
                      child: widget
                          .ampliamento!
                          ? pdfw.Center(
                          child: pdfw.Text(
                              'X',
                              style: pdfw.TextStyle(
                                  fontSize:
                                  9)))
                          : pdfw
                          .SizedBox(),
                    ),
                    pdfw.SizedBox(
                        width: 5),
                    pdfw.Text('ampliamento;',
                        style: pdfw
                            .TextStyle(
                            fontSize:
                            9)),
                    pdfw.SizedBox(
                        width: 5),
                    pdfw.Container(
                      width: 7,
                      height: 7,
                      decoration: pdfw
                          .BoxDecoration(
                        border: pdfw
                            .Border
                            .all(
                            width:
                            0.1),
                      ),
                      child: widget
                          .ampliamento!
                          ? pdfw.Center(
                          child: pdfw.Text(
                              'X',
                              style: pdfw.TextStyle(
                                  fontSize:
                                  9)))
                          : pdfw
                          .SizedBox(),
                    ),
                    pdfw.SizedBox(
                        width: 5),
                    pdfw.Text('manutenzione straordinaria;',
                        style: pdfw
                            .TextStyle(
                            fontSize:
                            9)),
                    pdfw.SizedBox(
                        width: 5),
                    pdfw.Container(
                      width: 7,
                      height: 7,
                      decoration: pdfw
                          .BoxDecoration(
                        border: pdfw
                            .Border
                            .all(
                            width:
                            0.1),
                      ),
                      child: widget
                          .ampliamento!
                          ? pdfw.Center(
                          child: pdfw.Text(
                              'X',
                              style: pdfw.TextStyle(
                                  fontSize:
                                  9)))
                          : pdfw
                          .SizedBox(),
                    ),
                    pdfw.SizedBox(
                        width: 5),
                    pdfw.Text('altro(3)',
                        style: pdfw
                            .TextStyle(
                            fontSize:
                            9)),
                    pdfw.SizedBox(width: 3),
                    pdfw.Text(
                        style: pdfw.TextStyle(
                            color: PdfColors.black,
                            fontSize: 10),
                        '${widget.altro}'),
                  ]
                ),
                
              ]
            ),

          ]
        )
      )
    );
    final bytes = await pdfAss.save();
    final dir = await getTemporaryDirectory();
    final file = io.File('${dir.path}/Certificazione_Impianto_${widget.denom_cliente?.replaceAll(" ", "_").toUpperCase()}_${DateFormat('dd_MM_yyyy')}.pdf');
    await file.writeAsBytes(bytes);
    await fileAss.writeAsBytes(await pdfAss.save().whenComplete(() async {
      if (fileAss != null) {
        await Future.delayed(Duration(seconds: 2)).then((val) async {
          dbHelper!
              .uploadCertificazioneImpianto(
              pa.basename(fileAss.path),
              fileAss,
              widget.denom_cliente!
                  .replaceAll(' ', '')
                  .toUpperCase() // Formatta la targa
          );
        });
      } else {

      }
    }));
    return file;
  }
}

pdfw.Widget buildCheckbox(bool isChecked) {
  return pdfw.Icon(
    isChecked
        ? pdfw.IconData(0xf14a)
        : pdfw.IconData(0xf0c8), // 0xf14a = checkSquare, 0xf0c8 = square
    size: 8,
  );
}
