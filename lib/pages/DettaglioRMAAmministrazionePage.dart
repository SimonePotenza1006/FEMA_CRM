import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:fema_crm/model/RestituzioneMerceModel.dart';
//import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'package:fema_crm/model/MerceInRiparazioneModel.dart';
import 'package:fema_crm/model/UtenteModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/InterventoModel.dart';
import 'GalleriaFotoInterventoPage.dart';

class DettaglioRMAAmministrazionePage extends StatefulWidget{
  final RestituzioneMerceModel merce;
  final VoidCallback? onNavigateBack;

  const DettaglioRMAAmministrazionePage(
      {Key? key, required this.merce, this.onNavigateBack}
      ): super(key: key);

  @override
  _DettaglioRMAAmministrazionePageState createState() => _DettaglioRMAAmministrazionePageState();
}

class _DettaglioRMAAmministrazionePageState extends State<DettaglioRMAAmministrazionePage>{
  String ipaddress = 'http://gestione.femasistemi.it:8090'; 
  String ipaddressProva = 'http://gestione.femasistemi.it:8095';
  String ipaddress2 = 'http://192.168.1.248:8090';
      String ipaddressProva2 = 'http://192.168.1.198:8095';
  List<UtenteModel> allUtenti = [];
  InterventoModel? interventoAssociato;
  DateTime _dataOdierna = DateTime.now();
  UtenteModel? selectedUtenteRicon;
  UtenteModel? selectedUtenteRitiro;
  Future<List<Uint8List>>? _futureImages;
  final _formKeyConclusione = GlobalKey<FormState>();
  TextEditingController importoFinaleController = TextEditingController();
  TextEditingController importoPreventivatoController = TextEditingController();
  final TextEditingController  _risoluzioneController = TextEditingController();
  final TextEditingController  _prodottiController = TextEditingController();
  final TextEditingController difettoController = TextEditingController();
  bool modificaDifettoVisible = false;
  DateTime? selectedDateRicon = null;
  DateTime? selectedDateRientro = null;
  bool _rimborso = false;
  bool _cambio = false;
  bool _concluso = false;

  /*Future<http.Response?> getIntervento() async {
    try {
      var apiUrl = Uri.parse('$ipaddress/api/restituzioneMerce/${int.parse(widget.merce.id.toString())}');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
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
  }*/


