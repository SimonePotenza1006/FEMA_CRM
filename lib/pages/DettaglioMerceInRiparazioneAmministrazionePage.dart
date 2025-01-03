import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
//import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:fema_crm/model/MerceInRiparazioneModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/InterventoModel.dart';
import 'DettaglioInterventoNewPage.dart';
import 'DettaglioInterventoNewPageAndroid.dart';
import 'GalleriaFotoInterventoPage.dart';

class DettaglioMerceInRiparazioneAmministrazionePage extends StatefulWidget{
  final MerceInRiparazioneModel merce;
  final VoidCallback? onNavigateBack;
  final UtenteModel utente;

  const DettaglioMerceInRiparazioneAmministrazionePage(
      {Key? key, required this.merce, this.onNavigateBack, required this.utente}
      ): super(key: key);

  @override
  _DettaglioMerceInRiparazioneAmministrazionePageState createState() => _DettaglioMerceInRiparazioneAmministrazionePageState();
}

class _DettaglioMerceInRiparazioneAmministrazionePageState extends State<DettaglioMerceInRiparazioneAmministrazionePage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';
  List<UtenteModel> allUtenti = [];
  InterventoModel? interventoAssociato;
  UtenteModel? selectedUtente;
  Future<List<Uint8List>>? _futureImages;
  final _formKeyConclusione = GlobalKey<FormState>();
  TextEditingController importoFinaleController = TextEditingController();
  TextEditingController importoPreventivatoController = TextEditingController();
  final TextEditingController  _risoluzioneController = TextEditingController();
  final TextEditingController  _prodottiController = TextEditingController();

  Future<http.Response?> getIntervento() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/intervento/merce/${int.parse(widget.merce.id.toString())}');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonData is List && jsonData.isNotEmpty) {
          var firstElement = jsonData[0];
          InterventoModel intervento = InterventoModel.fromJson(firstElement);
          setState(() {
            interventoAssociato = intervento;
          });
          return response;
        } else {
          print('Unexpected JSON format.');
          throw Exception('Unexpected JSON format: Not a List or Map.');
        }
      } else {
        print('Failed to load Intervento. Status code: ${response.statusCode}');
        throw Exception('Failed to load Intervento with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore recupero intervento: $e');
      return null;
    }
  }


  Future<List<Uint8List>> fetchImages() async {
    final data = await getIntervento();
    try {
      if (data == null) {
        throw Exception('Dati dell\'intervento non disponibili!');
      }
      var decodedData = jsonDecode(data.body);
      var interventoData = decodedData[0]; // Adjusted here
      InterventoModel intervento = InterventoModel.fromJson(interventoData); // Adjusted here
      final url = '$ipaddress/api/immagine/intervento/${intervento.id}/images';
      http.Response? response;
      try {
        response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
          if (jsonData is List) {
            final images = jsonData.map<Uint8List>((imageData) {

              final base64String = imageData['imageData'];
              final bytes = base64Decode(base64String);
              return bytes.buffer.asUint8List();
            }).toList();

            return images;
          } else {
            throw Exception('Formato di risposta non corretto: non è una lista.');
          }
        } else {
          throw Exception('Errore durante la chiamata al server: ${response.statusCode}');
        }
      } catch (e) {
        throw e;
      }
    } catch (e) {
      return [];
    }
  }




  @override
  void initState() {
    super.initState();
    _futureImages = fetchImages();
    importoPreventivatoController = TextEditingController(text: widget.merce.importo_preventivato.toString());
  }

  Widget buildInfoRow({required String title, required String value, BuildContext? context}) {
    bool isValueTooLong = value.length > 25;
    String displayedValue = isValueTooLong ? value.substring(0, 25) + "..." : value;
    return SizedBox(
      width: 500,
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

  Widget buildInterventoRow({
    required String title,
    required Widget valueWidget,
    BuildContext? context
  }) {
    return SizedBox(
      width: 500,
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
                      valueWidget, // Utilizzo del widget passato come parametro
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dettaglio Merce in Riparazione'.toUpperCase(),
          style: TextStyle(color: Colors.white, fontSize: 22.0), // Aumenta la dimensione del testo dell'intestazione
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Wrap(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Info merce in riparazione'.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                            SizedBox(height: 10.0),
                            buildInfoRow(title: 'ID MERCE', value: widget.merce.id!, context: context),
                            SizedBox(height: 10.0),
                            buildInterventoRow(title: "Intervento", valueWidget: GestureDetector(
                              onTap: () {
                                if (interventoAssociato != null) {
                                  if(Platform.isWindows){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DettaglioInterventoNewPage(intervento: interventoAssociato!, utente : widget.utente),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DettaglioInterventoNewPageAndroid(intervento: interventoAssociato!, utente : widget.utente),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 1.0), // Aggiunge spazio tra testo e underline
                                    child: Text(
                                      interventoAssociato != null ? interventoAssociato!.descrizione!.toUpperCase() : '///',
                                      style: TextStyle(
                                        color: interventoAssociato != null ? Colors.blue : Colors.black,
                                      ),
                                    ),
                                  ),
                                  if (interventoAssociato != null)
                                    Positioned(
                                      bottom: 0, // Posiziona la linea esattamente sotto il testo
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 1, // Altezza della linea di sottolineatura
                                        color: Colors.blue, // Colore della linea di sottolineatura
                                      ),
                                    ),
                                ],
                              ),
                            ), context : context),
                            SizedBox(height: 10,),
                            buildInfoRow(title: "articolo", value: widget.merce.articolo!, context: context),
                            SizedBox(height: 10.0),
                            buildInfoRow(title: "accessori", value: widget.merce.accessori ?? "N/A", context: context),
                            SizedBox(height: 10.0),
                            buildInfoRow(title: "difetto", value: widget.merce.difetto_riscontrato ?? "N/A", context: context),
                            SizedBox(height: 10.0),
                            buildInfoRow(title: 'Password', value: widget.merce.password ?? "N/A", context: context),
                            SizedBox(height: 10.0),
                            buildInfoRow(title: "dati", value: widget.merce.dati ?? "N/A", context: context),
                            SizedBox(height: 10.0),
                            buildInfoRow(title: "Richiesta preventivo", value: widget.merce.preventivo != null ? (widget.merce.preventivo != true ? "NO" : "SI"): "N/A", context: context),
                            if (widget.merce.preventivo != null && widget.merce.preventivo == true)
                              buildInfoRow(title: "prezzo preventivato", value: widget.merce.importo_preventivato != null ? widget.merce.importo_preventivato!.toStringAsFixed(2) : "Non Inserito", context: context),
                            SizedBox(
                                width: 500,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      child: TextFormField(
                                        controller: importoPreventivatoController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'Importo Preventivato'.toUpperCase(),
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        saveImportoPreventivo();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white, backgroundColor: Colors.red,
                                      ),
                                      child: Text('Salva importo Preventivo'.toUpperCase()),
                                    ),
                                  ],
                                )
                            ),
                            if(widget.merce.data_conclusione != null)
                              buildInfoRow(title: 'Risoluzione', value: widget.merce.risoluzione ?? "N?A", context: context),
                          ],
                        )
                    ),
                    SizedBox(width: 20),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildInfoRow(title: "data arrivo", value: widget.merce.data != null ? DateFormat('dd/MM/yyyy').format(widget.merce.data!) : "N/A"),
                          SizedBox(height: 10.0),
                          buildInfoRow(title: 'data conclusione', value: (widget.merce.data_conclusione != null ? DateFormat('dd/MM/yyyy').format(widget.merce.data_conclusione!) : 'N/A')),
                          SizedBox(height: 10),
                          buildInfoRow(title: 'data consegna', value: (widget.merce.data_consegna != null ? DateFormat('dd/MM/yyyy').format(widget.merce.data_consegna!) : "N/A")),
                          SizedBox(height: 10,),
                        ],
                      ),
                    ),
                    SizedBox(width: 10,),
                    Container(
                      child: SizedBox(
                        width: 400,
                        child: FutureBuilder<List<Uint8List>>(
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
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ],
        )
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
              bottom: 16,
              right: 16,
              child: SpeedDial(
                animatedIcon: AnimatedIcons.menu_close,
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                children: [
                  SpeedDialChild(
                    child: Icon(Icons.fact_check_outlined, color: Colors.white),
                    backgroundColor: Colors.red,
                    label: "Lavoro concluso".toUpperCase(),
                    onTap: () => _showConclusioneDialog(),
                  ),
                  if(widget.merce.data_conclusione != null)
                    SpeedDialChild(
                      child: Icon(Icons.directions_car_filled_outlined, color: Colors.white),
                      backgroundColor: Colors.red,
                      label: "Merce consegnata".toUpperCase(),
                      onTap: () => consegna(),
                    )
                ],
              )
          ),
        ],
      ),
    );
  }


  void _showConclusioneDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('COMPILA LA RISOLUZIONE E GLI EVENTUALI PRODOTTI INSTALLATI'),
          content: Form( // Avvolgi tutto dentro un Form
            key: _formKeyConclusione,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _risoluzioneController,
                  decoration: InputDecoration(
                    labelText: 'Risoluzione'.toUpperCase(),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) { // Aggiungi validatore
                    if (value == null || value.isEmpty) {
                      return 'Inserisci una descrizione valida';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _prodottiController,
                  decoration: InputDecoration(
                    labelText: 'prodotti installati'.toUpperCase(),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) { // Aggiungi validatore
                    if (value == null || value.isEmpty) {
                      return 'Scrivere // se non sono stati utilizzati prodotti';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_formKeyConclusione.currentState!.validate()) { // Convalida il form
                  conclusioneRiparazione();
                }
              },
              child: Text('Conferma'.toUpperCase()),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveImportoPreventivo() async {
    try {
      // Ottieni la data attuale come stringa ISO 8601
      String? dataConclusione = widget.merce.data_conclusione != null ? widget.merce.data_conclusione!.toIso8601String() : null;
      // Verifica se 'data_consegna' è null e converte in stringa ISO 8601 se necessario
      String? dataConsegna = widget.merce.data_consegna != null ? widget.merce.data_consegna!.toIso8601String() : null;
      double? importo = double.parse(importoPreventivatoController.text);
      final response = await http.post(
        Uri.parse('$ipaddress/api/merceInRiparazione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id,
          'data': widget.merce.data?.toIso8601String(), // Verifica se 'data' è null
          'articolo': widget.merce.articolo,
          'accessori': widget.merce.accessori,
          'difetto_riscontrato': widget.merce.difetto_riscontrato,
          'password': widget.merce.password,
          'dati': widget.merce.dati,
          'presenza_magazzino' : widget.merce.presenza_magazzino,
          'preventivo': widget.merce.preventivo,
          'importo_preventivato': importo,
          'preventivo_accettato' : widget.merce.preventivo_accettato,
          'diagnosi': widget.merce.diagnosi,
          'risoluzione': widget.merce.risoluzione,
          'data_conclusione': dataConclusione,
          'data_consegna': dataConsegna,
        }),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Importo preventivato salvato'),
        ),
      );
      setState(() {
        widget.merce.importo_preventivato = importo;
      });
    } catch (e) {
      print('Errore durante il salvataggio dell\'importo preventivato: $e');
    }
  }

  Future<void> conclusioneRiparazione() async {
    try {
      String? dataConsegna = widget.merce.data_consegna != null ? widget.merce.data_consegna!.toIso8601String() : null;
      final response = await http.post(
        Uri.parse('$ipaddress/api/merceInRiparazione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id,
          'data': widget.merce.data?.toIso8601String(), // Verifica se 'data' è null
          'articolo': widget.merce.articolo,
          'accessori': widget.merce.accessori,
          'difetto_riscontrato': widget.merce.difetto_riscontrato,
          'password': widget.merce.password,
          'dati': widget.merce.dati,
          'presenza_magazzino' : widget.merce.presenza_magazzino,
          'preventivo': widget.merce.preventivo,
          'importo_preventivato': widget.merce.importo_preventivato,
          'preventivo_accettato' : widget.merce.preventivo_accettato,
          'diagnosi': widget.merce.diagnosi,
          'risoluzione': _risoluzioneController.text,
          'data_conclusione': DateTime.now().toIso8601String(),
          'prodotti_installati':_prodottiController.text,
          'data_consegna': dataConsegna,
        }),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La riparazione è conclusa!'),
        ),
      );
      setState(() {
        widget.merce.data_conclusione= DateTime.now();
        widget.merce.risoluzione = _risoluzioneController.text;
      });
    } catch (e) {
      print('Errore durante il salvataggio dell\'importo preventivato: $e');
    }
  }

  Future<void> consegna() async {
    try {
      String? dataConclusione = widget.merce.data_conclusione != null ? widget.merce.data_conclusione!.toIso8601String() : null;
      final response = await http.post(
        Uri.parse('$ipaddress/api/merceInRiparazione'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id,
          'data': widget.merce.data?.toIso8601String(), // Verifica se 'data' è null
          'articolo': widget.merce.articolo,
          'accessori': widget.merce.accessori,
          'difetto_riscontrato': widget.merce.difetto_riscontrato,
          'password': widget.merce.password,
          'dati': widget.merce.dati,
          'presenza_magazzino' : widget.merce.presenza_magazzino,
          'preventivo': widget.merce.preventivo,
          'importo_preventivato': widget.merce.importo_preventivato,
          'preventivo_accettato' : widget.merce.preventivo_accettato,
          'diagnosi': widget.merce.diagnosi,
          'risoluzione': widget.merce.risoluzione,
          'data_conclusione': dataConclusione,
          'data_consegna': DateTime.now().toIso8601String(),
        }),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La merce è stata consegnata!'),
        ),
      );
      setState(() {
        widget.merce.data_consegna= DateTime.now();
      });
    } catch (e) {
      print('Errore durante il salvataggio dell\'importo preventivato: $e');
    }
  }

}