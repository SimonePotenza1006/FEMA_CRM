import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../model/SpesaVeicoloModel.dart';
import '../model/TipologiaSpesaVeicoloModel.dart';
import '../model/UtenteModel.dart';
import '../model/VeicoloModel.dart';

class SpesaSuVeicoloPage extends StatefulWidget {
  final UtenteModel utente;

  const SpesaSuVeicoloPage({Key? key, required this.utente}) : super(key: key);

  @override
  _SpesaSuVeicoloPageState createState() => _SpesaSuVeicoloPageState();
}

class _SpesaSuVeicoloPageState extends State<SpesaSuVeicoloPage> {
  List<TipologiaSpesaVeicoloModel> allTipologie = [];
  List<VeicoloModel> allVeicoli = [];
  List<SpesaVeicoloModel> allSpese = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  final TextEditingController _importoController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _dataPolizzaController = TextEditingController();
  final TextEditingController _dataBolloController = TextEditingController();
  final TextEditingController _noteFornitoreController = TextEditingController();
  final TextEditingController _noteSpesaController = TextEditingController();
  VeicoloModel? selectedVeicolo;
  TipologiaSpesaVeicoloModel? selectedTipologia;
  String? selectedFornitore;
  XFile? pickedImage;
  DateTime data = DateTime.now();
  DateTime? dataScadenzaPolizza;
  DateTime? dataScadenzaBollo;
  bool isKmValid = true;
  bool isImportoValid = true;
  final _formKey = GlobalKey<FormState>();

