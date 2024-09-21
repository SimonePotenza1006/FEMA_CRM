import 'dart:convert';
import 'dart:typed_data';
import 'package:fema_crm/pages/LogisticaPreventiviHomepage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io' as io;
import '../databaseHandler/DbHelper.dart';
import '../model/UtenteModel.dart';
import 'CassettoPreventiviServiziPage.dart';

class PdfPreventivoServizio extends StatefulWidget{
  final String source;
  final UtenteModel utente;
  final String filename;
  final List<String>? listfilename;

  const PdfPreventivoServizio(this.source,this.utente, this.filename, this.listfilename);

  @override
  _PdfPreventivoServizioState createState() => _PdfPreventivoServizioState();
}

class _PdfPreventivoServizioState extends State<PdfPreventivoServizio>{
  Uint8List unita = Uint8List(0);
  List<String>? listfiles;
  List<String>? listfilesMag;
  Widget child = const Center(child: CircularProgressIndicator());
  late io.File file;
  var dbHelper;

  @override
  initState(){
    print('uuuujnmfg gfgfgf');
    //getUnita();
    print('dtgergfhh jhjh'+widget.filename);
    dbHelper = DbHelper();
    _initFile();
    super.initState();
  }

  Future<void> _initFile() async {
    final tempDir = await getTemporaryDirectory();
    file = await io.File('${tempDir.path}/'+widget.filename).create();
  }

  Future<void> getUnita() async {
    print('hf76io90 ');
    unita=await dbHelper.getPdfNoleggio(widget.filename);
    final tempDir = await getTemporaryDirectory();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: null,//_onWillPop,
        child: Scaffold(
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
                              backgroundColor: Colors.red,
                              icon: Icon(Icons.print, color: Colors.white,),
                              label: Text("Stampa", style: TextStyle(color: Colors.white)),
                              onPressed: () async {
                                await Printing.layoutPdf(
                                    onLayout: (PdfPageFormat format) async => unita!);
                              }),
                          SizedBox(width: 30,),
                        ]) //: Container(),
                  ])),
          appBar: AppBar(
            backgroundColor: Colors.red,
            centerTitle: true,
            title: Text(widget.filename.replaceFirst("xyz0", "\\"),//'file - '+widget.utente.nome!+' '+widget.utente.cognome!,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 20.0),),
            automaticallyImplyLeading: false,
            // leading: IconButton(
            //   onPressed: () {
            //     //Navigator.pop(context);
            //   }, icon: Icon(
            //   Icons.arrow_back, color: Colors.white,
            // ),
            //
            // ),
            actions: [
              IconButton(
                icon: Icon(Icons.share, color: Colors.white),
                onPressed: () async {
                  try {
                    // Condividi il PDF utilizzando il file generato
                    await Share.shareXFiles([XFile(file.path)],
                        text: 'Ecco il preventivo in allegato');
                  } catch (e) {
                    print('Errore nella condivisione: $e');
                  }
                },
              ),
              SizedBox(width: 10,)
            ],
          ),
          body:
          FutureBuilder(
            future: getUnita(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (unita != null) {
                  return SfPdfViewer.memory(
                    //child
                    unita!,
                  );
                } else {
                  return Center(child: Text('PDF non disponibile'));
                }
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        )
    );
  }

}