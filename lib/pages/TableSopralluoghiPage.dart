// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
//
// import '../model/SopralluogoModel.dart';
//
// class TableSopralluoghiPage extends StatefulWidget{
//   TableSopralluoghiPage({Key? key}) : super(key:key);
//
//   @override
//   _TableSopralluoghiPageState createState() => _TableSopralluoghiPageState();
// }
//
// class _TableSopralluoghiPageState extends State<TableSopralluoghiPage>{
//   String ipaddress = 'http://gestione.femasistemi.it:8090';
//   late SopralluogoDataSource _dataSource;
//   List<SopralluogoModel> sopralluoghiList = [];
//   Map<String, double> _columnWidths ={
//     'sopralluogo' : 0,
//     'data' : 200,
//     'cliente' : 200,
//     'tipologia' : 200,
//     'descrizione' : 200,
//     'utente' : 200,
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     getAllSopralluoghi();
//   }
//
//   Future<void> getAllSopralluoghi() async {
//     try {
//       var apiUrl = Uri.parse('${ipaddress}/api/sopralluogo/ordered');
//       var response = await http.get(apiUrl);
//       if (response.statusCode == 200) {
//         var jsonData = jsonDecode(response.body);
//         List<SopralluogoModel> sopralluoghi = [];
//         for (var item in jsonData) {
//           sopralluoghi.add(SopralluogoModel.fromJson(item));
//         }
//         setState(() {
//           sopralluoghiList = sopralluoghi;// Salva la lista originale
//         });
//       } else {
//         throw Exception('Failed to load data from API: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Errore durante la chiamata all\'API: $e');
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Errore di connessione'),
//             content: Text(
//                 'Impossibile caricare i dati dall\'API. Controlla la tua connessione internet e riprova.'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context){
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Report sopralluoghi'.toUpperCase(),
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.red,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(10),
//         child: Column(
//           children: [
//             SizedBox(height: 10),
//             Expanded(
//                 child: SfDataGrid(
//                   allowTriStateSorting: true,
//                   allowMultiColumnSorting: true,
//                   allowSorting: true,
//                   source: _dataSource,
//                   columnWidthMode: ColumnWidthMode.auto,
//                   allowColumnsResizing: true,
//                   isScrollbarAlwaysShown: true,
//                   rowHeight: 40,
//                   gridLinesVisibility: GridLinesVisibility.both,
//                   headerGridLinesVisibility: GridLinesVisibility.both,
//                   columns: [
//                     GridColumn(
//                       columnName: 'sopralluogo',
//                       label: Container(
//                         padding: EdgeInsets.all(8.0),
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           border: Border(
//                             right: BorderSide(
//                               color: Colors.grey[300]!,
//                               width: 1,
//                             ),
//                           ),
//                         ),
//                         child: Text(
//                           'sopralluogo',
//                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//                         ),
//                       ),
//                       width: _columnWidths['spesa']?? double.nan,
//                       minimumWidth: 0,
//                     ),
//                     GridColumn(
//                       columnName: 'data',
//                       label: Container(
//                         padding: EdgeInsets.all(8.0),
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           border: Border(
//                             right: BorderSide(
//                               color: Colors.grey[300]!,
//                               width: 1,
//                             ),
//                           ),
//                         ),
//                         child: Text(
//                           'DATA',
//                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//                         ),
//                       ),
//                       width: _columnWidths['data']?? double.nan,
//                       minimumWidth: 0,
//                     ),
//                     GridColumn(
//                       columnName: 'cliente',
//                       label: Container(
//                         padding: EdgeInsets.all(8.0),
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           border: Border(
//                             right: BorderSide(
//                               color: Colors.grey[300]!,
//                               width: 1,
//                             ),
//                           ),
//                         ),
//                         child: Text(
//                           'CLIENTE',
//                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//                         ),
//                       ),
//                       width: _columnWidths['cliente']?? double.nan,
//                       minimumWidth: 0,
//                     ),
//                     GridColumn(
//                       columnName: 'tipologia',
//                       label: Container(
//                         padding: EdgeInsets.all(8.0),
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           border: Border(
//                             right: BorderSide(
//                               color: Colors.grey[300]!,
//                               width: 1,
//                             ),
//                           ),
//                         ),
//                         child: Text(
//                           'TIPOLOGIA',
//                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//                         ),
//                       ),
//                       width: _columnWidths['tipologia']?? double.nan,
//                       minimumWidth: 0,
//                     ),
//                     GridColumn(
//                       columnName: 'descrizione',
//                       label: Container(
//                         padding: EdgeInsets.all(8.0),
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           border: Border(
//                             right: BorderSide(
//                               color: Colors.grey[300]!,
//                               width: 1,
//                             ),
//                           ),
//                         ),
//                         child: Text(
//                           'DESCRIZIONE',
//                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//                         ),
//                       ),
//                       width: _columnWidths['descrizione']?? double.nan,
//                       minimumWidth: 0,
//                     ),
//                     GridColumn(
//                       columnName: 'utente',
//                       label: Container(
//                         padding: EdgeInsets.all(8.0),
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           border: Border(
//                             right: BorderSide(
//                               color: Colors.grey[300]!,
//                               width: 1,
//                             ),
//                           ),
//                         ),
//                         child: Text(
//                           'UTENTE',
//                           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//                         ),
//                       ),
//                       width: _columnWidths['utente']?? double.nan,
//                       minimumWidth: 0,
//                     ),
//                   ],
//                   onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
//                     setState(() {
//                       _columnWidths[details.column.columnName] = details.width;
//                     });
//                     return true;
//                   },
//                 )
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class SopralluogoDataSource extends DataGridSource{
//   List<SopralluogoModel> _sopralluoghi =[];
//   List<SopralluogoModel> _originalSopralluoghi = [];
//   BuildContext context;
//
//   SopralluogoDataSource(this.context, List<SopralluogoModel> sopralluoghi){
//     _sopralluoghi = sopralluoghi;
//     _originalSopralluoghi = List.from(sopralluoghi);
//   }
//
//   void resetData(){
//     _sopralluoghi = List.from(_originalSopralluoghi);
//     notifyListeners();
//   }
//
//   void updateData(List<SopralluogoModel> sopralluoghi){
//     _sopralluoghi.clear();
//     _sopralluoghi.addAll(sopralluoghi);
//     notifyListeners();
//   }
//
//   @override
//   List<DataGridRow> get rows{
//     List<DataGridRow> rows = [];
//     for(int i = 0; i < _sopralluoghi.length; i++){
//       SopralluogoModel sopralluogo = _sopralluoghi[i];
//       String? formattedData = sopralluogo.data != null ? DateFormat('dd/MM/yyyy').format(sopralluogo.data!) : "//";
//       String? utente = sopralluogo.utente != null ? sopralluogo.utente!.nomeCompleto();
//     }
//   }
// }