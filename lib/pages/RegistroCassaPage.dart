import 'dart:convert';
import 'dart:ui';
import 'package:excel/excel.dart';
import 'package:fema_crm/pages/PDFPrelievoCassaPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'dart:io';
import '../model/MovimentiModel.dart';
import '../model/UtenteModel.dart';
import 'AggiungiMovimentoPage.dart';
import 'DettaglioInterventoPage.dart';
import 'FemaShopPage.dart';
import 'ModificaMovimentazionePage.dart';

class RegistroCassaPage extends StatefulWidget {
  final UtenteModel userData;

  const RegistroCassaPage({Key? key, required this.userData}) : super(key: key);

  @override
  _RegistroCassaPageState createState() => _RegistroCassaPageState();
}

class _RegistroCassaPageState extends State<RegistroCassaPage> {
  List<MovimentiModel> movimentiList = [];
  List<MovimentiModel> movimentiList2 = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  double? fondoCassaSettimana1;
  double? fondoCassaSettimana2;
  double? fondoCassaSettimana3;
  final ScrollController _scrollController = ScrollController();
  double fondoCassa = 0.0;
  bool showSubMenu = false;
  final _formKeyUscita = GlobalKey<FormState>();
  final _formKeyPrelievo = GlobalKey<FormState>();
  final _formKeyVersamento = GlobalKey<FormState>();
  final TextEditingController _versamentoController = TextEditingController();
  final TextEditingController _entrataController = TextEditingController();
  final TextEditingController _uscitaController = TextEditingController();
  final TextEditingController _accontoController = TextEditingController();
  final TextEditingController _pagamentoController = TextEditingController();
  final TextEditingController _prelievoController = TextEditingController();
  final TextEditingController  _descrizioneUscitaController = TextEditingController();
  final TextEditingController _causaleVersamentoController = TextEditingController();
  GlobalKey<SfSignaturePadState> _signaturePadKey =
  GlobalKey<SfSignaturePadState>();



  @override
  void initState() {
    super.initState();
    getAllMovimentazioni();
    getAllMovimentazioniExcel();
  }

