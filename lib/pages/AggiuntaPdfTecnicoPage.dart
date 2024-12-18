import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../model/InterventoModel.dart';
import 'package:http/http.dart' as http;

class AggiuntaPdfTecnicoPage extends StatefulWidget {
  final InterventoModel intervento;

  AggiuntaPdfTecnicoPage({Key? key, required this.intervento}) : super(key: key);

  @override
  _AggiuntaPdfTecnicoPageState createState() => _AggiuntaPdfTecnicoPageState();
}

class _AggiuntaPdfTecnicoPageState extends State<AggiuntaPdfTecnicoPage> {
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';
  List<File> selectedFiles = [];
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text(
          'Aggiunta PDF',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Tooltip(
            message: 'Allega PDF',
            preferBelow: true,
            child: IconButton(
              icon: Icon(Icons.attach_file, color: Colors.white, size: 30),
              onPressed: () {
                _pickFiles();
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (selectedFiles.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: selectedFiles.length,
                  itemBuilder: (context, index) {
                    final file = selectedFiles[index];
                    return Row(
                      children: [
                        // Nome del file
                        Flexible(
                          child: Text(
                            'File: ${file.path.split('/').last}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(width: 10),
                        // Bottone Elimina
                        IconButton(
                          onPressed: () {
                            setState(() {
                              selectedFiles.removeAt(index);
                            });
                          },
                          icon: Icon(Icons.delete, color: Colors.grey),
                          tooltip: "Elimina",
                        ),
                      ],
                    );
                  },
                ),
              ),
            SizedBox(height: 16), // Spaziatura
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: selectedFiles.isNotEmpty
                    ? () {
                  _uploadAllFiles();
                }
                    : null, // Disattivato se la lista è vuota
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  selectedFiles.isNotEmpty ? Colors.red : Colors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Allega documenti',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadAllFiles() async {
    try {
      for (var file in selectedFiles) {
        await uploadFile(file); // Funzione di upload esistente
      }
      // Mostra l'alert dialog alla fine del caricamento di tutti i file
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Successo!"),
            content: Text("Tutti i documenti sono stati caricati correttamente!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Chiudi il dialog
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Errore durante il caricamento dei file: $e");
    }
  }

  Future<void> uploadFile(File file) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$ipaddress/pdfu/intervento'),
      );
      request.fields['intervento'] = widget.intervento.id!;
      request.files.add(
        await http.MultipartFile.fromPath(
          'pdf', // Nome del parametro nel controller
          file.path,
        ),
      );
      var response = await request.send();
      if (response.statusCode == 200) {
        print("File caricato con successo: ${file.path}");
      } else {
        print("Errore durante il caricamento del file: ${response.statusCode}");
      }
    } catch (e) {
      print("Errore durante il caricamento del file: $e");
    }
  }


  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );
      if (result != null) {
        setState(() {
          selectedFiles = result.paths.map((path) => File(path!)).toList();
        });
        print("File selezionati: ${selectedFiles.map((f) => f.path).join(', ')}");
      } else {
        // L'utente ha annullato la selezione
        print("Nessun file selezionato.");
      }
    } catch (e) {
      print("Errore durante la selezione dei file: $e");
    }
  }
}
