import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:fema_crm/model/SopralluogoModel.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../model/ClienteModel.dart';
import '../model/TipologiaInterventoModel.dart';
import '../model/UtenteModel.dart';
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
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';
  Future<List<Uint8List>>? _futureImages;
  List<XFile> pickedImages =  [];
  List<TipologiaInterventoModel> tipologieList = [];
  List<ClienteModel> clientiList = [];
  List<ClienteModel> filteredClientiList = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> getAllTipologie() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/tipologiaIntervento');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<TipologiaInterventoModel> tipologie = [];

        // Converti i dati ricevuti in oggetti TipologiaInterventoModel
        for (var item in jsonData) {
          tipologie.add(TipologiaInterventoModel.fromJson(item));
        }

        // Filtro per escludere le tipologie con id 5, 6 o 7
        tipologie = tipologie.where((tipologia) {
          return !(tipologia.id == '5' || tipologia.id == '6' || tipologia.id == '7');
        }).toList();

        // Aggiorna lo stato con la lista filtrata
        setState(() {
          tipologieList = tipologie;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
    }
  }

  Future<void> getAllClienti() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/cliente');
      var response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<ClienteModel> clienti = [];
        for (var item in jsonData) {
          clienti.add(ClienteModel.fromJson(item));
        }
        setState(() {
          clientiList = clienti;
          filteredClientiList = clienti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata all\'API: $e');
    }
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
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
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
              buildInfoRow(title: 'data', value: widget.sopralluogo.data != null ? DateFormat('dd/MM/yyyy').format(widget.sopralluogo.data!) : 'N/A'),
              buildInfoRow(title: 'tipologia', value: widget.sopralluogo.tipologia != null ? widget.sopralluogo.tipologia!.descrizione! : "N/A"),
              buildInfoRow(title: 'cliente', value: widget.sopralluogo.cliente != null ? widget.sopralluogo.cliente!.denominazione! : 'N/A'),
              buildInfoRow(title: 'descrizione', value: widget.sopralluogo.descrizione != null ? widget.sopralluogo.descrizione! : "N/A"),
              SizedBox(height: 30),
              FutureBuilder<List<Uint8List>>(
                future: _futureImages,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Imposta lo scroll orizzontale
                      child: Row(
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
                              margin: EdgeInsets.symmetric(horizontal: 8.0), // Margine tra le immagini
                              decoration: BoxDecoration(
                                border: Border.all(width: 1), // Aggiungi un bordo al container
                              ),
                              child: Image.memory(
                                imageData,
                                fit: BoxFit.cover, // Copri l'intero spazio del container
                              ),
                            ),
                          );
                        }).toList(),
                      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton.extended(
                onPressed: () {
                  takePicture();
                },
                label: Text(
                  'SCATTA FOTO',
                  style: TextStyle(color: Colors.white),
                ),
                icon: Icon(Icons.camera_alt, color: Colors.white),
                backgroundColor: Colors.red,
              ),
              SizedBox(width: 5,),
              FloatingActionButton.extended(
                onPressed: () {
                  pickImagesFromGallery();
                },
                label: Text(
                  'ALLEGA FOTO',
                  style: TextStyle(color: Colors.white),
                ),
                icon: Icon(Icons.photo_album_outlined, color: Colors.white),
                backgroundColor: Colors.red,
              ),
            ],
          ),
          SizedBox(height: 10),
          if (pickedImages.isNotEmpty)
            FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 20),
                          Text('Attendere...'),
                        ],
                      ),
                    );
                  },
                );
                saveImageSopralluogo().whenComplete(() async{
                  Navigator.pop(context);
                });
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

  Future<void> pickImagesFromGallery() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        pickedImages.addAll(pickedFiles);
      });
    }
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
}

Widget buildInfoRow({required String title, required String value, BuildContext? context}) {
  // Verifica se il valore supera i 25 caratteri
  bool isValueTooLong = value.length > 25;
  String displayedValue = isValueTooLong ? value.substring(0, 25) + "..." : value;
  return SizedBox(
    width:280,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4, // Linea di accento colorata
                    height: 24,
                    color: Colors.redAccent, // Colore di accento per un tocco di vivacità
                  ),
                  SizedBox(width: 10),
                  Text(
                    title.toUpperCase() + ": ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // Colore contrastante per il testo
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      displayedValue.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold, // Un colore secondario per differenziare il valore
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isValueTooLong && context != null)
                      IconButton(
                        icon: Icon(Icons.info_outline),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("${title.toUpperCase()}"),
                                content: Text(value),
                                actions: [
                                  TextButton(
                                    child: Text("Chiudi"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Divider( // Linea di separazione tra i widget
            color: Colors.grey[400],
            thickness: 1,
          ),
        ],
      ),
    ),
  );
}


