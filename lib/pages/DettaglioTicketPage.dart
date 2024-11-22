import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';

import '../model/TicketModel.dart';
import 'dart:convert';
import 'package:fema_crm/pages/HomeFormAmministrazioneNewPage.dart';
import 'package:fema_crm/pages/TableCommissioniPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fema_crm/model/CommissioneModel.dart';

import 'GalleriaFotoInterventoPage.dart';

class DettaglioTicketPage extends StatefulWidget{
  final TicketModel ticket;

  DettaglioTicketPage({Key? key, required this.ticket}) : super(key : key);

  @override
  _DettaglioTicketPageState createState() => _DettaglioTicketPageState();
}

class _DettaglioTicketPageState extends State<DettaglioTicketPage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090';
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  Future<List<Uint8List>>? _futureImages;

  @override
  void initState(){
    super.initState();
    _futureImages = fetchImages();
  }

  Future<List<Uint8List>> fetchImages() async {
    final url = '$ipaddressProva/api/immagine/ticket/${int.parse(widget.ticket.id.toString())}/images';
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

      }
      throw e; // rethrow the exception
    }
  }

  Future<void> savePics(List<Uint8List> images, int interventoId) async {
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

      for (var imageBytes in images) {
        // Converte Uint8List in MultipartFile
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$ipaddressProva/api/immagine/$interventoId'),
        );

        request.files.add(http.MultipartFile.fromBytes(
          'intervento', // Nome del campo nel form
          imageBytes,
          filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));

        var response = await request.send();

        if (response.statusCode == 200) {
          print('File inviato con successo');
        } else {
          print('Errore durante l\'invio del file: ${response.statusCode}');
        }
      }

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
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dettaglio ticket',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildInfoRow(title: "Id", value: widget.ticket.id!),
                buildInfoRow(title: "Priorità", value: widget.ticket.priorita.toString().split('.').last),
                buildInfoRow(title: "Tipologia", value: widget.ticket.tipologia?.descrizione ?? "N/A"),
                buildInfoRow(title: "Utente", value: widget.ticket.utente?.nomeCompleto() ?? "N/A"),
                buildInfoRow(title: "Data creazione", value: DateFormat('dd/MM/yyyy HH:mm').format(widget.ticket.data_creazione!)),
                buildInfoRow(title: "Data appuntamento", value: (widget.ticket.data != null ? DateFormat('dd/MM/yyyy').format(widget.ticket.data!) : "N/A")),
                buildInfoRow(title: "Orario appuntamento", value: widget.ticket.orario_appuntamento != null ? DateFormat('HH:mm').format(widget.ticket.orario_appuntamento!) : "N/A"),
                buildInfoRow(title: "Titolo", value: widget.ticket.titolo ?? "N/A"),
                buildInfoRow(title: "Descrizione", value: widget.ticket.descrizione ?? "N/A"),
                buildInfoRow(title: "Note", value: widget.ticket.note ?? "N/A"),
                buildInfoRow(title: "Cliente", value: widget.ticket.cliente?.denominazione ?? "N/A"),
                buildInfoRow(title: "Indirizzo Destinazione", value: widget.ticket.destinazione?.indirizzo ?? "N/A"),
                SizedBox(
                  width: 150, // Larghezza desiderata
                  height: 50, // Altezza desiderata
                  child: FloatingActionButton(
                    onPressed: () {
                      converti(widget.ticket);
                    },
                    backgroundColor: Colors.red, // Colore di sfondo rosso
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Bordi leggermente arrotondati
                    ),
                    child: Text(
                      'Converti',
                      style: TextStyle(
                        color: Colors.white, // Colore della scritta bianco
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 100),
            Container(
              width: 1000,
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
          ],
        )
      ),
    );
  }

  Future<void> converti(TicketModel ticket) async {
    try {
      // Passaggio 1: Converti il ticket in intervento
      final response = await http.post(
        Uri.parse('$ipaddressProva/api/intervento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'attivo': true,
          'visualizzato': false,
          'titolo': ticket.titolo,
          'priorita': ticket.priorita.toString().split('.').last,
          'data': ticket.data?.toIso8601String() ?? null,
          'data_apertura_intervento': DateTime.now().toIso8601String(),
          'orario_appuntamento': ticket.orario_appuntamento?.toIso8601String() ?? null,
          'descrizione': ticket.descrizione,
          'note': ticket.note ?? null,
          'utente_apertura': ticket.utente?.toMap() ?? null,
          'cliente': ticket.cliente?.toMap() ?? null,
          'tipologia': ticket.tipologia?.toMap() ?? null,
          'destinazione': ticket.destinazione?.toMap() ?? null,
        }),
      );

      if (response.statusCode == 201) {
        print('Ticket convertito in intervento con successo');
        final interventoId = jsonDecode(response.body)['id'];

        // Passaggio 2: Scarica le immagini in Uint8List
        final images = await fetchImages();

        // Passaggio 3: Carica le immagini nell'intervento
        await savePics(images, interventoId);
      } else {
        throw Exception('Errore durante la creazione dell\'intervento: ${response.statusCode}');
      }
      // Passaggio 4: Aggiorna lo stato del ticket
      final response2 = await http.post(
        Uri.parse('$ipaddressProva/api/ticket'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': ticket.id,
          'data_creazione': ticket.data_creazione?.toIso8601String(),
          'data': ticket.data?.toIso8601String(),
          'orario_appuntamento': ticket.orario_appuntamento?.toIso8601String(),
          'titolo': ticket.titolo,
          'priorita': ticket.priorita.toString().split('.').last,
          'descrizione': ticket.descrizione,
          'note': ticket.note,
          'convertito': true,
          'cliente': ticket.cliente?.toMap(),
          'destinazione': ticket.destinazione?.toMap(),
          'tipologia': ticket.tipologia?.toMap(),
          'utente': ticket.utente?.toMap(),
        }),
      );
      if (response2.statusCode == 201) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ticket convertito correttamente!')),
        );
      }
    } catch (e) {
      print('Qualcosa non va $e');
    }
  }




  Widget buildInfoRow({required String title, required String value, BuildContext? context}) {
    bool isValueTooLong = value.length > 25;
    String displayedValue = isValueTooLong ? value.substring(0, 25) + "..." : value;

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
                      width: 4,
                      height: 24,
                      color: Colors.redAccent,
                    ),
                    SizedBox(width: 10),
                    Text(
                      title.toUpperCase() + ": ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
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
                          fontWeight: FontWeight.bold,
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
            Divider(
              color: Colors.grey[400],
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }
}