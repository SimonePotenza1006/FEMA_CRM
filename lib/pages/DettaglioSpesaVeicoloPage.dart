import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../model/SpesaVeicoloModel.dart';

class DettaglioSpesaVeicoloPage extends StatefulWidget{
  final SpesaVeicoloModel spesa;

  const DettaglioSpesaVeicoloPage({Key? key, required this.spesa}) : super(key : key);

  @override
  _DettaglioSpesaSivisPageState createState() => _DettaglioSpesaSivisPageState();
}

class _DettaglioSpesaSivisPageState extends State<DettaglioSpesaVeicoloPage> {
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';
  List<Uint8List>? _images;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final images = await loadImages();
    setState(() {
      _images = images;
    });
  }

  Future<List<Uint8List>> loadImages() async {
    try {
      final response = await http.get(Uri.parse('$ipaddress/api/immagine/spesa/${widget.spesa.idSpesaVeicolo}/images'));
      if (response.statusCode == 200) {
        // Decodifica la lista di immagini JSON
        List<dynamic> imagesJson = jsonDecode(response.body);
        return imagesJson.map((imageData) => base64Decode(imageData['imageData'])).toList();
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      print('Error loading images: $e');
      return [];
    }
  }


  Future<Uint8List> getImageSpesa(String idspesa) async {
    try {
      final response = await http.get(Uri.parse('$ipaddress/api/immagine/spesa/${int.parse(widget.spesa.idSpesaVeicolo.toString())}'));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      print('Error loading image: $e');
      return Uint8List(0); // Return an empty Uint8List on error
    }
  }

  Future<Uint8List> _loadPlaceholderImage() async {
    final byteData = await rootBundle.load('assets/images/placeholder.jpg');
    return byteData.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dettaglio Spesa ${widget.spesa.idSpesaVeicolo}',
            style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildImageGallery(),
            const SizedBox(height: 20),
            _buildDetailsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    if (_images == null) {
      return Center(child: CircularProgressIndicator());
    } else if (_images!.isEmpty) {
      return Center(
        child: Text("Nessuna immagine per la spesa selezionata", style: TextStyle(fontWeight: FontWeight.bold),)
      );
    } else {
      return Container(
        height: 500,
        child: PageView.builder(
          itemCount: _images!.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Image.memory(_images![index]),
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 5,
                child: Image.memory(_images![index], fit: BoxFit.cover),
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildDetailsSection() {
    return Card(
      color: Colors.grey[100],
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Veicolo:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.spesa.veicolo?.descrizione}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Tipologia spesa:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.spesa.tipologia_spesa?.descrizione}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Fornitore:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.spesa.fornitore_carburante}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Importo:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.spesa.importo} €',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Utente:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.spesa.utente?.nome}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Contachilometri:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.spesa.km} km',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}