import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'dart:io' as io;
import 'package:pdf/widgets.dart' as pdfw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../databaseHandler/DbHelper.dart';
import '../model/AziendaModel.dart';
import '../model/UtenteModel.dart';
import 'PreventivoServiziPage.dart';
import 'package:path/path.dart' as p;
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io' show Platform;
import 'package:overlay_support/overlay_support.dart' as over;

class PreventivoServiziPdfPage extends StatefulWidget{
  final String? filename;
  final UtenteModel utente;
  final AziendaModel? azienda;
  List<Servizio> servizi;
  final String? totaleImponibile;
  final String? totaleIva;
  final String? totaleDocumento;
  final String? numeroPreventivo;
  final String? dataPreventivo;
  final String? denomDestinatario;
  final String? denomDestinazione;
  final String? indirizzoDestinatario;
  final String? indirizzoDestinazione;
  final String? cittaDestinatario;
  final String? cittaDestinazione;
  final String? codFisc;

  PreventivoServiziPdfPage({Key? key, this.filename, required this.utente, required this.azienda, required this.servizi, required this.totaleImponibile, required this.totaleIva,
    required this.totaleDocumento, required this.numeroPreventivo,required this.dataPreventivo, required this.denomDestinatario,required this.denomDestinazione,
    required this.indirizzoDestinatario, required this.indirizzoDestinazione, required this.cittaDestinatario, required this.cittaDestinazione, required this.codFisc,
  }) : super(key:key);

  _PreventivoServiziPdfPageState createState() => _PreventivoServiziPdfPageState();
}

class _PreventivoServiziPdfPageState extends State<PreventivoServiziPdfPage>{
  late io.File fileAss;
  late DateTime dateora;
  DbHelper? dbHelper;
  late String path;
  Future<io.File>? _pdfFileFuture;
  bool _isFileInitialized = false;
  late io.File file;
  Uint8List unita = Uint8List(0);

