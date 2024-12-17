import 'dart:convert';
import 'dart:typed_data';

import 'package:fema_crm/model/MovimentiModel.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:io/ansi.dart';
import 'package:photo_view/photo_view.dart';

import 'GalleriaFotoInterventoPage.dart';

class DettaglioSpesaFornitorePage extends StatefulWidget{
  final MovimentiModel movimento;

  const DettaglioSpesaFornitorePage({Key? key, required this.movimento});

  @override
  _DettaglioSpesaFornitorePageState createState() => _DettaglioSpesaFornitorePageState();
}

class _DettaglioSpesaFornitorePageState extends State<DettaglioSpesaFornitorePage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  List<XFile> pickedImages =  [];
  Future<List<Uint8List>>? _futureImages;

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

  Future<List<Uint8List>> fetchImages() async{
    final url = '$ipaddress/api/immagine/movimenti/${int.parse(widget.movimento.id.toString())}/images';
    http.Response? response;
    try{
      response = await http.get(Uri.parse(url));
      if(response.statusCode == 200){
        final jsonData = jsonDecode(response.body);
        final images = jsonData.map<Uint8List>((imageData) {
          final base64String = imageData['imageData'];
          final bytes = base64Decode(base64String);
          return bytes.buffer.asUint8List();
        }).toList();
        return images;
      } else{
        throw Exception('Errore durante la chiamata al server: ${response.statusCode}');
      }
    } catch(e){
      print('Errore durante la chiamata al server: $e');
      if (response!= null) {

      }
      throw e;
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Dettaglio spesa fornitore', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.attach_file,
              color: Colors.white,
            ),
            onPressed: (){
              takePicture();
            },
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildInfoRow(title: "Data", value: widget.movimento.data != null ? DateFormat('dd/MM/yyyy').format(widget.movimento.data!) : "N/A"),
              buildInfoRow(title: "Fornitore", value: widget.movimento.fornitore != null ? widget.movimento.fornitore!.denominazione! : "//"),
              buildInfoRow(title: "Descrizione", value: widget.movimento.descrizione != null ? widget.movimento.descrizione! : "//"),
              buildInfoRow(title: "Importo", value: widget.movimento.importo != null ? "${widget.movimento.importo!.toStringAsFixed(2)}€" : "//"),
              SizedBox(height: 30),
              FutureBuilder<List<Uint8List>>(
                  future: _futureImages,
                  builder: (context, snapshot){
                    if(snapshot.hasData){
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: snapshot.data!.map((imageData){
                            return GestureDetector(
                              onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PhotoViewPage(
                                          images: snapshot.data!,
                                          initialIndex: snapshot.data!.indexOf(imageData)
                                        )
                                    )
                                );
                              },
                              child: Container(
                                width: 150,
                                height: 170,
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1),
                                ),
                                child: Image.memory(
                                  imageData,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    } else if(snapshot.hasError){
                      return Text('Nessuna foto presente nel database!');
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }
              ),
              SizedBox(height: 10),
              if(pickedImages.length > 0)
                Column(
                  children: [
                    SizedBox(height: 10),
                    Text('File scelti :', style:TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    SizedBox(height: 5),
                    _buildImagePreview(),
                    SizedBox(height: 10),
                    Container(
                      alignment: Alignment.center,
                      width: 300,
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      child: ElevatedButton(
                        onPressed: (){
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
                          savePics();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                            EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          ),
                        ),
                        child: Text(
                          'Allega immagini',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    )
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> savePics() async{
    try{
      for(var image in pickedImages){
        if(image.path.isNotEmpty){
          print('Percorso del file: ${image.path}');
          var request = http.MultipartRequest(
            'POST',
            Uri.parse('$ipaddress/api/immagine/movimento/${int.parse(widget.movimento.id!.toString())}'),
          );
          request.files.add(
            await http.MultipartFile.fromPath(
              'movimento',
              image.path,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
          var response = await request.send();
          if(response.statusCode == 200){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Foto Salvata!'),
              ),
            );
          } else {
            print('Errore durante l\'invio del file: ${response.statusCode}');
          }
          Navigator.pop(context);
          pickedImages.clear();
          fetchImages();
        } else {
          print('Errore: Il percorso del file non è valido');
        }
      }
    } catch(e){
      print('Errore durante l\'invio del file: $e');
    }
  }

}

Widget buildInfoRow({required String title, required String value, BuildContext? context}) {
  // Verifica se il valore supera i 25 caratteri
  bool isValueTooLong = value.length > 18;
  String displayedValue = isValueTooLong ? value.substring(0, 18) + "..." : value;
  return SizedBox(
    width:350,
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


