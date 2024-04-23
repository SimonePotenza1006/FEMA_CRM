import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:fema_crm/model/SopralluogoModel.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class DettaglioSopralluogoPage extends StatefulWidget {
  final SopralluogoModel sopralluogo;

  const DettaglioSopralluogoPage({Key? key, required this.sopralluogo})
      : super(key: key);

  @override
  _DettaglioSopralluogoPageState createState() =>
      _DettaglioSopralluogoPageState();
}

class _DettaglioSopralluogoPageState extends State<DettaglioSopralluogoPage> {
  XFile? pickedImage;
  String ipaddress = 'http://gestione.femasistemi.it:8090';

  @override
  Widget build(BuildContext context) {
    String formattedDate =
    DateFormat('yyyy/MM/dd').format(widget.sopralluogo.data!);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dettaglio sopralluogo',
            style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Data del sopralluogo: $formattedDate',
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              Text(
                'Tipologia: ${widget.sopralluogo.tipologia?.descrizione}',
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              Text(
                'Cliente: ${widget.sopralluogo.cliente?.denominazione}',
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              Text(
                'Descrizione: ${widget.sopralluogo.descrizione}',
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              pickedImage != null
                  ? GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: Image.file(
                          File(pickedImage!.path),
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: FileImage(File(pickedImage!.path)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
                  : Container(),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              takePicture();
            },
            label: Text(
              'Allega foto',
              style: TextStyle(color: Colors.white),
            ),
            icon: Icon(Icons.camera_alt, color: Colors.white),
            backgroundColor: Colors.red,
          ),
          SizedBox(height: 10),
          if (pickedImage != null)
            FloatingActionButton.extended(
              onPressed: () {
                saveImageSopralluogo(File(pickedImage!.path));
              },
              label: Text(
                'Salva foto',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> saveImageSopralluogo(File imageFile) async {
    try {
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              '$ipaddress/api/immagine/sopralluogo/${widget.sopralluogo.id}'));
      request.files.add(
        await http.MultipartFile.fromPath(
          'sopralluogo',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Immagine salvata con successo');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto salvata con successo!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print(
            'Errore durante il salvataggio dell\'immagine: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata HTTP: $e');
    }
  }

  Future<void> takePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        pickedImage = pickedFile;
      });
    }
  }
}