  void _validateKm() {
    if (selectedVeicolo != null) {
      int enteredKm = int.tryParse(_kmController.text) ?? 0;
      setState(() {
        isKmValid = enteredKm >= (selectedVeicolo!.chilometraggio_attuale ?? 0);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getTipologieSpesa();
    getAllVeicoli();
    if(widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti"){
      getAllSpese();
    }
  }

  Future<Uint8List?> compressImage(String imagePath) async {
    final result = await FlutterImageCompress.compressWithFile(
      imagePath,
      minHeight: 1920,
      minWidth: 1080,
      quality: 50, // Imposta la qualità dell'immagine tra 0 e 100
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spesa su veicolo'.toString().toUpperCase(), style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  SizedBox(
                    width: 206,
                    child: DropdownButtonFormField<VeicoloModel>(
                      value: selectedVeicolo,
                      onChanged: (VeicoloModel? newValue) {
                        setState(() {
                          selectedVeicolo = newValue;
                          _validateKm();
                        });
                      },
                      items: allVeicoli.map((VeicoloModel veicolo) {
                        return DropdownMenuItem<VeicoloModel>(
                          value: veicolo,
                          child: Text(veicolo.descrizione!),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Veicolo'.toString().toUpperCase(),
                      ),
                      validator: (value) => value == null ? 'Seleziona un veicolo'.toString().toUpperCase() : null,
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 207,
                    child: DropdownButtonFormField<TipologiaSpesaVeicoloModel>(
                      value: selectedTipologia,
                      onChanged: (TipologiaSpesaVeicoloModel? newValue) {
                        setState(() {
                          selectedTipologia = newValue;
                        });
                      },
                      items: allTipologie.map((TipologiaSpesaVeicoloModel tipologia) {
                        return DropdownMenuItem<TipologiaSpesaVeicoloModel>(
                          value: tipologia,
                          child: Text(tipologia.descrizione!),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'TIPOLOGIA DI SPESA',
                      ),
                      validator: (value) => value == null ? 'Seleziona una tipologia di spesa'.toString().toUpperCase() : null,
                    ),
                  ),
                  SizedBox(height: 20),
                  if (selectedTipologia?.descrizione == "ALTRO")
                    Container(
                      child: SizedBox(
                        width: 207,
                        height: 80,
                        child: TextFormField(
                          controller: _noteSpesaController,
                          decoration: InputDecoration(
                            labelText: "Tipologia di spesa".toString().toUpperCase(),
                            hintText: "Scrivere la tipologia di spesa".toString().toUpperCase(),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 2)),
                          ),
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Inserisci la tipologia di spesa'.toString().toUpperCase() : null,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: 207,
                    child: DropdownButtonFormField<String>(
                      value: selectedFornitore,
                      onChanged: (newValue) {
                        setState(() {
                          selectedFornitore = newValue;
                        });
                      },
                      items: [
                        'IP VIA EUROPA',
                        'ALTRO',
                      ].map((categoria) {
                        return DropdownMenuItem<String>(
                          value: categoria,
                          child: Text(categoria),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Fornitore'.toString().toUpperCase(),
                      ),
                      validator: (value) => value == null ? 'Seleziona un fornitore'.toString().toUpperCase() : null,
                    ),
                  ),
                  SizedBox(height: 20),
                  if (selectedFornitore == "ALTRO")
                    Container(
                      child: SizedBox(
                        width: 200,
                        height: 70,
                        child: TextFormField(
                          controller: _noteFornitoreController,
                          decoration: InputDecoration(
                            labelText: "Fornitore".toString().toUpperCase(),
                            hintText: "Scrivere il fornitore".toString().toUpperCase(),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 2)),
                          ),
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Inserisci il fornitore'.toString().toUpperCase() : null,
                        ),
                      ),
                    ),
                  if (selectedTipologia?.descrizione == "POLIZZA")
                    Column(
                      children: [
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _dataPolizzaController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Data nuova scadenza polizza".toString().toUpperCase(),
                            hintText: "Seleziona la nuova data di scadenza della polizza".toString().toUpperCase(),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: dataScadenzaPolizza ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                dataScadenzaPolizza = pickedDate;
                                _dataPolizzaController.text =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
                              });
                            }
                          },
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Seleziona una data'.toString().toUpperCase() : null,
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  if (selectedTipologia?.descrizione == "BOLLO")
                    Column(
                      children: [
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _dataBolloController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Data nuova scadenza bollo".toString().toUpperCase(),
                            hintText: "Seleziona la nuova data di scadenza del bollo".toString().toUpperCase(),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: dataScadenzaBollo ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                dataScadenzaBollo = pickedDate;
                                _dataBolloController.text =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
                              });
                            }
                          },
                          validator: (value) =>
                          value == null || value.isEmpty ? 'Seleziona una data'.toString().toUpperCase() : null,
                        ),
                      ],
                    ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      controller: _importoController,
                      decoration: InputDecoration(
                        labelText: "Importo".toString().toUpperCase(),
                        hintText: "Inserisci l'importo della spesa".toString().toUpperCase(),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 2.0),
                        ),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Inserisci un importo valido' : null,
                    ),
                  ),
                  SizedBox(height: 20),
                  if (selectedTipologia?.descrizione == "POLIZZA")
                    Center(
                      child: Text(
                          "Inserire un chilometraggio qualsiasi, il sistema recupererà il precedente record!".toString().toUpperCase()),
                    ),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      controller: _kmController,
                      decoration: InputDecoration(
                        labelText: "Chilometri".toString().toUpperCase(),
                        hintText: "Inserisci il chilometraggio".toString().toUpperCase(),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 2.0),
                        ),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Inserisci un chilometraggio valido'.toString().toUpperCase() : null,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Text(
                  //   'Scatta una foto:'.toString().toUpperCase(),
                  //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  // ),
                  SizedBox(height: 10),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.camera_alt),
                          onPressed: () {
                            takePicture();
                          },
                          iconSize: 50,
                        ),
                        if (pickedImage != null)
                          Container(
                            width: 50,
                            height: 50,
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      child: Image.file(
                                        File(pickedImage!.path),
                                        fit: BoxFit.contain,
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Image.file(File(pickedImage!.path)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24,),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        checkScadenze();
                        saveImmagine();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                      textStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    child: Text('Salva spesa'.toString().toUpperCase()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: widget.utente.cognome! == "Mazzei" || widget.utente.cognome! == "Chiriatti"
          ? Container(
        margin: EdgeInsets.only(bottom: 16, right: 16),
        child: FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: () {
            _showConfirmationDialog();
          },
          child: Icon(Icons.arrow_downward, color: Colors.white),
        ),
      )
          : null,
    );
  }


  void _validateImporto() {
    double? importo = double.tryParse(_importoController.text);
    setState(() {
      isImportoValid = importo != null && importo > 0;
    });
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Scaricare excel report delle spese su veicolo?'.toString().toUpperCase()),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _generateExcel();
                Navigator.of(context).pop();
              },
              child: Text('Conferma'.toString().toUpperCase(), style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _generateExcel() async{
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    sheetObject.appendRow([
      'Data Spesa',
      'Veicolo',
      'Utente',
      'Chilometraggio',
      'Tipologia Spesa',
      'Fornitore Carburante',
      'Importo'
    ]);
    for(var spesa in allSpese){
      sheetObject.appendRow([
        spesa.data != null
            ? DateFormat('yyyy-MM-dd').format(spesa.data!)
            : 'N/A',
        spesa.veicolo?.descrizione ?? 'N/A',
        spesa.utente!.nome! + spesa.utente!.cognome! ?? 'N/A',
        spesa.km ?? 'N/A',
        spesa.tipologia_spesa?.descrizione ?? 'N/A',
        spesa.fornitore_carburante ?? 'N/A',
        spesa.importo ?? 'N/A',
      ]);
      try {
        late String filePath;
        if (Platform.isWindows) {
          // Percorso di salvataggio su Windows
          String appDocumentsPath = 'C:\\ReportSpeseVeicolo';
          filePath = '$appDocumentsPath\\report_speseVeicolo.xlsx';
        } else if (Platform.isAndroid) {
          // Percorso di salvataggio su Android
          Directory? externalStorageDir = await getExternalStorageDirectory();
          if (externalStorageDir != null) {
            String appDocumentsPath = externalStorageDir.path;
            filePath = '$appDocumentsPath/report_speseVeicolo.xlsx';
          } else {
            throw Exception('Impossibile ottenere il percorso di salvataggio.');
          }
        }
        var excelBytes = await excel.encode();
        if (excelBytes != null) {
          await File(filePath).create(recursive: true).then((file) {
            file.writeAsBytesSync(excelBytes);
          });
          // Notifica all'utente che il file è stato salvato con successo
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Excel salvato in $filePath')));
        } else {
          // Gestisci il caso in cui excel.encode() restituisce null
          print('Errore durante la codifica del file Excel');
        }
      } catch (error) {
        // Gestisci eventuali errori durante il salvataggio del file
        print('Errore durante il salvataggio del file Excel: $error');
      }
    }
  }

  Future<http.Response?> saveNewInfoVeicolo() async{
    print("Step 2 save Info");
    if(selectedTipologia?.descrizione == "TAGLIANDO"){
      try{
        final response = await http.post(
          Uri.parse('$ipaddress/api/veicolo'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': selectedVeicolo?.id,
            'descrizione' : selectedVeicolo?.descrizione.toString().toUpperCase(),
            'targa' : selectedVeicolo?.targa.toString().toUpperCase(),
            'seriale' : selectedVeicolo?.seriale.toString().toUpperCase(),
            'imei' : selectedVeicolo?.imei.toString().toUpperCase(),
            'scadenza_gps' : selectedVeicolo?.scadenza_gps?.toIso8601String(),
            'proprietario' : selectedVeicolo?.proprietario.toString().toUpperCase(),
            'chilometraggio_attuale' : int.parse(_kmController.text.toString()),
            'data_scadenza_bollo' : selectedVeicolo?.data_scadenza_bollo?.toIso8601String(),
            'data_scadenza_polizza' : selectedVeicolo?.data_scadenza_polizza?.toIso8601String(),
            'data_tagliando' : DateTime.now().toIso8601String(),
            'chilometraggio_ultimo_tagliando' : int.parse(_kmController.text.toString()),
            'soglia_tagliando' : selectedVeicolo?.soglia_tagliando,
            'data_revisione' : selectedVeicolo?.data_revisione?.toIso8601String(),
            'data_inversione_gomme' : selectedVeicolo?.data_inversione_gomme?.toIso8601String(),
            'chilometraggio_ultima_inversione' : selectedVeicolo?.chilometraggio_ultima_inversione,
            'soglia_inversione' : selectedVeicolo?.soglia_inversione,
            'data_sostituzione_gomme' : selectedVeicolo?.data_sostituzione_gomme?.toIso8601String(),
            'chilometraggio_ultima_sostituzione' : selectedVeicolo?.chilometraggio_ultima_sostituzione,
            'soglia_sostituzione' : selectedVeicolo?.soglia_sostituzione
          }),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Record relativi al tagliando salvati correttamente!'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
        return response;
      } catch(e){
        print('Qualcosa non va con il salvataggio dei dati del tagliando: $e');
        return null;
      }
    } else if(selectedTipologia?.descrizione == "INVERSIONE GOMME") {
      try{
        final response = await http.post(
          Uri.parse('$ipaddress/api/veicolo'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': selectedVeicolo?.id,
            'descrizione' : selectedVeicolo?.descrizione.toString().toUpperCase(),
            'targa' : selectedVeicolo?.targa.toString().toUpperCase(),
            'seriale' : selectedVeicolo?.seriale.toString().toUpperCase(),
            'imei' : selectedVeicolo?.imei.toString().toUpperCase(),
            'scadenza_gps' : selectedVeicolo?.scadenza_gps?.toIso8601String(),
            'proprietario' : selectedVeicolo?.proprietario.toString().toUpperCase(),
            'chilometraggio_attuale' : int.parse(_kmController.text.toString()),
            'data_scadenza_bollo' : selectedVeicolo?.data_scadenza_bollo?.toIso8601String(),
            'data_scadenza_polizza' : selectedVeicolo?.data_scadenza_polizza?.toIso8601String(),
            'data_tagliando' : selectedVeicolo?.data_tagliando?.toIso8601String(),
            'chilometraggio_ultimo_tagliando' : selectedVeicolo?.chilometraggio_ultimo_tagliando,
            'soglia_tagliando' : selectedVeicolo?.soglia_tagliando,
            'data_revisione' : selectedVeicolo?.data_revisione?.toIso8601String(),
            'data_inversione_gomme' : DateTime.now().toIso8601String(),
            'chilometraggio_ultima_inversione' : int.parse(_kmController.text.toString()),
            'soglia_inversione' : selectedVeicolo?.soglia_inversione,
            'data_sostituzione_gomme' : selectedVeicolo?.data_sostituzione_gomme?.toIso8601String(),
            'chilometraggio_ultima_sostituzione' : selectedVeicolo?.chilometraggio_ultima_sostituzione,
            'soglia_sostituzione' : selectedVeicolo?.soglia_sostituzione
          }),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Record relativi all\'inversione delle gomme salvati correttamente!'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
        return response;
      } catch(e){
        print('Qualcosa non va con il salvataggio dei dati dell\'inversione: $e');
        return null;
      }
    } else if(selectedTipologia?.descrizione == "POLIZZA") {
      try{
        final response = await http.post(
          Uri.parse('$ipaddress/api/veicolo'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': selectedVeicolo?.id,
            'descrizione' : selectedVeicolo?.descrizione.toString().toUpperCase(),
            'targa' : selectedVeicolo?.targa.toString().toUpperCase(),
            'seriale' : selectedVeicolo?.seriale.toString().toUpperCase(),
            'imei' : selectedVeicolo?.imei.toString().toUpperCase(),
            'scadenza_gps' : selectedVeicolo?.scadenza_gps?.toIso8601String(),
            'proprietario' : selectedVeicolo?.proprietario.toString().toUpperCase(),
            'chilometraggio_attuale' : selectedVeicolo?.chilometraggio_attuale,
            'data_scadenza_bollo' : selectedVeicolo?.data_scadenza_bollo?.toIso8601String(),
            'data_scadenza_polizza' : dataScadenzaPolizza?.toIso8601String(),
            'data_tagliando' : selectedVeicolo?.data_tagliando?.toIso8601String(),
            'chilometraggio_ultimo_tagliando' : selectedVeicolo?.chilometraggio_ultimo_tagliando,
            'soglia_tagliando' : selectedVeicolo?.soglia_tagliando,
            'data_revisione' : selectedVeicolo?.data_revisione?.toIso8601String(),
            'data_inversione_gomme' : DateTime.now().toIso8601String(),
            'chilometraggio_ultima_inversione' : int.parse(_kmController.text.toString()),
            'soglia_inversione' : selectedVeicolo?.soglia_inversione,
            'data_sostituzione_gomme' : selectedVeicolo?.data_sostituzione_gomme?.toIso8601String(),
            'chilometraggio_ultima_sostituzione' : selectedVeicolo?.chilometraggio_ultima_sostituzione,
            'soglia_sostituzione' : selectedVeicolo?.soglia_sostituzione
          }),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Record relativi alla polizza gomme salvati correttamente!'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
        return response;
      } catch(e){
        print('Qualcosa non va con il salvataggio dei dati dell\'inversione: $e');
        return null;
      }
    } else if(selectedTipologia?.descrizione == "SOSTITUZIONE GOMME"){
      try{
        final response = await http.post(
          Uri.parse('$ipaddress/api/veicolo'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': selectedVeicolo?.id,
            'descrizione' : selectedVeicolo?.descrizione.toString().toUpperCase(),
            'targa' : selectedVeicolo?.targa.toString().toUpperCase(),
            'seriale' : selectedVeicolo?.seriale.toString().toUpperCase(),
            'imei' : selectedVeicolo?.imei.toString().toUpperCase(),
            'scadenza_gps' : selectedVeicolo?.scadenza_gps?.toIso8601String(),
            'proprietario' : selectedVeicolo?.proprietario.toString().toUpperCase(),
            'chilometraggio_attuale' : int.parse(_kmController.text.toString()),
            'data_scadenza_bollo' : selectedVeicolo?.data_scadenza_bollo?.toIso8601String(),
            'data_scadenza_polizza' : selectedVeicolo?.data_scadenza_polizza?.toIso8601String(),
            'data_tagliando' : selectedVeicolo?.data_tagliando?.toIso8601String(),
            'chilometraggio_ultimo_tagliando' : selectedVeicolo?.chilometraggio_ultimo_tagliando,
            'soglia_tagliando' : selectedVeicolo?.soglia_tagliando,
            'data_revisione' : selectedVeicolo?.data_revisione?.toIso8601String(),
            'data_inversione_gomme' : selectedVeicolo?.data_inversione_gomme?.toIso8601String(),
            'chilometraggio_ultima_inversione' : selectedVeicolo?.chilometraggio_ultima_inversione,
            'soglia_inversione' : selectedVeicolo?.soglia_inversione,
            'data_sostituzione_gomme' : DateTime.now().toIso8601String(),
            'chilometraggio_ultima_sostituzione' : int.parse(_kmController.text.toString()),
            'soglia_sostituzione' : selectedVeicolo?.soglia_sostituzione
          }),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Record relativi alla sostituzione delle gomme salvati correttamente!'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
        return response;
      } catch(e){
        print('Qualcosa non va con il salvataggio dei dati della sostituzione: $e');
        return null;
      }
    } else if (selectedTipologia?.descrizione == "BOLLO"){
      try{
        final response = await http.post(
          Uri.parse('$ipaddress/api/veicolo'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': selectedVeicolo?.id,
            'descrizione' : selectedVeicolo?.descrizione.toString().toUpperCase(),
            'targa' : selectedVeicolo?.targa.toString().toUpperCase(),
            'seriale' : selectedVeicolo?.seriale.toString().toUpperCase(),
            'imei' : selectedVeicolo?.imei.toString().toUpperCase(),
            'scadenza_gps' : selectedVeicolo?.scadenza_gps?.toIso8601String(),
            'proprietario' : selectedVeicolo?.proprietario.toString().toUpperCase(),
            'chilometraggio_attuale' : int.parse(_kmController.text.toString()),
            'data_scadenza_bollo' : dataScadenzaBollo?.toIso8601String(),
            'data_scadenza_polizza' : selectedVeicolo?.data_scadenza_polizza?.toIso8601String(),
            'data_tagliando' : selectedVeicolo?.data_tagliando?.toIso8601String(),
            'chilometraggio_ultimo_tagliando' : selectedVeicolo?.chilometraggio_ultimo_tagliando,
            'soglia_tagliando' : selectedVeicolo?.soglia_tagliando,
            'data_revisione' : selectedVeicolo?.data_revisione?.toIso8601String(),
            'data_inversione_gomme' : selectedVeicolo?.data_inversione_gomme?.toIso8601String(),
            'chilometraggio_ultima_inversione' : selectedVeicolo?.chilometraggio_ultima_inversione,
            'soglia_inversione' : selectedVeicolo?.soglia_inversione,
            'data_sostituzione_gomme' : selectedVeicolo?.data_sostituzione_gomme?.toIso8601String(),
            'chilometraggio_ultima_sostituzione' : selectedVeicolo?.chilometraggio_ultima_sostituzione,
            'soglia_sostituzione' : selectedVeicolo?.soglia_sostituzione
          }),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Record relativi al bollo del veicolo salvati correttamente!'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
        return response;
      } catch(e){
        print('Qualcosa non va con il salvataggio dei dati della revisione: $e');
        return null;
      }
    } else if (selectedTipologia?.descrizione == "REVISIONE"){
      try{
        final response = await http.post(
          Uri.parse('$ipaddress/api/veicolo'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': selectedVeicolo?.id,
            'descrizione' : selectedVeicolo?.descrizione.toString().toUpperCase(),
            'targa' : selectedVeicolo?.targa.toString().toUpperCase(),
            'seriale' : selectedVeicolo?.seriale.toString().toUpperCase(),
            'imei' : selectedVeicolo?.imei.toString().toUpperCase(),
            'scadenza_gps' : selectedVeicolo?.scadenza_gps?.toIso8601String(),
            'proprietario' : selectedVeicolo?.proprietario.toString().toUpperCase(),
            'chilometraggio_attuale' : int.parse(_kmController.text.toString()),
            'data_scadenza_bollo' : selectedVeicolo?.data_scadenza_bollo?.toIso8601String(),
            'data_scadenza_polizza' : selectedVeicolo?.data_scadenza_polizza?.toIso8601String(),
            'data_tagliando' : selectedVeicolo?.data_tagliando?.toIso8601String(),
            'chilometraggio_ultimo_tagliando' : selectedVeicolo?.chilometraggio_ultimo_tagliando,
            'soglia_tagliando' : selectedVeicolo?.soglia_tagliando,
            'data_revisione' : DateTime.now().toIso8601String(),
            'data_inversione_gomme' : selectedVeicolo?.data_inversione_gomme?.toIso8601String(),
            'chilometraggio_ultima_inversione' : selectedVeicolo?.chilometraggio_ultima_inversione,
            'soglia_inversione' : selectedVeicolo?.soglia_inversione,
            'data_sostituzione_gomme' : selectedVeicolo?.data_sostituzione_gomme?.toIso8601String(),
            'chilometraggio_ultima_sostituzione' : selectedVeicolo?.chilometraggio_ultima_sostituzione,
            'soglia_sostituzione' : selectedVeicolo?.soglia_sostituzione
          }),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Record relativi alla revisione del veicolo salvati correttamente!'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
        return response;
      } catch(e){
        print('Qualcosa non va con il salvataggio dei dati della revisione: $e');
        return null;
      }
    } else {
      try{
        final response = await http.post(
          Uri.parse('$ipaddress/api/veicolo'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': selectedVeicolo?.id,
            'descrizione' : selectedVeicolo?.descrizione.toString().toUpperCase(),
            'targa' : selectedVeicolo?.targa.toString().toUpperCase(),
            'seriale' : selectedVeicolo?.seriale.toString().toUpperCase(),
            'imei' : selectedVeicolo?.imei.toString().toUpperCase(),
            'scadenza_gps' : selectedVeicolo?.scadenza_gps?.toIso8601String(),
            'proprietario' : selectedVeicolo?.proprietario.toString().toUpperCase(),
            'chilometraggio_attuale' : int.parse(_kmController.text.toString()),
            'data_scadenza_bollo' : selectedVeicolo?.data_scadenza_bollo?.toIso8601String(),
            'data_scadenza_polizza' : selectedVeicolo?.data_scadenza_polizza?.toIso8601String(),
            'data_tagliando' : selectedVeicolo?.data_tagliando?.toIso8601String(),
            'chilometraggio_ultimo_tagliando' : selectedVeicolo?.chilometraggio_ultimo_tagliando,
            'soglia_tagliando' : selectedVeicolo?.soglia_tagliando,
            'data_revisione' : selectedVeicolo?.data_revisione?.toIso8601String(),
            'data_inversione_gomme' : selectedVeicolo?.data_inversione_gomme?.toIso8601String(),
            'chilometraggio_ultima_inversione' : selectedVeicolo?.chilometraggio_ultima_inversione,
            'soglia_inversione' : selectedVeicolo?.soglia_inversione,
            'data_sostituzione_gomme' : selectedVeicolo?.data_sostituzione_gomme?.toIso8601String(),
            'chilometraggio_ultima_sostituzione' : selectedVeicolo?.chilometraggio_ultima_sostituzione,
            'soglia_sostituzione' : selectedVeicolo?.soglia_sostituzione
          }),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Record del veicolo aggiornati correttamente!'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );
        return response;
      } catch(e){
        print('Qualcosa non va con il salvataggio dei dati della revisione: $e');
        return null;
      }
    }
  }

  Future<void> checkScadenze() async {
    print("Step 1 check");
    final data = await saveNewInfoVeicolo();
    try {
      print("Step 3 scadenze");
      if (data == null) {
        throw Exception('Dati del veicolo non disponibili.');
      } else {
        final veicolo = VeicoloModel.fromJson(jsonDecode(data.body));
        var differenza_sostituzione_gomme = int.parse(veicolo.chilometraggio_attuale.toString()) - int.parse(veicolo.chilometraggio_ultima_sostituzione.toString());
        var differenza_inversione_gomme = int.parse(veicolo.chilometraggio_attuale.toString()) - int.parse(veicolo.chilometraggio_ultima_inversione.toString());
        var differenza_tagliando = int.parse(veicolo.chilometraggio_attuale.toString()) - int.parse(veicolo.chilometraggio_ultimo_tagliando.toString());

        if (differenza_sostituzione_gomme >= (int.parse(veicolo.soglia_sostituzione.toString()) - 100)) {
          try {
            final response = await http.post(
              Uri.parse('$ipaddress/api/noteTecnico'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'utente': widget.utente.toMap(),
                'data': DateTime.now().toIso8601String(),
                'nota': "Il veicolo ${veicolo.descrizione} ha quasi raggiunto la soglia dei chilometri prima della prossima sostituzione gomme!".toString().toUpperCase(),
              }),
            );
            print("Nota sostituzione gomme creata!");
          } catch (e) {
            print("Errore nota sostituzione : $e");
          }
        }

        if (differenza_inversione_gomme >= (int.parse(veicolo.soglia_inversione.toString()) - 100)) {
          try {
            final response = await http.post(
              Uri.parse('$ipaddress/api/noteTecnico'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'utente': widget.utente.toMap(),
                'data': DateTime.now().toIso8601String(),
                'nota': "Il veicolo ${veicolo.descrizione} ha quasi raggiunto la soglia dei chilometri prima della prossima inversione gomme!".toString().toUpperCase(),
              }),
            );
            print("Nota inversione gomme creata!");
          } catch (e) {
            print("Errore nota inversione : $e");
          }
        }

        if (differenza_tagliando >= (int.parse(veicolo.soglia_tagliando.toString()) - 100)) {
          try {
            final response = await http.post(
              Uri.parse('$ipaddress/api/noteTecnico'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'utente': widget.utente.toMap(),
                'data': DateTime.now().toIso8601String(),
                'nota': "Il veicolo ${veicolo.descrizione} ha quasi raggiunto la soglia dei chilometri prima del prossimo tagliando!".toString().toUpperCase(),
              }),
            );
            print("Nota tagliando creata!");
          } catch (e) {
            print("Errore nota tagliando : $e");
          }
        }
      }
    } catch (e) {
      print('Erroreee: $e');
    }
  }

  Future<http.Response?> saveSpesa() async {
    late http.Response response;
    var notaF = _noteFornitoreController.text.isEmpty ? _noteFornitoreController.text : null;
    var notaS = _noteSpesaController.text.isEmpty ? _noteSpesaController.text : null;
    try {
      response = await http.post(
        Uri.parse('$ipaddress/api/spesaVeicolo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': DateTime.now().toIso8601String(),
          'km': _kmController.text,
          'importo': _importoController.text,
          'fornitore_carburante': selectedFornitore,
          'tipologia_spesa': selectedTipologia?.toMap(),
          'veicolo': selectedVeicolo?.toMap(),
          'utente': widget.utente.toMap(),
          'note_tipologia_spesa' : notaS.toString().toUpperCase(),
          'note_fornitore' : notaF.toString().toUpperCase(),
        }),
      );
      print(response.body.toString());
      return response;
    } catch (e) {
      print('Errore durante il salvataggio della spesa: $e');
    }
    return null;
  }

  Future<void> getAllSpese() async{
    try{
      var apiUrl = Uri.parse('$ipaddress/api/spesaVeicolo/ordered');
      var response = await http.get(apiUrl);
      if(response.statusCode == 200){
        var jsonData = jsonDecode(response.body);
        List<SpesaVeicoloModel> spese = [];
        for(var item in jsonData){
          spese.add(SpesaVeicoloModel.fromJson(item));
        }
        setState(() {
          allSpese = spese;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Le spese su veicolo sono state correttamente caricate')));
      } else {
        throw Exception('Failed to load utenti data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching agenti data from API: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Connection Error'),
            content: Text('Unable to load data from API. Please check your internet connection and try again.'),
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

  Future<void> getAllVeicoli() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/veicolo');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<VeicoloModel> veicoli = [];
        for (var item in jsonData) {
          veicoli.add(VeicoloModel.fromJson(item));
        }
        setState(() {
          allVeicoli = veicoli;
        });
      } else {
        throw Exception('Failed to load utenti data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching agenti data from API: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Connection Error'),
            content: Text('Unable to load data from API. Please check your internet connection and try again.'),
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


  // Utilizzo della funzione per comprimere l'immagine prima di caricarla
  Future<void> saveImmagine() async {
    final data = await saveSpesa();
    try {
      if(data == null){
        throw Exception('Dati della spesa non disponibili.');
      }
      final spesa = SpesaVeicoloModel.fromJson(jsonDecode(data.body));
      try{
        if (spesa.idSpesaVeicolo == null) {
          throw Exception('Id spesa veicolo is null');
        }
        if (spesa.idSpesaVeicolo.toString().isEmpty ||!spesa.idSpesaVeicolo.toString().trim().contains(RegExp(r'^[0-9]+$'))) {
          throw Exception('Id spesa veicolo is not a valid number');
        }
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$ipaddress/api/immagine/spesa/${int.parse(spesa.idSpesaVeicolo.toString())}'),
        );
        request.files.add(
          await http.MultipartFile.fromPath(
            'spesa', // Field name
            pickedImage!.path, // File path
            contentType: MediaType('image', 'jpeg'),
          ),
        );
        var response = await request.send();
        if (response.statusCode == 200) {
          print('File inviato con successo');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Spesa registrata!'),
            ),
          );
        } else {
          print('Errore durante l\'invio del file: ${response.statusCode}');
        }
        Navigator.pop(context);
      } catch (e) {
        print('Errore durante l\'invio del file: $e');
      }
    } catch (e) {
      print('Errore durante l\'invio del file: $e');
    }
  }



  Widget _buildTextFormField(TextEditingController controller, String label, String hintText, {List<TextInputFormatter>? inputFormatters}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.red),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
      inputFormatters: inputFormatters,
      keyboardType: TextInputType.number, // Imposta la tastiera per input numerici
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo obbligatorio';
        }
        return null;
      },
    );
  }


  Future<void> takePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        pickedImage = pickedFile;
      });
    }
  }

  Future<void> getTipologieSpesa() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/tipologiaSpesaVeicolo');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        List<TipologiaSpesaVeicoloModel> tipologie = [];
        for (var item in jsonData) {
          tipologie.add(TipologiaSpesaVeicoloModel.fromJson(item));
        }
        setState(() {
          allTipologie = tipologie;
        });
      } else {
        throw Exception('Failed to load utenti data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching agenti data from API: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Connection Error'),
            content: Text('Unable to load data from API. Please check your internet connection and try again.'),
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
}
