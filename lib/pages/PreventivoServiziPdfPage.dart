// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io' as io;
// import 'package:pdf/widgets.dart' as pdfw;
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
// import '../databaseHandler/DbHelper.dart';
// import '../model/UtenteModel.dart';
// import 'PreventivoServiziPage.dart';
// import 'package:path/path.dart' as pa;
//
// class PreventivoServiziPdfPage extends StatefulWidget{
//   final UtenteModel utente;
//   List<Prodotto> prodotti;
//   double? totaleImponibile;
//   double? totaleIva;
//   double? totaleDocumento;
//   String? numeroPreventivo;
//   String? dataPreventivo;
//   String? denomDestinatario;
//   String? denomDestinazione;
//   String? indirizzoDestinatario;
//   String? indirizzoDestinazione;
//   String? cittaDestinatario;
//   String? cittaDestinazione;
//   String? codFisc;
//
//   PreventivoServiziPdfPage({Key? key, required this.utente, required this.prodotti, this.totaleImponibile, this.totaleIva,
//           this.totaleDocumento, this.numeroPreventivo, this.dataPreventivo, this.denomDestinatario, this.denomDestinazione,
//           this.indirizzoDestinatario, this.indirizzoDestinazione, this.cittaDestinatario, this.cittaDestinazione, this.codFisc,
//   }) : super(key:key);
//
//   _PreventivoServiziPdfPageState createState() => _PreventivoServiziPdfPageState();
// }
//
// class _PreventivoServiziPdfPageState extends State<PreventivoServiziPdfPage>{
//   late io.File fileAss;
//   late DateTime dateora;
//   DbHelper? dbHelper;
//   late String path;
//   Future<io.File>? _pdfFileFuture;
//   bool _isFileInitialized = false;
//
//   @override
//   void initState(){
//     dateora = DateTime.fromMillisecondsSinceEpoch(
//         DateTime.now().millisecondsSinceEpoch);
//     dbHelper = DbHelper();
//     super.initState();
//     _pdfFileFuture =
//         initializeFile();
//   }
//
//   Future<io.File> initializeFile() async {
//     final directory = await getApplicationSupportDirectory();
//     path = directory.path;
//     dateora = DateTime.now();
//     String formattedDate = DateFormat('ddMMyy_HHmmss').format(dateora);
//     fileAss = io.File('$path/Preventivo_Servizi_Numero_${widget.numeroPreventivo}_${formattedDate}.pdf');
//     await makePdfAss();
//     setState(() {
//       _isFileInitialized = true; // Set flag to true once file is initialized
//     });
//     print('Directory path: $path');
//     return fileAss;
//   }
//
//   Future<io.File> makePdfAss() async{
//     dateora = DateTime.now();
//     String formattedDate = DateFormat('ddMMyy_HHmmss').format(dateora);
//     final pdfAss = pdfw.Document();
//     final logoFema = pdfw.MemoryImage(
//         (await rootBundle.load('assets/images/logo_no_bg.png'))
//             .buffer
//             .asUint8List(),
//     );
//     final footer = pdfw.MemoryImage(
//         (await rootBundle.load('assets/images/partner_footer.JPG'))
//             .buffer
//             .asUint8List(),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: <Widget>[
//                 Row(mainAxisAlignment: MainAxisAlignment.start, children: [
//                   SizedBox(
//                     width: 40,
//                   ),
//                   //spPlatform == 'windows' ?
//                   FloatingActionButton.extended(
//                       heroTag: 'stampa',
//                       icon: Icon(Icons.print),
//                       label: Text("Stampa"),
//                       onPressed: () async {
//                         // await Printing.layoutPdf(
//                         //     onLayout: (PdfPageFormat format) async => unita!);
//                       }),
//                 ]) //: Container(),
//               ])),
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(
//           'Preventivo N ${widget.numeroPreventivo}',
//           style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
//         ),
//       ),
//       body: FutureBuilder<io.File>(
//         future: _pdfFileFuture,
//         builder: (BuildContext context, AsyncSnapshot<io.File> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (snapshot.hasData) {
//             final file = snapshot.data!;
//             return SfPdfViewer.file(file);
//           } else {
//             return Center(child: Text('No PDF file generated.'));
//           }
//         },
//       ),
//     );
//   }
// }
//
//
