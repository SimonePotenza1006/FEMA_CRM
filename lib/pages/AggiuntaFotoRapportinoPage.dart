import '../model/InterventoModel.dart';
import '../model/UtenteModel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'MenuSceltaSaldoPage.dart';

class AggiuntaFotoRapportinoPage extends StatefulWidget {
  final UtenteModel utente;
  final InterventoModel intervento;

  AggiuntaFotoRapportinoPage({Key? key, required this.utente, required this.intervento}) : super(key: key);

  @override
  _AggiuntaFotoRapportinoPageState createState() => _AggiuntaFotoRapportinoPageState();
}

class _AggiuntaFotoRapportinoPageState extends State<AggiuntaFotoRapportinoPage> {
  List<XFile> pickedImages = [];
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';

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

  Future<void> savePics() async {
    try {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MenuSceltaSaldoPage(utente: widget.utente, intervento: widget.intervento)),
                  );
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
       // Chiudi il dialog di caricamento in caso di errore
      print('Errore durante l\'invio del file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.90;

    return Scaffold(
      appBar: AppBar(
        title: Text('AGGIUNTA FOTO RAPPORTINO',
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
                      primary: Colors.red,
                      onPrimary: Colors.white,
                    ),
                    child: Text('SCATTA FOTO', style: TextStyle(fontSize: 18.0)),
                  ),
                  _buildImagePreview(),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: pickedImages.isNotEmpty ? savePics : null, // Attiva solo se ci sono immagini
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                    ),
                    child: Text('SALVA', style: TextStyle(fontSize: 18.0)),
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
