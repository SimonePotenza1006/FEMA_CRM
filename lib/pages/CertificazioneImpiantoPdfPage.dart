import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' as io;
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
import 'package:path/path.dart' as pa;

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

  Future<io.File> initializeFile() async {
    final directory = await getTemporaryDirectory();
    path = directory.path;
    dateora = DateTime.now();
    String formattedDate = DateFormat('ddMMyy_HHmmss').format(dateora);
    fileAss = io.File('$path/Certificazione_Impianto_${widget.impianto}_${widget.denom_cliente}_${formattedDate}.pdf');
    setState(() {
      filename = "Noleggio_Auto_${formattedDate}.pdf";
    });
    //await makePdfAss();
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

  // Future<io.File> makePdfAss() async{
  //   final pdfAss = pdfw.Document();
  // }


}

pdfw.Widget buildCheckbox(bool isChecked) {
  return pdfw.Icon(
    isChecked
        ? pdfw.IconData(0xf14a)
        : pdfw.IconData(0xf0c8), // 0xf14a = checkSquare, 0xf0c8 = square
    size: 8,
  );
}