  @override
  void initState(){
    dateora = DateTime.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch);
    dbHelper = DbHelper();
    super.initState(); // Aggiunge un breve delay
    _pdfFileFuture =
        initializeFile();
  }

  Future<io.File> initializeFile() async {
    final directory = await getApplicationSupportDirectory();
    path = directory.path;
    dateora = DateTime.now();
    String formattedDate = DateFormat('ddMMyy_HHmmss').format(dateora);
    fileAss = io.File('$path/Preventivo_Servizi_Numero_${widget.numeroPreventivo}_${formattedDate}.pdf');
    await makePdfAss();
    print('Directory path: $path');
    setState(() {
      _isFileInitialized = true; // Set flag to true once file is initialized
    });
    return fileAss;

  }

  Future<io.File> makePdfAss() async{
    dateora = DateTime.now();
    String formattedDate = DateFormat('ddMMyy_HHmmss').format(dateora);
    String nomeAzienda = widget.azienda!.nome!;
    String sedeLegale = widget.azienda!.sede_legale!;
    String luogoLavoro = widget.azienda!.luogo_di_lavoro!;
    String telefono = widget.azienda!.telefono!;
    String partitaIva = widget.azienda!.partita_iva!;
    String recapitoFatturazioneElettronica = widget.azienda!.recapito_fatturazione_elettronica!;
    String sito = widget.azienda!.sito!;
    String mail = widget.azienda!.email!;
    final pdfAss = pdfw.Document();
    final logoFema = pdfw.MemoryImage(
        (await rootBundle.load('assets/images/logo_no_bg.png'))
            .buffer
            .asUint8List(),
    );
    final footer = pdfw.MemoryImage(
        (await rootBundle.load('assets/images/partner_footer.JPG'))
            .buffer
            .asUint8List(),
    );
    pdfAss.addPage(
        pdfw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pdfw.EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          header: (context) => pdfw.Column(
            crossAxisAlignment: pdfw.CrossAxisAlignment.start,
            children:[
              pdfw.Row(
                mainAxisAlignment: pdfw.MainAxisAlignment.start,
                crossAxisAlignment: pdfw.CrossAxisAlignment.start,
                children: [
                  pdfw.SizedBox(
                    child: pdfw.Image(logoFema, height: 40),
                  ),
                  pdfw.SizedBox(
                    width: 4
                  ),
                  pdfw.SizedBox(
                    child: pdfw.Container(
                      child: pdfw.Column(
                        crossAxisAlignment: pdfw.CrossAxisAlignment.start,
                        children: [
                          pdfw.SizedBox(height: 5),
                          pdfw.Text(nomeAzienda.toUpperCase(), style: pdfw.TextStyle(fontSize: 20, fontWeight: pdfw.FontWeight.bold)),
                          pdfw.Row(
                            children: [
                              pdfw.SizedBox(
                                width: 400,
                                height: 2,
                                child: pdfw.Container(
                                  color: PdfColors.black
                                )
                              )
                            ]
                          ),
                          pdfw.Row(
                            children: [
                              pdfw.Text('Sede legale: ', style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold, fontSize: 10)),
                              pdfw.Text(sedeLegale, style: pdfw.TextStyle(fontSize: 10)),
                            ],
                          ),
                          pdfw.Row(
                            children: [
                              pdfw.Text('Sede operativa: ', style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold, fontSize: 10)),
                              pdfw.Text(luogoLavoro, style: pdfw.TextStyle(fontSize: 10)),
                            ],
                          ),
                          pdfw.Row(
                            children: [
                              pdfw.Text('Tel: ', style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold, fontSize: 10)),
                              pdfw.Text(telefono, style: pdfw.TextStyle(fontSize: 10)),
                            ],
                          ),
                          pdfw.Row(
                            children: [
                              pdfw.Text('C.F./P.Iva: ', style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold, fontSize: 10)),
                              pdfw.Text(partitaIva, style: pdfw.TextStyle(fontSize: 10)),
                            ],
                          ),
                          pdfw.Row(
                            children: [
                              pdfw.Text('Codice SdI: ', style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold, fontSize: 10)),
                              pdfw.Text(recapitoFatturazioneElettronica, style: pdfw.TextStyle(fontSize: 10)),
                            ],
                          ),
                          pdfw.Text(sito, style: pdfw.TextStyle(fontSize: 10)),
                          pdfw.Text(mail, style: pdfw.TextStyle(fontSize: 10)),
                        ]
                      )
                    )
                  ),
                ]
              ),
              pdfw.Text('Preventivo', style: pdfw.TextStyle(color: PdfColors.grey, fontSize: 20, fontWeight: pdfw.FontWeight.bold)),
              pdfw.SizedBox(height: 3),
              pdfw.Row(
                crossAxisAlignment: pdfw.CrossAxisAlignment.center,
                children: [
                  pdfw.Text('n. ', style: pdfw.TextStyle(color: PdfColors.grey, fontSize: 12)),
                  pdfw.SizedBox(width: 2),
                  pdfw.Text('${widget.numeroPreventivo} ', style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold, fontSize: 12)),
                  pdfw.SizedBox(width: 2),
                  pdfw.Text('del  ', style: pdfw.TextStyle(color: PdfColors.grey, fontWeight: pdfw.FontWeight.bold, fontSize: 12)),
                  pdfw.Text(widget.dataPreventivo != null ? '${widget.dataPreventivo}' : DateFormat('dd/MM/yyyy').format(DateTime.now()))
                ],
              ),
              pdfw.SizedBox(height: 5),
              pdfw.Row(
                mainAxisAlignment: pdfw.MainAxisAlignment.spaceAround,
                children: [
                  pdfw.Container(
                    width: 245,
                    height: 80,
                    color: PdfColors.grey100,
                    child: pdfw.Padding(
                      padding: pdfw.EdgeInsets.symmetric(vertical: 2, horizontal: 3),
                      child: pdfw.Column(
                        crossAxisAlignment: pdfw.CrossAxisAlignment.start,
                        children: [
                          pdfw.Text('Destinatario', style: pdfw.TextStyle(fontSize: 8, fontWeight: pdfw.FontWeight.bold)),
                          pdfw.SizedBox(height: 3),
                          pdfw.Text(widget.denomDestinatario != null ? widget.denomDestinatario! : "//", style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold, fontSize: 11)),
                          pdfw.SizedBox(height: 3),
                          pdfw.Text(widget.indirizzoDestinatario != null ? widget.indirizzoDestinatario! : "//", style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold, fontSize: 11)),
                          pdfw.SizedBox(height: 3),
                          pdfw.Text(widget.cittaDestinatario != null ? widget.cittaDestinatario! : "//", style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold, fontSize: 11)),
                          pdfw.SizedBox(height: 3),
                          pdfw.Text(widget.codFisc != null ? widget.codFisc! : "//", style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold, fontSize: 11)),
                        ]
                      )
                    )
                  ),
                  pdfw.Container(
                      width: 245,
                      height: 80,
                      color: PdfColors.grey100,
                      child: pdfw.Padding(
                          padding: pdfw.EdgeInsets.symmetric(vertical: 2, horizontal: 3),
                          child: pdfw.Column(
                              crossAxisAlignment: pdfw.CrossAxisAlignment.start,
                              children: [
                                pdfw.Text('Destinazione', style: pdfw.TextStyle(fontSize: 8, fontWeight: pdfw.FontWeight.bold)),
                                pdfw.SizedBox(height: 3),
                                pdfw.Text(widget.denomDestinazione != null ? widget.denomDestinazione! : "//", style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold, fontSize: 11)),
                                pdfw.SizedBox(height: 3),
                                pdfw.Text(widget.indirizzoDestinazione != null ? widget.indirizzoDestinazione! : "//", style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold, fontSize: 11)),
                                pdfw.SizedBox(height: 3),
                                pdfw.Text(widget.cittaDestinazione != null ? widget.cittaDestinazione! : "//", style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold, fontSize: 11)),
                              ]
                          )
                      )
                  )
                ]
              ),
              pdfw.SizedBox(height: 10),
            ]
          ),
          footer: (context) => pdfw.Column(
            children: [
              pdfw.Center(
                child: pdfw.Padding(
                  padding: pdfw.EdgeInsets.symmetric(horizontal: 2),
                  child: pdfw.Image(footer, height: 35, width: 550),
                ),
              ),
              pdfw.SizedBox(height: 3),
            ]
          ),
          build: (context) => [
            _buildPdfTable(widget.servizi),
            pdfw.Container(
              height: 300,
              child: pdfw.Column(
                mainAxisAlignment: pdfw.MainAxisAlignment.end,
                children: [
                  pdfw.Spacer(), // Aggiunge uno spazio flessibile per spingere il contenuto verso il fondo
                  pdfw.Row(
                    mainAxisAlignment: pdfw.MainAxisAlignment.spaceBetween,
                    children: [
                      pdfw.Container(
                        width: 250,
                        height: 120,
                        child: pdfw.Row(
                          mainAxisAlignment: pdfw.MainAxisAlignment.spaceBetween,
                          children: [
                            pdfw.Column(
                              crossAxisAlignment: pdfw.CrossAxisAlignment.start,
                              children: [
                                pdfw.SizedBox(height: 10),
                                pdfw.Text('Modalità di pagamento', style: pdfw.TextStyle(fontSize: 13, fontWeight: pdfw.FontWeight.bold)),
                                pdfw.SizedBox(height: 60),
                                pdfw.Text('Tutti i prezzi indicati hanno validità 10 giorni', style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold)),
                              ],
                            ),
                            pdfw.Column(
                              children: [
                                pdfw.SizedBox(height: 10),
                                pdfw.Text('Acconto', style: pdfw.TextStyle(fontSize: 13, fontWeight: pdfw.FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      pdfw.Container(
                        height: 120,
                        width: 250,
                        color: PdfColors.grey200,
                        child: pdfw.Padding(
                          padding: pdfw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                          child: pdfw.Column(
                            children: [
                              pdfw.Row(
                                mainAxisAlignment: pdfw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pdfw.Text('Tot. imponibile', style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold)),
                                  pdfw.Text('${widget.totaleImponibile}${String.fromCharCode(128)}', style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold)),
                                ],
                              ),
                              pdfw.SizedBox(height: 10),
                              pdfw.Row(
                                mainAxisAlignment: pdfw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pdfw.Text('Tot. Iva', style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold)),
                                  pdfw.Text('${widget.totaleIva}${String.fromCharCode(128)}', style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold)),
                                ],
                              ),
                              pdfw.SizedBox(height: 40),
                              pdfw.Row(
                                mainAxisAlignment: pdfw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pdfw.Text('Tot. documento', style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold, fontSize: 18)),
                                  pdfw.Text('${widget.totaleDocumento}${String.fromCharCode(128)}', style: pdfw.TextStyle(fontWeight: pdfw.FontWeight.bold, fontSize: 18)),
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
          ],
        ),
    );
    final bytes = await pdfAss.save();
    final dir = await getApplicationSupportDirectory();
    final file = io.File(p.join(dir.path, 'Preventivo_Servizi_${formattedDate}.pdf'));

    // Scrivi il file e aggiorna lo stato dopo la scrittura
    await file.writeAsBytes(bytes).whenComplete(() async {
      setState(() {
        _isFileInitialized = true; // Imposta il flag che indica che il file è pronto
        fileAss = file; // Aggiorna il riferimento al file appena generato
      });
      await Future.delayed(Duration(seconds: 2)).then((val) async{
        dbHelper?.uploadPdfPreventivoServizi(p.basename(fileAss.path),fileAss).whenComplete(() => print('ok'));
      });
    });

    return file;
  }

  List<String> splitFileMetadata(String metadata) {
    return metadata.split('|');
  }

  pdfw.Table _buildPdfTable(List<Servizio> servizi) {
    // Definiamo l'intestazione della tabella
    final headers = ['Codice', 'Descrizione', 'Quantità', 'Prezzo', 'Sconto', 'Importo', 'IVA'];

    return pdfw.Table.fromTextArray(
      // Definiamo l'allineamento delle colonne
      cellAlignment: pdfw.Alignment.center,
      headers: headers,
      data: servizi.map((servizio) {
        return [
          servizio.codice,
          servizio.descrizione,  // Questo campo andrà a capo se il testo è troppo lungo
          servizio.quantita,
          "${servizio.prezzo} ${String.fromCharCode(128)}",  // Simbolo euro
          servizio.sconto,
          "${servizio.importo} ${String.fromCharCode(128)}",  // Simbolo euro
          servizio.iva,
        ];
      }).toList(),
      // Personalizzazione dello stile dell'header
      headerStyle: pdfw.TextStyle(
        fontWeight: pdfw.FontWeight.bold,
        color: PdfColors.black,  // Colore del testo bianco
      ),
      headerDecoration: pdfw.BoxDecoration(
        color: PdfColors.grey200,  // Sfondo grigio per l'header
        border: pdfw.Border(
          bottom: pdfw.BorderSide(color: PdfColors.grey200, width: 1), // Mantiene solo la linea sotto l'header
        ),
      ),
      cellPadding: pdfw.EdgeInsets.all(5),
      columnWidths: {
        0: pdfw.FixedColumnWidth(80), // Codice
        1: pdfw.FixedColumnWidth(200), // Descrizione
        2: pdfw.FixedColumnWidth(70), // Quantità
        3: pdfw.FixedColumnWidth(80), // Prezzo
        4: pdfw.FixedColumnWidth(60), // Sconto
        5: pdfw.FixedColumnWidth(80), // Importo
        6: pdfw.FixedColumnWidth(50), // IVA
      },
      border: pdfw.TableBorder(
        horizontalInside: pdfw.BorderSide(color: PdfColors.grey),  // Linee solo tra le righe, non nelle colonne
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  SizedBox(
                    width: 40,
                  ),
                  //spPlatform == 'windows' ?
                  FloatingActionButton.extended(
                    backgroundColor: Colors.red,
                      heroTag: 'stampa',
                      icon: Icon(Icons.print, color: Colors.white),
                      label: Text("Stampa", style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        if (fileAss != null) {
                        await _printPdf(fileAss!.path); // Stampa il PDF quando si preme il bottone
                        } else {
                        print('Il file PDF non è ancora stato generato');
                        }
                      }),
                ]) //: Container(),
              ])),
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text(
          'Preventivo N ${widget.numeroPreventivo}',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () async {
              try {
                // Condividi il PDF utilizzando il file generato
                await Share.shareXFiles([XFile(fileAss.path)],
                    text: 'Ecco il preventivo in allegato');
              } catch (e) {
                print('Errore nella condivisione: $e');
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<io.File>(
        future: _pdfFileFuture,
        builder: (BuildContext context, AsyncSnapshot<io.File> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          } else if (snapshot.hasData && _isFileInitialized) {
            final file = snapshot.data!;
            return SfPdfViewer.file(file);
          } else {
            return Center(child: Text('Il file PDF non è stato generato correttamente.'));
          }
        },
      ),
    );
  }

  Future<void> _printPdf(String path) async {
    try {
      print('Percorso del file: $path'); // Stampa il percorso
      final pdfFile = io.File(path);
      if (await pdfFile.exists()) {
        final bytes = await pdfFile.readAsBytes();
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => bytes,
        );
      } else {
        print('File PDF non trovato.');
      }
    } catch (e) {
      print('Errore durante la stampa: $e');
    }
  }
}


