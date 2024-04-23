import 'dart:io';
import 'dart:typed_data';
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
  VeicoloModel? selectedVeicolo;
  TipologiaSpesaVeicoloModel? selectedTipologia;
  String? selectedFornitore;
  XFile? pickedImage;
  DateTime data = DateTime.now();

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
        title: Text('Spesa su veicolo', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(
                  'Compila tutti i campi per salvare la spesa',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 60),
                DropdownButton<VeicoloModel>(
                  value: selectedVeicolo,
                  onChanged: (VeicoloModel? newValue) {
                    setState(() {
                      selectedVeicolo = newValue;
                    });
                  },
                  items: allVeicoli.map((VeicoloModel veicolo) {
                    return DropdownMenuItem<VeicoloModel>(
                      value: veicolo,
                      child: Text(veicolo.descrizione!), // Sostituisci 'nome' con il campo appropriato del tuo modello VeicoloModel
                    );
                  }).toList(),
                  hint: Text('Veicolo'),
                ),
                SizedBox(height: 20),
                DropdownButton<TipologiaSpesaVeicoloModel>(
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
                  hint: Text('Tipologia di spesa'),
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: DropdownButton<String>(
                    value: selectedFornitore,
                    onChanged: (newValue) {
                      setState(() {
                        selectedFornitore = newValue;
                      });
                    },
                    items: [
                      'IP Via Europa',
                      'Altro',
                    ].map((categoria) {
                      return DropdownMenuItem<String>(
                        value: categoria,
                        child: Text(categoria),
                      );
                    }).toList(),
                    hint: Text('Fornitore'),
                  ),
                ),
                SizedBox(height: 20),
                _buildTextFormField(
                  _importoController,
                  "Importo",
                  "Inserisci l'importo della spesa",
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),

                SizedBox(height: 20),
                _buildTextFormField(
                  _kmController,
                  "Chilometri",
                  "Inserisci il chilometraggio",
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                SizedBox(height: 20),
                Text(
                  'Scatta una foto:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Center(
                  child:
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: () {
                          takePicture();
                        },
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
                ElevatedButton(
                  onPressed: () {
                    if (pickedImage != null) {
                      saveSpesa();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    onPrimary: Colors.white,
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: Text('Salva spesa'),
                ),
              ],
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

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Scaricare excel report delle spese su veicolo?'),
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

  Future<void> saveSpesa() async {
    try {
      if (pickedImage != null) {
        final response = await http.post(
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
          }),

        );
        print(response.body.toString());
        if (response.statusCode == 201) {
          if (pickedImage != null) {
            // Converti XFile in File
            final file = File(pickedImage!.path);
            // Chiamata al metodo per il caricamento dell'immagine
            saveImageSpesaVeicolo(file);
          }
        }
      }
    } catch (e) {
      print('Errore durante il salvataggio della spesa: $e');
    }
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
  Future<void> saveImageSpesaVeicolo(File imageFile) async {
    try {
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              '$ipaddress/api/immagine/veicolo/${int.parse(selectedVeicolo!.id.toString())}'));
      // Aggiungi il file come parte della richiesta chiamata "spesa"
      request.files.add(
          await http.MultipartFile.fromPath(
              'veicolo',
              imageFile.path,
              contentType: MediaType('image', 'jpeg')
          ));
      print('${int.parse(selectedVeicolo!.id.toString())}');
      print('Percorso del file: ${imageFile.path}');
      var response = await request.send();
      if (response.statusCode == 200) {
        print('File inviato con successo');
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Spesa su veicolo salvata!!'),
            duration: Duration(seconds: 3), // Durata dello Snackbar
          ),
        );

      } else {
        print('Errore durante l\'invio del file: ${response.statusCode}');
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
