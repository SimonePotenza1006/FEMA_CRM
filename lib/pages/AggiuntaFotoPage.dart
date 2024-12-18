import 'package:file_picker/file_picker.dart';

import '../model/InterventoModel.dart';
import '../model/UtenteModel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:io' as io;
import 'package:path/path.dart' as basename;

class AggiuntaFotoPage extends StatefulWidget {
  final UtenteModel utente;
  final InterventoModel intervento;

  AggiuntaFotoPage({Key? key, required this.utente, required this.intervento}) : super(key: key);

  @override
  _AggiuntaFotoPageState createState() => _AggiuntaFotoPageState();
}

class _AggiuntaFotoPageState extends State<AggiuntaFotoPage> {
  List<XFile> pickedImages = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = '192.128.1.248:8090';
  String ipaddressProva2 = '192.168.1.198:8095';
  final ImagePicker _picker = ImagePicker();
  io.File? imageFile;

  Future<void> takePicture() async {
    final ImagePicker _picker = ImagePicker();
    // Verifica se sei su Android
    if (Platform.isAndroid) {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          pickedImages.add(pickedFile);
        });
      }
    }
    // Verifica se sei su Windows
    else if (Platform.isWindows) {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        setState(() {
          pickedImages.addAll(pickedFiles);
        });
      }
    }
  }

  Future<void> pickImagesFromGallery() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        pickedImages.addAll(pickedFiles);
      });
    }
  }

  Future<void> pickPdfsFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      /*androidExtra: {
        'android.intent.extra.ALLOW_MULTIPLE': 'false',
        'android.intent.extra.FILTER_TYPES': ['application/pdf'],
      },*/
    );
    if (result != null) {
      setState(() {

        imageFile = io.File(result.files.first.path!);
        print('mkjhplm '+imageFile.toString());
        //_scannedDocumentFile = null;
        //_scannedDocumentFile=imageFile;
      });
    }
    /*final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        pickedImages.addAll(pickedFiles);
      });
    }*/
  }

  Future<void> savePics() async {
    try {
      // Mostra il caricamento
      showDialog(
        context: context,
        barrierDismissible: false, // Impedisce la chiusura del dialog premendo fuori
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Caricamento in corso..."),
              ],
            ),
          );
        },
      );

      for (var image in pickedImages) {
        if (image.path != null && image.path.isNotEmpty) {
          var request = http.MultipartRequest(
            'POST',
            Uri.parse('$ipaddress/api/immagine/${int.parse(widget.intervento.id!.toString())}'),
          );
          request.files.add(
            await http.MultipartFile.fromPath(
              'intervento', // Field name
              image.path, // File path
              contentType: MediaType('image', 'jpeg'),
            ),
          );
          var response = await request.send();
          if (response.statusCode == 200) {
            print('File inviato con successo');
          } else {
            print('Errore durante l\'invio del file: ${response.statusCode}');
          }
        } else {
          print('Errore: Il percorso del file non è valido');
        }
      }
      pickedImages.clear();
      Navigator.pop(context); // Chiudi il dialog di caricamento

      // Mostra il messaggio di caricamento completato
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Successo"),
            content: Text("Caricamento completato!"),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pop(context); // Chiudi l'alert di successo
                  Navigator.pop(context); // Torna alla pagina precedente
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      Navigator.pop(context); // Chiudi il dialog di caricamento in caso di errore
      print('Errore durante l\'invio del file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.90;

    return Scaffold(
      appBar: AppBar(
        title: Text('AGGIUNTA FOTO INTERVENTO ID ${widget.intervento.id}',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: width,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: takePicture,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.red,
                    ),
                    child: Text('Scatta Foto', style: TextStyle(fontSize: 18.0)),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: pickImagesFromGallery,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.red,
                    ),
                    child: Text('Allega foto da galleria', style: TextStyle(fontSize: 18.0)),
                  ),
                  /*SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: pickPdfsFromGallery,
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                    ),
                    child: Text('Allega pdf da galleria', style: TextStyle(fontSize: 18.0)),
                  ),
                  _buildImagePreview(),
                  if (imageFile != null) Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(basename.basename(imageFile!.uri.path ))),*/
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: pickedImages.isNotEmpty ? savePics : null, // Attiva solo se ci sono immagini
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.red,
                    ),
                    child: Text('Salva Foto', style: TextStyle(fontSize: 18.0)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pickedImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Image.file(File(pickedImages[index].path)),
                IconButton(
                  icon: Icon(Icons.remove_circle),
                  onPressed: () {
                    setState(() {
                      pickedImages.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