  Future<List<Uint8List>> fetchImages() async {
    //final data = await getIntervento();
    try {
      /*if (data == null) {
        throw Exception('Dati dell\'intervento non disponibili!');
      }
      var decodedData = jsonDecode(data.body);
      var interventoData = decodedData[0]; // Adjusted here
      InterventoModel intervento = InterventoModel.fromJson(interventoData);*/ // Adjusted here
      final url = '$ipaddress/api/immagine/restituzioneMerce/${widget.merce.id.toString()}/images';
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
    getAllUtentiAttivi();
    difettoController.text = widget.merce.difetto_riscontrato!;
    selectedDateRicon = widget.merce.data_riconsegna;
    selectedDateRientro = widget.merce.data_rientro_ufficio;
    selectedUtenteRicon = widget.merce.utenteRiconsegna;
    selectedUtenteRitiro = widget.merce.utenteRitiro;
    _futureImages = fetchImages();
    importoPreventivatoController = TextEditingController(text: '');//widget.merce.importo_preventivato.toString());
  }

  Future<void> getAllUtentiAttivi() async {
    try {
      final response = await http.get(Uri.parse('$ipaddress/api/utente/attivo'));

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        List<UtenteModel> utenti = [];
        for (var item in jsonData) {
          if (UtenteModel.fromJson(item).nome != 'Segreteria')
          utenti.add(UtenteModel.fromJson(item));
        }
        setState(() {
          allUtenti = utenti;
        });
      } else {
        throw Exception('Failed to load data from API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore durante la chiamata Api: $e');
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    if(mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Errore di connessione'),
            content: const Text(
              'Impossibile caricare i dati dall\'API. Controlla la tua connessione internet e riprova.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget buildInfoRow({required String title, required String value, BuildContext? context}) {
    bool isValueTooLong = value.length > 20;
    String displayedValue = isValueTooLong ? value.substring(0, 20) + "..." : value;
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

  Widget buildRimborsoRow({required String title, required bool value, BuildContext? context}) {
    //bool isValueTooLong = value.length > 20;
    //String displayedValue = isValueTooLong ? value.substring(0, 20) + "..." : value;
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
                      Switch(
                        value: _rimborso,
                        onChanged: (value) {
                          setState(() {
                            _rimborso = value ?? false;
                          });
                          modificaRimborso();
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

  Widget buildCambioRow({required String title, required bool value, BuildContext? context}) {
    //bool isValueTooLong = value.length > 20;
    //String displayedValue = isValueTooLong ? value.substring(0, 20) + "..." : value;
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
                      Switch(
                        value: _cambio,
                        onChanged: (value) {
                          setState(() {
                            _cambio = value ?? false;
                          });
                          modificaCambio();
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

  Widget buildConclusoRow({required String title, required bool value, BuildContext? context}) {
    //bool isValueTooLong = value.length > 20;
    //String displayedValue = isValueTooLong ? value.substring(0, 20) + "..." : value;
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
                      Switch(
                        value: _concluso,
                        onChanged: (value) {
                          setState(() {
                            _concluso = value ?? false;
                          });
                          modificaConcluso();
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

  void modificaDescrizione() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/restituzioneMerce'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id.toString(),
          'prodotto' : widget.merce.prodotto.toString(),
          'data_acquisto': widget.merce.data_acquisto?.toIso8601String(),
          'difetto_riscontrato' : difettoController.text.toUpperCase(),
          'fornitore' : widget.merce.fornitore?.toMap(),
          'data_riconsegna': widget.merce.data_riconsegna?.toIso8601String(),
          'utenteRiconsegna': widget.merce.utenteRiconsegna?.toMap(),
          'rimborso': widget.merce.rimborso,
          'cambio': widget.merce.cambio,
          'data_rientro_ufficio' : widget.merce.data_rientro_ufficio?.toIso8601String(),
          'utenteRitiro': widget.merce.utenteRitiro?.toMap(),
          'concluso': widget.merce.concluso
        }),
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Difetto salvato con successo!'),
          ),
        );
        setState(() {
          widget.merce.difetto_riscontrato = difettoController.text;
          modificaDifettoVisible = !modificaDifettoVisible;
        });
      }
    } catch(e){
      print('Qualcosa non va: $e');
    }
  }

  void modificaDataRicon() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/restituzioneMerce'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id.toString(),
          'prodotto' : widget.merce.prodotto.toString(),
          'data_acquisto': widget.merce.data_acquisto?.toIso8601String(),
          'difetto_riscontrato' : widget.merce.difetto_riscontrato.toString(),//difettoController.text.toUpperCase(),
          'fornitore' : widget.merce.fornitore?.toMap(),
          'data_riconsegna': selectedDateRicon?.toIso8601String(),//widget.merce.data_riconsegna?.toIso8601String(),
          'utenteRiconsegna': widget.merce.utenteRiconsegna?.toMap(),
          'rimborso': widget.merce.rimborso,
          'cambio': widget.merce.cambio,
          'data_rientro_ufficio' : widget.merce.data_rientro_ufficio?.toIso8601String(),
          'utenteRitiro': widget.merce.utenteRitiro?.toMap(),
          'concluso': widget.merce.concluso
        }),
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data di riconsegna salvata con successo!'),
          ),
        );
        setState(() {
          //widget.merce.difetto_riscontrato = difettoController.text;
        });
      }
    } catch(e){
      print('Qualcosa non va: $e');
    }
  }

