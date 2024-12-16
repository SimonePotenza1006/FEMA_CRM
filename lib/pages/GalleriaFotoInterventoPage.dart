import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fema_crm/model/InterventoModel.dart';
import 'package:photo_view/photo_view.dart';

class GalleriaFotoInterventoPage extends StatefulWidget {
  final InterventoModel intervento;

  GalleriaFotoInterventoPage({required this.intervento});

  @override
  _GalleriaFotoInterventoPageState createState() => _GalleriaFotoInterventoPageState();
}

class _GalleriaFotoInterventoPageState extends State<GalleriaFotoInterventoPage> {
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  Future<List<Uint8List>>? _futureImages;

  @override
  void initState() {
    super.initState();
    _futureImages = fetchImages();
  }

  Future<List<Uint8List>> fetchImages() async {
    final url = '$ipaddress/api/immagine/intervento/${int.parse(widget.intervento.id.toString())}/images';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Galleria foto intervento ID ${widget.intervento.id}',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // aggiungi padding all'intero body
        child: Center( // aggiungi Center per centrare il contenuto
          child: FutureBuilder<List<Uint8List>>(
            future: _futureImages,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Wrap(
                  spacing: 16, // aumenta la spaziatura orizzontale tra le foto
                  runSpacing: 16, // aumenta la spaziatura verticale tra le foto
                  children: snapshot.data!.map((imageData) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhotoViewPage(
                              images: snapshot.data!,
                              initialIndex: snapshot.data!.indexOf(imageData), // Passa l'indice corretto dell'immagine
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 250, // aumenta la larghezza del container
                        height: 270, // aumenta l'altezza del container
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
                return Text('Errore durante la chiamata al server');
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}

class PhotoViewPage extends StatefulWidget {
  final List<Uint8List> images;
  final int initialIndex;


  PhotoViewPage({required this.images, required this.initialIndex});

  @override
  _PhotoViewPageState createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex); // Imposta la pagina iniziale
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(''),
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController, // Associa il PageController
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: widget.images.map((imageData) {
              return PhotoView(
                imageProvider: MemoryImage(imageData),
                minScale: PhotoViewComputedScale.contained * 0.5,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            }).toList(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) {
                return Container(
                  width: 10,
                  height: 10,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index ? Colors.red : Colors.grey,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