  @override
  Widget build(BuildContext context) {
    //double fondoCassa = calcolaFondoCassa(movimentiList);
    //fondoCassa = fondoCassa.clamp(0, 10000);
    fondoCassa = double.parse(
        fondoCassa.toStringAsFixed(2));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Registro cassa',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              getAllMovimentazioni();
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            right: 16,
            child: SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              children: [
                SpeedDialChild(
                  child: Icon(Icons.shopping_bag_outlined, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Vendita al banco'.toUpperCase(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FemaShopPage(utente : widget.userData),
                    ),
                  ),
                ),
                SpeedDialChild(
                  child: Icon(Icons.history, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Rendiconto settimane precedenti'.toUpperCase(),
                  onTap: () => _showPreviousWeeksDialog(),
                ),
                SpeedDialChild(
                  child: Icon(Icons.build, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Pagamento/Acconto intervento'.toUpperCase(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AggiungiMovimentoPage(userData: widget.userData),
                    ),
                  ),
                ),
                SpeedDialChild(
                  child: Icon(Icons.arrow_downward, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Scarica Excel'.toUpperCase(),
                  onTap: () => _showConfirmationDialog(),
                ),
                SpeedDialChild(
                  child: Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Gestione Patrimoniale'.toUpperCase(),
                  onTap: () {
                    setState(() {
                      showSubMenu = !showSubMenu;
                    });
                  },
                ),
              ],
            ),
          ),
          if (showSubMenu) // Condizione per mostrare o nascondere il sub-menu
            Positioned(
              bottom: 80,
              right: 16,
              child: SpeedDial(
                animatedIcon: AnimatedIcons.view_list,
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                children: [
                  SpeedDialChild(
                    child: Icon(Icons.arrow_upward_outlined, color: Colors.white),
                    backgroundColor: Colors.red,
                    label: 'prelievo per acquisto'.toUpperCase(),
                    onTap: () => _showUscitaDialog(),
                  ),
                  SpeedDialChild(
                    child: Icon(Icons.currency_exchange_outlined, color: Colors.white),
                    backgroundColor: Colors.red,
                    label: 'Prelievo'.toUpperCase(),
                    onTap: () => _showPrelievoDialog(),
                  ),
                  SpeedDialChild(
                    child: Icon(Icons.arrow_downward_outlined, color: Colors.white),
                    backgroundColor: Colors.red,
                    label: 'Versamento'.toUpperCase(),
                    onTap: () => _showVersamentoDialog(),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: fondoCassa / 10000,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      strokeWidth: 15.0,
                    ),
                  ),
                  Text(
                    '€${fondoCassa.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Data creazione', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Data di riferimento', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Descrizione', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Importo', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Intervento', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Utente', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('')),
                    DataColumn(label: Text('')),
                  ],
                  rows: movimentiList.map((movimento) {
                    return DataRow(
                      cells: [
                        DataCell(Text(DateFormat('yyyy-MM-dd HH:mm').format(movimento.dataCreazione!))),
                        DataCell(Text(DateFormat('yyyy-MM-dd').format(movimento.data!))),
                        DataCell(Text(movimento.descrizione ?? '')),
                        DataCell(Text(_getTipoMovimentazioneString(movimento.tipo_movimentazione))),
                        DataCell(Text(movimento.importo != null ? movimento.importo!.toStringAsFixed(2) + '€' : '')),
                        DataCell(Text(movimento.cliente != null ? movimento.cliente!.denominazione! : '///')),
                        DataCell(
                          GestureDetector(
                            onTap: () {
                              if (movimento.intervento != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DettaglioInterventoPage(intervento: movimento.intervento!),
                                  ),
                                );
                              }
                            },
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 1.0), // Aggiunge spazio tra testo e underline
                                  child: Text(
                                    movimento.intervento != null ? movimento.intervento!.descrizione! : '///',
                                    style: TextStyle(
                                      color: movimento.intervento != null ? Colors.blue : Colors.black,
                                    ),
                                  ),
                                ),
                                if (movimento.intervento != null)
                                  Positioned(
                                    bottom: 0, // Posiziona la linea esattamente sotto il testo
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 1, // Altezza della linea di sottolineatura
                                      color: Colors.blue, // Colore della linea di sottolineatura
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        DataCell(Text(movimento.utente != null ? movimento.utente!.cognome ?? '' : '')),
                        DataCell(
                            Center(
                              child: IconButton(
                                onPressed: (){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ModificaMovimentazionePage(movimento : movimento))
                                  );
                                },
                                icon: Icon(Icons.mode_edit_outline_outlined, color: Colors.grey),
                              ),
                            )
                        ),
                        DataCell(
                            Center(
                              child: IconButton(
                                onPressed: (){
                                  showDialog(context: context,
                                      builder: (BuildContext context){
                                        return AlertDialog(
                                          title: Text('Eliminare la movimentazione di ${movimento.importo!.toStringAsFixed(2)}€?'),
                                          actions: [
                                            TextButton(onPressed: (){
                                              if(movimento.tipo_movimentazione == TipoMovimentazione.Acconto || movimento.tipo_movimentazione == TipoMovimentazione.Pagamento){
                                                deletePics(movimento);
                                              }
                                              deleteMovimentazione(movimento);
                                            },
                                              child: Text('Si'),
                                            ),
                                            TextButton(onPressed: (){
                                              Navigator.pop(context);
                                            },
                                              child: Text('No'),
                                            ),
                                          ],
                                        );
                                      });
                                },
                                icon: Icon(Icons.delete_forever, color: Colors.grey),
                              ),
                            )
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deletePics(MovimentiModel movimento) async{
    try{
      final response = await http.delete(
        Uri.parse('$ipaddress/api/immagine/movimento/${int.parse(movimento.id.toString())}'),
        headers: {'Content-Type': 'application/json'},
      );
      if(response.statusCode == 204){
        print('Immagini eliminate');
        await Future.delayed(Duration(seconds: 2));
        deleteMovimentazione(movimento);
      }
    } catch(e){
      print('Errore durante la richiesta HTTP: $e');
      deleteMovimentazione(movimento);
    }
  }

  Future<void> deleteMovimentazione(MovimentiModel movimento) async {
    try {
      final response = await http.delete(
        Uri.parse('$ipaddress/api/movimenti/${movimento.id}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 204) {
        print('Movimentazione eliminata con successo.');
        Navigator.pop(context);
        getAllMovimentazioni();
      } else {
        print('Errore durante l\'eliminazione della movimentazione: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la richiesta HTTP: $e');
    }
  }

  void _generateExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Definisci gli stili per le righe alternate
    CellStyle whiteBackground = CellStyle(
      backgroundColorHex: '#FFFFFF', // Bianco
      fontFamily: getFontFamily(FontFamily.Arial),
    );

    CellStyle greenBackground = CellStyle(
      backgroundColorHex: '#CCFFCC', // Verde chiaro
      fontFamily: getFontFamily(FontFamily.Arial),
    );

    // Aggiungi l'intestazione
    sheetObject.appendRow([
      'Data',
      'Tipo di movimentazione',
      'Importo',
      'Descrizione',
      'Utente',
    ]);

    // Applica lo stile di sfondo bianco per l'intestazione
    for (var i = 0; i < sheetObject.maxCols; i++) {
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .cellStyle = whiteBackground;
    }

    double total = 0;
    for (var spesa in movimentiList2) {
      if (spesa.importo != null) {
        if (spesa.tipo_movimentazione == TipoMovimentazione.Uscita ||
            spesa.tipo_movimentazione == TipoMovimentazione.Prelievo) {
          total -= spesa.importo!;
        } else if (spesa.tipo_movimentazione == TipoMovimentazione.Acconto ||
            spesa.tipo_movimentazione == TipoMovimentazione.Pagamento ||
            spesa.tipo_movimentazione == TipoMovimentazione.Entrata ||
            spesa.tipo_movimentazione == TipoMovimentazione.Versamento) {
          total += spesa.importo!;
        }
      }
    }

    int rowIndex = 1; // Inizia dalla seconda riga (indice 1)
    for (var spesa in movimentiList2) {
      String importoFormatted;
      if (spesa.importo != null) {
        if (spesa.tipo_movimentazione == TipoMovimentazione.Uscita ||
            spesa.tipo_movimentazione == TipoMovimentazione.Prelievo) {
          importoFormatted = '-${spesa.importo!.toStringAsFixed(2)}';
        } else if (spesa.tipo_movimentazione == TipoMovimentazione.Acconto ||
            spesa.tipo_movimentazione == TipoMovimentazione.Pagamento ||
            spesa.tipo_movimentazione == TipoMovimentazione.Entrata) {
          importoFormatted = '+${spesa.importo!.toStringAsFixed(2)}';
        } else {
          importoFormatted = spesa.importo!.toStringAsFixed(2);
        }
      } else {
        importoFormatted = 'N/A';
      }

      // Aggiungi la riga
      sheetObject.appendRow([
        spesa.data != null ? DateFormat('yyyy-MM-dd').format(spesa.data!) : 'N/A',
        spesa.tipo_movimentazione.toString().split('.').last ?? 'N/A',
        importoFormatted,
        spesa.descrizione ?? 'N/A',
        spesa.utente?.cognome ?? 'N/A'
      ]);

      // Alterna il colore di sfondo tra bianco e verde chiaro
      var backgroundColor = rowIndex % 2 == 0 ? whiteBackground : greenBackground;
      for (var i = 0; i < sheetObject.maxCols; i++) {
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex))
            .cellStyle = backgroundColor;
      }
      rowIndex++;
    }

    // Aggiungi la riga totale
    sheetObject.appendRow([
      'Totale',
      '',
      total.toStringAsFixed(2),
      '',
      ''
    ]);

    // Applica lo stile alla riga totale (bianco)
    for (var i = 0; i < sheetObject.maxCols; i++) {
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex))
          .cellStyle = whiteBackground;
    }

    try {
      late String filePath;
      if (Platform.isWindows) {
        String appDocumentsPath = 'C:\\ReportRegistroCassa';
        filePath = '$appDocumentsPath\\report_registro_cassa.xlsx';
      } else if (Platform.isAndroid) {
        Directory? externalStorageDir = await getExternalStorageDirectory();
        if (externalStorageDir != null) {
          String appDocumentsPath = externalStorageDir.path;
          filePath = '$appDocumentsPath/report_registro_cassa.xlsx';
        } else {
          throw Exception('Impossibile ottenere il percorso di salvataggio.');
        }
      }
      var excelBytes = await excel.encode();
      if (excelBytes != null) {
        await File(filePath).create(recursive: true).then((file) {
          file.writeAsBytesSync(excelBytes);
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Excel salvato in $filePath')));
      } else {
        print('Errore durante la codifica del file Excel');
      }
    } catch (error) {
      print('Errore durante il salvataggio del file Excel: $error');
    }
  }

  String _getTipoMovimentazioneString(TipoMovimentazione? tipoMovimentazione) {
    if (tipoMovimentazione == TipoMovimentazione.Entrata) {
      return 'Entrata';
    } else if (tipoMovimentazione == TipoMovimentazione.Uscita){
      return 'Uscita';
    } else if (tipoMovimentazione == TipoMovimentazione.Pagamento){
      return 'Pagamento';
    } else if (tipoMovimentazione == TipoMovimentazione.Acconto){
      return 'Acconto';
    } else if (tipoMovimentazione == TipoMovimentazione.Prelievo){
      return 'Prelievo';
    } else if (tipoMovimentazione == TipoMovimentazione.Versamento){
      return 'Versamento';
    } else {
      return 'Informazione non disponibile';
    }
  }

  double calcolaFondoCassa(List<MovimentiModel> movimenti) {
    double fondoCassa = 0;
    for (var movimento in movimenti) {
      if (movimento.importo != null) {
        if (movimento.tipo_movimentazione == TipoMovimentazione.Entrata || movimento.tipo_movimentazione == TipoMovimentazione.Pagamento || movimento.tipo_movimentazione == TipoMovimentazione.Acconto || movimento.tipo_movimentazione == TipoMovimentazione.Versamento) {
          fondoCassa += movimento.importo!;
        } else if (movimento.tipo_movimentazione == TipoMovimentazione.Uscita || movimento.tipo_movimentazione == TipoMovimentazione.Prelievo) {
          fondoCassa -= movimento.importo!;
        }
      }
    }
    return fondoCassa;
  }

  Future<void> getAllMovimentazioniExcel() async{
    try{
      var apiUrl = Uri.parse('${ipaddress}/api/movimenti');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<MovimentiModel> movimenti = [];
        for(var item in jsonData){
          MovimentiModel movimento = MovimentiModel.fromJson(item);
          DateTime now = DateTime.now();
          DateTime startOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 1);
          DateTime endOfWeek = startOfWeek.add(Duration(days: 7));
          if (movimento.dataCreazione!.isAfter(startOfWeek) && movimento.dataCreazione!.isBefore(endOfWeek)) {
            movimenti.add(movimento);
          }
        }
        setState(() {
          movimentiList2 = movimenti;
        });
      }
    } catch(e){
      print('Error $e');
    }
  }

  Future<void> getAllMovimentazioni() async {
    try {
      var apiUrl = Uri.parse('${ipaddress}/api/movimenti/ordered');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<MovimentiModel> movimenti = [];
        for (var item in jsonData) {
          MovimentiModel movimento = MovimentiModel.fromJson(item);
          DateTime now = DateTime.now();
          DateTime startOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 1);
          DateTime endOfWeek = startOfWeek.add(Duration(days: 7));
          if (movimento.dataCreazione!.isAfter(startOfWeek) && movimento.dataCreazione!.isBefore(endOfWeek)) {
            movimenti.add(movimento);
          }
          DateTime startOfPreviousWeek1 = startOfWeek.subtract(Duration(days: 7));
          DateTime endOfPreviousWeek1 = startOfWeek;
          DateTime startOfPreviousWeek2 = startOfWeek.subtract(Duration(days: 14));
          DateTime endOfPreviousWeek2 = startOfPreviousWeek1;
          DateTime startOfPreviousWeek3 = startOfWeek.subtract(Duration(days: 21));
          DateTime endOfPreviousWeek3 = startOfPreviousWeek2;
          if (movimento.dataCreazione!.isAfter(startOfPreviousWeek1) && movimento.dataCreazione!.isBefore(endOfPreviousWeek1)) {
            fondoCassaSettimana1 = calcolaFondoCassa([movimento]);
          } else if (movimento.dataCreazione!.isAfter(startOfPreviousWeek2) && movimento.dataCreazione!.isBefore(endOfPreviousWeek2)) {
            fondoCassaSettimana2 = calcolaFondoCassa([movimento]);
          } else if (movimento.dataCreazione!.isAfter(startOfPreviousWeek3) && movimento.dataCreazione!.isBefore(endOfPreviousWeek3)) {
            fondoCassaSettimana3 = calcolaFondoCassa([movimento]);
          }
        }
        setState(() {
          fondoCassa = calcolaFondoCassa(movimenti);
          movimentiList = movimenti; // Calculate fondoCassa here
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during API call: $e');
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

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Scaricare excel del report?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _generateExcel();
                Navigator.of(context).pop();
              },
              child: Text('Conferma', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showUscitaDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('COMPILA LE INFORMAZIONI DELL\'USCITA'),
          content: Form( // Avvolgi tutto dentro un Form
            key: _formKeyUscita,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _descrizioneUscitaController,
                  decoration: InputDecoration(
                    labelText: 'Descrizione'.toUpperCase(),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) { // Aggiungi validatore
                    if (value == null || value.isEmpty) {
                      return 'Inserisci una descrizione valida';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _uscitaController,
                  decoration: InputDecoration(
                    labelText: 'Importo uscita'.toUpperCase(),
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // consenti solo numeri e fino a 2 decimali
                  ],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) { // Aggiungi validatore
                    if (value == null || value.isEmpty) {
                      return 'Inserisci un importo valido';
                    }
                    try {
                      double.parse(value);
                    } catch (e) {
                      return 'Inserisci un importo numerico valido';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_formKeyUscita.currentState!.validate()) { // Convalida il form
                  addUscita();
                }
              },
              child: Text('Conferma uscita'.toUpperCase()),
            ),
          ],
        );
      },
    );
  }

  void _showPrelievoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('INSERISCI L\'IMPORTO DEL PRELIEVO'),
          content: Form( // Avvolgi tutto dentro un Form
            key: _formKeyPrelievo,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _prelievoController,
                  decoration: InputDecoration(
                    labelText: 'Importo prelievo'.toUpperCase(),
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // Consenti solo numeri e fino a 2 decimali
                  ],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) { // Aggiungi validatore
                    if (value == null || value.isEmpty) {
                      return 'Inserisci un importo valido';
                    }
                    // Rimuovi spazi vuoti o caratteri indesiderati
                    String cleanedValue = value.trim();
                    try {
                      double.parse(cleanedValue);  // Convalida se può essere convertito in double
                    } catch (e) {
                      return 'Inserisci un importo numerico valido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 5),
                Container(
                  width: 700,
                  height: 250,
                  child: SfSignaturePad(
                    key: _signaturePadKey,
                    backgroundColor: Colors.white,
                    strokeColor: Colors.black,
                    minimumStrokeWidth: 2.0,
                    maximumStrokeWidth: 4.0,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                if (_formKeyPrelievo.currentState!.validate()) { // Convalida il form
                  // Puliamo l'input prima di inviarlo alla funzione
                  String cleanedInput = _prelievoController.text.trim();

                  // Ottieni la firma dal SignaturePad
                  final signaturePadState = _signaturePadKey.currentState;
                  if (signaturePadState != null) {
                    final image = await signaturePadState.toImage(); // Ottieni l'immagine come dart:ui Image
                    final byteData = await image.toByteData(format: ImageByteFormat.png); // Convertilo in PNG
                    final Uint8List? firmaIncaricato = byteData?.buffer.asUint8List(); // Ottieni i byte come Uint8List

                    if (firmaIncaricato != null) {
                      // Passa la firma e i dati alla pagina PDFPrelievoCassaPage
                      addPrelievo(cleanedInput).whenComplete(() =>
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PDFPrelievoCassaPage(
                                descrizione: 'Prelievo del ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                                data: DateTime.now(),
                                utente: widget.userData,
                                tipoMovimentazione: TipoMovimentazione.Prelievo,
                                importo: _prelievoController.text,
                                firmaIncaricato: firmaIncaricato, // Passa la firma come Uint8List
                              ),
                            ),
                          ),
                      );
                    } else {
                      // Gestisci il caso in cui la firma non è stata raccolta
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Firma non valida, riprova.')),
                      );
                    }
                  }
                }
              },

              child: Text('Conferma prelievo'.toUpperCase()),
            ),
          ],
        );
      },
    );
  }

  void _showVersamentoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('INSERISCI L\'IMPORTO DEL VERSAMENTO E LA CAUSALE'),
          content: Form( // Avvolgi tutto dentro un Form
            key: _formKeyVersamento,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _causaleVersamentoController,
                  decoration: InputDecoration(
                    labelText: 'Causale versamento'.toUpperCase(),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) { // Aggiungi validatore
                    if (value == null || value.isEmpty) {
                      return 'Inserisci una causale valida';
                    }
                  },
                ),
                SizedBox(height: 5),
                TextFormField(
                  controller: _versamentoController,
                  decoration: InputDecoration(
                    labelText: 'Importo versamento'.toUpperCase(),
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // Consenti solo numeri e fino a 2 decimali
                  ],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) { // Aggiungi validatore
                    if (value == null || value.isEmpty) {
                      return 'Inserisci un importo valido';
                    }
                    try {
                      double.parse(value);
                    } catch (e) {
                      return 'Inserisci un importo numerico valido';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_formKeyVersamento.currentState!.validate()) { // Convalida il form
                  addVersamento(_versamentoController.text);
                }
              },
              child: Text('Conferma versamento'.toUpperCase()),
            ),
          ],
        );
      },
    );
  }

  Future<void> addUscita() async{
    try{
       final response = await http.post(
         Uri.parse('$ipaddress/api/movimenti'),
         headers: {'Content-Type': 'application/json'},
         body: jsonEncode({
           'data': DateTime.now().toIso8601String(),
           'descrizione' : _descrizioneUscitaController.text.toString().toUpperCase(),
           'tipo_movimentazione' : "Uscita",
           'importo' : double.parse(_uscitaController.text.toString()),
           'utente' : widget.userData.toMap()
         }),
       );
       if (response.statusCode == 201) {
         Navigator.pop(context);
         _uscitaController.clear();
         _descrizioneUscitaController.clear();
         setState(() {
           showSubMenu = false;
         });
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Movimentazione salvata con successo'),
           ),
         );
         getAllMovimentazioni();
       } else {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Errore durante il salvataggio della movimentazione'),
           ),
         );
       }
    } catch (e) {
      print('Ops: $e');
    }
  }

  Future<void> addPrelievo(String importo) async {
    try {
      final response = await http.post(
        Uri.parse('$ipaddress/api/movimenti'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({  // serializza il corpo della richiesta come JSON
          'data': DateTime.now().toIso8601String(),
          'descrizione': "Prelievo del ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}".toUpperCase(),
          'tipo_movimentazione': "Prelievo",
          'importo': importo,
          'utente': widget.userData.toMap()
        }),
      );
      if (response.statusCode == 201) {
        Navigator.pop(context);
        _prelievoController.clear();
        setState(() {
          showSubMenu = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Movimentazione salvata con successo'.toUpperCase()),
          ),
        );
        getAllMovimentazioni();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante il salvataggio della movimentazione'),
          ),
        );
      }
    } catch (e) {
      print('Ops: $e');
    }
  }

  Future<void> addVersamento(String importo) async {
    try {
      final response = await http.post(
        Uri.parse('$ipaddress/api/movimenti'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({  // serializza il corpo della richiesta come JSON
          'data': DateTime.now().toIso8601String(),
          'descrizione': _causaleVersamentoController.text.toUpperCase(),
          'tipo_movimentazione': "Versamento",
          'importo': double.parse(_versamentoController.text.toString()),
          'utente': widget.userData.toMap()
        }),
      );
      if (response.statusCode == 201) {
        Navigator.pop(context);
        _versamentoController.clear();
        setState(() {
          showSubMenu = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Movimentazione salvata con successo'.toUpperCase()),
          ),
        );
        getAllMovimentazioni();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante il salvataggio della movimentazione'),
          ),
        );
      }
    } catch (e) {
      print('Ops: $e');
    }
  }

  void _showPreviousWeeksDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Fondo cassa settimane precedenti'),
          content: Container(
            height: 200, // Personalizza l'altezza del dialog
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fondo cassa ${DateFormat('dd/MM').format(getStartOfPreviousWeek(1))}: ${fondoCassaSettimana1 ?? 'N/A'}'), // Aggiungi il fondo cassa della prima settimana
                SizedBox(height: 8),
                Text('Fondo cassa ${DateFormat('dd/MM').format(getStartOfPreviousWeek(2))}: ${fondoCassaSettimana2 ?? 'N/A'}'), // Aggiungi il fondo cassa della seconda settimana
                SizedBox(height: 8),
                Text('Fondo cassa ${DateFormat('dd/MM').format(getStartOfPreviousWeek(3))}: ${fondoCassaSettimana3 ?? 'N/A'}'), // Aggiungi il fondo cassa della terza settimana
              ],
            ),
          ),
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

  DateTime getStartOfPreviousWeek(int weekNumber) {
    DateTime now = DateTime.now();
    DateTime startOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 1);
    return startOfWeek.subtract(Duration(days: 7 * weekNumber));
  }
}