  void _showRiconDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleziona un Utente', textAlign: TextAlign.center),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lista degli utenti recuperati tramite la chiamata API
                  Column(
                    children: allUtenti.map((utente) {
                      return ListTile(
                        title: Text('${utente.nome} ${utente.cognome}'),
                        onTap: () async {
                          // Imposta l'utente selezionato come _selectedUtente
                          setState(() {
                            selectedUtenteRicon = utente;
                          });
                          try{
                            final response = await http.post(
                              Uri.parse('$ipaddress/api/restituzioneMerce'),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode({
                                'id': widget.merce.id.toString(),
                                'prodotto' : widget.merce.prodotto.toString(),
                                'data_acquisto': widget.merce.data_acquisto?.toIso8601String(),
                                'difetto_riscontrato' : widget.merce.difetto_riscontrato.toString(),//difettoController.text.toUpperCase(),
                                'fornitore' : widget.merce.fornitore?.toMap(),
                                'data_riconsegna': widget.merce.data_riconsegna?.toIso8601String(),
                                'utenteRiconsegna': selectedUtenteRicon,//widget.merce.utenteRiconsegna?.toMap(),
                                'rimborso': widget.merce.rimborso,
                                'cambio': widget.merce.cambio,
                                'data_rientro_ufficio' : widget.merce.data_rientro_ufficio?.toIso8601String(),
                                'utenteRitiro': widget.merce.utenteRitiro?.toMap(),
                                'concluso': widget.merce.concluso
                              }),
                            );
                            if(response.statusCode == 201){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Utente addetto alla riconsegna salvato con successo!'),
                                ),
                              );
                              setState(() {
                                //widget.merce.difetto_riscontrato = difettoController.text;
                              });
                            }
                          } catch(e){
                            print('Qualcosa non va: $e');
                          }
                          Navigator.of(context).pop();
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRitiroDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleziona un Utente', textAlign: TextAlign.center),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lista degli utenti recuperati tramite la chiamata API
                  Column(
                    children: allUtenti.map((utente) {
                      return ListTile(
                        title: Text('${utente.nome} ${utente.cognome}'),
                        onTap: () async {
                          // Imposta l'utente selezionato come _selectedUtente
                          setState(() {
                            selectedUtenteRitiro = utente;
                          });
                          try{
                            final response = await http.post(
                              Uri.parse('$ipaddress/api/restituzioneMerce'),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode({
                                'id': widget.merce.id.toString(),
                                'prodotto' : widget.merce.prodotto.toString(),
                                'data_acquisto': widget.merce.data_acquisto?.toIso8601String(),
                                'difetto_riscontrato' : widget.merce.difetto_riscontrato.toString(),//difettoController.text.toUpperCase(),
                                'fornitore' : widget.merce.fornitore?.toMap(),
                                'data_riconsegna': widget.merce.data_riconsegna?.toIso8601String(),
                                'utenteRiconsegna': widget.merce.utenteRiconsegna?.toMap(),
                                'rimborso': widget.merce.rimborso,
                                'cambio': widget.merce.cambio,
                                'data_rientro_ufficio' : widget.merce.data_rientro_ufficio?.toIso8601String(),
                                'utenteRitiro': selectedUtenteRitiro,//widget.merce.utenteRitiro?.toMap(),
                                'concluso': widget.merce.concluso
                              }),
                            );
                            if(response.statusCode == 201){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Utente addetto alla riconsegna salvato con successo!'),
                                ),
                              );
                              setState(() {
                                //widget.merce.difetto_riscontrato = difettoController.text;
                              });
                            }
                          } catch(e){
                            print('Qualcosa non va: $e');
                          }
                          Navigator.of(context).pop();
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  void modificaDataRientro() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/restituzioneMerce'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id.toString(),
          'prodotto' : widget.merce.prodotto.toString(),
          'data_acquisto': widget.merce.data_acquisto?.toIso8601String(),
          'difetto_riscontrato' : widget.merce.difetto_riscontrato.toString(),//difettoController.text.toUpperCase(),
          'fornitore' : widget.merce.fornitore?.toMap(),
          'data_riconsegna': widget.merce.data_riconsegna?.toIso8601String(),
          'utenteRiconsegna': widget.merce.utenteRiconsegna?.toMap(),
          'rimborso': widget.merce.rimborso,
          'cambio': widget.merce.cambio,
          'data_rientro_ufficio' : selectedDateRientro?.toIso8601String(),//widget.merce.data_rientro_ufficio?.toIso8601String(),
          'utenteRitiro': widget.merce.utenteRitiro?.toMap(),
          'concluso': widget.merce.concluso
        }),
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data di rientro in ufficio salvata con successo!'),
          ),
        );
        setState(() {
          //widget.merce.difetto_riscontrato = difettoController.text;
        });
      }
    } catch(e){
      print('Qualcosa non va: $e');
    }
  }

  void modificaRimborso() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/restituzioneMerce'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id.toString(),
          'prodotto' : widget.merce.prodotto.toString(),
          'data_acquisto': widget.merce.data_acquisto?.toIso8601String(),
          'difetto_riscontrato' : widget.merce.difetto_riscontrato.toString(),//difettoController.text.toUpperCase(),
          'fornitore' : widget.merce.fornitore?.toMap(),
          'data_riconsegna': widget.merce.data_riconsegna?.toIso8601String(),
          'utenteRiconsegna': widget.merce.utenteRiconsegna?.toMap(),
          'rimborso': _rimborso,//widget.merce.rimborso,
          'cambio': widget.merce.cambio,
          'data_rientro_ufficio' : widget.merce.data_rientro_ufficio?.toIso8601String(),
          'utenteRitiro': widget.merce.utenteRitiro?.toMap(),
          'concluso': widget.merce.concluso
        }),
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Modifica rimborso salvata con successo!'),
          ),
        );
        setState(() {
          //widget.merce.difetto_riscontrato = difettoController.text;
        });
      }
    } catch(e){
      print('Qualcosa non va: $e');
    }
  }

  void modificaCambio() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/restituzioneMerce'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id.toString(),
          'prodotto' : widget.merce.prodotto.toString(),
          'data_acquisto': widget.merce.data_acquisto?.toIso8601String(),
          'difetto_riscontrato' : widget.merce.difetto_riscontrato.toString(),//difettoController.text.toUpperCase(),
          'fornitore' : widget.merce.fornitore?.toMap(),
          'data_riconsegna': widget.merce.data_riconsegna?.toIso8601String(),
          'utenteRiconsegna': widget.merce.utenteRiconsegna?.toMap(),
          'rimborso': widget.merce.rimborso,
          'cambio': _cambio,//widget.merce.cambio,
          'data_rientro_ufficio' : widget.merce.data_rientro_ufficio?.toIso8601String(),
          'utenteRitiro': widget.merce.utenteRitiro?.toMap(),
          'concluso': widget.merce.concluso
        }),
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Modifica cambio salvata con successo!'),
          ),
        );
        setState(() {
          //widget.merce.difetto_riscontrato = difettoController.text;
        });
      }
    } catch(e){
      print('Qualcosa non va: $e');
    }
  }

  void modificaConcluso() async{
    try{
      final response = await http.post(
        Uri.parse('$ipaddress/api/restituzioneMerce'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': widget.merce.id.toString(),
          'prodotto' : widget.merce.prodotto.toString(),
          'data_acquisto': widget.merce.data_acquisto?.toIso8601String(),
          'difetto_riscontrato' : widget.merce.difetto_riscontrato.toString(),//difettoController.text.toUpperCase(),
          'fornitore' : widget.merce.fornitore?.toMap(),
          'data_riconsegna': widget.merce.data_riconsegna?.toIso8601String(),
          'utenteRiconsegna': widget.merce.utenteRiconsegna?.toMap(),
          'rimborso': widget.merce.rimborso,
          'cambio': widget.merce.cambio,
          'data_rientro_ufficio' : widget.merce.data_rientro_ufficio?.toIso8601String(),
          'utenteRitiro': widget.merce.utenteRitiro?.toMap(),
          'concluso': _concluso//widget.merce.concluso
        }),
      );
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Procedura conclusa con successo!'),
          ),
        );
        setState(() {

        });
      }
    } catch(e){
      print('Qualcosa non va: $e');
    }
  }

  Future<void> _selezionaDataRicon() async {
    final DateTime? dataSelezionata = await showDatePicker(
      locale: const Locale('it', 'IT'),
      context: context,
      initialDate: widget.merce.data_riconsegna == null ? _dataOdierna : widget.merce.data_riconsegna,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (dataSelezionata != null && dataSelezionata != _dataOdierna) {
      setState(() {
        selectedDateRicon = dataSelezionata;
      });
      if (dataSelezionata != widget.merce.data_riconsegna) modificaDataRicon();
    }
  }

  Future<void> _selezionaDataRientro() async {
    final DateTime? dataSelezionata = await showDatePicker(
      locale: const Locale('it', 'IT'),
      context: context,
      initialDate: widget.merce.data_rientro_ufficio == null ? _dataOdierna : widget.merce.data_rientro_ufficio,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (dataSelezionata != null && dataSelezionata != _dataOdierna) {
      setState(() {
        selectedDateRientro = dataSelezionata;
      });
      if (dataSelezionata != widget.merce.data_rientro_ufficio) modificaDataRientro();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dettaglio Merce RMA'.toUpperCase(),
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
                            Text('Info merce RMA'.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                            SizedBox(height: 10.0),
                            buildInfoRow(title: 'ID MERCE RMA', value: widget.merce.id!, context: context),
                            SizedBox(height: 10.0),
                            SizedBox(height: 10,),
                            buildInfoRow(
                                title: "prodotto", value: widget.merce.prodotto!, context: context),
                            SizedBox(height: 10.0),
                            buildInfoRow(title: 'data acquisto', value: (widget.merce.data_acquisto != null ? DateFormat('dd/MM/yyyy').format(widget.merce.data_acquisto!) : "N/A"), context: context),
                            SizedBox(height: 10.0),
                            Row(
                              children: [
                              SizedBox(
                              width: 500,
                              child:
                                buildInfoRow(
                                  title: "difetto riscontrato",
                                  value: widget.merce.difetto_riscontrato!,
                                  context: context
                                ),
                              ),
                                SizedBox(
                                  width: 10,
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      modificaDifettoVisible = !modificaDifettoVisible;
                                    });
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 15),
                            if(modificaDifettoVisible)
                              SizedBox(
                                  width: 500,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 300,
                                        child: TextFormField(
                                          maxLines: null,
                                          controller: difettoController,
                                          decoration: InputDecoration(
                                            labelText: 'Difetto riscontrato',
                                            hintText: 'Aggiungi difetto',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 170,
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Aggiunge padding attorno al FloatingActionButton
                                        decoration: BoxDecoration(
                                          // Puoi aggiungere altre decorazioni come bordi o ombre qui se necessario
                                        ),
                                        child: FloatingActionButton(
                                          heroTag: "Tag2",
                                          onPressed: () {
                                            if(difettoController.text.isNotEmpty){
                                              modificaDescrizione();
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Non è possibile salvare un difetto nullo!'),
                                                ),
                                              );
                                            }
                                          },
                                          backgroundColor: Colors.red,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Flexible( // Permette al testo di adattarsi alla dimensione del FloatingActionButton
                                                child: Text(
                                                  'Modifica Difetto'.toUpperCase(),
                                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                                  textAlign: TextAlign.center, // Centra il testo
                                                  softWrap: true, // Permette al testo di andare a capo
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                            SizedBox(height: 10.0),
                            buildInfoRow(title: 'fornitore', value: widget.merce.fornitore!.denominazione!, context: context),
                            SizedBox(height: 10.0),
                            Row(
                              children: [
                                SizedBox(
                                  width: 500,
                                  child:
                                  buildInfoRow(
                                      title: "data riconsegna",
                                      value: selectedDateRicon != null ? DateFormat('dd/MM/yyyy').format(selectedDateRicon!) : 'N/A',
                                      context: context
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                TextButton(
                                  onPressed: () {
                                    _selezionaDataRicon();
                                    /*setState(() {
                                      modificaDifettoVisible = !modificaDifettoVisible;
                                    });*/
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 10),

                            Row(
                              children: [
                                SizedBox(
                                  width: 500,
                                  child:
                                  buildInfoRow(
                                      title: "utente riconsegna",
                                      value: selectedUtenteRicon != null ? selectedUtenteRicon!.nome!+' '+selectedUtenteRicon!.cognome! : 'N/A',
                                      context: context
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                TextButton(
                                  onPressed: () {
                                    _showRiconDialog();
                                    /*setState(() {
                                      modificaDifettoVisible = !modificaDifettoVisible;
                                    });*/
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                            //buildInfoRow(title: "utente Riconsegna", value: widget.merce.utenteRiconsegna != null ? widget.merce.utenteRiconsegna!.nome!+' '+widget.merce.utenteRiconsegna!.cognome! : 'N/A', context: context),
                            SizedBox(height: 10.0),
                            buildRimborsoRow(title: "rimborso", value: widget.merce.rimborso!, context: context),
                            //buildInfoRow(title: "rimborso", value: widget.merce.rimborso != null ? (widget.merce.rimborso != true ? "NO" : "SI"): "N/A", context: context),
                            SizedBox(height: 10.0),
                            buildCambioRow(title: "cambio", value: widget.merce.cambio!, context: context),
                            //buildInfoRow(title: "cambio", value: widget.merce.cambio != null ? (widget.merce.cambio != true ? "NO" : "SI"): "N/A", context: context),
                            SizedBox(height: 10.0),
                            Row(
                              children: [
                                SizedBox(
                                  width: 500,
                                  child:
                                  buildInfoRow(
                                      title: "data rientro in ufficio",
                                      value: selectedDateRientro != null ? DateFormat('dd/MM/yyyy').format(selectedDateRientro!) : 'N/A',
                                      context: context
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                TextButton(
                                  onPressed: () {
                                    _selezionaDataRientro();
                                    /*setState(() {
                                      modificaDifettoVisible = !modificaDifettoVisible;
                                    });*/
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                            //buildInfoRow(title: "data rientro ufficio", value: (widget.merce.data_rientro_ufficio != null ? DateFormat('dd/MM/yyyy').format(widget.merce.data_rientro_ufficio!) : "N/A"), context: context),
                            SizedBox(height: 10.0),
                            Row(
                              children: [
                                SizedBox(
                                  width: 500,
                                  child:
                                  buildInfoRow(
                                      title: "utente ritiro",
                                      value: selectedUtenteRitiro != null ? selectedUtenteRitiro!.nome!+' '+selectedUtenteRitiro!.cognome! : 'N/A',
                                      context: context
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                TextButton(
                                  onPressed: () {
                                    _showRitiroDialog();
                                    /*setState(() {
                                      modificaDifettoVisible = !modificaDifettoVisible;
                                    });*/
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                            //buildInfoRow(title: "utente Ritiro", value: widget.merce.utenteRitiro != null ? widget.merce.utenteRitiro!.nome!+' '+widget.merce.utenteRitiro!.cognome! : 'N/A', context: context),
                            SizedBox(height: 10.0),
                            buildConclusoRow(title: "concluso", value: widget.merce.concluso!, context: context),
                          ],
                        )
                    ),
                    SizedBox(width: 30,),
                    Container(
                      child: SizedBox(
                        width: 600,
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
              ],
            ),
          ],
        )
      ),
    );
  }
}