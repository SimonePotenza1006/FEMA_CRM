import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:fema_crm/model/SopralluogoModel.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'GalleriaFotoInterventoPage.dart';

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
  Future<List<Uint8List>>? _futureImages;
  List<XFile> pickedImages =  [];



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

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  void _fetchImages() {
    setState(() {
      _futureImages = fetchImages();
    });
  }

  Future<List<Uint8List>> fetchImages() async {
    final url = '$ipaddress/api/immagine/sopralluogo/${int.parse(widget.sopralluogo.id.toString())}/images';
    http.Response? response;
    try {
      response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final images = jsonData.map<Uint8List>((imageData) {
          final base64String = imageData['imageData'];
          final bytes = base64Decode(base64String);
          return bytes.buffer.asUint8List();
        }).toList();
        return images; // no need to wrap with Future
      } else {
        throw Exception('Errore durante la chiamata al server: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata al server: $e');
      if (response!= null) {
        //print('Risposta del server: ${response.body}');
      }
      throw e; // rethrow the exception
    }
  }


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
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: (){
              _fetchImages();
            },
          ),
        ],
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
                'Posizione GPS: ${widget.sopralluogo.posizione}',
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              Text(
                'Descrizione: ${widget.sopralluogo.descrizione}',
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              FutureBuilder<List<Uint8List>>(
                future: _futureImages,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: snapshot.data!.map((imageData) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhotoViewPage(
                                  images: snapshot.data!,
                                  initialIndex: snapshot.data!.indexOf(imageData),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 150, // aumenta la larghezza del container
                            height: 170, // aumenta l'altezza del container
                            decoration: BoxDecoration(
                              border: Border.all(width: 1), // aggiungi bordo al container
                            ),
                            child: Image.memory(
                              imageData,
                              fit: BoxFit.cover, // aggiungi fit per coprire l'intero spazio
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Nessuna foto presente nel database!');
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
              SizedBox(height: 20),
              _buildImagePreview(),
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
          if (pickedImages.isNotEmpty)
            FloatingActionButton.extended(
              onPressed: () {
                saveImageSopralluogo();
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

  Future<void> saveImageSopralluogo() async {
    final sopralluogo = widget.sopralluogo.id;
    try {
      for (var image in pickedImages)  {
        if (image.path != null && image.path.isNotEmpty) {
          print('Percorso del file: ${image.path}');
          var request = http.MultipartRequest(
            'POST',
            Uri.parse('$ipaddress/api/immagine/sopralluogo/${sopralluogo}'),
          );
          request.files.add(
            await http.MultipartFile.fromPath(
              'sopralluogo', // Field name
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
          // Gestisci il caso in cui il percorso del file non è valido
          print('Errore: Il percorso del file non è valido');
        }
      }
    } catch (e) {
      print('Errore durante la chiamata HTTP: $e');
    }
    setState(() {
      pickedImages.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Immagini caricate correttamente!'),
      ),
    );
    _fetchImages();
  }

  Future<void> takePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        pickedImages.add(pickedFile);
      });
    }
  }
}
