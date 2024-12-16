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
import 'AcquistoFornitorePage.dart';
import 'AggiungiMovimentoPage.dart';
import 'DettaglioInterventoNewPage.dart';
import 'DettaglioSpesaFornitorePage.dart';
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
  List<DateTime> dateChiusure = [];

  List<MovimentiModel> movimentiListPreviousWeek = [];
  List<MovimentiModel> movimentiListPreviousWeek2 = [];
  List<MovimentiModel> movimentiListPreviousWeek3 = [];
  List<UtenteModel> allUtenti = [];
  UtenteModel? selectedUtente;
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  double? fondoCassaSettimana1;
  double? fondoCassaSettimana2;
  double? fondoCassaSettimana3;
  final ScrollController _scrollController = ScrollController();
  double fondoCassa = 0.0;
  bool showSubMenu = false;
  final _formKeyUscita = GlobalKey<FormState>();
  final _formKeyPrelievo = GlobalKey<FormState>();
  final _formKeyVersamento = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
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

  Future<void> getAllUtenti() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/utente/attivo');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<UtenteModel> utenti = [];
        for(var item in jsonData){
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          allUtenti = utenti;
        });
      } else {
        throw Exception('Failed to load utenti data from API: ${response.statusCode}');
      }
    } catch(e){
      print('Qualcosa non va utenti : $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getAllMovimentazioni();
    getAllMovimentazioniExcel();
    getAllUtenti();
  }

  @override
  Widget build(BuildContext context) {
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
              Icons.balance,
              color: Colors.white,
            ),
            onPressed: (){
              openChiusuraDialog(context, fondoCassa);
            },
          ),
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
                  child: Icon(Icons.shopping_bag_outlined, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Acquisto da fornitore'.toUpperCase(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AcquistoFornitorePage(utente : widget.userData),
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
                    DataColumn(label: Text('Fornitore', style: TextStyle(fontWeight: FontWeight.bold))),
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
                        DataCell(
                          movimento.tipo_movimentazione == TipoMovimentazione.Prelievo
                              ? GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PDFPrelievoCassaPage(
                                    descrizione: movimento.descrizione ?? '',
                                    data: movimento.dataCreazione,
                                    utente: movimento.utente,
                                    tipoMovimentazione: TipoMovimentazione.Prelievo,
                                    importo: movimento.importo?.toString() ?? '',
                                    firmaIncaricato: null, // Passa la firma come Uint8List
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 1.0), // Aggiunge spazio tra testo e underline
                                  child: Text(
                                    'Prelievo',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
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
                          )
                              : Text(
                            _getTipoMovimentazioneString(movimento.tipo_movimentazione),
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        DataCell(Text(movimento.importo != null ? movimento.importo!.toStringAsFixed(2) + '€' : '')),
                        DataCell(Text(movimento.cliente != null ? movimento.cliente!.denominazione! : '///')),
                        DataCell(
                          GestureDetector(
                            onTap: () {
                              if (movimento.fornitore != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DettaglioSpesaFornitorePage(movimento: movimento),
                                  ),
                                );
                              }
                            },
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 1.0), // Aggiunge spazio tra testo e underline
                                  child: Text(
                                    movimento.fornitore != null ? movimento.fornitore!.denominazione! : '///',
                                    style: TextStyle(
                                      color: movimento.fornitore != null ? Colors.blue : Colors.black,
                                    ),
                                  ),
                                ),
                                if (movimento.fornitore != null)
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
                        DataCell(
                          GestureDetector(
                            onTap: () {
                              if (movimento.intervento != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DettaglioInterventoNewPage(intervento: movimento.intervento!, utente: widget.userData,),
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

  void openChiusuraDialog(BuildContext context, double fondoCassa) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Conferma Chiusura'),
          content: Text('Confermare la chiusura con un fondo cassa pari a $fondoCassa€?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                confermaChiusura(); // Chiama la funzione di conferma chiusura
              },
              child: Text('Sì'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Chiude il dialog senza confermare
              },
              child: Text('No'),
            ),
          ],
        );
      },
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
      'Fornitore',
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
        spesa.tipo_movimentazione.toString().split('.').last,
        importoFormatted,
        spesa.descrizione ?? 'N/A',
        spesa.fornitore?.denominazione ?? 'N/A',
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
    } else if (tipoMovimentazione == TipoMovimentazione.Chiusura){
      return 'Chiusura';
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

  void calcolaFondiCassaSettimanePrecedenti() {
    setState(() {
      fondoCassaSettimana1 = _arrotondaA2Decimali(calcolaFondoCassa(movimentiListPreviousWeek));
      fondoCassaSettimana2 = _arrotondaA2Decimali(calcolaFondoCassa(movimentiListPreviousWeek2));
      fondoCassaSettimana3 = _arrotondaA2Decimali(calcolaFondoCassa(movimentiListPreviousWeek3));
    });

    // Debug: stampa dei valori calcolati
    print('Fondo cassa settimana 1 (ultima chiusura - penultima): $fondoCassaSettimana1');
    print('Fondo cassa settimana 2 (penultima - terzultima): $fondoCassaSettimana2');
    print('Fondo cassa settimana 3 (terzultima - quartultima): $fondoCassaSettimana3');
  }

// Funzione di arrotondamento
  double _arrotondaA2Decimali(double valore) {
    return double.parse(valore.toStringAsFixed(2));
  }

  Future<void> getAllMovimentazioniExcel() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/movimenti');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<MovimentiModel> movimenti = [];
        DateTime? lastChiusuraDate;
        // Primo loop per trovare la data dell'ultimo movimento di tipo "Chiusura"
        for (var item in jsonData) {
          MovimentiModel movimento = MovimentiModel.fromJson(item);
          if (movimento.tipo_movimentazione == TipoMovimentazione.Chiusura) {
            if (lastChiusuraDate == null || movimento.dataCreazione!.isAfter(lastChiusuraDate)) {
              lastChiusuraDate = movimento.dataCreazione;
            }
          }
        }
        // Se troviamo una data di chiusura valida, usiamola come data di inizio
        DateTime startDate = lastChiusuraDate ?? DateTime(2000); // Default inizio lontano se non ci sono chiusure
        // Secondo loop per raccogliere i movimenti dopo la data di chiusura
        for (var item in jsonData) {
          MovimentiModel movimento = MovimentiModel.fromJson(item);
          if (movimento.dataCreazione != null && movimento.dataCreazione!.isAfter(startDate)) {
            movimenti.add(movimento);
          }
        }
        // Aggiornamento dello stato con la lista dei movimenti trovati
        setState(() {
          movimentiList2 = movimenti;
        });
      }
    } catch (e) {
      print('Error $e');
    }
  }

  Future<void> getAllMovimentazioni() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/movimenti/ordered');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<MovimentiModel> movimenti = [];
        dateChiusure.clear(); // Usa la lista globale e svuotala prima di aggiungere nuovi valori

        // Individua tutte le date di "Chiusura"
        for (var item in jsonData) {
          MovimentiModel movimento = MovimentiModel.fromJson(item);
          if (movimento.tipo_movimentazione == TipoMovimentazione.Chiusura) {
            dateChiusure.add(movimento.dataCreazione!);
          } else {
            movimenti.add(movimento); // Aggiungi solo movimenti non di chiusura
          }
        }

        // Ordina le date di chiusura in ordine decrescente
        dateChiusure.sort((a, b) => b.compareTo(a));

        // Identifica le ultime 4 date di chiusura
        DateTime? ultimaChiusura = dateChiusure.isNotEmpty ? dateChiusure[0] : null;
        DateTime? penultimaChiusura = dateChiusure.length > 1 ? dateChiusure[1] : null;
        DateTime? terzultimaChiusura = dateChiusure.length > 2 ? dateChiusure[2] : null;
        DateTime? quartultimaChiusura = dateChiusure.length > 3 ? dateChiusure[3] : null;

        // Filtra i movimenti per le varie liste
        List<MovimentiModel> movimentiDopoUltimaChiusura = [];
        List<MovimentiModel> movimentiTraUltimaESeconda = [];
        List<MovimentiModel> movimentiTraSecondaETerza = [];
        List<MovimentiModel> movimentiTraTerzaEQuarta = [];

        for (var movimento in movimenti) {
          if (ultimaChiusura != null && movimento.dataCreazione!.isAfter(ultimaChiusura)) {
            movimentiDopoUltimaChiusura.add(movimento);
          } else if (penultimaChiusura != null &&
              movimento.dataCreazione!.isAfter(penultimaChiusura) &&
              movimento.dataCreazione!.isBefore(ultimaChiusura!)) {
            movimentiTraUltimaESeconda.add(movimento);
          } else if (terzultimaChiusura != null &&
              movimento.dataCreazione!.isAfter(terzultimaChiusura) &&
              movimento.dataCreazione!.isBefore(penultimaChiusura!)) {
            movimentiTraSecondaETerza.add(movimento);
          } else if (quartultimaChiusura != null &&
              movimento.dataCreazione!.isAfter(quartultimaChiusura) &&
              movimento.dataCreazione!.isBefore(terzultimaChiusura!)) {
            movimentiTraTerzaEQuarta.add(movimento);
          }
        }

        // Aggiorna lo stato con le liste calcolate
        setState(() {
          fondoCassa = calcolaFondoCassa(movimentiDopoUltimaChiusura);
          movimentiList = movimentiDopoUltimaChiusura;
          movimentiListPreviousWeek = movimentiTraUltimaESeconda;
          movimentiListPreviousWeek2 = movimentiTraSecondaETerza;
          movimentiListPreviousWeek3 = movimentiTraTerzaEQuarta;
        });

        calcolaFondiCassaSettimanePrecedenti();
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
                    labelText: 'DESCRIZIONE',
                    labelStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: 'Inserisci una descrizione valida',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.redAccent,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  validator: (value) {
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
                    labelText: 'IMPORTO USCITA',
                    labelStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: 'Inserisci un importo valido',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.redAccent,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // Consenti solo numeri e fino a 2 decimali
                  ],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
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
                SizedBox(height: 12),
                if(widget.userData.nome == "Segreteria")
                  Column(
                    children: [
                      DropdownButtonFormField<UtenteModel>(
                        decoration: InputDecoration(
                          labelText: 'SELEZIONA UTENTE',
                          labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.redAccent,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.0,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        ),
                        value: selectedUtente,
                        items: allUtenti.map((utente) {
                          return DropdownMenuItem<UtenteModel>(
                            value: utente,
                            child: Text(utente.nomeCompleto() ?? 'Nome non disponibile'),
                          );
                        }).toList(),
                        onChanged: (UtenteModel? val) {
                          setState(() {
                            selectedUtente = val;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Seleziona un utente';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'PASSWORD UTENTE',
                          labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                          hintText: 'Inserire la password dell\'utente',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.redAccent,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.0,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Inserisci una password valida';
                          }
                          return null;
                        },
                      ),
                    ],
                  )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_formKeyUscita.currentState!.validate()) { // Convalida il form
                  if(widget.userData.nome == "Segreteria"){
                    if(_passwordController.text == selectedUtente?.password){
                      addUscita();
                      setState(() {
                        selectedUtente = null;
                        _passwordController.clear();
                      });
                    } else {
                      showPasswordErrorDialog(context);
                    }
                  } else{
                    addUscita();
                  }
                }
              },
              child: Text('Conferma uscita'.toUpperCase()),
            ),
          ],
        );
      },
    );
  }

  Future<void> showPasswordErrorDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Impedisce la chiusura toccando fuori dal dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Errore'),
          content: Text('Password errata, impossibile creare il movimento'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Chiude il dialog
              },
              child: Text('Ok'),
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
                    labelText: 'IMPORTO PRELIEVO',
                    labelStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: 'Inserisci un importo valido',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.redAccent,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // Consenti solo numeri e fino a 2 decimali
                  ],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
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
                if(widget.userData.nome == "Segreteria")
                  Column(
                    children: [
                      SizedBox(height: 12),
                      DropdownButtonFormField<UtenteModel>(
                        decoration: InputDecoration(
                          labelText: 'SELEZIONA UTENTE',
                          labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.redAccent,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.0,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        ),
                        value: selectedUtente,
                        items: allUtenti.map((utente) {
                          return DropdownMenuItem<UtenteModel>(
                            value: utente,
                            child: Text(utente.nomeCompleto() ?? 'Nome non disponibile'),
                          );
                        }).toList(),
                        onChanged: (UtenteModel? val) {
                          setState(() {
                            selectedUtente = val;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Seleziona un utente';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'PASSWORD UTENTE',
                          labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                          hintText: 'Inserire la password dell\'utente',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.redAccent,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.0,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Inserisci una password valida';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                SizedBox(height: 10),
                Text('Inserire la firma', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
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
                  if(widget.userData.nome == "Segreteria"){
                    if(_passwordController.text == selectedUtente?.password){
                      String cleanedInput = _prelievoController.text.trim();

                      // Ottieni la firma dal SignaturePad
                      final signaturePadState = _signaturePadKey.currentState;
                      if (signaturePadState != null) {
                        final image = await signaturePadState
                            .toImage(); // Ottieni l'immagine come dart:ui Image
                        final byteData = await image.toByteData(
                            format: ImageByteFormat.png); // Convertilo in PNG
                        final Uint8List? firmaIncaricato = byteData?.buffer
                            .asUint8List(); // Ottieni i byte come Uint8List

                        if (firmaIncaricato != null) {
                          // Passa la firma e i dati alla pagina PDFPrelievoCassaPage
                          addPrelievo(cleanedInput).whenComplete(() =>
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PDFPrelievoCassaPage(
                                        descrizione: 'Prelievo del ${DateFormat(
                                            'dd/MM/yyyy').format(
                                            DateTime.now())}',
                                        data: DateTime.now(),
                                        utente: selectedUtente,
                                        tipoMovimentazione: TipoMovimentazione
                                            .Prelievo,
                                        importo: cleanedInput,
                                        firmaIncaricato: firmaIncaricato, // Passa la firma come Uint8List
                                      ),
                                ),
                              ),
                          );
                        } else {
                          // Gestisci il caso in cui la firma non è stata raccolta
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(
                                'Firma non valida, riprova.')),
                          );
                        }
                      }
                    } else {
                      showPasswordErrorDialog(context);
                    }
                  } else {
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
                                  importo: cleanedInput,
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
                    labelText: 'CAUSALE VERSAMENTO',
                    labelStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: 'Inserisci la causale del versamento',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.redAccent,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci una causale valida';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _versamentoController,
                  decoration: InputDecoration(
                    labelText: 'IMPORTO VERSAMENTO',
                    labelStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: 'Inserisci l\'importo del versamento',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.redAccent,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // Consenti solo numeri e fino a 2 decimali
                  ],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci un importo valido';
                    }
                    try {
                      double.parse(value);  // Verifica che il valore sia un numero
                    } catch (e) {
                      return 'Inserisci un importo numerico valido';
                    }
                    return null;
                  },
                ),
                if(widget.userData.nome == "Segreteria")
                  Column(
                    children: [
                      SizedBox(height: 12),
                      DropdownButtonFormField<UtenteModel>(
                        decoration: InputDecoration(
                          labelText: 'SELEZIONA UTENTE',
                          labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.redAccent,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.0,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        ),
                        value: selectedUtente,
                        items: allUtenti.map((utente) {
                          return DropdownMenuItem<UtenteModel>(
                            value: utente,
                            child: Text(utente.nomeCompleto() ?? 'Nome non disponibile'),
                          );
                        }).toList(),
                        onChanged: (UtenteModel? val) {
                          setState(() {
                            selectedUtente = val;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Seleziona un utente';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'PASSWORD UTENTE',
                          labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                          hintText: 'Inserire la password dell\'utente',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.redAccent,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.0,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Inserisci una password valida';
                          }
                          return null;
                        },
                      ),
                    ],
                  )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_formKeyVersamento.currentState!.validate()) {
                  if(widget.userData.nome == "Segreteria"){
                    if(_passwordController.text == selectedUtente?.password){
                      addVersamento(_versamentoController.text);
                      setState(() {
                        selectedUtente = null;
                        _passwordController.clear();
                      });
                    } else {
                      showPasswordErrorDialog(context);
                    }
                  } else {
                    addVersamento(_versamentoController.text);
                  }
                }
              },
              child: Text('Conferma versamento'.toUpperCase()),
            ),
          ],
        );
      },
    );
  }

  void confermaChiusura() async {
    showDialog(
      context: context,
      barrierDismissible: false, // Evita la chiusura del dialog finché l'operazione è in corso
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      final response = await http.post(
        Uri.parse('$ipaddress/api/movimenti'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': DateTime.now().toIso8601String(),
          'descrizione': "Chiusura cassa al ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}".toUpperCase(),
          'tipo_movimentazione': "Chiusura",
          'importo': 0,
          'utente': widget.userData.toMap()
        }),
      );
      if (response.statusCode == 201) {
        // Attesa di 1,5 secondi prima di chiamare la funzione `saveFondocassaAfterChiusura`
        await Future.delayed(Duration(milliseconds: 1500));
        await saveFondocassaAfterChiusura();
      }
    } catch (e) {
      print('Qualcosa non va $e');
    } finally {
      // Chiudi il dialog di caricamento al termine dell'operazione
      Navigator.of(context).pop();
    }
  }

  Future<void> saveFondocassaAfterChiusura() async {
    try {
      final response = await http.post(
        Uri.parse('$ipaddress/api/movimenti'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': DateTime.now().toIso8601String(),
          'descrizione': "Fondo cassa al ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}".toUpperCase(),
          'tipo_movimentazione': "Versamento",
          'importo': fondoCassa,
          'utente': widget.userData.toMap()
        }),
      );
      if (response.statusCode == 201) {
        setState(() {
          getAllMovimentazioni(); // Ricarica la lista dei movimenti
        });
      }
    } catch (e) {
      print('Errore 2: $e');
    }
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
          'utente' : widget.userData.nome == "Segreteria" ? selectedUtente?.toMap() : widget.userData.toMap()
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
          'utente': widget.userData.nome == "Segreteria" ? selectedUtente?.toMap() : widget.userData.toMap()
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
          'utente': widget.userData.nome == "Segreteria" ? selectedUtente?.toMap() : widget.userData.toMap()
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
            height: 250, // Aumenta l'altezza per ospitare i pulsanti
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Settimana 1
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Fondo cassa ${DateFormat('dd/MM/yyyy').format(dateChiusure.length > 1 ? dateChiusure[1] : DateTime.now())}: '
                            '${fondoCassaSettimana1?.toStringAsFixed(2) ?? 'N/A'}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          movimentiList = movimentiListPreviousWeek;
                          fondoCassa = fondoCassaSettimana1!;
                        });
                        Navigator.pop(context); // Chiude il dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Sfondo rosso
                        foregroundColor: Colors.white, // Testo bianco
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Arrotondamento
                        ),
                      ),
                      child: Text('Visualizza'),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                // Settimana 2
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Fondo cassa ${DateFormat('dd/MM/yyyy').format(dateChiusure.length > 2 ? dateChiusure[2] : DateTime.now())}: '
                            '${fondoCassaSettimana2?.toStringAsFixed(2) ?? 'N/A'}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          movimentiList = movimentiListPreviousWeek2;
                          fondoCassa = fondoCassaSettimana2!;
                        });
                        Navigator.pop(context); // Chiude il dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Sfondo rosso
                        foregroundColor: Colors.white, // Testo bianco
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Arrotondamento
                        ),
                      ),
                      child: Text('Visualizza'),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                // Settimana 3
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Fondo cassa ${DateFormat('dd/MM/yyyy').format(dateChiusure.length > 3 ? dateChiusure[3] : DateTime.now())}: '
                            '${fondoCassaSettimana3?.toStringAsFixed(2) ?? 'N/A'}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          movimentiList = movimentiListPreviousWeek3;
                          fondoCassa = fondoCassaSettimana3!;
                        });
                        Navigator.pop(context); // Chiude il dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Sfondo rosso
                        foregroundColor: Colors.white, // Testo bianco
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Arrotondamento
                        ),
                      ),
                      child: Text('Visualizza'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Chiude il dialog senza cambiare lista
              },
              child: Text('Chiudi'),
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
