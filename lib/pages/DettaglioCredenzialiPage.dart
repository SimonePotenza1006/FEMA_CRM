import 'dart:convert';
import 'dart:typed_data';

import 'package:fema_crm/model/CredenzialiClienteModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'GalleriaFotoInterventoPage.dart';

class DettaglioCredenzialiPage extends StatefulWidget {
  final CredenzialiClienteModel credenziale;

  const DettaglioCredenzialiPage({Key? key, required this.credenziale}) : super(key: key);

  @override
  _DettaglioCredenzialiPageState createState() => _DettaglioCredenzialiPageState();
}

class _DettaglioCredenzialiPageState extends State<DettaglioCredenzialiPage>{
  Future<List<Uint8List>>? _futureImages;
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
  String ipaddressProva2 = 'http://192.168.1.198:8095';

  @override
  void initState() {
    super.initState();
    _futureImages = fetchImages();
  }

  Future<List<Uint8List>> fetchImages() async {
    final url = '$ipaddress2/api/immagine/credenziali/${int.parse(widget.credenziale.id.toString())}/images';
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
        title: Text('Dettaglio credenziali',
        style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 500),
                  padding: EdgeInsets.all(25.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      buildInfoRow(title: "Cliente", value: widget.credenziale.cliente!.denominazione!, context: context),
                      SizedBox(height: 15),
                      buildInfoRow(title: "Utente incaricato", value: widget.credenziale.utente!.nomeCompleto()!, context: context),
                      SizedBox(height: 15),
                      buildInfoRow(title: "Descrizione", value: widget.credenziale.descrizione!, context: context),
                      SizedBox(height: 15),
                      buildInfoRow(title: "Credenziali", value: widget.credenziale.credenziali!, context: context),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                          width: 150,
                          child: FutureBuilder<List<Uint8List>>(
                            future: _futureImages,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: snapshot.data!.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    Uint8List imageData = entry.value;
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PhotoViewPage(
                                              images: snapshot.data!,
                                              initialIndex: index, // Passa l'indice dell'immagine cliccata
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
                        ),
                        ]
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        )
      ),
    );
  }

  Widget buildInfoRow({required String title, required String value, BuildContext? context}) {
    bool isValueTooLong = value.length > 15;
    String displayedValue = isValueTooLong ? value.substring(0, 10) + "..." : value;
    return SizedBox(
      width: 450,
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
                          fontSize: 15,
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

}